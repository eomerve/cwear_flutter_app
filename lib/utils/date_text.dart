const _weekdays = <String>[
  'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
];
const _months = <String>[
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December'
];
String longDate(DateTime day) =>
    '${_weekdays[day.weekday - 1]}, ${_months[day.month - 1]} ${day.day}, ${day.year}';
String monthDay(DateTime day) => '${_months[day.month - 1]} ${day.day}';
String monthShort(DateTime day) => _months[day.month - 1].substring(0, 3);
String rangeLabel(DateTime start, DateTime end) =>
    '${monthShort(start)} ${start.day}–${start.month == end.month ? '' : '${monthShort(end)} '}${end.day}, ${end.year}';
