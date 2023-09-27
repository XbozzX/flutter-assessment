import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './contactPage.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class UpdateContact extends StatefulWidget {
  final int currentContactIndex;

  const UpdateContact({super.key, required this.currentContactIndex});

  @override
  State<UpdateContact> createState() => _UpdateContactState();
}

class _UpdateContactState extends State<UpdateContact> {
  final _formKey = GlobalKey<FormState>();
  var _controllerFirstName = TextEditingController();
  var _controllerLastName = TextEditingController();
  var _controllerEmail = TextEditingController();
  late SharedPreferences userPreferences;
  Map currentContact = {};
  List<dynamic> userStorageContactList = [];

  @override
  void initState() {
    getContact(widget.currentContactIndex);
    super.initState();
  }

  Future updateContact(String firstName, String lastName, String email) async {
    Map<String, dynamic> putRequest = {
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "fav": "nonFav"
    };

    userPreferences.setString("contact", jsonEncode(userStorageContactList));
    final link =
        Uri.parse('https://reqres.in/api/users/4${currentContact['id']}');
    final apiResponse = await http.put(link, body: putRequest);
    if (apiResponse.statusCode == 200) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Processing Data")));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Unable to process the data")));
    }
  }

  void getContact(index) async {
    userPreferences = await SharedPreferences.getInstance();
    String? contact = userPreferences.getString("contact");
    List storageContact = jsonDecode(contact as String);
    setState(() {
      currentContact = storageContact[index];
      userStorageContactList = storageContact;
    });
  }

  TextFormField firstNameContext() {
    return TextFormField(
      controller: _controllerFirstName,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(40))),
      ),

      // The validator receives the text that the user has entered.
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  TextFormField lastNameContext() {
    return TextFormField(
      controller: _controllerLastName,
      keyboardType: TextInputType.emailAddress,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(40))),
      ),
      // The validator receives the text that the user has entered.
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  TextFormField emailContext() {
    return TextFormField(
      controller: _controllerEmail,
      decoration: const InputDecoration(
        border: OutlineInputBorder(
            borderRadius: BorderRadius.all(Radius.circular(40))),
      ),
      // The validator receives the text that the user has entered.
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter some text';
        }
        return null;
      },
    );
  }

  Form firstName_lastName_email_Context() {
    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
                child: Column(children: [
              Container(
                margin: const EdgeInsets.only(top: 20),
                child: const CircleAvatar(
                  radius: 80,
                  backgroundImage: AssetImage("assets/images/amico.png"),
                ),
              )
            ])),
            const Text("      First Name"),
            SizedBox(
              height: 5,
            ),
            firstNameContext(),
            SizedBox(
              height: 15,
            ),
            const Text("      Last Name"),
            SizedBox(
              height: 5,
            ),
            lastNameContext(),
            SizedBox(
              height: 15,
            ),
            const Text("      Email"),
            SizedBox(
              height: 5,
            ),
            emailContext(),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 145, vertical: 16),
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    updateContact(_controllerFirstName.text,
                        _controllerLastName.text, _controllerEmail.text);
                  });
                  // Validate returns true if the form is valid, or false otherwise.
                  if (_formKey.currentState!.validate()) {
                    // to provide notification
                    ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Processing Data')));
                    // Go back to Contacts Page
                    Navigator.push(
                        context,
                        CupertinoPageRoute(
                            builder: (context) => const ContactPage()));
                  }
                },
                child: const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _controllerFirstName.text = "";
    _controllerLastName.text = "";
    _controllerEmail.text = "";
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: Color.fromRGBO(50, 186, 165, 1.0),
      ),
      body: SingleChildScrollView(child: firstName_lastName_email_Context()),
    );
  }
}
