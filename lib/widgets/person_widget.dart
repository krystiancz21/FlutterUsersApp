import 'package:flutter/material.dart';
import '../models/person_model.dart';

class PersonWidget extends StatelessWidget {
  final Person person;
  const PersonWidget({Key? key, required this.person}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Card(
        color: Colors.white60,
        margin: const EdgeInsets.only(top: 8.0, left: 16.0, right:16.0),
        child: ListTile(
          title: Text(person.nameAndSurname),
          leading: CircleAvatar(
            backgroundImage: NetworkImage(person.imageUrl),
            radius: 50,
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text("City: ${person.city}"),
              Text("Phone: ${person.phoneNumber}"),
            ],
          ),
        ),
      ),
    );
  }
}