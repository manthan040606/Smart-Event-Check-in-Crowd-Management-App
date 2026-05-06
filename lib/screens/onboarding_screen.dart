import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme.dart';
import 'auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingData> _pages = [
    OnboardingData(
      title: "Hello User!!",
      subtitle: "Let's quickly go through the highlights of our app.",
      description: "Our app provides a platform where anyone can organize and attend events.",
      icon: Icons.celebration_rounded,
    ),
    OnboardingData(
      title: "As a Host...",
      subtitle: "You can..",
      description: "Effortlessly organize events on your device with a stress-free form.",
      icon: Icons.event_note_rounded,
    ),
    OnboardingData(
      title: "As a Host...",
      subtitle: "You can..",
      description: "During event hosting, you can pinpoint the event location on a map.",
      icon: Icons.map_rounded,
    ),
    OnboardingData(
      title: "As an Attendee...",
      subtitle: "You can..",
      description: "Quickly register for events you're interested in and receive a personalized QR code.",
      icon: Icons.qr_code_rounded,
    ),
  ];

  void _finishOnboarding() async {
    final box = await Hive.openBox('settings');
    await box.put('onboarding_complete', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                itemCount: _pages.length,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemBuilder: (context, index) {
                  return _buildPage(_pages[index]);
                },
              ),
            ),
            _buildBottomControls(),
          ],
        ),
      ),
    );
  }

  Widget _buildPage(OnboardingData data) {
    return Padding(
      padding: const EdgeInsets.all(40.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data.title,
            style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: AppTheme.primaryPurple),
          ),
          Text(
            data.subtitle,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 60),
          Container(
            padding: const EdgeInsets.all(40),
            decoration: BoxDecoration(
              color: AppTheme.accentLavender.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: Icon(data.icon, size: 100, color: AppTheme.primaryPurple),
          ),
          const SizedBox(height: 60),
          Text(
            data.description,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 15, color: Colors.grey.shade700, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          TextButton(
            onPressed: _finishOnboarding,
            child: const Text("skip", style: TextStyle(color: Colors.grey)),
          ),
          Row(
            children: List.generate(
              _pages.length,
              (index) => Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _currentPage == index ? AppTheme.primaryPurple : Colors.grey.shade300,
                ),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              if (_currentPage < _pages.length - 1) {
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              } else {
                _finishOnboarding();
              }
            },
            child: Text(
              _currentPage == _pages.length - 1 ? "done" : "next",
              style: const TextStyle(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}

class OnboardingData {
  final String title;
  final String subtitle;
  final String description;
  final IconData icon;

  OnboardingData({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.icon,
  });
}
