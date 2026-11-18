# SearchMyCar

Aplicación Flutter para registrar y localizar vehículos. Cada usuario inicia sesión con
Supabase y administra únicamente sus propios vehículos (bicicleta, moto o auto).

## Configurar Supabase

1. Crea un proyecto en [Supabase](https://supabase.com).
2. En **Authentication → Providers**, verifica que el proveedor **Email** esté habilitado.
   Puedes dejar activa la confirmación por correo o desactivarla en
   **Authentication → Sign In / Providers → Email**.
3. En **Project Settings → API** copia la **Project URL** y la **clave pública**
   (`publishable` o `anon`).
4. Crea tu archivo `.env` en la raíz del proyecto a partir de la plantilla:

```bash
cp .env.example .env
```

Y coloca tus datos:

```dotenv
SUPABASE_URL=https://tu-proyecto.supabase.co
SUPABASE_ANON_KEY=tu_clave_publica
```

La app carga ese archivo con `flutter_dotenv` al iniciar (ver
`lib/src/config/supabase_config.dart`). `.env` está en `.gitignore`, así que no se sube
al repositorio. También se aceptan los nombres `Url` y `Key`.

Si prefieres no usar `.env`, puedes pasar los valores al ejecutar la app (tienen prioridad):

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://tu-proyecto.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=tu_clave_publica
```

Nunca uses la clave `service_role` o `secret` dentro de la aplicación.

## Preparar la base de datos

Ejecuta **en orden** estos archivos completos en **Supabase → SQL Editor**:

1. `supabase/migrations/20261030000000_vehiculos_crud.sql`
2. `supabase/migrations/20261109000000_ubicaciones.sql`

La primera migración:

- Crea la tabla `public.vehiculos` si todavía no existe.
- Agrega la columna `categoria` con los valores `bicicleta`, `moto` y `auto`.
- Relaciona cada vehículo con `auth.users` mediante `user_id`.
- Activa RLS y crea políticas para que cada usuario solo pueda ver, crear, actualizar y
  eliminar sus propios vehículos.
- Hace que la patente sea única por usuario.

La segunda migración:

- Crea la tabla `public.ubicaciones` con latitud, longitud, precisión y fecha.
- Relaciona cada ubicación con un vehículo del mismo usuario.
- Activa RLS para que cada usuario solo vea y guarde sus propias ubicaciones.
- Impide guardar una ubicación usando el vehículo de otra cuenta.

Ambas son idempotentes, así que puedes ejecutarlas más de una vez sin problema. Si ya tenías
una tabla `vehiculos` de una versión anterior, la migración intenta conservar sus columnas y
datos existentes.

## Mapa y ubicación

El mapa usa [`flutter_map`](https://pub.dev/packages/flutter_map) con las teselas públicas de
OpenStreetMap y la geolocalización del dispositivo mediante `geolocator`.

- La app solicita permiso de ubicación al abrir el mapa.
- Muestra un marcador con tu posición actual y permite actualizarla con el botón de ubicación.
- En “Vehículo en uso” puedes elegir cuál de tus vehículos estás usando.
- Al pulsar **Guardar ubicación** se crea un registro en `public.ubicaciones` con la
  ubicación actual y el vehículo seleccionado.
- La pestaña **Registros** muestra el historial de ubicaciones guardadas, con vehículo,
  fecha, coordenadas y precisión.
- Si no tienes vehículos, el mapa ofrece un botón para agregar uno.

En Android ya están declarados los permisos `ACCESS_FINE_LOCATION` y `ACCESS_COARSE_LOCATION`.
Si agregas la plataforma iOS, incluye en `Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>SearchMyCar usa tu ubicación para guardar dónde estacionaste tu vehículo.</string>
```

Las teselas públicas de OpenStreetMap son adecuadas para desarrollo y uso moderado. Para una
app con mucho tráfico, usa un proveedor de teselas con plan gratuito o de pago y actualiza la
URL en `lib/src/pages/mapa_page.dart`.

## Uso

1. Abre la app y pulsa **Regístrate** para crear una cuenta con correo y contraseña.
2. Si la confirmación por correo está activa, revisa tu bandeja de entrada y confirma la
   cuenta antes de iniciar sesión.
3. Inicia sesión y entra a la pestaña **Vehículos**.
4. Usa **Agregar** para registrar una bicicleta, moto o auto.
5. Toca un vehículo o su menú para editarlo o eliminarlo.
6. Vuelve a **Mapa**, elige el vehículo en uso y pulsa **Guardar ubicación**.
7. Entra a **Registros** para ver el historial de ubicaciones guardadas.
8. En **Ajustes** puedes ver la cuenta activa y cerrar sesión.

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
