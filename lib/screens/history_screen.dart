import 'package:flutter/material.dart';
import '../state/app_controller.dart';
import '../theme/cwear_theme.dart';
import '../utils/date_text.dart';
import '../utils/respiration_demo.dart';
import '../widgets/common.dart';
import '../widgets/respiration_chart.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key, required this.state, required this.onProfile});
  final AppController state;
  final VoidCallback onProfile;
  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _mode = 1; // day / week / month
  DateTime _focus = DateUtils.dateOnly(DateTime.now());
  int _chosenDay = DateTime.now().weekday - 1;
  static const _modes = ['Day', 'Week', 'Month'];
  static const _weekdayLabels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];

  DateTime get _weekStart => _focus.subtract(Duration(days: _focus.weekday - 1));

  void _shift(int direction) {
    setState(() {
      final byDays = _mode == 0 ? 1 : _mode == 1 ? 7 : 30;
      _focus = _focus.add(Duration(days: direction * byDays));
      _chosenDay = _focus.weekday - 1;
    });
  }

  String get _periodLabel {
    if (_mode == 0) return longDate(_focus);
    if (_mode == 1) return rangeLabel(_weekStart, _weekStart.add(const Duration(days: 6)));
    return '${monthShort(_focus)} ${_focus.year}';
  }

  @override
  Widget build(BuildContext context) {
    final connected = widget.state.connected;
    final today = DateUtils.dateOnly(DateTime.now());
    final isCurrentWeek = !today.isBefore(_weekStart) &&
        today.isBefore(_weekStart.add(const Duration(days: 7)));
    final isRecentPeriod = switch (_mode) {
      0 => DateUtils.isSameDay(_focus, today),
      1 => isCurrentWeek,
      _ => _focus.year == today.year && _focus.month == today.month,
    };
    final canShowDemo = connected && isRecentPeriod;
    final samples = _mode == 0
        ? <double?>[15, 16, 17, 16, 16, 16, 16]
        : _mode == 1 ? RespirationDemo.weeklyRates : RespirationDemo.monthlyRates;
    final labels = _mode == 0
        ? const ['6', '8', '10', '12', '14', '16', '18']
        : _mode == 1 ? _weekdayLabels : const ['1', '5', '10', '15', '20', '25', '30'];
    return ScreenBody(child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const CWHeader(),
        const SizedBox(height: 16),
        Text(longDate(DateTime.now()),
            style: const TextStyle(color: CW.muted, fontSize: 13)),
        const SizedBox(height: 5),
        Row(children: [
          Expanded(child: Text('Your breathing story.',
              style: Theme.of(context).textTheme.headlineMedium)),
          InkWell(onTap: widget.onProfile,
              child: Avatar(state: widget.state, radius: 20)),
        ]),
        const SizedBox(height: 22),
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(color: CW.soft,
              borderRadius: BorderRadius.circular(15)),
          child: Row(children: [for (var i = 0; i < 3; i++)
            Expanded(child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() {
                _mode = i;
                _focus = today;
              }),
              child: AnimatedContainer(duration: const Duration(milliseconds: 170),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: _mode == i ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(11)),
                child: Center(child: Text(_modes[i], style: TextStyle(
                    fontSize: 13, fontWeight: _mode == i
                    ? FontWeight.w700 : FontWeight.w500,
                    color: _mode == i ? CW.ink : CW.muted))),
              ),
            )),
          ]),
        ),
        const SizedBox(height: 14),
        Row(children: [
          IconButton(onPressed: () => _shift(-1),
              icon: const Icon(Icons.chevron_left, color: CW.ink)),
          Expanded(child: Center(child: Row(mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.calendar_month_outlined, size: 17, color: CW.teal),
                const SizedBox(width: 7),
                Flexible(child: Text(_periodLabel,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: CW.ink,
                        fontWeight: FontWeight.w700, fontSize: 14))),
              ]))),
          IconButton(onPressed: () => _shift(1),
              icon: const Icon(Icons.chevron_right, color: CW.muted)),
        ]),
        if (_mode == 1) ...[
          const SizedBox(height: 9),
          Row(children: [for (var i = 0; i < 7; i++)
            Expanded(child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => setState(() {
                _chosenDay = i;
                _focus = _weekStart.add(Duration(days: i));
              }),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(color: i == _chosenDay
                    ? CW.teal : Colors.transparent,
                    borderRadius: BorderRadius.circular(13)),
                child: Column(children: [
                  Text(_weekdayLabels[i], style: TextStyle(
                      fontSize: 10, color: i == _chosenDay
                      ? Colors.white : CW.muted)),
                  const SizedBox(height: 6),
                  Text('${_weekStart.add(Duration(days: i)).day}',
                      style: TextStyle(fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: i == _chosenDay ? Colors.white : CW.ink)),
                ]),
              ),
            )),
          ]),
        ],
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: DisabledContent(disabled: !canShowDemo,
            child: Panel(color: CW.tealPale,
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_mode == 0 ? 'Daily average' : _mode == 1
                      ? 'Weekly average' : 'Monthly average',
                      style: const TextStyle(color: CW.tealDark, fontSize: 12)),
                  const SizedBox(height: 3),
                  Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
                    Text(canShowDemo ? '16' : '—', style: const TextStyle(
                        fontSize: 30, color: CW.ink, height: 1.2)),
                    const SizedBox(width: 5),
                    const Padding(padding: EdgeInsets.only(bottom: 4),
                      child: Text('BPM', style: TextStyle(fontSize: 11, color: CW.muted))),
                  ]),
                  Text(canShowDemo ? '1 BPM below last week' : 'No readings',
                      style: const TextStyle(fontSize: 10, color: CW.muted)),
                ],
              ),
            ),
          )),
          const SizedBox(width: 11),
          Expanded(child: DisabledContent(disabled: !canShowDemo,
            child: Panel(padding: const EdgeInsets.symmetric(
                horizontal: 15, vertical: 15),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Time monitored',
                      style: TextStyle(color: CW.muted, fontSize: 12)),
                  const SizedBox(height: 3),
                  Text(canShowDemo ? '6ʰ 42ᵐ' : '—',
                      style: const TextStyle(fontSize: 29,
                          color: CW.ink, height: 1.2)),
                  Text(canShowDemo ? 'Across 5 days' : 'No sessions',
                      style: const TextStyle(fontSize: 10, color: CW.muted)),
                ],
              ),
            ),
          )),
        ]),
        const SizedBox(height: 17),
        DisabledContent(disabled: !canShowDemo,
          child: Panel(padding: const EdgeInsets.fromLTRB(17, 17, 17, 18),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                const Expanded(child: Text('Respiration trend',
                    style: TextStyle(color: CW.ink, fontSize: 18,
                        fontWeight: FontWeight.w700))),
                const Text('Daily average',
                    style: TextStyle(color: CW.muted, fontSize: 11)),
              ]),
              const SizedBox(height: 6),
              const Text('BPM', style: TextStyle(fontSize: 11, color: CW.muted)),
              const SizedBox(height: 4),
              HistoryBars(values: samples, labels: labels,
                  enabled: canShowDemo,
                  highlightIndex: _mode == 1 ? today.weekday - 1 : 4),
              const SizedBox(height: 5),
              Row(children: [
                Container(height: 8, width: 11,
                    decoration: BoxDecoration(color: CW.teal,
                        borderRadius: BorderRadius.circular(3))),
                const SizedBox(width: 7),
                Expanded(child: Text(canShowDemo
                    ? 'Average breaths per minute · demo' : 'No recorded respiration data',
                    style: const TextStyle(color: CW.muted, fontSize: 11))),
              ]),
            ]),
          ),
        ),
        const SizedBox(height: 18),
        Row(children: [
          Expanded(child: Text(_mode == 0 ? longDate(_focus) :
              longDate(_weekStart.add(Duration(days: _chosenDay))),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: CW.ink, fontSize: 16,
                  fontWeight: FontWeight.w700))),
          Text(canShowDemo ? '2 sessions · demo' : '0 sessions',
              style: const TextStyle(color: CW.muted, fontSize: 11)),
        ]),
        const SizedBox(height: 10),
        if (canShowDemo) ...[
          _session('09:26 – now', '15 min · Demo recording', '16 BPM'),
          const Divider(color: CW.line),
          _session('07:15 – 07:42', '27 min · Demo completed', '16 BPM'),
        ] else
          const Padding(padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: Text('No sessions to display',
              style: TextStyle(color: CW.muted))),
          ),
        const SizedBox(height: 18),
        const MutedNote('Example history is simulated, not sensor-recorded. Empty periods have no readings. For personal tracking, not diagnosis.'),
      ],
    ));
  }

  Widget _session(String time, String details, String bpm) =>
      Padding(padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Container(width: 39, height: 39,
            decoration: BoxDecoration(color: CW.tealPale,
                borderRadius: BorderRadius.circular(13)),
            child: const Icon(Icons.monitor_heart_outlined, color: CW.teal)),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(time, style: const TextStyle(fontSize: 13,
                  color: CW.ink, fontWeight: FontWeight.w700)),
              Text(details, style: const TextStyle(fontSize: 11, color: CW.muted)),
            ],
          )),
          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(bpm, style: const TextStyle(fontSize: 12,
                color: CW.ink, fontWeight: FontWeight.w700)),
            const Text('Normal', style: TextStyle(fontSize: 11, color: CW.teal)),
          ]),
          const SizedBox(width: 10),
          const Icon(Icons.chevron_right, size: 18, color: CW.muted),
        ]),
      );
}
