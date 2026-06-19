# LiquidPedia Mobile - Flutter

Aplikasi mobile e-commerce Liquid & Vape berbasis Flutter yang terhubung dengan REST API Laravel (Sanctum).

## Persyaratan Sistem

| Komponen | Versi Minimal | Keterangan |
|---|---|---|
| Flutter | 3.41+ | SDK Flutter |
| Dart | 3.11+ | |
| Android Studio | Hedgehog+ | IDE + Android SDK |
| Java | 17+ | JDK untuk Android |
| Laravel Backend | - | `liquidpedia` API harus berjalan |

## Tech Stack

| Teknologi | Kegunaan |
|---|---|
| **Flutter** | Framework UI mobile |
| **Provider** | State management (MVVM) |
| **Dio** | HTTP Client + Token Interceptor |
| **flutter_secure_storage** | Penyimpanan token Sanctum |
| **flutter_map** + **latlong2** | OpenStreetMap untuk location picker |
| **cached_network_image** | Caching gambar produk |
| **intl** | Format mata uang & tanggal |
| **shimmer** | Loading skeleton |
| **url_launcher** | WhatsApp, tel, email |
| **geocoding** | Reverse geocode lokasi |

## Arsitektur

```
lib/
├── main.dart                          # Entry point + Provider setup
├── config/
│   ├── api_config.dart                # Base URL API
│   ├── theme.dart                     # Tema LiquidPedia (#D84040)
│   └── routes.dart                    # Route constants
├── services/
│   └── api_service.dart               # Dio + interceptor token + multipart
├── models/                            # Data class dari JSON API
│   ├── user.dart
│   ├── product.dart
│   ├── category.dart
│   ├── cart_item.dart
│   ├── order.dart
│   ├── order_item.dart
│   └── dashboard_stats.dart
├── repositories/                      # Layer akses data
│   ├── auth_repository.dart
│   ├── product_repository.dart
│   ├── cart_repository.dart
│   ├── order_repository.dart
│   └── admin_repository.dart
├── providers/                         # State management (ChangeNotifier)
│   ├── auth_provider.dart
│   ├── product_provider.dart
│   ├── cart_provider.dart
│   ├── order_provider.dart
│   └── admin_provider.dart
├── views/                             # Halaman aplikasi
│   ├── splash_screen.dart
│   ├── auth/ (login, register)
│   ├── home/ (beranda)
│   ├── products/ (list, detail)
│   ├── cart/ (keranjang)
│   ├── checkout/ (form + map)
│   ├── orders/ (riwayat, detail)
│   ├── profile/
│   └── admin/ (dashboard, products, categories, orders)
└── widgets/                           # Komponen reusable
    ├── product_card.dart              # Redesigned card + badge + add-to-cart mini
    ├── loading_widget.dart
    ├── location_picker.dart           # Map OpenStreetMap + gesture fix
    └── payment_method_picker.dart
```

## Screens & API Mapping

| Screen | Endpoint API |
|--------|-------------|
| **Splash** (auto-login) | `GET /api/auth/user` |
| **Login** | `POST /api/auth/login` |
| **Register** | `POST /api/auth/register` |
| **Home** (Best Seller, New Arrival, Kategori) | `GET /api/products/home` |
| **Product List** (filter kategori) | `GET /api/products?category=slug` |
| **Product Detail** | `GET /api/products/{id}` |
| **Cart** (CRUD) | `GET/POST/PUT/DELETE /api/cart/{product}` |
| **Checkout** (form + map OSM) | `POST /api/orders` |
| **Order List** (pagination) | `GET /api/orders` |
| **Order Detail** + Payment Instructions | `GET /api/orders/{id}` + `GET /api/orders/{id}/payment` |
| **Profile** | `GET /api/auth/user` |

## Cara Menjalankan

### 1. Clone Repository

```bash
git clone https://github.com/username/liquid-mobile.git
cd liquid_mobile
```

### 2. Install Dependency

```bash
flutter pub get
```

### 3. Konfigurasi API

Edit `lib/config/api_config.dart`:

```dart
class ApiConfig {
  static const String baseUrl = 'http://localhost:8000';
  static const String apiPrefix = '/api/';
  static const Duration timeout = Duration(seconds: 30);
}
```

- **Emulator Android:** `http://localhost:8000` (dengan `adb reverse`)
- **Device fisik:** `http://[IP_HOST]:8000` (ganti dengan IP komputer)

### 4. Setup ADB Reverse (khusus emulator Android)

Setiap kali emulator di-restart:

```bash
adb reverse tcp:8000 tcp:8000
```

### 5. Pastikan Backend Laravel Berjalan

```bash
cd ../liquid
php artisan serve --host=0.0.0.0 --port=8000
```

### 6. Jalankan Aplikasi

Dari terminal:

```bash
flutter run
```

Atau buka project di **Android Studio** → klik **Run** (▶️).

## Akun Login

| Role | Email | Password |
|------|-------|----------|
| **Admin** | `admin@liquidpedia.id` | `admin123` |
| **Customer** | Registrasi manual | - |

## Fitur Aplikasi

### Storefront
- Beranda dengan produk Best Seller & New Arrival
- Katalog produk filter per kategori (Vape / Liquid)
- Pencarian produk dengan debounce 500ms
- Detail produk dengan info table (Kategori, Status, Garansi)
- Keranjang belanja (database-based) dengan badge real-time
- Checkout dengan form pengiriman + **OpenStreetMap location picker**
- 4 metode pembayaran: Transfer Bank, E-Wallet, QRIS, COD
- Konfirmasi pesanan via WhatsApp
- **Cancel order** (selama status masih pending)
- Copy-to-clipboard nomor rekening / e-wallet
- Entry animations (AnimatedOpacity + SlideTransition)

### Admin Panel (via Profile → Admin Panel)
- Dashboard statistik (total produk, kategori, pesanan, pendapatan)
- CRUD Produk dengan upload gambar
- CRUD Kategori
- Manajemen Pesanan + update status pembayaran
- Tombol "Lihat Petunjuk Pembayaran" & "Batalkan Pesanan"

### Manajemen Akun
- Register / Login customer
- Profil pengguna
- Riwayat pesanan dengan status pembayaran
- Detail pesanan + instruksi pembayaran

## Tema

| Warna | Nilai |
|-------|-------|
| Primary | `#D84040` (merah) |
| Secondary | `#8E1616` (merah tua) |
| Accent | `#1D1616` (hampir hitam) |
| Background | `#EEEEEE` (abu terang) |

## Troubleshooting

| Masalah | Solusi |
|---------|--------|
| `Connection refused` | Laravel server tidak berjalan, jalankan `php artisan serve` |
| `SocketException` | ADB reverse belum di-set, jalankan `adb reverse tcp:8000 tcp:8000` |
| `Method not supported` | Cek `apiPrefix` di `api_config.dart` harus `/api/` (dengan slash) |
| Login gagal "Email atau password salah" | Gunakan akun yang sudah terdaftar di database |
| Gambar tidak muncul | Pastikan `php artisan storage:link` sudah dijalankan di backend |
| Map tidak tampil | Koneksi internet aktif (tile OSM dari internet) |

## Catatan

- Aplikasi ini membutuhkan backend Laravel yang berjalan (`liquidpedia`)
- Cart bersifat user-based (harus login untuk checkout)
- Token Sanctum disimpan di `flutter_secure_storage`
- API base URL bisa diubah di `lib/config/api_config.dart`
