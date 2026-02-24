/// AppLocalizations
/// Single source of truth for all UI strings.
/// Add new keys here first, then fill in both [_en] and [_it].
class AppLocalizations {
  final String languageCode;
  const AppLocalizations(this.languageCode);

  static const AppLocalizations en = AppLocalizations('en');
  static const AppLocalizations it = AppLocalizations('it');

  static AppLocalizations of(String code) =>
      code == 'it' ? it : en;

  String get(String key) {
    final map = languageCode == 'it' ? _it : _en;
    return map[key] ?? _en[key] ?? key;
  }

  // ─── convenience getters ────────────────────────────────────

  // General
  String get appName         => get('appName');
  String get cancel          => get('cancel');
  String get save            => get('save');
  String get create          => get('create');
  String get delete          => get('delete');
  String get edit            => get('edit');
  String get required        => get('required');
  String get yes             => get('yes');
  String get no              => get('no');

  // Drawer
  String get allConnections  => get('allConnections');
  String get appSettings     => get('appSettings');
  String get backupRestore   => get('backupRestore');
  String get helpFaq         => get('helpFaq');
  String get userGuide       => get('userGuide');
  String get about           => get('about');
  String get exit            => get('exit');

  // Connections screen
  String get connections     => get('connections');
  String get noConnections   => get('noConnections');
  String get addConnection   => get('addConnection');

  // Connection form
  String get clientId        => get('clientId');
  String get brokerAddress   => get('brokerAddress');
  String get port            => get('port');
  String get networkProtocol => get('networkProtocol');
  String get username        => get('username');
  String get password        => get('password');
  String get additionalOptions => get('additionalOptions');
  String get addDashboard    => get('addDashboard');
  String get dashboardName   => get('dashboardName');
  String get setAsHome       => get('setAsHome');
  String get home            => get('home');

  // Dashboard screen
  String get addPanel        => get('addPanel');
  String get connectionSettings => get('connectionSettings');
  String get noPanels        => get('noPanels');
  String get addFirstPanel   => get('addFirstPanel');

  // Panel picker
  String get selectPanel     => get('selectPanel');

  // Panel common
  String get panelName       => get('panelName');
  String get topic           => get('topic');
  String get subscribeTopic  => get('subscribeTopic');
  String get disableDashboardPrefix => get('disableDashboardPrefix');
  String get payloadIsJson   => get('payloadIsJson');
  String get showReceivedTimestamp => get('showReceivedTimestamp');
  String get showSentTimestamp => get('showSentTimestamp');
  String get confirmBeforePublish => get('confirmBeforePublish');
  String get retain          => get('retain');
  String get qos             => get('qos');
  String get factor          => get('factor');
  String get decimalPrecision => get('decimalPrecision');
  String get unit            => get('unit');
  String get enableNotification => get('enableNotification');

  // Text Input panel
  String get addTextInputPanel => get('addTextInputPanel');
  String get clearTextOnPublish => get('clearTextOnPublish');

  // Text Output panel
  String get addTextOutputPanel => get('addTextOutputPanel');
  String get showHistory     => get('showHistory');
  String get textSize        => get('textSize');

  // Switch panel
  String get addSwitchPanel  => get('addSwitchPanel');
  String get payloadOn       => get('payloadOn');
  String get payloadOff      => get('payloadOff');
  String get switchType      => get('switchType');

  // Slider panel
  String get addSliderPanel  => get('addSliderPanel');
  String get payloadMin      => get('payloadMin');
  String get payloadMax      => get('payloadMax');
  String get sliderStep      => get('sliderStep');
  String get sliderOrientation => get('sliderOrientation');
  String get sliderColor     => get('sliderColor');
  String get dynamicColor    => get('dynamicColor');

  // Progress panel
  String get addProgressPanel => get('addProgressPanel');
  String get progressType    => get('progressType');

  // Gauge panel
  String get addGaugePanel   => get('addGaugePanel');
  String get arcColor1       => get('arcColor1');
  String get arcColor2       => get('arcColor2');
  String get arcColor3       => get('arcColor3');

  // Chart panel
  String get addChartPanel   => get('addChartPanel');
  String get chartType       => get('chartType');
  String get addSeries       => get('addSeries');
  String get seriesLabel     => get('seriesLabel');
  String get seriesColor     => get('seriesColor');

