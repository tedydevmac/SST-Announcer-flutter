import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:sst_announcer/announcement.dart';

class Searchpage extends StatefulWidget {
  const Searchpage({super.key});

  @override
  State<Searchpage> createState() => _SearchpageState();
}

class _SearchpageState extends State<Searchpage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Search")),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Ink(
            child: Column(
              children: [
                CupertinoTextField(
                  decoration: BoxDecoration(),
                  placeholder: "Search for announcements",
                  style: TextStyle(color: Colors.white),
                ),
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemBuilder: ((context, index) {
                      return InkWell(
                        onTap: () {
                          var navigator = Navigator.of(context);
                          navigator.push(
                            CupertinoPageRoute(
                              builder: (context) {
                                return AnnouncementPage();
                              },
                            ),
                          );
                        },
                        child: ListTile(
                          title: Text(
                            "Search result $index",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Text("Body text $index"),
                        ),
                      );
                    }),
                    itemCount: 5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
