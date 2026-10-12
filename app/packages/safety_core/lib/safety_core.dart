/// Lógica pura de NEW-ERA: tomas previstas, estados, escalado y utilidades.
///
/// Solo depende de `timezone`. Nadie fuera de [RelojSistema] llama a
/// `DateTime.now()`.
library;

export 'src/reloj.dart';
export 'src/ulid.dart';
export 'src/tipos.dart';
export 'src/proximas_tomas.dart';
export 'src/estado_toma.dart';
export 'src/escalado.dart';
export 'src/parte_del_dia.dart';
export 'src/id_alarma.dart';
export 'src/zonas.dart';
