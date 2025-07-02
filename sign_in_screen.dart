import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:animate_do/animate_do.dart';
import 'main.dart'; // Import main.dart to use FlexPathApp.navigateToScreen

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final SupabaseClient supabase = Supabase.instance.client;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController forgotPasswordEmailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    forgotPasswordEmailController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (emailController.text.trim().isEmpty) {
      _showErrorDialog('Please enter your email.');
      return;
    }
    if (passwordController.text.isEmpty) {
      _showErrorDialog('Please enter your password.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final AuthResponse response = await supabase.auth.signInWithPassword(
        email: emailController.text.trim().toLowerCase(),
        password: passwordController.text,
      );
      if (!mounted) return;
      if (response.user != null) {
        // Fetch user type after successful login
        final userTypeResponse = await supabase
            .from('users')
            .select('user_type')
            .eq('id', response.user!.id)
            .maybeSingle();

        final userType = userTypeResponse?['user_type'] as String?;
        print('Logged in userType: $userType');

        if (userType == 'Employer') {
          FlexPathApp.navigateToScreen(context, '/dashboard'); // Navigate to employer dashboard
        } else if (userType == 'Job Seeker') {
          FlexPathApp.navigateToScreen(context, '/jobFeed'); // Navigate to job feed for job seekers
        } else if (userType == 'Admin') { // Handle Admin user type
          FlexPathApp.navigateToScreen(context, '/adminDashboard'); // Navigate to admin dashboard
        }
        else {
          // Fallback or handle unknown user types
          FlexPathApp.navigateToScreen(context, '/homepage');
        }
      } else {
        _showErrorDialog('Sign in failed: Invalid credentials');
      }
    } on AuthException catch (e) {
      if (!mounted) return;
      if (e.message.toLowerCase().contains('invalid login credentials')) {
        _showErrorDialog('Invalid email or password. Please try again.');
      } else {
        _showErrorDialog('Sign in failed: ${e.message}');
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('An unexpected error occurred: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  // Revised: This method now sends a password reset email
  Future<void> _sendPasswordResetEmail() async {
    final email = forgotPasswordEmailController.text.trim().toLowerCase();

    if (email.isEmpty) {
      if (!mounted) return;
      _showErrorDialog('Please enter your email address.');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await supabase.auth.resetPasswordForEmail(
        email,
        // Optional: specify a redirect URL after reset (e.g., your app's deep link)
        // redirectTo: 'io.supabase.flutterquickstart://login-callback/',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Password reset email sent to $email. Please check your inbox.')),
        );
        Navigator.pop(context); // Close the dialog
      }
    } catch (e) {
      if (!mounted) return;
      _showErrorDialog('Error sending password reset email: ${e.toString()}');
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

  void _showForgotPasswordDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardColor, // Use theme color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: Text('Reset Password', style: Theme.of(context).textTheme.titleLarge), // Use theme text style
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: forgotPasswordEmailController,
                style: Theme.of(context).textTheme.bodyLarge, // Use theme text style
                decoration: InputDecoration(
                  labelText: 'Email',
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Theme.of(context).textTheme.bodyMedium?.color)), // Use theme text style
          ),
          ElevatedButton(
            onPressed: _isLoading ? null : _sendPasswordResetEmail, // Call the revised method
            child: _isLoading
                ? const CircularProgressIndicator(color: Colors.white)
                : const Text('Send Reset Email'),
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
                      mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const SizedBox(height: 60),
                        FadeInDown(
                          duration: const Duration(milliseconds: 800),
                          child: Text(
                            'Sign In to FlexPath',
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
                              labelText: 'Email',
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
                              labelText: 'Password',
                              prefixIcon: Icon(Icons.lock, color: Theme.of(context).primaryColor),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 400),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: GestureDetector(
                              onTap: _showForgotPasswordDialog,
                              child: Bounce(
                                duration: const Duration(milliseconds: 500),
                                child: Text(
                                  'Forgot Password?',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.w600,
                                    decoration: TextDecoration.underline,
                                    color: Theme.of(context).primaryColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                        FadeInUp(
                          duration: const Duration(milliseconds: 800),
                          delay: const Duration(milliseconds: 500),
                          child: ZoomIn(
                            duration: const Duration(milliseconds: 300),
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _signIn,
                              child: _isLoading
                                  ? const CircularProgressIndicator(color: Colors.white)
                                  : const Text(
                                'Sign In',
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
                    onPressed: () => Navigator.pushReplacementNamed(context, '/homepage'),
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