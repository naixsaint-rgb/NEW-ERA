# ADR-0004 · iPhone e iOS 26 con AlarmKit para la persona
Fecha: 2026-10-12 · Estado: aceptada
## Contexto
La persona usa un iPhone 12 mini (admite iOS 26) y llevará Apple Watch.
## Decisión
La alarma que no para se implementa con AlarmKit (iOS 26) y llega al Apple Watch emparejado. Plan B si falla:
avisos repetidos de prioridad alta y alertas críticas solicitadas a Apple. Mientras no haya cuenta de
desarrollador, se prueba con Apple ID gratuito desde Xcode (instalaciones de 7 días) y con el simulador.
## Consecuencias
La cuenta de Apple Developer es inevitable para instalar de forma estable; se dará de alta tras la demo.
Pendiente de probar en la semana 1: apagado desde el reloj y voz grabada como sonido de la alarma.
