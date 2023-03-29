import 'package:flutter/material.dart';
import 'package:sst_announcer/main.dart';

class AnnouncementPage extends StatefulWidget {
  final String title;
  String bodyText;
  final int position;
  AnnouncementPage(
      {super.key,
      required this.title,
      required this.bodyText,
      required this.position});

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
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            const Text("Announcement"),
            const SizedBox(
              width: 8,
            ),
            if (categoried == true && customCats.isNotEmpty)
              DropdownButton<String>(
                value: selectedCat,
                items: customCats.map((String customCat) {
                  return DropdownMenuItem<String>(
                    value: customCat,
                    child: Text(customCat),
                  );
                }).toList(),
                onChanged: choiceDropdownCallback,
                isExpanded: true,
              )
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                categoried = !categoried;
                if (categoried == false) {
                  selectedCat = "";
                }
              });
            },
            icon: categoried == true
                ? const Icon(Icons.category)
                : const Icon(Icons.category_outlined),
          )
        ],
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
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
