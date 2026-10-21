-- =====================================================
-- OTO MOBIL WONOSOBO - Setup Supabase
-- Jalankan di: Supabase Dashboard > SQL Editor > New query
-- =====================================================

-- 1) Tabel mobil
create table if not exists public.cars (
  id            bigint generated always as identity primary key,
  title         text    not null,
  brand         text    not null,
  body          text    not null default 'MPV',
  year          int     not null,
  price         bigint  not null check (price >= 0),
  mileage       text,
  transmission  text    not null default 'Otomatis',
  fuel          text    not null default 'Bensin',
  color         text,
  image         text,                       -- foto utama (cover)
  images        text[]  not null default '{}', -- semua foto (indeks 0 = foto utama)
  description   text,
  status        text    not null default 'tersedia' check (status in ('tersedia','terjual')),
  is_featured   boolean not null default false,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);

-- Jika tabel `cars` SUDAH dibuat sebelumnya (tanpa kolom images), jalankan 2 baris ini:
alter table public.cars add column if not exists images text[] not null default '{}';
update public.cars set images = array[image] where image is not null and cardinality(images) = 0;

create index if not exists cars_status_idx on public.cars (status);
create index if not exists cars_created_idx on public.cars (created_at desc);

-- 2) Auto-update kolom updated_at
create or replace function public.set_updated_at()
returns trigger language plpgsql as $$
begin
  new.updated_at = now();
  return new;
end $$;

drop trigger if exists trg_cars_updated on public.cars;
create trigger trg_cars_updated before update on public.cars
for each row execute function public.set_updated_at();

-- 3) Row Level Security
--    Publik boleh MELIHAT mobil; hanya admin (user login) yang boleh ubah data.
alter table public.cars enable row level security;

drop policy if exists "cars_public_read"   on public.cars;
drop policy if exists "cars_admin_insert"  on public.cars;
drop policy if exists "cars_admin_update"  on public.cars;
drop policy if exists "cars_admin_delete"  on public.cars;

create policy "cars_public_read"  on public.cars for select using (true);
create policy "cars_admin_insert" on public.cars for insert to authenticated with check (true);
create policy "cars_admin_update" on public.cars for update to authenticated using (true) with check (true);
create policy "cars_admin_delete" on public.cars for delete to authenticated using (true);

-- 4) Storage bucket untuk foto mobil (publik dibaca, hanya admin yang upload)
insert into storage.buckets (id, name, public)
values ('car-images', 'car-images', true)
on conflict (id) do nothing;

drop policy if exists "car_images_public_read"  on storage.objects;
drop policy if exists "car_images_admin_insert" on storage.objects;
drop policy if exists "car_images_admin_update" on storage.objects;
drop policy if exists "car_images_admin_delete" on storage.objects;

create policy "car_images_public_read"  on storage.objects for select
  using (bucket_id = 'car-images');
create policy "car_images_admin_insert" on storage.objects for insert to authenticated
  with check (bucket_id = 'car-images');
create policy "car_images_admin_update" on storage.objects for update to authenticated
  using (bucket_id = 'car-images');
create policy "car_images_admin_delete" on storage.objects for delete to authenticated
  using (bucket_id = 'car-images');

-- 5) (Opsional) Data contoh
insert into public.cars (title, brand, body, year, price, mileage, transmission, fuel, color, image, images, description, is_featured)
values
('Toyota Kijang Innova Reborn 2.4 V AT','Toyota','MPV',2020,335000000,'45.000 km','Otomatis','Diesel','Hitam Metalik',
 'https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=800&q=80',
 array['https://images.unsplash.com/photo-1549399542-7e3f8b79c341?auto=format&fit=crop&w=800&q=80'],
 'Kondisi istimewa, mulus rawatan bengkel resmi Toyota. Bebas kecelakaan dan bebas banjir.', true),
('Honda Brio RS 1.2 CVT','Honda','Hatchback',2021,178000000,'28.000 km','Otomatis','Bensin','Kuning Kunyit',
 'https://images.unsplash.com/photo-1590362891991-f776e747a588?auto=format&fit=crop&w=800&q=80',
 array['https://images.unsplash.com/photo-1590362891991-f776e747a588?auto=format&fit=crop&w=800&q=80'],
 'Mobil lincah perkotaan. Tangan pertama dari baru, surat lengkap.', true);

-- =====================================================
-- LANGKAH WAJIB SETELAH INI:
-- 1. Authentication > Users > Add user  -> buat akun admin (email + password)
-- 2. Authentication > Sign In / Providers > matikan "Allow new users to sign up"
--    (supaya orang lain tidak bisa mendaftar dan ikut mengubah data)
-- =====================================================
