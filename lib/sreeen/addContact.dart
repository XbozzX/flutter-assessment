import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import './contactPage.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddContact extends StatefulWidget {
  const AddContact({super.key});

  @override
  State<AddContact> createState() => _AddContactState();
}

class _AddContactState extends State<AddContact> {
  final _formKey = GlobalKey<FormState>();
  var _controllerFirstName = TextEditingController();
  var _controllerLastName = TextEditingController();
  var _controllerEmail = TextEditingController();
  late SharedPreferences _userStorage;

  Future _addContact(String firstName, String lastName, String email) async {
    Map<String, dynamic> requestPost = {
      "first_name": firstName,
      "last_name": lastName,
      "email": email,
      "fav": "nonFav"
    };

    // Obtain shared preferences
    _userStorage = await SharedPreferences.getInstance();
    String? newContact = _userStorage.getString("contact");
    List contact = jsonDecode(newContact as String);
    contact.add(requestPost);

    _userStorage.setString("contact", jsonEncode(contact));

    final uri = Uri.parse('https://reqres.in/api/users');
    final res = await http.post(uri, body: requestPost);
    if (res.statusCode == 201) {
      const SnackBar(content: Text('Processing Data'));
      print(res.statusCode);
      //Navigator.pop(context);
    } else {
      const SnackBar(content: Text("Contact Added Unsuccessful"));
    }
  }

  // create the first name data
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

  // create the last name data
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

  // create the email data
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

  // setup form data
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
                    _addContact(_controllerFirstName.text,
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
