import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:e_estates/stateManagement/user_uid.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  String? userProfile;
  String? userName;
  String? userNumber;
  TextEditingController numberController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  String selectedOption = '';

  @override
  void initState() {
    super.initState();
    initializeUserProfile();
  }

  Future<void> initializeUserProfile() async {
    try {
      userProfile = await getCurrentUserProfile();
      userName = await getCurrentUsername();
      userNumber = await getCurrentUserNumber();

      print('User Profile: $userProfile');
      print('User Name: $userName');
      print('User Number: $userNumber');

      setState(() {
        if (userName != null) {
          nameController.text = userName!;
        }
        if (userNumber != null) {
          numberController.text = userNumber!;
        }
      });
    } catch (e) {
      print('Error fetching user profile: $e');
    }
  }

  void onOptionSelected(String option) {
    setState(() {
      selectedOption = option;
      print('Selected Option: $option');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit", style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: userProfile != null
                          ? NetworkImage(userProfile!)
                          : null,
                      child: userProfile == null
                          ? const Icon(Icons.person, size: 50)
                          : null,
                    ),
                    TextButton(
                      style: const ButtonStyle(
                        backgroundColor:
                            MaterialStatePropertyAll(Colors.transparent),
                      ),
                      onPressed: () {},
                      child: const Text(
                        "Edit Picture",
                        style: TextStyle(color: Colors.blue, fontSize: 14),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Text("Name"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: nameController,
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color.fromARGB(255, 52, 52, 52)
                      : Colors.grey[300],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "userName",
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Text("I am"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  buildOptionButton('Broker'),
                  buildOptionButton('House Owner'),
                  buildOptionButton('Student'),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14),
              child: Text("Number"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: numberController,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+-]')),
                ],
                style: Theme.of(context).textTheme.bodyMedium,
                decoration: InputDecoration(
                  fillColor: Theme.of(context).brightness == Brightness.dark
                      ? const Color.fromARGB(255, 52, 52, 52)
                      : Colors.grey[300],
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25.0),
                    borderSide: BorderSide.none,
                  ),
                  hintText: "+977",
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildOptionButton(String option) {
    return InkWell(
      focusColor: Colors.transparent,
      highlightColor: Colors.transparent,
      hoverColor: Colors.transparent,
      splashColor: Colors.transparent,
      onTap: () => onOptionSelected(option),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        decoration: BoxDecoration(
          color: selectedOption == option
              ? Colors.blue
              : const Color.fromARGB(255, 52, 52, 52),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          option,
          style: const TextStyle(),
        ),
      ),
    );
  }
}
