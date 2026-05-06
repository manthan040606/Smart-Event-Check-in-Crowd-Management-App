import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum UserRole { host, attendee, none }

class UserRoleNotifier extends StateNotifier<UserRole> {
  final Ref ref;
  UserRoleNotifier(this.ref) : super(UserRole.none) {
    _loadRole();
  }

  Future<void> _loadRole() async {
    final box = await Hive.openBox('settings');
    final roleString = box.get('user_role', defaultValue: 'none');
    state = UserRole.values.firstWhere((e) => e.toString() == 'UserRole.$roleString', orElse: () => UserRole.none);
  }

  Future<void> setRole(UserRole role) async {
    final box = await Hive.openBox('settings');
    await box.put('user_role', role.name);
    // Reset navigation to first tab when switching roles
    ref.read(navigationProvider.notifier).state = 0;
    state = role;
  }

  Future<void> logout() async {
    final box = await Hive.openBox('settings');
    await box.delete('user_role');
    await box.delete('current_user_id');
    // Reset navigation
    ref.read(navigationProvider.notifier).state = 0;
    state = UserRole.none;
  }
}

final userRoleProvider = StateNotifierProvider<UserRoleNotifier, UserRole>((ref) {
  return UserRoleNotifier(ref);
});

final navigationProvider = StateProvider<int>((ref) => 0);
