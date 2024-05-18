import 'dart:convert';
import 'package:e_estates/models/college_models.dart';
import 'package:e_estates/widgets/home_amanities.dart';
import 'package:e_estates/widgets/tenent_preferences.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:google_fonts/google_fonts.dart';

class UploadWidgets extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final Function saveMystate;
  final bool highlightLocationButton;
  final bool checkedLocationButton;
  final bool highlightedAmanitiesButton;
  final bool highlightedPrefrencesButton;
  final Function(String?) onPaymentFrequencyChanged;
  final Function(List<String>) homeAminities;
  final Function(List<String>) tenentPreferences;
  final Function(bool) onIsStudentChanged;
  final Function(String?) college;
  final Function(String?) courses;

  const UploadWidgets(
      {super.key,
      required this.titleController,
      required this.descriptionController,
      required this.saveMystate,
      required this.priceController,
      required this.highlightLocationButton,
      required this.onPaymentFrequencyChanged,
      required this.homeAminities,
      required this.checkedLocationButton,
      required this.highlightedAmanitiesButton,
      required this.tenentPreferences,
      required this.highlightedPrefrencesButton,
      required this.onIsStudentChanged,
      required this.college,
      required this.courses});

  @override
  State<UploadWidgets> createState() => _UploadWidgetsState();
}

class _UploadWidgetsState extends State<UploadWidgets> {
  TextEditingController searchController = TextEditingController();
  bool amanitiesChecker = false;
  bool prefrencesChecker = false;
  bool isStudent = false;
  List<College> colleges = [];
  College? selectedCollege;
  String? selectedCourse;
  String? paymentFrequency = 'Monthly';
  List<String> selectedItems = [];
  List<College> filteredColleges = [];
  List<String> selectedPreference = [];
  String dropdownValue = 'Monthly';
  String lableText = "hello";

