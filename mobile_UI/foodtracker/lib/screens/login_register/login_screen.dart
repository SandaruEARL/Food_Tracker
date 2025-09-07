// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/constant.dart';
import '../home_wrapper_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0; // Add this to track current tab

  // Login form controllers
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();

  // Register form controllers
  final _registerFormKey = GlobalKey<FormState>();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerConfirmPasswordController = TextEditingController();
  String? _selectedUserType;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Listen to both tab changes and animation changes
    _tabController.addListener(_handleTabChange);
    _tabController.animation?.addListener(_handleAnimationChange);
  }

  void _handleTabChange() {
    if (_tabController.indexIsChanging) {
      // This handles direct tab taps
      setState(() {
        _currentTabIndex = _tabController.index;
      });
    }
  }

  void _handleAnimationChange() {
    // This handles swipe gestures during animation
    final animationValue = _tabController.animation?.value ?? 0.0;
    final newIndex = animationValue >= 0.5 ? 1 : 0;

    if (newIndex != _currentTabIndex) {
      setState(() {
        _currentTabIndex = newIndex;
      });
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    _registerConfirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Column(
            children: [
              // Top safe area with app branding
              Container(
                padding: EdgeInsets.only(
                  top: MediaQuery.of(context).padding.top + 40,
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "SPEED ",
                          style: TextStyle(
                            fontSize: 36,
                            fontFamily: 'hind',
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF0386D0),
                          ),
                        ),
                        Text(
                          "MAN",
                          style: TextStyle(
                            fontSize: 36,
                            fontFamily: 'hind',
                            fontWeight: FontWeight.bold,
                            color: Colors.grey[800],
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 60.0),
                            child: Text.rich(
                              TextSpan(
                                text: _currentTabIndex == 0 // Use _currentTabIndex instead
                                    ? "By signing in you are agreeing "
                                    : "By signing up you are agreeing ",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: 'hind',
                                  color: Color(0xFFA6A6A6),
                                ),
                                children: [
                                  TextSpan(
                                    text: "our Term and privacy policy",
                                    style: TextStyle(
                                      fontFamily: 'hind',
                                      color: Color(0xFF0386D0),
                                    ),
                                  ),
                                ],
                              ),
                              textAlign: TextAlign.center,
                              softWrap: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Navigation Ribbon - Square with font color only
              Container(
                margin: EdgeInsets.symmetric(horizontal: 80),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(0),
                ),
                child: TabBar(
                  controller: _tabController,
                  indicatorSize: TabBarIndicatorSize.tab,
                  indicatorColor: Color(0xFF0386D0),
                  labelColor: Color(0xFF0386D0),
                  unselectedLabelColor: Color(0xFFA6A6A6),
                  labelStyle: TextStyle(fontWeight: FontWeight.bold),
                  unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
                  tabs: [
                    Tab(text: 'LOGIN'),
                    Tab(text: 'REGISTER'),
                  ],
                ),
              ),

              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLoginTab(authProvider),
                    _buildRegisterTab(authProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget buildTextFormField({
    required TextEditingController controller,
    required String labelText,
    required IconData prefixIcon,
    bool obscureText = false,
    String? Function(String?)? validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextFormField(
      style: TextStyle( fontFamily: 'hind',),
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      validator: validator,
      enableSuggestions: false,
      autocorrect: false,
      autofillHints: null,
      decoration: InputDecoration(
        labelText: labelText,
        labelStyle: TextStyle(color: Color(0xFFA6A6A6)),
        prefixIcon: Icon(prefixIcon, color: Color(0xFFA6A6A6)),
        border: UnderlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
        enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFFA6A6A6))),
        focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Color(0xFF0386D0), width: 2)),
        errorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red)),
        focusedErrorBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 2)),
      ),
    );
  }

  Widget _buildLoginTab(AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).viewInsets.left + 30,
        right: MediaQuery.of(context).viewInsets.right + 30,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
        top: MediaQuery.of(context).viewInsets.top + 20,
      ),
      child: Form(
        key: _loginFormKey,
        child: Column(
          children: [
            buildTextFormField(
              controller: _loginEmailController,
              labelText: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) => (value?.isEmpty ?? true) ? 'Email is required' : null,
            ),
            SizedBox(height: 16),
            buildTextFormField(
              controller: _loginPasswordController,
              labelText: 'Password',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (value) => (value?.isEmpty ?? true) ? 'Password is required' : null,
            ),
            SizedBox(height: 20),
            // Error message and login button
            if (authProvider.error != null)
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(authProvider.error!, style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              ),
            ElevatedButton(
              onPressed: authProvider.isLoading ? null : _login,
              style: ElevatedButton.styleFrom(
                backgroundColor:  Color(0xFF0386D0),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: authProvider.isLoading
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : Text('Login', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterTab(AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.only(
        left: MediaQuery.of(context).viewInsets.left + 30,
        right: MediaQuery.of(context).viewInsets.right + 30,
        top: MediaQuery.of(context).viewInsets.top + 30,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _registerFormKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            buildTextFormField(
              controller: _registerNameController,
              labelText: 'Full Name',
              prefixIcon: Icons.person_outline,
              validator: (value) => (value?.isEmpty ?? true) ? 'Name is required' : null,
            ),

            // User Type Dropdown
            Container(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey, width: 1)),
              ),
              child: Row(
                children: [
                  Icon(Icons.account_circle_outlined, color:  Color(0xFFA6A6A6)),
                  SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        dropdownColor:  Colors.white,
                        value: _selectedUserType,
                        isExpanded: true,
                        hint: Text(
                          'Register as',
                          style: TextStyle(
                            color: Color(0xFFA6A6A6),
                            fontFamily: 'hind',
                          ),
                        ),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            setState(() {
                              _selectedUserType = newValue;
                            });
                          }
                        },
                        items: [
                          DropdownMenuItem(value: UserType.customer, child: Text('Customer',style: TextStyle(color:  Color(0xFFA6A6A6)),)),
                          DropdownMenuItem(value: UserType.driver, child: Text('Driver',style: TextStyle(color:  Color(0xFFA6A6A6)))),
                          DropdownMenuItem(value: UserType.restaurant, child: Text('Restaurant',style: TextStyle(color:  Color(0xFFA6A6A6)))),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            buildTextFormField(
              controller: _registerEmailController,
              labelText: 'Email',
              prefixIcon: Icons.email_outlined,
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Email is required';
                if (!value!.contains('@')) return 'Invalid email format';
                return null;
              },
            ),
            SizedBox(height: 16),
            buildTextFormField(
              controller: _registerPasswordController,
              labelText: 'Password',
              prefixIcon: Icons.lock_outline,
              obscureText: true,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Password is required';
                if (value!.length < 6) return 'Password must be at least 6 characters';
                return null;
              },
            ),
            SizedBox(height: 16),
            // Error message
            if (authProvider.error != null)
              Container(
                padding: EdgeInsets.all(12),
                margin: EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  border: Border.all(color: Colors.red.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red, size: 20),
                    SizedBox(width: 8),
                    Expanded(child: Text(authProvider.error!, style: TextStyle(color: Colors.red))),
                  ],
                ),
              ),

            // Register button
            ElevatedButton(
              onPressed: authProvider.isLoading ? null : _register,
              style: ElevatedButton.styleFrom(
                backgroundColor:  Color(0xFF0386D0),
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                elevation: 2,
              ),
              child: authProvider.isLoading
                  ? SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
              )
                  : Text('Register', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  _login() async {
    if (_loginFormKey.currentState?.validate() ?? false) {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.login(
        _loginEmailController.text.trim(),
        _loginPasswordController.text,
      );

      if (mounted && success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeWrapper()),
        );
      }
    }
  }

  _register() async {
    if (_registerFormKey.currentState?.validate() ?? false) {
      if (_selectedUserType == null) {
        // Show error message or set error in AuthProvider
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a user type'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final success = await authProvider.register(
        _registerNameController.text.trim(),
        _registerEmailController.text.trim(),
        _registerPasswordController.text,
        _selectedUserType!,
      );

      if (mounted && success) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeWrapper()),
        );
      }
    }
  }
}