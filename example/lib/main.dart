import 'dart:convert';

import 'package:example/environment_variable_example.dart';
import 'package:flutter/material.dart';
import 'package:mention_tag_text_field/mention_tag_text_field.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        // home: const MentionTagTextFieldExample(),
        home: const EnvironmentVariableExample());
  }
}

class MentionTagTextFieldExample extends StatefulWidget {
  const MentionTagTextFieldExample({
    super.key,
  });

  @override
  State<MentionTagTextFieldExample> createState() =>
      _MentionTagTextFieldExampleState();
}

class _MentionTagTextFieldExampleState
    extends State<MentionTagTextFieldExample> {
  final MentionTagTextEditingController _controller =
      MentionTagTextEditingController();

  @override
  void initState() {
    super.initState();
    _controller.setText = "Hello @Emily Johnson ";
  }

  String? mentionValue;
  List searchResults = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (mentionValue != null)
                suggestions()
              else
                const Expanded(child: SizedBox()),
              const SizedBox(
                height: 16,
              ),
              mentionField(),
            ],
          ),
        ),
      ),
    );
  }

  MentionTagTextField mentionField() {
    final border = OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0), borderSide: BorderSide.none);
    return MentionTagTextField(
      keyboardType: TextInputType.multiline,
      minLines: 1,
      maxLines: 5,
      controller: _controller,
      initialMentions: const [
        ('@Emily Johnson', User(id: 1, name: 'Emily Johnson'), null)
      ],
      onMention: onMention,
      mentionTagDecoration: MentionTagDecoration(
          mentionStart: ['@', '#'],
          mentionBreak: ' ',
          allowDecrement: false,
          allowEmbedding: false,
          showMentionStartSymbol: false,
          maxWords: null,
          mentionTextStyle: TextStyle(
              color: Colors.blue, backgroundColor: Colors.blue.shade50)),
      decoration: InputDecoration(
          hintText: 'Write something...',
          hintStyle: TextStyle(color: Colors.grey.shade400),
          filled: true,
          fillColor: Colors.grey.shade100,
          border: border,
          focusedBorder: border,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0)),
    );
  }

  Widget suggestions() {
    if (searchResults.isEmpty) {
      return const Expanded(
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Flexible(
        fit: FlexFit.loose,
        child: ListView.builder(
            itemCount: searchResults.length,
            reverse: true,
            itemBuilder: (context, index) {
              return GestureDetector(
                onTap: () {
                  _controller.addMention(
                      label:
                          "${searchResults[index]['firstName']} ${searchResults[index]['lastName']}",
                      data: User(
                          id: searchResults[index]['id'],
                          name:
                              "${searchResults[index]['firstName']} ${searchResults[index]['lastName']}"),
                      stylingWidget: _controller.mentions.length == 1
                          ? MyCustomTag(
                              controller: _controller,
                              text:
                                  "${searchResults[index]['firstName']} ${searchResults[index]['lastName']}")
                          : null);
                  mentionValue = null;
                  setState(() {});
                },
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundImage:
                        NetworkImage(searchResults[index]['image']),
                  ),
                  title: Text(
                      "${searchResults[index]['firstName']} ${searchResults[index]['lastName']}"),
                  subtitle: Text(
                    "@${searchResults[index]['username']}",
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                  ),
                ),
              );
            }));
  }

  Future<void> onMention(String? value) async {
    mentionValue = value;
    searchResults.clear();
    setState(() {});
    if (value == null) return;
    final searchInput = value.substring(1);
    searchResults = await fetchSuggestionsFromServer(searchInput) ?? [];
    setState(() {});
  }

  Future<List?> fetchSuggestionsFromServer(String input) async {
    try {
      final response = await http
          .get(Uri.parse('http://dummyjson.com/users/search?q=$input'));
      return jsonDecode(response.body)['users'];
    } catch (e) {
      debugPrint(e.toString());
    }
    return null;
  }
}

class MyCustomTag extends StatelessWidget {
  const MyCustomTag({
    super.key,
    required this.controller,
    required this.text,
  });

  final MentionTagTextEditingController controller;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 6.0),
      decoration: BoxDecoration(
          color: Colors.yellow.shade50,
          borderRadius: const BorderRadius.all(Radius.circular(50))),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(text,
              style: TextStyle(
                color: Colors.yellow.shade700,
              )),
          const SizedBox(
            width: 6.0,
          ),
          GestureDetector(
            onTap: () {
              controller.remove(index: 1);
              print(controller.text);
            },
            child: Icon(
              Icons.close,
              size: 12,
              color: Colors.yellow.shade700,
            ),
          )
        ],
      ),
    );
  }
}

class User {
  const User({required this.id, required this.name});
  final int id;
  final String name;
}
