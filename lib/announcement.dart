import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';

class AnnouncementPage extends StatefulWidget {
  const AnnouncementPage({super.key});

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
            child: Expanded(
              child: Column(
                children: [
                  Text(
                    "Title of announcement",
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
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
                    "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nulla sit amet orci eget urna fringilla hendrerit eu at felis. Donec tempus euismod dui, posuere varius arcu venenatis id. Vestibulum facilisis nibh vel ipsum ornare, fringilla vehicula metus scelerisque. Sed mollis, ante vel rutrum viverra, metus velit rhoncus urna, id vulputate nibh elit sed ex. Donec facilisis leo nibh, tristique viverra elit auctor quis. Donec sollicitudin elit est, eget tempor turpis ultrices non. Etiam fringilla bibendum diam quis vehicula. Donec suscipit enim ut leo malesuada fermentum. Nunc interdum est odio, ut porta lorem blandit id. Suspendisse ac eros et dolor porta.",
                    style: TextStyle(fontSize: 18),
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
                    "Documents",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: (BuildContext, index) {
                      return InkWell(
                        onTap: () {},
                        child: ListTile(
                          leading: Icon(Icons.image),
                          title: Text("Document $index"),
                        ),
                      );
                    },
                    itemCount: 3,
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
