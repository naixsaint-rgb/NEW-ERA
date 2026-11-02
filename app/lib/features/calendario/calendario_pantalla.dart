import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/db/repositorios/eventos_repositorio.dart';
import '../../core/i18n/fechas.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/claves_ui.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/widgets/tarjeta_grande.dart';
import '../hoy/dominio/tomas.dart';
import '../hoy/vistas/piezas_hoy.dart';
import 'dominio/calendario.dart';

/// Pestaña Calendario de la familia: un mes con un punto de estado por día y,
/// debajo, las tomas y los hechos del día elegido. Todo sale de la base: ni
/// citas ni turnos hasta la semana 13.
class CalendarioPantalla extends ConsumerStatefulWidget {
  const CalendarioPantalla({super.key});

  @override
  ConsumerState<CalendarioPantalla> createState() => _CalendarioPantallaState();
}

class _CalendarioPantallaState extends ConsumerState<CalendarioPantalla> {
  late MesCalendario _mes;

  /// `yyyy-MM-dd` del día pulsado; nulo: hoy (o el día 1 en otro mes).
  String? _elegido;

  @override
  void initState() {
    super.initState();
    final zona = ref.read(contextoProvider).zonaHoraria;
    final ahora =
        ref.read(ahoraProvider).value ?? ref.read(relojProvider).ahora();
    _mes = MesCalendario.de(ahora, zona);
  }

