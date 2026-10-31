class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.body,
  });

  final String id;
  final String title;
  final String body;
}

/// Data contoh untuk halaman tujuan deep link `/pengumuman/:id`.
const List<Announcement> sampleAnnouncements = <Announcement>[
  Announcement(
    id: '1',
    title: 'Jadwal UTS semester ganjil',
    body: 'Ujian Tengah Semester dilaksanakan 20-25 Oktober 2026. '
        'Cek jadwal per mata kuliah pada portal akademik.',
  ),
  Announcement(
    id: '2',
    title: 'Pendaftaran KP dibuka',
    body: 'Pendaftaran Kerja Praktik gelombang 2 dibuka sampai 31 Oktober 2026. '
        'Syarat: minimal 100 SKS dan tidak ada nilai E.',
  ),
  Announcement(
    id: '3',
    title: 'Jadwal kuliah berubah',
    body: 'Kelas Pemrograman Mobile pindah ke Ruang A2, '
        'dimulai pukul 13.00 WIB.',
  ),
];

Announcement? findAnnouncement(String id) {
  for (final announcement in sampleAnnouncements) {
    if (announcement.id == id) return announcement;
  }
  return null;
}
