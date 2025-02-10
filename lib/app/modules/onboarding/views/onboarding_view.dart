import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/onboarding_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
// import '../../../widgets/navigation_with_animation.dart';

class OnboardingView extends GetView<OnboardingController> {
  const OnboardingView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final PageController pageController = PageController();
    final RxInt currentPage = 0.obs;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              flex: 3,
              child: PageView(
                controller: pageController,
                onPageChanged: (index) {
                  currentPage.value = index;
                },
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SvgPicture.asset(
                      'assets/images/different_Onboarding/Conversation-rafiki.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SvgPicture.asset(
                      'assets/images/different_Onboarding/Chatting-rafiki.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              ),
            ),
            // Page Indicators
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  2,
                  (index) => Obx(() => Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: currentPage.value == index
                              ? const Color(0xFF6C63FF)
                              : Colors.grey.shade300,
                        ),
                      )),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Obx(() => Text(
                          currentPage.value == 0
                              ? 'Connect and chat with\nfriends around the world'
                              : 'Share moments with your\nfriends instantly',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                    height: 1.3,
                                  ),
                        )),
                    const SizedBox(height: 12),
                    Obx(() => Text(
                          currentPage.value == 0
                              ? 'Start meaningful conversations anytime, anywhere'
                              : 'Stay connected with friends and family easily',
                          textAlign: TextAlign.center,
                          style:
                              Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    color: Colors.grey[600],
                                  ),
                        )),
                    // const Spacer(),
                    const SizedBox(height: 35),
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
            ),
          ],
        ),
      ),
    );
  }
}