  void _irA(MesCalendario mes) => setState(() {
    _mes = mes;
    _elegido = null;
  });

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final zona = ref.watch(contextoProvider).zonaHoraria;
    final ahora =
        ref.watch(ahoraProvider).value ?? ref.read(relojProvider).ahora();
    final hoy = fechaLocalDe(zona, ahora);
    final hoyEnEsteMes = MesCalendario(hoy.anio, hoy.mes) == _mes;
    final fechaHoy = fechaDeDia(hoy.anio, hoy.mes, hoy.dia);
    final elegido = _elegido ?? (hoyEnEsteMes ? fechaHoy : _mes.fecha(1));
    final datos = ref.watch(datosMesProvider(_mes));
    final abajo = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      key: ClavesUi.pantallaCalendario,
      body: ListView(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 24 + abajo),
        children: [
          CabeceraGrande(vispera: l.calVispera, titulo: l.pestanaCalendario),
          const SizedBox(height: 14),
          TarjetaGrande(
            margen: EdgeInsets.zero,
            relleno: const EdgeInsets.fromLTRB(4, 4, 4, 12),
            child: _Mes(
              mes: _mes,
              datos: datos.value,
              fechaHoy: fechaHoy,
              elegido: elegido,
              alAnterior: () => _irA(_mes.anterior),
              alSiguiente: () => _irA(_mes.siguiente),
              alElegir: (f) => setState(() => _elegido = f),
            ),
          ),
          separacionBloques,
          _DiaElegido(mes: _mes, fecha: elegido, datos: datos, zona: zona),
          separacionBloques,
          GrupoLista(
            children: [
              FilaLlegaPronto(titulo: l.calPie, subtitulo: l.llegaEnSemana(13)),
            ],
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------- El mes

String _inicialDia(AppLocalizations l, int diaSemana) => switch (diaSemana) {
  DateTime.monday => l.hoyInicialLunes,
  DateTime.tuesday => l.hoyInicialMartes,
  DateTime.wednesday => l.hoyInicialMiercoles,
  DateTime.thursday => l.hoyInicialJueves,
  DateTime.friday => l.hoyInicialViernes,
  DateTime.saturday => l.hoyInicialSabado,
  _ => l.hoyInicialDomingo,
};

/// Color del punto de un día (nulo: sin punto).
Color? colorDePunto(EstadoDiaCalendario estado, ColoresApp c) =>
    switch (estado) {
      EstadoDiaCalendario.sinTomas => null,
      EstadoDiaCalendario.completo => c.verde,
      EstadoDiaCalendario.parcial => c.naranjaRelleno,
      EstadoDiaCalendario.sinHechas => c.rojo,
      EstadoDiaCalendario.previstas => c.textoSecundario,
    };

class _Mes extends StatelessWidget {
  const _Mes({
    required this.mes,
    required this.datos,
    required this.fechaHoy,
    required this.elegido,
    required this.alAnterior,
    required this.alSiguiente,
    required this.alElegir,
  });

  final MesCalendario mes;

  /// Nulo mientras se cargan.
  final DatosMes? datos;
  final String fechaHoy;
  final String elegido;
  final VoidCallback alAnterior;
  final VoidCallback alSiguiente;
  final ValueChanged<String> alElegir;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final filas = <Widget>[];
    for (var fila = 0; fila < mes.filas; fila++) {
      filas.add(
        Row(
          children: [
            for (var col = 0; col < 7; col++)
              Expanded(
                child: _celda(context, fila * 7 + col - mes.huecosAntes + 1),
              ),
          ],
        ),
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            _Flecha(
              clave: ClavesUi.mesAnterior,
              icono: CupertinoIcons.chevron_left,
              etiqueta: l.calMesAnterior,
              alPulsar: alAnterior,
            ),
            Expanded(
              child: Semantics(
                header: true,
                child: TextoQueCabe(
                  mesYAnio(mes.pared),
                  key: ClavesUi.mesCalendario,
                  alineacion: Alignment.center,
                  estilo: t.titleMedium?.copyWith(color: c.texto),
                ),
              ),
            ),
            _Flecha(
              clave: ClavesUi.mesSiguiente,
              icono: CupertinoIcons.chevron_right,
              etiqueta: l.calMesSiguiente,
              alPulsar: alSiguiente,
            ),
          ],
        ),
        ExcludeSemantics(
          child: Row(
            children: [
              for (var d = DateTime.monday; d <= DateTime.sunday; d++)
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Text(
                      _inicialDia(l, d),
                      textAlign: TextAlign.center,
                      style: t.labelMedium?.copyWith(color: c.textoSecundario),
                    ),
                  ),
                ),
            ],
          ),
        ),
        ...filas,
        const SizedBox(height: 8),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: _Leyenda(),
        ),
      ],
    );
  }

  /// La casilla del día [dia] (1 a N), o un hueco en blanco fuera del mes.
  Widget _celda(BuildContext context, int dia) {
    if (dia < 1 || dia > mes.diasEnMes) {
      return const SizedBox(height: CeldaDiaCalendario.alto);
    }
    final l = context.l;
    final fecha = mes.fecha(dia);
    final esHoy = fecha == fechaHoy;
    final tomas = datos?.tomasDe(fecha) ?? const <TomaVista>[];
    final estado = datos?.estadoDe(fecha) ?? EstadoDiaCalendario.sinTomas;
    final nombreDia = fechaLarga(mes.paredDe(dia));
    final cuenta = contarTomas(tomas);
    final base = switch (estado) {
      EstadoDiaCalendario.sinTomas => l.hoySemanticaCeldaSinTomas(
        esHoy ? l.calDiaHoy(nombreDia) : nombreDia,
      ),
      EstadoDiaCalendario.previstas => l.calSemanticaPrevistas(
        esHoy ? l.calDiaHoy(nombreDia) : nombreDia,
        cuenta.previstas,
      ),
      _ => l.hoySemanticaCeldaDia(
        esHoy ? l.calDiaHoy(nombreDia) : nombreDia,
        cuenta.hechas,
        cuenta.previstas,
      ),
    };
    return CeldaDiaCalendario(
      key: ClavesUi.diaCalendario(fecha),
      dia: dia,
      estado: estado,
      esHoy: esHoy,
      seleccionado: fecha == elegido,
      etiqueta: base,
      alPulsar: () => alElegir(fecha),
    );
  }
}

