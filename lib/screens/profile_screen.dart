import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/user_provider.dart';
import '../widgets/location_display.dart';
import 'responder_registration_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _bloodGroupController = TextEditingController();
  final _emergencyContactController = TextEditingController();

  final List<String> _bloodGroups = ['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-'];
  String? _selectedBloodGroup;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.userProfile != null) {
      _nameController.text = userProvider.userProfile!.name;
      _phoneController.text = userProvider.userProfile!.phoneNumber;
      _emergencyContactController.text = userProvider.userProfile!.emergencyContact;
      if (_bloodGroups.contains(userProvider.userProfile!.bloodGroup)) {
        _selectedBloodGroup = userProvider.userProfile!.bloodGroup;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bloodGroupController.dispose();
    _emergencyContactController.dispose();
    super.dispose();
  }

  void _saveProfile() {
    if (_formKey.currentState!.validate()) {
      final newProfile = UserProfile(
        name: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        bloodGroup: _selectedBloodGroup ?? '',
        emergencyContact: _emergencyContactController.text.trim(),
        role: 'User', // Default role for standard profiles
      );

      Provider.of<UserProvider>(context, listen: false).saveProfile(newProfile).then((_) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully')),
        );
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
      ),
      body: Consumer<UserProvider>(
        builder: (context, userProvider, child) {
          if (userProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.person_pin,
                    size: 80,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 24),
                  
                  // Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your name';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Phone Number Field
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Phone Number',
                      prefixIcon: Icon(Icons.phone),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Blood Group Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedBloodGroup,
                    decoration: const InputDecoration(
                      labelText: 'Blood Group',
                      prefixIcon: Icon(Icons.bloodtype),
                      border: OutlineInputBorder(),
                    ),
                    items: _bloodGroups.map((group) {
                      return DropdownMenuItem(
                        value: group,
                        child: Text(group),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedBloodGroup = newValue;
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please select your blood group';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Emergency Contact Field
                  TextFormField(
                    controller: _emergencyContactController,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Emergency Contact Number',
                      prefixIcon: Icon(Icons.contact_phone),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter an emergency contact number';
                      }
                      return null;
                    },
                  ),
                  // Removed Role Dropdown - this is now a dedicated tab in HomeScreen
                  const SizedBox(height: 32),
                  
                  // Save Button
                  ElevatedButton(
                    onPressed: _saveProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Save Profile',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // GPS Coordinates Section (Moved from Home Screen)
                  const LocationDisplay(),
                  
                  const SizedBox(height: 32),
                  const Divider(thickness: 1),
                  const SizedBox(height: 16),
                  
                  // Volunteering Action
                  const Text(
                    'Additional Options',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ListTile(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.blue.withOpacity(0.3), width: 1),
                    ),
                    tileColor: Colors.blue.shade50,
                    leading: const Icon(Icons.volunteer_activism, color: Colors.blue, size: 30),
                    title: Text(
                      'Volunteer as Responder',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    subtitle: const Text('Medical pros: register to help others'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const ResponderRegistrationScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
