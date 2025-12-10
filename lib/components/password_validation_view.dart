import 'package:flutter/material.dart';

class PasswordValidationView extends StatelessWidget {
  final String password;
  const PasswordValidationView({super.key, required this.password});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildValidationRow('At least 8 characters', password.length >= 8),
        _buildValidationRow('Contains a lowercase letter',
            RegExp(r'(?=.*[a-z])').hasMatch(password)),
        _buildValidationRow('Contains an uppercase letter',
            RegExp(r'(?=.*[A-Z])').hasMatch(password)),
        _buildValidationRow(
            'Contains a number', RegExp(r'(?=.*\d)').hasMatch(password)),
        _buildValidationRow('Contains a special character',
            RegExp(r'(?=.*[!@#\$%^&*])').hasMatch(password)),
      ],
    );
  }

  Widget _buildValidationRow(String text, bool validated) {
    return Row(
      children: [
        Icon(
          validated ? Icons.check : Icons.close,
          color: validated ? Colors.green : Colors.red,
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            decoration: validated ? TextDecoration.lineThrough : null,
          ),
        ),
      ],
    );
  }
}
