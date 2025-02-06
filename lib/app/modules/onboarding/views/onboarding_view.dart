import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';
// import '../../../widgets/navigation_with_animation.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFCFCFC),
      body: Stack(
        children: [
          // Background container to cover full height
          Container(
            width: double.infinity,
            height: double.infinity,
            color: Colors.white,
          ),
          // Content
          Column(
            children: [
              // Full width image from top
              Container(
                width: double.infinity,
                height: MediaQuery.of(context).size.height * 0.60,
                decoration: const BoxDecoration(
                  color: Colors.white,
                ),
                child: Image.asset(
                  'assets/images/onboard.png',
                  fit: BoxFit.contain,
                ),
              ),
              SizedBox(height: 70),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Title text
                    Text(
                      'Enjoy the new experience of\nchating with global friends',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                            height: 1.3,
                          ),
                    ),
                    const SizedBox(height: 12),
                    // Subtitle text
                    Text(
                      'Connect people around the world for free',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                    const SizedBox(height: 32),
                    // Google Sign in button
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: Obx(() => ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF6C63FF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        onPressed: controller.isLoading.value 
                            ? null 
                            : () => controller.signInWithGoogle(),
                        icon: controller.isLoading.value
                            ? const SizedBox.shrink()
                            : Image.asset(
                                'assets/images/googleLogo.png',
                                height: 24,
                              ),
                        label: controller.isLoading.value
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Sign in with Google',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      )),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