  @override
  void initState() {
    super.initState();
    loadColleges();
    filteredColleges = List.from(colleges);
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  String getAcronym(String name) {
    const List<String> ignoreWords = ['of', 'the', 'and'];
    return name
        .split(' ')
        .where((word) =>
            !ignoreWords.contains(word.toLowerCase())) // Exclude ignore words
        .map((word) => word.isNotEmpty
            ? word[0]
            : '') // Take the first letter of each remaining word
        .join()
        .toUpperCase(); // Combine into an acronym and convert to uppercase
  }

  void loadColleges() async {
    try {
      final String response =
          await rootBundle.loadString('assets/kathmandu_college.json');
      final data = json.decode(response);
      var collegeList = data['colleges'] as List;
      setState(() {
        colleges = collegeList.map((c) => College.fromJson(c)).toList();
        filteredColleges = List.from(colleges);
        if (colleges.isNotEmpty) {
          selectedCollege = colleges[0];
        }
      });
    } catch (e) {
      print('Error loading colleges: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: TextFormField(
            controller: widget.titleController,
            style: Theme.of(context).textTheme.bodyMedium,
            decoration: InputDecoration(
                hintText: 'Write a title...',
                hintStyle: GoogleFonts.raleway(
                  fontSize: 15,
                ),
                border: const UnderlineInputBorder(
                    borderSide: BorderSide(width: 0.2)),
                contentPadding: const EdgeInsets.only(bottom: 25)),
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter a title';
              }
              return null;
            },
          ),
        ),
        TextFormField(
          controller: widget.descriptionController,
          style: Theme.of(context).textTheme.bodyMedium,
          decoration: InputDecoration(
            hintText: 'Description',
            hintStyle: GoogleFonts.raleway(
              fontSize: 15,
            ),
            border: InputBorder.none,
            counterText: '${widget.descriptionController.text.length} / 250',
          ),
          maxLength: 250,
          maxLines: null,
          onChanged: (text) {
            setState(() {});
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please enter a Description';
            }
            return null;
          },
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: TextButton(
            onPressed: () {
              widget.saveMystate();
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
              backgroundColor: widget.highlightLocationButton
                  ? Colors.red[300]!.withOpacity(0.5)
                  : Colors.transparent,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.location_on,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Add Location',
                          style: GoogleFonts.raleway(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      widget.checkedLocationButton
                          ? Icons.check_circle_rounded
                          : Icons.arrow_forward_ios,
                      size: 16,
                    ),
                  ],
                )),
          ),
        ),
        TextButton(
          onPressed: () {
            showModalBottomSheet(
                backgroundColor:
                    Theme.of(context).brightness == Brightness.light
                        ? const Color.fromRGBO(245, 245, 245, 1)
                        : Colors.black,
                context: context,
                isScrollControlled: true,
                builder: (context) => DraggableScrollableSheet(
                      expand: false,
                      initialChildSize: 0.75, // 100% of screen height
                      minChildSize: 0.5, // 50% of screen height
                      maxChildSize: 1, // 100% of screen height
                      builder: (BuildContext context,
                          ScrollController scrollController) {
                        return SingleChildScrollView(
                          controller: scrollController,
                          child: Column(
                            children: [
                              const SizedBox(
                                height: 85,
                                child: Icon(Icons.drag_handle_rounded),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  const Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: Text(
                                      'Add more details ',
                                      style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  HomeAmanities(selectedItems: selectedItems),
                                  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: ElevatedButton(
                                        onPressed: () {
                                          setState(() {
                                            widget.homeAminities(selectedItems);
                                            amanitiesChecker = true;
                                          });

                                          Navigator.pop(context);
                                        },
                                        style: ButtonStyle(
                                            elevation:
                                                MaterialStateProperty.all(5),
                                            shape: MaterialStateProperty.all(
                                                RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)))),
                                        child: const Text('Done'),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ));
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
            backgroundColor: widget.highlightedAmanitiesButton
                ? Colors.red[300]!.withOpacity(0.5)
                : Colors.transparent,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.shopping_bag,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Add Details',
                        style: GoogleFonts.raleway(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                  Icon(
                    amanitiesChecker
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_ios,
                    size: 16,
                  ),
                ],
              )),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: TextButton(
            onPressed: () {
              showModalBottomSheet(
                  backgroundColor:
                      Theme.of(context).brightness == Brightness.light
                          ? const Color.fromRGBO(245, 245, 245, 1)
                          : Colors.black,
                  context: context,
                  isScrollControlled: true,
                  builder: (context) => DraggableScrollableSheet(
                        expand: false,
                        initialChildSize: 0.75, // 100% of screen height
                        minChildSize: 0.5, // 50% of screen height
                        maxChildSize: 1, // 100% of screen height
                        builder: (BuildContext context,
                            ScrollController scrollController) {
                          return SingleChildScrollView(
                            controller: scrollController,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 85,
                                  child: Icon(Icons.drag_handle_rounded),
                                ),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    const Padding(
                                      padding: EdgeInsets.all(12.0),
                                      child: Text(
                                        'Add more details ',
                                        style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    TenantPreference(
                                      selectedPreferences: selectedPreference,
                                    ),
                                    Center(
                                      child: Padding(
                                        padding: const EdgeInsets.all(8.0),
                                        child: ElevatedButton(
                                          onPressed: () {
                                            setState(() {
                                              widget.tenentPreferences(
                                                  selectedPreference);
                                              prefrencesChecker = true;
                                            });
                                            Navigator.pop(context);
                                          },
                                          style: ButtonStyle(
                                              elevation:
                                                  MaterialStateProperty.all(5),
                                              shape: MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              10)))),
                                          child: const Text('Done'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ));
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
              backgroundColor: widget.highlightedPrefrencesButton
                  ? Colors.red[300]!.withOpacity(0.5)
                  : Colors.transparent,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Padding(
                padding: const EdgeInsets.only(bottom: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.person_search,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Add Tenant Preferences',
                          style: GoogleFonts.raleway(
                            fontSize: 15,
                          ),
                        ),
                      ],
                    ),
                    Icon(
                      prefrencesChecker
                          ? Icons.check_circle_rounded
                          : Icons.arrow_forward_ios,
                      size: 16,
                    ),
                  ],
                )),
          ),
        ),
        Row(
          children: <Widget>[
            Expanded(
              child: InkWell(
                onTap: () {
                  setState(() {
                    isStudent = !isStudent;
                  });
                },
                child: Text(
                  "I am a student searching for roommates",
                  style: GoogleFonts.raleway(
                      fontWeight: FontWeight.normal,
                      fontSize: 14,
                      color: Colors.grey),
                ),
              ),
            ),
            Checkbox(
              checkColor: Colors.white,
              side: const BorderSide(width: 1, color: Colors.grey),
              activeColor: Colors.blue,
              value: isStudent,
              onChanged: (bool? newValue) {
                if (newValue != null) {
                  setState(() {
                    isStudent = newValue;
                    widget.onIsStudentChanged(newValue);
                    print(widget.onIsStudentChanged);

                    selectedCollege = null; // Reset related selections
                    selectedCourse = null;
                  });
                }
              },
            ),
          ],
        ),
        if (isStudent) ...[
          Column(
            children: [
              TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  backgroundColor: Colors.transparent,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                    context: context,
                    isScrollControlled:
                        true, // Ensure the sheet takes full height if needed
                    builder: (BuildContext context) {
                      return StatefulBuilder(
                        builder:
                            (BuildContext context, StateSetter setModalState) {
                          return DraggableScrollableSheet(
                            expand: false,
                            initialChildSize:
                                0.75, // Adjust these sizes according to your needs
                            minChildSize: 0.5,
                            maxChildSize: 0.90,
                            builder: (context, scrollController) {
                              return Padding(
                                padding: const EdgeInsets.all(12.0),
                                child: Column(
                                  children: [
                                    const SizedBox(
                                      height: 50.0,
                                      child: Center(
                                        child: Icon(
                                          Icons.drag_handle,
                                          color: Color.fromARGB(
                                              255, 124, 124, 124),
                                        ), // Arrow icon
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 12),
                                      child: TextField(
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium,
                                        controller: searchController,
                                        onChanged: (value) {
                                          setModalState(() {
                                            value = value.toLowerCase();
                                            filteredColleges =
                                                colleges.where((college) {
                                              return college.name
                                                      .toLowerCase()
                                                      .contains(value) ||
                                                  getAcronym(college.name)
                                                      .toLowerCase()
                                                      .startsWith(value);
                                            }).toList();
                                          });
                                        },
                                        decoration: InputDecoration(
                                          fillColor:
                                              Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Colors.black
                                                  : Colors.grey[300],
                                          filled: true,
                                          hintText: 'Search College',
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(25.0),
                                            borderSide: BorderSide.none,
                                          ),
                                          suffixIcon: const Icon(Icons.search),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: ListView.builder(
                                        controller: scrollController,
                                        itemCount: filteredColleges.length,
                                        itemBuilder:
                                            (BuildContext context, int index) {
                                          return ListTile(
                                            title: Text(
                                              filteredColleges[index].name,
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyMedium,
                                            ),
                                            onTap: () {
                                              setState(() {
                                                selectedCollege =
                                                    filteredColleges[index];
                                                widget.college(
                                                    selectedCollege!.name);

                                                selectedCourse =
                                                    null; // Reset the course selection
                                                Navigator.pop(
                                                    context); // Close the bottom sheet
                                              });
                                            },
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
                child: Padding(
                    padding: const EdgeInsets.only(bottom: 5),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.school_rounded,
                              size: 16,
                            ),
                            const SizedBox(width: 4),
                            RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: 'Select College  ',
                                    style: GoogleFonts.raleway(
                                        fontSize: 15,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? Colors.white
                                            : Colors.grey),
                                  ),
                                  TextSpan(
                                    text: '(Optional)',
                                    style: GoogleFonts.raleway(
                                      fontSize: 15,
                                      color: Colors.grey[400],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const Icon(
                          Icons.arrow_drop_down,
                          size: 20,
                        ),
                      ],
                    )),
              ),
              if (selectedCollege != null) ...[
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    "Selected College: ${selectedCollege?.name}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                )
              ]
            ],
          ),
          if (selectedCollege != null &&
              (selectedCollege!.courses.isNotEmpty)) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: TextButton(
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  alignment: Alignment.centerLeft,
                  backgroundColor: Colors.transparent,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                onPressed: () {
                  showModalBottomSheet(
                    backgroundColor:
                        Theme.of(context).brightness == Brightness.dark
                            ? Colors.black
                            : Colors.white,
                    context: context,
                    isScrollControlled: true,
                    builder: (BuildContext context) {
                      return DraggableScrollableSheet(
                        expand: false,
                        initialChildSize: 0.75,
                        minChildSize: 0.5,
                        maxChildSize: 0.90,
                        builder: (context, scrollController) {
                          return ListView.builder(
                            controller: scrollController,
                            itemCount: selectedCollege!.courses.length,
                            itemBuilder: (BuildContext context, int index) {
                              return Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: ListTile(
                                  title: Text(
                                    selectedCollege!.courses[index],
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  onTap: () {
                                    setState(() {
                                      selectedCourse =
                                          selectedCollege!.courses[index];
                                      widget.courses(selectedCourse);

                                      Navigator.pop(context);
                                    });
                                  },
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 5),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.book_rounded,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Select Course',
                            style: GoogleFonts.raleway(
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      const Icon(
                        Icons.arrow_drop_down,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
          if (selectedCourse != null) ...[
            Text(
              "Selected Cources: $selectedCourse",
              style: const TextStyle(color: Colors.grey),
            )
          ],
        ],
        Row(
          children: <Widget>[
            Expanded(
              child: TextFormField(
                onTap: () {
                  setState(() {
                    widget.onPaymentFrequencyChanged(paymentFrequency);
                  });
                },
                controller: widget.priceController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
                ],
                decoration: const InputDecoration(
                  hintText: 'Price',
                  hintStyle: TextStyle(fontSize: 15),
                  border: InputBorder.none,
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a Price';
                  }
                  return null;
                },
              ),
            ),
            Container(
              decoration: const BoxDecoration(
                  border: Border(
                      bottom: BorderSide(color: Colors.grey, width: 0.5))),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8),
                child: DropdownButton<String>(
                  value: dropdownValue,
                  elevation: 16,
                  style: const TextStyle(color: Colors.blue),
                  underline: Container(
                    height: 2,
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue!;
                      paymentFrequency = newValue;
                    });
                    widget.onPaymentFrequencyChanged(paymentFrequency);
                  },
                  items: <String>['Monthly', 'Yearly', 'Weekly', 'Daily']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}
