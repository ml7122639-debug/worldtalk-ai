import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale, _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400));
    _scale = Tween<double>(begin: 0.6, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutBack));
    _fade = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _ctrl, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));
    _ctrl.forward();
    Future.delayed(const Duration(milliseconds: 2600), () {
      if (mounted) AppNavigator.pushReplacement(context, AppRoutes.home);
    });
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0xFFFAFAF8), Color(0xFFB8A9E8)], stops: [0.0, 1.0])),
        child: Center(
          child: AnimatedBuilder(
            animation: _ctrl,
            builder: (context, _) => Opacity(
              opacity: _fade.value,
              child: Transform.scale(
                scale: _scale.value,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 90, height: 90, decoration: BoxDecoration(color: AppColors.ink, borderRadius: BorderRadius.circular(24)), child: const Icon(Icons.language, size: 44, color: Colors.white)),
                  const SizedBox(height: 24),
                  const Text('WorldTalk AI', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800, color: AppColors.ink, letterSpacing: -0.5)),
                  const SizedBox(height: 8),
                  Text('বিশ্বের সাথে কথা বলুন', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.ink.withValues(alpha: 0.6))),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
