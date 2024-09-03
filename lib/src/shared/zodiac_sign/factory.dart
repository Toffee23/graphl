class ZodiacFactory {
  DateTime date;

  ZodiacFactory({required this.date});

  static List<Map<String, String>> zodiacSignsAndSymbols = [
    {
      "ZodicaName": "Aquarius",
      "ZodicaSign": "🌊",
    },
    {
      "ZodicaName": "Capricorn",
      "ZodicaSign": "🐐",
    },
    {
      "ZodicaName": "Pisces",
      "ZodicaSign": "🐟",
    },
    {
      "ZodicaName": "Aries",
      "ZodicaSign": "🔥",
    },
    {
      "ZodicaName": "Taurus",
      "ZodicaSign": "🌼",
    },
    {
      "ZodicaName": "Geminies",
      "ZodicaSign": "🗣️",
    },
    {
      "ZodicaName": "Cancer",
      "ZodicaSign": "🦀",
    },
    {
      "ZodicaName": "Leo",
      "ZodicaSign": "🦁",
    },
    {
      "ZodicaName": "Virgo",
      "ZodicaSign": "🌾",
    },
    {
      "ZodicaName": "Libra",
      "ZodicaSign": "⚖️",
    },
    {
      "ZodicaName": "Scorpio",
      "ZodicaSign": "🦂",
    },
    {
      "ZodicaName": "Sagittarius",
      "ZodicaSign": "🏹",
    }
  ];

  static Map<String, dynamic> _getZodiacSign(DateTime date) {
    var days = date.day;
    var months = date.month;
    if (months == 1) {
      if (days >= 21) {
        return ZodiacFactory.find("Aquarius");
      } else {
        return ZodiacFactory.find("Capricorn");
      }
    } else if (months == 2) {
      if (days >= 20) {
        return ZodiacFactory.find("Pisces");
      } else {
        return ZodiacFactory.find("Aquarius");
      }
    } else if (months == 3) {
      if (days >= 21) {
        return ZodiacFactory.find("Aries");
      } else {
        return ZodiacFactory.find("Pisces");
      }
    } else if (months == 4) {
      if (days >= 21) {
        return ZodiacFactory.find("Taurus");
      } else {
        return ZodiacFactory.find("Aries");
      }
    } else if (months == 5) {
      if (days >= 22) {
        return ZodiacFactory.find("Geminies");
      } else {
        return ZodiacFactory.find("Taurus");
      }
    } else if (months == 6) {
      if (days >= 22) {
        return ZodiacFactory.find("Cancer");
      } else {
        return ZodiacFactory.find("Geminies");
      }
    } else if (months == 7) {
      if (days >= 23) {
        return ZodiacFactory.find("Leo");
      } else {
        return ZodiacFactory.find("Cancer");
      }
    } else if (months == 8) {
      if (days >= 23) {
        return ZodiacFactory.find("Virgo");
      } else {
        return ZodiacFactory.find("Leo");
      }
    } else if (months == 9) {
      if (days >= 24) {
        return ZodiacFactory.find("Libra");
      } else {
        return ZodiacFactory.find("Virgo");
      }
    } else if (months == 10) {
      if (days >= 24) {
        return ZodiacFactory.find("Scorpio");
      } else {
        return ZodiacFactory.find("Libra");
      }
    } else if (months == 11) {
      if (days >= 23) {
        return ZodiacFactory.find("Sagittarius");
      } else {
        return ZodiacFactory.find("Scorpio");
      }
    } else if (months == 12) {
      if (days >= 22) {
        return ZodiacFactory.find("Capricorn");
      } else {
        return ZodiacFactory.find("Sagittarius");
      }
    }
    return {};
  }

  static find(String zodicaName) {
    return ZodiacFactory.zodiacSignsAndSymbols
        .firstWhere((zodiac) => zodiac['ZodicaName'] == zodicaName);
  }

  String get sign {
    return getZodiacSign()["ZodicaSign"];
  }

  String get name {
    return getZodiacSign()["ZodicaName"];
  }

  getZodiacSign() {
    return ZodiacFactory._getZodiacSign(date);
  }
}
