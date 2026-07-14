import 'generated/app_localizations.dart';

String localizedSyncMessage(AppLocalizations l10n, String message) {
  return switch (message) {
    '等待启用 Android 互联通道' => l10n.androidChannelWaiting,
    'Android 互联通道已请求启用' => l10n.androidChannelRequested,
    'Android 互联通道未注册' => l10n.androidChannelUnavailable,
    'Android 互联通道已停用' => l10n.androidChannelStopped,
    '已启用本地模拟配对通道' => l10n.mockChannelEnabled,
    '无法解析手表同步消息' => l10n.invalidWatchMessage,
    '模拟通道无法解析 ACK' => l10n.invalidMockAck,
    _ => message,
  };
}
