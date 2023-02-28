import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class AnnouncementPage extends StatefulWidget {
  AnnouncementPage({super.key, required this.title, required this.bodyText});
  var title;
  var bodyText;
  @override
  State<AnnouncementPage> createState() => _AnnouncementPageState();
}

class _AnnouncementPageState extends State<AnnouncementPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Announcement")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Ink(
            child: SingleChildScrollView(
              child: Expanded(
                child: Column(
                  children: [
                    Text(
                      widget.title,
                      style:
                          TextStyle(fontSize: 25, fontWeight: FontWeight.w500),
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Divider(
                      thickness: 1,
                      color: Colors.white,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      widget.bodyText,
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
