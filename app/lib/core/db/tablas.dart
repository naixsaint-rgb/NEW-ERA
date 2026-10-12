import 'package:drift/drift.dart';

// Convenciones: ids TEXT (UUID v4; ULID en eventos); tiempos INTEGER en ms UTC;
// JSON en TEXT. Los hechos son de solo inserción (disparadores en base_datos.dart).

// ---------------------------------------------------------------- Fichas

@DataClassName('Circulo')
class Circulos extends Table {
  TextColumn get id => text()();
  TextColumn get nombre => text()();
  IntColumn get creadoEn => integer()();
  IntColumn get versionClave => integer().withDefault(const Constant(1))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Persona')
class Personas extends Table {
  TextColumn get id => text()();
  TextColumn get circuloId => text().references(Circulos, #id)();
  TextColumn get alias => text()();
  TextColumn get fotoId => text().nullable().references(Fotos, #id)();
  TextColumn get zonaHoraria =>
      text().withDefault(const Constant('Europe/Madrid'))();
  IntColumn get creadaEn => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Miembro')
class Miembros extends Table {
  TextColumn get id => text()();
  TextColumn get circuloId => text().references(Circulos, #id)();
  TextColumn get nombre => text()();
  TextColumn get relacion => text()();
  TextColumn get telefono => text().nullable()();
  TextColumn get fotoId => text().nullable().references(Fotos, #id)();

  /// `responsable`, `cuidador`, `apoyo` o `lectura`.
  TextColumn get rol => text()();
  IntColumn get ordenEscalado => integer().nullable()();
  BoolColumn get enMiGente => boolean().withDefault(const Constant(true))();
  IntColumn get creadoEn => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Dispositivo')
class Dispositivos extends Table {
  TextColumn get id => text()();
  TextColumn get circuloId => text().references(Circulos, #id)();

  /// `persona` o `familia`.
  TextColumn get perfil => text()();

  /// `ios`, `android` o `web`.
  TextColumn get plataforma => text()();
  TextColumn get miembroId => text().nullable().references(Miembros, #id)();
  IntColumn get registradoEn => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Medicamento')
class Medicamentos extends Table {
  TextColumn get id => text()();
  TextColumn get personaId => text().references(Personas, #id)();
  TextColumn get nombre => text()();
  TextColumn get nombreParaPersona => text()();

  /// `redonda`, `ovalada`, `capsula` u `otra`.
  TextColumn get forma => text()();
  TextColumn get color => text().nullable()();
  @ReferenceName('medicamentosDeCaja')
  TextColumn get fotoCajaId => text().nullable().references(Fotos, #id)();
  @ReferenceName('medicamentosDePastilla')
  TextColumn get fotoPastillaId => text().nullable().references(Fotos, #id)();
  TextColumn get registroCima => text().nullable()();
  IntColumn get creadoEn => integer()();
  IntColumn get retiradoEn => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Voz')
class Voces extends Table {
  TextColumn get id => text()();
  TextColumn get miembroId => text().references(Miembros, #id)();

  /// `grabada` o `generada`.
  TextColumn get tipo => text()();
  TextColumn get modelo => text().nullable()();
  TextColumn get consentimientoId =>
      text().nullable().references(Consentimientos, #id)();
  IntColumn get creadaEn => integer()();
  IntColumn get retiradaEn => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Frase')
class Frases extends Table {
  TextColumn get id => text()();
  TextColumn get vozId => text().references(Voces, #id)();
  TextColumn get texto => text()();
  TextColumn get uso => text()();
  TextColumn get audioRuta => text().nullable()();
  BoolColumn get aprobada => boolean()();
  IntColumn get creadaEn => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

// ---------------------------------------------------------------- Hechos

@DataClassName('Foto')
class Fotos extends Table {
  TextColumn get id => text()();
  BlobColumn get bytes => blob()();
  TextColumn get mime => text()();
  IntColumn get creadaEn => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Pauta')
@TableIndex(name: 'pautas_por_pauta', columns: {#pautaId, #version})
class Pautas extends Table {
  /// Id de la versión.
  TextColumn get id => text()();

  /// Id lógico de la pauta, común a todas sus versiones.
  TextColumn get pautaId => text()();
  IntColumn get version => integer()();
  TextColumn get medicamentoId => text().references(Medicamentos, #id)();
  TextColumn get personaId => text().references(Personas, #id)();
  TextColumn get dosis => text()();

  /// JSON `["09:00","14:00"]`, ordenadas y sin repetir.
  TextColumn get horas => text()();
  IntColumn get diasSemana => integer().withDefault(const Constant(127))();
  TextColumn get compartimento => text().nullable()();
  TextColumn get vozId => text().nullable().references(Voces, #id)();

  /// `video`, `foto` o `ninguna`.
  TextColumn get comprobacion => text().withDefault(const Constant('video'))();
  IntColumn get segundosVideo => integer().withDefault(const Constant(10))();
  TextColumn get zonaHoraria => text()();
  IntColumn get vigenteDesde => integer()();
  BoolColumn get activa => boolean()();
  TextColumn get motivo => text().nullable()();
  TextColumn get creadaPor => text()();
  IntColumn get creadaEn => integer()();

  @override
  Set<Column> get primaryKey => {id};

  @override
  List<Set<Column>> get uniqueKeys => [
    {pautaId, version},
  ];
}

/// Sin columna de estado: se calcula con los eventos.
@DataClassName('Toma')
class Tomas extends Table {
  TextColumn get id => text()();
  TextColumn get pautaVersionId => text().references(Pautas, #id)();
  TextColumn get personaId => text().references(Personas, #id)();
  IntColumn get previstaPara => integer()();
  TextColumn get fechaLocal => text()();
  TextColumn get horaLocal => text()();
  IntColumn get creadaEn => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('ComprobacionToma')
class Comprobaciones extends Table {
  TextColumn get id => text()();
  TextColumn get tomaId => text().references(Tomas, #id)();
  TextColumn get clipEventoUlid => text()();
  TextColumn get revisorMiembroId => text().references(Miembros, #id)();

  /// `verificada` o `dudosa`.
  TextColumn get veredicto => text()();
  TextColumn get nota => text().nullable()();
  IntColumn get revisadaEn => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Evento')
@TableIndex(name: 'eventos_por_sujeto', columns: {#sujeto, #ocurridoEn})
@TableIndex(name: 'eventos_por_tipo', columns: {#tipo, #ocurridoEn})
class Eventos extends Table {
  TextColumn get ulid => text()();
  TextColumn get circuloId => text().references(Circulos, #id)();

  /// Miembro o persona.
  TextColumn get autor => text()();
  TextColumn get dispositivo => text()();
  TextColumn get tipo => text()();

  /// Id de toma, medicamento…
  TextColumn get sujeto => text().nullable()();
  IntColumn get ocurridoEn => integer()();
  IntColumn get registradoEn => integer()();
  TextColumn get payload => text().withDefault(const Constant('{}'))();
  TextColumn get corrigeA => text().nullable()();

  @override
  Set<Column> get primaryKey => {ulid};
}

@DataClassName('PreguntaControl')
class PreguntasControl extends Table {
  TextColumn get id => text()();
  TextColumn get personaId => text().references(Personas, #id)();

  /// `estado`, `dolor`, `plan` o `si_no`.
  TextColumn get tipo => text()();
  TextColumn get texto => text()();
  TextColumn get fraseId => text().nullable().references(Frases, #id)();
  IntColumn get lanzadaEn => integer()();

  /// `movil`, `reloj` o `cuidador`.
  TextColumn get origen => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Respuesta')
class Respuestas extends Table {
  TextColumn get id => text()();
  TextColumn get preguntaId => text().references(PreguntasControl, #id)();
  TextColumn get valor => text()();
  TextColumn get audioRuta => text().nullable()();
  IntColumn get respondidaEn => integer()();
  TextColumn get origen => text()();
  RealColumn get latitud => real().nullable()();
  RealColumn get longitud => real().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Consentimiento')
class Consentimientos extends Table {
  TextColumn get id => text()();
  TextColumn get circuloId => text().references(Circulos, #id)();
  TextColumn get otorgante => text()();
  TextColumn get enNombreDe => text().nullable()();

  /// `voz`, `grabacion_consulta`, `video_toma`, `ubicacion` o `datos`.
  TextColumn get sobre => text()();
  TextColumn get textoMostrado => text()();
  TextColumn get documentoFotoId => text().nullable().references(Fotos, #id)();
  IntColumn get otorgadoEn => integer()();
  TextColumn get revocaA => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Comida')
class Comidas extends Table {
  TextColumn get id => text()();
  TextColumn get personaId => text().references(Personas, #id)();

  /// `desayuno`, `comida`, `merienda`, `cena` u `otro`.
  TextColumn get momento => text()();

  /// `todo`, `mitad`, `poco` o `nada`.
  TextColumn get cuanto => text()();
  TextColumn get fotoId => text().nullable().references(Fotos, #id)();
  TextColumn get nota => text().nullable()();
  IntColumn get ocurridaEn => integer()();
  TextColumn get registradaPor => text()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('Hidratacion')
class Hidrataciones extends Table {
  TextColumn get id => text()();
  TextColumn get personaId => text().references(Personas, #id)();
  IntColumn get vasos => integer().withDefault(const Constant(1))();
  IntColumn get ocurridaEn => integer()();
  TextColumn get registradaPor => text()();

  @override
  Set<Column> get primaryKey => {id};
}
