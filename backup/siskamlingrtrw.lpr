program siskamlingrtrw;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, Crt;

const
  MAX_QUEUE = 100;
  MAX_DATA = 100;
  NAMA_FILE = 'laporan_rtrw.dat';

type
  { 1. Konsep: RECORD }
  TKejadian = record
    Waktu: string[10];      // Format HH:MM
    Lokasi: string[50];
    Kategori: string[30];   // Pencurian, Mencurigakan, dll
    TingkatBahaya: integer; // 1 (Rendah) - 3 (Tinggi)
  end;

  TPetugas = record
    Nama: string[50];
    Blok: string[10];
  end;

var
  // Variabel Global untuk File Handling & Array
  DataLaporan: array[1..MAX_DATA] of TKejadian;
  JumlahLaporan: integer;
  FileLaporan: file of TKejadian;

  // Variabel Global untuk Queue
  AntreanRonda: array[1..MAX_QUEUE] of TPetugas;
  Head, Tail: integer;

{ ================= KUMPULAN PROSEDUR QUEUE ================= }
procedure InitQueue;
begin
  Head := 1;
  Tail := 0;
end;

procedure Enqueue(PetugasBaru: TPetugas);
begin
  if Tail < MAX_QUEUE then
  begin
    Inc(Tail);
    AntreanRonda[Tail] := PetugasBaru;
    Writeln('Petugas ', PetugasBaru.Nama, ' berhasil ditambahkan ke jadwal ronda.');
  end else
    Writeln('Antrean jadwal ronda penuh!');
end;

procedure Dequeue;
var
  PetugasAktif: TPetugas;
begin
  if Head > Tail then
    Writeln('Tidak ada petugas dalam jadwal ronda saat ini.')
  else
  begin
    PetugasAktif := AntreanRonda[Head];
    Inc(Head);
    Writeln('Petugas ', PetugasAktif.Nama, ' (Blok ', PetugasAktif.Blok, ') sedang melaksanakan patroli aktif!');
  end;
end;

procedure TampilJadwalRonda;
var
  i: integer;
begin
  Writeln('--- DAFTAR PETUGAS SIAGA (QUEUE) ---');
  if Head > Tail then
    Writeln('Antrean kosong.')
  else
  begin
    for i := Head to Tail do
      Writeln(i - Head + 1, '. ', AntreanRonda[i].Nama, ' - Blok ', AntreanRonda[i].Blok);
  end;
end;

{ ================= KUMPULAN PROSEDUR FILE HANDLING ================= }
{ 3. Konsep: FILE HANDLING }
procedure LoadDataLaporan;
var
  TempData: TKejadian;
begin
  JumlahLaporan := 0;
  AssignFile(FileLaporan, NAMA_FILE);
  {$I-} Reset(FileLaporan); {$I+}
  if IOResult = 0 then
  begin
    while not EOF(FileLaporan) do
    begin
      Read(FileLaporan, TempData);
      Inc(JumlahLaporan);
      DataLaporan[JumlahLaporan] := TempData;
    end;
    CloseFile(FileLaporan);
  end
  else
  begin
    // Jika file belum ada, buat baru
    Rewrite(FileLaporan);
    CloseFile(FileLaporan);
  end;
end;

procedure SaveDataLaporan;
var
  i: integer;
begin
  AssignFile(FileLaporan, NAMA_FILE);
  Rewrite(FileLaporan);
  for i := 1 to JumlahLaporan do
    Write(FileLaporan, DataLaporan[i]);
  CloseFile(FileLaporan);
end;

procedure TambahLaporan;
begin
  ClrScr;
  Writeln('=== INPUT LAPORAN KEAMANAN ===');
  if JumlahLaporan < MAX_DATA then
  begin
    Inc(JumlahLaporan);
    with DataLaporan[JumlahLaporan] do
    begin
      Write('Waktu Kejadian (HH:MM) : '); Readln(Waktu);
      Write('Titik/Lokasi Kejadian  : '); Readln(Lokasi);
      Write('Kategori/Deskripsi     : '); Readln(Kategori);
      Write('Tingkat Bahaya (1-3)   : '); Readln(TingkatBahaya);
    end;
    SaveDataLaporan;
    Writeln('Laporan berhasil disimpan!');
  end else
    Writeln('Kapasitas penyimpanan laporan penuh!');
  Readln;
end;

