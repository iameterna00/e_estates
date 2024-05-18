import 'package:e_estates/stateManagement/user_uid.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ProfileEdit extends StatefulWidget {
  const ProfileEdit({super.key});

  @override
  State<ProfileEdit> createState() => _ProfileEditState();
}

class _ProfileEditState extends State<ProfileEdit> {
  String? userProfile;
  String? userName;
  TextEditingController name = TextEditingController();
  String selectedOption = '';

  @override
  void initState() {
    super.initState();
    initializeUserProfile();
  }

  Future<void> initializeUserProfile() async {
    userProfile = getCurrentUserProfile();
    userName = getCurrentUsername();
    name.text = userName!;
    setState(() {});
  }

  void onOptionSelected(String option) {
    setState(() {
      selectedOption = option;
      print(option);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Title(color: Colors.black, child: const Text("Edit")),
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
                      backgroundImage: NetworkImage(userProfile!),
                    ),
                    TextButton(
                        onPressed: () {},
                        child: const Text(
                          "Edit Picture",
                          style: TextStyle(color: Colors.blue, fontSize: 14),
                        )),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              child: Text(
                "Name",
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: TextField(
                        controller: name,
                        style: Theme.of(context).textTheme.bodyMedium,
                        decoration: InputDecoration(
                            fillColor:
                                Theme.of(context).brightness == Brightness.dark
                                    ? const Color.fromARGB(255, 52, 52, 52)
                                    : Colors.grey[300],
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(25.0),
                              borderSide: BorderSide.none,
                            ),
                            hintText: "userName")),
                  ),
                ),
              ],
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              child: Text("I am"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  InkWell(
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () => onOptionSelected('Broker'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: selectedOption == 'Broker'
                            ? Colors.blue
                            : const Color.fromARGB(255, 52, 52, 52),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Broker',
                        style: TextStyle(),
                      ),
                    ),
                  ),
                  InkWell(
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () => onOptionSelected('House Owner'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: selectedOption == 'House Owner'
                            ? Colors.blue
                            : const Color.fromARGB(255, 52, 52, 52),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'House Owner',
                        style: TextStyle(),
                      ),
                    ),
                  ),
                  InkWell(
                    focusColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () => onOptionSelected('Student'),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 10, horizontal: 20),
                      decoration: BoxDecoration(
                        color: selectedOption == 'Student'
                            ? Colors.blue
                            : const Color.fromARGB(255, 52, 52, 52),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Student',
                        style: TextStyle(),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 14, vertical: 0),
              child: Text("Number"),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
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
                    hintText: "+977"),
              ),
            )
          ],
        ),
      ),
    );
  }
}
