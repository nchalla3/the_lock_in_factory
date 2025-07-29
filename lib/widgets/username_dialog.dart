import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class UsernameDialog extends StatefulWidget {
  final bool isFromGoogleSignIn;
  
  const UsernameDialog({
    super.key,
    this.isFromGoogleSignIn = false,
  });

  @override
  State<UsernameDialog> createState() => _UsernameDialogState();
}

class _UsernameDialogState extends State<UsernameDialog> {
  final _usernameController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isAvailable = true;
  String? _errorMessage;

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  Future<void> _checkUsername() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final isAvailable = await _authService.isUsernameAvailable(username);
      setState(() {
        _isAvailable = isAvailable;
        if (!isAvailable) {
          _errorMessage = 'Username is already taken';
        }
      });
    } catch (e) {
      setState(() {
        _errorMessage = 'Error checking username: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _confirmUsername() async {
    final username = _usernameController.text.trim();
    if (username.isEmpty || !_isAvailable) return;

    setState(() => _isLoading = true);

    try {
      if (widget.isFromGoogleSignIn) {
        await _authService.completeGoogleSignInWithUsername(username);
      }
      if (mounted) {
        Navigator.of(context).pop(username);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'Error setting username: $e';
        });
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String? _validateUsername(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Username is required';
    }
    
    final username = value.trim();
    if (username.length < 3) {
      return 'Username must be at least 3 characters';
    }
    
    if (username.length > 20) {
      return 'Username must be less than 20 characters';
    }
    
    // Check for valid characters (alphanumeric and underscore)
    final regex = RegExp(r'^[a-zA-Z0-9_]+$');
    if (!regex.hasMatch(username)) {
      return 'Username can only contain letters, numbers, and underscores';
    }
    
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Choose Username'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Choose a unique username for your account'),
          const SizedBox(height: 16),
          TextFormField(
            controller: _usernameController,
            decoration: InputDecoration(
              labelText: 'Username',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              errorText: _errorMessage,
              suffixIcon: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : _usernameController.text.isNotEmpty
                      ? Icon(
                          _isAvailable ? Icons.check_circle : Icons.cancel,
                          color: _isAvailable ? Colors.green : Colors.red,
                        )
                      : null,
            ),
            onChanged: (_) {
              // Reset state when user types
              setState(() {
                _isAvailable = true;
                _errorMessage = null;
              });
              
              // Debounce username checking
              Future.delayed(const Duration(milliseconds: 500), () {
                if (_usernameController.text.trim().isNotEmpty && 
                    _validateUsername(_usernameController.text) == null) {
                  _checkUsername();
                }
              });
            },
            autovalidateMode: AutovalidateMode.onUserInteraction,
            validator: _validateUsername,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: _isLoading || 
                     !_isAvailable || 
                     _usernameController.text.trim().isEmpty ||
                     _validateUsername(_usernameController.text) != null
              ? null 
              : _confirmUsername,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8D6E63),
            foregroundColor: Colors.white,
          ),
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Confirm'),
        ),
      ],
    );
  }
}
