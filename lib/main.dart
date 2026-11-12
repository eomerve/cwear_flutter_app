import 'package:flutter/material.dart';

import 'screens/connect_screen.dart';
import 'screens/history_screen.dart';
import 'screens/live_screen.dart';
import 'screens/profile_screen.dart';
import 'state/app_controller.dart';
import 'theme/cwear_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final controller = AppController();
  await controller.initialize();
  runApp(CWearApp(controller: controller));
}

class CWearApp extends StatelessWidget {
  const CWearApp({super.key, required this.controller});
  final AppController controller;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'C-Wear Respiratory Care',
    debugShowCheckedModeBanner: false,
    theme: CW.theme,
    home: HomeShell(controller: controller),
  );
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key, required this.controller});
  final AppController controller;
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  late int _currentIndex;
  final _profileKey = GlobalKey<ProfileScreenState>();

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.controller.connected ? 1 : 0;
    widget.controller.addListener(_onAppChanged);
  }

  void _onAppChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onAppChanged);
    super.dispose();
  }

  void _selectNow(int index) {
    FocusManager.instance.primaryFocus?.unfocus();
    setState(() => _currentIndex = index);
  }

  Future<void> _select(int index) async {
    if (_currentIndex == index) return;
    if (_currentIndex == 3) {
      final saved = await _profileKey.currentState?.save() ?? true;
      if (!saved || !mounted) return;
    }
    _selectNow(index);
  }

  void _returnToLive() => _selectNow(1);

  @override
  Widget build(BuildContext context) {
    final state = widget.controller;
    final screen = switch (_currentIndex) {
      0 => ConnectScreen(state: state, onConnected: _returnToLive),
      1 => LiveScreen(state: state,
          onEditProfile: () => _selectNow(3),
          onConnect: () => _selectNow(0)),
      2 => HistoryScreen(state: state, onProfile: () => _selectNow(3)),
      _ => ProfileScreen(key: _profileKey, state: state,
          onReturnToLive: _returnToLive, onCancel: _returnToLive),
    };
    return Scaffold(
      body: SafeArea(bottom: false, child: screen),
      bottomNavigationBar: _BottomNavigation(
        currentIndex: _currentIndex, onTap: _select,
      ),
    );
  }
}

class _BottomNavigation extends StatelessWidget {
  const _BottomNavigation({required this.currentIndex, required this.onTap});
  final int currentIndex;
  final ValueChanged<int> onTap;
  static const items = <({String name, IconData icon})>[
    (name: 'Connect', icon: Icons.qr_code_scanner_rounded),
    (name: 'Live', icon: Icons.monitor_heart_outlined),
    (name: 'History', icon: Icons.bar_chart_rounded),
    (name: 'Profile', icon: Icons.person_outline_rounded),
  ];

  @override
  Widget build(BuildContext context) => Container(
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(top: BorderSide(color: CW.line)),
    ),
    child: SafeArea(top: false,
      child: Center(heightFactor: 1,
        child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 540),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(5, 6, 5, 3),
            child: Row(children: [
              for (var i = 0; i < items.length; i++)
                Expanded(child: Semantics(
                  button: true, selected: i == currentIndex,
                  label: items[i].name,
                  child: InkWell(
                    onTap: () => onTap(i),
                    borderRadius: BorderRadius.circular(16),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2),
                      child: Column(mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            constraints: const BoxConstraints(minWidth: 55),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: i == currentIndex ? CW.tealPale : Colors.transparent,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(items[i].icon, size: 24,
                              color: i == currentIndex ? CW.teal : CW.muted),
                          ),
                          const SizedBox(height: 3),
                          Text(items[i].name,
                            style: TextStyle(fontSize: 11,
                                color: i == currentIndex ? CW.tealDark : CW.muted)),
                        ],
                      ),
                    ),
                  ),
                )),
            ]),
          ),
        ),
      ),
    ),
  );
}
