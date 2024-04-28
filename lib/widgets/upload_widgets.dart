import 'dart:convert';

import 'package:dropdown_search/dropdown_search.dart';
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
      required this.highlightedPrefrencesButton});

  @override
  State<UploadWidgets> createState() => _UploadWidgetsState();
}

class _UploadWidgetsState extends State<UploadWidgets> {
  bool amanitiesChecker = false;
  bool prefrencesChecker = false;
  bool isStudent = false;
  List<College> colleges = [];
  College? selectedCollege;
  String? selectedCourse;
  String? paymentFrequency = 'Monthly';
  List<String> selectedItems = [];
  List<String> selectedPreference = [];
  String dropdownValue = 'Monthly';
  String lableText = "hello";

  @override
  void initState() {
    super.initState();
    loadColleges();
  }

  void loadColleges() async {
    try {
      final String response =
          await rootBundle.loadString('assets/kathmandu_college.json');
      final data = json.decode(response);
      var collegeList = data['colleges'] as List;
      colleges = collegeList.map((c) => College.fromJson(c)).toList();
      if (colleges.isNotEmpty) {
        selectedCollege = colleges[0];
      }
    } catch (e) {
      // Handle the error appropriately
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
              checkColor: Colors.black,
              activeColor: Colors.blue,
              value: isStudent,
              onChanged: (bool? newValue) {
                setState(() {
                  isStudent = newValue!;
                  selectedCollege = null;
                  selectedCourse = null;
                });
              },
            ),
          ],
        ),
        if (isStudent) ...[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (BuildContext context) {
                        return Container(
                          padding: const EdgeInsets.all(8.0),
                          height: MediaQuery.of(context).size.height * 0.5,
                          child: ListView.builder(
                            itemCount: colleges.length,
                            itemBuilder: (BuildContext context, int index) {
                              return ListTile(
                                title: Text(colleges[index].name),
                                onTap: () {
                                  setState(() {
                                    selectedCollege = colleges[index];
                                    selectedCourse =
                                        null; // Reset the course selection
                                    Navigator.pop(
                                        context); // Close the bottom sheet
                                  });
                                },
                              );
                            },
                          ),
                        );
                      },
                    );
                  },
                  child: Text(selectedCollege?.name ?? 'Select College'),
                ),
                if (selectedCollege != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text("Selected College: ${selectedCollege?.name}"),
                  )
                ]
              ],
            ),
          ),
          if (selectedCollege != null &&
              (selectedCollege!.courses.isNotEmpty)) ...[
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DropdownSearch<String>(
                    dropdownSearchDecoration: const InputDecoration(
                      labelText: "Select Courses",
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 15,
                      ),
                    ),
                    items: selectedCollege!.courses,
                    dropdownBuilder: (context, selectedCourse) {
                      return Text(
                        selectedCourse ?? "",
                        style: const TextStyle(
                            color: Colors.grey), // Custom playful text style
                      );
                    },
                    onChanged: (String? newValue) {
                      setState(() {
                        selectedCourse = newValue;
                      });
                    },
                    selectedItem: selectedCourse,
                  ),
                ],
              ),
            ),
          ] else if (selectedCollege != null &&
              selectedCollege!.courses.isEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(8),
              child: Text("No courses available for this college"),
            )
          ],
          if (isStudent && selectedCollege != null && selectedCourse != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: ElevatedButton(
                onPressed: () {
                  // Implement your submission logic here
                  print('Selected College: ${selectedCollege?.name}');
                  print('Selected Course: $selectedCourse');
                },
                child: Text('Submit'),
              ),
            ),
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
