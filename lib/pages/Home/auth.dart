import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rawasii/services/api.dart';
import 'package:rawasii/pages/Home/appshell.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(textTheme: GoogleFonts.tajawalTextTheme()),
      home: FutureBuilder<bool>(
        future: ApiService.isLoggedIn(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              backgroundColor: Color(0xFFF2EDE6),
              body: Center(
                child: CircularProgressIndicator(color: Color(0xFF4A2C24)),
              ),
            );
          }
          if (snapshot.data == true) {
            return const Appshell();
          }
          return const LoginPage();
        },
      ),
    );
  }
}

// ==================== LOGIN PAGE ====================
class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _forgotPressed = false;
  bool _signUpPressed = false;
  bool _enPressed = false;
  bool _passwordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EDE6),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: GestureDetector(
                  onTapDown: (_) => setState(() => _enPressed = true),
                  onTapUp: (_) => setState(() => _enPressed = false),
                  onTapCancel: () => setState(() => _enPressed = false),
                  onTap: () {},
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _enPressed
                          ? const Color(0xFFD0C8C0)
                          : Colors.white.withOpacity(0.85),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'EN',
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            color: const Color(0xFF4A2C24),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(
                          Icons.language,
                          size: 16,
                          color: Color(0xFF4A2C24),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color.fromARGB(
                  255,
                  255,
                  255,
                  255,
                ).withOpacity(0.6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4A2C24),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'Log in',
                          style: GoogleFonts.tajawal(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Log in / Sign Up',
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: const Color(0xFF4A2C24),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Email',
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: const Color(0xFF4A2C24),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    style: GoogleFonts.tajawal(color: const Color(0xFF4A2C24)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFD6C9B8),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Password',
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: const Color(0xFF4A2C24),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    style: GoogleFonts.tajawal(color: const Color(0xFF4A2C24)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFD6C9B8),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                        child: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF4A2C24),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTapDown: (_) => setState(() => _forgotPressed = true),
                        onTapUp: (_) => setState(() => _forgotPressed = false),
                        onTapCancel: () =>
                            setState(() => _forgotPressed = false),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ForgotPasswordPage(),
                            ),
                          );
                        },
                        child: Text(
                          'Forgot Password ?',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: _forgotPressed
                                ? const Color(0xFFAAAAAA)
                                : const Color(0xFF4A2C24),
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: _isLoading
                            ? null
                            : () async {
                                final email = _emailController.text.trim();
                                final password = _passwordController.text
                                    .trim();

                                if (email.isEmpty || password.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Please fill all fields',
                                        style: GoogleFonts.tajawal(),
                                      ),
                                    ),
                                  );
                                  return;
                                }

                                final messenger = ScaffoldMessenger.of(context);
                                final navigator = Navigator.of(context);

                                setState(() => _isLoading = true);
                                final result = await ApiService.login(
                                  email,
                                  password,
                                );
                                if (!mounted) return;
                                setState(() => _isLoading = false);

                                if (result.containsKey('error')) {
                                  final errorMsg = result['error'];
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        errorMsg,
                                        style: GoogleFonts.tajawal(),
                                      ),
                                      backgroundColor: Colors.red,
                                      duration: const Duration(seconds: 3),
                                    ),
                                  );
                                  return;
                                }

                                if (result.containsKey('access_token')) {
                                  navigator.pushReplacement(
                                    MaterialPageRoute(
                                      builder: (_) => const HomePage(),
                                    ),
                                  );
                                } else {
                                  messenger.showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        result['error'] ?? 'Login failed',
                                        style: GoogleFonts.tajawal(),
                                      ),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A2C24),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 10,
                          ),
                        ),
                        child: _isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                'Log in',
                                style: GoogleFonts.tajawal(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(color: Color(0x554A2C24)),
                  const SizedBox(height: 10),
                  Center(
                    child: GestureDetector(
                      onTapDown: (_) => setState(() => _signUpPressed = true),
                      onTapUp: (_) => setState(() => _signUpPressed = false),
                      onTapCancel: () => setState(() => _signUpPressed = false),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const SignUpPage()),
                        );
                      },
                      child: RichText(
                        text: TextSpan(
                          text: "Don't have an account ? ",
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: const Color(0xFF4A2C24),
                          ),
                          children: [
                            TextSpan(
                              text: 'Sign Up',
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: _signUpPressed
                                    ? const Color(0xFFAAAAAA)
                                    : const Color(0xFF4A2C24),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

// ==================== HOME PAGE ====================
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Appshell();
  }
}

// ==================== SIGN UP PAGE ====================
class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  bool _passwordVisible = false;
  bool _confirmVisible = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EDE6),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'EN',
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                        color: const Color(0xFF4A2C24),
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(
                      Icons.language,
                      size: 16,
                      color: Color(0xFF4A2C24),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.6),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Text(
                      'Sign Up',
                      style: GoogleFonts.tajawal(
                        fontWeight: FontWeight.w800,
                        fontSize: 24,
                        color: const Color(0xFF4A2C24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'create an account !',
                      style: GoogleFonts.tajawal(
                        fontSize: 13,
                        color: const Color(0xFF4A2C24),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Username',
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: const Color(0xFF4A2C24),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _usernameController,
                    style: GoogleFonts.tajawal(color: const Color(0xFF4A2C24)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFD6C9B8),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Email',
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: const Color(0xFF4A2C24),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _emailController,
                    style: GoogleFonts.tajawal(color: const Color(0xFF4A2C24)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFD6C9B8),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Password',
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: const Color(0xFF4A2C24),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _passwordController,
                    obscureText: !_passwordVisible,
                    style: GoogleFonts.tajawal(color: const Color(0xFF4A2C24)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFD6C9B8),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () => setState(
                          () => _passwordVisible = !_passwordVisible,
                        ),
                        child: Icon(
                          _passwordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF4A2C24),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Confirm Password',
                    style: GoogleFonts.tajawal(
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                      color: const Color(0xFF4A2C24),
                    ),
                  ),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _confirmController,
                    obscureText: !_confirmVisible,
                    style: GoogleFonts.tajawal(color: const Color(0xFF4A2C24)),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFD6C9B8),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide.none,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: () =>
                            setState(() => _confirmVisible = !_confirmVisible),
                        child: Icon(
                          _confirmVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: const Color(0xFF4A2C24),
                          size: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final username = _usernameController.text.trim();
                        final email = _emailController.text.trim();
                        final password = _passwordController.text.trim();
                        final confirm = _confirmController.text.trim();

                        if (username.isEmpty ||
                            email.isEmpty ||
                            password.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Please fill all fields',
                                style: GoogleFonts.tajawal(),
                              ),
                            ),
                          );
                          return;
                        }

                        if (password != confirm) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Passwords do not match',
                                style: GoogleFonts.tajawal(),
                              ),
                            ),
                          );
                          return;
                        }

                        final messenger = ScaffoldMessenger.of(context);
                        final navigator = Navigator.of(context);

                        final result = await ApiService.register(
                          email,
                          password,
                          username,
                        );
                        if (!mounted) return;

                        if (result.containsKey('user_id')) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                'Account created! Check your email ✅',
                                style: GoogleFonts.tajawal(),
                              ),
                            ),
                          );
                          navigator.pop();
                        } else {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(
                                result['error'] ?? 'Register failed',
                                style: GoogleFonts.tajawal(),
                              ),
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A2C24),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.tajawal(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: RichText(
                        text: TextSpan(
                          text: 'Already have an account ? ',
                          style: GoogleFonts.tajawal(
                            fontSize: 12,
                            color: const Color(0xFF4A2C24),
                          ),
                          children: [
                            TextSpan(
                              text: 'Log in',
                              style: GoogleFonts.tajawal(
                                fontSize: 12,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF4A2C24),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==================== FORGOT PASSWORD PAGE ====================
class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  bool _sendPressed = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EDE6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF4A2C24),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Forgot Password',
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4A2C24),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'Enter your\nEmail Address',
                style: GoogleFonts.tajawal(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4A2C24),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'We will send a verification code to your email.',
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  color: const Color(0xFF4A2C24),
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'Email',
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: const Color(0xFF4A2C24),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: GoogleFonts.tajawal(color: const Color(0xFF4A2C24)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFD6C9B8),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTapDown: (_) => setState(() => _sendPressed = true),
                onTapUp: (_) => setState(() => _sendPressed = false),
                onTapCancel: () => setState(() => _sendPressed = false),
                onTap: () async {
                  final email = _emailController.text.trim();
                  if (email.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please enter your email!',
                          style: GoogleFonts.tajawal(),
                        ),
                      ),
                    );
                    return;
                  }

                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);

                  setState(() => _isLoading = true);
                  final result = await ApiService.forgotPassword(email);
                  if (!mounted) return;
                  setState(() => _isLoading = false);

                  if (result.containsKey('message')) {
                    navigator.push(
                      MaterialPageRoute(
                        builder: (_) => VerificationPage(email: email),
                      ),
                    );
                  } else {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          result['error'] ?? 'Error!',
                          style: GoogleFonts.tajawal(),
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _sendPressed
                        ? const Color(0xFFD0C8C0)
                        : const Color(0xFF4A2C24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Send Code',
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== VERIFICATION PAGE ====================
class VerificationPage extends StatefulWidget {
  final String email;
  const VerificationPage({super.key, required this.email});

  @override
  State<VerificationPage> createState() => _VerificationPageState();
}

class _VerificationPageState extends State<VerificationPage> {
  int _secondsRemaining = 299;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    Future.delayed(const Duration(seconds: 1), () {
      if (!mounted) return;
      setState(() {
        if (_secondsRemaining > 0) _secondsRemaining--;
      });
      _startTimer();
    });
  }

  String get _timerText {
    int minutes = _secondsRemaining ~/ 60;
    int seconds = _secondsRemaining % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  final TextEditingController _c1 = TextEditingController();
  final TextEditingController _c2 = TextEditingController();
  final TextEditingController _c3 = TextEditingController();
  final TextEditingController _c4 = TextEditingController();
  final TextEditingController _c5 = TextEditingController();
  final TextEditingController _c6 = TextEditingController();
  final FocusNode _f1 = FocusNode();
  final FocusNode _f2 = FocusNode();
  final FocusNode _f3 = FocusNode();
  final FocusNode _f4 = FocusNode();
  final FocusNode _f5 = FocusNode();
  final FocusNode _f6 = FocusNode();

  String get _otpCode =>
      _c1.text + _c2.text + _c3.text + _c4.text + _c5.text + _c6.text;

  bool _verifyPressed = false;
  bool _sendAgainPressed = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EDE6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF4A2C24),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Forgot Password',
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4A2C24),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'Enter your\nVerification Code',
                style: GoogleFonts.tajawal(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4A2C24),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              Row(
                children: [
                  _box(_c1, _f1, _f2),
                  _box(_c2, _f2, _f3),
                  _box(_c3, _f3, _f4),
                  _box(_c4, _f4, _f5),
                  _box(_c5, _f5, _f6),
                  _box(_c6, _f6, null),
                ],
              ),
              const SizedBox(height: 24),
              Text(
                _timerText,
                style: GoogleFonts.tajawal(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF4A2C24),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'We sent a verification code to your email. You can check your inbox.',
                style: GoogleFonts.tajawal(
                  fontSize: 15,
                  color: const Color(0xFF4A2C24),
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTapDown: (_) => setState(() => _sendAgainPressed = true),
                onTapUp: (_) => setState(() => _sendAgainPressed = false),
                onTapCancel: () => setState(() => _sendAgainPressed = false),
                onTap: () async {
                  final messenger = ScaffoldMessenger.of(context);
                  await ApiService.forgotPassword(widget.email);
                  if (!mounted) return;
                  messenger.showSnackBar(
                    SnackBar(
                      content: Text(
                        'Code resent!',
                        style: GoogleFonts.tajawal(),
                      ),
                    ),
                  );
                },
                child: RichText(
                  text: TextSpan(
                    text: "I didn't receive the code ? ",
                    style: GoogleFonts.tajawal(
                      fontSize: 15,
                      color: const Color(0xFF4A2C24),
                    ),
                    children: [
                      TextSpan(
                        text: 'Send again.',
                        style: GoogleFonts.tajawal(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: _sendAgainPressed
                              ? const Color(0xFFAAAAAA)
                              : const Color(0xFF4A2C24),
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTapDown: (_) => setState(() => _verifyPressed = true),
                onTapUp: (_) => setState(() => _verifyPressed = false),
                onTapCancel: () => setState(() => _verifyPressed = false),
                onTap: () async {
                  final code = _otpCode;
                  if (code.length < 6) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please enter the complete code!',
                          style: GoogleFonts.tajawal(),
                        ),
                      ),
                    );
                    return;
                  }

                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);

                  setState(() => _isLoading = true);
                  final result = await ApiService.verifyOtp(widget.email, code);
                  if (!mounted) return;
                  setState(() => _isLoading = false);

                  if (result.containsKey('access_token')) {
                    navigator.push(
                      MaterialPageRoute(
                        builder: (_) => ResetPasswordPage(
                          accessToken: result['access_token'],
                        ),
                      ),
                    );
                  } else {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          result['error'] ?? 'Invalid code!',
                          style: GoogleFonts.tajawal(),
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _verifyPressed
                        ? const Color(0xFFD0C8C0)
                        : const Color(0xFF4A2C24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Verify',
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _box(
    TextEditingController controller,
    FocusNode current,
    FocusNode? next,
  ) {
    return Container(
      margin: const EdgeInsets.only(right: 12),
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.transparent,
        border: Border.all(color: const Color(0xFF4A2C24), width: 1.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: TextField(
        controller: controller,
        focusNode: current,
        textAlign: TextAlign.center,
        maxLength: 1,
        keyboardType: TextInputType.number,
        decoration: const InputDecoration(
          counterText: '',
          border: InputBorder.none,
        ),
        style: GoogleFonts.tajawal(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: const Color(0xFF4A2C24),
        ),
        onChanged: (value) {
          if (value.isNotEmpty && next != null) next.requestFocus();
        },
      ),
    );
  }
}

// ==================== RESET PASSWORD PAGE ====================
class ResetPasswordPage extends StatefulWidget {
  final String accessToken;
  const ResetPasswordPage({super.key, required this.accessToken});

  @override
  State<ResetPasswordPage> createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _loginPressed = false;
  bool _newPasswordVisible = false;
  bool _confirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2EDE6),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF4A2C24),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'Reset Password',
                    style: GoogleFonts.tajawal(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF4A2C24),
                    ),
                  ),
                  const Spacer(),
                ],
              ),
              const SizedBox(height: 40),
              Text(
                'Create your\nNew Password',
                style: GoogleFonts.tajawal(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF4A2C24),
                  height: 1.2,
                ),
              ),
              const SizedBox(height: 40),
              Text(
                'New Password',
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: const Color(0xFF4A2C24),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _newPasswordController,
                obscureText: !_newPasswordVisible,
                style: GoogleFonts.tajawal(color: const Color(0xFF4A2C24)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFD6C9B8),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () => setState(
                      () => _newPasswordVisible = !_newPasswordVisible,
                    ),
                    child: Icon(
                      _newPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xFF4A2C24),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Confirm Password',
                style: GoogleFonts.tajawal(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  color: const Color(0xFF4A2C24),
                ),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _confirmPasswordController,
                obscureText: !_confirmPasswordVisible,
                style: GoogleFonts.tajawal(color: const Color(0xFF4A2C24)),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: const Color(0xFFD6C9B8),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: GestureDetector(
                    onTap: () => setState(
                      () => _confirmPasswordVisible = !_confirmPasswordVisible,
                    ),
                    child: Icon(
                      _confirmPasswordVisible
                          ? Icons.visibility
                          : Icons.visibility_off,
                      color: const Color(0xFF4A2C24),
                      size: 20,
                    ),
                  ),
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTapDown: (_) => setState(() => _loginPressed = true),
                onTapUp: (_) => setState(() => _loginPressed = false),
                onTapCancel: () => setState(() => _loginPressed = false),
                onTap: () async {
                  final newPassword = _newPasswordController.text.trim();
                  final confirm = _confirmPasswordController.text.trim();

                  if (newPassword.isEmpty || confirm.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Please fill all fields!',
                          style: GoogleFonts.tajawal(),
                        ),
                      ),
                    );
                    return;
                  }
                  if (newPassword != confirm) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Passwords do not match!',
                          style: GoogleFonts.tajawal(),
                        ),
                      ),
                    );
                    return;
                  }

                  final messenger = ScaffoldMessenger.of(context);
                  final navigator = Navigator.of(context);

                  setState(() => _isLoading = true);
                  final result = await ApiService.resetPassword(
                    widget.accessToken,
                    newPassword,
                  );
                  if (!mounted) return;
                  setState(() => _isLoading = false);

                  if (result.containsKey('message')) {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          'Password updated successfully!',
                          style: GoogleFonts.tajawal(),
                        ),
                      ),
                    );
                    navigator.pushAndRemoveUntil(
                      MaterialPageRoute(builder: (_) => const LoginPage()),
                      (route) => false,
                    );
                  } else {
                    messenger.showSnackBar(
                      SnackBar(
                        content: Text(
                          result['error'] ?? 'Error!',
                          style: GoogleFonts.tajawal(),
                        ),
                      ),
                    );
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: _loginPressed
                        ? const Color(0xFFD0C8C0)
                        : const Color(0xFF4A2C24),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: _isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Log in',
                            style: GoogleFonts.tajawal(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
