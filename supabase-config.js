// =====================================================
// KONFIGURASI SUPABASE - OTO MOBIL WONOSOBO
// File ini dipakai bersama oleh website & admin panel.
// Letakkan di folder yang sama dengan file HTML.
// Ambil nilainya di: Supabase > Project Settings > API
// =====================================================
const SUPABASE_URL  = 'https://zewvvtbscvkcndwxieie.supabase.co';
const SUPABASE_ANON = 'ISI_DENGAN_ANON_PUBLIC_KEY'; // pakai kunci "anon public", JANGAN service_role
const BUCKET        = 'car-images';                 // nama bucket foto (sama dengan di SQL setup)

// Alamat halaman (relatif atau lengkap). Ubah jika nama file / foldernya berbeda.
const ADMIN_URL = 'admin_oto_mobil_wonosobo.html';  // dibuka otomatis setelah admin Log In di website
const SITE_URL  = 'oto_mobil_wonosobo_supabase.html'; // tombol "Lihat Website" di admin panel
