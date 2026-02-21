class FractionHelper {
  static const Map<String, String> _fractionMap = {
    '1/2': '½',
    '1/3': '⅓',
    '2/3': '⅔',
    '1/4': '¼',
    '3/4': '¾',
    '1/5': '⅕',
    '2/5': '⅖',
    '3/5': '⅗',
    '4/5': '⅘',
    '1/6': '⅙',
    '5/6': '⅚',
    '1/7': '⅐',
    '1/8': '⅛',
    '3/8': '⅜',
    '5/8': '⅝',
    '7/8': '⅞',
    '1/9': '⅑',
    '1/10': '⅒',
  };

  /// Converts plain text fractions in a string to their Unicode equivalents.
  /// Example: "10 1/2" -> "10½"
  static String convertToUnicode(String text) {
    String result = text;
    _fractionMap.forEach((key, value) {
      // Handle both "1/2" and " 1/2" (with space)
      result = result.replaceAll(' $key', value);
      result = result.replaceAll(key, value);
    });
    return result;
  }
}
