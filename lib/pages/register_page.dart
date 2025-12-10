import 'package:chatify/components/my_button.dart';
import 'package:chatify/components/my_text_field.dart';
import 'package:chatify/components/password_validation_view.dart';
import 'package:chatify/services/auth/auth_service.dart';
import 'package:chatify/utils/app_styls.dart';
import 'package:chatify/utils/validators.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatefulWidget {
  final VoidCallback onTap;
  const RegisterPage({super.key, required this.onTap});
  @override
  RegisterPageState createState() => RegisterPageState();
}

class RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  // Show error message
  void _showErrorDialog(String message) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          "Registration Failed",
          style: AppStyles.styleSemiBold16(context),
        ),
        content: Text(
          message,
          style: AppStyles.styleRegular14(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              "OK",
              style: AppStyles.styleMedium16(context),
            ),
          ),
        ],
      ),
    );
  }

  // Register function
  Future<void> register() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    // Set loading state
    if (mounted) {
      setState(() => _isLoading = true);
    }

    final auth = AuthService();

    try {
      await auth.signUpWithEmailPassword(
        _emailController.text.trim(),
        _passwordController.text.trim(),
        _nameController.text.trim(), // Pass the name
      );
    } catch (e) {
      _showErrorDialog(e.toString());
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person_add,
                    size: 60,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 50),
                  Text(
                    "Let's create an account for you",
                    style: AppStyles.styleMedium20(context),
                  ),
                  const SizedBox(height: 25),
                  MyTextField(
                    hintText: 'Email',
                    obscureText: false,
                    controller: _emailController,
                    validator: Validators.email,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    hintText: 'Your name',
                    obscureText: false,
                    controller: _nameController,
                    validator: Validators.name,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    hintText: 'Password',
                    obscureText: true,
                    controller: _passwordController,
                    validator: Validators.password,
                  ),
                  const SizedBox(height: 10),
                  PasswordValidationView(
                    password: _passwordController.text,
                  ),
                  const SizedBox(height: 10),
                  MyTextField(
                    hintText: 'Confirm Password',
                    obscureText: true,
                    controller: _confirmPasswordController,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'Passwords do not match.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 25),
                  _isLoading
                      ? const CircularProgressIndicator()
                      : MyButton(
                          text: 'Register',
                          onTap: register,
                        ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Already have an account? ',
                        style: AppStyles.styleRegular16(context),
                      ),
                      GestureDetector(
                        onTap: widget.onTap,
                        child: Text(
                          'Login now',
                          style: AppStyles.styleBold16(context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
