# 中文语言支持 / Chinese Language Support

## 概述 / Overview

`inno_bundle` 现在支持中文语言，包括简体中文和繁体中文。这使得你可以为中文用户创建本地化的 Windows 安装程序。

`inno_bundle` now supports Chinese languages, including Simplified Chinese and Traditional Chinese. This allows you to create localized Windows installers for Chinese users.

## 支持的中文语言 / Supported Chinese Languages

- **简体中文 (Simplified Chinese)**: `chineseSimplified`
- **繁体中文 (Traditional Chinese)**: `chineseTraditional`

## 使用方法 / Usage

在你的 `pubspec.yaml` 文件中的 `inno_bundle` 配置部分添加中文语言支持：

Add Chinese language support in the `inno_bundle` configuration section of your `pubspec.yaml` file:

```yaml
inno_bundle:
  # 其他配置...
  languages:
    - english          # 英语
    - chineseSimplified    # 简体中文
    - chineseTraditional   # 繁体中文
```

## 完整示例 / Complete Example

```yaml
name: my_flutter_app
version: 1.0.0+1

dependencies:
  flutter:
    sdk: flutter

dev_dependencies:
  inno_bundle: ^0.11.3

inno_bundle:
  id: your-app-id-here
  publisher: Your Company Name
  installer_icon: assets/images/installer.ico
  languages:
    - english
    - chineseSimplified
    - chineseTraditional
  admin: auto
  arch: x64_compatible
```

## 语言文件位置 / Language File Locations

- 简体中文: `Languages\Unofficial\ChineseSimplified.isl`
- 繁体中文: `Languages\Unofficial\ChineseTraditional.isl`

这些语言文件来自 Inno Setup 官方仓库的非官方语言包。

These language files come from the unofficial language pack in the official Inno Setup repository.

## 注意事项 / Notes

1. 确保你使用的是 Unicode 版本的 Inno Setup，以正确显示中文字符。
2. 安装程序会根据用户的系统语言自动选择合适的语言。
3. 如果用户的系统语言不匹配任何配置的语言，将使用第一个配置的语言作为默认语言。

1. Make sure you are using the Unicode version of Inno Setup to properly display Chinese characters.
2. The installer will automatically select the appropriate language based on the user's system language.
3. If the user's system language doesn't match any configured language, the first configured language will be used as the default.

## 构建安装程序 / Building the Installer

运行以下命令来构建包含中文语言支持的安装程序：

Run the following command to build an installer with Chinese language support:

```bash
dart run inno_bundle
```

安装程序将包含所有配置的语言，用户可以在安装过程中选择他们偏好的语言。

The installer will include all configured languages, and users can select their preferred language during the installation process.