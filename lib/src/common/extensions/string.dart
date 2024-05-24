import 'package:html/parser.dart';

extension StringExtension on String {
  String get htmlParsed {
    final document = parse(this);
    final String parsedString =
        parse(document.body!.text).documentElement!.text;

    return parsedString;
  }
}
