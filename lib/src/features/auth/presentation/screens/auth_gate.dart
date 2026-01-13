import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:med_shakthi/src/features/dashboard/pharmacy_home_screen.dart';
import 'package:med_shakthi/src/features/dashboard/supplier_dashboard.dart';
import 'package:med_shakthi/src/features/auth/presentation/screens/login_page.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  bool _isLoading = true;
  bool _isSupplier = false;

  @override
  void initState() {
    super.initState();
    _checkUserRole();
  }

  Future<void> _checkUserRole() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    // Check if user ID exists in 'suppliers' table
    final data = await Supabase.instance.client
        .from('suppliers')
        .select()
        .eq('user_id', user.id)
        .maybeSingle();

    if (mounted) {
      setState(() {
        _isSupplier = data != null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final user = Supabase.instance.client.auth.currentUser;

    if (user == null) {
      return const LoginPage();
    }

    if (_isSupplier) {
      return const SupplierDashboard();
    } else {
      return const PharmacyHomeScreen();
    }
  }
}

