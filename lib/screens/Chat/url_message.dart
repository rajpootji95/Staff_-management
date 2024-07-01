import 'package:fieldmanager_hrms_flutter/utils/app_constants.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlMessage extends StatefulWidget {
  const UrlMessage({
    Key? key,
    required this.textContent,
    required this.textColor,
    required this.isMyMessage,
  }) : super(key: key);

  final String textContent;
  final Color textColor;
  final bool isMyMessage;

  @override
  State<UrlMessage> createState() => _UrlMessageState();

}

class _UrlMessageState extends State<UrlMessage> {



  static String formatLink(String url, String text) {
    return '<a href="$url">$text</a>';
  }

  static const pattern =
      r"(https?:\/\/(www.)?|www.)([\w-]+.([\w-]+.)?[\w]+)([\w./?=%-]*)";
  final regExp = RegExp(pattern);
  bool hasURLs(String text) {
    return regExp.hasMatch(text);
  }

  @override
  Widget build(BuildContext context) {
    final text = widget.textContent;
    final textColor = widget.textColor;
    final isMyMessage = widget.isMyMessage;

    final linkTextStyle = TextStyle(
      color: isMyMessage ? Colors.blueGrey : Colors.blue,
      fontSize: fontSizeMedium,
      fontWeight: FontWeight.bold,
      decoration: TextDecoration.underline,
    );

    return RichText(
      text: TextSpan(
        children: text.split(' ').map((word) {
          if (hasURLs(word)) {
            return TextSpan(
              text: word,
              style: linkTextStyle,
              recognizer: TapGestureRecognizer()
                ..onTap = () {
                  launchUrl(Uri.parse(word));
                },
            );
          } else {
            return TextSpan(
              text: '$word ',
              style: TextStyle(color: textColor, fontSize: fontSizeMedium),
            );
          }
        }).toList(),
      ),
    );
  }
}