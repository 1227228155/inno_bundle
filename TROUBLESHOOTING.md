# 中文语言支持故障排除指南

## 问题描述

如果你遇到以下错误：
```
Error on line 35 in inno-script.iss: Couldn't open include file "C:\Users\...\Languages\Unofficial\ChineseSimplified.isl": 系统找不到指定的路径。
```

## 解决步骤

### 步骤 1: 清理缓存和构建文件

```bash
# 清理 Dart 包缓存
dart pub cache clean

# 删除项目构建目录
rmdir /s /q build

# 清理 inno_bundle 缓存（如果可用）
dart run inno_bundle:debug --clear
```

### 步骤 2: 确保使用最新版本

在 `pubspec.yaml` 中：

```yaml
dev_dependencies:
  inno_bundle:
    git:
      url: https://github.com/1227228155/inno_bundle
      ref: dev  # 或最新的标签
```

然后运行：
```bash
dart pub get
```

### 步骤 3: 验证配置

确保你的 `pubspec.yaml` 中的语言配置正确：

```yaml
inno_bundle:
  languages:
    - english
    - chineseSimplified    # 注意：不是 chinese_simplified
    - chineseTraditional   # 注意：不是 chinese_traditional
```

### 步骤 4: 手动清理系统临时文件

删除系统临时目录中的 inno_bundle 相关文件：

Windows:
```cmd
cd %TEMP%
for /d %i in (inno_bundle*) do rmdir /s /q "%i"
```

### 步骤 5: 重新构建

```bash
dart run inno_bundle
```

## 调试工具

如果问题仍然存在，使用内置的调试工具：

```bash
# 显示调试信息
dart run inno_bundle:debug --info

# 清理所有缓存
dart run inno_bundle:debug --clear
```

## 常见问题

### Q: 为什么会出现 "Languages\Unofficial\ChineseSimplified.isl" 路径？

A: 这通常表示你使用的是旧版本的插件。新版本会自动下载中文语言文件并使用绝对路径。

### Q: 网络问题导致下载失败怎么办？

A: 插件会自动使用备用下载源。如果仍然失败，请检查网络连接或稍后重试。

### Q: 如何验证中文语言文件是否正确下载？

A: 运行调试命令查看缓存信息：
```bash
dart run inno_bundle:debug --info
```

### Q: 在 CI/CD 环境中如何处理？

A: 确保 CI 环境有网络访问权限下载语言文件，或者预先缓存这些文件。

## 技术细节

新版本的 inno_bundle 会：

1. 自动检测 Inno Setup 安装目录中是否存在中文语言文件
2. 如果不存在，从 GitHub 自动下载
3. 使用绝对路径引用下载的文件
4. 缓存文件以避免重复下载

生成的脚本应该包含类似这样的条目：
```
Name: "chineseSimplified"; MessagesFile: "C:\Users\...\Temp\inno_bundle_...\Languages\ChineseSimplified.isl"
```

而不是：
```
Name: "chineseSimplified"; MessagesFile: "compiler:Languages\Unofficial\ChineseSimplified.isl"
```

## 联系支持

如果以上步骤都无法解决问题，请提供以下信息：

1. 运行 `dart run inno_bundle:debug --info` 的输出
2. 你的 `pubspec.yaml` 配置
3. 完整的错误信息
4. 操作系统版本和 Dart 版本