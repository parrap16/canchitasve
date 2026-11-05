-- ============================================================================
-- CAIMANEROS — Fase 1: Booking de Canchas (Usuarios, Catálogo y Mapas)
-- Migración: 002_fase1_booking_catalogo.sql
-- ============================================================================

-- Habilitar extensiones necesarias
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- ── 1. Tabla de Perfiles ─────────────────────────────────────────────────────
-- Extiende auth.users con rol y datos del ecosistema Caimaneros
CREATE TABLE IF NOT EXISTS public.perfiles (
    id          UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    rol         TEXT NOT NULL CHECK (rol IN ('jugador', 'administrador')) DEFAULT 'jugador',
    nombre      TEXT NOT NULL,
    telefono    TEXT,
    created_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at  TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Trigger para updated_at en perfiles
CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER LANGUAGE plpgsql AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS set_perfiles_updated_at ON public.perfiles;
CREATE TRIGGER set_perfiles_updated_at
    BEFORE UPDATE ON public.perfiles
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- Función y trigger para auto-crear perfil básico tras registro en Supabase Auth
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER LANGUAGE plpgsql SECURITY DEFINER AS $$
BEGIN
    INSERT INTO public.perfiles (id, rol, nombre, telefono)
    VALUES (
        NEW.id,
        COALESCE(NEW.raw_user_meta_data->>'rol', 'jugador'),
        COALESCE(NEW.raw_user_meta_data->>'nombre', split_part(NEW.email, '@', 1)),
        NEW.raw_user_meta_data->>'telefono'
    )
    ON CONFLICT (id) DO UPDATE SET
        rol = EXCLUDED.rol,
        nombre = EXCLUDED.nombre,
        telefono = EXCLUDED.telefono,
        updated_at = NOW();
    RETURN NEW;
END;
$$;

DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created
    AFTER INSERT ON auth.users
    FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- ── 2. Tabla de Complejos Deportivos ─────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.complejos_deportivos (
    id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    admin_id     UUID NOT NULL REFERENCES public.perfiles(id) ON DELETE RESTRICT,
    nombre       TEXT NOT NULL,
    direccion    TEXT NOT NULL,
    latitud      DOUBLE PRECISION NOT NULL,
    longitud     DOUBLE PRECISION NOT NULL,
    foto_url     TEXT,
    precio_base  NUMERIC(10,2) NOT NULL DEFAULT 0.00,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS set_complejos_updated_at ON public.complejos_deportivos;
CREATE TRIGGER set_complejos_updated_at
    BEFORE UPDATE ON public.complejos_deportivos
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ── 3. Tabla de Canchas ──────────────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS public.canchas (
    id           UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    complejo_id  UUID NOT NULL REFERENCES public.complejos_deportivos(id) ON DELETE CASCADE,
    formato      INT NOT NULL CHECK (formato IN (5, 7, 11)),
    superficie   TEXT NOT NULL CHECK (superficie IN ('sintetica', 'tabloncillo')),
    techada      BOOLEAN NOT NULL DEFAULT FALSE,
    created_at   TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at   TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

DROP TRIGGER IF EXISTS set_canchas_updated_at ON public.canchas;
CREATE TRIGGER set_canchas_updated_at
    BEFORE UPDATE ON public.canchas
    FOR EACH ROW EXECUTE FUNCTION public.handle_updated_at();

-- ── Índices de Rendimiento y Búsqueda Geoespacial ────────────────────────────
CREATE INDEX IF NOT EXISTS idx_complejos_admin ON public.complejos_deportivos(admin_id);
CREATE INDEX IF NOT EXISTS idx_complejos_coords ON public.complejos_deportivos(latitud, longitud);
CREATE INDEX IF NOT EXISTS idx_canchas_complejo ON public.canchas(complejo_id);
CREATE INDEX IF NOT EXISTS idx_canchas_formato ON public.canchas(formato);

-- ── 4. Row Level Security (RLS) ──────────────────────────────────────────────

-- Perfiles
ALTER TABLE public.perfiles ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "perfiles_select_public" ON public.perfiles;
CREATE POLICY "perfiles_select_public"
    ON public.perfiles FOR SELECT
    USING (TRUE);

DROP POLICY IF EXISTS "perfiles_insert_own" ON public.perfiles;
CREATE POLICY "perfiles_insert_own"
    ON public.perfiles FOR INSERT
    WITH CHECK (auth.uid() = id);

DROP POLICY IF EXISTS "perfiles_update_own" ON public.perfiles;
CREATE POLICY "perfiles_update_own"
    ON public.perfiles FOR UPDATE
    USING (auth.uid() = id)
    WITH CHECK (auth.uid() = id);

-- Complejos Deportivos
ALTER TABLE public.complejos_deportivos ENABLE ROW LEVEL SECURITY;

-- Catálogo de lectura pública para todos los usuarios (jugadores y administradores)
DROP POLICY IF EXISTS "complejos_select_public" ON public.complejos_deportivos;
CREATE POLICY "complejos_select_public"
    ON public.complejos_deportivos FOR SELECT
    USING (TRUE);

-- Solo administradores autenticados pueden crear sus complejos
DROP POLICY IF EXISTS "complejos_insert_admin" ON public.complejos_deportivos;
CREATE POLICY "complejos_insert_admin"
    ON public.complejos_deportivos FOR INSERT
    WITH CHECK (
        auth.uid() = admin_id AND
        EXISTS (SELECT 1 FROM public.perfiles WHERE id = auth.uid() AND rol = 'administrador')
    );

-- Solo el administrador propietario puede actualizar su complejo
DROP POLICY IF EXISTS "complejos_update_admin" ON public.complejos_deportivos;
CREATE POLICY "complejos_update_admin"
    ON public.complejos_deportivos FOR UPDATE
    USING (auth.uid() = admin_id)
    WITH CHECK (auth.uid() = admin_id);

-- Solo el administrador propietario puede eliminar su complejo
DROP POLICY IF EXISTS "complejos_delete_admin" ON public.complejos_deportivos;
CREATE POLICY "complejos_delete_admin"
    ON public.complejos_deportivos FOR DELETE
    USING (auth.uid() = admin_id);

-- Canchas
ALTER TABLE public.canchas ENABLE ROW LEVEL SECURITY;

-- Lectura pública de canchas
DROP POLICY IF EXISTS "canchas_select_public" ON public.canchas;
CREATE POLICY "canchas_select_public"
    ON public.canchas FOR SELECT
    USING (TRUE);

-- Inserción, actualización y borrado solo por el administrador del complejo
DROP POLICY IF EXISTS "canchas_insert_admin" ON public.canchas;
CREATE POLICY "canchas_insert_admin"
    ON public.canchas FOR INSERT
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.complejos_deportivos cd
            WHERE cd.id = complejo_id AND cd.admin_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "canchas_update_admin" ON public.canchas;
CREATE POLICY "canchas_update_admin"
    ON public.canchas FOR UPDATE
    USING (
        EXISTS (
            SELECT 1 FROM public.complejos_deportivos cd
            WHERE cd.id = complejo_id AND cd.admin_id = auth.uid()
        )
    )
    WITH CHECK (
        EXISTS (
            SELECT 1 FROM public.complejos_deportivos cd
            WHERE cd.id = complejo_id AND cd.admin_id = auth.uid()
        )
    );

DROP POLICY IF EXISTS "canchas_delete_admin" ON public.canchas;
CREATE POLICY "canchas_delete_admin"
    ON public.canchas FOR DELETE
    USING (
        EXISTS (
            SELECT 1 FROM public.complejos_deportivos cd
            WHERE cd.id = complejo_id AND cd.admin_id = auth.uid()
        )
    );


-- ============================================================================
-- 5. SEED DE DATOS DE PRUEBA (MARACAIBO, VENEZUELA) — FASE 1
-- Ejecuta este bloque para insertar complejos reales de prueba
-- ============================================================================

-- Perfil de administrador de prueba
INSERT INTO public.perfiles (id, rol, nombre, telefono)
VALUES (
    'a0000000-0000-0000-0000-000000000001',
    'administrador',
    'Administrador Caimaneros Maracaibo',
    '+58 414 6123456'
)
ON CONFLICT (id) DO UPDATE SET
    rol = 'administrador',
    nombre = EXCLUDED.nombre;

-- Complejo 1: Vereda del Lago (Referencia 1)
INSERT INTO public.complejos_deportivos (id, admin_id, nombre, direccion, latitud, longitud, foto_url, precio_base)
VALUES (
    'b1000000-0000-0000-0000-000000000001',
    'a0000000-0000-0000-0000-000000000001',
    'Complejo Deportivo Vereda del Lago',
    'Paseo Vereda del Lago, Av. 2 El Milagro, Maracaibo, Zulia',
    10.655842,
    -71.603518,
    'https://images.unsplash.com/photo-1574629810360-7efbbe195018?q=80&w=1200&auto=format&fit=crop',
    25.00
)
ON CONFLICT (id) DO NOTHING;

-- Canchas de Vereda del Lago
INSERT INTO public.canchas (complejo_id, formato, superficie, techada)
VALUES
    ('b1000000-0000-0000-0000-000000000001', 5, 'sintetica', FALSE),
    ('b1000000-0000-0000-0000-000000000001', 7, 'sintetica', FALSE)
ON CONFLICT DO NOTHING;

-- Complejo 2: Complejo La Estancia / Bella Vista (Referencia 2)
INSERT INTO public.complejos_deportivos (id, admin_id, nombre, direccion, latitud, longitud, foto_url, precio_base)
VALUES (
    'b2000000-0000-0000-0000-000000000002',
    'a0000000-0000-0000-0000-000000000001',
    'Complejo Deportivo La Estancia',
    'Calle 67 con Av. 3D, Sector La Lago / Bella Vista, Maracaibo, Zulia',
    10.678125,
    -71.618450,
    'https://images.unsplash.com/photo-1529900748604-07564a03e7a6?q=80&w=1200&auto=format&fit=crop',
    30.00
)
ON CONFLICT (id) DO NOTHING;

-- Canchas de La Estancia
INSERT INTO public.canchas (complejo_id, formato, superficie, techada)
VALUES
    ('b2000000-0000-0000-0000-000000000002', 5, 'sintetica', TRUE),
    ('b2000000-0000-0000-0000-000000000002', 5, 'tabloncillo', TRUE),
    ('b2000000-0000-0000-0000-000000000002', 7, 'sintetica', FALSE)
ON CONFLICT DO NOTHING;

-- Complejo 3: San Francisco Futsal Arena
INSERT INTO public.complejos_deportivos (id, admin_id, nombre, direccion, latitud, longitud, foto_url, precio_base)
VALUES (
    'b3000000-0000-0000-0000-000000000003',
    'a0000000-0000-0000-0000-000000000001',
    'San Francisco Futsal & Soccer Arena',
    'Av. 5 Urb. Coromoto, Sector Plaza El Sol, San Francisco, Zulia',
    10.612500,
    -71.642100,
    'https://images.unsplash.com/photo-1508098682722-e99c43a406b2?q=80&w=1200&auto=format&fit=crop',
    35.00
)
ON CONFLICT (id) DO NOTHING;

-- Canchas de San Francisco Arena
INSERT INTO public.canchas (complejo_id, formato, superficie, techada)
VALUES
    ('b3000000-0000-0000-0000-000000000003', 5, 'sintetica', TRUE),
    ('b3000000-0000-0000-0000-000000000003', 11, 'sintetica', FALSE)
ON CONFLICT DO NOTHING;
