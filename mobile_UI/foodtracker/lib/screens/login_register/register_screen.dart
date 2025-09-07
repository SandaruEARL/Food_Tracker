// lib/screens/auth/register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../utils/constant.dart';
import '../home_wrapper_screen.dart';


class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  String _selectedUserType = UserType.customer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Register')),
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.restaurant, size: 80, color: Colors.orange),
                    SizedBox(height: 40),

                    TextFormField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Name is required';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Email is required';
                        if (!value!.contains('@')) return 'Invalid email format';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    TextFormField(
                      controller: _passwordController,
                      decoration: InputDecoration(
                        labelText: 'Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Password is required';
                        if (value!.length < 6) return 'Password must be at least 6 characters';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    TextFormField(
                      controller: _confirmPasswordController,
                      decoration: InputDecoration(
                        labelText: 'Confirm Password',
                        border: OutlineInputBorder(),
                      ),
                      obscureText: true,
                      validator: (value) {
                        if (value?.isEmpty ?? true) return 'Please confirm your password';
                        if (value != _passwordController.text) return 'Passwords do not match';
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // User Type Selection
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedUserType,
                          isExpanded: true,
                          hint: Text('Select User Type'),
                          onChanged: (String? newValue) {
                            if (newValue != null) {
                              setState(() {
                                _selectedUserType = newValue;
                              });
                            }
                          },
                          items: [
                            DropdownMenuItem<String>(
                              value: UserType.customer,
                              child: Text('Customer'),
                            ),
                            DropdownMenuItem<String>(
                              value: UserType.driver,
                              child: Text('Driver'),
                            ),
                            DropdownMenuItem<String>(
                              value: UserType.restaurant,
                              child: Text('Restaurant'),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 24),

                    if (authProvider.error != null)
                      Container(
                        padding: EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          border: Border.all(color: Colors.red),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          authProvider.error!,
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: authProvider.isLoading ? null : _register,
                      child: authProvider.isLoading
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text('Register'),
                      style: ElevatedButton.styleFrom(
                        minimumSize: Size(double.infinity, 50),
                      ),
                    ),
                    SizedBox(height: 16),

                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text('Already have an account? Login'),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  _register() async {
    if (_formKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
        _selectedUserType,
      );

      if (success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeWrapper()),
        );
      }
    }
  }
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}