import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:sst_announcer/rss.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({super.key});
  var numberOfPostsToFetch;
  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  final TextEditingController numberOfPostsController = TextEditingController();
  @override
  void dispose() {
    numberOfPostsController.dispose();
    super.dispose();
  }

  Widget build(BuildContext context) {
    numberOfPostsController.text = "${widget.numberOfPostsToFetch}";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Settings"),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      "Number of posts to fetch",
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  SizedBox(width: 10),
                  SizedBox(
                    width: 80,
                    child: CupertinoTextField(
                      placeholder: "e.g. 50",
                      controller: numberOfPostsController,
                      decoration: BoxDecoration(),
                      style: TextStyle(color: Colors.white),
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 20,
              ),
              ElevatedButton(
                  onPressed: () {
                    widget.numberOfPostsToFetch =
                        int.parse(numberOfPostsController.text);
                  },
                  child: Text("Save"))
            ],
          ),
        ),
      ),
    );
  }
}
