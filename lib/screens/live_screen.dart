import 'package:flutter/material.dart';
import '../state/app_controller.dart';
import '../theme/cwear_theme.dart';
import '../utils/date_text.dart';
import '../utils/respiration_demo.dart';
import '../widgets/common.dart';
import '../widgets/respiration_chart.dart';

class LiveScreen extends StatelessWidget {
  const LiveScreen({super.key, required this.state, required this.onEditProfile,
      required this.onConnect});
  final AppController state;
  final VoidCallback onEditProfile;
  final VoidCallback onConnect;

  @override
  Widget build(BuildContext context) {
    final connected = state.connected;
    return ScreenBody(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CWHeader(),
        const SizedBox(height: 16),
        Row(children: [
          const Icon(Icons.calendar_month_outlined, color: CW.muted, size: 16),
          const SizedBox(width: 6),
          Expanded(child: Text(longDate(DateTime.now()),
              style: const TextStyle(color: CW.muted, fontSize: 13))),
        ]),
        const SizedBox(height: 5),
        Text('Your breathing, live.',
            style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: 20),
        Row(children: [
          Avatar(state: state, radius: 27),
          const SizedBox(width: 13),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(state.fullName, overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700,
                      color: CW.ink)),
              Text('${state.age} years old',
                  style: const TextStyle(color: CW.muted, fontSize: 13)),
            ],
          )),
          IconButton.filledTonal(
            tooltip: 'Edit profile',
            onPressed: onEditProfile,
            style: IconButton.styleFrom(
                backgroundColor: Colors.white, foregroundColor: CW.teal),
            icon: const Icon(Icons.edit_outlined),
          ),
        ]),
        const SizedBox(height: 17),
        InkWell(
          onTap: onConnect,
          borderRadius: BorderRadius.circular(15),
          child: Panel(border: true, padding:
              const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Row(children: [
              Icon(connected ? Icons.circle : Icons.circle_outlined,
                  color: connected ? CW.teal : CW.muted, size: 10),
              const SizedBox(width: 10),
              Expanded(child: Text(connected ? 'C-Wear · Connected' : 'No sensor connected',
                  style: const TextStyle(color: CW.ink, fontSize: 13,
                      fontWeight: FontWeight.w600))),
              if (connected) ...[
                const DemoPill(),
                const SizedBox(width: 7),
                const Icon(Icons.battery_5_bar, color: CW.teal, size: 18),
                const Text('84%', style: TextStyle(
                    color: CW.ink, fontWeight: FontWeight.w700, fontSize: 12)),
              ] else
                const Icon(Icons.chevron_right, color: CW.muted, size: 20),
            ]),
          ),
        ),
        const SizedBox(height: 18),
        DisabledContent(disabled: !connected,
          child: Panel(color: CW.tealPale,
            padding: const EdgeInsets.fromLTRB(21, 19, 21, 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Expanded(child: Text('Respiration rate', style: TextStyle(
                      fontSize: 14, color: CW.tealDark, fontWeight: FontWeight.w600))),
                  WindMark(),
                ]),
                const SizedBox(height: 6),
                Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Text(connected ? '${RespirationDemo.rateBpm}' : '—',
                      style: const TextStyle(fontSize: 58, color: CW.ink,
                          height: 1, fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Padding(padding: const EdgeInsets.only(bottom: 8),
                    child: const Text('BPM',
                        style: const TextStyle(fontSize: 17,
                            fontWeight: FontWeight.w700, color: CW.tealDark))),
                ]),
                const SizedBox(height: 6),
                Text(connected ? 'Breaths per minute · Simulated live' : 'Breaths per minute · Not connected',
                    style: const TextStyle(color: CW.muted, fontSize: 12)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 17),
        DisabledContent(disabled: !connected,
          child: Panel(
            padding: const EdgeInsets.fromLTRB(19, 17, 19, 16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
                  const Expanded(child: Text('Respiration',
                      style: TextStyle(color: CW.ink, fontSize: 19,
                          fontWeight: FontWeight.w700))),
                  Icon(Icons.circle, color: connected ? CW.teal : CW.muted, size: 8),
                  const SizedBox(width: 6),
                  Text(connected ? 'LIVE · DEMO' : 'OFFLINE',
                      style: const TextStyle(color: CW.teal, fontSize: 11,
                          fontWeight: FontWeight.w800, letterSpacing: 1.2)),
                ]),
                const SizedBox(height: 5),
                RespirationChart(connected: connected),
                const SizedBox(height: 6),
                Row(children: [
                  const Text('15-second window', style: TextStyle(
                      color: CW.muted, fontSize: 11)),
                  const Spacer(),
                  const Icon(Icons.sensors_outlined, color: CW.teal, size: 18),
                  const SizedBox(width: 5),
                  Text(connected ? 'Good signal (demo)' : 'No signal',
                      style: const TextStyle(color: CW.muted, fontSize: 11)),
                ]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 17),
        DisabledContent(disabled: !connected,
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(child: Text('Respiratory status',
                  style: TextStyle(fontWeight: FontWeight.w700,
                      color: CW.ink, fontSize: 14))),
              Icon(connected ? Icons.check_circle_outline
                  : Icons.remove_circle_outline,
                  size: 18, color: CW.teal),
              const SizedBox(width: 5),
              Text(connected ? 'Normal' : 'Unavailable',
                  style: const TextStyle(fontWeight: FontWeight.w600,
                      color: CW.teal, fontSize: 13)),
            ]),
            const SizedBox(height: 8),
            Row(children: [
              Expanded(child: _statusChip('Critical', Icons.error_outline,
                  const Color(0xFFB66F65), false)),
              const SizedBox(width: 7),
              Expanded(child: _statusChip('Weak', Icons.warning_amber_rounded,
                  const Color(0xFFB58D37), false)),
              const SizedBox(width: 7),
              Expanded(child: _statusChip('Normal', Icons.check_circle_outline,
                  CW.teal, connected)),
            ]),
          ]),
        ),
        const SizedBox(height: 8),
        const Text('App status only. Not a medical diagnosis.',
            style: TextStyle(color: CW.muted, fontSize: 11)),
        const SizedBox(height: 15),
        const MutedNote('Readings and history are simulated for demonstration. For personal tracking, not diagnosis. If you feel unwell, seek medical advice.'),
        if (!connected) ...[
          const SizedBox(height: 16),
          SizedBox(width: double.infinity,
            child: FilledButton.icon(
              onPressed: onConnect,
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Connect a sensor to start'),
              style: FilledButton.styleFrom(backgroundColor: CW.teal,
                  padding: const EdgeInsets.all(15)),
            ),
          ),
        ],
      ],
    ));
  }

  Widget _statusChip(String label, IconData icon, Color color, bool selected) =>
      Container(
        constraints: const BoxConstraints(minHeight: 37),
        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? CW.tealPale : CW.soft,
          borderRadius: BorderRadius.circular(10),
          border: selected ? Border.all(color: CW.teal) : null,
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 5),
          Flexible(child: Text(label, overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 11, color: color,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500))),
        ]),
      );
}
