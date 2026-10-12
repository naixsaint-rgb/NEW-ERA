# ADR-0001 · Dos apps sobre un solo código Flutter
Fecha: 2026-10-12 · Estado: aceptada
## Contexto
El promotor pide la app de la persona (iPhone y Apple Watch) y la app de la familia (Android e iPhone).
## Decisión
Un solo proyecto Flutter con dos perfiles (persona y familia) elegidos al emparejar el dispositivo, más una
capa nativa Swift para AlarmKit y Acceso Asistido, y una app watchOS en Swift. Android queda como ruta
alternativa para otras familias.
## Alternativas rechazadas
Dos proyectos separados (duplica modelo de datos y cifrado); nativo doble (duplica todo); solo PWA (sin alarmas fiables).
## Consecuencias
Un modelo de datos y un cifrado compartidos; la demo web sale del mismo código; iOS se compila con Codemagic.
