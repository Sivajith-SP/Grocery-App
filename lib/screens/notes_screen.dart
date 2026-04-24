import 'package:flutter/material.dart';
import 'package:grocery_app/provider/notes_provider.dart';
import 'package:provider/provider.dart';

class NotesScreen extends StatelessWidget {
  const NotesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _textcontroller =TextEditingController();

    return Scaffold(
      appBar: AppBar(
        title: Text("Notes demo"),
      ),
      body: Column(
        children: [
          TextField(
            controller: _textcontroller,
            decoration: InputDecoration(
              labelText: "Enter note",
            ),
          ),
          SizedBox(height: 20,),
          ElevatedButton(onPressed: (){
            context.read<NotesProvider>().addNote(_textcontroller.text);
          }, child: Text("Add to firebase")),
        ],
      ),
    );
  }
}
