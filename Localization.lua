local addonName, addon = ...

addon.locale = {}

addon.locale.enEN = {
    -- Core
    ["SAdCore"] = "SAdCore",
    ["versionPrefix"] = "v",
    ["close"] = "Close",
    
    -- Settings Panel Headers
    ["loggingHeader"] = "Logging",
    ["profile"] = "Profile",
    
    -- Settings Options
    ["logVersion"] = "Log Version on Load",
    ["logVersionTooltip"] = "Log the current version of the addon to the chat window on start up.",
    ["enableDebugging"] = "Enable Debugging",
    ["enableDebuggingTooltip"] = "Enable debug messages in the chat window.",
    ["useCharacterSettings"] = "Use Character-Specific Settings",
    ["characterSpecificSettingsTooltip"] = "When enabled, settings will be saved per character instead of account-wide.",
    
    -- Import/Export
    ["loadSettings"] = "Load Settings from String",
    ["loadSettingsTooltip"] = "Paste an exported settings string and click Load to import settings.",
    ["loadSettingsButton"] = "Load",
    ["shareSettings"] = "Share",
    ["shareSettingsTooltip"] = "Export your current settings as a string that can be shared with others.",
    ["shareSettingsTitle"] = "Share Settings",
    ["shareSettingsLabel"] = "Press CTRL + C to Copy",
    
    -- Import Messages
    ["importDecodeFailed"] = "Decode failed.",
    ["importDeserializeFailed"] = "Deserialize failed.",
    ["importInvalidData"] = "Invalid data structure.",
    ["importWrongAddon"] = "Imported settings are for a different addon.",
    ["importVersionMismatch"] = "Version mismatch.",
    ["importSuccess"] = "Settings imported successfully.",
    ["imported"] = "Imported",
    ["current"] = "Current",
    
    -- Author Info
    ["tagline"] = "Simple Addons—Bare minimum addons for bare minimum brains.",
    ["authorTitle"] = "Author",
    ["authorName"] = "Press CTRL + C to Copy",
}

addon.locale.ruRU = {
    -- Core
    ["SAdCore"] = "SAdCore",
    ["versionPrefix"] = "v",
    ["close"] = "Закрыть",
    
    -- Settings Panel Headers
    ["loggingHeader"] = "Логирование",
    ["profile"] = "Профиль",
    
    -- Settings Options
    ["logVersion"] = "Записывать версию при загрузке",
    ["logVersionTooltip"] = "Выводить текущую версию аддона в чат при запуске.",
    ["enableDebugging"] = "Включить отладку",
    ["enableDebuggingTooltip"] = "Включить отладочные сообщения в окне чата.",
    ["useCharacterSettings"] = "Использовать настройки персонажа",
    ["characterSpecificSettingsTooltip"] = "Когда включено, настройки сохраняются для каждого персонажа отдельно, а не для всей учетной записи.",
    
    -- Import/Export
    ["loadSettings"] = "Загрузить настройки из строки",
    ["loadSettingsTooltip"] = "Вставьте экспортированную строку настроек и нажмите Загрузить для импорта.",
    ["loadSettingsButton"] = "Загрузить",
    ["shareSettings"] = "Поделиться",
    ["shareSettingsTooltip"] = "Экспортировать текущие настройки в виде строки, которой можно поделиться с другими.",
    ["shareSettingsTitle"] = "Поделиться настройками",
    ["shareSettingsLabel"] = "Нажмите CTRL + C для копирования",
    
    -- Import Messages
    ["importDecodeFailed"] = "Ошибка декодирования.",
    ["importDeserializeFailed"] = "Ошибка десериализации.",
    ["importInvalidData"] = "Неверная структура данных.",
    ["importWrongAddon"] = "Импортированные настройки предназначены для другого аддона.",
    ["importVersionMismatch"] = "Несоответствие версий.",
    ["importSuccess"] = "Настройки успешно импортированы.",
    ["imported"] = "Импортировано",
    ["current"] = "Текущая",
    
    -- Author Info
    ["tagline"] = "Простые аддоны. Минимальные аддоны для минимальных мозгов.",
    ["authorTitle"] = "Автор",
    ["authorName"] = "Нажмите CTRL + C для копирования",
}