/// Flecha ‹ o › del mes: 48 de zona táctil.
class _Flecha extends StatelessWidget {
  const _Flecha({
    required this.clave,
    required this.icono,
    required this.etiqueta,
    required this.alPulsar,
  });

  final Key clave;
  final IconData icono;
  final String etiqueta;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Semantics(
      key: clave,
      button: true,
      label: etiqueta,
      excludeSemantics: true,
      onTap: alPulsar,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: alPulsar,
        child: SizedBox.square(
          dimension: 48,
          child: Icon(icono, size: 22, color: c.azul),
        ),
      ),
    );
  }
}

/// Casilla de un día: el número y, debajo, su punto de estado. Hoy lleva el
/// número en azul y un borde; el día elegido, fondo azul claro. Se lee como
/// un botón ("Martes 13 de octubre, hoy: 1 de 3 tomas hechas").
class CeldaDiaCalendario extends StatelessWidget {
  const CeldaDiaCalendario({
    super.key,
    required this.dia,
    required this.estado,
    required this.esHoy,
    required this.seleccionado,
    required this.etiqueta,
    required this.alPulsar,
  });

  /// Alto de la zona táctil.
  static const alto = 48.0;

  /// Diámetro del punto de estado.
  static const punto = 8.0;

  final int dia;
  final EstadoDiaCalendario estado;
  final bool esHoy;
  final bool seleccionado;
  final String etiqueta;
  final VoidCallback alPulsar;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final colorPunto = colorDePunto(estado, c);
    final colorNumero = seleccionado
        ? c.azulSobreTinte
        : (esHoy ? c.azul : c.texto);
    return Semantics(
      button: true,
      selected: seleccionado,
      label: etiqueta,
      excludeSemantics: true,
      onTap: alPulsar,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: alPulsar,
        child: SizedBox(
          height: alto,
          child: Padding(
            padding: const EdgeInsets.all(2),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: seleccionado ? c.azulClaro : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
                border: esHoy ? Border.all(color: c.azul, width: 2) : null,
              ),
              // La casilla no crece con la letra: el número y el punto
              // caben siempre en los 48.
              child: MediaQuery.withClampedTextScaling(
                maxScaleFactor: 1.3,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      dia.toString(),
                      maxLines: 1,
                      softWrap: false,
                      style: t.bodyLarge?.copyWith(
                        color: colorNumero,
                        fontWeight: esHoy || seleccionado
                            ? FontWeight.w800
                            : FontWeight.w500,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 3),
                    SizedBox.square(
                      dimension: punto,
                      child: colorPunto == null
                          ? null
                          : DecoratedBox(
                              decoration: BoxDecoration(
                                color: colorPunto,
                                shape: BoxShape.circle,
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Qué quiere decir cada punto, con palabras (ningún estado va solo por
/// color).
class _Leyenda extends StatelessWidget {
  const _Leyenda();

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    Widget item(EstadoDiaCalendario estado, String texto) => Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ExcludeSemantics(
          child: Container(
            width: CeldaDiaCalendario.punto,
            height: CeldaDiaCalendario.punto,
            decoration: BoxDecoration(
              color: colorDePunto(estado, c),
              shape: BoxShape.circle,
            ),
          ),
        ),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            texto,
            style: t.bodySmall?.copyWith(color: c.textoSecundario),
          ),
        ),
      ],
    );
    return Wrap(
      spacing: 14,
      runSpacing: 4,
      children: [
        item(EstadoDiaCalendario.completo, l.calLeyendaHechas),
        item(EstadoDiaCalendario.parcial, l.calLeyendaAlgunas),
        item(EstadoDiaCalendario.sinHechas, l.calLeyendaNinguna),
        item(EstadoDiaCalendario.previstas, l.calLeyendaPrevistas),
      ],
    );
  }
}

// ---------------------------------------------------------- El día elegido

class _DiaElegido extends ConsumerWidget {
  const _DiaElegido({
    required this.mes,
    required this.fecha,
    required this.datos,
    required this.zona,
  });

  final MesCalendario mes;

  /// `yyyy-MM-dd`.
  final String fecha;
  final AsyncValue<DatosMes> datos;
  final String zona;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final dia = int.parse(fecha.substring(8));
    final titulo = Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(16, 0, 16, 8),
      child: Semantics(
        header: true,
        child: Text(
          fechaLarga(mes.paredDe(dia)),
          key: ClavesUi.diaElegido,
          style: t.titleMedium?.copyWith(color: c.texto),
        ),
      ),
    );
    final cuerpo = datos.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) =>
          Text(l.errorGenerico, style: t.bodyMedium?.copyWith(color: c.texto)),
      data: (d) {
        final tomas = d.tomasDe(fecha);
        final hechos = d.hechosDe(fecha);
        if (tomas.isEmpty && hechos.isEmpty) {
          return GrupoLista(
            children: [FilaLista(titulo: l.calSinNada, apagada: true)],
          );
        }
        final nombres = ref.watch(nombresAutoresProvider);
        final alias = ref.watch(personaProvider).value?.alias;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (tomas.isNotEmpty)
              GrupoLista(
                sangria: FilaTomaHoy.sangria,
                children: [
                  for (final x in tomas)
                    FilaTomaHoy(toma: x, nota: quienConfirmo(l, x, nombres)),
                ],
              ),
            if (tomas.isNotEmpty && hechos.isNotEmpty) separacionBloques,
            if (hechos.isNotEmpty)
              GrupoLista(
                titulo: l.calHechos,
                children: [
                  for (final h in hechos)
                    _FilaHecho(
                      hecho: h,
                      zona: zona,
                      nombres: nombres,
                      alias: alias,
                    ),
                ],
              ),
          ],
        );
      },
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [titulo, cuerpo],
    );
  }
}

