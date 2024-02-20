import 'package:e_estates/widgets/map_widget.dart';
import 'package:flutter/material.dart';

class AddLocation extends StatefulWidget {
  const AddLocation({super.key});

  @override
  State<AddLocation> createState() => _AddLocationState();
}

class _AddLocationState extends State<AddLocation> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Location'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            TextFormField(),
            Container(
              height: 300,
              child: LocationPickerMap(),
            )
          ],
        ),
      ),
    );
  }
}
