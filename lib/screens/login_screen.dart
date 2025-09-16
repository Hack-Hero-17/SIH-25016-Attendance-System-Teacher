// lib/screens/login_screen.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'permission_check_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthService _auth = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Use a post-frame callback to ensure the first build is complete
    // before attempting any navigation.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLoginStatus();
    });
  }

  // --- Best Practice: Checking Login Status ---
  // Checks if a user is ALREADY signed in.
  void _checkLoginStatus() async {
    String? userId = _auth.getCurrentUserId();
    // The 'mounted' property checks if the widget is still in the widget tree.
    // It's crucial to check this before using 'context' in async functions.
    if (userId != null && mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PermissionCheckScreen(userId: userId),
        ),
      );
    }
  }

  // --- Best Practice: The Error-Free Login Function ---
  // This function is structured to completely avoid the race condition.
  void _login() async {
    // 1. Show the loading indicator.
    setState(() {
      _isLoading = true;
    });

    // 2. Await the result from Firebase.
    String? userId = await _auth.signIn(
      _emailController.text,
      _passwordController.text,
    );

    // 3. THE CRITICAL GUARD: Before using 'context', we MUST check if the
    //    widget is still on the screen. If not, we do nothing.
    if (!mounted) return;

    // 4. THE LOGIC SPLIT: This prevents the crash.
    // If login was SUCCESSFUL (we have a userId):
    if (userId != null) {
      // We ONLY navigate. We DO NOT call setState().
      // This avoids the conflict and the '!_debugLocked' crash.
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => PermissionCheckScreen(userId: userId),
        ),
      );
    }
    // If login FAILED (userId is null):
    else {
      // We are NOT navigating, so it's now safe to update the state
      // to turn off the loading indicator and show an error message.
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed. Please check your credentials.')),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome Back, Teacher!',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 40),
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 30),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 80, vertical: 15),
                  textStyle: const TextStyle(fontSize: 16),
                ),
                child: const Text('Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}