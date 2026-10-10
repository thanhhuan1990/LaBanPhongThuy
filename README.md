# La Bàn Phong Thuỷ

App Flutter xem la bàn phong thuỷ theo Mệnh, Can Chi và Cung phi của người dùng.

## Yêu cầu môi trường

| Thành phần | Phiên bản |
|---|---|
| Flutter | 3.47.x (stable) |
| JDK | 17 trở lên (dùng JBR đi kèm Android Studio) |
| Gradle | 9.3.1 (tự tải qua wrapper) |
| Android Gradle Plugin | 9.1.0 |
| Kotlin | 2.4.0 |

Kiểm tra môi trường:

```bash
flutter doctor --verbose
```

## Chạy debug

```bash
flutter pub get
flutter run
```

Ở chế độ debug, app dùng ad unit test của Google, không dùng ad unit thật.

## Build release (Android)

### 1. Lấy file ký app

Hai file sau **không có trong git** mà được lưu trên **Google Drive cá nhân** của tác giả:

- `key.properties`: chứa mật khẩu và alias của keystore
- `keystore`: file keystore dùng để ký app

Tải về và đặt vào thư mục `android/`:

```
android/
├── key.properties
└── keystore
```

Trong `android/key.properties`, dòng `storeFile` phải trỏ đúng tới keystore. Đường dẫn tương đối được tính từ `android/app/`:

```properties
storeFile=../keystore
```

> Không commit hai file này. Chúng đã có trong `android/.gitignore`.
> Nếu mất keystore thì không phát hành được bản cập nhật cho app trên Google Play.

### 2. Tăng version

Sửa `version` trong `pubspec.yaml`. Số sau dấu `+` là `versionCode` và phải lớn hơn bản đã upload lên Google Play:

```yaml
version: 1.1.3+7
```

### 3. Build

App bundle để upload lên Google Play:

```bash
flutter build appbundle --release
```

File output: `build/app/outputs/bundle/release/app-release.aab`

APK để cài thử trực tiếp:

```bash
flutter build apk --release
```

File output: `build/app/outputs/flutter-apk/app-release.apk`

### 4. Kiểm tra chữ ký

```bash
keytool -printcert -jarfile build/app/outputs/bundle/release/app-release.aab
```

SHA1 phải khớp với upload key trong Play Console (Setup → App signing).

## Ghi chú

- `permission_handler_android` đang được ghim ở `13.0.1` qua `dependency_overrides` trong `pubspec.yaml`, vì bản 14.x yêu cầu compileSdk 37 mà AGP 9.1 chưa nhận diện được. Bỏ override khi AGP hỗ trợ.
- Quảng cáo AdMob: ad unit ID nằm trong `lib/utils/ad_helper.dart`, App ID nằm trong `android/app/src/main/AndroidManifest.xml`.
