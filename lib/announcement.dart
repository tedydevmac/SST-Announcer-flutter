import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class AnnouncementPage extends StatefulWidget {
  final String title;
  String bodyText;
  AnnouncementPage({super.key, required this.title, required this.bodyText});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

String selectedCat = "";

class _AnnouncementPageState extends State<AnnouncementPage> {
  void choiceDropdownCallback(String? selectedValue) {
    if (selectedValue != null) {
      selectedCat = selectedValue;
    }
  }

  bool categoried = false;
  @override
  Widget build(BuildContext context) {
    var originalString = widget.bodyText;
    var parsedString = originalString.replaceAllMapped(
        RegExp(
            "(font-size: [^;]+;|color: #[0-9a-fA-F]{6};|background-color: \\w+;)"),
        (match) {
      return '"${match.group(0)}"';
    });
    print(parsedString);

    Color backgroundColor = Colors.black;

    bool isDarkMode =
        (MediaQuery.of(context).platformBrightness == Brightness.dark);
    if (isDarkMode) {
      backgroundColor = Colors.white;
    } else {
      backgroundColor = Colors.black;
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: const [
            Text("Announcement"),
          ],
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Ink(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                        color: backgroundColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  Html(
                    data: parsedString,
                    style: {
                      "body": Style(
                          fontSize: FontSize.large, color: backgroundColor),
                      "p": Style(
                          fontSize: FontSize.large, color: backgroundColor),
                    },
                    onLinkTap: (link, _, __, ___) {
                      launch(link!);
                    },
                  ),
                  /*Text(
                    widget.title,
                    style: const TextStyle(
                        fontSize: 25, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  const Divider(
                    thickness: 1,
                    color: Colors.white,
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.bodyText,
                    style: const TextStyle(fontSize: 18),
                  ),*/
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
