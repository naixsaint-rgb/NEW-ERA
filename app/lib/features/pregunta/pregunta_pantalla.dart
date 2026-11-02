import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:safety_core/safety_core.dart';

import '../../core/db/repositorios/voces_repositorio.dart';
import '../../core/enrutado/rutas.dart';
import '../../core/i18n/fechas.dart';
import '../../core/plataforma/audio/reproductor.dart';
import '../../core/providers.dart';
import '../../core/tema/colores.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/claves_ui.dart';
import '../../shared/l10n_ext.dart';
import '../../shared/widgets/boton_grande.dart';

/// Cómo se pinta una respuesta.
enum _Estilo { verde, naranja, rojo, azul }

/// Una respuesta posible de una pregunta.
class _Opcion {
  const _Opcion(this.clave, this.texto, this.icono, this.estilo);

  /// Clave de test (`ClavesUi.respuesta(clave)`).
  final String clave;
  final String Function(AppLocalizations) texto;
  final IconData? icono;
  final _Estilo estilo;
}

/// Una pregunta con sus respuestas y la frase grabada que la dice.
class _Pregunta {
  const _Pregunta(this.tipo, this.uso, this.texto, this.opciones);

  final TipoPreguntaControl tipo;
  final UsoFrase uso;
  final String Function(AppLocalizations) texto;
  final List<_Opcion> opciones;
}

final _preguntas = [
  _Pregunta(
    TipoPreguntaControl.estado,
    UsoFrase.comoEstas,
    (l) => l.preguntaComoEstas,
    [
      _Opcion(
        'bien',
        (l) => l.preguntaRespBien,
        Icons.sentiment_satisfied_alt,
        _Estilo.verde,
      ),
      _Opcion(
        'regular',
        (l) => l.preguntaRespRegular,
        Icons.sentiment_neutral,
        _Estilo.naranja,
      ),
      _Opcion(
        'mal',
        (l) => l.preguntaRespMal,
        Icons.sentiment_dissatisfied,
        _Estilo.rojo,
      ),
    ],
  ),
  _Pregunta(
    TipoPreguntaControl.dolor,
    UsoFrase.teDuele,
    (l) => l.preguntaTeDuele,
    [
      _Opcion(
        'nada',
        (l) => l.preguntaRespNada,
        CupertinoIcons.checkmark_circle,
        _Estilo.verde,
      ),
      _Opcion(
        'poco',
        (l) => l.preguntaRespUnPoco,
        CupertinoIcons.exclamationmark_circle,
        _Estilo.naranja,
      ),
      _Opcion(
        'mucho',
        (l) => l.preguntaRespMucho,
        CupertinoIcons.exclamationmark_triangle,
        _Estilo.rojo,
      ),
    ],
  ),
  _Pregunta(
    TipoPreguntaControl.plan,
    UsoFrase.queHaras,
    (l) => l.preguntaQueHaras,
    [
      _Opcion('pasear', (l) => l.preguntaRespPasear, null, _Estilo.azul),
      _Opcion('descansar', (l) => l.preguntaRespDescansar, null, _Estilo.azul),
      _Opcion('tele', (l) => l.preguntaRespVerLaTele, null, _Estilo.azul),
      _Opcion('otra', (l) => l.preguntaRespOtraCosa, null, _Estilo.azul),
    ],
  ),
];

/// Lo que se guarda cuando contesta "Prefiero decirlo" (la grabación de su
/// voz llega más adelante).
const respuestaDecirlo = 'decirlo';

/// Pregunta de la persona (maqueta C-Persona): "¿Cómo estás?" con la voz de un
/// familiar y respuestas grandes. Tres preguntas en orden y una pantalla de
/// "Gracias".
///
/// La voz: cada pregunta suena al mostrarse con la frase grabada de la
/// familia (la primera voz del círculo que la tenga aprobada) y otra vez al
/// tocar el altavoz. Sin frase grabada no suena nada ni hay tarjeta de voz.
///
/// Control por horas (plan v3, 2.4 bis): fuera del modo prueba, cada
/// respuesta se guarda al tocarla (`preguntas_control`, `respuestas` y
/// `pregunta_respondida` con la ronda, la pregunta, la respuesta y lo que
/// tardó desde que la vio) y viaja a la familia por el cartero. "Prefiero
/// decirlo" se guarda como `decirlo`. Al abrirse para una ronda, para su
/// alarma.
///
/// Con [prueba] (desde la familia) no se guarda nada y al terminar vuelve a
/// Medicación; si no, al inicio de la persona.
class PreguntaPantalla extends ConsumerStatefulWidget {
  const PreguntaPantalla({super.key, this.prueba = false, this.ronda});

