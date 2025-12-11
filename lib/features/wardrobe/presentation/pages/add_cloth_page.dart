import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mm/features/wardrobe/presentation/bloc/wardrobe%20bloc/wardrobe_bloc.dart';

class AddClothPage extends StatefulWidget {
  final String userId;
  const AddClothPage({super.key, required this.userId});

  @override
  State<AddClothPage> createState() => _AddClothPageState();
}

class _AddClothPageState extends State<AddClothPage> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  String _selectedCategory = 'T-Shirt';

  final List<String> _categories = [
    'T-Shirt',
    'Shirt',
    'Trousers',
    'Dress',
    'Shoes',
    'Other',
  ];

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Cloth')),

      body: BlocListener<WardrobeBloc, WardrobeState>(
        listener: (context, state) {
          if (state is WardrobeErrorState) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          } else if (state is WardrobeLoadedState) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text("Item Added Sucessfully!"),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //Image Picker Area
                GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      builder: (_) => SafeArea(
                        child: Wrap(
                          children: [
                            ListTile(
                              leading: const Icon(Icons.photo_library),
                              title: const Text('Gallery'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.gallery);
                              },
                            ),
                            ListTile(
                              leading: const Icon(Icons.camera_alt),
                              title: const Text('Camera'),
                              onTap: () {
                                Navigator.pop(context);
                                _pickImage(ImageSource.camera);
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  child: Container(
                    height: 200,
                    decoration: BoxDecoration(
                      color: Colors.grey[200],
                      borderRadius: BorderRadius.circular(12.0),
                      border: Border.all(color: Colors.grey),
                    ),
                    child: _selectedImage != null
                        ? ClipRRect(
                            borderRadius: BorderRadius.circular(12.0),
                            child: Image.file(
                              _selectedImage!,
                              fit: BoxFit.cover,
                            ),
                          )
                        : const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.add_a_photo,
                                size: 50,
                                color: Colors.grey,
                              ),
                              SizedBox(height: 8.0),
                              Text(
                                'Tap to select an image',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 20.0),

                //Name Input
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(labelText: 'Cloth Name'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a name';
                    }
                    return null;
                  },
                ),

                SizedBox(height: 16.0),

                //Category Dropdown
                DropdownButtonFormField(
                  initialValue: _selectedCategory,
                  items: _categories.map((String category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
                  onChanged: (newValue) {
                    setState(() {
                      _selectedCategory = newValue!;
                    });
                  },
                ),

                const SizedBox(height: 30.0),

                //Save Button
                BlocBuilder<WardrobeBloc, WardrobeState>(
                  builder: (context, state) {
                    if (state is WardrobeLoadingState) {
                      return const CircularProgressIndicator();
                    }
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        fixedSize: Size(
                          MediaQuery.of(context).size.width - 50,
                          60,
                        ),
                      ),
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          if (_selectedImage == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Please select an image'),
                              ),
                            );
                            return;
                          }

                          context.read<WardrobeBloc>().add(
                            WardrobeAddClothingItemEvent(
                              userId: widget.userId,
                              name: _nameController.text,
                              category: _selectedCategory,
                              imageFile: _selectedImage!,
                            ),
                          );
                        }
                      },
                      child: const Text('Save Item'),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
