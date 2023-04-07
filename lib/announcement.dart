import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';

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
            "(font-size: 40;|color: #[0-9a-fA-F]{6};|background-color: \\w+;)"),
        (match) {
      return '"${match.group(0)}"';
    });
    Widget html = Html(
      data: parsedString,
    );

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
                  html,
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
