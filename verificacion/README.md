# FlowAcademic — Reproducción de la verificación del MVP

Proyecto de Ingeniería de Software · UPB · gestión 2026

## 1. Alcance y revisión

Este documento complementa el informe *FlowAcademic: primer incremento funcional*, secciones V.1–V.4 y anexo C. Se verifica el registro de tareas y su priorización, sin añadir funcionalidades al MVP.

- Repositorio: https://github.com/sebascatala/flow_academic
- Línea base: `4d2221ea5c9f02bd046812ab1ed0076ea49f3706`.
- Incorporación de pruebas: `70ac26e46f24b6323a5c04a3b4ebaa308f06c87e`.
- Revisión de referencia con evidencias: `716956b856b57101dca6a81762d5f75a26709a02`.
- Rama: `pruebas`. PR: https://github.com/sebascatala/flow_academic/pull/1 (observaciones pendientes).

## 2. Preparación del entorno

Se requiere Git, Flutter/Dart, Android SDK y emulador Android, Node.js, Firebase CLI y Java compatible con el emulador de Firestore. En Windows se utilizó PowerShell. Registrar versiones exactas antes de repetir la prueba; no se dispone de ellas en el registro inicial.

Desde una carpeta de trabajo nueva, con acceso al repositorio:

```powershell
git clone --branch pruebas https://github.com/sebascatala/flow_academic.git
cd flow_academic
git switch --detach 716956b856b57101dca6a81762d5f75a26709a02
git rev-parse HEAD
git status --short
flutter --version
flutter doctor -v
node -v
npm -v
firebase --version
java -version
flutter pub get
flutter devices
```

Si Firebase CLI no está instalado: `npm install -g firebase-tools`. No reemplazar el pubspec ni actualizar dependencias deliberadamente. Conservar las versiones registradas en `pubspec.lock`. Si el repositorio requiere autenticación, usar el acceso propio sin incluir credenciales en evidencias.

## 3. Pruebas unitarias y de widgets

Usar una carpeta de salida distinta de los logs originales para conservar las evidencias históricas:

```powershell
New-Item -ItemType Directory -Force evidencias/reproduccion
flutter test --reporter expanded 2>&1 | Tee-Object evidencias/reproduccion/unitarias.txt
$LASTEXITCODE
```

Resultado de referencia reportado el 24/11/2026: 18 pruebas aprobadas (17 unitarias y una de widgets). El código de salida esperado es 0. Registrar el resultado real incluso si difiere.

| ID | Archivo | Comportamiento esperado |
|---|---|---|
| U-01 | `test/prioritization/calculador_prioridad_test.dart` | CA-06: B precede a A aunque vence después. |
| U-02 | `test/academic/validadores_tarea_test.dart` | CA-03: dificultad ausente rechazada con mensaje exacto. |
| U-03 | `test/prioritization/calculador_prioridad_test.dart` | CA-08: exclusión de tareas completadas. |

## 4. Pruebas de integración y fallo

Abrir un emulador Android. En una terminal independiente, desde la raíz:

```powershell
firebase emulators:start --only firestore --project demo-flowacademic --config verificacion/firebase.test.json
```

Esperar `All emulators ready!` y comprobar Firestore en `127.0.0.1:8080`. Mantener la terminal abierta. En otra terminal:

```powershell
flutter devices
flutter test integration_test/verificacion_mvp_test.dart -d emulator-5554 --dart-define=FIRESTORE_HOST=10.0.2.2 --reporter expanded 2>&1 | Tee-Object evidencias/reproduccion/integracion.txt
$LASTEXITCODE
```

Sustituir `emulator-5554` por el identificador real. `10.0.2.2` corresponde al acceso al host desde el emulador Android estándar. Las pruebas inicializan una aplicación Firebase separada con proyecto demo, desactivan persistencia local y usan los repositorios reales contra el emulador. No desplegar `verificacion/firestore.rules` ni conectarse a producción.

## 5. Datos controlados y resultados esperados

| ID | Estado inicial y acción | Aserciones |
|---|---|---|
| I-01 | Usuario ficticio `mvp-i01`; Historia (90) y Cálculo II (40). Crear A (2 días, dificultad/importancia 1), después B (5 días, dificultad/importancia 5). | B posición 1, A posición 2; dos documentos en servidor; campos de B correctos y sin error del provider. |
| I-02 | Usuario `mvp-i02`; materia Historia y tarea A existentes. Abrir formulario, ingresar título ficticio, materia, fecha e importancia, omitir dificultad y guardar. | Mensaje exacto de dificultad, título conservado y único documento anterior sin cambios. |
| F-01 | Usuario `mvp-f01`; colección vacía y regla local que deniega escrituras. Completar formulario e intentar guardar. | Mensaje de error de guardado, formulario abierto, título conservado y colección vacía. |

Las fechas de integración son relativas al día de ejecución. El código incluye limpieza de las subcolecciones de materias y tareas de I-01 e I-02 antes y después de cada caso. F-01 comprueba colección vacía y no permite escritura. Usar instancia nueva del emulador sin importación de datos. Si una ejecución se interrumpe, detener y reiniciar el emulador sin importar datos para restaurar el estado. Al terminar, detenerlo con Ctrl+C; no exportar datos de producción.

Resultado de referencia reportado: I-01, I-02 y F-01 aprobadas; salida `00:28 +3: All tests passed!`. Total con la suite anterior: 21 aprobadas. La captura y salida compartidas respaldan los resultados; este README no constituye una ejecución adicional.

## 6. Registro de reproducción

Completar por cada nueva ejecución:

- Fecha y responsable:
- Commit (`git rev-parse HEAD`) y estado (`git status --short`):
- Versiones de Flutter, Dart, Firebase CLI, Java y Android/dispositivo:
- Comandos ejecutados y códigos de salida:
- Resultados por ID (aprobado, fallido, no ejecutado o bloqueado):
- Ruta del log y capturas, si corresponde:
- Defectos, intervención y resultado de reejecución:
- Restauración del entorno:

Evidencias originales previstas: `evidencias/unitarias.txt` y `evidencias/integracion.txt`. Confirmar su presencia y contenido en la revisión de referencia. Las nuevas salidas se guardan en `evidencias/reproduccion/`. No incluir datos personales ni credenciales.

## 7. Límites y revisión

La prueba I-01 comprueba el estado reactivo del provider, no el aviso visual del puesto de `main.dart`. I-02 comprueba la validación del formulario, no la garantía frente a llamadas directas al repositorio. F-01 comprueba una denegación controlada, no todos los fallos de red. Las reglas locales no certifican seguridad de producción ni autenticación real. Los pesos del algoritmo no están validados con usuarios.

Si cambia CA-03 revisar U-02 e I-02; si cambia CA-06 revisar U-01 e I-01; si cambia CA-07 revisar I-01 y la prueba de recálculo; si cambia CA-08 revisar U-03. Si cambia el manejo de errores, revisar F-01.

Revisión entre pares: PR #1, pendiente de observaciones, respuesta y decisión verificables. No declarar una revisión realizada hasta contar con evidencia del compañero.
