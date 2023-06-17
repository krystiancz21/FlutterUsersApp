import 'package:flutter/material.dart';
import '../models/person_model.dart';

class PersonOfflineWidget extends StatelessWidget {
  final Person person;
  final VoidCallback editClick;
  final VoidCallback deleteClick;
  const PersonOfflineWidget(
      {Key? key,
      required this.person,
      required this.deleteClick,
      required this.editClick})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        color: Colors.white60,
        margin: const EdgeInsets.only(top: 8.0, left: 16.0, right: 16.0),
        child: ListTile(
          title: Text(person.nameAndSurname),
          leading: CircleAvatar(
            backgroundImage: MemoryImage(person.imageBytes!),
            radius: 50,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(person.city),
              Text(person.phoneNumber),
            ],
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: editClick,
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: deleteClick,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
