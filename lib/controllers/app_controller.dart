import 'dart:async';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/config/app_config.dart';
import '../services/preferences_service.dart';

class AppController extends ChangeNotifier {
  AppController({
    required AppConfig config,
    required PreferencesService preferences,
  })  : _config = config,
        _preferences = preferences;

  final AppConfig _config;
  final PreferencesService _preferences;

  StreamSubscription<dynamic>? _authSubscription;
  bool _demoSignedIn = false;
  bool _darkMode = false;
  bool _compactCards = false;
  String _fullName = 'Taller Gráfico Demo';
  String _role = 'admin';

  AppConfig get config => _config;
  bool get demoMode => _config.demoMode;
  bool get darkMode => _darkMode;
  bool get compactCards => _compactCards;
  bool get isAdmin => _role == 'admin';
  String get role => _role;
  String get fullName => _fullName;

  bool get isAuthenticated {
    if (demoMode) return _demoSignedIn;
    return Supabase.instance.client.auth.currentSession != null;
  }

  String? get currentUserId {
    if (demoMode) return _demoSignedIn ? 'demo-user' : null;
    return Supabase.instance.client.auth.currentUser?.id;
  }

  String get currentUserEmail {
    if (demoMode) return 'taller@grafik360.com';
    return Supabase.instance.client.auth.currentUser?.email ?? 'Sin correo';
  }

  Future<void> initialize() async {
    _darkMode = await _preferences.getDarkMode();
    _compactCards = await _preferences.getCompactCards();

    if (!demoMode) {
      await _loadProfile();
      _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
        (event) async {
          await _loadProfile();
          notifyListeners();
        },
      );
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    if (demoMode) {
      await Future<void>.delayed(const Duration(milliseconds: 450));
      _demoSignedIn = true;
      _role = 'admin';
      _fullName = 'Administrador de Taller';
      notifyListeners();
      return;
    }

    await Supabase.instance.client.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
    await _loadProfile();
    notifyListeners();
  }

  Future<bool> signUp({
    required String fullName,
    required String email,
    required String password,
  }) async {
    if (demoMode) {
      _demoSignedIn = true;
      _fullName = fullName.trim().isEmpty ? 'Usuario de Taller' : fullName.trim();
      notifyListeners();
      return true;
    }

    final response = await Supabase.instance.client.auth.signUp(
      email: email.trim(),
      password: password,
      data: {'full_name': fullName.trim()},
    );
    await _loadProfile();
    notifyListeners();
    return response.session != null;
  }

  Future<void> signOut() async {
    if (demoMode) {
      _demoSignedIn = false;
      _role = 'user';
      notifyListeners();
      return;
    }
    await Supabase.instance.client.auth.signOut();
    _role = 'user';
    _fullName = 'Usuario';
    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    notifyListeners();
    await _preferences.setDarkMode(value);
  }

  Future<void> setCompactCards(bool value) async {
    _compactCards = value;
    notifyListeners();
    await _preferences.setCompactCards(value);
  }

  bool canEdit(String ownerId) {
    return demoMode || isAdmin || currentUserId == ownerId;
  }

  bool canEditIncident(String ownerId) => canEdit(ownerId);

  Future<void> _loadProfile() async {
    if (demoMode) return;
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      _fullName = 'Usuario';
      _role = 'user';
      return;
    }

    _fullName = (user.userMetadata?['full_name'] as String?)?.trim().isNotEmpty == true
        ? user.userMetadata!['full_name'] as String
        : (user.email?.split('@').first ?? 'Usuario');

    final profile = await Supabase.instance.client
        .from('profiles')
        .select('full_name, role')
        .eq('id', user.id)
        .maybeSingle();

    if (profile != null) {
      final map = Map<String, dynamic>.from(profile);
      _fullName = (map['full_name'] as String?)?.trim().isNotEmpty == true
          ? map['full_name'] as String
          : _fullName;
      _role = map['role'] as String? ?? 'user';
    }
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
