import 'package:flutter/widgets.dart';

/// `Key` que usan los tests para encontrar elementos.
abstract final class ClavesUi {
  static const loSiguiente = ValueKey<String>('lo_siguiente');
  static const necesitoAyuda = ValueKey<String>('necesito_ayuda');
  static const confirmarToma = ValueKey<String>('confirmar_toma');
  static const enlaceFicha = ValueKey<String>('enlace_ficha');
  static const miGente = ValueKey<String>('mi_gente');
  static const esLaHora = ValueKey<String>('es_la_hora');
  static const muyBien = ValueKey<String>('muy_bien');
  static const semaforo = ValueKey<String>('semaforo');
  static const buscadorCatalogo = ValueKey<String>('buscador_catalogo');

  /// Botón "Mis pastillas" del inicio de la persona.
  static const misPastillas = ValueKey<String>('mis_pastillas');

  /// Pantalla "Mis pastillas" de la persona.
  static const pantallaMisPastillas = ValueKey<String>(
    'pantalla_mis_pastillas',
  );

  /// Pantalla de pregunta de la persona ("¿Cómo estás?").
  static const pregunta = ValueKey<String>('pregunta');

  /// Pestaña "Resumen" de la familia (la pantalla).
  static const pantallaResumen = ValueKey<String>('pantalla_resumen');

  /// Botón "Probar pregunta" (modo prueba) de la familia.
  static const probarPregunta = ValueKey<String>('probar_pregunta');

  /// Tarjeta "Pastillero de la semana" de Medicación.
  static const pastillero = ValueKey<String>('pastillero');

  /// Anillo de tomas hechas de hoy (Resumen).
  static const anilloTomas = ValueKey<String>('anillo_tomas');

  /// Botón "Volver al inicio" de las pantallas de la persona.
  static const volverAlInicio = ValueKey<String>('volver_al_inicio');

  /// Pantalla Calendario de la familia.
  static const pantallaCalendario = ValueKey<String>('pantalla_calendario');

  /// Título del mes del Calendario ("Octubre de 2026").
  static const mesCalendario = ValueKey<String>('mes_calendario');

  /// Flechas ‹ y › del Calendario.
  static const mesAnterior = ValueKey<String>('mes_anterior');
  static const mesSiguiente = ValueKey<String>('mes_siguiente');

  /// Título del día elegido del Calendario (la fecha larga).
  static const diaElegido = ValueKey<String>('dia_elegido');

  /// Casilla de un día del Calendario por su fecha (`2026-10-13`).
  static ValueKey<String> diaCalendario(String fecha) =>
      ValueKey<String>('dia_calendario_$fecha');

  /// Pestaña de la familia: `hoy`, `medicacion`, `calendario`...
  static ValueKey<String> pestana(String slug) =>
      ValueKey<String>('pestana_$slug');

  /// Segmento de un `SelectorSegmentos`: `ayer`, `hoy`, `manana`, `semana`...
  static ValueKey<String> segmento(String valor) =>
      ValueKey<String>('segmento_$valor');

  /// Opción del ajuste "Aspecto": `automatico`, `claro`, `oscuro`, `horas`.
  static ValueKey<String> aspecto(String valor) =>
      ValueKey<String>('aspecto_$valor');

  /// Respuesta de la pantalla de pregunta: `bien`, `regular`, `mal`...
  static ValueKey<String> respuesta(String valor) =>
      ValueKey<String>('respuesta_$valor');

  /// Fila del catálogo por id (`cobre_metales-000`).
  static ValueKey<String> filaCatalogo(String id) =>
      ValueKey<String>('fila_$id');

  /// Círculo: fila "Invitar otro móvil".
  static const circInvitar = ValueKey<String>('circ_invitar');

  /// Invitación: el QR, el código escrito y "Copiar el código".
  static const circQr = ValueKey<String>('circ_qr');
  static const circCodigo = ValueKey<String>('circ_codigo');
  static const circCopiar = ValueKey<String>('circ_copiar');

  /// Círculo: fila de un familiar (`circ_familiar_<id>`).
  static ValueKey<String> circFamiliar(String miembroId) =>
      ValueKey<String>('circ_familiar_$miembroId');

  /// Familiar: segmento de su puesto en el orden de aviso (0, ninguno).
  static ValueKey<String> circPuesto(int puesto) =>
      ValueKey<String>('circ_puesto_$puesto');