addon.locale.deDE = {
    -- Core
    ["SAdCore"] = "SAdCore",
    ["versionPrefix"] = "v",
    ["close"] = "Schließen",
    
    -- Settings Panel Headers
    ["loggingHeader"] = "Protokollierung",
    ["profile"] = "Profil",
    
    -- Settings Options
    ["logVersion"] = "Version beim Laden protokollieren",
    ["logVersionTooltip"] = "Die aktuelle Version des Addons beim Start im Chat anzeigen.",
    ["enableDebugging"] = "Debugging aktivieren",
    ["enableDebuggingTooltip"] = "Debug-Meldungen im Chat-Fenster aktivieren.",
    ["useCharacterSettings"] = "Charakterspezifische Einstellungen verwenden",
    ["characterSpecificSettingsTooltip"] = "Wenn aktiviert, werden die Einstellungen pro Charakter statt kontoweit gespeichert.",
    
    -- Import/Export
    ["loadSettings"] = "Einstellungen aus Text laden",
    ["loadSettingsTooltip"] = "Fügen Sie eine exportierte Einstellungszeichenfolge ein und klicken Sie auf Laden, um zu importieren.",
    ["loadSettingsButton"] = "Laden",
    ["shareSettings"] = "Teilen",
    ["shareSettingsTooltip"] = "Exportieren Sie Ihre aktuellen Einstellungen als Zeichenfolge, die mit anderen geteilt werden kann.",
    ["shareSettingsTitle"] = "Einstellungen teilen",
    ["shareSettingsLabel"] = "Drücken Sie STRG + C zum Kopieren",
    
    -- Import Messages
    ["importDecodeFailed"] = "Dekodierung fehlgeschlagen.",
    ["importDeserializeFailed"] = "Deserialisierung fehlgeschlagen.",
    ["importInvalidData"] = "Ungültige Datenstruktur.",
    ["importWrongAddon"] = "Importierte Einstellungen sind für ein anderes Addon.",
    ["importVersionMismatch"] = "Versionskonflikt.",
    ["importSuccess"] = "Einstellungen erfolgreich importiert.",
    ["imported"] = "Importiert",
    ["current"] = "Aktuell",
    
    -- Author Info
    ["tagline"] = "Einfache Addons. Minimale Addons für minimale Gehirne.",
    ["authorTitle"] = "Autor",
    ["authorName"] = "Drücken Sie STRG + C zum Kopieren",
}

addon.locale.frFR = {
    -- Core
    ["SAdCore"] = "SAdCore",
    ["versionPrefix"] = "v",
    ["close"] = "Fermer",
    
    -- Settings Panel Headers
    ["loggingHeader"] = "Journalisation",
    ["profile"] = "Profil",
    
    -- Settings Options
    ["logVersion"] = "Afficher la version au chargement",
    ["logVersionTooltip"] = "Afficher la version actuelle de l'addon dans le chat au démarrage.",
    ["enableDebugging"] = "Activer le débogage",
    ["enableDebuggingTooltip"] = "Activer les messages de débogage dans la fenêtre de chat.",
    ["useCharacterSettings"] = "Utiliser les paramètres par personnage",
    ["characterSpecificSettingsTooltip"] = "Lorsqu'activé, les paramètres sont sauvegardés par personnage au lieu d'être partagés sur le compte.",
    
    -- Import/Export
    ["loadSettings"] = "Charger les paramètres depuis une chaîne",
    ["loadSettingsTooltip"] = "Collez une chaîne de paramètres exportée et cliquez sur Charger pour importer.",
    ["loadSettingsButton"] = "Charger",
    ["shareSettings"] = "Partager",
    ["shareSettingsTooltip"] = "Exporter vos paramètres actuels sous forme de chaîne pouvant être partagée.",
    ["shareSettingsTitle"] = "Partager les paramètres",
    ["shareSettingsLabel"] = "Appuyez sur CTRL + C pour copier",
    
    -- Import Messages
    ["importDecodeFailed"] = "Échec du décodage.",
    ["importDeserializeFailed"] = "Échec de la désérialisation.",
    ["importInvalidData"] = "Structure de données invalide.",
    ["importWrongAddon"] = "Les paramètres importés sont pour un autre addon.",
    ["importVersionMismatch"] = "Incompatibilité de version.",
    ["importSuccess"] = "Paramètres importés avec succès.",
    ["imported"] = "Importé",
    ["current"] = "Actuel",
    
    -- Author Info
    ["tagline"] = "Addons simples. Addons minimaux pour cerveaux minimaux.",
    ["authorTitle"] = "Auteur",
    ["authorName"] = "Appuyez sur CTRL + C pour copier",
}