/// Un hecho que no es de toma: icono, qué fue y su hora.
class _FilaHecho extends StatelessWidget {
  const _FilaHecho({
    required this.hecho,
    required this.zona,
    required this.nombres,
    required this.alias,
  });

  final HechoDelDia hecho;
  final String zona;
  final Map<String, String> nombres;
  final String? alias;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final e = hecho.evento;
    final payload = EventosRepositorio.payloadDe(e);
    final hora = horaCorta(
      aLocal(
        DateTime.fromMillisecondsSinceEpoch(e.ocurridoEn, isUtc: true),
        zona,
      ),
    );
    final (icono, fondo, simbolo, titulo, subtitulo) = switch (hecho.tipo) {
      TipoEvento.mensajeFamilia => (
        CupertinoIcons.chat_bubble_fill,
        c.azul,
        c.sobreAzul,
        l.calHechoMensaje(alias ?? l.calLaPersona),
        _texto(payload['texto']),
      ),
      TipoEvento.ayudaPedida => (
        CupertinoIcons.exclamationmark_triangle_fill,
        c.rojo,
        c.sobreRojo,
        l.calHechoAyuda,
        null,
      ),
      TipoEvento.llamadaIniciada => (
        CupertinoIcons.phone_fill,
        c.verde,
        c.sobreVerde,
        l.calHechoLlamada,
        nombres[payload['miembroId']],
      ),
      _ => (
        CupertinoIcons.capsule_fill,
        c.indigo,
        IconoCuadrado.simboloSobre(c.indigo),
        l.calHechoMedicamento,
        _texto(payload['nombre']),
      ),
    };
    return FilaLista(
      leading: IconoCuadrado(icono, fondo: fondo, color: simbolo),
      titulo: titulo,
      subtitulo: subtitulo,
      detalle: hora,
    );
  }

  static String? _texto(Object? v) {
    if (v is! String) return null;
    final t = v.trim();
    return t.isEmpty ? null : t;
  }
}
