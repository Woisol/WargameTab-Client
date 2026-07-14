# Wargame Tab Client
<img src="assets/icon/icon.png" style="display: block; height: 200px; margin: 1rem auto;" />

client 是 Wargame Tab 的 Flutter 手机端应用，负责查看手表记录、管理本地对局、接收手表同步数据，以及提供对局详情和统计。

当前 client 的数据来源包括：

- 本地 SharedPreferences 中已保存的对局。
- Debug/mock 通道提供的演示数据。
- Android 互联通道接收的手表同步消息。

云端账号、远程数据库和自动识别 D 不在当前 client 范围内。

## 功能

- 首页：生涯击杀/死亡统计、KPM、总时长、最近一场和历史对局预览。
- 对局详情：分数面板、比赛时间、总时长和 K/D 时间线。
- 时间线预览：短按立即显示最近事件；长按移动时实时选择最近事件，显示竖线、事件类型和相对时间。
- 历史对局：查看全部记录、进入详情、删除对局并确认。
- 设备同步：启动/停用配对通道，接收手表推送并写入本地仓库。
- 设置：深色/浅色/跟随系统主题、跟随系统/中文/English，以及互联调试开关。
- 国际化：使用 Flutter gen_l10n 和 ARB 资源，支持中文和 English。

## 开发环境

- Flutter/Dart：以 pubspec.yaml 中的 Dart SDK 约束为准。
- Android 构建需要可用的 Android SDK 和 Gradle 环境。
- 依赖安装和 Flutter 命令需要在本机 Flutter 工具链中执行。

首次准备：

~~~text
cd client
flutter pub get
flutter gen-l10n
~~~

项目根目录有 l10n.yaml。不要删除它；Flutter 会按该文件读取 lib/l10n/arb 下的资源，并将生成文件输出到 lib/l10n/generated。

## 常用命令

在 client 目录执行：

~~~text
flutter gen-l10n
flutter test
flutter run
flutter build apk --debug
~~~

生成的本地化 Dart 文件不应手工编辑。修改文案时编辑：

~~~text
client/lib/l10n/arb/app_zh.arb
client/lib/l10n/arb/app_en.arb
~~~

当前环境中 Flutter/Dart 命令可能长时间无响应；遇到这种情况应由有可用 Flutter 工具链的开发环境执行生成、测试和构建。

## 同步通道

应用通过 WARGAME_SYNC_CHANNEL 选择通道。默认值为 auto：

| 值      | Debug 行为                      | Release 行为                    |
| ------- | ------------------------------- | ------------------------------- |
| auto    | 使用 MockWatchSyncChannel       | 使用 AndroidInterconnectChannel |
| mock    | 使用本地模拟通道                | 使用本地模拟通道                |
| android | 使用 AndroidInterconnectChannel | 使用 AndroidInterconnectChannel |

示例：

~~~text
flutter run --dart-define=WARGAME_SYNC_CHANNEL=mock
flutter build apk --debug --dart-define=WARGAME_SYNC_CHANNEL=android
~~~

auto 在 Debug 下会自动注入模拟同步数据，适合开发首页、设备页和详情页；Release 不会自动注入 mock 对局。

同步流程：

1. Watch 端通过 system.interconnect 推送已完成对局。
2. Client 解码 type 为 wargame.sessions.push、protocolVersion 为 1 的消息。
3. Client 按 sessionId 去重并写入本地 SessionRepository。
4. Client 返回 wargame.sessions.ack，Watch 收到 ACK 后将对应记录标记为 synced。
5. DeviceScreen 展示通道状态、最近同步时间、本次写入数量和诊断信息。

Android 实际通道依赖 Android 原生互联能力；Mock 通道只用于开发和测试，不代表真实设备链路。

## 国际化

本地化配置位于：

~~~text
client/l10n.yaml
client/lib/l10n/arb/app_zh.arb
client/lib/l10n/arb/app_en.arb
client/lib/l10n/generated/
~~~

语言模式由 ClientSettingsRepository 保存：

- system：跟随系统；系统语言为 English 时使用 English，其余回退中文。
- zh：中文。
- en：English。

新增用户可见文案时，应同时更新两份 ARB，并通过 AppLocalizations 使用。不要在页面中新增硬编码的用户文案。

## 数据与持久化

Client 使用 SharedPreferencesKeyValueStore 实现 KeyValueStore。

主要 key：

- wargame_client_sessions：本地 WargameSession 数组。
- wargame_client_theme_mode：dark、light 或 system。
- wargame_client_locale_mode：system、zh 或 en。
- wargame_client_interconnect_debug：互联调试开关。

WargameSession 的核心结构：

~~~json
{
  "sessionId": "session_xxx",
  "startTime": 1752057600000,
  "endTime": 1752060720000,
  "status": "finished",
  "summary": {
    "kills": 18,
    "deaths": 5
  },
  "events": [
    {
      "eventId": "event_xxx",
      "type": "kill",
      "time": 90,
      "meta": {
        "actionSource": "manual"
      }
    }
  ]
}
~~~

其中 time 是相对本局开始时间的秒数。Client 当前保留 finished、synced 等状态用于展示和同步处理。

## 目录结构

~~~text
client/
├─ l10n.yaml                         # Flutter 本地化生成配置
├─ pubspec.yaml                      # Flutter 依赖和构建配置
├─ lib/
│  ├─ main.dart                      # 应用入口、主题、locale、导航和同步服务
│  ├─ data/
│  │  ├─ client_settings_repository.dart
│  │  ├─ key_value_store.dart
│  │  ├─ mock_sessions.dart
│  │  └─ session_repository.dart
│  ├─ l10n/
│  │  ├─ arb/                        # 中文和英文 ARB
│  │  ├─ generated/                  # gen_l10n 生成文件
│  │  └─ sync_message_localizer.dart
│  ├─ models/                        # 会话、事件和生涯统计模型
│  ├─ screens/                       # 首页、设备、历史、详情和设置
│  ├─ sync/                          # 通道抽象、Android/Mock 通道、协议和服务
│  ├─ theme/                         # ThemeData 和 WargameColors
│  └─ widgets/                       # 统计面板、分数面板、卡片和时间线
└─ test/
   ├─ widget_test.dart
   ├─ timeline_chart_test.dart
   ├─ session_repository_test.dart
   ├─ client_settings_repository_test.dart
   ├─ interconnect_sync_codec_test.dart
   ├─ watch_sync_service_test.dart
   ├─ watch_sync_logger_test.dart
   └─ android_interconnect_channel_test.dart
~~~

## 测试

测试覆盖：

- SessionRepository 的读取、保存、删除和同步 upsert。
- ClientSettingsRepository 的主题、语言和调试设置持久化。
- Push/ACK 协议编解码和同步服务状态。
- Android 通道的 MethodChannel 行为。
- 首页、设置、设备、历史、详情跳转。
- 时间线最近事件选择、短按预览、未知事件类型和浮窗时间。

Flutter widget test 需要本地化生成文件存在。修改 ARB 后先运行 flutter gen-l10n，再运行 flutter test。

## 当前限制

- AndroidInterconnectChannel 需要真实 Android 互联能力；桌面和普通模拟环境应使用 mock 通道。
- Client 不负责在手机端记录 K/D，记录来源是 Watch 或测试/模拟数据。
- 不包含云端同步、账号体系、录音、自动识别 D 和后台分析服务。
- 生产构建、真机互联和 Flutter 测试需要在具备完整工具链的本机环境验证。

