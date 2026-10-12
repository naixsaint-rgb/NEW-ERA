/// Los 9 apartados del dosier de un tema, con el nombre del origen y su
/// valor tal cual (texto o lista de textos).
final class Dosier {
  const Dosier(this.apartados);

  factory Dosier.desdeJson(Map<String, dynamic> json) => Dosier({
    for (final e in json.entries)
      e.key: e.value is List
          ? [for (final x in e.value as List<dynamic>) x.toString()]
          : e.value?.toString(),
  });

  /// Orden y nombres del origen: `tesis`, `defensores`, `mecanismos`...
  final Map<String, Object?> apartados;

  /// Dosier resumido: los apartados tal cual (sin las `notas`).
  int get numeroApartados => apartados.length;
}

final class TemaCatalogo {
  const TemaCatalogo({
    required this.key,
    required this.titulo,
    required this.nFilas,
    required this.dosier,
  });

  factory TemaCatalogo.desdeJson(Map<String, dynamic> json) => TemaCatalogo(
    key: json['key'] as String,
    titulo: json['titulo'] as String,
    nFilas: json['n_filas'] as int,
    dosier: Dosier.desdeJson(
      Map<String, dynamic>.from(json['dosier'] as Map<dynamic, dynamic>),
    ),
  );

  final String key;
  final String titulo;
  final int nFilas;
  final Dosier dosier;
}

/// Una fila: lo que reporta una fuente, con su cifra tal cual.
final class FilaCatalogo {
  FilaCatalogo({
    required this.id,
    required this.temaIndice,
    required this.temaKey,
    required this.grupo,
    required this.intervencion,
    required this.tradicionOAngulo,
    required this.estudio,
    required this.tipoFuente,
    required this.diseno,
    required this.n,
    required this.poblacion,
    required this.duracion,
    required this.dosisOProtocolo,
    required this.queMidio,
    required this.resultadoReportado,
    required this.direccionSegunLaFuente,
    required this.efectosAdversosReportados,
    required this.financiacionYConflictos,
    required this.comoProbarloEnCasa,
    required this.costeAprox,
    required this.enlace,
    required this.identificador,
    required this.verificacion,
  });

  /// Construye la fila buscando cada valor por el nombre de su columna.
  factory FilaCatalogo.desdeArray(
    List<dynamic> fila,
    Map<String, int> columnas,
    String Function(int) temaKeyDe,
  ) {
    String? s(String c) {
      final v = fila[columnas[c]!];
      if (v == null) return null;
      final t = v.toString();
      return t.isEmpty ? null : t;
    }

    final temaIndice = fila[columnas['tema']!] as int;
    return FilaCatalogo(
      id: s('id')!,
      temaIndice: temaIndice,
      temaKey: temaKeyDe(temaIndice),
      grupo: s('grupo'),
      intervencion: s('intervencion'),
      tradicionOAngulo: s('tradicion_o_angulo'),
      estudio: s('estudio'),
      tipoFuente: s('tipo_fuente'),
      diseno: s('diseno'),
      n: s('n'),
      poblacion: s('poblacion'),
      duracion: s('duracion'),
      dosisOProtocolo: s('dosis_o_protocolo'),
      queMidio: s('que_midio'),
      resultadoReportado: s('resultado_reportado'),
      direccionSegunLaFuente: s('direccion_segun_la_fuente'),
      efectosAdversosReportados: s('efectos_adversos_reportados'),
      financiacionYConflictos: s('financiacion_y_conflictos'),
      comoProbarloEnCasa: s('como_probarlo_en_casa'),
      costeAprox: s('coste_aprox'),
      enlace: s('enlace'),
      identificador: s('identificador'),
      verificacion: s('verificacion'),
    );
  }

  final String id;
  final int temaIndice;
  final String temaKey;
  final String? grupo;
  final String? intervencion;
  final String? tradicionOAngulo;
  final String? estudio;
  final String? tipoFuente;
  final String? diseno;
  final String? n;
  final String? poblacion;
  final String? duracion;
  final String? dosisOProtocolo;
  final String? queMidio;
  final String? resultadoReportado;
  final String? direccionSegunLaFuente;
  final String? efectosAdversosReportados;
  final String? financiacionYConflictos;
  final String? comoProbarloEnCasa;
  final String? costeAprox;
  final String? enlace;
  final String? identificador;
  final String? verificacion;

