import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../theme.dart';
import '../providers/user_role_provider.dart';

class AuthScreen extends ConsumerStatefulWidget {
  const AuthScreen({super.key});

  @override
  ConsumerState<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends ConsumerState<AuthScreen> {
  bool _isLogin = true;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppTheme.primaryPurple, AppTheme.primaryPurple.withBlue(200)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            // Floating Decorative Circles
            Positioned(
              top: -100,
              left: -50,
              child: CircleAvatar(radius: 120, backgroundColor: Colors.white.withOpacity(0.1)),
            ),
            Positioned(
              bottom: -50,
              right: -50,
              child: CircleAvatar(radius: 100, backgroundColor: Colors.white.withOpacity(0.05)),
            ),
            
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // App Logo Placeholder
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white.withOpacity(0.2)),
                      ),
                      child: const Icon(Icons.qr_code_2_rounded, size: 64, color: Colors.white),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "QRifyME",
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -1),
                    ),
                    Text(
                      "Smart Event Management",
                      style: TextStyle(fontSize: 16, color: Colors.white.withOpacity(0.7)),
                    ),
                    const SizedBox(height: 60),
                    
                    // Auth Card
                    Container(
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(32),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            _isLogin ? "Welcome Back" : "Create Account",
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _isLogin ? "Sign in to manage your events." : "Join us to host or attend events.",
                            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                          ),
                          const SizedBox(height: 32),
                          
                          // Custom Auth Buttons (Select Role)
                          Text("I AM A...", style: TextStyle(color: Colors.grey.shade500, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildRoleBtn("HOST", Icons.admin_panel_settings_rounded, () => _simulateLogin(UserRole.host)),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: _buildRoleBtn("ATTENDEE", Icons.person_rounded, () => _simulateLogin(UserRole.attendee)),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_isLogin ? "Don't have an account? " : "Already have an account? ", style: const TextStyle(fontSize: 12)),
                              GestureDetector(
                                onTap: () => setState(() => _isLogin = !_isLogin),
                                child: Text(
                                  _isLogin ? "Sign Up" : "Log In",
                                  style: const TextStyle(color: AppTheme.primaryPurple, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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

  Widget _buildRoleBtn(String label, IconData icon, VoidCallback onTap) {
    return InkWell(
      onTap: _isLoading ? null : onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20),
        decoration: BoxDecoration(
          color: AppTheme.primaryPurple.withOpacity(0.05),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.primaryPurple.withOpacity(0.1)),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryPurple, size: 28),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: AppTheme.primaryPurple)),
          ],
        ),
      ),
    );
  }

  Future<void> _simulateLogin(UserRole role) async {
    setState(() => _isLoading = true);
    
    // Simulate API delay
    await Future.delayed(const Duration(milliseconds: 800));
    
    final box = await Hive.openBox('settings');
    final mockId = role == UserRole.host ? 'HOST_${DateTime.now().millisecond}' : 'ATTENDEE_${DateTime.now().millisecond}';
    await box.put('current_user_id', mockId);
    
    ref.read(userRoleProvider.notifier).setRole(role);
    
    if (mounted) {
      setState(() => _isLoading = false);
    }
  }
}