  // Bar Graph panel
  String get addBarGraphPanel => get('addBarGraphPanel');
  String get orientation     => get('orientation');
  String get defineRange     => get('defineRange');
  String get addBar          => get('addBar');
  String get barLabel        => get('barLabel');
  String get barColor        => get('barColor');

  // Multi-state Indicator
  String get addMultiStatePanel => get('addMultiStatePanel');
  String get iconSize        => get('iconSize');
  String get addState        => get('addState');
  String get stateLabel      => get('stateLabel');
  String get statePayload    => get('statePayload');
  String get stateColor      => get('stateColor');

  // Node Status panel
  String get addNodeStatusPanel => get('addNodeStatusPanel');
  String get payloadSyncRequest => get('payloadSyncRequest');
  String get payloadOnline   => get('payloadOnline');
  String get payloadOffline  => get('payloadOffline');
  String get onlineIcon      => get('onlineIcon');
  String get offlineIcon     => get('offlineIcon');
  String get autoSyncOnLoad  => get('autoSyncOnLoad');

  // URI Launcher panel
  String get addUriLauncherPanel => get('addUriLauncherPanel');
  String get staticUrl       => get('staticUrl');

  // Settings screen
  String get darkTheme       => get('darkTheme');
  String get runInBackground => get('runInBackground');
  String get startOnBoot     => get('startOnBoot');
  String get disableBatteryOptimization => get('disableBatteryOptimization');
  String get keepScreenOn    => get('keepScreenOn');
  String get defaultConnection => get('defaultConnection');
  String get none            => get('none');
  String get selectLanguage  => get('selectLanguage');
  String get dashboardListPlacement => get('dashboardListPlacement');
  String get portrait        => get('portrait');
  String get landscape       => get('landscape');
  String get bottomBar       => get('bottomBar');
  String get sideBar         => get('sideBar');
  String get english         => get('english');
  String get italian         => get('italian');
}

