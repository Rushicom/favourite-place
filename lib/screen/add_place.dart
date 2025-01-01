import 'package:favourite_places/models/place.dart';
import 'package:favourite_places/widget/image_input.dart';
import 'package:favourite_places/widget/location_input.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:favourite_places/providers/user_places.dart';

class AddPlaceScreen extends ConsumerStatefulWidget {
  const AddPlaceScreen({super.key});

  @override
  ConsumerState<AddPlaceScreen> createState() {
    return _AddPlaceScreenState();
  }
}

class _AddPlaceScreenState extends ConsumerState<AddPlaceScreen> {
  final _titleController = TextEditingController();
  File? _selectedImage;
  PlaceLocation? _selectedLocation;
  void _savePlace() {
    final enteredTitle = _titleController.text;
    if (enteredTitle.isEmpty || _selectedImage == null || _selectedLocation == null) {
      return;
    }

    ref
        .read(userPlacesProvider.notifier)
        .addPlace(enteredTitle, _selectedImage!,_selectedLocation!);

    Navigator.of(context).pop(); // back to the main screen
  }

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add new Place'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
                decoration: const InputDecoration(labelText: 'Title'),
                controller: _titleController,
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onSurface)),
            const SizedBox(
              height: 10,
            ),
            ImageInput(
              onPickImage: (image) {// it is the photo constructor function call
                _selectedImage = image;
              },
            ),
           const SizedBox(height: 10,),
           LocationInput(onSelectLocation: (location) {
             _selectedLocation = location;
           },),
            const SizedBox(
              height: 16,
            ),
            ElevatedButton.icon(
              onPressed: _savePlace,
              icon: const Icon(Icons.add),
              label: const Text('Add Place'),
            ),
          ],
        ),
      ),
    );
  }
}
