import '../../core/db/base_datos.dart';
import '../../core/db/repositorios/voces_repositorio.dart';
import '../../l10n/app_localizations.dart';

/// Texto sugerido de cada frase (lo que el familiar lee en voz alta).
String textoFrase(AppLocalizations l, UsoFrase uso, String alias) =>
    switch (uso) {
      UsoFrase.toma => l.vozFraseToma(alias),
      UsoFrase.muyBien => l.vozFraseMuyBien,
      UsoFrase.comoEstas => l.vozFraseComoEstas,
      UsoFrase.teDuele => l.vozFraseTeDuele,
      UsoFrase.queHaras => l.vozFraseQueHaras,
    };

/// Cuándo suena cada frase.
String cuandoSuena(AppLocalizations l, UsoFrase uso) => switch (uso) {
  UsoFrase.toma => l.vozUsoToma,
  UsoFrase.muyBien => l.vozUsoMuyBien,
  UsoFrase.comoEstas ||
  UsoFrase.teDuele ||
  UsoFrase.queHaras => l.vozUsoPregunta,
};

/// Voz activa más reciente de [miembroId] (nula si no tiene o la retiró).
Voz? vozActivaDe(String miembroId, List<Voz> voces) {
  Voz? r;
  for (final v in voces) {
    if (v.miembroId != miembroId || v.retiradaEn != null) continue;
    if (v.tipo != 'grabada') continue;
    if (r == null || v.creadaEn > r.creadaEn) r = v;
  }
  return r;
}

/// Última voz retirada de [miembroId], si la hay.
Voz? vozRetiradaDe(String miembroId, List<Voz> voces) {
  Voz? r;
  for (final v in voces) {
    if (v.miembroId != miembroId || v.retiradaEn == null) continue;
    if (r == null || v.retiradaEn! > r.retiradaEn!) r = v;
  }
  return r;
}

/// Frase más reciente de [vozId] para cada uso.
Map<UsoFrase, Frase> frasesDeVoz(String vozId, List<Frase> frases) {
  final r = <UsoFrase, Frase>{};
  for (final f in frases) {
    if (f.vozId != vozId) continue;
    final uso = UsoFrase.desdeNombre(f.uso);
    if (uso == null) continue;
    final ya = r[uso];
    if (ya == null || f.creadaEn > ya.creadaEn) r[uso] = f;
  }
  return r;
}
