# Penjelasan Praktikum 1: Animasi Lanjutan di Flutter

## A. Penjelasan Langkah Pengerjaan

### 1. Menjalankan starter code

Saya membuka proyek starter aplikasi kuis yang tersedia pada modul, lalu menyiapkan dependensi melalui `flutter pub get`. Setelah itu, saya membuka emulator Android Pixel 9a dan menjalankan aplikasi menggunakan `flutter run`.

Saya mempelajari alur kuis, mulai dari tombol “New Game”, pemilihan jawaban, perpindahan soal, hingga tampilan hasil akhir. Saya memakai alur tersebut sebagai dasar untuk menambahkan animasi.

### 2. Menambahkan animasi pada skor

Saya membuat widget `AnimatedScoreIcon` dan menempatkannya pada `StatusBar`. Saya menambahkan satu ikon untuk satu soal dan menentukan status aktifnya melalui kondisi `index < viewModel.score`.

Saya menggunakan `AnimatedScale` untuk mengubah ukuran ikon serta `TweenAnimationBuilder<Color?>` dengan `ColorTween` untuk mengubah warnanya. Setelah pengguna menjawab dengan benar, pengguna dapat melihat ikon skor membesar dan berganti warna.

### 3. Menambahkan transisi pergantian soal

Saya mengembangkan `QuestionCard` dengan `PageTransitionSwitcher` dari package `animations`, mengikuti tahap akhir pada modul. Saya memberikan `ValueKey(question)` pada kartu untuk membedakan soal lama dengan soal baru.

Saya menggabungkan `FadeThroughTransition`, `FadeTransition`, dan `SlideTransition` untuk menghasilkan efek memudar dan bergeser saat pergantian soal. Saya memakai `Stack` dengan `Alignment.topCenter` agar posisi kartu tetap berada di bagian atas selama transisi.

### 4. Membuat efek kartu jawaban berbalik

Saya membuat widget `CardFlipEffect` pada berkas `card_flip_effect.dart`. Saya menambahkan `SingleTickerProviderStateMixin` dan `AnimationController` untuk mengontrol putaran kartu.

Pada `didUpdateWidget`, saya membandingkan key kartu lama dan kartu baru. Saat key berubah, saya menyimpan tampilan lama dalam `_previousChild`, lalu menjalankan animasi. Saya menggunakan `AnimatedBuilder` dan `Transform.rotateX` untuk membuat putaran sebesar 180 derajat.

Saya menampilkan jawaban lama pada paruh awal putaran dan jawaban baru pada paruh berikutnya. Saya menambahkan `Transform.flip(flipY: true)` agar pengguna dapat membaca jawaban baru dengan posisi yang benar.

Untuk mengatur jeda antarkartu, saya memakai `TweenSequence` dengan `ConstantTween`. Saya membungkus kartu pada `AnswerCards` menggunakan `CardFlipEffect` dan mengisi `delayAmount` dengan `index.toDouble() / 2` agar kartu berbalik bergiliran.

### 5. Mengatur transisi navigasi

Saya menambahkan `pageTransitionsTheme` pada `ThemeData` di `main.dart`. Untuk Android, saya memilih `PredictiveBackPageTransitionsBuilder`. Untuk iOS, macOS, Windows, dan Linux, saya memakai `FadeThroughPageTransitionsBuilder`.

Saya menambahkan `android:enableOnBackInvokedCallback` pada manifest Android untuk mendukung navigasi kembali prediktif. Pengguna memerlukan perangkat Android yang mendukung fitur tersebut untuk mengamati efeknya.

### 6. Membuat halaman hasil kuis

Saya membuat `GameOverScreen` pada berkas `game_over_screen.dart` untuk menampilkan skor akhir. Saya mengganti dialog “Game Over” pada starter dengan halaman hasil dan menghubungkannya melalui `OpenContainer`.

Setelah menjawab soal terakhir, pengguna dapat menekan “Lihat hasil”. Saya memakai transisi `OpenContainer` untuk membuat area kartu soal mengembang menuju halaman hasil. Pada halaman tersebut, saya menambahkan skor akhir dan tombol “Kembali ke beranda”.

### 7. Memeriksa dan menguji aplikasi

