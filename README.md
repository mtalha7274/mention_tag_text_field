This package extends the capabilties of a normal TextField or TextFormField to enable mention or tagging.
<p align="center">
  <img src="https://s14.gifyu.com/images/bNspb.gif" alt="Demo GIF" />
</p>

## Getting started

In your pubspec.yaml
```yaml
dependencies:
    mention_tag_text_field: ^latest
```

Import the package using
```dart
import 'package:mention_tag_text_field/mention_tag_text_field.dart';
```

## Usage

Define a MentionTagTextEditingController
```dart
final MentionTagTextEditingController _controller =
      MentionTagTextEditingController();
```

You can use MentionTagTextField just like your normal TextField. If you are using Form widget you can use MentionTagTextFormField.
```dart
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
                suggestions() // Widget to show search results
              else
                const Expanded(child: SizedBox()),
              const SizedBox(
                height: 16,
              ),
              MentionTagTextField(
                controller: _controller,

                // onMention will return text when mention is triggered,
                // otherwise it'll return null.
                onMention: (value) async {
                  mentionValue = value;
                  setState(() {});
                  await getUsersFromNetwork(); // Write your logic to get search results.
                },
                mentionTagDecoration: MentionTagDecoration(
                    // Define list of symbols where mention will be triggered.
                    mentionStart: ['@', '#'],

                    // The character which will be inserted automatically after the mention.
                    mentionBreak: ' ',

                    // Enable removing mention decrementally instead of all at once.
                    allowDecrement: true,

                    // Prevent mention triggering if mention symbol is embedded in the text.
                    allowEmbedding: false,

                    // If mention symbol is visible or not with mentions in the textfield.
                    showMentionStartSymbol: false,

                    // Max words a mention can have, must be greater than 0 or null.
                    // Null means any number of words.
                    maxWords: null,

                    // TextStyle for mentions
                    mentionTextStyle: TextStyle(
                        color: Colors.blue,
                        backgroundColor: Colors.blue.shade50)),
                decoration: InputDecoration(
                    hintText: 'Write something...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    filled: true,
                    fillColor: Colors.grey.shade100,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none),
                    focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0),
                        borderSide: BorderSide.none),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 12.0)),
              )
            ],
          ),
        ),
      ),
    );
  }
```

**Initial Mentions**

You can also set the initial mentions if your initial text has mentions in it. First set the initial text,
```dart
@override
  void initState() {
    super.initState();
    _controller.setText = "Hello @Emily Johnson ";
  }
```

Now set the intial mentions using initialMentions property. You must pass a list of tuples containing mention label and data associated with it. The mention label must have a mandatory mention start symbol for intial mentions. 

You can also give a specific styling widget or pass null to use default mention styling which you set in mentionTagDecoration.
```dart
MentionTagTextField(
      controller: _controller,
      initialMentions: const [
        ('@Emily Johnson', User(id: 1, name: 'Emily Johnson'), null)
      ],
      ...
)
``` 

**Adding Mentions**

You can add mentions using _controller.addMention which takes a mention label and optional data associated with it.
```dart
 _controller.addMention(label: 'Emily Johnson', data: User(id: 0, name: 'Emily Johnson'));
```

To give a mention or tag a specific styling, you can pass your own custom widget in stylingWidget parameter of _controller.addMention. This enables you to create a variaty of styles for your mentions or tags.
```dart
_controller.addMention(label: 'Emma Miller', data: User(id: 1, name: 'Emma Miller'), stylingWidget: MyCustomTag(
   ... 
   ));
```
<p align="center">
  <img src="https://s14.gifyu.com/images/bNsp5.png" alt="Demo Image" />
</p>

**Removing Mentions Manually**

By default, mentions or tags are automatically removed on backspaces. 

If you want to remove a mention or tag on some action like button inside a custom tag or an external remove button, you need to call _controller.remove and give it the index of mention or tag which it has in _controller.mentions.
```dart
 _controller.remove(index: 1);
```
This will remove the mention or tag from both _controller and TextField.

Note: _controller.mentions is a getter removing mentions from it won't remove mentions from TextField, so you must have to call _controller.remove

**Getting All Mentions**

Finally, you can get all the mentions data using _controller.mentions which returns the list of data passed to each mention. If no data was passed, list of mention labels will be returned.
```dart
final List mentions = _controller.mentions;
```

To get the text with mention labels in it, use
```dart
final String textWithMentions = _controller.getText;
```

**Copying and Cutting**

You can copy and cut selection text by overriding `contextMenuBuilder`. See the example for a full implementation.

## Additional information
- **Contributing**: Contributions are welcome! Feel free to open issues or submit pull requests on [GitHub](https://github.com/iWOLFSTEIN/mention_tag_text_field).
- **Support & Feedback**: You can expect prompt responses and support from the package maintainers.
