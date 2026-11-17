# flow_academic

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
# FlowAcademic — Primer incremento funcional

App móvil (Flutter + Firebase) que ordena las tareas académicas del estudiante
según fecha de entrega, importancia, dificultad y rendimiento en la materia.

## Qué está implementado
- Registro e inicio de sesión (correo y contraseña).
- Registro de materias y tareas, con validación de campos.
- Lista priorizada con explicación «¿Por qué este orden?».
- Marcar una tarea como completada.

## Qué NO está implementado
Recomendaciones con IA, registro de notas, notificaciones, sincronización con
el portal universitario.

## Requisitos
- Flutter [completar con la salida de `flutter --version`]
- Android Studio con un emulador, o un celular Android con depuración USB
- Conexión a internet (la app usa Firebase). No hace falta configurar Firebase:
  `lib/firebase_options.dart` ya apunta al proyecto del equipo.

## Instalación y arranque
    git clone https://github.com/sebascatala/flow_academic
    cd flow_academic
    flutter pub get
    flutter run

## Pruebas automáticas
    flutter test

## Datos de prueba
No hay cuentas precargadas ni credenciales. Registra una cuenta nueva desde la
app (cualquier correo y una contraseña de al menos 6 caracteres) y crea:
- Materia «Cálculo II», promedio 40.
- Materia «Historia», promedio 90.
- Tarea A: Historia, vence en 2 días, dificultad 1, importancia 1.
- Tarea B: Cálculo II, vence en 5 días, dificultad 5, importancia 5.

## Cómo comprobar los criterios de aceptación
- **CA-06:** con los datos anteriores, la tarea B aparece sobre la A, aunque A
  vence antes.
- **CA-03:** al crear una tarea sin elegir la dificultad, aparece «Elige una
  dificultad del 1 al 5.» y no se guarda nada.

## Limitaciones conocidas
- Requiere internet; sin conexión no se puede guardar.
- La regla de priorización es provisional (pesos sin validar con usuarios).
- [agregar errores pendientes que encuentren]

## Versión de entrega
Etiqueta `v0.1-parcial1` — commit [hash]