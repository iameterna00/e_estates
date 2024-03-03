import 'package:e_estates/widgets/home_amanities.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadWidgets extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;
  final TextEditingController priceController;
  final Function saveMystate;
  final bool highlightLocationButton;
  final Function(String?) onPaymentFrequencyChanged;
  final Function(List<String>) homeAminities;

  const UploadWidgets(
      {super.key,
      required this.titleController,
      required this.descriptionController,
      required this.saveMystate,
      required this.priceController,
      required this.highlightLocationButton,
      required this.onPaymentFrequencyChanged,
      required this.homeAminities});

  @override
  State<UploadWidgets> createState() => _UploadWidgetsState();
}

class _UploadWidgetsState extends State<UploadWidgets> {
  String? paymentFrequency = 'Monthly';
  List<String> selectedItems = [];
  String dropdownValue = 'Monthly';
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: TextFormField(
            controller: widget.titleController,
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
          decoration: InputDecoration(
              hintText: 'Description',
              hintStyle: GoogleFonts.raleway(
                fontSize: 15,
              ),
              border: InputBorder.none),
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
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                  ],
                )),
          ),
        ),
        TextButton(
          onPressed: () {
            showModalBottomSheet(
                context: context,
                //  isScrollControlled: true,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                    return Column(
                      children: [
                        const SizedBox(
                          height: 45,
                          child: Icon(Icons.drag_handle),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height / 2,
                          width: MediaQuery.of(context).size.width,
                          child: SingleChildScrollView(
                            child: Column(
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
                                homeAmanities(selectedItems: selectedItems),
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: ElevatedButton(
                                    onPressed: () {
                                      widget.homeAminities(selectedItems);
                                    },
                                    child: Text('Share'),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  });
                });
          },
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero,
            alignment: Alignment.centerLeft,
            backgroundColor: Colors.transparent,
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
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                ],
              )),
        ),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: TextButton(
            onPressed: () {},
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              alignment: Alignment.centerLeft,
              backgroundColor: Colors.transparent,
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
                    const Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                    ),
                  ],
                )),
          ),
        ),
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
                keyboardType: TextInputType.numberWithOptions(decimal: true),
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
