import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class UserInfoPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('user_entered_info')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }

        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        final data = snapshot.data!.docs;

        return ListView.builder(
          itemCount: data.length,
          itemBuilder: (context, index) {
            final documentData = data[index].data() as Map<String, dynamic>;

            // Check if 'text' field exists and is not null
            if (documentData.containsKey('text') &&
                documentData['text'] != null) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Card(
                  elevation: 3,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Text(documentData['text']),
                  ),
                ),
              );
            } else {
              // If 'text' field is missing or null, return an empty container
              return Container();
            }
          },
        );
      },
    );
  }
}
