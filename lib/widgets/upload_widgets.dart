import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class UploadWidgets extends StatefulWidget {
  final TextEditingController titleController;
  final TextEditingController descriptionController;

  const UploadWidgets(
      {super.key,
      required this.titleController,
      required this.descriptionController});

  @override
  State<UploadWidgets> createState() => _UploadWidgetsState();
}

class _UploadWidgetsState extends State<UploadWidgets> {
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
              Navigator.pushNamed(context, '/addlocation');
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
        )
      ],
    );
  }
}
