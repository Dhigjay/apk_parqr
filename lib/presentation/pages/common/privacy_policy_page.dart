import 'package:flutter/material.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kebijakan Privasi'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSection(
              '1. Pendahuluan',
              'Aplikasi PARQR menghargai privasi Anda. Kami berkomitmen untuk melindungi informasi pribadi Anda sesuai dengan ketentuan yang berlaku.',
            ),
            _buildSection(
              '2. Data yang Dikumpulkan',
              'Kami mengumpulkan beberapa data saat Anda menggunakan aplikasi ini, antara lain:\n\n'
                  '• Nama\n'
                  '• Email\n'
                  '• Nomor kendaraan\n'
                  '• Informasi lahan parkir\n'
                  '• Riwayat parkir\n'
                  '• Lokasi (saat diperlukan untuk fitur parkir)',
            ),
            _buildSection(
              '3. Penggunaan Data',
              'Data yang kami kumpulkan digunakan untuk:\n\n'
                  '• Autentikasi akun\n'
                  '• Proses booking parkir\n'
                  '• Pembuatan QR masuk dan keluar\n'
                  '• Validasi kendaraan\n'
                  '• Peningkatan layanan kami',
            ),
            _buildSection(
              '4. Penyimpanan Data',
              'Semua data Anda disimpan secara aman menggunakan layanan backend (Supabase) yang dilengkapi dengan sistem keamanan standar industri.',
            ),
            _buildSection(
              '5. Keamanan Data',
              'Aplikasi PARQR berusaha melindungi data pengguna melalui sistem autentikasi terenkripsi dan kontrol akses (Row Level Security) untuk mencegah akses data yang tidak sah.',
            ),
            _buildSection(
              '6. Hak Pengguna',
              'Sebagai pengguna, Anda berhak untuk:\n\n'
                  '• Mengubah profil Anda\n'
                  '• Mengubah password akun Anda\n'
                  '• Menghubungi pengelola apabila Anda ingin menghapus akun beserta data terkait',
            ),
            _buildSection(
              '7. Perubahan Kebijakan',
              'Kebijakan privasi ini dapat diperbarui sewaktu-waktu. Perubahan signifikan akan diinformasikan melalui pembaruan aplikasi atau melalui email yang terdaftar.',
            ),
            _buildSection(
              '8. Kontak',
              'Apabila Anda memiliki pertanyaan lebih lanjut, silakan hubungi kami melalui:\n\n'
                  'Email: support@parqr.id\n'
                  'Atau hubungi Administrator Sistem PARQR',
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            content,
            style: const TextStyle(
              fontSize: 15,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}
