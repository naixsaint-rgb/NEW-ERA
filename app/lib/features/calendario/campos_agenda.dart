import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../core/db/repositorios/agenda_repositorio.dart';
import '../../core/i18n/fechas.dart';
import '../../core/tema/colores.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/ios/ios.dart';
import '../../shared/l10n_ext.dart';

/// `yyyy-MM-dd` a fecha UTC a las 00:00 (sin zona, para formatearla).
DateTime fechaDeTexto(String fecha) => DateTime.utc(
  int.parse(fecha.substring(0, 4)),
  int.parse(fecha.substring(5, 7)),
  int.parse(fecha.substring(8, 10)),
);

/// Fecha a `yyyy-MM-dd`.
String textoDeFecha(DateTime d) {
  String dos(int n) => n.toString().padLeft(2, '0');
  return '${d.year.toString().padLeft(4, '0')}-${dos(d.month)}-${dos(d.day)}';
}

/// Selector de fecha nativo de Flutter (en español de España); devuelve
/// `yyyy-MM-dd` o nulo si se cancela.
Future<String?> elegirFecha(BuildContext context, String actual) async {
  final f = await showDatePicker(
    context: context,
    initialDate: fechaDeTexto(actual),
    firstDate: DateTime.utc(2020),
    lastDate: DateTime.utc(2100),
  );
  return f == null ? null : textoDeFecha(f);
}

/// Selector de hora nativo en 24 horas; devuelve `HH:mm` o nulo.
Future<String?> elegirHora(BuildContext context, String actual) async {
  final t = await showTimePicker(
    context: context,
    initialTime: TimeOfDay(
      hour: int.parse(actual.substring(0, 2)),
      minute: int.parse(actual.substring(3, 5)),
    ),
    builder: (context, hijo) => MediaQuery(
      data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
      child: hijo!,
    ),
  );
  if (t == null) return null;
  String dos(int n) => n.toString().padLeft(2, '0');
  return '${dos(t.hour)}:${dos(t.minute)}';
}

/// Texto de un tipo de cita.
String etiquetaTipoCita(AppLocalizations l, String tipo) => switch (tipo) {
  TipoCita.analisis => l.citaTipoAnalisis,
  TipoCita.otra => l.citaTipoOtra,
  _ => l.citaTipoMedico,
};

/// Icono de un tipo de cita.
IconData iconoTipoCita(String tipo) => switch (tipo) {
  TipoCita.analisis => CupertinoIcons.drop_fill,
  TipoCita.otra => CupertinoIcons.calendar,
  _ => CupertinoIcons.heart_fill,
};

/// Marca de un día con cita (cuadradito) o con turno (rombo): forma distinta
/// del punto redondo de las tomas.
class MarcaAgenda extends StatelessWidget {
  const MarcaAgenda({super.key, required this.esCita, this.tamano = 6});

  final bool esCita;
  final double tamano;

  @override
  Widget build(BuildContext context) {
    final c = context.colores;
    final caja = DecoratedBox(
      decoration: BoxDecoration(
        color: esCita ? c.indigo : c.morado,
        borderRadius: BorderRadius.circular(esCita ? 1.5 : 0),
      ),
    );
    return ExcludeSemantics(
      child: SizedBox.square(
        dimension: tamano + (esCita ? 0 : 2),
        child: esCita
            ? caja
            : Transform.rotate(
                angle: 0.785398,
                child: SizedBox.square(dimension: tamano, child: caja),
              ),
      ),
    );
  }
}

/// Fila "etiqueta … valor" que abre un selector de fecha u hora.
class FilaSelector extends StatelessWidget {
  const FilaSelector({
    super.key,
    required this.etiqueta,
    required this.valor,
    required this.icono,
    required this.alPulsar,
    this.enLinea = true,
  });

  final String etiqueta;
  final String valor;
  final IconData icono;
  final VoidCallback? alPulsar;

  /// El valor va a la derecha (una hora); si es largo (una fecha), debajo.
  final bool enLinea;

  @override
  Widget build(BuildContext context) {
    return FilaLista(
      leading: IconoCuadrado(icono),
      titulo: etiqueta,
      subtitulo: enLinea ? null : valor,
      detalle: enLinea ? valor : null,
      onTap: alPulsar,
      conChevron: false,
      etiquetaSemantica: '$etiqueta, $valor',
    );
  }
}

/// Fecha larga de `yyyy-MM-dd`: "Martes 13 de octubre".
String fechaLargaDeTexto(String fecha) => fechaLarga(fechaDeTexto(fecha));

/// Fila con marca de elegida (como la del papel de un familiar).
class FilaElegir extends StatelessWidget {
  const FilaElegir({
    super.key,
    required this.clave,
    required this.titulo,
    required this.elegida,
    required this.alPulsar,
  });

  final Key clave;
  final String titulo;
  final bool elegida;
  final VoidCallback? alPulsar;

  @override
  Widget build(BuildContext context) {
    final l = context.l;
    final c = context.colores;
    return FilaLista(
      key: clave,
      titulo: titulo,
      conChevron: false,
      trailing: elegida
          ? Icon(CupertinoIcons.checkmark_alt, color: c.azul)
          : null,
      etiquetaSemantica: elegida ? '$titulo, ${l.circSeleccionado}' : null,
      onTap: alPulsar,
    );
  }
}
