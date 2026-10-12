import 'package:flutter/widgets.dart';

import '../l10n/app_localizations.dart';

extension ContextoL10n on BuildContext {
  /// Textos de la app en español de España.
  AppLocalizations get l => AppLocalizations.of(this);
}