  /// Familiar › Avisos en este móvil: abrir ntfy, aviso de prueba, el tema y
  /// "Copiar el tema".
  static const circAvisosAbrir = ValueKey<String>('circ_avisos_abrir');
  static const circAvisosPrueba = ValueKey<String>('circ_avisos_prueba');
  static const circAvisosTema = ValueKey<String>('circ_avisos_tema');
  static const circAvisosCopiar = ValueKey<String>('circ_avisos_copiar');

  /// Círculo: "Añadir familiar" y "Pon tu nombre".
  static const circAnadir = ValueKey<String>('circ_anadir');
  static const circPonNombre = ValueKey<String>('circ_pon_nombre');

  /// Familiar: "Editar" y "Quitar del círculo" (con su confirmación).
  static const circEditar = ValueKey<String>('circ_editar');
  static const circQuitar = ValueKey<String>('circ_quitar');
  static const circQuitarConfirmar = ValueKey<String>('circ_quitar_confirmar');

  /// Formulario de familiar: nombre, teléfono, papel (`circ_papel_<valor>`) y
  /// "Guardar".
  static const circNombre = ValueKey<String>('circ_nombre');
  static const circTelefono = ValueKey<String>('circ_telefono');
  static const circGuardar = ValueKey<String>('circ_guardar');
  static ValueKey<String> circPapel(String valor) =>
      ValueKey<String>('circ_papel_$valor');

  /// Perfil: tercera tarjeta, "Este móvil se une a una familia…".
  static const unirTarjeta = ValueKey<String>('unir_tarjeta');

  /// Unirse: leer el QR, el campo del código, "Pegar", "Unir este móvil" y el
  /// botón de confirmar que se borran los datos de este móvil.
  static const unirLeerQr = ValueKey<String>('unir_leer_qr');
  static const unirCodigo = ValueKey<String>('unir_codigo');
  static const unirPegar = ValueKey<String>('unir_pegar');
  static const unirAceptar = ValueKey<String>('unir_aceptar');
  static const unirConfirmar = ValueKey<String>('unir_confirmar');

  /// Voces: fila de un familiar en la lista (`voz_miembro_<id>`).
  static ValueKey<String> vozMiembro(String miembroId) =>
      ValueKey<String>('voz_miembro_$miembroId');

  /// Voces: tarjeta de una frase por su uso (`toma`, `muy_bien`…).
  static ValueKey<String> vozFrase(String uso) =>
      ValueKey<String>('voz_frase_$uso');

  /// Voces: botones de una frase por su uso.
  static ValueKey<String> vozGrabar(String uso) =>
      ValueKey<String>('voz_grabar_$uso');
  static ValueKey<String> vozParar(String uso) =>
      ValueKey<String>('voz_parar_$uso');
  static ValueKey<String> vozEscuchar(String uso) =>
      ValueKey<String>('voz_escuchar_$uso');
  static ValueKey<String> vozAprobar(String uso) =>
      ValueKey<String>('voz_aprobar_$uso');

  /// Voces: cuenta atrás de la grabación ("Grabando · quedan 8 s").
  static const vozCuentaAtras = ValueKey<String>('voz_cuenta_atras');

  /// Voces: "Leer y aceptar" (o "Volver a grabar") de un familiar sin voz.
  static const vozLeerYAceptar = ValueKey<String>('voz_leer_y_aceptar');

  /// Voces: "Retirar la voz" y su confirmación.
  static const vozRetirar = ValueKey<String>('voz_retirar');
  static const vozRetirarConfirmar = ValueKey<String>('voz_retirar_confirmar');

  /// Consentimiento de voz: el texto, "Acepto, soy …" y "Ahora no".
  static const vozConsTexto = ValueKey<String>('voz_cons_texto');
  static const vozConsAcepto = ValueKey<String>('voz_cons_acepto');
  static const vozConsAhoraNo = ValueKey<String>('voz_cons_ahora_no');

  /// Toma: "Te lo recuerda la voz de …" (solo si hay frase).
  static const vozTeLoRecuerda = ValueKey<String>('voz_te_lo_recuerda');

  /// Control por horas: interruptor, botones de hora y ritmo.
  static const controlActivado = ValueKey<String>('control_activado');

