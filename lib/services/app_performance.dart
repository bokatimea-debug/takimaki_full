import 'dart:developer' as developer;

/// Small, dependency-free startup measurement for debug and test devices.
/// The value is emitted only to the device log and contains no user data.
class AppPerformance {
  AppPerformance._();

  static final Stopwatch _startup = Stopwatch();
  static bool _firstFrameRecorded = false;

  static void start() {
    if (!_startup.isRunning) _startup.start();
  }

  static void recordFirstFrame() {
    if (_firstFrameRecorded) return;
    _firstFrameRecorded = true;
    developer.log(
      'first_frame_ms=${_startup.elapsedMilliseconds}',
      name: 'takimaki.performance',
    );
  }
}
