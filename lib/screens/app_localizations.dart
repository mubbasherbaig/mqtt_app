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

  // Chart Panel
  String get addChartPanel   => get('addChartPanel');
  String get chartType       => get('chartType');
  String get decimal         => get('decimal');
  String get addMoreItem     => get('addMoreItem');
  String get item            => get('item');
  String get pieChart        => get('pieChart');
  String get donutChart      => get('donutChart');
  String get barChart        => get('barChart');

  // Bar Graph panel
  String get addBarGraphPanel => get('addBarGraphPanel');
  String get orientation     => get('orientation');
  String get defineRange     => get('defineRange');
  String get addBar          => get('addBar');
  String get barLabel        => get('barLabel');
  String get barColor        => get('barColor');
  String get addMoreBar      => get('addMoreBar');
  String get bar             => get('bar');
  String get label           => get('label');

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

  // Barcode Scanner panel
  String get addBarcodeScannerPanel => get('addBarcodeScannerPanel');
  String get buttonColor             => get('buttonColor');
  String get buttonSize              => get('buttonSize');

  // Button panel
  String get addButtonPanel     => get('addButtonPanel');
  String get noPayload          => get('noPayload');
  String get payload            => get('payload');
  String get separatePayload    => get('separatePayload');
  String get repeatPublish      => get('repeatPublish');
  String get fitToWidth         => get('fitToWidth');
  String get useIcons           => get('useIcons');

  String get addColorPickerPanel => get('addColorPickerPanel');
  String get addAlpha            => get('addAlpha');
  String get hideColorValue      => get('hideColorValue');

  // Inside AppLocalizations class
  String get addComboBoxPanel    => get('addComboBoxPanel');
  String get useIconForOption    => get('useIconForOption');
  String get labelForItem        => get('labelForItem');
  String get payloadForItem      => get('payloadForItem');

  String get addDateTimePickerPanel => get('addDateTimePickerPanel');
  String get pickerType             => get('pickerType');
  String get small                  => get('small');
  String get medium                 => get('medium');
  String get large                  => get('large');
  String get dateAndTime            => get('dateAndTime');
  String get date                   => get('date');
  String get time                   => get('time');

  String get arcColor          => get('arcColor');

  String get addImagePanel   => get('addImagePanel');
  String get imageSource     => get('imageSource');
  String get autoRefresh     => get('autoRefresh');
  String get fitToPanelWidth => get('fitToPanelWidth');
  String get urlPayload      => get('urlPayload');
  String get base64Payload   => get('base64Payload');
  String get binaryPayload   => get('binaryPayload');

  String get addLayoutDecoratorPanel => get('addLayoutDecoratorPanel');
  String get layoutDecoratorInfo     => get('layoutDecoratorInfo');
  String get titleAlignment          => get('titleAlignment');
  String get left                    => get('left');
  String get center                  => get('center');
  String get right                   => get('right');

  String get addLedIndicatorPanel => get('addLedIndicatorPanel');
  String get onIcon                => get('onIcon');
  String get offIcon               => get('offIcon');
  String get iconColor             => get('iconColor');

  String get addLineGraphPanel      => get('addLineGraphPanel');
  String get addMoreGraph           => get('addMoreGraph');
  String get smoothCurve            => get('smoothCurve');
  String get maxPersistence         => get('maxPersistence');
  String get maxDuration            => get('maxDuration');
  String get showPlotArea           => get('showPlotArea');
  String get showPointsAndTooltip   => get('showPointsAndTooltip');
  String get graphColor             => get('graphColor');
  String get topicForGraph          => get('topicForGraph');
  String get labelForGraph          => get('labelForGraph');
  String get graphSeries => get('graphSeries');

  String get addMultiStateIndicator => get('addMultiStateIndicator');
  String get chooseIcon              => get('chooseIcon');
  String get pickIconColor           => get('pickIconColor');

  String get color => get('color');

  String get addRadioButtonsPanel => get('addRadioButtonsPanel');
  String get addRadioItem         => get('addRadioItem');

  String get addANewDashboard           => get('addANewDashboard');
  String get deleteThisDashboard        => get('deleteThisDashboard');
  String get deleteThisDashboardConfirm => get('deleteThisDashboardConfirm');
  String get cannotDeleteLastDashboard  => get('cannotDeleteLastDashboard');
  String get noDashboards               => get('noDashboards');

  String get appearance        => get('appearance');
  String get behavior          => get('behavior');
  String get dashboardSettings => get('dashboardSettings');

  String get useIconSwitch => get('useIconSwitch');
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
  'addMoreBar': 'Add more bar',
  'bar': 'Bar',
  'barLabel': 'Bar label',
  'barColor': 'Bar color',
  'label': 'Label',

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

  // Barcode Scanner
  'addBarcodeScannerPanel': 'Add a Barcode Scanner panel',
  'buttonColor': 'Button color',
  'buttonSize': 'Button size',

  // Button
  'addButtonPanel': 'Add a Button panel',
  'noPayload': 'No payload',
  'payload': 'Payload',
  'separatePayload': 'Separate payload on release',
  'repeatPublish': 'Repeat publish until released',
  'fitToWidth': 'Fit to panel width',
  'useIcons': 'Use icons for button',

  'addColorPickerPanel': 'Add a Color Picker panel',
  'addAlpha': 'Add alpha',
  'hideColorValue': 'Hide color value',

  'addComboBoxPanel': 'Add a Combo Box panel',
  'useIconForOption': 'Use icon for option',
  'labelForItem': 'Label for item',
  'payloadForItem': 'Payload for item',

  'addDateTimePickerPanel': 'Add a Date Time Picker panel',
  'pickerType': 'Picker type',
  'small': 'Small',
  'medium': 'Medium',
  'large': 'Large',
  'dateAndTime': 'Date Time',
  'date': 'Date',
  'time': 'Time',

  'addImagePanel': 'Add an Image panel',
  'imageSource': 'Image source',
  'autoRefresh': 'Auto refresh',
  'fitToPanelWidth': 'Fit to panel width',
  'urlPayload': 'URL Payload',
  'base64Payload': 'Base64 Payload',
  'binaryPayload': 'Binary Payload',

  'addLayoutDecoratorPanel': 'Add a Layout Decorator panel',
  'layoutDecoratorInfo': 'This panel neither subscribes nor publishes any data. This panel is for decoration purpose only. It is useful to create header labels for combo panels.',
  'titleAlignment': 'Title alignment',
  'left': 'Left',
  'center': 'Center',
  'right': 'Right',

  'addLedIndicatorPanel': 'Add a LED Indicator panel',
  'onIcon': 'On icon',
  'offIcon': 'Off icon',
  'iconColor': 'Icon color',

  'addLineGraphPanel': 'Add a Line Graph panel',
  'addMoreGraph': 'Add more graph',
  'smoothCurve': 'Smooth curve',
  'maxPersistence': 'Max persistence',
  'maxDuration': 'Max duration',
  'showPlotArea': 'Show plot area',
  'showPointsAndTooltip': 'Show points and tooltip',
  'graphColor': 'Graph color',
  'topicForGraph': 'Topic for graph',
  'labelForGraph': 'Label for graph',

  'graphSeries': 'Graph series',

  'addMultiStateIndicator': 'Add a Multi-State Indicator',
  'addMoreItem': 'Add more item',
  'chooseIcon': 'Choose\nicon',
  'pickIconColor': 'Pick Icon Color',

  'Horizontal': 'Horizontal',
  'Vertical': 'Vertical',
  'Circular': 'Circular',

  'addRadioButtonsPanel': 'Add a Radio Buttons panel',
  'addRadioItem': 'Add radio item',

  'addANewDashboard':           'Add a new dashboard',
  'deleteThisDashboard':        'Delete this dashboard',
  'deleteThisDashboardConfirm': 'All panels in this dashboard will be permanently removed.',
  'cannotDeleteLastDashboard':  'Cannot delete the last dashboard.',
  'noDashboards':               'No dashboards yet.',

  'appearance':        'Appearance',
  'behavior':          'Behavior',
  'dashboardSettings': 'Dashboard',

  'useIconSwitch': 'Use icon switch',
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
  'addMoreBar': 'Aggiungi un\'altra barra',
  'bar': 'Barra',
  'barLabel': 'Etichetta barra',
  'barColor': 'Colore barra',
  'label': 'Etichetta',

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

  // Barcode Scanner
  'addBarcodeScannerPanel': 'Aggiungi pannello Scanner di codici a barre',
  'buttonColor': 'Colore pulsante',
  'buttonSize': 'Dimensione pulsante',

  // Button
  'addButtonPanel': 'Aggiungi pannello Pulsante',
  'noPayload': 'Nessun payload',
  'payload': 'Payload',
  'separatePayload': 'Payload separato al rilascio',
  'repeatPublish': 'Ripeti pubblicazione fino al rilascio',
  'fitToWidth': 'Adatta alla larghezza del pannello',
  'useIcons': 'Usa icone per il pulsante',

  'addColorPickerPanel': 'Aggiungi pannello Selettore colore',
  'addAlpha': 'Aggiungi canale alfa',
  'hideColorValue': 'Nascondi valore colore',

  'addComboBoxPanel': 'Aggiungi pannello Casella combinata',
  'useIconForOption': 'Usa icona per l\'opzione',
  'labelForItem': 'Etichetta per l\'elemento',
  'payloadForItem': 'Payload per l\'elemento',

  'addDateTimePickerPanel': 'Aggiungi Selettore data e ora',
  'pickerType': 'Tipo di selettore',
  'small': 'Piccolo',
  'medium': 'Medio',
  'large': 'Grande',
  'dateAndTime': 'Data e ora',
  'date': 'Data',
  'time': 'Ora',

  'addImagePanel': 'Aggiungi pannello Immagine',
  'imageSource': 'Sorgente immagine',
  'autoRefresh': 'Aggiornamento automatico',
  'fitToPanelWidth': 'Adatta alla larghezza del pannello',
  'urlPayload': 'Payload URL',
  'base64Payload': 'Payload Base64',
  'binaryPayload': 'Payload Binario',

  'addLayoutDecoratorPanel': 'Aggiungi pannello Decoratore layout',
  'layoutDecoratorInfo': 'Questo pannello non sottoscrive né pubblica dati. È solo a scopo decorativo, utile per creare etichette di intestazione per i pannelli combinati.',
  'titleAlignment': 'Allineamento titolo',
  'left': 'Sinistra',
  'center': 'Centro',
  'right': 'Destra',

  'addLedIndicatorPanel': 'Aggiungi Indicatore LED',
  'onIcon': 'Icona acceso',
  'offIcon': 'Icona spento',
  'iconColor': 'Colore icona',


  'addLineGraphPanel': 'Aggiungi grafico a linee',
  'addMoreGraph': 'Aggiungi altro grafico',
  'smoothCurve': 'Curva smussata',
  'maxPersistence': 'Persistenza massima',
  'maxDuration': 'Durata massima',
  'showPlotArea': 'Mostra area del tracciato',
  'showPointsAndTooltip': 'Mostra punti e tooltip',
  'graphColor': 'Colore del grafico',
  'topicForGraph': 'Argomento per il grafico',
  'labelForGraph': 'Etichetta per il grafico',
  'graphSeries': 'Serie del grafico',

  'addMultiStateIndicator': 'Aggiungi indicatore multi-stato',
  'addMoreItem': 'Aggiungi altro elemento',
  'chooseIcon': 'Scegli\nicona',
  'pickIconColor': 'Scegli colore icona',

  'Horizontal': 'Orizzontale',
  'Vertical': 'Verticale',
  'Circular': 'Circolare',

  'addRadioButtonsPanel': 'Aggiungi pannello pulsanti radio',
  'addRadioItem': 'Aggiungi elemento radio',

  'addANewDashboard':           'Aggiungi una nuova dashboard',
  'deleteThisDashboard':        'Elimina questa dashboard',
  'deleteThisDashboardConfirm': 'Tutti i pannelli di questa dashboard verranno rimossi definitivamente.',
  'cannotDeleteLastDashboard':  'Impossibile eliminare l\'ultima dashboard.',
  'noDashboards':               'Nessuna dashboard.',

  'appearance':        'Aspetto',
  'behavior':          'Comportamento',
  'dashboardSettings': 'Dashboard',

  'useIconSwitch': 'Usa icona interruttore',
};