// ─────────────────────────────────────────────────────────────
// ENGLISH
// ─────────────────────────────────────────────────────────────
const Map<String, String> _en = {
  'appName': 'MQTT Panel',
  'cancel': 'CANCEL',
  'save': 'SAVE',
  'create': 'CREATE',
  'delete': 'Delete',
  'edit': 'Edit',
  'required': 'Required',
  'yes': 'Yes',
  'no': 'No',

  // Drawer
  'allConnections': 'All Connections',
  'appSettings': 'App Settings',
  'backupRestore': 'Backup and Restore',
  'helpFaq': 'Help and FAQ',
  'userGuide': 'User Guide',
  'about': 'About',
  'exit': 'Exit',

  // Connections
  'connections': 'Connections',
  'noConnections': 'No connections yet.\nTap + to add one.',
  'addConnection': 'Add Connection',

  // Connection form
  'clientId': 'Client ID',
  'brokerAddress': 'Broker address',
  'port': 'Port',
  'networkProtocol': 'Network protocol',
  'username': 'Username',
  'password': 'Password',
  'additionalOptions': 'Additional options',
  'addDashboard': 'Add Dashboard',
  'dashboardName': 'Dashboard name',
  'setAsHome': 'Set as connection home',
  'home': 'Home',

  // Dashboard
  'addPanel': 'Add Panel',
  'connectionSettings': 'Connection Settings',
  'noPanels': 'No panels yet.',
  'addFirstPanel': 'Tap ⋮ → Add Panel to get started.',

  // Panel picker
  'selectPanel': 'Select Panel Type',

  // Panel common
  'panelName': 'Panel name',
  'topic': 'Topic',
  'subscribeTopic': 'Subscribe Topic',
  'disableDashboardPrefix': 'Disable dashboard prefix topic',
  'payloadIsJson': 'Payload is JSON Data',
  'showReceivedTimestamp': 'Show received timestamp',
  'showSentTimestamp': 'Show sent timestamp',
  'confirmBeforePublish': 'Confirm before publish',
  'retain': 'Retain',
  'qos': 'QoS',
  'factor': 'Factor',
  'decimalPrecision': 'Decimal precision',
  'unit': 'Unit',
  'enableNotification': 'Enable notification or alarm',

  // Text Input
  'addTextInputPanel': 'Add a Text Input panel',
  'clearTextOnPublish': 'Clear text on publish',

  // Text Output
  'addTextOutputPanel': 'Add a Text Output panel',
  'showHistory': 'Show history',
  'textSize': 'Text size',

  // Switch
  'addSwitchPanel': 'Add a Switch panel',
  'payloadOn': 'Payload on',
  'payloadOff': 'Payload off',
  'switchType': 'Switch type',

  // Slider
  'addSliderPanel': 'Add a Slider panel',
  'payloadMin': 'Payload min',
  'payloadMax': 'Payload max',
  'sliderStep': 'Slider step',
  'sliderOrientation': 'Slider Orientation',
  'sliderColor': 'Slider color',
  'dynamicColor': 'Dynamic color',

  // Progress
  'addProgressPanel': 'Add a Progress panel',
  'progressType': 'Progress type',

  // Gauge
  'addGaugePanel': 'Add a Gauge panel',
  'arcColor1': 'Arc color 1',
  'arcColor2': 'Arc color 2',
  'arcColor3': 'Arc color 3',

  // Chart
  'addChartPanel': 'Add a Chart panel',
  'chartType': 'Chart type',
  'addSeries': 'Add series',
  'seriesLabel': 'Series label',
  'seriesColor': 'Series color',

  // Bar Graph
  'addBarGraphPanel': 'Add a Bar Graph panel',
  'orientation': 'Orientation',
  'defineRange': 'Define range',
  'addBar': 'Add bar',
  'barLabel': 'Bar label',
  'barColor': 'Bar color',

  // Multi-state
  'addMultiStatePanel': 'Add a Multi-State Indicator panel',
  'iconSize': 'Icon size',
  'addState': 'Add state',
  'stateLabel': 'State label',
  'statePayload': 'State payload',
  'stateColor': 'State color',

  // Node Status
  'addNodeStatusPanel': 'Add a Node Status panel',
  'payloadSyncRequest': 'Payload sync request',
  'payloadOnline': 'Payload online',
  'payloadOffline': 'Payload offline',
  'onlineIcon': 'Online icon',
  'offlineIcon': 'Offline icon',
  'autoSyncOnLoad': 'Auto sync on load',

  // URI Launcher
  'addUriLauncherPanel': 'Add an URI Launcher panel',
  'staticUrl': 'Static URL',

  // Settings
  'darkTheme': 'Dark theme',
  'runInBackground': 'Run in background',
  'startOnBoot': 'Start on boot',
  'disableBatteryOptimization': 'Disable battery optimization',
  'keepScreenOn': 'Keep screen on',
  'defaultConnection': 'Default Connection',
  'none': 'None',
  'selectLanguage': 'Select language',
  'dashboardListPlacement': 'Dashboard list placement',
  'portrait': 'Portrait',
  'landscape': 'Landscape',
  'bottomBar': 'Bottom Bar',
  'sideBar': 'Side Bar',
  'english': 'English',
  'italian': 'Italian',
};