  /// Texto de búsqueda ya normalizado (sin mayúsculas ni tildes) sobre grupo,
  /// intervención, estudio, resultado, población, dosis, financiación e
  /// identificador.
  late final String textoBusqueda = normalizarTexto(
    [
      grupo,
      intervencion,
      estudio,
      resultadoReportado,
      poblacion,
      dosisOProtocolo,
      financiacionYConflictos,
      identificador,
    ].whereType<String>().join(' | '),
  );
}

/// Minúsculas y sin tildes (`á`→`a`, `ü`→`u`, `ñ`→`n`...).
String normalizarTexto(String entrada) {
  const origen = 'áàäâãéèëêíìïîóòöôõúùüûñç';
  const destino = 'aaaaaeeeeiiiiooooouuuunc';
  final sb = StringBuffer();
  for (final c in entrada.toLowerCase().runes) {
    final ch = String.fromCharCode(c);
    final i = origen.indexOf(ch);
    sb.write(i >= 0 ? destino[i] : ch);
  }
  return sb.toString();
}

/// Resumen por (tema, grupo) del índice.
final class GrupoResumen {
  const GrupoResumen({
    required this.tema,
    required this.grupo,
    required this.n,
    required this.mejora,
    required this.sinCambio,
    required this.empeora,
    required this.mixto,
    required this.noAplica,
    required this.citasEncontradas,
    required this.citasNoEncontradas,
  });

  factory GrupoResumen.desdeJson(Map<String, dynamic> j) => GrupoResumen(
    tema: j['tema'] as String,
    grupo: j['grupo'] as String,
    n: j['n'] as int,
    mejora: j['mejora'] as int,
    sinCambio: j['sin cambio'] as int,
    empeora: j['empeora'] as int,
    mixto: j['mixto'] as int,
    noAplica: j['no aplica'] as int,
    citasEncontradas: j['citas_encontradas'] as int,
    citasNoEncontradas: j['citas_no_encontradas'] as int,
  );

  final String tema;
  final String grupo;
  final int n;
  final int mejora;
  final int sinCambio;
  final int empeora;
  final int mixto;
  final int noAplica;
  final int citasEncontradas;
  final int citasNoEncontradas;
}

/// Índice del catálogo (`indice.json`).
final class IndiceCatalogo {
  const IndiceCatalogo({
    required this.catalogoSha256,
    required this.totalFilas,
    required this.temas,
    required this.porDireccion,
    required this.porTipoFuente,
    required this.grupos,
  });

  factory IndiceCatalogo.desdeJson(Map<String, dynamic> j) => IndiceCatalogo(
    catalogoSha256: j['catalogo_sha256'] as String,
    totalFilas: j['total_filas'] as int,
    temas: [
      for (final t in j['temas'] as List<dynamic>)
        (
          key: (t as Map<String, dynamic>)['key'] as String,
          titulo: t['titulo'] as String,
          nFilas: t['n_filas'] as int,
        ),
    ],
    porDireccion: {
      for (final e in (j['por_direccion'] as Map<String, dynamic>).entries)
        e.key: e.value as int,
    },
    porTipoFuente: {
      for (final e in (j['por_tipo_fuente'] as Map<String, dynamic>).entries)
        e.key: e.value as int,
    },
    grupos: [
      for (final g in j['grupos'] as List<dynamic>)
        GrupoResumen.desdeJson(g as Map<String, dynamic>),
    ],
  );

  final String catalogoSha256;
  final int totalFilas;
  final List<({String key, String titulo, int nFilas})> temas;
  final Map<String, int> porDireccion;
  final Map<String, int> porTipoFuente;
  final List<GrupoResumen> grupos;
}

/// Catálogo completo en memoria.
final class Catalogo {
  const Catalogo({
    required this.esquema,
    required this.fuenteSha256,
    required this.columnas,
    required this.temas,
    required this.filas,
    required this.indice,
  });

  final int esquema;
  final String fuenteSha256;
  final List<String> columnas;
  final List<TemaCatalogo> temas;
  final List<FilaCatalogo> filas;
  final IndiceCatalogo indice;

  TemaCatalogo? tema(String key) {
    for (final t in temas) {
      if (t.key == key) return t;
    }
    return null;
  }

  FilaCatalogo? fila(String id) {
    for (final f in filas) {
      if (f.id == id) return f;
    }
    return null;
  }

  String tituloDeTema(String key) => tema(key)?.titulo ?? key;
}