  /// `?prueba=1` de la ruta (lo lee el router).
  final bool prueba;

  /// `?ronda=` de la ruta: la ronda del control por horas que se contesta.
  /// Sin ella (fuera del modo prueba), la de la hora en punto de ahora.
  final String? ronda;

  @override
  ConsumerState<PreguntaPantalla> createState() => _PreguntaPantallaState();
}

class _PreguntaPantallaState extends ConsumerState<PreguntaPantalla> {
  /// Lo contestado hasta ahora, en orden de pregunta.
  final _respuestas = <String>[];
  Timer? _cierre;
  late final Reproductor _reproductor;

  /// Pregunta cuya frase ya sonó al mostrarse.
  int? _sonadaEn;

  /// Cuándo se mostró la pregunta actual (para el tiempo de respuesta).
  late DateTime _mostradaEn;

  /// Ronda que se contesta (nula en modo prueba: no se guarda nada).
  String? _ronda;

  /// Pregunta que se está mostrando (0–2); 3 es la pantalla de "Gracias".
  int get _indice => _respuestas.length;
  bool get _terminada => _indice >= _preguntas.length;

  @override
  void initState() {
    super.initState();
    _reproductor = ref.read(reproductorProvider);
    _mostradaEn = ref.read(relojProvider).ahora();
    if (!widget.prueba) {
      final ronda = widget.ronda;
      if (ronda != null && esIdRonda(ronda)) {
        _ronda = ronda;
        // La alarma de la ronda deja de sonar: ahora habla la pantalla.
        unawaited(_pararAlarma(ronda));
      } else {
        final l = aLocal(_mostradaEn, ref.read(contextoProvider).zonaHoraria);
        _ronda = idRonda(l.year, l.month, l.day, l.hour);
      }
    }
  }

  Future<void> _pararAlarma(String ronda) async {
    try {
      await ref.read(servicioAlarmasProvider).cancelar(ronda);
    } catch (_) {
      // Si no se deja parar, la pregunta sigue igual.
    }
  }

  /// Guarda la respuesta [clave] a la pregunta [indice] (fuera del modo
  /// prueba). Nunca bloquea la pantalla.
  void _guardar(int indice, String clave) {
    final ronda = _ronda;
    if (ronda == null) return;
    final pregunta = _preguntas[indice];
    final frase = ref.read(
      fraseSonoraProvider((uso: pregunta.uso, vozId: null)),
    );
    final repo = ref.read(controlHorasRepositorioProvider);
    unawaited(
      repo
          .responder(
            ronda: ronda,
            tipo: pregunta.tipo,
            valor: clave,
            texto: pregunta.texto(context.l),
            mostradaEn: _mostradaEn,
            fraseId: frase?.fraseId,
          )
          .then<void>((_) {}, onError: (Object _) {}),
    );
  }

  @override
  void dispose() {
    _cierre?.cancel();
    unawaited(_reproductor.parar());
    super.dispose();
  }

