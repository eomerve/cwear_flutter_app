import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../state/app_controller.dart';
import '../theme/cwear_theme.dart';
import '../widgets/common.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, required this.state,
      required this.onReturnToLive, required this.onCancel});
  final AppController state;
  final VoidCallback onReturnToLive;
  final VoidCallback onCancel;
  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  late final TextEditingController _name;
  late final TextEditingController _age;
  final _formKey = GlobalKey<FormState>();
  String? _selectedPhoto;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.state.fullName);
    _age = TextEditingController(text: widget.state.age.toString());
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    super.dispose();
  }

  Future<void> _changePhoto() async {
    try {
      final photo = await ImagePicker().pickImage(
          source: ImageSource.gallery, maxHeight: 1100,
          maxWidth: 1100, imageQuality: 86);
      if (photo == null || !mounted) return;
      setState(() => _selectedPhoto = photo.path);
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Could not select a photo. Please check photo access.')));
    }
  }

  /// Save and return without a second confirmation (also used by back arrow).
  Future<bool> save({bool navigate = false}) async {
    if (_saving) return false;
    if (!(_formKey.currentState?.validate() ?? false)) return false;
    setState(() => _saving = true);
    try {
      String? savedPhoto;
      if (_selectedPhoto != null) {
        final directory = await getApplicationDocumentsDirectory();
        final source = File(_selectedPhoto!);
        final fileName = 'profile_${DateTime.now().microsecondsSinceEpoch}.jpg';
        final destination = File('${directory.path}/$fileName');
        savedPhoto = (await source.copy(destination.path)).path;
      }
      await widget.state.updateProfile(name: _name.text,
          newAge: int.parse(_age.text.trim()), newAvatarPath: savedPhoto);
      if (mounted && navigate) widget.onReturnToLive();
      return true;
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Could not save profile. Please try again.')));
      }
      return false;
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: false,
    onPopInvokedWithResult: (didPop, result) {
      if (!didPop) save(navigate: true);
    },
    child: ScreenBody(child: Form(
      key: _formKey,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          OutlinedButton(
            onPressed: _saving ? null : () => save(navigate: true),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: CW.line),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(13)),
              padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 12),
            ),
            child: const Icon(Icons.arrow_back, color: CW.ink, size: 20),
          ),
          const Expanded(child: Center(child: Text('Y O U R   P R O F I L E',
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
                  color: CW.muted)))),
          const SizedBox(width: 52),
        ]),
        const SizedBox(height: 33),
        Text('A little about you.',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 10),
        const Text('Keep your details up to date for a more personal monitoring experience.',
            style: TextStyle(fontSize: 14, color: CW.muted, height: 1.48)),
        const SizedBox(height: 32),
        Center(child: Column(children: [
          Stack(children: [
            CircleAvatar(radius: 54, backgroundColor: CW.tealPale,
              backgroundImage: _selectedPhoto != null
                  ? FileImage(File(_selectedPhoto!))
                  : widget.state.avatarPath != null &&
                    File(widget.state.avatarPath!).existsSync()
                      ? FileImage(File(widget.state.avatarPath!))
                      : const AssetImage('assets/images/default_avatar.jpeg')
                        as ImageProvider,
            ),
            Positioned(bottom: 0, right: 0,
              child: Material(color: CW.teal, shape: const CircleBorder(),
                child: IconButton(
                  tooltip: 'Change photo', onPressed: _changePhoto,
                  color: Colors.white, iconSize: 19,
                  icon: const Icon(Icons.camera_alt_outlined),
                ),
              ),
            ),
          ]),
          const SizedBox(height: 7),
          TextButton(onPressed: _changePhoto,
              child: const Text('Change photo', style: TextStyle(
                  color: CW.teal, fontWeight: FontWeight.w700))),
        ])),
        const SizedBox(height: 18),
        const Text('Full name', style: TextStyle(fontSize: 13,
            fontWeight: FontWeight.w700, color: CW.ink)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _name,
          textCapitalization: TextCapitalization.words,
          textInputAction: TextInputAction.next,
          maxLength: 70,
          decoration: const InputDecoration(counterText: '',
              hintText: 'Your name'),
          validator: (value) => (value?.trim().isEmpty ?? true)
              ? 'Please enter your name' : null,
        ),
        const SizedBox(height: 6),
        const Text('The name shown on your monitoring dashboard.',
            style: TextStyle(color: CW.muted, fontSize: 11)),
        const SizedBox(height: 22),
        const Text('Age', style: TextStyle(fontSize: 13,
            fontWeight: FontWeight.w700, color: CW.ink)),
        const SizedBox(height: 8),
        TextFormField(
          controller: _age,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          onFieldSubmitted: (_) => save(navigate: true),
          decoration: const InputDecoration(suffixText: 'years'),
          validator: (value) {
            final n = int.tryParse(value?.trim() ?? '');
            if (n == null || n < 1 || n > 120) {
              return 'Enter an age between 1 and 120';
            }
            return null;
          },
        ),
        const SizedBox(height: 7),
        const Text('Enter your age in whole years.',
            style: TextStyle(color: CW.muted, fontSize: 11)),
        const SizedBox(height: 27),
        Panel(color: CW.soft,
          padding: const EdgeInsets.all(17),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.verified_user_outlined, color: CW.teal, size: 20),
            const SizedBox(width: 11),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('Your profile, your control', style: TextStyle(
                    color: CW.ink, fontSize: 12, fontWeight: FontWeight.w700)),
                SizedBox(height: 5),
                Text('These details identify your demo readings. You can update them at any time.',
                    style: TextStyle(color: CW.muted, fontSize: 12, height: 1.4)),
              ],
            )),
          ]),
        ),
        const SizedBox(height: 29),
        SizedBox(width: double.infinity, height: 52,
          child: FilledButton.icon(
            onPressed: _saving ? null : () => save(navigate: true),
            icon: const Icon(Icons.check),
            label: Text(_saving ? 'Saving...' : 'Save changes'),
            style: FilledButton.styleFrom(
              backgroundColor: CW.teal,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
            ),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(width: double.infinity, height: 49,
          child: OutlinedButton(
            onPressed: _saving ? null : widget.onCancel,
            style: OutlinedButton.styleFrom(foregroundColor: CW.ink,
              side: const BorderSide(color: CW.line),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15))),
            child: const Text('Cancel',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ),
      ]),
    )),
  );
}
