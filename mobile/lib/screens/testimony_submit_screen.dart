// lib/screens/testimony_submit_screen.dart

import 'package:flutter/material.dart';
import '../config/app_colors.dart';
import '../models/testimony.dart';
import '../services/api/testimony_api.dart';
import '../services/device_service.dart';

class TestimonySubmitScreen extends StatefulWidget {
  const TestimonySubmitScreen({super.key});

  @override
  State<TestimonySubmitScreen> createState() => _TestimonySubmitScreenState();
}

class _TestimonySubmitScreenState extends State<TestimonySubmitScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _nameController = TextEditingController();
  final _api = TestimonyApi();

  bool _isAnonymous = false;
  bool _submitting = false;
  bool _submitted = false;
  String? _error;

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final deviceId = await DeviceService.getDeviceId();
      await _api.createTestimony(Testimony(
        message: _messageController.text.trim(),
        authorName: _nameController.text.trim(),
        isAnonymous: _isAnonymous,
        deviceId: deviceId,
      ));
      setState(() {
        _submitted = true;
        _submitting = false;
      });
      _messageController.clear();
      _nameController.clear();
    } catch (e) {
      setState(() {
        _error = 'Could not submit your testimony. Check your connection and try again.';
        _submitting = false;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Share Your Testimony')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Your testimony will be reviewed before it appears publicly.',
                style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              if (_error != null)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(_error!, style: const TextStyle(color: AppColors.error)),
                ),
              if (_submitted)
                Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Thank you for sharing! It will appear here once approved.',
                    style: TextStyle(color: AppColors.success),
                  ),
                ),
              TextFormField(
                controller: _messageController,
                maxLines: 6,
                decoration: const InputDecoration(
                  labelText: 'What has God done for you?',
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (value) =>
                    (value == null || value.trim().isEmpty) ? 'Please share your testimony' : null,
              ),
              const SizedBox(height: 16),
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Share anonymously'),
                value: _isAnonymous,
                onChanged: (value) => setState(() => _isAnonymous = value),
              ),
              if (!_isAnonymous)
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Your name (optional)',
                    border: OutlineInputBorder(),
                  ),
                ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitting ? null : _submit,
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: _submitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Submit Testimony'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}