import 'package:flutter/material.dart';

class TenantPreference extends StatefulWidget {
  const TenantPreference({
    super.key,
    required this.selectedPreferences,
  });

  final List<String> selectedPreferences;

  @override
  State<TenantPreference> createState() => _TenantPreference();
}

class _TenantPreference extends State<TenantPreference> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white,
                border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    width: 0.3),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text("Who do you want to rent to?"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            if (widget.selectedPreferences.contains('Family')) {
                              widget.selectedPreferences.remove("Family");
                            } else {
                              widget.selectedPreferences.add("Family");
                              widget.selectedPreferences.remove("Any");
                            }
                          });
                        },
                        child: Card(
                          elevation: 0,
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'assets/icons/family.png',
                                      scale: 6,
                                    ),
                                  ),
                                  if (widget.selectedPreferences
                                      .contains('Family'))
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.blue,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Text(
                                'Family',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            if (widget.selectedPreferences
                                .contains('Female Student')) {
                              widget.selectedPreferences
                                  .remove('Female Student');
                            } else {
                              widget.selectedPreferences.add('Female Student');
                              widget.selectedPreferences.remove("Any");
                            }
                          });
                        },
                        child: Card(
                          elevation: 0,
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'assets/icons/studentfemaleblack.png',
                                      scale: 6,
                                    ),
                                  ),
                                  if (widget.selectedPreferences
                                      .contains('Female Student'))
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.blue,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Text(
                                'Female Student',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            if (widget.selectedPreferences
                                .contains('Male Student')) {
                              widget.selectedPreferences.remove('Male Student');
                            } else {
                              widget.selectedPreferences.add('Male Student');
                              widget.selectedPreferences.remove("Any");
                            }
                          });
                        },
                        child: Card(
                          elevation: 0,
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'assets/icons/studentmale.png',
                                      scale: 6,
                                    ),
                                  ),
                                  if (widget.selectedPreferences
                                      .contains('Male Student'))
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.blue,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Text(
                                'Male Student',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  //SECOND ROW
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            if (widget.selectedPreferences
                                .contains('Male Worker')) {
                              widget.selectedPreferences.remove("Male Worker");
                            } else {
                              widget.selectedPreferences.add("Male Worker");
                              widget.selectedPreferences.remove("Any");
                            }
                          });
                        },
                        child: Card(
                          elevation: 0,
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'assets/icons/businessman.png',
                                      scale: 6,
                                    ),
                                  ),
                                  if (widget.selectedPreferences
                                      .contains('Male Worker'))
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.blue,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Text(
                                'Male Worker',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            if (widget.selectedPreferences
                                .contains('Female Worker')) {
                              widget.selectedPreferences
                                  .remove('Female Worker');
                            } else {
                              widget.selectedPreferences.add('Female Worker');
                              widget.selectedPreferences.remove("Any");
                            }
                          });
                        },
                        child: Card(
                          elevation: 0,
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'assets/icons/businesswoman.png',
                                      scale: 6,
                                    ),
                                  ),
                                  if (widget.selectedPreferences
                                      .contains('Female Worker'))
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.blue,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Text(
                                'Female Worker',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            if (widget.selectedPreferences.contains('Any')) {
                              widget.selectedPreferences.remove("Any");
                            } else {
                              widget.selectedPreferences.clear();
                              widget.selectedPreferences.add('Any');
                            }
                          });
                        },
                        child: Card(
                          elevation: 0,
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'assets/icons/all.png',
                                      scale: 6,
                                    ),
                                  ),
                                  if (widget.selectedPreferences
                                      .contains('Any'))
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.check_circle,
                                          color: Colors.blue,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Text(
                                ' Any',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
          const SizedBox(
            height: 25,
          ),
          Container(
            width: MediaQuery.of(context).size.width,
            decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.black
                    : Colors.white,
                border: Border.all(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Colors.black
                        : Colors.white,
                    width: 0.3),
                borderRadius: BorderRadius.circular(10)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text("Your Preferences"),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            if (widget.selectedPreferences
                                .contains('No Smooking')) {
                              widget.selectedPreferences.remove("No Smooking");
                            } else {
                              widget.selectedPreferences.add("No Smooking");
                            }
                          });
                        },
                        child: Card(
                          elevation: 0,
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'assets/icons/smoking.png',
                                      scale: 6,
                                    ),
                                  ),
                                  if (widget.selectedPreferences
                                      .contains('No Smooking'))
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.cancel_rounded,
                                          color: Colors.red,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Text(
                                'Smooking',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            if (widget.selectedPreferences.contains('Pets')) {
                              widget.selectedPreferences.remove('Pets');
                            } else {
                              widget.selectedPreferences.add('Pets');
                            }
                          });
                        },
                        child: Card(
                          elevation: 0,
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'assets/icons/pets.png',
                                      scale: 6,
                                    ),
                                  ),
                                  if (widget.selectedPreferences
                                      .contains('Pets'))
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.cancel_rounded,
                                          color: Colors.red,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Text(
                                'Pets',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      InkWell(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onTap: () {
                          setState(() {
                            if (widget.selectedPreferences
                                .contains('Night Shift')) {
                              widget.selectedPreferences.remove('Night Shift');
                            } else {
                              widget.selectedPreferences.add('Night Shift');
                            }
                          });
                        },
                        child: Card(
                          elevation: 0,
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Image.asset(
                                      'assets/icons/nightshift.png',
                                      scale: 6,
                                    ),
                                  ),
                                  if (widget.selectedPreferences
                                      .contains('Night Shift'))
                                    const Positioned(
                                      right: 0,
                                      bottom: 0,
                                      child: CircleAvatar(
                                        backgroundColor: Colors.white,
                                        child: Icon(
                                          Icons.cancel_rounded,
                                          color: Colors.red,
                                          size: 30,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const Text(
                                'Night Shift',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