  /// [campo] `desde` o `hasta`; [accion] `menos` o `mas`.
  static ValueKey<String> controlHora(String campo, String accion) =>
      ValueKey<String>('control_${campo}_$accion');
  static ValueKey<String> controlRitmo(int horas) =>
      ValueKey<String>('control_ritmo_$horas');
  // ---- Agenda: citas y turnos del calendario.

  /// Calendario: "Añadir cita" y "Añadir turno" del día elegido, y las
  /// "Próximas citas".
  static const calAnadirCita = ValueKey<String>('cal_anadir_cita');
  static const calAnadirTurno = ValueKey<String>('cal_anadir_turno');
  static const calProximas = ValueKey<String>('cal_proximas');

  /// Fila de una cita (`cita_<id>`) o de un turno (`turno_<id>`).
  static ValueKey<String> citaFila(String id) => ValueKey<String>('cita_$id');
  static ValueKey<String> turnoFila(String id) => ValueKey<String>('turno_$id');

  /// Formularios: campos, tipo, quién y botones.
  static const agTitulo = ValueKey<String>('ag_titulo');
  static const agLugar = ValueKey<String>('ag_lugar');
  static const agNotas = ValueKey<String>('ag_notas');
  static const agFecha = ValueKey<String>('ag_fecha');
  static const agHora = ValueKey<String>('ag_hora');
  static const agDesde = ValueKey<String>('ag_desde');
  static const agHasta = ValueKey<String>('ag_hasta');
  static const agRepetir = ValueKey<String>('ag_repetir');
  static const agGuardar = ValueKey<String>('ag_guardar');
  static const agBorrar = ValueKey<String>('ag_borrar');
  static const agBorrarConfirmar = ValueKey<String>('ag_borrar_confirmar');
  static ValueKey<String> agTipo(String valor) =>
      ValueKey<String>('ag_tipo_$valor');

  /// Quién acompaña (cita; `nadie` o el id) o quién está (turno).
  static ValueKey<String> agAcompana(String id) =>
      ValueKey<String>('ag_acompana_$id');
  static ValueKey<String> agMiembro(String id) =>
      ValueKey<String>('ag_miembro_$id');

  /// Marca de un día con cita o con turno en el mes (`cal_marca_cita_<fecha>`).
  static ValueKey<String> marcaCita(String fecha) =>
      ValueKey<String>('cal_marca_cita_$fecha');
  static ValueKey<String> marcaTurno(String fecha) =>
      ValueKey<String>('cal_marca_turno_$fecha');

  /// Hoy y Mañana: fila de una cita y "Hoy está con ella".
  static const hoyCita = ValueKey<String>('hoy_cita');
  static const hoyEstaConElla = ValueKey<String>('hoy_esta_con_ella');

  // ------------------------------------------------------------ Alimentación

  static const pantallaAlimentacion = ValueKey<String>('pantalla_alimentacion');

  /// Segmento Hoy / Semana de Alimentación (`hoy`, `semana`).
  static ValueKey<String> alimVista(String valor) =>
      ValueKey<String>('alim_vista_$valor');

  /// Fila de un momento sin comida anotada (`desayuno`…) y fila de una
  /// comida anotada (por id).
  static ValueKey<String> alimFila(String momento) =>
      ValueKey<String>('alim_fila_$momento');
  static ValueKey<String> alimComida(String id) =>
      ValueKey<String>('alim_comida_$id');

  static const alimAnotar = ValueKey<String>('alim_anotar');
  static const alimVasoMas = ValueKey<String>('alim_vaso_mas');
  static const alimVasoMenos = ValueKey<String>('alim_vaso_menos');
  static const alimVasosTexto = ValueKey<String>('alim_vasos_texto');
  static const alimObjetivoMas = ValueKey<String>('alim_objetivo_mas');
  static const alimObjetivoMenos = ValueKey<String>('alim_objetivo_menos');
  static const alimObjetivoTexto = ValueKey<String>('alim_objetivo_texto');

  /// Día de la vista Semana (`yyyy-MM-dd`).
  static ValueKey<String> alimDia(String fecha) =>
      ValueKey<String>('alim_dia_$fecha');

  /// Fila de Alimentación en Resumen.
  static const resumenAlimentacion = ValueKey<String>('resumen_alimentacion');

