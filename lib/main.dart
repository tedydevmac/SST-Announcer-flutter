import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:sst_announcer/search.dart';
import 'package:sst_announcer/themes.dart';
import 'package:sst_announcer/categories/categories_list.dart';
import 'package:sst_announcer/categories/user_categories.dart';

import 'categories/categoriespage.dart';

final postStreamController = StreamController<PostStream>.broadcast();

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

List<String> customCats = [];

class HomePage extends StatefulWidget {
  HomePage({super.key, required this.title});
  final String title;
  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final addCatController = TextEditingController();
  bool addCustomCat = false;
  @override
  void initState() {
    super.initState();
  }

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
                    child: Text(
                      "SST Announcer",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  ExpansionTile(
                    clipBehavior: Clip.none,
                    title: const Text(
                      "Categories",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      CategoryListPage(),
                    ],
                  ),
                  const Divider(
                    thickness: 0.5,
                    color: Colors.black,
                  ),
                  ExpansionTile(
                    clipBehavior: Clip.hardEdge,
                    title: const Text(
                      "Custom Categories",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListView.separated(
                            physics: const NeverScrollableScrollPhysics(),
                            separatorBuilder: (context, index) =>
                                const Divider(),
                            itemCount: customCats.length,
                            shrinkWrap: true,
                            itemBuilder: (BuildContext context, int index) {
                              return InkWell(
                                onTap: () {
                                  var navigator = Navigator.of(context);
                                  navigator.push(CupertinoPageRoute(
                                    builder: (context) {
                                      return CategoryPage(
                                        category: customCats[index],
                                        isCustom: true,
                                      );
                                    },
                                  ));
                                },
                                child: ListTile(
                                  title: Text(customCats[index]),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete),
                                    iconSize: 22,
                                    color: Colors.black,
                                    tooltip: "Delete category",
                                    onPressed: () {
                                      setState(() {
                                        customCats.removeAt(index);
                                      });
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 15,
                      ),
                      addCustomCat == true
                          ? Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                shape: BoxShape.rectangle,
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
                                border: Border.all(
                                    width: 0.5, color: Colors.blueGrey),
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  TextField(
                                    controller: addCatController,
                                    decoration: const InputDecoration(
                                      hintText: "Input category title",
                                      hintStyle: TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 13),
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      TextButton(
                                        onPressed: () {
                                          if (addCatController.text == "") {
                                            setState(() {
                                              addCustomCat = false;
                                            });
                                            return;
                                          }
                                          setState(() {
                                            customCats
                                                .add(addCatController.text);
                                            addCatController.text = "";
                                            addCustomCat = false;
                                          });
                                        },
                                        child: const Text("Add category"),
                                      )
                                    ],
                                  )
                                ],
                              ),
                            )
                          : ElevatedButton.icon(
                              style: filledButtonStyle,
                              onPressed: () {
                                setState(() {
                                  addCustomCat = true;
                                });
                              },
                              icon: const Icon(Icons.add),
                              label: const Text("Add custom category"),
                            ),
                      const SizedBox(
                        height: 10,
                      )
                    ],
                  )
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
            icon: const Icon(Icons.search),
          )
        ],
      ),
      body: Ink(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(
                height: 10,
              ),
              Expanded(
                child: FeedPage(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
