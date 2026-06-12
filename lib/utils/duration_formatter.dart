/// Format a Duration to MM:SS string format
///
/// Minutes are clamped to 99 maximum
/// Seconds are always 2 digits with zero padding
String formatTimer(Duration duration) {
  final totalSeconds = duration.inSeconds;
  final minutes = (totalSeconds ~/ 60).clamp(0, 99);
  final seconds = (totalSeconds % 60).clamp(0, 59);

  return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
}

/// Truncate a name to maxLength characters with ellipsis if needed
/// Preserves full name internally but provides display-safe version
String truncateNameForDisplay(String name, {int maxLength = 30}) {
  if (name.length <= maxLength) {
    return name;
  }

  return '${name.substring(0, maxLength - 1)}…';
}
