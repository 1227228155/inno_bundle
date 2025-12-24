## 中文语言支持 / Chinese Language Support

## 概述 / Overview

`inno_bundle` 现在支持中文语言，包括简体中文和繁体中文。这使得你可以为中文用户创建本地化的 Windows 安装程序。

`inno_bundle` now supports Chinese languages, including Simplified Chinese and Traditional Chinese. This allows you to create localized Windows installers for Chinese users.

## 支持的中文语言 / Supported Chinese Languages

- **简体中文 (Simplified Chinese)**: `chineseSimplified`
- **繁体中文 (Traditional Chinese)**: `chineseTraditional`

## 自动下载功能 / Automatic Download Feature

如果你的 Inno Setup 安装中没有中文语言文件，`inno_bundle` 会自动从可靠的源下载这些文件：

If your Inno Setup installation doesn't have Chinese language files, `inno_bundle` will automatically download them from reliable sources:

- **简体中文文件来源**: [kira-96/Inno-Setup-Chinese-Simplified-Translation](https://github.com/kira-96/Inno-Setup-Chinese-Simplified-Translation)
- **繁体中文文件来源**: [jrsoftware/issrc (官方仓库)](https://github.com/jrsoftware/issrc)

语言文件会被下载到临时目录中，并在构建过程中自动使用。

Language files will be downloaded to a temporary directory and used automatically during the build process.

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

## 技术实现 / Technical Implementation

- 构建时自动检测 Inno Setup 安装目录中是否存在中文语言文件
- 如果文件不存在，自动从 GitHub 下载最新版本
- 使用绝对路径引用下载的语言文件，避免依赖 Inno Setup 的标准安装
- 支持离线使用（如果文件已经下载过）

- Automatically detects if Chinese language files exist in the Inno Setup installation directory during build
- If files don't exist, automatically downloads the latest versions from GitHub
- Uses absolute paths to reference downloaded language files, avoiding dependency on standard Inno Setup installation
- Supports offline usage (if files have been downloaded previously)

## 注意事项 / Notes

1. **网络连接**: 首次使用中文语言时需要网络连接来下载语言文件。
2. **Unicode 支持**: 确保你使用的是 Unicode 版本的 Inno Setup，以正确显示中文字符。
3. **自动语言选择**: 安装程序会根据用户的系统语言自动选择合适的语言。
4. **缓存机制**: 下载的语言文件会被缓存，避免重复下载。

1. **Network Connection**: Internet connection is required for the first time using Chinese languages to download language files.
2. **Unicode Support**: Make sure you are using the Unicode version of Inno Setup to properly display Chinese characters.
3. **Automatic Language Selection**: The installer will automatically select the appropriate language based on the user's system language.
4. **Caching Mechanism**: Downloaded language files are cached to avoid repeated downloads.

## 构建安装程序 / Building the Installer

运行以下命令来构建包含中文语言支持的安装程序：

Run the following command to build an installer with Chinese language support:

```bash
dart run inno_bundle
```

如果是首次使用中文语言，你会看到下载进度信息：

If it's your first time using Chinese languages, you'll see download progress information:

```
🌱  Downloading Chinese Simplified language file...
✅  Chinese Simplified language file downloaded
🌱  Downloading Chinese Traditional language file...
✅  Chinese Traditional language file downloaded
```

安装程序将包含所有配置的语言，用户可以在安装过程中选择他们偏好的语言。

The installer will include all configured languages, and users can select their preferred language during the installation process.