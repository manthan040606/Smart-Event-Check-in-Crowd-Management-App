import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

enum UserRole { host, attendee, none }

class UserRoleNotifier extends StateNotifier<UserRole> {
  UserRoleNotifier() : super(UserRole.none) {
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
    state = role;
  }

  Future<void> logout() async {
    final box = await Hive.openBox('settings');
    await box.delete('user_role');
    state = UserRole.none;
  }
}

final userRoleProvider = StateNotifierProvider<UserRoleNotifier, UserRole>((ref) {
  return UserRoleNotifier();
});
