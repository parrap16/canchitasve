// Archivo de barril del módulo auth.
// Exporta la API pública de la feature.

// data
export 'data/models/usuario_model.dart';
export 'data/repositories/auth_repository_impl.dart';

// domain
export 'domain/entities/usuario.dart';
export 'domain/entities/usuario_perfil.dart';
export 'domain/repositories/i_auth_repository.dart';
export 'domain/usecases/sign_in_usecase.dart';
export 'domain/usecases/sign_out_usecase.dart';
export 'domain/usecases/sign_up_usecase.dart';

// presentation
export 'presentation/controllers/auth_controller.dart';
export 'presentation/pages/login_page.dart';
export 'presentation/pages/register_page.dart';
