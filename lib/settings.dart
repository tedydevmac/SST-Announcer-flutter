import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsScreen extends StatefulWidget {
  SettingsScreen({super.key});
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
    int? intValue;

    saveFetchValue() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      intValue = prefs.getInt("postsToFetch");
      print("value successfully set: ${prefs.getInt("postsToFetch")}");
    }

    getFetchValue() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      intValue = prefs.getInt("postsToFetch")!;
      print("value: $intValue");
    }

    saveFetchValue();
    getFetchValue();
    numberOfPostsController.text = "$intValue";

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
                    saveFetchValue();
                    print("saved: $intValue");
                    getFetchValue();
                  },
                  child: const Text("Save"))
            ],
          ),
        ),
      ),
    );
  }
}
