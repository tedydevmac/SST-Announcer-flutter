import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:shared_preferences/shared_preferences.dart';

const List<String> colorChoices = ["Purple", "Blue", "Red"];
Color pickerColor = Color(0xff443a49);
Color currentColor = Color(0xff443a49);

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String dropdownValue = colorChoices.first;

  void changeColor(Color color) {
    setState(() => pickerColor = color);
  }

  void getColor() async {
    final prefs = await SharedPreferences.getInstance();
    currentColor = Color(
      prefs.getInt("color") ?? Color(0xff443a49).value,
    );
    print("current colour: $currentColor");
  }

  void saveColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setInt("color", color.value);
    print(prefs.getInt("color"));
  }

  @override
  Widget build(BuildContext context) {
    getColor();
    return Scaffold(
      appBar: AppBar(
        title: Text("Settings"),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            children: [
              ListView(
                shrinkWrap: true,
                children: [
                  Row(
                    children: [
                      Text(
                        "Colour scheme:",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      SizedBox(
                        width: 20,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(width: 2, color: Colors.white),
                        ),
                        child: Icon(
                          Icons.square,
                          color: currentColor,
                        ),
                      ),
                      Spacer(),
                      TextButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (context) {
                              return AlertDialog(
                                title: Text("Choose colour theme"),
                                content: SingleChildScrollView(
                                  child: ColorPicker(
                                    pickerColor: currentColor,
                                    onColorChanged: changeColor,
                                  ),
                                ),
                                actions: [
                                  Center(
                                    child: Row(
                                      children: [
                                        ElevatedButton(
                                            onPressed: () {
                                              var navigator =
                                                  Navigator.of(context);
                                              navigator.pop();
                                            },
                                            child: Text("Cancel")),
                                        Spacer(),
                                        ElevatedButton(
                                            onPressed: () async {
                                              final prefs =
                                                  await SharedPreferences
                                                      .getInstance();
                                              var navigator =
                                                  Navigator.of(context);
                                              print(
                                                  "current picker color: $pickerColor");
                                              saveColor(pickerColor);
                                              print(
                                                  "saved color: ${prefs.getInt("color")}");
                                              setState(() {
                                                getColor();
                                              });
                                              navigator.pop();
                                            },
                                            child: Text("Set color")),
                                      ],
                                    ),
                                  )
                                ],
                              );
                            },
                          );
                        },
                        child: Text(
                          "Change",
                          style: TextStyle(fontSize: 16),
                        ),
                      )
                    ],
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
