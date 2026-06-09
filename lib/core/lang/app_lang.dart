class AppLang {
  static String lang = "fr";

  static Map<String, Map<String, String>> _values = {
    "fr": {
      "dashboard": "Tableau de bord",
      "vehicles": "Véhicules",
    },
    "en": {
      "dashboard": "Dashboard",
      "vehicles": "Vehicles",
    },
    "ar": {
      "dashboard": "لوحة التحكم",
      "vehicles": "السيارات",
    }
  };

  static String t(String key) {
    return _values[lang]?[key] ?? key;
  }
}
