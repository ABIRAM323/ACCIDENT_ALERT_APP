import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user_profile.dart';
import '../providers/user_provider.dart';

class ResponderRegistrationScreen extends StatefulWidget {
  const ResponderRegistrationScreen({super.key});

  @override
  State<ResponderRegistrationScreen> createState() => _ResponderRegistrationScreenState();
}

class _ResponderRegistrationScreenState extends State<ResponderRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();

  final List<String> _roles = ['Doctor', 'Nurse', 'Ambulance Driver'];
  String _selectedRole = 'Doctor';
  bool _isRegistering = false;

  @override
  void initState() {
    super.initState();
    _loadInitialRole();
  }

  void _loadInitialRole() {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    if (userProvider.userProfile != null) {
      if (_roles.contains(userProvider.userProfile!.role)) {
        _selectedRole = userProvider.userProfile!.role;
      }
    }
  }

  void _registerAsResponder() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isRegistering = true;
      });

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final currentProfile = userProvider.userProfile;

      if (currentProfile != null) {
        // Upgrade the existing local profile's role to the medical role they selected 
        // which triggers the UserProvider to submit their coordinates straight to Firebase.
        final upgradedProfile = UserProfile(
          name: currentProfile.name,
          phoneNumber: currentProfile.phoneNumber,
          bloodGroup: currentProfile.bloodGroup,
          emergencyContact: currentProfile.emergencyContact,
          role: _selectedRole,
        );

        await userProvider.saveProfile(upgradedProfile);

        if (!mounted) return;
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Successfully Registered as a Responder!')),
        );
        
        Navigator.pop(context);
      } else {
        setState(() {
          _isRegistering = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please complete your User Profile first!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Volunteer as Responder'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 2,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(
                Icons.medical_services,
                size: 80,
                color: Colors.blue,
              ),
              const SizedBox(height: 24),
              const Text(
                'Help Your Community in Need',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                'By registering as an emergency responder, your contact information will be securely made available to nearby citizens in the event of an accident or emergency. We will collect your active location continuously to facilitate rapid deployment.',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[700],
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              
              const Text(
                'Select Your Qualification:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),

              // Role Dropdown
              DropdownButtonFormField<String>(
                value: _selectedRole,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.work),
                  border: OutlineInputBorder(),
                ),
                items: _roles.map((role) {
                  return DropdownMenuItem(
                    value: role,
                    child: Text(role),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _selectedRole = newValue;
                    });
                  }
                },
              ),
              const SizedBox(height: 32),
              
              // Register Button
              ElevatedButton(
                onPressed: _isRegistering ? null : _registerAsResponder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _isRegistering 
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  : const Text(
                  'Register & Enable Location Sharing',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
