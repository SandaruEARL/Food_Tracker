// lib/screens/auth/login_register_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../providers/auth_provider.dart';
import '../../../utils/constants.dart';
import '../home_wrapper_screen.dart';
import '../../../widgets/custom_text_form_field.dart';
import '../../../widgets/custom_elevated_button.dart';
import '../../../widgets/custom_tab_bar.dart';
import '../../../widgets/brand_logo.dart'; // Import the new brand logo widget

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _currentTabIndex = 0;

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

  // Separate error states for login and register
  String? _loginError;
  String? _registerError;

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
      // Clear errors when switching tabs
      _clearErrors();
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
      // Clear errors when switching tabs
      _clearErrors();
    }
  }

  void _clearErrors() {
    setState(() {
      _loginError = null;
      _registerError = null;
    });
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
    final safeAreaTop = MediaQuery.of(context).padding.top;

    return Scaffold(
      body: Consumer<AuthProvider>(
        builder: (context, authProvider, child) {
          return Column(
            children: [
              // Top safe area with app branding
              Container(
                padding: EdgeInsets.only(
                  top: safeAreaTop + 24,
                ),
                child: Column(
                  children: [
                    // Using the new BrandLogo widget
                    BrandLogo(size: 30,),

                    SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      constraints: BoxConstraints(maxWidth: 400),
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text.rich(
                        TextSpan(
                          text: _currentTabIndex == 0
                              ? "By signing in you are agreeing "
                              : "By signing up you are agreeing ",
                          style: TextStyle(
                            fontSize: 14,
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
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Navigation Ribbon - Using CustomTabBar
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 23),
                child: CustomTabBar(
                  controller: _tabController,
                  tabTitles: ['Login', 'Register'],
                ),
              ),

              // Tab Content
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 24),
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildLoginTab(authProvider),
                      _buildRegisterTab(authProvider),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildErrorMessage(String error) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        border: Border.all(color: Colors.red.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 20,
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                color: Colors.red,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSocialLoginButtons() {
    return Column(
      children: [
        SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: Divider(color: Color(0xFFA6A6A6))),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'or continue with',
                style: TextStyle(
                  color: Color(0xFFA6A6A6),
                  fontFamily: 'hind',
                  fontSize: 14,
                ),
              ),
            ),
            Expanded(child: Divider(color: Color(0xFFA6A6A6))),
          ],
        ),
        SizedBox(height: 24),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildSocialButton(
              icon: FontAwesomeIcons.google,
              label: '',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Google sign-in coming soon!'),
                    backgroundColor: Colors.blue,
                  ),
                );
              },
            ),
            SizedBox(width: 32),

            _buildSocialButton(
              icon: FontAwesomeIcons.apple,
              label: '',
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Apple sign-in coming soon!'),
                    backgroundColor: Colors.black87,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(
        icon,
        size: 24,
        color: Colors.grey,
      ),
    );
  }

  Widget _buildLoginTab(AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          minHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Form(
          key: _loginFormKey,
          child: Column(
            children: [
              CustomTextFormField(
                controller: _loginEmailController,
                labelText: 'Email',
                prefixIcon: Icons.email_outlined,
                keyboardType: TextInputType.emailAddress,
                validator: (value) => (value?.isEmpty ?? true) ? 'Email is required' : null,
              ),
              SizedBox(height: 24),
              CustomTextFormField(
                controller: _loginPasswordController,
                labelText: 'Password',
                prefixIcon: Icons.lock_outline,
                obscureText: true,
                validator: (value) => (value?.isEmpty ?? true) ? 'Password is required' : null,
              ),
              SizedBox(height: 24),

              // Error message for login only
              if (_loginError != null) _buildErrorMessage(_loginError!),

              CustomElevatedButton(
                onPressed: _login,
                text: 'Login',
                isLoading: authProvider.isLoading,
              ),

              // Social login buttons
              _buildSocialLoginButtons(),

              SizedBox(height: 48),


              Text("v1.0.0 - quickman - dev")
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRegisterTab(AuthProvider authProvider) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(vertical: 24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: 400,
          minHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        child: Form(
          key: _registerFormKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomTextFormField(
                controller: _registerNameController,
                labelText: 'Full Name',
                prefixIcon: Icons.person_outline,
                validator: (value) => (value?.isEmpty ?? true) ? 'Name is required' : null,
              ),
              SizedBox(height: 24),

              // User Type Dropdown
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.grey, width: 1),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_circle_outlined,
                      color: Color(0xFFA6A6A6),
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          dropdownColor: Colors.white,
                          value: _selectedUserType,
                          isExpanded: true,
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.black87,
                          ),
                          hint: Text(
                            'Register as',
                            style: TextStyle(
                              fontSize: 16,
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
                            DropdownMenuItem(
                              value: UserType.customer,
                              child: Text(
                                'Customer',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFFA6A6A6),
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: UserType.driver,
                              child: Text(
                                'Driver',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFFA6A6A6),
                                ),
                              ),
                            ),
                            DropdownMenuItem(
                              value: UserType.restaurant,
                              child: Text(
                                'Restaurant',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Color(0xFFA6A6A6),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              CustomTextFormField(
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
              SizedBox(height: 24),

              CustomTextFormField(
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
              SizedBox(height: 24),

              // Error message for register only
              if (_registerError != null) _buildErrorMessage(_registerError!),

              // Register button
              CustomElevatedButton(
                onPressed: _register,
                text: 'Register',
                isLoading: authProvider.isLoading,
              ),

              // Social login buttons for register tab as well
              _buildSocialLoginButtons(),

              SizedBox(height: 32),


             Text("v1.0.0 - quickman - dev")
            ],
          ),
        ),
      ),
    );
  }

  _login() async {
    if (_loginFormKey.currentState?.validate() ?? false) {
      setState(() {
        _loginError = null; // Clear previous login error
      });

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
      } else if (mounted && authProvider.error != null) {
        setState(() {
          _loginError = authProvider.error;
        });
      }
    }
  }

  _register() async {
    if (_registerFormKey.currentState?.validate() ?? false) {
      if (_selectedUserType == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please select a user type'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      setState(() {
        _registerError = null; // Clear previous register error
      });

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
      } else if (mounted && authProvider.error != null) {
        setState(() {
          _registerError = authProvider.error;
        });
      }
    }
  }
}