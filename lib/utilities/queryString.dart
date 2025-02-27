// ignore_for_file: file_names

class QueryString {
  /// Parses the given query string into a Map.
  static Map parse(String query) {
    var search =  RegExp('([^&=]+)=?([^&]*)');
    var result =  Map();

    // Get rid off the beginning ? in query strings.
    if (query.startsWith('?')) query = query.substring(1);

    // A custom decoder.
    decode(String s) => Uri.decodeComponent(s.replaceAll('+', ' '));

    // Go through all the matches and build the result map.
    for (Match match in search.allMatches(query)) {
      result[decode(match.group(1)!)] = decode(match.group(2)!);
    }

    return result;
  }
}
