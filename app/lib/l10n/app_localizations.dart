import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('es')];

  /// No description provided for @appTitulo.
  ///
  /// In es, this message translates to:
  /// **'NEW-ERA'**
  String get appTitulo;

  /// No description provided for @avisoDemo.
  ///
  /// In es, this message translates to:
  /// **'Demo con datos de ejemplo. Sin cifrar: no escribas datos reales.'**
  String get avisoDemo;

  /// No description provided for @cambiarPerfil.
  ///
  /// In es, this message translates to:
  /// **'Cambiar perfil'**
  String get cambiarPerfil;

  /// No description provided for @cambiarPerfilAyuda.
  ///
  /// In es, this message translates to:
  /// **'Vuelve a elegir de quién es este móvil.'**
  String get cambiarPerfilAyuda;

  /// No description provided for @perfilTitulo.
  ///
  /// In es, this message translates to:
  /// **'¿De quién es este móvil?'**
  String get perfilTitulo;

  /// No description provided for @perfilAyuda.
  ///
  /// In es, this message translates to:
  /// **'Se puede cambiar más tarde desde Ajustes.'**
  String get perfilAyuda;

  /// No description provided for @perfilPersona.
  ///
  /// In es, this message translates to:
  /// **'De la persona'**
  String get perfilPersona;

  /// No description provided for @perfilFamilia.
  ///
  /// In es, this message translates to:
  /// **'De un familiar o cuidador'**
  String get perfilFamilia;

  /// No description provided for @errorGenerico.
  ///
  /// In es, this message translates to:
  /// **'Algo ha ido mal. Inténtalo otra vez.'**
  String get errorGenerico;

  /// No description provided for @alguien.
  ///
  /// In es, this message translates to:
  /// **'alguien'**
  String get alguien;

  /// No description provided for @cancelar.
  ///
  /// In es, this message translates to:
  /// **'Cancelar'**
  String get cancelar;

  /// No description provided for @noConsta.
  ///
  /// In es, this message translates to:
  /// **'No consta'**
  String get noConsta;

  /// No description provided for @campoObligatorio.
  ///
  /// In es, this message translates to:
  /// **'Este campo es obligatorio'**
  String get campoObligatorio;

  /// No description provided for @pestanaHoy.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get pestanaHoy;

  /// No description provided for @pestanaMedicacion.
  ///
  /// In es, this message translates to:
  /// **'Medicación'**
  String get pestanaMedicacion;

  /// No description provided for @pestanaCalendario.
  ///
  /// In es, this message translates to:
  /// **'Calendario'**
  String get pestanaCalendario;

  /// No description provided for @pestanaConsultas.
  ///
  /// In es, this message translates to:
  /// **'Consultas'**
  String get pestanaConsultas;

  /// No description provided for @pestanaAlarmas.
  ///
  /// In es, this message translates to:
  /// **'Alarmas'**
  String get pestanaAlarmas;

  /// No description provided for @pestanaVoces.
  ///
  /// In es, this message translates to:
  /// **'Voces'**
  String get pestanaVoces;

  /// No description provided for @pestanaAlimentacion.
  ///
  /// In es, this message translates to:
  /// **'Alimentación'**
  String get pestanaAlimentacion;

  /// No description provided for @pestanaIdeas.
  ///
  /// In es, this message translates to:
  /// **'Ideas y tablas'**
  String get pestanaIdeas;

  /// No description provided for @pestanaCirculo.
  ///
  /// In es, this message translates to:
  /// **'Círculo'**
  String get pestanaCirculo;

  /// No description provided for @pestanaAjustes.
  ///
  /// In es, this message translates to:
  /// **'Ajustes'**
  String get pestanaAjustes;

  /// No description provided for @pestanaMas.
  ///
  /// In es, this message translates to:
  /// **'Más'**
  String get pestanaMas;

  /// No description provided for @pestanaResumen.
  ///
  /// In es, this message translates to:
  /// **'Resumen'**
  String get pestanaResumen;

  /// No description provided for @botonMasAyuda.
  ///
  /// In es, this message translates to:
  /// **'Calendario, consultas, alarmas, voces, círculo y ajustes'**
  String get botonMasAyuda;

  /// No description provided for @volver.
  ///
  /// In es, this message translates to:
  /// **'Volver'**
  String get volver;

  /// No description provided for @enConstruccion.
  ///
  /// In es, this message translates to:
  /// **'En construcción'**
  String get enConstruccion;

  /// No description provided for @aspecto.
  ///
  /// In es, this message translates to:
  /// **'Aspecto'**
  String get aspecto;

  /// No description provided for @aspectoAutomatico.
  ///
  /// In es, this message translates to:
  /// **'Automático'**
  String get aspectoAutomatico;

  /// No description provided for @aspectoClaro.
  ///
  /// In es, this message translates to:
  /// **'Claro'**
  String get aspectoClaro;

  /// No description provided for @aspectoOscuro.
  ///
  /// In es, this message translates to:
  /// **'Oscuro'**
  String get aspectoOscuro;

  /// No description provided for @aspectoHoras.
  ///
  /// In es, this message translates to:
  /// **'Noche (22–⁠08)'**
  String get aspectoHoras;

  /// No description provided for @aspectoAyuda.
  ///
  /// In es, this message translates to:
  /// **'Automático sigue al móvil. Noche: oscuro de 22:00 a 08:00.'**
  String get aspectoAyuda;

  /// No description provided for @misPastillas.
  ///
  /// In es, this message translates to:
  /// **'Mis pastillas'**
  String get misPastillas;

  /// No description provided for @preguntaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Pregunta'**
  String get preguntaTitulo;

  /// No description provided for @preguntaModoPrueba.
  ///
  /// In es, this message translates to:
  /// **'Modo prueba: no se guarda nada.'**
  String get preguntaModoPrueba;

  /// No description provided for @tendraTitulo.
  ///
  /// In es, this message translates to:
  /// **'Lo que tendrá'**
  String get tendraTitulo;

  /// No description provided for @llegaEnSemana.
  ///
  /// In es, this message translates to:
  /// **'Llega en la semana {n}'**
  String llegaEnSemana(int n);

  /// No description provided for @llegaEnSemanas.
  ///
  /// In es, this message translates to:
  /// **'Llega en las semanas {a} y {b}'**
  String llegaEnSemanas(int a, int b);

  /// No description provided for @calendarioTendra.
  ///
  /// In es, this message translates to:
  /// **'Un calendario con las tomas, las citas y las visitas de la familia, para verlo todo de un vistazo.'**
  String get calendarioTendra;

  /// No description provided for @consultasTendra.
  ///
  /// In es, this message translates to:
  /// **'Preparar las consultas con el médico: preguntas, grabación con permiso y un resumen para la familia.'**
  String get consultasTendra;

  /// No description provided for @alarmasTendra.
  ///
  /// In es, this message translates to:
  /// **'Avisos escalonados: si la pastilla no se confirma, se avisa a la familia por orden. Y el control por horas, de 9 a 21.'**
  String get alarmasTendra;

  /// No description provided for @controlHorasTitulo.
  ///
  /// In es, this message translates to:
  /// **'Control por horas'**
  String get controlHorasTitulo;

  /// No description provided for @controlHorasTendra.
  ///
  /// In es, this message translates to:
  /// **'Tres preguntas cada hora, de 9 a 21, con horas ajustables: cómo está, si hay dolor y qué plan tiene.'**
  String get controlHorasTendra;

  /// No description provided for @verControlHoras.
  ///
  /// In es, this message translates to:
  /// **'Ver el control por horas'**
  String get verControlHoras;

  /// No description provided for @vocesTendra.
  ///
  /// In es, this message translates to:
  /// **'Mensajes grabados por los familiares para acompañar cada aviso.'**
  String get vocesTendra;

  /// No description provided for @alimentacionTendra.
  ///
  /// In es, this message translates to:
  /// **'Registro de comidas y de vasos de agua, con foto si se quiere.'**
  String get alimentacionTendra;

  /// No description provided for @parteManana.
  ///
  /// In es, this message translates to:
  /// **'Por la mañana'**
  String get parteManana;

  /// No description provided for @parteTarde.
  ///
  /// In es, this message translates to:
  /// **'Por la tarde'**
  String get parteTarde;

  /// No description provided for @parteNoche.
  ///
  /// In es, this message translates to:
  /// **'Por la noche'**
  String get parteNoche;

  /// No description provided for @loSiguiente.
  ///
  /// In es, this message translates to:
  /// **'Lo siguiente'**
  String get loSiguiente;

  /// No description provided for @noHayMasPastillas.
  ///
  /// In es, this message translates to:
  /// **'Ahora no hay más pastillas.'**
  String get noHayMasPastillas;

  /// No description provided for @aLasHoraPastilla.
  ///
  /// In es, this message translates to:
  /// **'A las {hora}, {nombre}'**
  String aLasHoraPastilla(String hora, String nombre);

  /// No description provided for @esLaHora.
  ///
  /// In es, this message translates to:
  /// **'Es la hora: {nombre}'**
  String esLaHora(String nombre);

  /// No description provided for @miGente.
  ///
  /// In es, this message translates to:
  /// **'Mi gente'**
  String get miGente;

  /// No description provided for @llamarA.
  ///
  /// In es, this message translates to:
  /// **'Llamar a {nombre}'**
  String llamarA(String nombre);

  /// No description provided for @necesitoAyuda.
  ///
  /// In es, this message translates to:
  /// **'Necesito ayuda'**
  String get necesitoAyuda;

  /// No description provided for @ayudaLlamando.
  ///
  /// In es, this message translates to:
  /// **'Estoy llamando a {nombre}.'**
  String ayudaLlamando(String nombre);

  /// No description provided for @ayudaAvisada.
  ///
  /// In es, this message translates to:
  /// **'He anotado que necesitas ayuda.'**
  String get ayudaAvisada;

  /// No description provided for @mensajeDeLaFamilia.
  ///
  /// In es, this message translates to:
  /// **'Mensaje de la familia'**
  String get mensajeDeLaFamilia;

  /// No description provided for @yaMeLaHeTomado.
  ///
  /// In es, this message translates to:
  /// **'YA ME LA HE TOMADO'**
  String get yaMeLaHeTomado;

  /// No description provided for @compartimentoEs.
  ///
  /// In es, this message translates to:
  /// **'Compartimento: {compartimento}'**
  String compartimentoEs(String compartimento);

  /// No description provided for @ensenaLaPastilla.
  ///
  /// In es, this message translates to:
  /// **'Enséñame la pastilla y tómatela delante del móvil'**
  String get ensenaLaPastilla;

  /// No description provided for @cuentaAtras.
  ///
  /// In es, this message translates to:
  /// **'Quedan {n} segundos'**
  String cuentaAtras(int n);

  /// No description provided for @muyBien.
  ///
  /// In es, this message translates to:
  /// **'Muy bien'**
  String get muyBien;

  /// No description provided for @yaEstaTomada.
  ///
  /// In es, this message translates to:
  /// **'Ya está tomada'**
  String get yaEstaTomada;

  /// No description provided for @volverAlInicio.
  ///
  /// In es, this message translates to:
  /// **'Volver al inicio'**
  String get volverAlInicio;

  /// No description provided for @tomaNoEncontrada.
  ///
  /// In es, this message translates to:
  /// **'No encuentro esta toma.'**
  String get tomaNoEncontrada;

  /// No description provided for @semanticaFotoPastilla.
  ///
  /// In es, this message translates to:
  /// **'Foto de la pastilla: {nombre}'**
  String semanticaFotoPastilla(String nombre);

  /// No description provided for @camaraDemo.
  ///
  /// In es, this message translates to:
  /// **'Demo: aquí se vería la cámara frontal'**
  String get camaraDemo;

  /// No description provided for @estadoPrevista.
  ///
  /// In es, this message translates to:
  /// **'Prevista'**
  String get estadoPrevista;

  /// No description provided for @estadoConfirmada.
  ///
  /// In es, this message translates to:
  /// **'Confirmada'**
  String get estadoConfirmada;

  /// No description provided for @estadoConfirmadaSinVideo.
  ///
  /// In es, this message translates to:
  /// **'Confirmada sin vídeo'**
  String get estadoConfirmadaSinVideo;

  /// No description provided for @estadoNoConfirmada.
  ///
  /// In es, this message translates to:
  /// **'No confirmada'**
  String get estadoNoConfirmada;

  /// No description provided for @estadoCerradaPorFamiliar.
  ///
  /// In es, this message translates to:
  /// **'Cerrada por un familiar'**
  String get estadoCerradaPorFamiliar;

  /// No description provided for @semanticaEstadoToma.
  ///
  /// In es, this message translates to:
  /// **'Estado de la toma: {estado}'**
  String semanticaEstadoToma(String estado);

  /// No description provided for @semaforoRojo.
  ///
  /// In es, this message translates to:
  /// **'Hoy hay una toma sin confirmar'**
  String get semaforoRojo;

  /// No description provided for @semaforoNaranja.
  ///
  /// In es, this message translates to:
  /// **'Hay una toma confirmada sin vídeo'**
  String get semaforoNaranja;

  /// No description provided for @semaforoVerde.
  ///
  /// In es, this message translates to:
  /// **'Todo en orden por ahora'**
  String get semaforoVerde;

  /// No description provided for @semanticaSemaforo.
  ///
  /// In es, this message translates to:
  /// **'Semáforo del día: {texto}'**
  String semanticaSemaforo(String texto);

  /// No description provided for @ultimaToma.
  ///
  /// In es, this message translates to:
  /// **'Última toma'**
  String get ultimaToma;

  /// No description provided for @sinTomasAun.
  ///
  /// In es, this message translates to:
  /// **'Todavía no ha habido ninguna toma.'**
  String get sinTomasAun;

  /// No description provided for @tomasDeHoy.
  ///
  /// In es, this message translates to:
  /// **'Tomas de hoy'**
  String get tomasDeHoy;

  /// No description provided for @sinTomasHoy.
  ///
  /// In es, this message translates to:
  /// **'Hoy no hay tomas previstas.'**
  String get sinTomasHoy;

  /// No description provided for @confirmadaPorDesde.
  ///
  /// In es, this message translates to:
  /// **'Confirmada por {quien}, {como}'**
  String confirmadaPorDesde(String quien, String como);

  /// No description provided for @origenMovil.
  ///
  /// In es, this message translates to:
  /// **'desde el móvil'**
  String get origenMovil;

  /// No description provided for @origenReloj.
  ///
  /// In es, this message translates to:
  /// **'desde el reloj'**
  String get origenReloj;

  /// No description provided for @origenFamiliar.
  ///
  /// In es, this message translates to:
  /// **'por un familiar'**
  String get origenFamiliar;

  /// No description provided for @cerradaPor.
  ///
  /// In es, this message translates to:
  /// **'Cerrada por {nombre}'**
  String cerradaPor(String nombre);

  /// No description provided for @sinConfirmarAun.
  ///
  /// In es, this message translates to:
  /// **'Sin confirmar'**
  String get sinConfirmarAun;

  /// No description provided for @reservadaVideo.
  ///
  /// In es, this message translates to:
  /// **'Vídeo de la toma'**
  String get reservadaVideo;

  /// No description provided for @reservadaUbicacion.
  ///
  /// In es, this message translates to:
  /// **'Ubicación'**
  String get reservadaUbicacion;

  /// No description provided for @reservadaControl.
  ///
  /// In es, this message translates to:
  /// **'Respuesta de control'**
  String get reservadaControl;

  /// No description provided for @anadirMedicamento.
  ///
  /// In es, this message translates to:
  /// **'Añadir medicamento'**
  String get anadirMedicamento;

  /// No description provided for @probarPantallaToma.
  ///
  /// In es, this message translates to:
  /// **'Probar pantalla de toma'**
  String get probarPantallaToma;

  /// No description provided for @medicamentos.
  ///
  /// In es, this message translates to:
  /// **'Medicamentos'**
  String get medicamentos;

  /// No description provided for @sinMedicamentos.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay medicamentos.'**
  String get sinMedicamentos;

  /// No description provided for @verMedicamento.
  ///
  /// In es, this message translates to:
  /// **'Ver {nombre}'**
  String verMedicamento(String nombre);

  /// No description provided for @resumenPauta.
  ///
  /// In es, this message translates to:
  /// **'{horas} · {dosis}'**
  String resumenPauta(String horas, String dosis);

  /// No description provided for @pautaSuspendida.
  ///
  /// In es, this message translates to:
  /// **'Pauta suspendida'**
  String get pautaSuspendida;

  /// No description provided for @altaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Nuevo medicamento'**
  String get altaTitulo;

  /// No description provided for @nombreMedicamento.
  ///
  /// In es, this message translates to:
  /// **'Nombre del medicamento'**
  String get nombreMedicamento;

  /// No description provided for @nombreParaPersona.
  ///
  /// In es, this message translates to:
  /// **'Nombre para la persona'**
  String get nombreParaPersona;

  /// No description provided for @nombreParaPersonaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Como lo va a leer ella o él, por ejemplo: pastilla blanca pequeña'**
  String get nombreParaPersonaAyuda;

  /// No description provided for @formaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Forma'**
  String get formaTitulo;

  /// No description provided for @formaRedonda.
  ///
  /// In es, this message translates to:
  /// **'Redonda'**
  String get formaRedonda;

  /// No description provided for @formaOvalada.
  ///
  /// In es, this message translates to:
  /// **'Ovalada'**
  String get formaOvalada;

  /// No description provided for @formaCapsula.
  ///
  /// In es, this message translates to:
  /// **'Cápsula'**
  String get formaCapsula;

  /// No description provided for @formaOtra.
  ///
  /// In es, this message translates to:
  /// **'Otra'**
  String get formaOtra;

  /// No description provided for @colorTitulo.
  ///
  /// In es, this message translates to:
  /// **'Color'**
  String get colorTitulo;

  /// No description provided for @colorBlanco.
  ///
  /// In es, this message translates to:
  /// **'Blanco'**
  String get colorBlanco;

  /// No description provided for @colorAmarillo.
  ///
  /// In es, this message translates to:
  /// **'Amarillo'**
  String get colorAmarillo;

  /// No description provided for @colorRojo.
  ///
  /// In es, this message translates to:
  /// **'Rojo'**
  String get colorRojo;

  /// No description provided for @colorRosa.
  ///
  /// In es, this message translates to:
  /// **'Rosa'**
  String get colorRosa;

  /// No description provided for @colorNaranja.
  ///
  /// In es, this message translates to:
  /// **'Naranja'**
  String get colorNaranja;

  /// No description provided for @colorVerde.
  ///
  /// In es, this message translates to:
  /// **'Verde'**
  String get colorVerde;

  /// No description provided for @colorAzul.
  ///
  /// In es, this message translates to:
  /// **'Azul'**
  String get colorAzul;

  /// No description provided for @colorMarron.
  ///
  /// In es, this message translates to:
  /// **'Marrón'**
  String get colorMarron;

  /// No description provided for @fotoCaja.
  ///
  /// In es, this message translates to:
  /// **'Foto de la caja'**
  String get fotoCaja;

  /// No description provided for @fotoPastilla.
  ///
  /// In es, this message translates to:
  /// **'Foto de la pastilla'**
  String get fotoPastilla;

  /// No description provided for @hacerFoto.
  ///
  /// In es, this message translates to:
  /// **'Hacer foto'**
  String get hacerFoto;

  /// No description provided for @elegirDeLaGaleria.
  ///
  /// In es, this message translates to:
  /// **'Elegir de la galería'**
  String get elegirDeLaGaleria;

  /// No description provided for @pautaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Pauta'**
  String get pautaTitulo;

  /// No description provided for @horasDeToma.
  ///
  /// In es, this message translates to:
  /// **'Horas de la toma (24 h)'**
  String get horasDeToma;

  /// No description provided for @anadirHora.
  ///
  /// In es, this message translates to:
  /// **'Añadir hora'**
  String get anadirHora;

  /// No description provided for @quitarHora.
  ///
  /// In es, this message translates to:
  /// **'Quitar la hora {hora}'**
  String quitarHora(String hora);

  /// No description provided for @diasDeToma.
  ///
  /// In es, this message translates to:
  /// **'Días'**
  String get diasDeToma;

  /// No description provided for @diaLunes.
  ///
  /// In es, this message translates to:
  /// **'Lunes'**
  String get diaLunes;

  /// No description provided for @diaMartes.
  ///
  /// In es, this message translates to:
  /// **'Martes'**
  String get diaMartes;

  /// No description provided for @diaMiercoles.
  ///
  /// In es, this message translates to:
  /// **'Miércoles'**
  String get diaMiercoles;

  /// No description provided for @diaJueves.
  ///
  /// In es, this message translates to:
  /// **'Jueves'**
  String get diaJueves;

  /// No description provided for @diaViernes.
  ///
  /// In es, this message translates to:
  /// **'Viernes'**
  String get diaViernes;

  /// No description provided for @diaSabado.
  ///
  /// In es, this message translates to:
  /// **'Sábado'**
  String get diaSabado;

  /// No description provided for @diaDomingo.
  ///
  /// In es, this message translates to:
  /// **'Domingo'**
  String get diaDomingo;

  /// No description provided for @dosis.
  ///
  /// In es, this message translates to:
  /// **'Dosis'**
  String get dosis;

  /// No description provided for @compartimentoEtiqueta.
  ///
  /// In es, this message translates to:
  /// **'Compartimento del pastillero (opcional)'**
  String get compartimentoEtiqueta;

  /// No description provided for @comprobacionTitulo.
  ///
  /// In es, this message translates to:
  /// **'Cómo se comprueba'**
  String get comprobacionTitulo;

  /// No description provided for @comprobacionVideo.
  ///
  /// In es, this message translates to:
  /// **'Vídeo de 10 s'**
  String get comprobacionVideo;

  /// No description provided for @comprobacionFoto.
  ///
  /// In es, this message translates to:
  /// **'Foto'**
  String get comprobacionFoto;

  /// No description provided for @comprobacionNinguna.
  ///
  /// In es, this message translates to:
  /// **'Ninguna'**
  String get comprobacionNinguna;

  /// No description provided for @guardarMedicamento.
  ///
  /// In es, this message translates to:
  /// **'Guardar medicamento'**
  String get guardarMedicamento;

  /// No description provided for @todosLosDias.
  ///
  /// In es, this message translates to:
  /// **'Todos los días'**
  String get todosLosDias;

  /// No description provided for @medicamentoNoEncontrado.
  ///
  /// In es, this message translates to:
  /// **'No encuentro este medicamento.'**
  String get medicamentoNoEncontrado;

  /// No description provided for @formaYColor.
  ///
  /// In es, this message translates to:
  /// **'Forma {forma} · color {color}'**
  String formaYColor(String forma, String color);

  /// No description provided for @sinColor.
  ///
  /// In es, this message translates to:
  /// **'sin indicar'**
  String get sinColor;

  /// No description provided for @pautaActual.
  ///
  /// In es, this message translates to:
  /// **'Pauta actual'**
  String get pautaActual;

  /// No description provided for @lineaHoras.
  ///
  /// In es, this message translates to:
  /// **'Horas: {valor}'**
  String lineaHoras(String valor);

  /// No description provided for @lineaDias.
  ///
  /// In es, this message translates to:
  /// **'Días: {valor}'**
  String lineaDias(String valor);

  /// No description provided for @lineaDosis.
  ///
  /// In es, this message translates to:
  /// **'Dosis: {valor}'**
  String lineaDosis(String valor);

  /// No description provided for @lineaCompartimento.
  ///
  /// In es, this message translates to:
  /// **'Compartimento: {valor}'**
  String lineaCompartimento(String valor);

  /// No description provided for @lineaComprobacion.
  ///
  /// In es, this message translates to:
  /// **'Comprobación: {valor}'**
  String lineaComprobacion(String valor);

  /// No description provided for @cambiarPauta.
  ///
  /// In es, this message translates to:
  /// **'Cambiar la pauta'**
  String get cambiarPauta;

  /// No description provided for @reanudarPauta.
  ///
  /// In es, this message translates to:
  /// **'Reanudar la pauta'**
  String get reanudarPauta;

  /// No description provided for @suspenderPauta.
  ///
  /// In es, this message translates to:
  /// **'Suspender la pauta'**
  String get suspenderPauta;

  /// No description provided for @suspender.
  ///
  /// In es, this message translates to:
  /// **'Suspender'**
  String get suspender;

  /// No description provided for @motivo.
  ///
  /// In es, this message translates to:
  /// **'Motivo'**
  String get motivo;

  /// No description provided for @historialPauta.
  ///
  /// In es, this message translates to:
  /// **'Historial de la pauta'**
  String get historialPauta;

  /// No description provided for @versionDesde.
  ///
  /// In es, this message translates to:
  /// **'Versión {version} desde {desde}'**
  String versionDesde(int version, String desde);

  /// No description provided for @motivoDe.
  ///
  /// In es, this message translates to:
  /// **'Motivo: {motivo}'**
  String motivoDe(String motivo);

  /// No description provided for @motivoDelCambio.
  ///
  /// In es, this message translates to:
  /// **'Motivo del cambio'**
  String get motivoDelCambio;

  /// No description provided for @guardarCambio.
  ///
  /// In es, this message translates to:
  /// **'Guardar el cambio'**
  String get guardarCambio;

  /// No description provided for @sinFamiliares.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay familiares.'**
  String get sinFamiliares;

  /// No description provided for @rolResponsable.
  ///
  /// In es, this message translates to:
  /// **'Responsable'**
  String get rolResponsable;

  /// No description provided for @rolCuidador.
  ///
  /// In es, this message translates to:
  /// **'Cuidador o cuidadora'**
  String get rolCuidador;

  /// No description provided for @rolApoyo.
  ///
  /// In es, this message translates to:
  /// **'Apoyo'**
  String get rolApoyo;

  /// No description provided for @rolLectura.
  ///
  /// In es, this message translates to:
  /// **'Solo lectura'**
  String get rolLectura;

  /// No description provided for @ordenDeAviso.
  ///
  /// In es, this message translates to:
  /// **'Se le avisa en el puesto {orden}'**
  String ordenDeAviso(int orden);

  /// No description provided for @circuloGestion.
  ///
  /// In es, this message translates to:
  /// **'Añadir, quitar y cambiar los permisos de los familiares llega en la semana 16.'**
  String get circuloGestion;

  /// No description provided for @cargarEjemplo.
  ///
  /// In es, this message translates to:
  /// **'Cargar datos de ejemplo'**
  String get cargarEjemplo;

  /// No description provided for @cargarEjemploAyuda.
  ///
  /// In es, this message translates to:
  /// **'Añade una persona de ejemplo, familiares y medicamentos ficticios.'**
  String get cargarEjemploAyuda;

  /// No description provided for @ejemploCargado.
  ///
  /// In es, this message translates to:
  /// **'Datos de ejemplo cargados.'**
  String get ejemploCargado;

  /// No description provided for @ejemploYaCargado.
  ///
  /// In es, this message translates to:
  /// **'Ya hay medicamentos: no se han cargado datos de ejemplo.'**
  String get ejemploYaCargado;

  /// No description provided for @ajustesPlataforma.
  ///
  /// In es, this message translates to:
  /// **'Plataforma de este dispositivo: {plataforma}'**
  String ajustesPlataforma(String plataforma);

  /// No description provided for @ajustesMas.
  ///
  /// In es, this message translates to:
  /// **'El resto de los ajustes llega en la semana 16.'**
  String get ajustesMas;

  /// No description provided for @catalogoCabecera.
  ///
  /// In es, this message translates to:
  /// **'Cada fila dice lo que reporta su fuente, con su cifra tal cual y quién lo pagó. Nadie hace de juez.'**
  String get catalogoCabecera;

  /// No description provided for @catalogoNoCargado.
  ///
  /// In es, this message translates to:
  /// **'No se ha podido cargar el catálogo.'**
  String get catalogoNoCargado;

  /// No description provided for @resumenPorGrupo.
  ///
  /// In es, this message translates to:
  /// **'Resumen por grupo'**
  String get resumenPorGrupo;

  /// No description provided for @dosieresPorTema.
  ///
  /// In es, this message translates to:
  /// **'Dosieres por tema'**
  String get dosieresPorTema;

  /// No description provided for @nFilas.
  ///
  /// In es, this message translates to:
  /// **'{n} filas'**
  String nFilas(int n);

  /// No description provided for @buscar.
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get buscar;

  /// No description provided for @filtrarPorTema.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por tema'**
  String get filtrarPorTema;

  /// No description provided for @filtrarPorDireccion.
  ///
  /// In es, this message translates to:
  /// **'Dirección según la fuente'**
  String get filtrarPorDireccion;

  /// No description provided for @filtrarPorTipoFuente.
  ///
  /// In es, this message translates to:
  /// **'Filtrar por tipo de fuente'**
  String get filtrarPorTipoFuente;

  /// No description provided for @grupoFiltrado.
  ///
  /// In es, this message translates to:
  /// **'Grupo: {grupo}'**
  String grupoFiltrado(String grupo);

  /// No description provided for @nDeTotal.
  ///
  /// In es, this message translates to:
  /// **'{n} de {total}'**
  String nDeTotal(int n, int total);

  /// No description provided for @quitarFiltros.
  ///
  /// In es, this message translates to:
  /// **'Quitar filtros'**
  String get quitarFiltros;

  /// No description provided for @abrirFicha.
  ///
  /// In es, this message translates to:
  /// **'Abrir la ficha de {nombre}'**
  String abrirFicha(String nombre);

  /// No description provided for @direccionMejora.
  ///
  /// In es, this message translates to:
  /// **'Mejora'**
  String get direccionMejora;

  /// No description provided for @direccionSinCambio.
  ///
  /// In es, this message translates to:
  /// **'Sin cambio'**
  String get direccionSinCambio;

  /// No description provided for @direccionEmpeora.
  ///
  /// In es, this message translates to:
  /// **'Empeora'**
  String get direccionEmpeora;

  /// No description provided for @direccionMixto.
  ///
  /// In es, this message translates to:
  /// **'Mixto'**
  String get direccionMixto;

  /// No description provided for @direccionNoAplica.
  ///
  /// In es, this message translates to:
  /// **'No aplica'**
  String get direccionNoAplica;

  /// No description provided for @semanticaDireccion.
  ///
  /// In es, this message translates to:
  /// **'Dirección según la fuente: {texto}'**
  String semanticaDireccion(String texto);

  /// No description provided for @fichaTitulo.
  ///
  /// In es, this message translates to:
  /// **'Ficha'**
  String get fichaTitulo;

  /// No description provided for @filaNoEncontrada.
  ///
  /// In es, this message translates to:
  /// **'No encuentro esta fila.'**
  String get filaNoEncontrada;

  /// No description provided for @abrirLaFuente.
  ///
  /// In es, this message translates to:
  /// **'Abrir la fuente'**
  String get abrirLaFuente;

  /// No description provided for @campoTema.
  ///
  /// In es, this message translates to:
  /// **'Tema'**
  String get campoTema;

  /// No description provided for @campoGrupo.
  ///
  /// In es, this message translates to:
  /// **'Intervención (grupo)'**
  String get campoGrupo;

  /// No description provided for @campoIntervencion.
  ///
  /// In es, this message translates to:
  /// **'Intervención (tal como la nombra la fuente)'**
  String get campoIntervencion;

  /// No description provided for @campoTradicion.
  ///
  /// In es, this message translates to:
  /// **'Tradición o ángulo'**
  String get campoTradicion;

  /// No description provided for @campoEstudio.
  ///
  /// In es, this message translates to:
  /// **'Estudio / fuente'**
  String get campoEstudio;

  /// No description provided for @campoTipoFuente.
  ///
  /// In es, this message translates to:
  /// **'Tipo de fuente'**
  String get campoTipoFuente;

  /// No description provided for @campoDiseno.
  ///
  /// In es, this message translates to:
  /// **'Diseño'**
  String get campoDiseno;

  /// No description provided for @campoN.
  ///
  /// In es, this message translates to:
  /// **'n'**
  String get campoN;

  /// No description provided for @campoPoblacion.
  ///
  /// In es, this message translates to:
  /// **'Población'**
  String get campoPoblacion;

  /// No description provided for @campoDuracion.
  ///
  /// In es, this message translates to:
  /// **'Duración'**
  String get campoDuracion;

  /// No description provided for @campoDosis.
  ///
  /// In es, this message translates to:
  /// **'Dosis o protocolo'**
  String get campoDosis;

  /// No description provided for @campoQueMidio.
  ///
  /// In es, this message translates to:
  /// **'Qué midió'**
  String get campoQueMidio;

  /// No description provided for @campoResultado.
  ///
  /// In es, this message translates to:
  /// **'Resultado reportado (cifra tal cual)'**
  String get campoResultado;

  /// No description provided for @campoDireccion.
  ///
  /// In es, this message translates to:
  /// **'Dirección según la fuente'**
  String get campoDireccion;

  /// No description provided for @campoEfectosAdversos.
  ///
  /// In es, this message translates to:
  /// **'Efectos adversos reportados'**
  String get campoEfectosAdversos;

  /// No description provided for @campoFinanciacion.
  ///
  /// In es, this message translates to:
  /// **'Financiación y conflictos'**
  String get campoFinanciacion;

  /// No description provided for @campoComoProbarlo.
  ///
  /// In es, this message translates to:
  /// **'Cómo probarlo en casa (según la fuente)'**
  String get campoComoProbarlo;

  /// No description provided for @campoCoste.
  ///
  /// In es, this message translates to:
  /// **'Coste aprox.'**
  String get campoCoste;

  /// No description provided for @campoVerificacion.
  ///
  /// In es, this message translates to:
  /// **'Verificación documental'**
  String get campoVerificacion;

  /// No description provided for @campoIdentificador.
  ///
  /// In es, this message translates to:
  /// **'Identificador'**
  String get campoIdentificador;

  /// No description provided for @campoEnlace.
  ///
  /// In es, this message translates to:
  /// **'Enlace'**
  String get campoEnlace;

  /// No description provided for @dosierTitulo.
  ///
  /// In es, this message translates to:
  /// **'Dosier'**
  String get dosierTitulo;

  /// No description provided for @temaNoEncontrado.
  ///
  /// In es, this message translates to:
  /// **'No encuentro este tema.'**
  String get temaNoEncontrado;

  /// No description provided for @verFilasDelTema.
  ///
  /// In es, this message translates to:
  /// **'Ver las filas de este tema'**
  String get verFilasDelTema;

  /// No description provided for @dosierTesis.
  ///
  /// In es, this message translates to:
  /// **'Tesis'**
  String get dosierTesis;

  /// No description provided for @dosierDefensores.
  ///
  /// In es, this message translates to:
  /// **'Defensores'**
  String get dosierDefensores;

  /// No description provided for @dosierMecanismos.
  ///
  /// In es, this message translates to:
  /// **'Mecanismos'**
  String get dosierMecanismos;

  /// No description provided for @dosierConsenso.
  ///
  /// In es, this message translates to:
  /// **'Consenso y quién lo paga'**
  String get dosierConsenso;

  /// No description provided for @dosierEnterrado.
  ///
  /// In es, this message translates to:
  /// **'Lo enterrado'**
  String get dosierEnterrado;

  /// No description provided for @dosierProtocolos.
  ///
  /// In es, this message translates to:
  /// **'Protocolos reportados'**
  String get dosierProtocolos;

  /// No description provided for @dosierRiesgos.
  ///
  /// In es, this message translates to:
  /// **'Riesgos reconocidos por los defensores'**
  String get dosierRiesgos;

  /// No description provided for @dosierFuentes.
  ///
  /// In es, this message translates to:
  /// **'Fuentes heterodoxas'**
  String get dosierFuentes;

  /// No description provided for @dosierIdeas.
  ///
  /// In es, this message translates to:
  /// **'Ideas para la app'**
  String get dosierIdeas;

  /// No description provided for @relacionYRol.
  ///
  /// In es, this message translates to:
  /// **'{relacion} · {rol}'**
  String relacionYRol(String relacion, String rol);

  /// No description provided for @etiquetaConConteo.
  ///
  /// In es, this message translates to:
  /// **'{texto} · {n}'**
  String etiquetaConConteo(String texto, int n);

  /// No description provided for @todosLosTemas.
  ///
  /// In es, this message translates to:
  /// **'Todos los temas'**
  String get todosLosTemas;

  /// No description provided for @personaAhoraNoTocaNada.
  ///
  /// In es, this message translates to:
  /// **'Ahora no toca nada'**
  String get personaAhoraNoTocaNada;

  /// No description provided for @personaTomarlaAhora.
  ///
  /// In es, this message translates to:
  /// **'Tomarla ahora'**
  String get personaTomarlaAhora;

  /// No description provided for @personaHoyDia.
  ///
  /// In es, this message translates to:
  /// **'Hoy, {dia}'**
  String personaHoyDia(String dia);

  /// No description provided for @personaHoraCompartimento.
  ///
  /// In es, this message translates to:
  /// **'{hora} · {compartimento}'**
  String personaHoraCompartimento(String hora, String compartimento);

  /// No description provided for @personaAhoraCon.
  ///
  /// In es, this message translates to:
  /// **'Ahora · {texto}'**
  String personaAhoraCon(String texto);

  /// No description provided for @personaYaTomada.
  ///
  /// In es, this message translates to:
  /// **'Ya tomada'**
  String get personaYaTomada;

  /// No description provided for @personaLuego.
  ///
  /// In es, this message translates to:
  /// **'Luego'**
  String get personaLuego;

  /// No description provided for @personaSinTomar.
  ///
  /// In es, this message translates to:
  /// **'Sin tomar'**
  String get personaSinTomar;

  /// No description provided for @personaYaMeLaHeTomado.
  ///
  /// In es, this message translates to:
  /// **'Ya me la he tomado'**
  String get personaYaMeLaHeTomado;

  /// No description provided for @personaHoyNoHayPastillas.
  ///
  /// In es, this message translates to:
  /// **'Hoy no hay pastillas'**
  String get personaHoyNoHayPastillas;

  /// No description provided for @personaHola.
  ///
  /// In es, this message translates to:
  /// **'Hola, {nombre}'**
  String personaHola(String nombre);

  /// No description provided for @personaDiaYHora.
  ///
  /// In es, this message translates to:
  /// **'{dia} · {hora}'**
  String personaDiaYHora(String dia, String hora);

  /// No description provided for @personaAhoraToca.
  ///
  /// In es, this message translates to:
  /// **'Ahora toca'**
  String get personaAhoraToca;

  /// No description provided for @personaLlamar.
  ///
  /// In es, this message translates to:
  /// **'Llamar'**
  String get personaLlamar;

  /// No description provided for @personaAyuda.
  ///
  /// In es, this message translates to:
  /// **'Ayuda'**
  String get personaAyuda;

  /// No description provided for @hoySegmentoAyer.
  ///
  /// In es, this message translates to:
  /// **'Ayer'**
  String get hoySegmentoAyer;

  /// No description provided for @hoySegmentoHoy.
  ///
  /// In es, this message translates to:
  /// **'Hoy'**
  String get hoySegmentoHoy;

  /// No description provided for @hoySegmentoManana.
  ///
  /// In es, this message translates to:
  /// **'Mañana'**
  String get hoySegmentoManana;

  /// No description provided for @hoySegmentoSemana.
  ///
  /// In es, this message translates to:
  /// **'Semana'**
  String get hoySegmentoSemana;

  /// No description provided for @hoyCasillaTomas.
  ///
  /// In es, this message translates to:
  /// **'Tomas'**
  String get hoyCasillaTomas;

  /// No description provided for @hoyCasillaVideos.
  ///
  /// In es, this message translates to:
  /// **'Vídeos'**
  String get hoyCasillaVideos;

  /// No description provided for @hoyCasillaAvisos.
  ///
  /// In es, this message translates to:
  /// **'Avisos'**
  String get hoyCasillaAvisos;

  /// No description provided for @hoyDeTotal.
  ///
  /// In es, this message translates to:
  /// **'de {total}'**
  String hoyDeTotal(int total);

  /// No description provided for @hoySemanticaCasilla.
  ///
  /// In es, this message translates to:
  /// **'{titulo}: {valor}'**
  String hoySemanticaCasilla(String titulo, String valor);

  /// No description provided for @hoyProximaToma.
  ///
  /// In es, this message translates to:
  /// **'Próxima toma'**
  String get hoyProximaToma;

  /// No description provided for @hoyHoraYCompartimento.
  ///
  /// In es, this message translates to:
  /// **'{hora} · {compartimento}'**
  String hoyHoraYCompartimento(String hora, String compartimento);

  /// No description provided for @hoySiNoLaToma.
  ///
  /// In es, this message translates to:
  /// **'Si no la toma: aviso a las {hora}'**
  String hoySiNoLaToma(String hora);

  /// No description provided for @hoyComprobaciones.
  ///
  /// In es, this message translates to:
  /// **'Comprobaciones'**
  String get hoyComprobaciones;

  /// No description provided for @hoyVideoDeLaToma.
  ///
  /// In es, this message translates to:
  /// **'Vídeo de la toma de las {hora} · {segundos} s'**
  String hoyVideoDeLaToma(String hora, int segundos);

  /// No description provided for @hoyVideoDeLaTomaSinDuracion.
  ///
  /// In es, this message translates to:
  /// **'Vídeo de la toma de las {hora}'**
  String hoyVideoDeLaTomaSinDuracion(String hora);

  /// No description provided for @hoyFotoDeLaToma.
  ///
  /// In es, this message translates to:
  /// **'Foto de la toma de las {hora}'**
  String hoyFotoDeLaToma(String hora);

  /// No description provided for @hoySinComprobacionesHoy.
  ///
  /// In es, this message translates to:
  /// **'Sin comprobaciones hoy'**
  String get hoySinComprobacionesHoy;

  /// No description provided for @hoySinComprobacionesAyer.
  ///
  /// In es, this message translates to:
  /// **'Sin comprobaciones ayer'**
  String get hoySinComprobacionesAyer;

  /// No description provided for @hoyLlegaPronto.
  ///
  /// In es, this message translates to:
  /// **'Llega pronto'**
  String get hoyLlegaPronto;

  /// No description provided for @hoyTomasDeAyer.
  ///
  /// In es, this message translates to:
  /// **'Tomas de ayer'**
  String get hoyTomasDeAyer;

  /// No description provided for @hoySinTomasAyer.
  ///
  /// In es, this message translates to:
  /// **'Ayer no había tomas previstas.'**
  String get hoySinTomasAyer;

  /// No description provided for @hoyRespuestasControlLlega.
  ///
  /// In es, this message translates to:
  /// **'Respuestas de control: llega en la semana {n}'**
  String hoyRespuestasControlLlega(int n);

  /// No description provided for @hoyTomasDeManana.
  ///
  /// In es, this message translates to:
  /// **'Tomas de mañana'**
  String get hoyTomasDeManana;

  /// No description provided for @hoySinTomasManana.
  ///
  /// In es, this message translates to:
  /// **'Mañana no hay tomas previstas.'**
  String get hoySinTomasManana;

  /// No description provided for @hoyQuienRecibeAvisos.
  ///
  /// In es, this message translates to:
  /// **'Quién recibe los avisos'**
  String get hoyQuienRecibeAvisos;

  /// No description provided for @hoyAvisoAMinutos.
  ///
  /// In es, this message translates to:
  /// **'{nombre} a los {minutos} min'**
  String hoyAvisoAMinutos(String nombre, int minutos);

  /// No description provided for @hoyQuienRecibeAyuda.
  ///
  /// In es, this message translates to:
  /// **'Si no confirma una toma, el aviso llega en este orden.'**
  String get hoyQuienRecibeAyuda;

  /// No description provided for @hoySinFamiliares.
  ///
  /// In es, this message translates to:
  /// **'Todavía no hay familiares en el círculo.'**
  String get hoySinFamiliares;

  /// No description provided for @hoyUltimos7Dias.
  ///
  /// In es, this message translates to:
  /// **'Últimos 7 días · {desde} a {hasta}'**
  String hoyUltimos7Dias(String desde, String hasta);

  /// No description provided for @hoyTomasHechasQuedan.
  ///
  /// In es, this message translates to:
  /// **'tomas hechas · hoy quedan {k}'**
  String hoyTomasHechasQuedan(int k);

  /// No description provided for @hoySemanticaTotales.
  ///
  /// In es, this message translates to:
  /// **'{hechas} de {previstas} tomas hechas · hoy quedan {k}'**
  String hoySemanticaTotales(int hechas, int previstas, int k);

  /// No description provided for @hoyRespuestasLlega.
  ///
  /// In es, this message translates to:
  /// **'Respuestas: llega en la semana {n}'**
  String hoyRespuestasLlega(int n);

  /// No description provided for @hoyFilaTomas.
  ///
  /// In es, this message translates to:
  /// **'Tomas'**
  String get hoyFilaTomas;

  /// No description provided for @hoyFilaRespondio.
  ///
  /// In es, this message translates to:
  /// **'Respondió'**
  String get hoyFilaRespondio;

  /// No description provided for @hoySemanticaCeldaDia.
  ///
  /// In es, this message translates to:
  /// **'{dia}: {hechas} de {previstas} tomas hechas'**
  String hoySemanticaCeldaDia(String dia, int hechas, int previstas);

  /// No description provided for @hoySemanticaCeldaSinTomas.
  ///
  /// In es, this message translates to:
  /// **'{dia}: sin tomas'**
  String hoySemanticaCeldaSinTomas(String dia);

  /// No description provided for @hoyLoQueDijo.
  ///
  /// In es, this message translates to:
  /// **'Lo que dijo esta semana'**
  String get hoyLoQueDijo;

  /// No description provided for @hoyLoQueDijoAviso.
  ///
  /// In es, this message translates to:
  /// **'Sus respuestas a las preguntas de cada hora'**
  String get hoyLoQueDijoAviso;

  /// No description provided for @hoyInicialLunes.
  ///
  /// In es, this message translates to:
  /// **'L'**
  String get hoyInicialLunes;

  /// No description provided for @hoyInicialMartes.
  ///
  /// In es, this message translates to:
  /// **'M'**
  String get hoyInicialMartes;

  /// No description provided for @hoyInicialMiercoles.
  ///
  /// In es, this message translates to:
  /// **'X'**
  String get hoyInicialMiercoles;

  /// No description provided for @hoyInicialJueves.
  ///
  /// In es, this message translates to:
  /// **'J'**
  String get hoyInicialJueves;

  /// No description provided for @hoyInicialViernes.
  ///
  /// In es, this message translates to:
  /// **'V'**
  String get hoyInicialViernes;

  /// No description provided for @hoyInicialSabado.
  ///
  /// In es, this message translates to:
  /// **'S'**
  String get hoyInicialSabado;

  /// No description provided for @hoyInicialDomingo.
  ///
  /// In es, this message translates to:
  /// **'D'**
  String get hoyInicialDomingo;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
