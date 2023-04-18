import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:url_launcher/url_launcher.dart';

class AnnouncementPage extends StatefulWidget {
  final String title;
  String bodyText;
  String author;
  AnnouncementPage(
      {super.key,
      required this.title,
      required this.bodyText,
      required this.author});
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
        actions: [
          IconButton(
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text("Set reminder"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            decoration:
                                InputDecoration(hintText: "Notification title"),
                          ),
                          TextField(
                            decoration:
                                InputDecoration(hintText: "Notification body"),
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return DatePickerDialog(
                                      initialDate: DateTime.now(),
                                      firstDate:
                                          DateTime.utc(2023, DateTime.january),
                                      lastDate:
                                          DateTime(2023, DateTime.december));
                                },
                              );
                            },
                            child: Text("Choose date"),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return TimePickerDialog(
                                      initialTime: TimeOfDay.now());
                                },
                              );
                            },
                            child: Text("Choose time"),
                          ),
                        ],
                      ),
                      actions: [
                        Center(
                          child: Row(children: [
                            ElevatedButton(
                              onPressed: () {
                                var navigator = Navigator.of(context);
                                navigator.pop();
                              },
                              child: Text("Cancel"),
                            ),
                            Spacer(),
                            ElevatedButton(
                              onPressed: () {
                                var navigator = Navigator.of(context);
                                navigator.pop();
                              },
                              child: Text("Confirm"),
                            ),
                          ]),
                        )
                      ],
                      alignment: Alignment.center,
                    );
                  },
                );
              },
              icon: Icon(Icons.calendar_month))
        ],
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.title,
                    style: TextStyle(
                        color: backgroundColor,
                        fontSize: 20,
                        fontWeight: FontWeight.bold),
                  ),
                  Text(widget.author),
                  const SizedBox(
                    height: 15,
                  ),
                  Html(
                    data: parsedString,
                    style: {
                      "body": Style(
                          fontSize: FontSize.large,
                          color: backgroundColor,
                          textDecorationColor: backgroundColor),
                      "content": Style(
                          fontSize: FontSize.large,
                          color: backgroundColor,
                          textDecorationColor: backgroundColor),
                      "div": Style(
                          fontSize: FontSize.large,
                          color: backgroundColor,
                          textDecorationColor: backgroundColor),
                      /*"span": Style(
                          fontSize: FontSize.large,
                          color: backgroundColor,
                          textDecorationColor: backgroundColor),*/
                      "p": Style(
                          fontSize: FontSize.large,
                          color: backgroundColor,
                          textDecorationColor: backgroundColor),
                      "a": Style(
                        color: Colors.blue,
                      ),
                    },
                    onLinkTap: (link, _, __, ___) {
                      launch(link!);
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
