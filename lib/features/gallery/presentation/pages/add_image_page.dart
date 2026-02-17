import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mm/core/theme/app_theme.dart';
import 'package:mm/features/gallery/presentation/bloc/gallery_bloc.dart';

class AddImagePage extends StatefulWidget {
  final String userId;
  const AddImagePage({super.key, required this.userId});

  @override
  State<AddImagePage> createState() => _AddImagePageState();
}

class _AddImagePageState extends State<AddImagePage> {
  final _poseNameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  String _selectedPose = 'Front View';

  final List<Map<String, dynamic>> _poseTypes = [
    {'name': 'Front View', 'icon': Icons.person},
    {'name': 'Side View', 'icon': Icons.person_outline},
    {'name': 'Back View', 'icon': Icons.person_pin},
    {'name': 'Full Body', 'icon': Icons.accessibility_new},
    {'name': 'Upper Body', 'icon': Icons.face},
    {'name': 'Custom', 'icon': Icons.edit},
  ];

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: source,
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 90,
    );

    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  void _showImageSourceSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              "Choose Image Source",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryColor,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.photo_library_outlined,
                  label: "Gallery",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.gallery);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.camera_alt_outlined,
                  label: "Camera",
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage(ImageSource.camera);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.accentColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 32, color: AppTheme.primaryColor),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Custom App Bar
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: const Icon(
                        Icons.arrow_back_ios_new,
                        size: 18,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Text(
                      "Add New Pose",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Content
            Expanded(
              child: BlocListener<GalleryBloc, GalleryState>(
                listener: (context, state) {
                  if (state is GalleryErrorState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(state.message),
                        backgroundColor: AppTheme.secondaryColor,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                  } else if (state is GalleryLoadedState) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Pose added successfully!"),
                        backgroundColor: Colors.green.shade600,
                        behavior: SnackBarBehavior.floating,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    );
                    Navigator.pop(context);
                  }
                },
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Image Picker
                        GestureDetector(
                          onTap: _showImageSourceSheet,
                          child: Container(
                            height: 260,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: _selectedImage != null
                                ? Stack(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: Image.file(
                                          _selectedImage!,
                                          width: double.infinity,
                                          height: double.infinity,
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                      Positioned(
                                        top: 12,
                                        right: 12,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _selectedImage = null;
                                            });
                                          },
                                          child: Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.1),
                                                  blurRadius: 8,
                                                ),
                                              ],
                                            ),
                                            child: const Icon(
                                              Icons.close,
                                              size: 20,
                                              color: AppTheme.secondaryColor,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  )
                                : Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(16),
                                        decoration: BoxDecoration(
                                          color: AppTheme.accentColor,
                                          borderRadius: BorderRadius.circular(
                                            16,
                                          ),
                                        ),
                                        child: const Icon(
                                          Icons.add_a_photo_outlined,
                                          size: 40,
                                          color: AppTheme.primaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      const Text(
                                        "Tap to add your photo",
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        "Choose a clear full-body or upper-body photo",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: AppTheme.textLight,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        ),

                        const SizedBox(height: 28),

                        // Pose Type Selection
                        const Text(
                          "Pose Type",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: _poseTypes.map((pose) {
                            final isSelected = _selectedPose == pose['name'];
                            return GestureDetector(
                              onTap: () {
                                setState(() {
                                  _selectedPose = pose['name'];
                                  if (pose['name'] != 'Custom') {
                                    _poseNameController.text = pose['name'];
                                  } else {
                                    _poseNameController.clear();
                                  }
                                });
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 12,
                                ),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryColor
                                      : AppTheme.accentColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      pose['icon'],
                                      size: 18,
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.textSecondary,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      pose['name'],
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white
                                            : AppTheme.textPrimary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        const SizedBox(height: 24),

                        // Custom Pose Name (only if Custom is selected)
                        if (_selectedPose == 'Custom') ...[
                          const Text(
                            "Custom Pose Name",
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textSecondary,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _poseNameController,
                            style: const TextStyle(
                              fontSize: 16,
                              color: AppTheme.textPrimary,
                            ),
                            decoration: InputDecoration(
                              hintText: "Enter a name for this pose",
                              hintStyle: TextStyle(color: AppTheme.textLight),
                              prefixIcon: const Icon(
                                Icons.edit_outlined,
                                color: AppTheme.textSecondary,
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 18,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade200,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (_selectedPose == 'Custom' &&
                                  (value == null || value.isEmpty)) {
                                return 'Please enter a pose name';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 20),
                        ],

                        // Description
                        const Text(
                          "Description (Optional)",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.textSecondary,
                            letterSpacing: 0.5,
                          ),
                        ),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _descriptionController,
                          maxLines: 2,
                          style: const TextStyle(
                            fontSize: 16,
                            color: AppTheme.textPrimary,
                          ),
                          decoration: InputDecoration(
                            hintText: "E.g., Casual outfit, Standing pose",
                            hintStyle: TextStyle(color: AppTheme.textLight),
                            prefixIcon: const Icon(
                              Icons.description_outlined,
                              color: AppTheme.textSecondary,
                            ),
                            filled: true,
                            fillColor: Colors.white,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 18,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: BorderSide(
                                color: Colors.grey.shade200,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: AppTheme.primaryColor,
                                width: 2,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        // Submit Button
                        BlocBuilder<GalleryBloc, GalleryState>(
                          builder: (context, state) {
                            final isLoading = state is GalleryLoadingState;
                            return SizedBox(
                              width: double.infinity,
                              height: 56,
                              child: ElevatedButton.icon(
                                onPressed: isLoading
                                    ? null
                                    : () {
                                        if (_selectedImage == null) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: const Text(
                                                "Please select an image",
                                              ),
                                              backgroundColor:
                                                  AppTheme.secondaryColor,
                                              behavior:
                                                  SnackBarBehavior.floating,
                                              shape: RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                              ),
                                            ),
                                          );
                                          return;
                                        }
                                        if (_formKey.currentState!.validate()) {
                                          final poseName =
                                              _selectedPose == 'Custom'
                                              ? _poseNameController.text.trim()
                                              : _selectedPose;
                                          context.read<GalleryBloc>().add(
                                            GalleryAddImageEvent(
                                              userId: widget.userId,
                                              poseName: poseName,
                                              description:
                                                  _descriptionController.text
                                                      .trim()
                                                      .isEmpty
                                                  ? null
                                                  : _descriptionController.text
                                                        .trim(),
                                              imageFile: _selectedImage!,
                                            ),
                                          );
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTheme.primaryColor,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                icon: isLoading
                                    ? const SizedBox.shrink()
                                    : const Icon(
                                        Icons.cloud_upload_outlined,
                                        color: Colors.white,
                                      ),
                                label: isLoading
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        "Upload Pose",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                        ),
                                      ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _poseNameController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}
