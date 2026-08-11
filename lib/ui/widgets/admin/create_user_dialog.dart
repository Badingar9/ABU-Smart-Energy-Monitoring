import 'package:flutter/material.dart';
import 'package:scada_app/models/role.dart';

class CreateUserDialog extends StatefulWidget {
  final void Function(String fullName, String email, RoleType role) onCreate;
  const CreateUserDialog({super.key, required this.onCreate});

  @override
  State<CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<CreateUserDialog> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  RoleType _role = RoleType.technician;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_nameController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Name and email are required')),
      );
      return;
    }
    widget.onCreate(
      _nameController.text.trim(),
      _emailController.text.trim(),
      _role,
    );
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New user'),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Full name'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<RoleType>(
              initialValue: _role,
              decoration: const InputDecoration(labelText: 'Role'),
              items: const [
                DropdownMenuItem(
                  value: RoleType.admin,
                  child: Text('Administrator'),
                ),
                DropdownMenuItem(
                  value: RoleType.technician,
                  child: Text('Technician'),
                ),
              ],
              onChanged: (v) => setState(() => _role = v ?? _role),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton(onPressed: _submit, child: const Text('Create')),
      ],
    );
  }
}