addon.locale.esES = {
    -- Core
    ["SAdCore"] = "SAdCore",
    ["versionPrefix"] = "v",
    ["close"] = "Cerrar",
    
    -- Settings Panel Headers
    ["loggingHeader"] = "Registro",
    ["profile"] = "Perfil",
    
    -- Settings Options
    ["logVersion"] = "Registrar versión al cargar",
    ["logVersionTooltip"] = "Mostrar la versión actual del addon en el chat al iniciar.",
    ["enableDebugging"] = "Habilitar depuración",
    ["enableDebuggingTooltip"] = "Habilitar mensajes de depuración en la ventana de chat.",
    ["useCharacterSettings"] = "Usar configuración por personaje",
    ["characterSpecificSettingsTooltip"] = "Cuando está habilitado, la configuración se guarda por personaje en lugar de para toda la cuenta.",
    
    -- Import/Export
    ["loadSettings"] = "Cargar configuración desde texto",
    ["loadSettingsTooltip"] = "Pega una cadena de configuración exportada y haz clic en Cargar para importar.",
    ["loadSettingsButton"] = "Cargar",
    ["shareSettings"] = "Compartir",
    ["shareSettingsTooltip"] = "Exporta tu configuración actual como una cadena que se puede compartir.",
    ["shareSettingsTitle"] = "Compartir configuración",
    ["shareSettingsLabel"] = "Pulsa CTRL + C para copiar",
    
    -- Import Messages
    ["importDecodeFailed"] = "Error de decodificación.",
    ["importDeserializeFailed"] = "Error de deserialización.",
    ["importInvalidData"] = "Estructura de datos no válida.",
    ["importWrongAddon"] = "La configuración importada es para otro addon.",
    ["importVersionMismatch"] = "Incompatibilidad de versión.",
    ["importSuccessCharacter"] = "Configuración importada al perfil del personaje.",
    ["importSuccessGlobal"] = "Configuración importada al perfil global.",
    ["imported"] = "Importado",
    ["current"] = "Actual",
    
    -- Author Info
    ["tagline"] = "Addons simples. Addons mínimos para cerebros mínimos.",
    ["authorTitle"] = "Autor",
    ["authorName"] = "Pulsa CTRL + C para copiar",
}

addon.locale.esMX = {
    -- Core
    ["SAdCore"] = "SAdCore",
    ["versionPrefix"] = "v",
    ["close"] = "Cerrar",
    
    -- Settings Panel Headers
    ["loggingHeader"] = "Registro",
    ["profile"] = "Perfil",
    
    -- Settings Options
    ["logVersion"] = "Registrar versión al cargar",
    ["logVersionTooltip"] = "Mostrar la versión actual del addon en el chat al iniciar.",
    ["enableDebugging"] = "Habilitar depuración",
    ["enableDebuggingTooltip"] = "Habilitar mensajes de depuración en la ventana de chat.",
    ["useCharacterSettings"] = "Usar configuración por personaje",
    ["characterSpecificSettingsTooltip"] = "Cuando está habilitado, la configuración se guarda por personaje en lugar de para toda la cuenta.",
    
    -- Import/Export
    ["loadSettings"] = "Cargar configuración desde texto",
    ["loadSettingsTooltip"] = "Pega una cadena de configuración exportada y haz clic en Cargar para importar.",
    ["loadSettingsButton"] = "Cargar",
    ["shareSettings"] = "Compartir",
    ["shareSettingsTooltip"] = "Exporta tu configuración actual como una cadena que se puede compartir.",
    ["shareSettingsTitle"] = "Compartir configuración",
    ["shareSettingsLabel"] = "Presiona CTRL + C para copiar",
    
    -- Import Messages
    ["importDecodeFailed"] = "Error de decodificación.",
    ["importDeserializeFailed"] = "Error de deserialización.",
    ["importInvalidData"] = "Estructura de datos no válida.",
    ["importWrongAddon"] = "La configuración importada es para otro addon.",
    ["importVersionMismatch"] = "Incompatibilidad de versión.",
    ["importSuccessCharacter"] = "Configuración importada al perfil del personaje.",
    ["importSuccessGlobal"] = "Configuración importada al perfil global.",
    ["imported"] = "Importado",
    ["current"] = "Actual",
    
    -- Author Info
    ["tagline"] = "Addons simples. Addons mínimos para cerebros mínimos.",
    ["authorTitle"] = "Autor",
    ["authorName"] = "Presiona CTRL + C para copiar",
}