  /// Formulario de comida.
  static ValueKey<String> alimMomento(String valor) =>
      ValueKey<String>('alim_momento_$valor');
  static ValueKey<String> alimCuanto(String valor) =>
      ValueKey<String>('alim_cuanto_$valor');
  static const alimNota = ValueKey<String>('alim_nota');
  static const alimFecha = ValueKey<String>('alim_fecha');
  static const alimHora = ValueKey<String>('alim_hora');
  static const alimFotoHacer = ValueKey<String>('alim_foto_hacer');
  static const alimFotoElegir = ValueKey<String>('alim_foto_elegir');
  static const alimFotoQuitar = ValueKey<String>('alim_foto_quitar');
  static const alimGuardar = ValueKey<String>('alim_guardar');
  static const alimBorrar = ValueKey<String>('alim_borrar');
  static const alimBorrarConfirmar = ValueKey<String>('alim_borrar_confirmar');

  // ------------------------------------------------------------ Consultas

  static const pantallaConsultas = ValueKey<String>('pantalla_consultas');
  static const pantallaFichaConsulta = ValueKey<String>(
    'pantalla_ficha_consulta',
  );

  /// Lista: «Nueva cita» y la fila de una cita (`consulta_<id>`).
  static const consNuevaCita = ValueKey<String>('cons_nueva_cita');
  static ValueKey<String> consFila(String id) =>
      ValueKey<String>('consulta_$id');

  /// Ficha: editar la cita.
  static const consEditarCita = ValueKey<String>('cons_editar_cita');

  /// Preguntas: campo, añadir y, por id, la fila, marcar, editar y borrar.
  static const consPreguntaCampo = ValueKey<String>('cons_pregunta_campo');
  static const consPreguntaAnadir = ValueKey<String>('cons_pregunta_anadir');
  static ValueKey<String> consPregunta(String id) =>
      ValueKey<String>('cons_pregunta_$id');
  static ValueKey<String> consPreguntaMarca(String id) =>
      ValueKey<String>('cons_pregunta_marca_$id');
  static ValueKey<String> consPreguntaEditar(String id) =>
      ValueKey<String>('cons_pregunta_editar_$id');
  static ValueKey<String> consPreguntaBorrar(String id) =>
      ValueKey<String>('cons_pregunta_borrar_$id');

  /// Notas: campo, añadir y, por id, la fila, editar y borrar.
  static const consNotaCampo = ValueKey<String>('cons_nota_campo');
  static const consNotaAnadir = ValueKey<String>('cons_nota_anadir');
  static ValueKey<String> consNota(String id) =>
      ValueKey<String>('cons_nota_$id');
  static ValueKey<String> consNotaEditar(String id) =>
      ValueKey<String>('cons_nota_editar_$id');
  static ValueKey<String> consNotaBorrar(String id) =>
      ValueKey<String>('cons_nota_borrar_$id');

  /// Diálogos de texto y de borrado (editar una pregunta o una nota).
  static const consDialogoCampo = ValueKey<String>('cons_dialogo_campo');
  static const consDialogoGuardar = ValueKey<String>('cons_dialogo_guardar');
  static const consBorrarConfirmar = ValueKey<String>('cons_borrar_confirmar');

  /// «Qué ha pasado desde la última consulta» y cada cifra (`tomas_ok`,
  /// `tomas_sin`, `rondas_ok`, `rondas_sin`, `mal`, `dolor`, `comidas`).
  static const consDesde = ValueKey<String>('cons_desde');
  static ValueKey<String> consCifra(String nombre) =>
      ValueKey<String>('cons_cifra_$nombre');

  /// Grabación: botón, casilla de permiso, empezar, parar, escuchar, borrar,
  /// y los textos de estado.
  static const consGrabar = ValueKey<String>('cons_grabar');
  static const consGrabPermiso = ValueKey<String>('cons_grab_permiso');
  static const consGrabEmpezar = ValueKey<String>('cons_grab_empezar');
  static const consGrabParar = ValueKey<String>('cons_grab_parar');
  static const consGrabTiempo = ValueKey<String>('cons_grab_tiempo');
  static const consGrabEscuchar = ValueKey<String>('cons_grab_escuchar');
  static const consGrabBorrar = ValueKey<String>('cons_grab_borrar');
  static const consGrabEstado = ValueKey<String>('cons_grab_estado');

  /// Resumen: botón, texto y copiar.
  static const consCompartir = ValueKey<String>('cons_compartir');
  static const consResumenTexto = ValueKey<String>('cons_resumen_texto');
  static const consCopiar = ValueKey<String>('cons_copiar');
}