Saya menjalankan `flutter analyze` untuk memeriksa kode dan `flutter test` untuk menguji fungsi aplikasi. Saya menguji perhitungan skor, penguncian jawaban, perpindahan soal, serta alur menuju halaman hasil dan kembali ke beranda.

Saya menguji tampilan pada ukuran layar 320 × 640 dan 740 × 360 melalui pengujian widget. Pemeriksaan kode tidak menemukan masalah, dan keempat pengujian lulus. Saya menjalankan aplikasi pada emulator Android Pixel 9a.

## B. Penjelasan Modifikasi

### 1. Mengganti ikon dan warna skor

Saya memilih ikon petir `Icons.bolt_rounded` dengan warna indigo sebagai penanda skor. Pilihan ini mengikuti ketentuan praktikum yang meminta penggunaan ikon dan warna sendiri.

Saya menggunakan abu-abu untuk ikon yang belum aktif. Setelah pengguna memperoleh poin, saya mengubah warna ikon menjadi indigo dan ukurannya dari skala `0.5` menjadi `1.0`. Saya memilih petir untuk menyesuaikan tampilan dengan pesan “Benar! Energi bertambah.” setelah jawaban benar.

Untuk mengganti tampilannya, saya dapat mengubah `Icons.bolt_rounded` pada widget `Icon` dan nilai warna akhir pada `ColorTween`. Saya memakai `Colors.indigo` sebagai warna dasar tema aplikasi melalui `ColorScheme.fromSeed`.

### 2. Menyesuaikan durasi dan pola gerak animasi

Saya mengatur animasi ukuran ikon skor selama 1.000 milidetik dengan `Curves.elasticOut` untuk menghasilkan efek memantul. Pada perubahan warna, saya memakai `Curves.easeOutCubic` agar perubahan warnanya melambat menjelang akhir.

Untuk pergantian soal, saya memilih durasi 400 milidetik dengan `Curves.easeInCubic` pada efek geser dan memudar. Saya mengatur putaran kartu jawaban selama 500 milidetik per kartu, di luar jeda antarkartu, menggunakan `Curves.easeInOutCubic`.

Saya dapat menyesuaikan kecepatan melalui `Duration` dan pola gerak melalui properti `curve`. Pada kartu jawaban, saya dapat mengubah jarak waktu antarputaran melalui nilai `delayAmount`.

### 3. Menambahkan animasi angka skor akhir

Saya menambahkan animasi angka skor pada `GameOverScreen` sebagai pengembangan di luar langkah wajib modul. Pengguna dapat melihat angka bertambah dari nol menuju jumlah jawaban benar.

Saya menggunakan `TweenAnimationBuilder<double>` dengan nilai awal `0` dan nilai akhir `score.toDouble()`. Saya mengatur durasinya selama 1.000 milidetik dengan `Curves.easeOutCubic`, lalu memakai `value.round()` untuk menampilkan bilangan bulat. Jika pengguna memperoleh tiga poin, pengguna akan melihat angka naik dari nol sampai tiga.

Saya menambahkan efek ini untuk memberi penekanan pada hasil kuis. Saya dapat mengubah durasi dan curve tanpa mengubah perhitungan skor.

### 4. Menambahkan tombol untuk membuka hasil

Saya menambahkan tombol “Lihat hasil” setelah pengguna menjawab soal terakhir. Pengguna dapat mengamati perubahan ikon skor sebelum membuka halaman hasil melalui efek `OpenContainer`.

Saya mengatur transisi menuju halaman hasil selama 700 milidetik. Pada halaman hasil, pengguna dapat menekan “Kembali ke beranda” untuk memulai permainan baru.

### 5. Menambahkan umpan balik jawaban dan penguncian pilihan

Saya menambahkan warna hijau dan ikon centang pada jawaban benar. Untuk pilihan salah, saya memakai warna kesalahan dari tema dan ikon silang. Saya menyertakan teks umpan balik setelah pengguna menjawab.

Saya membatasi satu pilihan untuk satu soal melalui pemeriksaan `didAnswerQuestion` pada `QuizViewModel`. Saya menonaktifkan penekanan kartu setelah pengguna memilih jawaban agar pengguna tidak memperoleh poin tambahan dari penekanan berulang. Saya mengaktifkan tombol “Berikutnya” setelah pengguna menjawab.
