const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

/// Formats an ISO 8601 string (e.g. "2026-09-01T00:00:00.000Z") as
/// "1 Sep 2026" without pulling in the intl package for one use case.
String formatSimpleDate(String isoString) {
  final date = DateTime.parse(isoString).toLocal();
  return '${date.day} ${_months[date.month - 1]} ${date.year}';
}