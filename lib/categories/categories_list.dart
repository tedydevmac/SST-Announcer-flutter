import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sst_announcer/categories/categoriespage.dart';
import 'package:sst_announcer/themes.dart';
import 'package:xml/xml.dart' as xml;

class CategoryListPage extends StatefulWidget {
  @override
  _CategoryListPageState createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  List<String> categories = [];
  bool customCatAdd = false;
  final addCatController = TextEditingController();
  late String customCat;

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  void fetchCategories() async {
    final response = await http.get(
      Uri.parse('http://studentsblog.sst.edu.sg/feeds/posts/default'),
    );
    final document = xml.XmlDocument.parse(response.body);

    final entries = document.findAllElements('entry');
    final List<String> allCategories = [];
    for (var entry in entries) {
      final categories = entry.findAllElements('category');
      for (var category in categories) {
        final categoryName = category.getAttribute('term');
        allCategories.add(categoryName!);
      }
    }

    final uniqueCategories = Set<String>.from(allCategories).toList();
    uniqueCategories.sort();

    setState(() {
      categories = uniqueCategories;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        ListView.separated(
          physics: NeverScrollableScrollPhysics(),
          separatorBuilder: (context, index) => Divider(),
          itemCount: categories.length,
          shrinkWrap: true,
          itemBuilder: (BuildContext context, int index) {
            return InkWell(
              onTap: () {
                var navigator = Navigator.of(context);
                navigator.push(CupertinoPageRoute(
                  builder: (context) {
                    return CategoryPage(
                      category: categories[index],
                    );
                  },
                ));
              },
              child: ListTile(
                title: Text(categories[index]),
              ),
            );
          },
        ),
        if (customCatAdd == false)
          ElevatedButton.icon(
            style: filledButtonStyle,
            onPressed: () {
              setState(() {
                customCatAdd = true;
              });
            },
            icon: const Icon(Icons.add),
            label: const Text("Add custom category"),
          ),
        const SizedBox(
          height: 5,
        ),
        if (customCatAdd)
          Container(
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              shape: BoxShape.rectangle,
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              border: Border.all(width: 0.5, color: Colors.blueGrey),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: addCatController,
                  decoration: const InputDecoration(
                    hintText: "Input category title",
                    hintStyle:
                        TextStyle(fontWeight: FontWeight.w400, fontSize: 13),
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
                        categories.add(addCatController.text);
                        setState(() {
                          customCatAdd == false;
                        });
                      },
                      child: const Text("Add category"),
                    )
                  ],
                )
              ],
            ),
          ),
        const SizedBox(
          height: 15,
        )
      ],
    );
  }
}
