import 'dart:typed_data';

import 'package:html/parser.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sst_announcer/announcement.dart';
import 'package:sst_announcer/search.dart';
import 'package:sst_announcer/themes.dart';
import 'package:sst_announcer/categories/categories_list.dart';
import 'package:sst_announcer/categories/user_categories.dart';
import 'package:xml/xml.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SST Announcer',
      theme: lightTheme,
      darkTheme: darkTheme,
      home: HomePage(title: 'All announcements'),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.title});
  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Ink(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const Center(
                    child: Text("SST Announcer",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)),
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
                  ExpansionTile(
                    clipBehavior: Clip.none,
                    title: Text(
                      "Categories",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    children: [
                      SizedBox(
                        height: 10,
                      ),
                      CategoryListPage(),
                    ],
                  ),
                  TextButton(
                      onPressed: () {},
                      child: Row(
                        children: [
                          Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Text(
                            "Add custom category",
                            style: TextStyle(fontSize: 15, color: Colors.white),
                          )
                        ],
                      ))
                ],
              ),
            ),
          ),
        ),
      ),
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                var navigator = Navigator.of(context);
                navigator.push(
                  CupertinoPageRoute(
                    builder: (context) {
                      return BlogPage();
                    },
                  ),
                );
              },
              icon: const Icon(Icons.search))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(10, 0, 10, 0),
        child: Ink(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 10,
                ),
                const SizedBox(
                  height: 10,
                ),
                Expanded(child: FeedPage()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
