# BLE 智能药盒 App

一个用于连接 BLE 设备并读取温度、湿度和药品余量的 Flutter 应用。

## 功能特点

- ✅ 自动扫描并连接指定 BLE 设备 (MAC: C2:38:B1:17:AA:FC)
- ✅ 实时显示温度、湿度、药品余量
- ✅ 完美支持 Android 14+
- ✅ 自动处理蓝牙权限

## 使用方法（无需安装 Flutter）

### 方法一：使用 GitHub Actions 自动编译（推荐）

1. **创建 GitHub 账号**
   - 访问 https://github.com/
   - 注册免费账号

2. **创建新仓库**
   - 点击右上角 "+" → "New repository"
   - 仓库名：`ble-app`
   - 选择 "Public"
   - 勾选 "Add a README file"
   - 点击 "Create repository"

3. **上传项目文件**
   - 将本项目的所有文件上传到 GitHub 仓库
   - 包括：`lib/`, `android/`, `pubspec.yaml`, `.github/` 等

4. **等待自动编译**
   - 上传后，GitHub 会自动开始编译
   - 点击顶部 "Actions" 标签页查看进度
   - 等待约 5-10 分钟

5. **下载 APK**
   - 编译完成后，在 Actions 页面点击最新的运行记录
   - 在 "Artifacts" 部分下载 `ble-app-release-apk`
   - 解压后得到 `app-release.apk`

6. **安装到手机**
   - 将 APK 文件传输到安卓手机
   - 在手机上点击安装（需开启"允许安装未知来源应用"）

### 方法二：使用在线 Flutter 编译服务

如果你不想使用 GitHub，可以使用在线编译服务：

1. 访问 https://zapp.run/ 或 https://flutlab.io/
2. 创建新项目
3. 复制 `lib/main.dart` 和 `pubspec.yaml` 的内容
4. 点击编译按钮
5. 下载生成的 APK

## 项目结构

```
ble-app/
├── lib/
│   └── main.dart          # 主程序文件
├── android/
│   ├── app/
│   │   └── src/main/
│   │       └── AndroidManifest.xml  # 权限配置
│   ├── build.gradle       # 项目级构建配置
│   └── app/build.gradle  # 应用级构建配置
├── pubspec.yaml           # 依赖配置
└── .github/
    └── workflows/
        └── build.yml      # GitHub Actions 自动编译配置
```

## 设备要求

- BLE 设备 MAC 地址：`C2:38:B1:17:AA:FC`
- 数据格式（JSON）：`{"temp": 25, "humidity": 60, "weight": 100}`

## 故障排除

### 如果无法连接设备：

1. 确保手机蓝牙已开启
2. 确保 BLE 设备在附近并已通电
3. 在手机设置中授予应用所有权限：
   - 位置信息 → 允许
   - 附近的设备 → 允许
   - 蓝牙 → 允许

### 如果编译失败：

- 检查 GitHub Actions 日志中的错误信息
- 确保所有文件已正确上传
- 可以尝试重新触发编译（删除并重新推送代码）

## 自定义修改

### 修改设备 MAC 地址

编辑 `lib/main.dart`，找到：
```dart
if (result.device.remoteId.toString().toUpperCase() == 'C2:38:B1:17:AA:FC') {
```
将 `'C2:38:B1:17:AA:FC'` 改为你的设备 MAC 地址。

### 修改显示的数据字段

如果你的 JSON 数据格式不同，编辑 `parseData` 函数：
```dart
void parseData(String rawData) {
  Map<String, dynamic> data = jsonDecode(rawData);
  setState(() {
    temperature = data['temp']?.toString() ?? '--';
    humidity = data['humidity']?.toString() ?? '--';
    medicineRemaining = data['weight']?.toString() ?? '--';
  });
}
```

将 `'temp'`, `'humidity'`, `'weight'` 改为你的 JSON 中的字段名。

## 技术支持

如有问题，请检查：
- BLE 设备是否正常工作
- 手机 Android 版本是否为 14+
- 应用权限是否已全部授予

---

**祝你使用愉快！**
