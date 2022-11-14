import 'package:flutter/material.dart';
import 'package:fluttercontactpicker/fluttercontactpicker.dart';
import 'package:localstorage/localstorage.dart';

Future<Set<PhoneContact>> fetchContacts() async {
  LocalStorage storage = LocalStorage("walkpal-emergency-contacts");
  Set<PhoneContact> results = {};
  var data = await storage.getItem("contacts");
  if(data == null){
    await storage.setItem("contacts", []);
    return results;
  }

  for (var contact in data){
    results.add(PhoneContact.fromMap(contact));
  }

  return results;
}

Future saveContacts(Set<PhoneContact> contacts) async {
  LocalStorage storage = LocalStorage("walkpal-emergency-contacts");
  List<dynamic> data = [];
  for (PhoneContact contact in contacts){
    data.add({
      "fullName": contact.fullName, 
      "phoneNumber": {
        "phoneNumber": contact.phoneNumber?.number,
        "label": contact.phoneNumber?.label
      }
    });
  }
  return await storage.setItem("contacts", data);
}

class ContactsScreen extends StatefulWidget{
  ContactsScreen({Key? key}) : super(key: key);
  @override
  State<ContactsScreen> createState() => ContactsScreenState();
}

class ContactsScreenState extends State<ContactsScreen> {
  Set<PhoneContact> contacts = {};

  @override
  void initState() {
    super.initState();
    fetchContacts().then((value) {
      setState(() {
        contacts = value;
      });
    });
  }

  @override
  Widget build(BuildContext context){
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: ListView(
        children: [
          const Text("Emergency Contacts", 
            style: TextStyle(
              decoration: TextDecoration.none, 
              fontSize: 40, 
              color: Colors.white70,
              fontWeight: FontWeight.bold
            ),
            textAlign: TextAlign.center,
          ),
          Container(
            padding: const EdgeInsets.all(16),
            child: 
              const Text("These contacts will be notified when you have an emergency.", 
              textAlign: TextAlign.center,
              style: TextStyle(
                decoration: TextDecoration.none, 
                fontSize: 16, 
                color: Colors.white70, 
                fontWeight: FontWeight.w400
              ),
            ),
          ),
          ...buildContactList(context)
        ]
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          try {
            addContact();
          } catch(e){
            return;
          }
        },
      ),
    );
  }

  List<Widget> buildContactList(BuildContext context){
    return contacts.map((c) => 
      ListTile(
        textColor: Colors.white,
        title: Text(c.fullName ?? ""),
        subtitle: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(c.phoneNumber?.number ?? ""), 
            Text(c.phoneNumber?.label ?? "")
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.close),
          color: Colors.white54,
          onPressed: (){
            deleteContact(c);
          },
        ),
      )
    ).toList();
  }

  Future addContact() async {
    try {
      PhoneContact contact = await FlutterContactPicker.pickPhoneContact();
      contacts.add(contact);
      await saveContacts(contacts);
      Set<PhoneContact> data = await fetchContacts();
      setState(() {
        contacts = data;
      });
    } catch(e) {
      return;
    }
  }

  Future deleteContact(PhoneContact contact) async {
    contacts.remove(contact);
    await saveContacts(contacts);
    Set<PhoneContact> data = await fetchContacts();
    setState(() {
      contacts = data;
    });
  }

}