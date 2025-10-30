import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:audioplayers/audioplayers.dart';

class SuccessScreen extends StatefulWidget {
  final String userName;
  final int avatarIndex;
  final bool strongPasswordBadge;
  final bool earlyBirdBadge;
  final bool profileCompleteBadge;

  const SuccessScreen({
    super.key,
    required this.userName,
    required this.avatarIndex,
    required this.strongPasswordBadge,
    required this.earlyBirdBadge,
    required this.profileCompleteBadge,
  });

  @override
  State<SuccessScreen> createState() => _SuccessScreenState();
}

class _SuccessScreenState extends State<SuccessScreen> {
  late ConfettiController _confettiController;
  late AudioPlayer _audioPlayer;

  final List<String> avatars = [
    'assets/avatars/avatar1.jpg',
    'assets/avatars/avatar2.jpg',
    'assets/avatars/avatar3.jpg',
    'assets/avatars/avatar4.jpg',
    'assets/avatars/avatar5.jpg',
  ];

  @override
  void initState() {
    super.initState();
    _confettiController =
        ConfettiController(duration: const Duration(seconds: 4))..play();
    _audioPlayer = AudioPlayer();
    _playSound("success");
  }

  Future<void> _playSound(String name) async {
    try {
      await _audioPlayer.play(AssetSource("sounds/$name.mp3"));
    } catch (_) {}
  }

  @override
  void dispose() {
    _confettiController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF6A11CB), Color(0xFF2575FC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          ConfettiWidget(
            confettiController: _confettiController,
            blastDirectionality: BlastDirectionality.explosive,
            emissionFrequency: 0.05,
            numberOfParticles: 40,
            maxBlastForce: 12,
            minBlastForce: 4,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Hero(
                tag: 'logo',
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: AssetImage(avatars[widget.avatarIndex]),
                ),
              ),
              const SizedBox(height: 20),
              AnimatedTextKit(
                animatedTexts: [
                  ColorizeAnimatedText(
                    'Welcome, ${widget.userName}!',
                    textStyle: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                    colors: [
                      Colors.white,
                      Colors.amber,
                      Colors.cyanAccent,
                      Colors.lightGreenAccent,
                    ],
                  ),
                  WavyAnimatedText(
                    'You made it! 🎉',
                    textStyle: const TextStyle(
                      fontSize: 26,
                      color: Colors.white,
                    ),
                    speed: const Duration(milliseconds: 150),
                  ),
                ],
                totalRepeatCount: 1,
              ),
              const SizedBox(height: 40),
              const Text(
                "🏅 Achievements Unlocked",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 15),
              Wrap(
                spacing: 15,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: _buildBadges(),
              ),
              const SizedBox(height: 40),
              ElevatedButton.icon(
                icon: const Icon(Icons.home),
                label: const Text(
                  "Back to Home",
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.deepPurple,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 10,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _buildBadges() {
    List<Widget> badges = [];

    if (widget.strongPasswordBadge) {
      badges.add(_badgeCard("Strong Password Master", Icons.lock));
    }
    if (widget.earlyBirdBadge) {
      badges.add(_badgeCard("Early Bird Special", Icons.wb_sunny));
    }
    if (widget.profileCompleteBadge) {
      badges.add(_badgeCard("Profile Completer", Icons.emoji_events));
    }

    if (badges.isEmpty) {
      badges.add(const Text(
        "No badges yet 💤",
        style: TextStyle(color: Colors.white70),
      ));
    }

    return badges;
  }

  Widget _badgeCard(String title, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.amberAccent, size: 22),
          const SizedBox(width: 8),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ],
      ),
    );
  }
}
