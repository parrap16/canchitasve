# CAIMANEROS — Monorepo

> Ecosistema de fútbol aficionado en Venezuela.

## Proyectos

| Proyecto | Stack | Estado |
|----------|-------|--------|
| [`canchitas-web/`](./canchitas-web) | Next.js 14 + Supabase | 🟡 Fase 0 — Configuración base |
| [`caimaneros-app/`](.) | Flutter + Supabase + Riverpod | 🟡 Fase 0 — Configuración base |

## Requisitos del entorno de desarrollo

- **Flutter** ≥ 3.4 (para `caimaneros-app`)
- **Node.js** ≥ 20 + **npm** ≥ 10 (para `canchitas-web`)
- **Supabase CLI** (para migraciones de BD)

## Inicio rápido — Canchitas

```bash
# 1. Entrar al proyecto web
cd canchitas-web

# 2. Instalar dependencias
npm install

# 3. Configurar entorno
cp .env.example .env.local
# Editar .env.local con tus credenciales de Supabase

# 4. Aplicar esquema de base de datos
npx supabase db push
# O ejecutar supabase/migrations/001_schema_inicial.sql en el dashboard

# 5. Iniciar servidor de desarrollo
npm run dev
# → http://localhost:3000
```

## Inicio rápido — Caimaneros App

```bash
# Desde la raíz
flutter pub get
flutter run
```
