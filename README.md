# SearchMyCar

Aplicación Flutter para registrar y localizar vehículos.

## Configurar Supabase

1. Crea un proyecto en [Supabase](https://supabase.com).
2. En **Authentication → Providers**, verifica que el proveedor **Email** esté habilitado.
3. Crea un usuario de prueba en **Authentication → Users**. Si la confirmación por correo está
   activa, marca la opción para confirmarlo automáticamente.
4. En **Project Settings → API** copia la **Project URL** y la **clave pública**
   (`publishable` o `anon`).
5. Abre `lib/src/config/supabase_config.dart` y coloca tus datos en las
   constantes `_urlPorDefecto` y `_clavePorDefecto`:

```dart
static const String _urlPorDefecto = 'https://tu-proyecto.supabase.co';
static const String _clavePorDefecto = 'tu_clave_publica';
```

También puedes evitar editar el archivo usando:

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=tu_clave_publica
```

Nunca uses la clave `service_role` o `secret` dentro de la aplicación.

## Ejecutar

```bash
flutter pub get
flutter run
```

## Verificar

```bash
flutter analyze
flutter test
```
