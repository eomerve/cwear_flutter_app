import 'dart:io';

import 'package:flutter/material.dart';
import '../state/app_controller.dart';
import '../theme/cwear_theme.dart';

class ScreenBody extends StatelessWidget {
  const ScreenBody({super.key, required this.child});
  final Widget child;
  @override
  Widget build(BuildContext context) => Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 22, 24, 28),
            physics: const BouncingScrollPhysics(),
            child: child,
          ),
        ),
      );
}

/// Original C-Wear wordmark, with only its surrounding white canvas removed.
/// No extra card, container background, shadow or divider: the logo rests
/// directly on the same surface as the rest of the page.
class CWHeader extends StatelessWidget {
  const CWHeader({super.key});

  @override
  Widget build(BuildContext context) => SizedBox(
        width: double.infinity,
        height: 54,
        child: Align(
          alignment: Alignment.centerLeft,
          child: Image.asset(
            'assets/images/cwear_brand_header_v5.png',
            width: 158,
            height: 54,
            alignment: Alignment.centerLeft,
            fit: BoxFit.contain,
            filterQuality: FilterQuality.high,
            errorBuilder: (context, error, stackTrace) =>
                const SizedBox.shrink(),
          ),
        ),
      );
}

class WindMark extends StatelessWidget {
  const WindMark({super.key, this.size = 26});
  final double size;
  @override
  Widget build(BuildContext context) => Icon(Icons.air_rounded, color: CW.teal, size: size);
}

class Panel extends StatelessWidget {
  const Panel({super.key, required this.child, this.color = CW.white, this.padding,
    this.border = false});
  final Widget child;
  final Color color;
  final EdgeInsets? padding;
  final bool border;
  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: padding ?? const EdgeInsets.all(19),
        decoration: BoxDecoration(
          color: color, borderRadius: BorderRadius.circular(21),
          border: border ? Border.all(color: CW.line) : null,
        ),
        child: child,
      );
}

class Avatar extends StatelessWidget {
  const Avatar({super.key, required this.state, this.radius = 28});
  final AppController state;
  final double radius;
  @override
  Widget build(BuildContext context) {
    final path = state.avatarPath;
    final image = path != null && File(path).existsSync()
        ? FileImage(File(path)) as ImageProvider
        : const AssetImage('assets/images/default_avatar.jpeg');
    return CircleAvatar(radius: radius, backgroundColor: CW.tealPale,
        backgroundImage: image);
  }
}

class DisabledContent extends StatelessWidget {
  const DisabledContent({super.key, required this.disabled, required this.child});
  final bool disabled;
  final Widget child;
  @override
  Widget build(BuildContext context) => IgnorePointer(
        ignoring: disabled,
        child: Opacity(opacity: disabled ? .43 : 1, child: child),
      );
}

class DemoPill extends StatelessWidget {
  const DemoPill({super.key});
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(color: CW.tealPale,
            borderRadius: BorderRadius.circular(10)),
        child: const Text('DEMO', style: TextStyle(fontSize: 10,
            letterSpacing: .8, fontWeight: FontWeight.w800, color: CW.tealDark)),
      );
}

class MutedNote extends StatelessWidget {
  const MutedNote(this.message, {super.key});
  final String message;
  @override
  Widget build(BuildContext context) => Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline, color: CW.muted, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(
              fontSize: 12, height: 1.4, color: CW.muted))),
        ],
      );
}
