import 'package:flutter/material.dart';

class HtmlAsTextSpan extends StatelessWidget {
  final String html;
  final double? fontSize;

  const HtmlAsTextSpan(
      this.html, {
        this.fontSize,
        super.key,
      });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    final RegExp htmlTagRegExp = RegExp(r'<(\/?)(b|i|u|em)>(.*?)');
    final List<InlineSpan> spans = [];
    final List<TextStyle> styleStack = [];

    int lastIndex = 0;
    Iterable<RegExpMatch> matches = htmlTagRegExp.allMatches(html);

    for (final match in matches) {
      if (match.start > lastIndex) {
        spans.add(
          TextSpan(
            text: html.substring(lastIndex, match.start),
            style: styleStack.isNotEmpty
                ? styleStack.last
                : TextStyle(
              fontSize: fontSize,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        );
      }

      final isClosingTag = match.group(1) == '/';
      final tag = match.group(2);
      final text = match.group(3);

      if (!isClosingTag) {
        TextStyle newStyle = TextStyle(
          fontSize: fontSize,
          color: Theme.of(context).colorScheme.onSurface,
        );
        switch (tag) {
          case 'b':
            newStyle = (styleStack.isNotEmpty ? styleStack.last : newStyle).merge(TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold));
            break;
          case 'i':
          case 'em':
            newStyle = (styleStack.isNotEmpty ? styleStack.last : newStyle).merge(TextStyle(fontSize: fontSize, fontStyle: FontStyle.italic));
            break;
          case 'u':
            newStyle = (styleStack.isNotEmpty ? styleStack.last : newStyle).merge(TextStyle(fontSize: fontSize, decoration: TextDecoration.underline));
            break;
          default:
            newStyle = styleStack.isNotEmpty ? styleStack.last : newStyle;
        }
        styleStack.add(newStyle);

        spans.add(
          TextSpan(
            text: text,
            style: newStyle.merge(TextStyle(
              fontSize: fontSize,
              color: Theme.of(context).colorScheme.onSurface,
            ),),
          ),
        );
      } else {
        // Closing tag
        if (styleStack.isNotEmpty) {
          styleStack.removeLast();
        }
      }

      lastIndex = match.end;
    }

    // Add remaining text after the last match
    if (lastIndex < html.length) {
      spans.add(
        TextSpan(
          text: html.substring(lastIndex),
          style: styleStack.isNotEmpty
              ? styleStack.last
              : TextStyle(
            fontSize: fontSize,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      );
    }

    return RichText(
      text: TextSpan(
        children: spans,
        style: TextStyle(
          fontSize: fontSize,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
    );
  }
}
