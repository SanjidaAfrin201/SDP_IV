import 'dart:io';
import 'dart:typed_data'; // Import for Uint8List
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'sign_in_screen.dart'; // Import SignInScreen to navigate back

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController mobileNumberController = TextEditingController();
  final TextEditingController dateOfBirthController = TextEditingController();
  final TextEditingController nidNumberController = TextEditingController();
  final TextEditingController districtController = TextEditingController();
  final TextEditingController upazilaController = TextEditingController();
  final TextEditingController skillsController = TextEditingController();
  final TextEditingController primaryOccupationController = TextEditingController();
  final TextEditingController availableHoursController = TextEditingController();
  final TextEditingController expectedCompensationController = TextEditingController();
  final TextEditingController transportationController = TextEditingController();
  final TextEditingController educationController = TextEditingController();
  final TextEditingController companyNameController = TextEditingController();
  final TextEditingController businessRegNumberController = TextEditingController();
  final TextEditingController industrySectorController = TextEditingController();
  final TextEditingController companySizeController = TextEditingController();
  final TextEditingController officeLocationController = TextEditingController();

  String userType = 'Job Seeker';
  File? profileImage;
  File? nidImage;
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    fullNameController.dispose();
    mobileNumberController.dispose();
    dateOfBirthController.dispose();
    nidNumberController.dispose();
    districtController.dispose();
    upazilaController.dispose();
    skillsController.dispose();
    primaryOccupationController.dispose();
    availableHoursController.dispose();
    expectedCompensationController.dispose();
    transportationController.dispose();
    educationController.dispose();
    companyNameController.dispose();
    businessRegNumberController.dispose();
    industrySectorController.dispose();
    companySizeController.dispose();
    officeLocationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage({required bool isProfile}) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        if (isProfile) {
          profileImage = File(pickedFile.path);
        } else {
          nidImage = File(pickedFile.path);
        }
      });
    }
  }

  Future<String?> _uploadImage(File image, String bucket, String path) async {
    try {
      final List<int> imageBytes = await image.readAsBytes();

      // Check if file already exists and remove/upsert
      try {
        await supabase.storage.from(bucket).remove([path]);
      } catch (e) {
        // Ignore if file doesn't exist to be removed
        // print('Warning: Could not remove old file, perhaps it does not exist: ${e.toString()}'); // Removed print
      }

      final String? response = await supabase.storage.from(bucket).uploadBinary(
        path,
        Uint8List.fromList(imageBytes), // Convert List<int> to Uint8List
        fileOptions: const FileOptions(upsert: true), // Use upsert to overwrite if it somehow exists
      );

      if (response != null) {
        return supabase.storage.from(bucket).getPublicUrl(path);
      }
      return null;
    } catch (e) {
      _showErrorDialog('Image upload failed: ${e.toString()}');
      return null;
    }
  }


  Future<void> _signUp() async {
    setState(() => _isLoading = true);

    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;
    final confirmPassword = confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showErrorDialog('Email and password are required');
      setState(() => _isLoading = false);
      return;
    }

    if (!RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$').hasMatch(email)) {
      _showErrorDialog('Please enter a valid email address');
      setState(() => _isLoading = false);
      return;
    }

    if (password.length < 6) {
      _showErrorDialog('Password must be at least 6 characters');
      setState(() => _isLoading = false);
      return;
    }

    if (password != confirmPassword) {
      _showErrorDialog('Passwords do not match');
      setState(() => _isLoading = false);
      return;
    }

    try {
      // Sign up user with Supabase Auth
      final AuthResponse authResponse = await supabase.auth.signUp(email: email, password: password);
      final userId = authResponse.user?.id;

      if (userId == null) {
        _showErrorDialog('Sign up failed: Unable to create user. ${authResponse.session?.user?.email}');
        setState(() => _isLoading = false);
        return;
      }

      // Upload images if provided
      String? profileImageUrl;
      String? nidImageUrl;

      if (profileImage != null) {
        profileImageUrl = await _uploadImage(
          profileImage!,
          'profile-pictures',
          '$userId/profile.jpg',
        );
      }

      if (nidImage != null) {
        nidImageUrl = await _uploadImage(
          nidImage!,
          'nid_images', // Assuming this is the correct bucket name for NID images
          '$userId/nid_${DateTime.now().millisecondsSinceEpoch}.jpg', // Unique name for NID
        );
      }

      // Prepare user data
      final Map<String, dynamic> userData = {
        'id': userId,
        'full_name': fullNameController.text.trim(),
        'mobile_number': mobileNumberController.text.trim(),
        'email': email,
        'date_of_birth': dateOfBirthController.text.trim(),
        'nid_number': nidNumberController.text.trim(),
        'profile_image': profileImageUrl,
        'district': districtController.text.trim(),
        'upazila': upazilaController.text.trim(),
        'user_type': userType,
        'verification_status': 'pending', // Default status for NID verification
      };

      // Add user type specific fields
      if (userType == 'Job Seeker') {
        userData.addAll({
          'skills': skillsController.text.trim().split(',').map((e) => e.trim()).toList(),
          'primary_occupation': primaryOccupationController.text.trim(),
          'available_hours': availableHoursController.text.trim(),
          'expected_compensation': expectedCompensationController.text.trim(),
          'transportation': transportationController.text.trim(),
          'education': educationController.text.trim(),
        });
      } else if (userType == 'Employer') {
        userData.addAll({
          'company_name': companyNameController.text.trim(),
          'business_reg_number': businessRegNumberController.text.trim(),
          'industry_sector': industrySectorController.text.trim(),
          'company_size': companySizeController.text.trim(),
          'office_location': officeLocationController.text.trim(),
        });
      }

      // Update user data in the users table (initial entry created by trigger)
      await supabase.from('users').update(userData).eq('id', userId);

      // If NID image was uploaded, also create a record in nid_verifications table
      if (nidImageUrl != null) {
        await supabase.from('nid_verifications').insert({
          'user_id': userId,
          'nid_number': nidNumberController.text.trim(),
          'front_image_url': nidImageUrl, // Assuming you combine front/back into one image for signup for now
          'back_image_url': null, // Adjust if you collect separate images
          'verification_status': 'pending',
        });
      }


      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Sign up successful! Please verify your email and then sign in.')),
        );
        // Navigate to sign-in screen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
        );
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Sign up failed: ${e.toString()}');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor, // Use theme color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 30), // Use theme color
            const SizedBox(width: 10),
            Text('Error', style: Theme.of(context).textTheme.titleLarge), // Use theme text style
          ],
        ),
        content: Text(message, style: Theme.of(context).textTheme.bodyMedium), // Use theme text style
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK', style: TextStyle(color: Theme.of(context).primaryColor)), // Use theme color
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Theme.of(context).scaffoldBackgroundColor, Theme.of(context).colorScheme.surface], // Use theme colors
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top - MediaQuery.of(context).padding.bottom),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                        const SizedBox(height: 60),
                        FadeInDown(
                          duration: const Duration(milliseconds: 800),
                          child: Text(
                            'Sign Up to FlexPath',
                            style: Theme.of(context).textTheme.displaySmall?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                              shadows: [
                                Shadow(
                                  blurRadius: 10,
                                  color: Theme.of(context).primaryColor.withAlpha(77),
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 200),
                          child: TextField(
                            controller: emailController,
                            style: Theme.of(context).textTheme.bodyLarge,
                            decoration: InputDecoration(
                              labelText: 'Email *',
                              prefixIcon: Icon(Icons.email, color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 300),
                          child: TextField(
                            controller: passwordController,
                            obscureText: true,
                            style: Theme.of(context).textTheme.bodyLarge,
                            decoration: InputDecoration(
                              labelText: 'Password *',
                              prefixIcon: Icon(Icons.lock, color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 400),
                          child: TextField(
                            controller: confirmPasswordController,
                            obscureText: true,
                            style: Theme.of(context).textTheme.bodyLarge,
                            decoration: InputDecoration(
                              labelText: 'Confirm Password *',
                              prefixIcon: Icon(Icons.lock, color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 500),
                          child: TextField(
                            controller: fullNameController,
                            style: Theme.of(context).textTheme.bodyLarge,
                            decoration: InputDecoration(
                              labelText: 'Full Name',
                              prefixIcon: Icon(Icons.person, color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 600),
                          child: TextField(
                            controller: mobileNumberController,
                            style: Theme.of(context).textTheme.bodyLarge,
                            decoration: InputDecoration(
                              labelText: 'Mobile Number',
                              prefixIcon: Icon(Icons.phone, color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 700),
                          child: TextField(
                            controller: dateOfBirthController,
                            style: Theme.of(context).textTheme.bodyLarge,
                            decoration: InputDecoration(
                              labelText: 'Date of Birth (YYYY-MM-DD)',
                              prefixIcon: Icon(Icons.calendar_today, color: Theme.of(context).primaryColor),
                            ),
                            onTap: () async {
                              FocusScope.of(context).requestFocus(FocusNode()); // To prevent keyboard from appearing
                              DateTime? pickedDate = await showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime(1900),
                                lastDate: DateTime.now(),
                                builder: (context, child) {
                                  return Theme(
                                    data: ThemeData.dark().copyWith(
                                      colorScheme: ColorScheme.dark(
                                        primary: Theme.of(context).primaryColor, // Header background color
                                        onPrimary: Colors.white, // Header text color
                                        surface: Theme.of(context).cardColor, // Calendar background color
                                        onSurface: Colors.white, // Calendar text color
                                      ),
                                      textButtonTheme: TextButtonThemeData(
                                        style: TextButton.styleFrom(
                                          foregroundColor: Theme.of(context).primaryColor, // OK/Cancel button text color
                                        ),
                                      ),
                                    ),
                                    child: child!,
                                  );
                                },
                              );
                              if (pickedDate != null) {
                                dateOfBirthController.text = pickedDate.toIso8601String().split('T')[0]; // Format as YYYY-MM-DD
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 800),
                          child: TextField(
                            controller: nidNumberController,
                            style: Theme.of(context).textTheme.bodyLarge,
                            decoration: InputDecoration(
                              labelText: 'NID Number',
                              prefixIcon: Icon(Icons.credit_card, color: Theme.of(context).primaryColor),
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 900),
                          child: TextField(
                            controller: districtController,
                            style: Theme.of(context).textTheme.bodyLarge,
                            decoration: InputDecoration(
                              labelText: 'District',
                              prefixIcon: Icon(Icons.location_city, color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 1000),
                          child: TextField(
                            controller: upazilaController,
                            style: Theme.of(context).textTheme.bodyLarge,
                            decoration: InputDecoration(
                              labelText: 'Upazila',
                              prefixIcon: Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 1100),
                          child: DropdownButtonFormField<String>(
                            value: userType,
                            dropdownColor: Theme.of(context).cardColor, // Dropdown background
                            style: Theme.of(context).textTheme.bodyLarge,
                            items: ['Job Seeker', 'Employer']
                                .map((type) => DropdownMenuItem(value: type, child: Text(type, style: Theme.of(context).textTheme.bodyLarge)))
                                .toList(),
                            onChanged: (value) {
                              setState(() => userType = value!);
                            },
                            decoration: InputDecoration(
                              labelText: 'User Type *',
                              prefixIcon: Icon(Icons.person_pin, color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                        if (userType == 'Job Seeker') ...[
                          const SizedBox(height: 16),
                          FadeInUp(
                            duration: const Duration(milliseconds: 800),
                            delay: const Duration(milliseconds: 1200),
                            child: TextField(
                              controller: skillsController,
                              style: Theme.of(context).textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: 'Skills (comma-separated)',
                                prefixIcon: Icon(Icons.build, color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeInUp(
                            duration: const Duration(milliseconds: 800),
                            delay: const Duration(milliseconds: 1300),
                            child: TextField(
                              controller: primaryOccupationController,
                              style: Theme.of(context).textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: 'Primary Occupation',
                                prefixIcon: Icon(Icons.work, color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeInUp(
                            duration: const Duration(milliseconds: 800),
                            delay: const Duration(milliseconds: 1400),
                            child: TextField(
                              controller: availableHoursController,
                              style: Theme.of(context).textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: 'Available Hours',
                                prefixIcon: Icon(Icons.access_time, color: Theme.of(context).primaryColor),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeInUp(
                            duration: const Duration(milliseconds: 800),
                            delay: const Duration(milliseconds: 1500),
                            child: TextField(
                              controller: expectedCompensationController,
                              style: Theme.of(context).textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: 'Expected Compensation',
                                prefixIcon: Icon(Icons.attach_money, color: Theme.of(context).primaryColor),
                              ),
                              keyboardType: TextInputType.number,
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeInUp(
                            duration: const Duration(milliseconds: 800),
                            delay: const Duration(milliseconds: 1600),
                            child: TextField(
                              controller: transportationController,
                              style: Theme.of(context).textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: 'Transportation',
                                prefixIcon: Icon(Icons.directions_car, color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeInUp(
                            duration: const Duration(milliseconds: 800),
                            delay: const Duration(milliseconds: 1700),
                            child: TextField(
                              controller: educationController,
                              style: Theme.of(context).textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: 'Education',
                                prefixIcon: Icon(Icons.school, color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                        ],
                        if (userType == 'Employer') ...[
                          const SizedBox(height: 16),
                          FadeInUp(
                            duration: const Duration(milliseconds: 800),
                            delay: const Duration(milliseconds: 1200),
                            child: TextField(
                              controller: companyNameController,
                              style: Theme.of(context).textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: 'Company Name',
                                prefixIcon: Icon(Icons.business, color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeInUp(
                            duration: const Duration(milliseconds: 800),
                            delay: const Duration(milliseconds: 1300),
                            child: TextField(
                              controller: businessRegNumberController,
                              style: Theme.of(context).textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: 'Business Registration Number',
                                prefixIcon: Icon(Icons.description, color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeInUp(
                            duration: const Duration(milliseconds: 800),
                            delay: const Duration(milliseconds: 1400),
                            child: TextField(
                              controller: industrySectorController,
                              style: Theme.of(context).textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: 'Industry Sector',
                                prefixIcon: Icon(Icons.factory, color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeInUp(
                            duration: const Duration(milliseconds: 800),
                            delay: const Duration(milliseconds: 1500),
                            child: TextField(
                              controller: companySizeController,
                              style: Theme.of(context).textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: 'Company Size',
                                prefixIcon: Icon(Icons.group, color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          FadeInUp(
                            duration: const Duration(milliseconds: 800),
                            delay: const Duration(milliseconds: 1600),
                            child: TextField(
                              controller: officeLocationController,
                              style: Theme.of(context).textTheme.bodyLarge,
                              decoration: InputDecoration(
                                labelText: 'Office Location',
                                prefixIcon: Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 1800),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _pickImage(isProfile: true),
                                  style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                                    backgroundColor: MaterialStateProperty.resolveWith((states) => Theme.of(context).colorScheme.secondary),
                                  ),
                                  child: Text(
                                    profileImage == null ? 'Upload Profile Image' : 'Profile Image Selected',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () => _pickImage(isProfile: false),
                                  style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                                    backgroundColor: MaterialStateProperty.resolveWith((states) => Theme.of(context).colorScheme.secondary),
                                  ),
                                  child: Text(
                                    nidImage == null ? 'Upload NID Image' : 'NID Image Selected',
                                    style: Theme.of(context).textTheme.labelLarge?.copyWith(fontSize: 12),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 1900),
                          child: ZoomIn(
                            duration: const Duration(milliseconds: 300),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signUp,
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                'Sign Up',
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: FadeInLeft(
                  duration: const Duration(milliseconds: 800),
                  child: IconButton(
                    icon: Icon(Icons.arrow_back, color: Theme.of(context).textTheme.bodyLarge?.color, size: 30),
                    onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const SignInScreen())),
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
