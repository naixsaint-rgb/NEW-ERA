// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Spanish Castilian (`es`).
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTitulo => 'NEW-ERA';

  @override
  String get avisoDemo => 'Demo con datos de ejemplo, sin cifrar.';

  @override
  String get cambiarPerfil => 'Cambiar perfil';

  @override
  String get cambiarPerfilAyuda => 'Vuelve a elegir de quién es este móvil.';

  @override
  String get perfilTitulo => '¿De quién es este móvil?';

  @override
  String get perfilAyuda => 'Se puede cambiar más tarde desde Ajustes.';

  @override
  String get perfilPersona => 'De la persona';

  @override
  String get perfilFamilia => 'De un familiar o cuidador';

  @override
  String get errorGenerico => 'Algo ha ido mal. Inténtalo otra vez.';

  @override
  String get alguien => 'alguien';

  @override
  String get cancelar => 'Cancelar';

  @override
  String get noConsta => 'No consta';

  @override
  String get campoObligatorio => 'Este campo es obligatorio';

  @override
  String get pestanaHoy => 'Hoy';

  @override
  String get pestanaMedicacion => 'Medicación';

  @override
  String get pestanaCalendario => 'Calendario';

  @override
  String get pestanaConsultas => 'Consultas';

  @override
  String get pestanaAlarmas => 'Alarmas';

  @override
  String get pestanaVoces => 'Voces';

  @override
  String get pestanaAlimentacion => 'Alimentación';

  @override
  String get pestanaIdeas => 'Ideas y tablas';

  @override
  String get pestanaCirculo => 'Círculo';

  @override
  String get pestanaAjustes => 'Ajustes';

  @override
  String get pestanaMas => 'Más';

  @override
  String get pestanaResumen => 'Resumen';

  @override
  String get botonMasAyuda =>
      'Calendario, consultas, alarmas, voces, círculo y ajustes';

  @override
  String get volver => 'Volver';

  @override
  String get aspecto => 'Aspecto';

  @override
  String get aspectoAutomatico => 'Automático';

  @override
  String get aspectoClaro => 'Claro';

  @override
  String get aspectoOscuro => 'Oscuro';

  @override
  String get aspectoHoras => 'Noche (22–⁠08)';

  @override
  String get aspectoAyuda =>
      'Automático sigue al móvil. Noche: oscuro de 22:00 a 08:00.';

  @override
  String get misPastillas => 'Mis pastillas';

  @override
  String get preguntaModoPrueba => 'Modo prueba: no se guarda nada.';

  @override
  String get tendraTitulo => 'Lo que tendrá';

  @override
  String llegaEnSemana(int n) {
    return 'Llega en la semana $n';
  }

  @override
  String llegaEnSemanas(int a, int b) {
    return 'Llega en las semanas $a y $b';
  }

  @override
  String get calendarioTendra =>
      'Un calendario con las tomas, las citas y las visitas de la familia, para verlo todo de un vistazo.';

  @override
  String get consultasTendra =>
      'Preparar las consultas con el médico: preguntas, grabación con permiso y un resumen para la familia.';

  @override
  String get alarmasTendra =>
      'Avisos escalonados: si la pastilla no se confirma, se avisa a la familia por orden. Y el control por horas, de 9 a 21.';

  @override
  String get controlHorasTitulo => 'Control por horas';

  @override
  String get controlHorasTendra =>
      'Tres preguntas cada hora, de 9 a 21, con horas ajustables: cómo está, si hay dolor y qué plan tiene.';

  @override
  String get verControlHoras => 'Ver el control por horas';

  @override
  String get vocesTendra =>
      'Mensajes grabados por los familiares para acompañar cada aviso.';

  @override
  String get alimentacionTendra =>
      'Registro de comidas y de vasos de agua, con foto si se quiere.';

  @override
  String get parteManana => 'Por la mañana';

  @override
  String get parteTarde => 'Por la tarde';

  @override
  String get parteNoche => 'Por la noche';

  @override
  String get loSiguiente => 'Lo siguiente';

  @override
  String get noHayMasPastillas => 'Ahora no hay más pastillas.';

  @override
  String aLasHoraPastilla(String hora, String nombre) {
    return 'A las $hora, $nombre';
  }

  @override
  String esLaHora(String nombre) {
    return 'Es la hora: $nombre';
  }

  @override
  String get miGente => 'Mi gente';

  @override
  String llamarA(String nombre) {
    return 'Llamar a $nombre';
  }

  @override
  String get necesitoAyuda => 'Necesito ayuda';

  @override
  String ayudaLlamando(String nombre) {
    return 'Estoy llamando a $nombre.';
  }

  @override
  String get ayudaAvisada => 'He anotado que necesitas ayuda.';

  @override
  String get mensajeDeLaFamilia => 'Mensaje de la familia';

  @override
  String get yaMeLaHeTomado => 'YA ME LA HE TOMADO';

  @override
  String compartimentoEs(String compartimento) {
    return 'Compartimento: $compartimento';
  }

  @override
  String get ensenaLaPastilla =>
      'Enséñame la pastilla y tómatela delante del móvil';

  @override
  String cuentaAtras(int n) {
    return 'Quedan $n segundos';
  }

  @override
  String get muyBien => 'Muy bien';

  @override
  String get yaEstaTomada => 'Ya está tomada';

  @override
  String get volverAlInicio => 'Volver al inicio';

  @override
  String get tomaNoEncontrada => 'No encuentro esta toma.';

  @override
  String semanticaFotoPastilla(String nombre) {
    return 'Foto de la pastilla: $nombre';
  }

  @override
  String get camaraDemo => 'Demo: aquí se vería la cámara frontal';

  @override
  String get estadoPrevista => 'Prevista';

  @override
  String get estadoConfirmada => 'Confirmada';

  @override
  String get estadoConfirmadaSinVideo => 'Confirmada sin vídeo';

  @override
  String get estadoNoConfirmada => 'No confirmada';

  @override
  String get estadoCerradaPorFamiliar => 'Cerrada por un familiar';

  @override
  String semanticaEstadoToma(String estado) {
    return 'Estado de la toma: $estado';
  }

  @override
  String get semaforoRojo => 'Hoy hay una toma sin confirmar';

  @override
  String get semaforoNaranja => 'Hay una toma confirmada sin vídeo';

  @override
  String get semaforoVerde => 'Todo en orden por ahora';

  @override
  String semanticaSemaforo(String texto) {
    return 'Semáforo del día: $texto';
  }

  @override
  String get ultimaToma => 'Última toma';

  @override
  String get tomasDeHoy => 'Tomas de hoy';

  @override
  String get sinTomasHoy => 'Hoy no hay tomas previstas.';

  @override
  String confirmadaPorDesde(String quien, String como) {
    return 'Confirmada por $quien, $como';
  }

  @override
  String get origenMovil => 'desde el móvil';

  @override
  String get origenReloj => 'desde el reloj';

  @override
  String get origenFamiliar => 'por un familiar';

  @override
  String cerradaPor(String nombre) {
    return 'Cerrada por $nombre';
  }

  @override
  String get sinConfirmarAun => 'Sin confirmar';

  @override
  String get reservadaUbicacion => 'Ubicación';

  @override
  String get reservadaControl => 'Respuesta de control';

  @override
  String get anadirMedicamento => 'Añadir medicamento';

  @override
  String get probarPantallaToma => 'Probar pantalla de toma';

  @override
  String get medicamentos => 'Medicamentos';

  @override
  String get sinMedicamentos => 'Todavía no hay medicamentos.';

  @override
  String resumenPauta(String horas, String dosis) {
    return '$horas · $dosis';
  }

  @override
  String get pautaSuspendida => 'Pauta suspendida';

  @override
  String get altaTitulo => 'Nuevo medicamento';

  @override
  String get nombreMedicamento => 'Nombre del medicamento';

  @override
  String get nombreParaPersona => 'Nombre para la persona';

  @override
  String get nombreParaPersonaAyuda =>
      'Como lo va a leer ella o él, por ejemplo: pastilla blanca pequeña';

  @override
  String get formaTitulo => 'Forma';

  @override
  String get formaRedonda => 'Redonda';

  @override
  String get formaOvalada => 'Ovalada';

  @override
  String get formaCapsula => 'Cápsula';

  @override
  String get formaOtra => 'Otra';

  @override
  String get colorTitulo => 'Color';

  @override
  String get colorBlanco => 'Blanco';

  @override
  String get colorAmarillo => 'Amarillo';

  @override
  String get colorRojo => 'Rojo';

  @override
  String get colorRosa => 'Rosa';

  @override
  String get colorNaranja => 'Naranja';

  @override
  String get colorVerde => 'Verde';

  @override
  String get colorAzul => 'Azul';

  @override
  String get colorMarron => 'Marrón';

  @override
  String get fotoCaja => 'Foto de la caja';

  @override
  String get fotoPastilla => 'Foto de la pastilla';

  @override
  String get hacerFoto => 'Hacer foto';

  @override
  String get elegirDeLaGaleria => 'Elegir de la galería';

  @override
  String get pautaTitulo => 'Pauta';

  @override
  String get horasDeToma => 'Horas de la toma (24 h)';

  @override
  String get anadirHora => 'Añadir hora';

  @override
  String quitarHora(String hora) {
    return 'Quitar la hora $hora';
  }

  @override
  String get diasDeToma => 'Días';

  @override
  String get diaLunes => 'Lunes';

  @override
  String get diaMartes => 'Martes';

  @override
  String get diaMiercoles => 'Miércoles';

  @override
  String get diaJueves => 'Jueves';

  @override
  String get diaViernes => 'Viernes';

  @override
  String get diaSabado => 'Sábado';

  @override
  String get diaDomingo => 'Domingo';

  @override
  String get dosis => 'Dosis';

  @override
  String get compartimentoEtiqueta => 'Compartimento del pastillero (opcional)';

  @override
  String get comprobacionTitulo => 'Cómo se comprueba';

  @override
  String get comprobacionVideo => 'Vídeo de 10 s';

  @override
  String get comprobacionFoto => 'Foto';

  @override
  String get comprobacionNinguna => 'Ninguna';

  @override
  String get guardarMedicamento => 'Guardar medicamento';

  @override
  String get todosLosDias => 'Todos los días';

  @override
  String get medicamentoNoEncontrado => 'No encuentro este medicamento.';

  @override
  String formaYColor(String forma, String color) {
    return 'Forma $forma · color $color';
  }

  @override
  String get sinColor => 'sin indicar';

  @override
  String get pautaActual => 'Pauta actual';

  @override
  String lineaHoras(String valor) {
    return 'Horas: $valor';
  }

  @override
  String lineaDias(String valor) {
    return 'Días: $valor';
  }

  @override
  String lineaDosis(String valor) {
    return 'Dosis: $valor';
  }

  @override
  String lineaCompartimento(String valor) {
    return 'Compartimento: $valor';
  }

  @override
  String lineaComprobacion(String valor) {
    return 'Comprobación: $valor';
  }

  @override
  String get cambiarPauta => 'Cambiar la pauta';

  @override
  String get reanudarPauta => 'Reanudar la pauta';

  @override
  String get suspenderPauta => 'Suspender la pauta';

  @override
  String get suspender => 'Suspender';

  @override
  String get motivo => 'Motivo';

  @override
  String get historialPauta => 'Historial de la pauta';

  @override
  String versionDesde(int version, String desde) {
    return 'Versión $version desde $desde';
  }

  @override
  String motivoDe(String motivo) {
    return 'Motivo: $motivo';
  }

  @override
  String get motivoDelCambio => 'Motivo del cambio';

  @override
  String get guardarCambio => 'Guardar el cambio';

  @override
  String get sinFamiliares => 'Todavía no hay familiares.';

  @override
  String get rolResponsable => 'Responsable';

  @override
  String get rolCuidador => 'Cuidador o cuidadora';

  @override
  String get rolApoyo => 'Apoyo';

  @override
  String get rolLectura => 'Solo lectura';

  @override
  String ordenDeAviso(int orden) {
    return 'Se le avisa en el puesto $orden';
  }

  @override
  String get circuloGestion =>
      'Añadir, quitar y cambiar los permisos de los familiares llega en la semana 16.';

  @override
  String get cargarEjemplo => 'Cargar datos de ejemplo';

  @override
  String get cargarEjemploAyuda =>
      'Añade una persona de ejemplo, familiares y medicamentos ficticios.';

  @override
  String get ejemploCargado => 'Datos de ejemplo cargados.';

  @override
  String get ejemploYaCargado =>
      'Ya hay medicamentos: no se han cargado datos de ejemplo.';

  @override
  String ajustesPlataforma(String plataforma) {
    return 'Plataforma de este dispositivo: $plataforma';
  }

  @override
  String get ajustesMas => 'El resto de los ajustes llega en la semana 16.';

  @override
  String get catalogoCabecera =>
      'Cada fila dice lo que reporta su fuente, con su cifra tal cual y quién lo pagó. Nadie hace de juez.';

  @override
  String get catalogoNoCargado => 'No se ha podido cargar el catálogo.';

  @override
  String get resumenPorGrupo => 'Resumen por grupo';

  @override
  String get dosieresPorTema => 'Dosieres por tema';

  @override
  String nFilas(int n) {
    return '$n filas';
  }

  @override
  String get buscar => 'Buscar';

  @override
  String get filtrarPorTema => 'Filtrar por tema';

  @override
  String get filtrarPorDireccion => 'Dirección según la fuente';

  @override
  String get filtrarPorTipoFuente => 'Filtrar por tipo de fuente';

  @override
  String grupoFiltrado(String grupo) {
    return 'Grupo: $grupo';
  }

  @override
  String nDeTotal(int n, int total) {
    return '$n de $total';
  }

  @override
  String get quitarFiltros => 'Quitar filtros';

  @override
  String abrirFicha(String nombre) {
    return 'Abrir la ficha de $nombre';
  }

  @override
  String get direccionMejora => 'Mejora';

  @override
  String get direccionSinCambio => 'Sin cambio';

  @override
  String get direccionEmpeora => 'Empeora';

  @override
  String get direccionMixto => 'Mixto';

  @override
  String get direccionNoAplica => 'No aplica';

  @override
  String semanticaDireccion(String texto) {
    return 'Dirección según la fuente: $texto';
  }

  @override
  String get fichaTitulo => 'Ficha';

  @override
  String get filaNoEncontrada => 'No encuentro esta fila.';

  @override
  String get abrirLaFuente => 'Abrir la fuente';

  @override
  String get campoTema => 'Tema';

  @override
  String get campoGrupo => 'Intervención (grupo)';

  @override
  String get campoIntervencion => 'Intervención (tal como la nombra la fuente)';

  @override
  String get campoTradicion => 'Tradición o ángulo';

  @override
  String get campoEstudio => 'Estudio / fuente';

  @override
  String get campoTipoFuente => 'Tipo de fuente';

  @override
  String get campoDiseno => 'Diseño';

  @override
  String get campoN => 'n';

  @override
  String get campoPoblacion => 'Población';

  @override
  String get campoDuracion => 'Duración';

  @override
  String get campoDosis => 'Dosis o protocolo';

  @override
  String get campoQueMidio => 'Qué midió';

  @override
  String get campoResultado => 'Resultado reportado (cifra tal cual)';

  @override
  String get campoDireccion => 'Dirección según la fuente';

  @override
  String get campoEfectosAdversos => 'Efectos adversos reportados';

  @override
  String get campoFinanciacion => 'Financiación y conflictos';

  @override
  String get campoComoProbarlo => 'Cómo probarlo en casa (según la fuente)';

  @override
  String get campoCoste => 'Coste aprox.';

  @override
  String get campoVerificacion => 'Verificación documental';

  @override
  String get campoIdentificador => 'Identificador';

  @override
  String get campoEnlace => 'Enlace';

  @override
  String get dosierTitulo => 'Dosier';

  @override
  String get temaNoEncontrado => 'No encuentro este tema.';

  @override
  String get verFilasDelTema => 'Ver las filas de este tema';

  @override
  String get dosierTesis => 'Tesis';

  @override
  String get dosierDefensores => 'Defensores';

  @override
  String get dosierMecanismos => 'Mecanismos';

  @override
  String get dosierConsenso => 'Consenso y quién lo paga';

  @override
  String get dosierEnterrado => 'Lo enterrado';

  @override
  String get dosierProtocolos => 'Protocolos reportados';

  @override
  String get dosierRiesgos => 'Riesgos reconocidos por los defensores';

  @override
  String get dosierFuentes => 'Fuentes heterodoxas';

  @override
  String get dosierIdeas => 'Ideas para la app';

  @override
  String relacionYRol(String relacion, String rol) {
    return '$relacion · $rol';
  }

  @override
  String etiquetaConConteo(String texto, int n) {
    return '$texto · $n';
  }

  @override
  String get todosLosTemas => 'Todos los temas';

  @override
  String get personaAhoraNoTocaNada => 'Ahora no toca nada';

  @override
  String get personaTomarlaAhora => 'Tomarla ahora';

  @override
  String personaHoyDia(String dia) {
    return 'Hoy, $dia';
  }

  @override
  String personaHoraCompartimento(String hora, String compartimento) {
    return '$hora · $compartimento';
  }

  @override
  String personaAhoraCon(String texto) {
    return 'Ahora · $texto';
  }

  @override
  String get personaYaTomada => 'Ya tomada';

  @override
  String get personaLuego => 'Luego';

  @override
  String get personaSinTomar => 'Sin tomar';

  @override
  String get personaYaMeLaHeTomado => 'Ya me la he tomado';

  @override
  String get personaHoyNoHayPastillas => 'Hoy no hay pastillas';

  @override
  String personaHola(String nombre) {
    return 'Hola, $nombre';
  }

  @override
  String personaDiaYHora(String dia, String hora) {
    return '$dia · $hora';
  }

  @override
  String get personaAhoraToca => 'Ahora toca';

  @override
  String get personaLlamar => 'Llamar';

  @override
  String get personaAyuda => 'Ayuda';

  @override
  String get hoySegmentoAyer => 'Ayer';

  @override
  String get hoySegmentoHoy => 'Hoy';

  @override
  String get hoySegmentoManana => 'Mañana';

  @override
  String get hoySegmentoSemana => 'Semana';

  @override
  String get hoyCasillaTomas => 'Tomas';

  @override
  String get hoyCasillaVideos => 'Vídeos';

  @override
  String get hoyCasillaAvisos => 'Avisos';

  @override
  String hoyDeTotal(int total) {
    return 'de $total';
  }

  @override
  String get hoyProximaToma => 'Próxima toma';

  @override
  String hoyHoraYCompartimento(String hora, String compartimento) {
    return '$hora · $compartimento';
  }

  @override
  String hoySiNoLaToma(String hora) {
    return 'Si no la toma: aviso a las $hora';
  }

  @override
  String get hoyComprobaciones => 'Comprobaciones';

  @override
  String hoyVideoDeLaToma(String hora, int segundos) {
    return 'Vídeo de la toma de las $hora · $segundos s';
  }

  @override
  String hoyVideoDeLaTomaSinDuracion(String hora) {
    return 'Vídeo de la toma de las $hora';
  }

  @override
  String hoyFotoDeLaToma(String hora) {
    return 'Foto de la toma de las $hora';
  }

  @override
  String get hoySinComprobacionesHoy => 'Sin comprobaciones hoy';

  @override
  String get hoySinComprobacionesAyer => 'Sin comprobaciones ayer';

  @override
  String get hoyLlegaPronto => 'Llega pronto';

  @override
  String get hoyTomasDeAyer => 'Tomas de ayer';

  @override
  String get hoySinTomasAyer => 'Ayer no había tomas previstas.';

  @override
  String hoyRespuestasControlLlega(int n) {
    return 'Respuestas de control: llega en la semana $n';
  }

  @override
  String get hoyTomasDeManana => 'Tomas de mañana';

  @override
  String get hoySinTomasManana => 'Mañana no hay tomas previstas.';

  @override
  String get hoyQuienRecibeAvisos => 'Quién recibe los avisos';

  @override
  String hoyAvisoAMinutos(String nombre, int minutos) {
    return '$nombre a los $minutos min';
  }

  @override
  String get hoyQuienRecibeAyuda =>
      'Si no confirma una toma, el aviso llega en este orden.';

  @override
  String get hoySinFamiliares => 'Todavía no hay familiares en el círculo.';

  @override
  String hoyUltimos7Dias(String desde, String hasta) {
    return 'Últimos 7 días · $desde a $hasta';
  }

  @override
  String hoyTomasHechasQuedan(int k) {
    return 'tomas hechas · hoy quedan $k';
  }

  @override
  String hoySemanticaTotales(int hechas, int previstas, int k) {
    return '$hechas de $previstas tomas hechas · hoy quedan $k';
  }

  @override
  String hoyRespuestasLlega(int n) {
    return 'Respuestas: llega en la semana $n';
  }

  @override
  String get hoyFilaTomas => 'Tomas';

  @override
  String get hoyFilaRespondio => 'Respondió';

  @override
  String hoySemanticaCeldaDia(String dia, int hechas, int previstas) {
    return '$dia: $hechas de $previstas tomas hechas';
  }

  @override
  String hoySemanticaCeldaSinTomas(String dia) {
    return '$dia: sin tomas';
  }

  @override
  String get hoyLoQueDijo => 'Lo que dijo esta semana';

  @override
  String get hoyLoQueDijoAviso => 'Sus respuestas a las preguntas de cada hora';

  @override
  String get hoyInicialLunes => 'L';

  @override
  String get hoyInicialMartes => 'M';

  @override
  String get hoyInicialMiercoles => 'X';

  @override
  String get hoyInicialJueves => 'J';

  @override
  String get hoyInicialViernes => 'V';

  @override
  String get hoyInicialSabado => 'S';

  @override
  String get hoyInicialDomingo => 'D';

  @override
  String get medicVispera => 'Pastillero y pastillas';

  @override
  String get medicPastilleroTitulo => 'Pastillero de la semana';

  @override
  String get medicPastilleroVacio =>
      'El pastillero aparecerá cuando haya una pauta activa.';

  @override
  String get medicInicialesDias => 'L M X J V S D';

  @override
  String medicDiaHoy(String dia) {
    return '$dia, hoy';
  }

  @override
  String medicCeldaEtiqueta(String dia, String hora, String estado) {
    return '$dia $hora: $estado';
  }

  @override
  String get medicEstadoTomada => 'tomada';

  @override
  String get medicEstadoNoConfirmada => 'no confirmada';

  @override
  String get medicEstadoAhora => 'ahora';

  @override
  String get medicEstadoPrevista => 'prevista';

  @override
  String medicEstadoParcial(int hechas, int total) {
    return '$hechas de $total tomadas';
  }

  @override
  String get medicProbarTitulo => 'Probar';

  @override
  String get medicProbarPregunta => 'Probar pregunta';

  @override
  String get medicProbarPreguntaAyuda => 'Modo prueba: no se guarda nada.';

  @override
  String get medicPastillasTitulo => 'Pastillas · con su foto';

  @override
  String get medicPastillasPie =>
      'La foto la hace la familia una vez. Ella la ve en la alarma y en Mis pastillas; aquí, en la lista.';

  @override
  String medicFotoDe(String autor, String fecha) {
    return 'Foto de $autor · $fecha';
  }

  @override
  String medicHorasUnidas(String resto, String ultima) {
    return '$resto y $ultima';
  }

  @override
  String resumenUltimaToma(
    String hora,
    String medicamento,
    String quien,
    String como,
  ) {
    return 'Toma confirmada a las $hora: $medicamento · $quien, $como';
  }

  @override
  String get resumenSinTomasAun => 'Sin tomas aún';

  @override
  String resumenUltimaSenal(String hora) {
    return 'Última señal $hora';
  }

  @override
  String get resumenOrigenMovil => 'móvil';

  @override
  String get resumenOrigenReloj => 'reloj';

  @override
  String get resumenOrigenFamiliar => 'familiar';

  @override
  String get resumenTarjetaTomas => 'Tomas';

  @override
  String get resumenTarjetaVideos => 'Vídeos';

  @override
  String get resumenTarjetaAvisos => 'Avisos';

  @override
  String get resumenTarjetaMensaje => 'Mensaje';

  @override
  String resumenDeTotal(int total) {
    return ' de $total';
  }

  @override
  String resumenSemanticaTomas(int hechas, int total) {
    return '$hechas de $total tomas hechas';
  }

  @override
  String resumenSiguiente(String hora) {
    return 'siguiente $hora';
  }

  @override
  String get resumenSinMasTomas => 'sin más tomas';

  @override
  String get resumenSinTomasHoy => 'Sin tomas hoy';

  @override
  String get resumenHoy => 'hoy';

  @override
  String get resumenVer => 'Ver';

  @override
  String get resumenAyudaYLlamadas => 'ayuda y llamadas, hoy';

  @override
  String resumenMensajeDe(String nombre, String hora) {
    return 'De $nombre · $hora';
  }

  @override
  String get resumenSinMensajes => 'Sin mensajes';

  @override
  String get resumenRelojLlega => 'Pulso, pasos y sueño llegan con el reloj';

  @override
  String get resumenProximaToma => 'Próxima toma';

  @override
  String resumenHoraCompartimento(String hora, String compartimento) {
    return '$hora · $compartimento';
  }

  @override
  String resumenAvisoA(String nombre, String hora) {
    return 'Si no la toma, aviso a $nombre a las $hora';
  }

  @override
  String get resumenControlHoras => 'Control por horas';

  @override
  String get resumenControlRango => '9 a 21 h';

  @override
  String preguntaProgreso(String hora, int n) {
    return '$hora · pregunta $n de 3';
  }

  @override
  String preguntaPuntos(int n) {
    return 'Pregunta $n de 3';
  }

  @override
  String preguntaTeLoPregunta(String nombre) {
    return 'Te lo pregunta $nombre';
  }

  @override
  String get preguntaTeLoPreguntaFamilia => 'Te lo pregunta tu familia';

  @override
  String get preguntaVolverAOir => 'Toca para volver a oírla';

  @override
  String get preguntaVozLlega => 'La voz grabada llega en la semana 5';

  @override
  String get preguntaComoEstas => '¿Cómo estás?';

  @override
  String get preguntaTeDuele => '¿Te duele algo?';

  @override
  String get preguntaQueHaras => '¿Qué vas a hacer luego?';

  @override
  String get preguntaRespBien => 'Bien';

  @override
  String get preguntaRespRegular => 'Regular';

  @override
  String get preguntaRespMal => 'Mal';

  @override
  String get preguntaRespNada => 'Nada';

  @override
  String get preguntaRespUnPoco => 'Un poco';

  @override
  String get preguntaRespMucho => 'Mucho';

  @override
  String get preguntaRespPasear => 'Pasear';

  @override
  String get preguntaRespDescansar => 'Descansar';

  @override
  String get preguntaRespVerLaTele => 'Ver la tele';

  @override
  String get preguntaRespOtraCosa => 'Otra cosa';

  @override
  String get preguntaPrefieroDecirlo => 'Prefiero decirlo';

  @override
  String get preguntaDecirloLlega => 'Llega en la semana 5';

  @override
  String get preguntaGracias => 'Gracias';

  @override
  String get preguntaHasContestado => 'Esto has contestado';

  @override
  String get fixSemaforoRetraso => 'Una toma se retrasa';

  @override
  String get fixSinTomasAunHoy => 'Sin tomas aún hoy';

  @override
  String fixPendienteDesde(String hora) {
    return 'Pendiente desde las $hora';
  }

  @override
  String fixMananaALas(String hora) {
    return 'Mañana a las $hora';
  }

  @override
  String fixMananaALasHoraPastilla(String hora, String nombre) {
    return 'Mañana a las $hora, $nombre';
  }

  @override
  String get fixReservadaVerVideo =>
      'Ver el vídeo de cada toma desde el móvil de la familia';

  @override
  String fixResumenAlDia(String alias) {
    return 'Tomas de $alias al día';
  }

  @override
  String fixResumenSeRetrasa(String alias) {
    return '$alias: una toma se retrasa';
  }

  @override
  String fixResumenSinVideo(String alias) {
    return '$alias: una toma sin vídeo';
  }

  @override
  String fixResumenSinConfirmar(String alias) {
    return '$alias: una toma sin confirmar';
  }

  @override
  String fixResumenSiguienteManana(String hora) {
    return 'siguiente mañana $hora';
  }

  @override
  String fixAyerHora(String hora) {
    return 'ayer $hora';
  }

  @override
  String fixFechaHora(String fecha, String hora) {
    return '$fecha, $hora';
  }

  @override
  String get fixComprobacionVideoCorto => 'Vídeo';
}
