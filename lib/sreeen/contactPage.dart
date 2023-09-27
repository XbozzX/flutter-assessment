import 'package:assessment_app/sreeen/addContact.dart';
import 'package:assessment_app/sreeen/updateContact.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  late SharedPreferences _userStorage;
  List<dynamic> filterContactsList = [];
  List<dynamic> FullcontactsList = [];
  bool click = true;

  @override
  void initState() {
    getContactList();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  // GET the data from API and update the userPreferences
  Future getContactList() async {
    final apiResponse =
        await http.get(Uri.parse('https://reqres.in/api/users?page=1'));
    final jsonContactList = jsonDecode(apiResponse.body);

    _userStorage = await SharedPreferences.getInstance();
    var apiContactList = jsonContactList['data'];
    for (var i = 0; i < jsonContactList['data'].length; i++) {
      apiContactList[i]['fav'] = "nonFav";
    }
    _userStorage.setString("contact", jsonEncode(apiContactList));
    setState(() {
      filterContactsList = apiContactList;
      FullcontactsList = apiContactList;
    });
  }

  Future deleteContact(int index) async {
    final apiResponse = await http.delete(Uri.parse(
        'https://reqres.in/api/users/${filterContactsList[index]['id']}'));
    filterContactsList.removeAt(index);
    _userStorage = await SharedPreferences.getInstance();
    _userStorage.setString("contact", jsonEncode(filterContactsList));
    if (apiResponse.statusCode == 204) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Processing Data")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unable to process the data")));
    }

    setState(() {});
  }

//Refresh screen
  IconButton myRefreshScreen() {
    return IconButton(
      icon: const Icon(Icons.refresh),
      onPressed: () async {
        // handle the press
        _userStorage = await SharedPreferences.getInstance();
        String? userStorageContactList = _userStorage.getString("contact");
        List newContactList = jsonDecode(userStorageContactList as String);
        filterContactsList = newContactList;
        setState(() {});
      },
    );
  }

// SEARCH BAR FUNCTION
  Column searchBar() {
    return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            // Add padding around the search bar
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            // Use a Material design search bar
            child: TextField(
              onChanged: (value) {
                filterSearchResults(value);
              },
              // controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search...',
                // Add a search icon or button to the search bar
                suffixIcon: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: () {},
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
              ),
            ),
          ))
    ]);
  }

  void filterSearchResults(String query) {
    setState(() {
      filterContactsList = FullcontactsList.where((contact) =>
          contact['first_name'].toLowerCase().contains(query.toLowerCase()) ||
          contact['last_name'].toLowerCase().contains(query.toLowerCase()) ||
          contact['email']
              .toLowerCase()
              .contains(query.toLowerCase())).toList();
    });
  }

  Row buttonAll_Favourite() {
    return Row(
      children: [
        Padding(padding: const EdgeInsets.all(8.0)),
        ElevatedButton(
          style: TextButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Color.fromRGBO(50, 186, 165, 1.0),
          ),
          onPressed: () async {
            _userStorage = await SharedPreferences.getInstance();
            String? userStorageContactList = _userStorage.getString("contact");
            List newContactList = jsonDecode(userStorageContactList as String);
            filterContactsList = newContactList;
            setState(() {});
          },
          child: const Text('All'),
        ),
        Padding(padding: const EdgeInsets.all(16.0)),
        ElevatedButton(
          style: TextButton.styleFrom(
            foregroundColor: Color.fromRGBO(27, 26, 87, 1.0),
            backgroundColor: Colors.white,
          ),
          onPressed: () async {
            _userStorage = await SharedPreferences.getInstance();
            String? userStorageContactList = _userStorage.getString("contact");
            List newContactList = jsonDecode(userStorageContactList as String);
            filterContactsList = newContactList;
            setState(() {});
          },
          child: const Text('Favourite'),
        )
      ],
    );
  }

  void isFavourite(index) async {
    if (filterContactsList[index]['fav'] == "yesFav") {
      filterContactsList[index]['fav'] = "nonFav";
      // Icons.favorite;
    } else {
      filterContactsList[index]['fav'] = "yesFav";
    }
  }

  ListView listMyContact() {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: filterContactsList.length,
      itemBuilder: (context, index) {
        final Fullcontact = filterContactsList[index];
        return ExpansionTile(
          title: Text(Fullcontact['first_name'] +
              " " +
              Fullcontact['last_name'].toString()),
          subtitle: Text(Fullcontact['email'].toString()),
          iconColor: Colors.amber,
          leading: CircleAvatar(
            foregroundImage: NetworkImage(Fullcontact['avatar']),
            backgroundImage: const AssetImage("assets/images/amico.png"),
          ),
          trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
            IconButton(
              icon: Icon(
                (click = false) ? Icons.favorite : Icons.favorite_border,
                size: 20.0,
                color: Colors.brown[900],
              ),
              onPressed: () {
                // to setup Icon for favourite
                setState(() {
                  Icon(
                    (click = true) ? Icons.favorite : Icons.favorite_border,
                  );
                });
                isFavourite(index);
              },
            ),
          ]),
          children: <Widget>[
            ListTile(
              title: Text(Fullcontact['first_name'] +
                  " " +
                  Fullcontact['last_name'].toString()),
              subtitle: Text(Fullcontact['email'].toString()),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: <Widget>[
                IconButton(
                    icon: Icon(
                      Icons.send,
                      size: 20.0,
                      color: Colors.brown[900],
                    ),
                    onPressed: () {
                      //   Sent email
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Send Email")));
                    }),
                IconButton(
                    icon: Icon(
                      Icons.edit,
                      size: 20.0,
                      color: Colors.brown[900],
                    ),
                    onPressed: () {
                      //   update the contact
                      Navigator.push(
                          context,
                          CupertinoPageRoute(
                              builder: (context) =>
                                  UpdateContact(currentContactIndex: index)));
                    }),
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    size: 20.0,
                    color: Colors.brown[900],
                  ),
                  onPressed: () {
                    // Delete the contact;
                    deleteContact(index);
                  },
                ),
              ]),
            )
          ],
        );
      },
    );
  }

  // ADD CONTACT BUTTON FUNCTION
  Row addContactButton() {
    return Row(/* mainAxisAlignment: MainAxisAlignment.end*/ children: [
      Padding(padding: EdgeInsets.fromLTRB(0, 0, 325, 90)),
      //margin: const EdgeInsets.all(10),
      FloatingActionButton(
        onPressed: () {
          // Navigate to add contact page
          Navigator.push(context,
              CupertinoPageRoute(builder: (context) => const AddContact()));
        },
        backgroundColor: const Color.fromRGBO(50, 186, 165, 1.0),
        child: const Icon(Icons.add),
      )
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('My Contact'),
          centerTitle: true,
          backgroundColor: Color.fromRGBO(50, 186, 165, 1.0),
          actions: [myRefreshScreen()],
        ),
        body: ListView(
          children: [
            searchBar(),
            buttonAll_Favourite(),
            listMyContact(),
            addContactButton(),
          ],
        ));
  }
}
