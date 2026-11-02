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
}
