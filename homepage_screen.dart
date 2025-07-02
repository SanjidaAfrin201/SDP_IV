import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';

class HomepageScreen extends StatelessWidget {
  const HomepageScreen({super.key});

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
              Column(
                children: [
                  // Main content centered in the middle of the screen
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          FadeInDown(
                            duration: const Duration(milliseconds: 800),
                            child: Text(
                              'FlexPath',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
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
                            child: ZoomIn(
                              duration: const Duration(milliseconds: 300),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/signIn');
                                },
                                icon: const Icon(Icons.login, color: Colors.white, size: 20),
                                label: const Text(
                                  'Sign In',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                                  backgroundColor: MaterialStateProperty.resolveWith((states) => Theme.of(context).primaryColor),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          FadeInUp(
                            duration: const Duration(milliseconds: 800),
                            delay: const Duration(milliseconds: 300),
                            child: ZoomIn(
                              duration: const Duration(milliseconds: 300),
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/signUp');
                                },
                                icon: const Icon(Icons.person_add, color: Colors.white, size: 20),
                                label: const Text(
                                  'Sign Up',
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                style: Theme.of(context).elevatedButtonTheme.style?.copyWith(
                                  backgroundColor: MaterialStateProperty.resolveWith((states) => Theme.of(context).colorScheme.secondary),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Footer at the bottom
                  Column(
                    children: [
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 400),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Theme.of(context).cardColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  title: Row(
                                    children: [
                                      Icon(Icons.info, color: Theme.of(context).primaryColor, size: 30),
                                      const SizedBox(width: 10),
                                      Text('About Us', style: Theme.of(context).textTheme.titleLarge),
                                    ],
                                  ),
                                  content: Text(
                                    'FlexPath is a mobile-first platform designed to connect workers and employers for flexible, short-term gigs. Focused on the unique needs of Bangladesh, it provides an accessible solution for individuals looking to monetize their idle hours while giving employers access to a pool of local talent for micro-tasks. Whether you\'re a student looking for part-time work, a rural artisan seeking to showcase your crafts, or a small business in need of quick assistance, FlexPath bridges the gap. With features like job feeds, user profiles, real-time messaging, and local payment integration through Bkash, FlexPath aims to redefine the gig economy by offering a simple, secure, and empowering platform for Bangladesh’s diverse workforce.',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Close', style: TextStyle(color: Theme.of(context).primaryColor)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Bounce(
                            duration: const Duration(milliseconds: 500),
                            child: Text(
                              'About Us',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      FadeInUp(
                        duration: const Duration(milliseconds: 800),
                        delay: const Duration(milliseconds: 500),
                        child: GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor: Theme.of(context).cardColor,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  title: Row(
                                    children: [
                                      Icon(Icons.description, color: Theme.of(context).primaryColor, size: 30),
                                      const SizedBox(width: 10),
                                      Text('Terms & Conditions', style: Theme.of(context).textTheme.titleLarge),
                                    ],
                                  ),
                                  content: SingleChildScrollView(
                                    child: Text(
                                      '''Acceptance of Terms\nBy accessing or using the FlexPath application, you agree to comply with and be bound by the following terms and conditions. If you do not agree with these terms, do not use the App.\n\nUser Registration\nUsers must provide accurate information during registration. You agree to keep your login credentials confidential and notify FlexPath immediately in case of any unauthorized use of your account.\n\nPrivacy Policy\nYour privacy is important to us. FlexPath will collect personal information only as needed for providing the services. By using the App, you consent to the collection and use of your information as outlined in our Privacy Policy.\n\nUser Responsibilities\nFor Workers: You agree to provide truthful and complete information about your skills, availability, and work history. You are responsible for managing your job applications and ensuring the quality of your work.\nFor Employers: You are responsible for providing accurate job descriptions and fair compensation. You agree to treat workers respectfully and follow the applicable labor laws.\n\nProhibited Activities\nYou must not:\n- Engage in unlawful or fraudulent activities.\n- Post jobs that violate the rights of others or are misleading.\n- Use the App to harass, threaten, or discriminate against any user.\n\nPayments\nFlexPath integrates with Bkash and other local payment methods to ensure secure transactions. You agree to use these services responsibly. All payments are processed according to the platform’s guidelines.\n\nRating and Reviews\nBoth workers and employers are encouraged to leave ratings and reviews after completing a task. These reviews should be honest, and FlexPath reserves the right to remove any inappropriate or offensive feedback.\n\nIntellectual Property\nAll content provided by FlexPath, including logos, designs, and software, remains the property of FlexPath. You are granted a limited, non-transferable license to use the App in accordance with these terms.\n\nLimitation of Liability\nFlexPath will not be liable for any damages resulting from the use or inability to use the App. We make no guarantees regarding the availability or quality of jobs posted or completed.\n\nModifications to Terms\nFlexPath reserves the right to update or modify these Terms and Conditions at any time. Any changes will be posted on the App, and your continued use will indicate acceptance of the updated terms.\n\nTermination\nFlexPath reserves the right to suspend or terminate your account for violation of these terms, without prior notice.\n\nGoverning Law\nThese Terms and Conditions are governed by the laws of Bangladesh. Any disputes will be resolved in the appropriate courts in Bangladesh.\n\nFor more details or inquiries, please contact FlexPath support at monekostomathanosto@gmail.com''',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Close', style: TextStyle(color: Theme.of(context).primaryColor)),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Bounce(
                            duration: const Duration(milliseconds: 500),
                            child: Text(
                              'Terms & Conditions',
                              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                decoration: TextDecoration.underline,
                                color: Theme.of(context).primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}