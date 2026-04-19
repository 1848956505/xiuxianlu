# 修仙录

> 融入修仙主题的待办清单 App —— 将日常的工作、学习旅程看作一段修仙之路

## 产品理念

- **简单直白**：奇遇任务一句话记录，不需要四象限法则
- **修仙即自律**：修仙之路漫长，唯有坚持才能成仙
- **激励突破**：通过境界系统让用户有持续的动力

## 功能特性

| 功能 | 修仙隐喻 | 说明 |
|------|---------|------|
| 奇遇任务 | 奇遇 | 一句话记录的日常事务、灵光一现的想法 |
| 主线任务 | 修行主线 | 支持多层子任务嵌套的成长型目标 |
| 任务归档 | 功法封存 | 归档结算灵气，只增不减原则 |
| 每日签到 | 晨练 | 每天打开 App 领取灵气 |
| 境界系统 | 修仙境界 | 灵气积累 → 突破 → 解锁新功能/UI |
| 灵气面板 | 修为面板 | 显示当前灵气、境界、进度 |

## 技术栈

- **框架**：Flutter + Dart
- **本地存储**：SQLite
- **状态管理**：Riverpod
- **架构**：分层架构（UI / Domain / Data）

## 运行方式

### 方式一：在 Android 手机/模拟器上运行（推荐）

#### 第 1 步：安装必要软件

| 软件 | 下载地址 | 说明 |
|------|---------|------|
| **Flutter SDK** | https://docs.flutter.dev/get-started/install/windows | 勾选 Android 工具链会自动安装 Android SDK |
| **Android Studio** | https://developer.android.com/studio | 提供 Android 模拟器和 SDK |
| **VS Code**（可选） | https://code.visualstudio.com/ | 轻量级编辑器 |

#### 第 2 步：配置环境

安装完成后，打开 **CMD** 或 **PowerShell**：

```bash
# 验证 Flutter 安装
flutter doctor

# 如果提示 Android toolchain 缺失，运行：
flutter doctor --android-licenses
```

#### 第 3 步：克隆项目并运行

```bash
# 克隆代码
git clone https://github.com/1848956505/xiuxianlu.git
cd xiuxianlu

# 获取依赖
flutter pub get

# 连接 Android 手机（开启 USB 调试）或启动模拟器
# 然后运行：
flutter run
```

#### 第 4 步：在手机上看到效果

- **真机**：用 USB 线连接手机，手机上开启"开发者选项" → "USB 调试"
- **模拟器**：在 Android Studio 中创建一个虚拟设备（AVD），然后 `flutter run`

### 方式二：在 Windows 桌面端运行（预览）

```bash
flutter run -d windows
```

这会编译一个 Windows 桌面应用，可以直接在电脑上看效果。

### 注意事项

1. **首次编译较慢** — Flutter 第一次构建 Android APK 需要下载 Gradle 依赖，可能需要 10-20 分钟
2. **电脑配置要求** — 至少 8GB 内存，建议 SSD 硬盘
3. **Android SDK 版本** — 需要 Android SDK 21+（Android 5.0+）

## 项目结构

```
lib/
├── main.dart                    # 入口文件
├── app.dart                     # App 配置
├── core/                        # 核心公共模块
│   ├── constants/               # 常量（境界配置、配色）
│   ├── theme/                   # 水墨风主题
│   └── utils/                   # 工具函数
├── data/                        # 数据层
│   ├── database/                # SQLite 数据库
│   └── repositories/            # 数据仓库
├── domain/                      # 领域层
│   └── models/                  # 数据模型
└── features/                    # 功能模块
    ├── task/                    # 任务管理
    ├── checkin/                 # 每日签到
    ├── realm/                   # 境界系统
    └── home/                    # 首页
```

## 境界体系

| 境界 | 累计灵气 | 大约时间 | 解锁内容 |
|------|---------|---------|---------|
| 炼气期 | 0 | 第 1 天 | 待办清单、每日签到、灵气面板 |
| 筑基期 | 500 | ~5 天 | 自定义主题 + 云同步 |
| 结丹期 | 2,000 | ~18 天 | 数据统计 + 桌面小组件 |
| 元婴期 | 6,000 | ~55 天 | 白噪音 + 元婴专属主题 |
| 化神期 | 15,000 | ~136 天 | 后续版本新功能 |
| 炼虚期 | 35,000 | ~318 天 | 后续版本新功能 |
| 合体期 | 80,000 | ~727 天 | 后续版本新功能 |

## License

MIT
