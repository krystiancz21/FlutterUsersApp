import 'package:flutter/material.dart';
import 'package:flutter_number_picker/flutter_number_picker.dart';
import '../widgets/person_offline_widget.dart';

import '../models/person_model.dart';
import 'form_screen.dart';
import '../services/person_database.dart';
import '../services/person_network_service.dart';
import '../widgets/person_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final PersonNetworkService personService = PersonNetworkService();
  var _peopleCount = 1;
  bool _online = true;
  bool _offlineMode = false;

  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
  GlobalKey<RefreshIndicatorState>();
  List<Person> _peopleList = [];
  Future<void>? _initPeopleData;

  @override
  void initState() {
    super.initState();
    _initPeopleData = _initPeople();
  }

  Future<void> _initPeople() async {
    if (_offlineMode) {
      _peopleList = await PersonDatabase.getPersons();
    } else {
      // _peopleList = await personService.fetchPersons(_peopleCount);
      _peopleList = await personService.fetchAndDisplayPersons(_peopleCount);
    }
  }

  Future<void> _refreshPeople() async {
    setState(() {
      if (_offlineMode) {
        _initPeople();
      } else {
        _initPeopleData = _initPeople();
      }
    });
  }

  void _updatePeopleCount(value) {
    setState(() {
      _peopleCount = value.toInt();
    });
  }

  Future<void> savePeopleToDatabase() async {
    await PersonDatabase.clearDatabase(); // można zakomentować czyszczenie przed zapisem
    for (Person person in _peopleList) {
      await PersonDatabase.insertPerson(person);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      appBar: AppBar(
        title: const Text('People'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(4.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Download:'),
                  CustomNumberPicker(
                    initialValue: _peopleCount,
                    maxValue: 100,
                    minValue: 1,
                    step: 1,
                    enable: _online,
                    onValue: _updatePeopleCount,
                  ),
                  if (_online)
                    ElevatedButton(
                      child: const Text('Save'),
                      onPressed: () {
                        savePeopleToDatabase();
                      },
                    ),
                  const Text(' Online:'),
                  Switch(
                    value: _online,
                    activeColor: Colors.blue,
                    onChanged: (bool value) {
                      setState(() {
                        _online = value;
                        if (!_online) {
                          _offlineMode = true;
                          _initPeople();
                        } else {
                          _offlineMode = false;
                        }
                      });
                    },
                  ),
                ],
              ),
            ),
            Expanded(
              child: _offlineMode ? OfflineScreen() : _buildOnlineContent(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOnlineContent() {
    return FutureBuilder(
      future: _initPeopleData,
      builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
          case ConnectionState.waiting:
          case ConnectionState.active:
            {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const <Widget>[
                    CircularProgressIndicator(),
                    SizedBox(
                      height: 20.0,
                    ),
                    Text("Loading at the moment, please hold the line.")
                  ],
                ),
              );
            }
          case ConnectionState.done:
            {
              return RefreshIndicator(
                key: _refreshIndicatorKey,
                onRefresh: _refreshPeople,
                child: ListView.builder(
                  itemCount: _peopleList.length,
                  itemBuilder: (BuildContext context, index) => PersonWidget(
                    person: _peopleList[index],
                  ),
                ),
              );
            }
        }
      },
    );
  }
}

class OfflineScreen extends StatefulWidget {
  @override
  _OfflineScreenState createState() => _OfflineScreenState();
}

class _OfflineScreenState extends State<OfflineScreen> {
  late Future<List<Person>?> _personsFuture;

  @override
  void initState() {
    super.initState();
    _personsFuture = PersonDatabase.getPersonsFromDb();
  }

  void _deletePerson(BuildContext context, Person person) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Delete'),
        content: const Text('Are you sure you want to delete this person?'),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(30),
        ),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          TextButton(
            child: const Text(
              'Delete',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            onPressed: () async {
              await PersonDatabase.deletePerson(person);
              setState(() {
                _personsFuture = PersonDatabase.getPersonsFromDb();
              });
              if (context != null && context.mounted) {
                Navigator.of(context).pop();
              }
            },
          ),
        ],
      ),
    );
  }

  void _editPerson(BuildContext context, Person person) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FromScreen(person: person),
      ),
    );
    setState(() {
      _personsFuture = PersonDatabase.getPersonsFromDb();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Person>?>(
      future: _personsFuture,
      builder: (context, AsyncSnapshot<List<Person>?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Center(child: Text(snapshot.error.toString()));
        } else if (snapshot.hasData) {
          if (snapshot.data != null) {
            return ListView.builder(
              itemBuilder: (context, index) => PersonOfflineWidget(
                person: snapshot.data![index],
                deleteClick: () {
                  _deletePerson(context, snapshot.data![index]);
                },
                editClick: () {
                  _editPerson(context, snapshot.data![index]);
                },
              ),
              itemCount: snapshot.data!.length,
            );
          }
          return const Center(
            child: Text('No people yet'),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }
}
