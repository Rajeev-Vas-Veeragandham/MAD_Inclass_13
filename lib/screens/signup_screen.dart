import 'dart:async';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'success_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  int _selectedAvatar = -1;
  bool _isGraduate = false;
  double _progress = 0;
  String _progressMessage = "Let's begin your adventure!";
  bool _isSubmitting = false;

  late final AnimationController _shakeController;
  late final AudioPlayer _audioPlayer;

  // Badge states
  bool strongPasswordBadge = false;
  bool earlyBirdBadge = false;
  bool profileCompleteBadge = false;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _audioPlayer = AudioPlayer();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _shakeController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _playSound(String assetName) async {
    try {
      await _audioPlayer.play(AssetSource('sounds/$assetName.mp3'));
    } catch (_) {}
  }

  void _updateProgress() {
    int completed = 0;
    if (_nameController.text.isNotEmpty) completed++;
    if (_emailController.text.isNotEmpty) completed++;
    if (_passwordController.text.isNotEmpty) completed++;
    if (_selectedAvatar != -1) completed++;
    if (_isGraduate) completed++;

    setState(() {
      _progress = (completed / 5) * 100;
    });

    if (_progress >= 100) {
      _progressMessage = "🎉 Ready for adventure!";
      _playSound("success");
    } else if (_progress >= 75) {
      _progressMessage = "Almost done! 💪";
      _playSound("milestone");
    } else if (_progress >= 50) {
      _progressMessage = "Halfway there! 🔥";
      _playSound("milestone");
    } else if (_progress >= 25) {
      _progressMessage = "Great start! 🌟";
      _playSound("milestone");
    } else {
      _progressMessage = "Let's begin your adventure!";
    }
  }

  Color _passwordStrengthColor(String password) {
    if (password.length < 4) return Colors.red;
    if (password.length < 6) return Colors.orange;
    if (password.contains(RegExp(r'(?=.*[A-Z])(?=.*\d)')))
      return Colors.green;
    return Colors.yellow;
  }

  double _passwordStrength(String password) {
    if (password.isEmpty) return 0;
    double strength = 0;
    if (password.length >= 6) strength += 0.3;
    if (password.contains(RegExp(r'[A-Z]'))) strength += 0.3;
    if (password.contains(RegExp(r'[0-9]'))) strength += 0.2;
    if (password.contains(RegExp(r'[!@#\$&*~]'))) strength += 0.2;
    return strength.clamp(0, 1);
  }

  void _validateAndSubmit() async {
    if (!_formKey.currentState!.validate() || _selectedAvatar == -1) {
      _shakeController.forward(from: 0);
      _playSound("error");
      return;
    }

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(seconds: 2));

    // Badges
    final password = _passwordController.text;
    if (_passwordStrength(password) >= 0.8) strongPasswordBadge = true;
    final now = DateTime.now();
    if (now.hour < 12) earlyBirdBadge = true;
    if (_nameController.text.isNotEmpty &&
        _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _selectedAvatar != -1) profileCompleteBadge = true;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          userName: _nameController.text,
          avatarIndex: _selectedAvatar,
          strongPasswordBadge: strongPasswordBadge,
          earlyBirdBadge: earlyBirdBadge,
          profileCompleteBadge: profileCompleteBadge,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final password = _passwordController.text;
    final passStrength = _passwordStrength(password);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Join the Adventure"),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      body: AnimatedBuilder(
        animation: _shakeController,
        builder: (context, child) {
          final offset = 6 * (1 - _shakeController.value);
          return Transform.translate(
            offset: Offset(offset, 0),
            child: child,
          );
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              _buildProgressTracker(),
              const SizedBox(height: 20),
              _buildAvatarSelection(),
              const SizedBox(height: 15),
              _buildFormFields(passStrength, password),
              const SizedBox(height: 25),
              _isSubmitting
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 55),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: _validateAndSubmit,
                      child: const Text(
                        "Sign Up",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressTracker() {
    return Column(
      children: [
        Text(
          _progressMessage,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 10),
        LinearProgressIndicator(
          value: _progress / 100,
          minHeight: 10,
          borderRadius: BorderRadius.circular(8),
          color: Colors.deepPurple,
          backgroundColor: Colors.deepPurple.shade100,
        ),
        const SizedBox(height: 5),
        Text("${_progress.toStringAsFixed(0)}% Complete",
            style: const TextStyle(fontSize: 13, color: Colors.black54)),
      ],
    );
  }

  Widget _buildAvatarSelection() {
    List<String> avatars = [
      'assets/avatars/avatar1.jpg',
      'assets/avatars/avatar2.jpg',
      'assets/avatars/avatar3.jpg',
      'assets/avatars/avatar4.jpg',
      'assets/avatars/avatar5.jpg',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Choose Your Avatar",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: List.generate(avatars.length, (index) {
            bool selected = _selectedAvatar == index;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedAvatar = index;
                });
                _updateProgress();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  border: Border.all(
                    color: selected ? Colors.deepPurple : Colors.transparent,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(60),
                  boxShadow: selected
                      ? [
                          BoxShadow(
                            color: Colors.deepPurple.withOpacity(0.4),
                            blurRadius: 15,
                          )
                        ]
                      : [],
                ),
                child: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(avatars[index]),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildFormFields(double passStrength, String password) {
    return Form(
      key: _formKey,
      onChanged: _updateProgress,
      child: Column(
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: "Full Name",
              prefixIcon: Icon(Icons.person),
              border: OutlineInputBorder(),
            ),
            validator: (val) =>
                val!.isEmpty ? "Please enter your name 😅" : null,
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _emailController,
            decoration: const InputDecoration(
              labelText: "Email",
              prefixIcon: Icon(Icons.email),
              border: OutlineInputBorder(),
            ),
            validator: (val) => val!.contains("@")
                ? null
                : "Hmm, that doesn't look like an email 👀",
          ),
          const SizedBox(height: 15),
          TextFormField(
            controller: _passwordController,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: "Password",
              prefixIcon: Icon(Icons.lock),
              border: OutlineInputBorder(),
            ),
            onChanged: (_) => _updateProgress(),
            validator: (val) =>
                val!.length < 6 ? "Password too short 🙃" : null,
          ),
          const SizedBox(height: 10),
          LinearProgressIndicator(
            value: passStrength,
            backgroundColor: Colors.red.shade100,
            color: _passwordStrengthColor(password),
            minHeight: 8,
            borderRadius: BorderRadius.circular(10),
          ),
          const SizedBox(height: 8),
          Text(
            passStrength < 0.4
                ? "Weak password 😬"
                : passStrength < 0.8
                    ? "Medium strength 🔸"
                    : "Strong password 💪",
            style: TextStyle(
              color: _passwordStrengthColor(password),
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          CheckboxListTile(
            title: const Text("Graduate Student"),
            value: _isGraduate,
            onChanged: (val) {
              setState(() => _isGraduate = val!);
              _updateProgress();
            },
          ),
        ],
      ),
    );
  }
}
