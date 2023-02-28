import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sst_announcer/announcement.dart';
import 'package:sst_announcer/rss.dart';
import 'package:sst_announcer/search.dart';
import 'package:sst_announcer/settings.dart';
import 'package:sst_announcer/themes.dart';

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
      home: const HomePage(title: 'Announcer'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.settings),
          onPressed: () {
            var navigator = Navigator.of(context);
            navigator.push(CupertinoPageRoute(builder: (context) {
              return SettingsScreen();
            }));
          },
        ),
        title: Text(widget.title),
        actions: [
          IconButton(
              onPressed: () {
                var navigator = Navigator.of(context);
                navigator.push(
                  CupertinoPageRoute(
                    builder: (context) {
                      return Searchpage();
                    },
                  ),
                );
              },
              icon: Icon(Icons.search))
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: Ink(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                SizedBox(
                  height: 10,
                ),
                Expanded(
                  child: ListView.separated(
                      shrinkWrap: true,
                      scrollDirection: Axis.vertical,
                      physics: AlwaysScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () {
                            var navigator = Navigator.of(context);
                            navigator
                                .push(CupertinoPageRoute(builder: (context) {
                              return AnnouncementPage();
                            }));
                          },
                          child: ListTile(
                            title: Text(
                              'Announcement $index',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text("Description $index"),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return const Divider();
                      },
                      itemCount: 20),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        foregroundColor: Colors.white,
        backgroundColor: darkTheme.backgroundColor,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
