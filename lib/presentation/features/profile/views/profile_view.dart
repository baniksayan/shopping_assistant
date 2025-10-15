import 'package:flutter/material.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import '../../../../data/data_sources/local/hive_service.dart';
import '../../../../data/models/user_model.dart';
import '../../../../core/theme/app_themes.dart';
import '../../../../core/utils/location_service.dart';

class ProfileView extends StatefulWidget {
  final Function(AppTheme) onThemeChanged;
  final VoidCallback onProfileUpdated;

  const ProfileView({
    super.key,
    required this.onThemeChanged,
    required this.onProfileUpdated,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _pinCodeController = TextEditingController();
  final _cityController = TextEditingController();
  final _districtController = TextEditingController();
  final _stateController = TextEditingController();
  final _countryController = TextEditingController();
  
  UserModel? _user;
  bool _isLoading = false;
  bool _isLocationLoading = false;
  String? _profileImagePath;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() {
    _user = HiveService.getCurrentUser();
    if (_user != null) {
      setState(() {
        _firstNameController.text = _user!.firstName;
        _lastNameController.text = _user!.lastName;
        _pinCodeController.text = _user!.pinCode ?? '';
        _cityController.text = _user!.city ?? '';
        _districtController.text = _user!.district ?? '';
        _stateController.text = _user!.state ?? '';
        _countryController.text = _user!.country ?? '';
        _profileImagePath = _user!.profileImagePath;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    
    final ImageSource? source = await showDialog<ImageSource>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Choose Image Source'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Camera'),
              onTap: () => Navigator.pop(context, ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Gallery'),
              onTap: () => Navigator.pop(context, ImageSource.gallery),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _profileImagePath = image.path;
        });
        
        await HiveService.updateProfileImage(image.path);
        widget.onProfileUpdated();
      }
    }
  }

  Future<void> _autoDetectLocation() async {
    setState(() {
      _isLocationLoading = true;
    });

    final position = await LocationService.getCurrentLocation();

    if (position != null) {
      final address = await LocationService.getAddressFromCoordinates(
        position.latitude,
        position.longitude,
      );

      await HiveService.saveLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        address: address,
      );

      _loadUserData();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Location updated successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Unable to detect location'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }

    setState(() {
      _isLocationLoading = false;
    });
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      if (_user != null) {
        _user!.firstName = _firstNameController.text.trim();
        _user!.lastName = _lastNameController.text.trim();
        _user!.pinCode = _pinCodeController.text.trim();
        _user!.city = _cityController.text.trim();
        _user!.district = _districtController.text.trim();
        _user!.state = _stateController.text.trim();
        _user!.country = _countryController.text.trim();
        
        await _user!.save();
        
        widget.onProfileUpdated();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        }
      }

      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _pinCodeController.dispose();
    _cityController.dispose();
    _districtController.dispose();
    _stateController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: theme.primaryColor,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _saveProfile,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Profile Picture Section
              _buildProfilePictureSection(theme),
              
              const SizedBox(height: 32),
              
              // User Name Display
              Text(
                _user?.fullName ?? 'User',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: theme.primaryColor,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                _user?.email ?? '',
                style: TextStyle(
                  fontSize: 14,
                  color: theme.colorScheme.tertiary.withOpacity(0.7),
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Editable Fields Section
              _buildSectionTitle('Personal Information', theme),
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _firstNameController,
                label: 'First Name',
                icon: Icons.person_outline,
                theme: theme,
              ),
              
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _lastNameController,
                label: 'Last Name',
                icon: Icons.person_outline,
                theme: theme,
              ),
              
              const SizedBox(height: 24),
              
              // Read-Only Fields
              _buildSectionTitle('Contact Information', theme),
              const SizedBox(height: 16),
              
              _buildReadOnlyField(
                label: 'Phone Number',
                value: _user?.phoneNumber ?? '',
                icon: Icons.phone_outlined,
                theme: theme,
              ),
              
              const SizedBox(height: 16),
              
              _buildReadOnlyField(
                label: 'Email Address',
                value: _user?.email ?? '',
                icon: Icons.email_outlined,
                theme: theme,
              ),
              
              const SizedBox(height: 24),
              
              // Auto-Detect Location
              _buildSectionTitle('Location', theme),
              const SizedBox(height: 16),
              
              _buildAutoDetectLocationCard(theme),
              
              const SizedBox(height: 16),
              
              // Manual Location Fields
              _buildTextField(
                controller: _pinCodeController,
                label: 'Pin Code',
                icon: Icons.pin_drop_outlined,
                theme: theme,
                keyboardType: TextInputType.number,
              ),
              
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _cityController,
                label: 'City',
                icon: Icons.location_city_outlined,
                theme: theme,
              ),
              
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _districtController,
                label: 'District',
                icon: Icons.map_outlined,
                theme: theme,
              ),
              
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _stateController,
                label: 'State',
                icon: Icons.location_on_outlined,
                theme: theme,
              ),
              
              const SizedBox(height: 16),
              
              _buildTextField(
                controller: _countryController,
                label: 'Country',
                icon: Icons.public_outlined,
                theme: theme,
              ),
              
              const SizedBox(height: 32),
              
              // Save Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.primaryColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfilePictureSection(ThemeData theme) {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: theme.primaryColor, width: 3),
            boxShadow: [
              BoxShadow(
                color: theme.primaryColor.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 3,
              ),
            ],
          ),
          child: _profileImagePath != null && _profileImagePath!.isNotEmpty
              ? ClipOval(
                  child: Image.file(
                    File(_profileImagePath!),
                    fit: BoxFit.cover,
                  ),
                )
              : Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: theme.primaryColor,
                  ),
                  child: Center(
                    child: Text(
                      _user?.initials ?? 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 40,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: _pickImage,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: theme.primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: theme.colorScheme.tertiary,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ThemeData theme,
    TextInputType? keyboardType,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.primaryColor),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.primaryColor.withOpacity(0.3),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.primaryColor, width: 2),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter $label';
        }
        return null;
      },
    );
  }

  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
    required ThemeData theme,
  }) {
    return TextFormField(
      initialValue: value,
      enabled: false,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: theme.primaryColor.withOpacity(0.5)),
        filled: true,
        fillColor: Colors.grey.withOpacity(0.1),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: theme.primaryColor.withOpacity(0.2),
          ),
        ),
      ),
    );
  }

  Widget _buildAutoDetectLocationCard(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.primaryColor.withOpacity(0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.location_on,
                color: theme.primaryColor,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Auto-Detected Location',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: theme.colorScheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            _user?.address ?? 'No location detected',
            style: TextStyle(
              fontSize: 13,
              color: theme.colorScheme.tertiary.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isLocationLoading ? null : _autoDetectLocation,
              icon: _isLocationLoading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Icon(Icons.my_location, size: 18),
              label: Text(_isLocationLoading ? 'Detecting...' : 'Update Location'),
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
