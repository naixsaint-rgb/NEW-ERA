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
  String get avisoDemo =>
      'Demo con datos de ejemplo. Sin cifrar: no escribas datos reales.';

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
  String get enConstruccion => 'En construcción';

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
  String get preguntaTitulo => 'Pregunta';

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
  String get sinTomasAun => 'Todavía no ha habido ninguna toma.';

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
  String get reservadaVideo => 'Vídeo de la toma';

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
  String verMedicamento(String nombre) {
    return 'Ver $nombre';
  }

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
}