// ─────────────────────────────────────────────────────────────
// ITALIAN
// ─────────────────────────────────────────────────────────────
const Map<String, String> _it = {
  'appName': 'MQTT Panel',
  'cancel': 'ANNULLA',
  'save': 'SALVA',
  'create': 'CREA',
  'delete': 'Elimina',
  'edit': 'Modifica',
  'required': 'Obbligatorio',
  'yes': 'Sì',
  'no': 'No',

  // Drawer
  'allConnections': 'Tutte le connessioni',
  'appSettings': 'Impostazioni app',
  'backupRestore': 'Backup e ripristino',
  'helpFaq': 'Aiuto e FAQ',
  'userGuide': 'Guida utente',
  'about': 'Informazioni',
  'exit': 'Esci',

  // Connections
  'connections': 'Connessioni',
  'noConnections': 'Nessuna connessione.\nPremi + per aggiungerne una.',
  'addConnection': 'Aggiungi connessione',

  // Connection form
  'clientId': 'ID client',
  'brokerAddress': 'Indirizzo broker',
  'port': 'Porta',
  'networkProtocol': 'Protocollo di rete',
  'username': 'Nome utente',
  'password': 'Password',
  'additionalOptions': 'Opzioni aggiuntive',
  'addDashboard': 'Aggiungi dashboard',
  'dashboardName': 'Nome dashboard',
  'setAsHome': 'Imposta come home della connessione',
  'home': 'Home',

  // Dashboard
  'addPanel': 'Aggiungi pannello',
  'connectionSettings': 'Impostazioni connessione',
  'noPanels': 'Nessun pannello.',
  'addFirstPanel': 'Premi ⋮ → Aggiungi pannello per iniziare.',

  // Panel picker
  'selectPanel': 'Seleziona tipo pannello',

  // Panel common
  'panelName': 'Nome pannello',
  'topic': 'Topic',
  'subscribeTopic': 'Topic di sottoscrizione',
  'disableDashboardPrefix': 'Disabilita prefisso topic dashboard',
  'payloadIsJson': 'Il payload è JSON',
  'showReceivedTimestamp': 'Mostra timestamp ricezione',
  'showSentTimestamp': 'Mostra timestamp invio',
  'confirmBeforePublish': 'Conferma prima della pubblicazione',
  'retain': 'Retain',
  'qos': 'QoS',
  'factor': 'Fattore',
  'decimalPrecision': 'Precisione decimale',
  'unit': 'Unità',
  'enableNotification': 'Abilita notifica o allarme',

  // Text Input
  'addTextInputPanel': 'Aggiungi pannello Testo Input',
  'clearTextOnPublish': 'Cancella testo dopo la pubblicazione',

  // Text Output
  'addTextOutputPanel': 'Aggiungi pannello Testo Output',
  'showHistory': 'Mostra cronologia',
  'textSize': 'Dimensione testo',

  // Switch
  'addSwitchPanel': 'Aggiungi pannello Interruttore',
  'payloadOn': 'Payload acceso',
  'payloadOff': 'Payload spento',
  'switchType': 'Tipo interruttore',

  // Slider
  'addSliderPanel': 'Aggiungi pannello Cursore',
  'payloadMin': 'Payload minimo',
  'payloadMax': 'Payload massimo',
  'sliderStep': 'Passo cursore',
  'sliderOrientation': 'Orientamento cursore',
  'sliderColor': 'Colore cursore',
  'dynamicColor': 'Colore dinamico',

  // Progress
  'addProgressPanel': 'Aggiungi pannello Progresso',
  'progressType': 'Tipo progresso',

  // Gauge
  'addGaugePanel': 'Aggiungi pannello Manometro',
  'arcColor1': 'Colore arco 1',
  'arcColor2': 'Colore arco 2',
  'arcColor3': 'Colore arco 3',

  // Chart
  'addChartPanel': 'Aggiungi pannello Grafico',
  'chartType': 'Tipo grafico',
  'addSeries': 'Aggiungi serie',
  'seriesLabel': 'Etichetta serie',
  'seriesColor': 'Colore serie',

  // Bar Graph
  'addBarGraphPanel': 'Aggiungi pannello Grafico a barre',
  'orientation': 'Orientamento',
  'defineRange': 'Definisci intervallo',
  'addBar': 'Aggiungi barra',
  'barLabel': 'Etichetta barra',
  'barColor': 'Colore barra',

  // Multi-state
  'addMultiStatePanel': 'Aggiungi pannello Indicatore multi-stato',
  'iconSize': 'Dimensione icona',
  'addState': 'Aggiungi stato',
  'stateLabel': 'Etichetta stato',
  'statePayload': 'Payload stato',
  'stateColor': 'Colore stato',

  // Node Status
  'addNodeStatusPanel': 'Aggiungi pannello Stato nodo',
  'payloadSyncRequest': 'Payload richiesta di sincronizzazione',
  'payloadOnline': 'Payload online',
  'payloadOffline': 'Payload offline',
  'onlineIcon': 'Icona online',
  'offlineIcon': 'Icona offline',
  'autoSyncOnLoad': 'Sincronizzazione automatica al caricamento',

  // URI Launcher
  'addUriLauncherPanel': 'Aggiungi pannello Avvia URI',
  'staticUrl': 'URL statico',

  // Settings
  'darkTheme': 'Tema scuro',
  'runInBackground': 'Esegui in background',
  'startOnBoot': 'Avvia all\'avvio',
  'disableBatteryOptimization': 'Disabilita ottimizzazione batteria',
  'keepScreenOn': 'Mantieni schermo acceso',
  'defaultConnection': 'Connessione predefinita',
  'none': 'Nessuna',
  'selectLanguage': 'Seleziona lingua',
  'dashboardListPlacement': 'Posizione lista dashboard',
  'portrait': 'Verticale',
  'landscape': 'Orizzontale',
  'bottomBar': 'Barra inferiore',
  'sideBar': 'Barra laterale',
  'english': 'Inglese',
  'italian': 'Italiano',
};