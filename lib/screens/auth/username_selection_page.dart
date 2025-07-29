import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../wrappers/auth_wrapper.dart';

class UsernameSelectionPage extends StatefulWidget {
  final String? displayName;
  final String? photoUrl;
  
  const UsernameSelectionPage({
    super.key,
    this.displayName,
    this.photoUrl,
  });

  @override
  State<UsernameSelectionPage> createState() => _UsernameSelectionPageState();
}

class _UsernameSelectionPageState extends State<UsernameSelectionPage> {
  final _usernameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  final AuthService _authService = AuthService();
  
  bool _isLoading = false;
  bool _isCheckingAvailability = false;
  bool? _isUsernameAvailable;
  String? _availabilityMessage;

  @override
  void initState() {
    super.initState();
    // Suggest a username based on display name
    if (widget.displayName != null) {
      final suggestion = _generateUsernameSuggestion(widget.displayName!);
      _usernameController.text = suggestion;
      _checkUsernameAvailability(suggestion);
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    super.dispose();
  }

  String _generateUsernameSuggestion(String displayName) {
    // Create a username suggestion from display name
    String suggestion = displayName
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9]'), '')
        .trim();
    
    // Ensure it's between 3-20 characters
    if (suggestion.length < 3) {
      suggestion = '${suggestion}user';
    }
    if (suggestion.length > 20) {
      suggestion = suggestion.substring(0, 20);
    }
    
    return suggestion;
  }

  Future<void> _checkUsernameAvailability(String username) async {
    if (username.trim().length < 3) {
      setState(() {
        _isUsernameAvailable = false;
        _availabilityMessage = 'Username must be at least 3 characters';
        _isCheckingAvailability = false;
      });
      return;
    }

    if (username.trim().length > 20) {
      setState(() {
        _isUsernameAvailable = false;
        _availabilityMessage = 'Username must be less than 20 characters';
        _isCheckingAvailability = false;
      });
      return;
    }

    setState(() {
      _isCheckingAvailability = true;
      _availabilityMessage = null;
    });

    try {
      final isAvailable = await _userService.isUsernameAvailable(username.trim());
      setState(() {
        _isUsernameAvailable = isAvailable;
        _availabilityMessage = isAvailable 
            ? 'Username is available!' 
            : 'Username is already taken';
        _isCheckingAvailability = false;
      });
    } catch (e) {
      setState(() {
        _isUsernameAvailable = false;
        _availabilityMessage = 'Error checking availability';
        _isCheckingAvailability = false;
      });
    }
  }

  Future<void> _confirmUsername() async {
    if (!_formKey.currentState!.validate() || _isUsernameAvailable != true) {
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.completeGoogleSignInWithUsername(_usernameController.text.trim());
      
      if (mounted) {
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Username set successfully! Welcome to Lock-In Factory!'),
            backgroundColor: Colors.green,
          ),
        );
        
        // Small delay to ensure Firestore write is complete
        await Future.delayed(const Duration(milliseconds: 500));
        
        // Force a complete app restart by navigating to a new AuthWrapper
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const AuthWrapper()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to set username: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      // Navigate back to AuthWrapper which will show login
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const AuthWrapper()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Profile Picture
                      if (widget.photoUrl != null) ...[
                        CircleAvatar(
                          radius: 40,
                          backgroundImage: NetworkImage(widget.photoUrl!),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Welcome Message
                      Text(
                        'Welcome${widget.displayName != null ? ', ${widget.displayName}' : ''}!',
                        style: GoogleFonts.oswald(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF8D6E63),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      
                      Text(
                        'Choose a unique username to complete your account setup',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),

                      // Username Field
                      TextFormField(
                        controller: _usernameController,
                        decoration: InputDecoration(
                          labelText: 'Username',
                          prefixIcon: const Icon(Icons.person_outline),
                          suffixIcon: _isCheckingAvailability
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: Padding(
                                    padding: EdgeInsets.all(12.0),
                                    child: CircularProgressIndicator(strokeWidth: 2),
                                  ),
                                )
                              : _isUsernameAvailable == true
                                  ? const Icon(Icons.check_circle, color: Colors.green)
                                  : _isUsernameAvailable == false
                                      ? const Icon(Icons.error, color: Colors.red)
                                      : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          helperText: _availabilityMessage,
                          helperStyle: TextStyle(
                            color: _isUsernameAvailable == true 
                                ? Colors.green 
                                : _isUsernameAvailable == false 
                                    ? Colors.red 
                                    : Colors.grey[600],
                          ),
                        ),
                        onChanged: (value) {
                          // Debounce username checking
                          Future.delayed(const Duration(milliseconds: 500), () {
                            if (_usernameController.text == value && value.isNotEmpty) {
                              _checkUsernameAvailability(value);
                            }
                          });
                        },
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter a username';
                          }
                          if (value.trim().length < 3) {
                            return 'Username must be at least 3 characters';
                          }
                          if (value.trim().length > 20) {
                            return 'Username must be less than 20 characters';
                          }
                          if (_isUsernameAvailable != true) {
                            return 'Please choose an available username';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 32),

                      // Confirm Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: (_isLoading || _isUsernameAvailable != true) 
                              ? null 
                              : _confirmUsername,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF8D6E63),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                )
                              : const Text(
                                  'Continue',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sign Out Button
                      TextButton(
                        onPressed: _isLoading ? null : _signOut,
                        child: Text(
                          'Sign Out',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