  /// La frase de la pregunta [indice] suena una vez al mostrarse.
  void _sonarAlMostrar(int indice, FraseSonora? frase) {
    if (frase == null || _sonadaEn == indice) return;
    _sonadaEn = indice;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _indice == indice) {
        unawaited(_reproductor.reproducir(frase.ruta));
      }
    });
  }

  void _contestar(String clave) {
    if (_terminada) return;
    unawaited(_reproductor.parar());
    _guardar(_indice, clave);
    _mostradaEn = ref.read(relojProvider).ahora();
    setState(() => _respuestas.add(clave));
    if (_terminada) {
      _cierre = Timer(const Duration(seconds: 2), () {
        if (!mounted) return;
        context.go(widget.prueba ? Rutas.pestana('medicacion') : Rutas.persona);
      });
    }
  }

  void _avisar(String texto) {
    final mensajes = ScaffoldMessenger.of(context);
    mensajes.hideCurrentSnackBar();
    mensajes.showSnackBar(
      SnackBar(content: Text(texto), duration: const Duration(seconds: 2)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    return Scaffold(
      key: ClavesUi.pregunta,
      backgroundColor: c.tarjeta,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: _terminada
                ? _Gracias(
                    respuestas: _respuestas,
                    prueba: widget.prueba,
                    textoDe: (i, clave) => _textoRespuesta(l, i, clave),
                  )
                : LayoutBuilder(
                    // Pantallas bajas (375×728 con la letra al 130 %):
                    // botones de 84 y título de 40, y todo desplazable.
                    builder: (context, limites) => _contenidoPregunta(
                      context,
                      compacta: limites.maxHeight < 760,
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  String _textoRespuesta(AppLocalizations l, int i, String clave) {
    if (clave == respuestaDecirlo) return l.preguntaPrefieroDecirlo;
    return _preguntas[i].opciones.firstWhere((o) => o.clave == clave).texto(l);
  }

  Widget _contenidoPregunta(BuildContext context, {required bool compacta}) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final pregunta = _preguntas[_indice];
    final contexto = ref.watch(contextoProvider);
    final ahora =
        ref.watch(ahoraProvider).value ?? ref.read(relojProvider).ahora();
    final hora = horaCorta(aLocal(ahora, contexto.zonaHoraria));
    final frase = ref.watch(
      fraseSonoraProvider((uso: pregunta.uso, vozId: null)),
    );
    _sonarAlMostrar(_indice, frase);

    return SingleChildScrollView(
      key: ValueKey<int>(_indice),
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  l.preguntaProgreso(hora, _indice + 1),
                  style: t.titleSmall?.copyWith(
                    color: c.textoSecundario,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              _Puntos(actual: _indice, total: _preguntas.length),
            ],
          ),
          const SizedBox(height: 24),
          if (frase != null) ...[
            _TarjetaVoz(
              quien: l.preguntaTeLoPregunta(frase.nombre),
              alTocar: () => unawaited(_reproductor.reproducir(frase.ruta)),
            ),
            const SizedBox(height: 24),
          ],
          Semantics(
            header: true,
            child: Text(
              pregunta.texto(l),
              style: t.displayMedium?.copyWith(
                fontSize: compacta ? 40 : 48,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
                height: 1.05,
                color: c.texto,
              ),
            ),
          ),
          const SizedBox(height: 24),
          if (pregunta.opciones.length <= 3)
            for (final (i, o) in pregunta.opciones.indexed) ...[
              if (i > 0) const SizedBox(height: 14),
              _botonGrande(o, l, c, altura: compacta ? 84 : 108),
            ]
          else
            _CuadriculaOpciones(
              opciones: pregunta.opciones,
              constructor: (o) => _botonGrande(o, l, c, altura: 80, tamano: 24),
            ),
          const SizedBox(height: 24),
          _BotonDecirlo(
            onPressed: () {
              _avisar(l.preguntaDecirloLlega);
              _contestar(respuestaDecirlo);
            },
          ),
        ],
      ),
    );
  }

  Widget _botonGrande(
    _Opcion o,
    AppLocalizations l,
    ColoresApp c, {
    double altura = 108,
    double tamano = 32,
  }) {
    final (color, texto) = switch (o.estilo) {
      _Estilo.verde => (c.verde, c.sobreVerde),
      _Estilo.naranja => (c.naranjaRelleno, c.sobreNaranja),
      _Estilo.rojo => (c.rojo, c.sobreRojo),
      _Estilo.azul => (c.azulClaro, c.azulSobreTinte),
    };
    return BotonGrande(
      key: ClavesUi.respuesta(o.clave),
      texto: o.texto(l),
      icono: o.icono,
      color: color,
      colorTexto: texto,
      altura: altura,
      tamanoTexto: tamano,
      onPressed: () => _contestar(o.clave),
    );
  }
}

/// Tres puntos de progreso (el de la pregunta actual, oscuro).
class _Puntos extends StatelessWidget {
  const _Puntos({required this.actual, required this.total});

  final int actual;
  final int total;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    return Semantics(
      label: context.l.preguntaPuntos(actual + 1),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < total; i++) ...[
            if (i > 0) const SizedBox(width: 6),
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: i == actual ? c.texto : c.barraBorde,
                borderRadius: BorderRadius.circular(5),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Tarjeta gris con el altavoz: "Te lo pregunta Lucía". Tocarla repite la
/// frase grabada.
class _TarjetaVoz extends StatelessWidget {
  const _TarjetaVoz({required this.quien, required this.alTocar});

  final String quien;
  final VoidCallback alTocar;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    final forma = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(22),
    );
    return Material(
      color: c.rellenoSuave,
      shape: forma,
      clipBehavior: Clip.antiAlias,
      child: Semantics(
        button: true,
        child: InkWell(
          onTap: alTocar,
          customBorder: forma,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 84),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              child: Row(
                children: [
                  ExcludeSemantics(
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: c.azul,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        CupertinoIcons.speaker_2_fill,
                        size: 26,
                        color: c.sobreAzul,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          quien,
                          style: t.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                            color: c.texto,
                          ),
                        ),
                        Text(
                          l.preguntaVolverAOir,
                          style: t.bodyMedium?.copyWith(
                            color: c.textoSecundario,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Las cuatro respuestas de la tercera pregunta: dos filas de dos. Con el
/// texto muy grande, una debajo de otra para que no se parta ninguna palabra.
class _CuadriculaOpciones extends StatelessWidget {
  const _CuadriculaOpciones({
    required this.opciones,
    required this.constructor,
  });

  final List<_Opcion> opciones;
  final Widget Function(_Opcion) constructor;

  @override
  Widget build(BuildContext context) {
    final columna = MediaQuery.textScalerOf(context).scale(24) > 27;
    if (columna) {
      return Column(
        children: [
          for (final (i, o) in opciones.indexed) ...[
            if (i > 0) const SizedBox(height: 14),
            constructor(o),
          ],
        ],
      );
    }
    return Column(
      children: [
        for (var f = 0; f < opciones.length; f += 2) ...[
          if (f > 0) const SizedBox(height: 14),
          Row(
            children: [
              Expanded(child: constructor(opciones[f])),
              const SizedBox(width: 14),
              Expanded(child: constructor(opciones[f + 1])),
            ],
          ),
        ],
      ],
    );
  }
}

/// "Prefiero decirlo": botón con borde y micrófono. Sin grabación todavía.
class _BotonDecirlo extends StatelessWidget {
  const _BotonDecirlo({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    return SizedBox(
      height: 72,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: const Icon(CupertinoIcons.mic, size: 28),
        label: Text(context.l.preguntaPrefieroDecirlo),
        style: OutlinedButton.styleFrom(
          foregroundColor: c.texto,
          backgroundColor: c.tarjeta,
          side: BorderSide(color: c.barraBorde, width: 2),
          minimumSize: const Size.fromHeight(72),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
          ),
          textStyle: t.titleMedium?.copyWith(
            fontSize: 22,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Pantalla de "Gracias": las respuestas en palabras durante 2 segundos.
class _Gracias extends StatelessWidget {
  const _Gracias({
    required this.respuestas,
    required this.prueba,
    required this.textoDe,
  });

  final List<String> respuestas;
  final bool prueba;
  final String Function(int pregunta, String clave) textoDe;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    final t = Theme.of(context).textTheme;
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: ExcludeSemantics(
              child: Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  color: c.verdeClaro,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.checkmark_alt,
                  size: 48,
                  color: c.verde,
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Semantics(
            header: true,
            child: Text(
              l.preguntaGracias,
              style: t.displayMedium?.copyWith(
                fontSize: 48,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
                height: 1.05,
                color: c.texto,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            l.preguntaHasContestado,
            style: t.bodyLarge?.copyWith(color: c.textoSecundario),
          ),
          const SizedBox(height: 20),
          for (final (i, clave) in respuestas.indexed) ...[
            if (i > 0) const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: c.rellenoSuave,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _preguntas[i].texto(l),
                    style: t.bodyMedium?.copyWith(color: c.textoSecundario),
                  ),
                  Text(
                    textoDe(i, clave),
                    style: t.headlineSmall?.copyWith(color: c.texto),
                  ),
                ],
              ),
            ),
          ],
          if (prueba) ...[
            const SizedBox(height: 20),
            Text(
              l.preguntaModoPrueba,
              style: t.bodyLarge?.copyWith(color: c.textoSecundario),
            ),
          ],
        ],
      ),
    );
  }
}
