import 'dart:typed_data';
import '../services/person_database.dart';

class Person {
  int? id;
  String nameAndSurname;
  String city;
  String phoneNumber;
  String imageUrl;
  Uint8List? imageBytes;

  Person( 
    {
      this.id,
      required this.nameAndSurname,
      required this.city,
      required this.phoneNumber,
      required this.imageUrl,
      Uint8List? this.imageBytes
  });

  Person.fromJson(Map<String, dynamic> json)
      : nameAndSurname =
        "${json["name"]["title"]} ${json["name"]["first"]} ${json["name"]["last"]}",
        city = json["location"]["city"],
        phoneNumber = json["phone"],
        imageUrl = json["picture"]["large"],
        imageBytes = null;

  Map<String, dynamic> toJson() => {
        'nameAndSurname': nameAndSurname,
        'city': city,
        'phoneNumber': phoneNumber,
        'imageUrl': imageUrl,
        'imageBytes': imageBytes,
  };

  Map<String, dynamic> toJsonId() => {
    'id': id,
    'nameAndSurname': nameAndSurname,
    'city': city,
    'phoneNumber': phoneNumber,
    'imageUrl': imageUrl,
    'imageBytes': imageBytes,
  };

  Person.fromDb(Map<String, dynamic> dbMap)
      : id = dbMap[PersonDatabase.idColumn],
        nameAndSurname = dbMap[PersonDatabase.nameAndSurnameColumn],
        city = dbMap[PersonDatabase.cityColumn],
        phoneNumber = dbMap[PersonDatabase.phoneNumberColumn],
        imageUrl = dbMap[PersonDatabase.imageUrlColumn],
        imageBytes = dbMap[PersonDatabase.imageBytesColumn];

  Map<String, dynamic> toDbMapNoId() {
    return {
      PersonDatabase.nameAndSurnameColumn: nameAndSurname,
      PersonDatabase.cityColumn: city,
      PersonDatabase.phoneNumberColumn: phoneNumber,
      PersonDatabase.imageUrlColumn: imageUrl,
      PersonDatabase.imageBytesColumn: imageBytes
    };
  }

}
