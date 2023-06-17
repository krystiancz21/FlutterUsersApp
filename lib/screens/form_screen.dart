import 'dart:io';
import 'dart:typed_data';
import 'package:http/http.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/person_database.dart';
import '../models/person_model.dart';

class FromScreen extends StatefulWidget {
  final Person? person;
  const FromScreen({Key? key, this.person}) : super(key: key);

  @override
  State<FromScreen> createState() => FromScreenState();
}

class FromScreenState extends State<FromScreen> {
  final TextEditingController nameAndSurnameController = TextEditingController();
  final TextEditingController cityController = TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final ImagePicker imagePicker = ImagePicker();

  late FocusNode nameAndSurnameFocusNode;
  late FocusNode cityFocusNode;
  late FocusNode phoneNumberFocusNode;

  bool nameAndSurnameFocused = false;
  bool cityFocused = false;
  bool phoneNumberFocused = false;

  late Uint8List imageAsBytes = Uint8List(0);
  void pickImageClick() async {
    XFile? image = await imagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (image != null) {
        File imageFile = File(image.path);
        imageAsBytes = imageFile.readAsBytesSync();
      }
    });
  }

  void savePerson() async {
    final nameAndSurname = nameAndSurnameController.value.text;
    final city = cityController.value.text;
    final phoneNumber = phoneNumberController.value.text;

    if (nameAndSurname.isEmpty || city.isEmpty || phoneNumber.isEmpty) {
      return;
    }

    final Person personModel = Person(
        id: widget.person?.id,
        nameAndSurname: nameAndSurname,
        city: city,
        phoneNumber: phoneNumber,
        imageUrl: city,
        imageBytes: imageAsBytes); // tu bd zmiana!

    if (widget.person == null) {
      await PersonDatabase.insertPerson(personModel);
    } else {
      await PersonDatabase.updatePerson(personModel);
    }

    if (context.mounted) Navigator.pop(context);
  }

  void showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        action: SnackBarAction(
          label: "OK",
          onPressed: () {},
        ),
      ),
    );
  }

  String? validateNameAndSurnameNotEmpty(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {});
      return "Enter name and surname";
    }
    return null;
  }

  String? validateCityNotEmpty(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {});
      return "Enter city";
    }
    return null;
  }

  String? validatePhoneNumberNotEmpty(String? value) {
    if (value == null || value.isEmpty) {
      setState(() {});
      return "Enter phone number";
    }
    return null;
  }

  @override
  void initState() {
    super.initState();

    if (widget.person != null) {
      nameAndSurnameController.text = widget.person!.nameAndSurname;
      cityController.text = widget.person!.city;
      phoneNumberController.text = widget.person!.phoneNumber;
    }

    nameAndSurnameFocusNode = FocusNode();
    nameAndSurnameFocusNode.addListener(() {
      if (nameAndSurnameFocusNode.hasFocus != nameAndSurnameFocused) {
        nameAndSurnameFocused = nameAndSurnameFocusNode.hasFocus;
        String? validateResult =
        validateNameAndSurnameNotEmpty(nameAndSurnameController.text);
        if (!nameAndSurnameFocused && validateResult != null) {
          showSnackBar(validateResult);
        }
      }
    });

    cityFocusNode = FocusNode();
    cityFocusNode.addListener(() {
      if (cityFocusNode.hasFocus != cityFocused) {
        cityFocused = cityFocusNode.hasFocus;
        String? validateResult =
        validateCityNotEmpty(cityController.text);
        if (!cityFocused && validateResult != null) {
          showSnackBar(validateResult);
        }
      }
    });

    phoneNumberFocusNode = FocusNode();
    phoneNumberFocusNode.addListener(() {
      if (phoneNumberFocusNode.hasFocus != phoneNumberFocused) {
        phoneNumberFocused = phoneNumberFocusNode.hasFocus;
        String? validateResult =
        validatePhoneNumberNotEmpty(phoneNumberController.text);
        if (!phoneNumberFocused && validateResult != null) {
          showSnackBar(validateResult);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.person == null ? 'Add person' : 'Edit person'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: nameAndSurnameController,
                  validator: validateNameAndSurnameNotEmpty,
                  focusNode: nameAndSurnameFocusNode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Name and surname',
                    labelText: 'Name and surname*',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: cityController,
                  validator: validateCityNotEmpty,
                  focusNode: cityFocusNode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'City',
                    labelText: 'City*',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: phoneNumberController,
                  validator: validatePhoneNumberNotEmpty,
                  focusNode: phoneNumberFocusNode,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: 'Phone number',
                    labelText: 'Phone number*',
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: SizedBox(
                  child: Row(
                    children: [
                      SizedBox(
                        width: 160,
                        height: 160,
                        child:  Image.memory(imageAsBytes),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 14.0),
                        child: ElevatedButton(
                          onPressed: pickImageClick,
                          child: const Text("Pick image"),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: savePerson,
        tooltip: 'AddOrEdit',
        child: const Icon(Icons.done),
      ),
    );
  }

  @override
  void dispose() {
    nameAndSurnameController.dispose();
    cityController.dispose();
    phoneNumberController.dispose();
    nameAndSurnameFocusNode.dispose();
    cityFocusNode.dispose();
    phoneNumberFocusNode.dispose();
    super.dispose();
  }

}