{ ================= KUMPULAN PROSEDUR SORTING ================= }
{ 4. Konsep: SORTING KEJADIAN }
procedure UrutkanLaporanByBahaya;
var
  i, j: integer;
  Temp: TKejadian;
begin
  // Menggunakan algoritma Bubble Sort (Descending - Bahaya Tertinggi di atas)
  for i := 1 to JumlahLaporan - 1 do
    for j := 1 to JumlahLaporan - i do
      if DataLaporan[j].TingkatBahaya < DataLaporan[j+1].TingkatBahaya then
      begin
        Temp := DataLaporan[j];
        DataLaporan[j] := DataLaporan[j+1];
        DataLaporan[j+1] := Temp;
      end;
end;

procedure TampilStatistik;
var
  i: integer;
begin
  ClrScr;
  Writeln('=== STATISTIK & ANALISIS JAM RAWAN ===');
  if JumlahLaporan = 0 then
    Writeln('Belum ada data laporan keamanan.')
  else
  begin
    UrutkanLaporanByBahaya; // Panggil sorting sebelum tampil
    Writeln('Data diurutkan berdasarkan Tingkat Bahaya tertinggi:');
    Writeln('--------------------------------------------------------------');
    Writeln('No | Waktu | Lokasi               | Kategori           | Level');
    Writeln('--------------------------------------------------------------');
    for i := 1 to JumlahLaporan do
    begin
      with DataLaporan[i] do
        Writeln(i:2, ' | ', Waktu:5, ' | ', Lokasi:20, ' | ', Kategori:18, ' | ', TingkatBahaya:3);
    end;
    Writeln('--------------------------------------------------------------');
    Writeln('*Sistem Analisis: Jam yang paling sering muncul adalah Jam Rawan.');
  end;
  Readln;
end;

{ ================= KUMPULAN PROSEDUR MENU ================= }
{ 5. Konsep: MULTI-LEVEL MENU }
procedure SubMenuRonda;
var
  Pilihan: char;
  PBaru: TPetugas;
begin
  repeat
    ClrScr;
    Writeln('=== MENU MANAJEMEN PETUGAS & RONDA ===');
    Writeln('1. Tambah Petugas ke Jadwal (Enqueue)');
    Writeln('2. Berangkatkan Patroli Pintar (Dequeue)');
    Writeln('3. Monitoring Petugas Siaga');
    Writeln('0. Kembali ke Menu Utama');
    Write('Pilih menu: '); Readln(Pilihan);

    case Pilihan of
      '1': begin
             Write('Masukkan Nama Petugas: '); Readln(PBaru.Nama);
             Write('Masukkan Blok Area   : '); Readln(PBaru.Blok);
             Enqueue(PBaru);
             Readln;
           end;
      '2': begin
             Dequeue;
             Readln;
           end;
      '3': begin
             TampilJadwalRonda;
             Readln;
           end;
    end;
  until Pilihan = '0';
end;

procedure SubMenuLaporan;
var
  Pilihan: char;
begin
  repeat
    ClrScr;
    Writeln('=== DASHBOARD KEAMANAN WARGA ===');
    Writeln('1. Input Laporan Keamanan Baru');
    Writeln('2. Statistik & Peringatan Jam Rawan (Sorted)');
    Writeln('0. Kembali ke Menu Utama');
    Write('Pilih menu: '); Readln(Pilihan);

    case Pilihan of
      '1': TambahLaporan;
      '2': TampilStatistik;
    end;
  until Pilihan = '0';
end;

var
  MenuUtama: char;

begin
  // Inisialisasi awal program
  InitQueue;
  LoadDataLaporan;

  repeat
    ClrScr;
    Writeln('==================================================');
    Writeln('  SISTEM MONITORING KEAMANAN LINGKUNGAN RT/RW     ');
    Writeln('==================================================');
    Writeln('1. Modul Patroli & Jadwal Ronda');
    Writeln('2. Modul Laporan & Dashboard Warga');
    Writeln('0. Keluar Aplikasi');
    Writeln('==================================================');
    Write('Pilihan Anda: '); Readln(MenuUtama);

    case MenuUtama of
      '1': SubMenuRonda;
      '2': SubMenuLaporan;
    end;
  until MenuUtama = '0';

  Writeln('Terima kasih telah menggunakan sistem ini. Tetap Aman!');
  Sleep(1000);
end.
