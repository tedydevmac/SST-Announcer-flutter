import 'package:flutter/material.dart';
import 'package:sst_announcer/main.dart';

class AnnouncementPage extends StatefulWidget {
  final String title;
  String bodyText;
  final bool isCustom;
  AnnouncementPage(
      {super.key,
      required this.title,
      required this.bodyText,
      required this.isCustom});

  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Announcement"),
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
                  ),
                  const SizedBox(
                    height: 15,
                  ),
                  widget.isCustom == true
                      ? const Text("custom")
                      : const Text("not custom")
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
