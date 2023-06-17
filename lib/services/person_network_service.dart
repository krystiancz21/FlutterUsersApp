import 'dart:convert';

import 'package:http/http.dart' as http;
import '../models/person_model.dart';

const String randomPersonURL = "https://randomuser.me/api/";

class PersonNetworkService {
  Future<List<Person>> fetchPersons(int amount) async {
    http.Response response =
        await http.get(Uri.parse('$randomPersonURL?results=$amount'));

    if (response.statusCode == 200) {
      Map peopleData = jsonDecode(response.body);
      List<dynamic> peoples = peopleData["results"];
      return peoples.map((json) => Person.fromJson(json)).toList();
    } else {
      throw Exception("Something gone wrong, ${response.statusCode}");
    }
  }

  Future<List<Person>> fetchAndDisplayPersons(int count) async {
    http.Response response =
        await http.get(Uri.parse('$randomPersonURL?results=$count'));

    if (response.statusCode == 200) {
      Map peopleData = jsonDecode(response.body);
      List<dynamic> tmpPeopleList = peopleData["results"];
      final peopleListFromService =
          tmpPeopleList.map((json) => Person.fromJson(json)).toList();

      for (int p = 0; p < tmpPeopleList.length; ++p) {
        final url = tmpPeopleList[p]["picture"]["large"];
        peopleListFromService[p].imageBytes =
            (await http.get(Uri.parse(url))).bodyBytes;
      }

      return peopleListFromService;
    } else {
      throw Exception('Failed to fetch persons, ${response.statusCode}');
    }
  }
}
