import 'package:client/sync/watch_sync_logger.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('logger always writes logs but only debugs toast when requested', () {
    final logs = <String>[];
    final toasts = <String>[];
    final logger = WatchSyncLogger(
      debug: false,
      onLog: logs.add,
      onToast: toasts.add,
    );

    logger.log('always', toast: true);
    expect(logs, ['always']);
    expect(toasts, isEmpty);

    logger.setDebug(true);
    logger.log('silent', toast: false);
    logger.log('visible', toast: true);

    expect(logs, ['always', 'silent', 'visible']);
    expect(toasts, ['visible']);
  });
}