addon.locale.ptBR = {
    -- Core
    ["SAdCore"] = "SAdCore",
    ["versionPrefix"] = "v",
    ["close"] = "Fechar",
    
    -- Settings Panel Headers
    ["loggingHeader"] = "Registro",
    ["profile"] = "Perfil",
    
    -- Settings Options
    ["logVersion"] = "Registrar versão ao carregar",
    ["logVersionTooltip"] = "Exibir a versão atual do addon no chat ao iniciar.",
    ["enableDebugging"] = "Ativar depuração",
    ["enableDebuggingTooltip"] = "Ativar mensagens de depuração na janela de chat.",
    ["useCharacterSettings"] = "Usar configurações por personagem",
    ["characterSpecificSettingsTooltip"] = "Quando ativado, as configurações são salvas por personagem em vez de para toda a conta.",
    
    -- Import/Export
    ["loadSettings"] = "Carregar configurações de texto",
    ["loadSettingsTooltip"] = "Cole uma string de configurações exportada e clique em Carregar para importar.",
    ["loadSettingsButton"] = "Carregar",
    ["shareSettings"] = "Compartilhar",
    ["shareSettingsTooltip"] = "Exportar suas configurações atuais como uma string que pode ser compartilhada.",
    ["shareSettingsTitle"] = "Compartilhar configurações",
    ["shareSettingsLabel"] = "Pressione CTRL + C para copiar",
    
    -- Import Messages
    ["importDecodeFailed"] = "Falha na decodificação.",
    ["importDeserializeFailed"] = "Falha na desserialização.",
    ["importInvalidData"] = "Estrutura de dados inválida.",
    ["importWrongAddon"] = "As configurações importadas são para outro addon.",
    ["importVersionMismatch"] = "Incompatibilidade de versão.",
    ["importSuccess"] = "Configurações importadas com sucesso.",
    ["imported"] = "Importado",
    ["current"] = "Atual",
    
    -- Author Info
    ["tagline"] = "Addons simples. Addons mínimos para cérebros mínimos.",
    ["authorTitle"] = "Autor",
    ["authorName"] = "Pressione CTRL + C para copiar",
}

addon.locale.itIT = {
    -- Core
    ["SAdCore"] = "SAdCore",
    ["versionPrefix"] = "v",
    ["close"] = "Chiudi",
    
    -- Settings Panel Headers
    ["loggingHeader"] = "Registrazione",
    ["profile"] = "Profilo",
    
    -- Settings Options
    ["logVersion"] = "Registra versione al caricamento",
    ["logVersionTooltip"] = "Mostra la versione corrente dell'addon nella chat all'avvio.",
    ["enableDebugging"] = "Abilita debug",
    ["enableDebuggingTooltip"] = "Abilita messaggi di debug nella finestra della chat.",
    ["useCharacterSettings"] = "Usa impostazioni per personaggio",
    ["characterSpecificSettingsTooltip"] = "Quando abilitato, le impostazioni vengono salvate per personaggio invece che per l'intero account.",
    
    -- Import/Export
    ["loadSettings"] = "Carica impostazioni da testo",
    ["loadSettingsTooltip"] = "Incolla una stringa di impostazioni esportata e fai clic su Carica per importare.",
    ["loadSettingsButton"] = "Carica",
    ["shareSettings"] = "Condividi",
    ["shareSettingsTooltip"] = "Esporta le tue impostazioni correnti come stringa che può essere condivisa.",
    ["shareSettingsTitle"] = "Condividi impostazioni",
    ["shareSettingsLabel"] = "Premi CTRL + C per copiare",
    
    -- Import Messages
    ["importDecodeFailed"] = "Decodifica fallita.",
    ["importDeserializeFailed"] = "Deserializzazione fallita.",
    ["importInvalidData"] = "Struttura dati non valida.",
    ["importWrongAddon"] = "Le impostazioni importate sono per un altro addon.",
    ["importVersionMismatch"] = "Incompatibilità di versione.",
    ["importSuccess"] = "Impostazioni importate con successo.",
    ["imported"] = "Importato",
    ["current"] = "Corrente",
    
    -- Author Info
    ["tagline"] = "Addon semplici. Addon minimali per cervelli minimali.",
    ["authorTitle"] = "Autore",
    ["authorName"] = "Premi CTRL + C per copiare",
}