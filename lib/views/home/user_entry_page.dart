import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class TextEntryDialogScreen extends StatelessWidget {
  final TextEditingController textEditingController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Enter Text'),
      content: TextField(
        controller: textEditingController,
        decoration: InputDecoration(hintText: 'Please enter the data'),
      ),
      actions: <Widget>[
        TextButton(
          child: Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: Text('Save'),
          onPressed: () {
            // Save the entered text to Firebase or perform any other action
            String enteredText = textEditingController.text;
            // TODO: Save enteredText to Firebase
            saveTextToFirestore(enteredText);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }

  Future<void> saveTextToFirestore(String enteredText) async {
    try {
      CollectionReference collectionReference =
          FirebaseFirestore.instance.collection("user_entered_info");
      collectionReference.add({
        'text': enteredText,
        'timestamp': FieldValue.serverTimestamp(),
      });
      print('Text is saved to Database');
    } catch (e) {
      print('Error while saving the user input: $e');
    }
  }
}
