program SiskamlingRTRW;

{$mode objfpc}{$H+}

uses
  Classes, SysUtils, Crt;

const
  MAX_QUEUE = 100;
  MAX_DATA = 100;
  NAMA_FILE = 'laporan_rtrw.dat';

type
  { --- 1. RECORD --- }
  TKejadian = record
    Waktu: string[10];      // Format HH:MM
    Lokasi: string[50];
    Kategori: string[30];
    TingkatBahaya: integer; // 1 (Rendah) - 3 (Tinggi)
  end;

  TPetugas = record
    Nama: string[50];
    Blok: string[10];
  end;

var
  // File Handling & Data Array
  DataLaporan: array[1..MAX_DATA] of TKejadian;
  JumlahLaporan: integer;
  FileLaporan: file of TKejadian;

  // Queue (Antrean)
  AntreanRonda: array[1..MAX_QUEUE] of TPetugas;
  Head, Tail: integer;

  // Status Petugas (Untuk Dashboard & Simulasi)
  PetugasAktif: TPetugas;
  StatusPatroli: Boolean;

{ ================= FUNGSI ANALISIS & INOVASI ================= }
// Mencari jam paling sering terjadi insiden (Inovasi: Analisis Jam Rawan)
function CariJamRawan: integer;
var
  HitungJam: array[0..23] of integer;
  i, MaxCount, JamRawan, JamAktual: integer;
  JamStr: string;
begin
  for i := 0 to 23 do HitungJam[i] := 0; // Reset array
  MaxCount := 0;
  JamRawan := -1; // -1 artinya belum ada data valid

  for i := 1 to JumlahLaporan do
  begin
    JamStr := Copy(DataLaporan[i].Waktu, 1, 2); // Ambil 2 digit pertama (HH)
    JamAktual := StrToIntDef(JamStr, -1);
    if (JamAktual >= 0) and (JamAktual <= 23) then
      Inc(HitungJam[JamAktual]);
  end;

  // Cari frekuensi tertinggi
  for i := 0 to 23 do
  begin
    if HitungJam[i] > MaxCount then
    begin
      MaxCount := HitungJam[i];
      JamRawan := i;
    end;
  end;

  Result := JamRawan; // Mengembalikan jam paling rawan
end;


{ ================= PROSEDUR QUEUE ================= }
procedure InitQueue;
begin
  Head := 1;
  Tail := 0;
  StatusPatroli := False;
end;

procedure Enqueue(PetugasBaru: TPetugas);
begin
  if Tail < MAX_QUEUE then
  begin
    Inc(Tail);
    AntreanRonda[Tail] := PetugasBaru;
    Writeln('Sukses! Petugas ', PetugasBaru.Nama, ' masuk ke jadwal ronda.');
  end else
    Writeln('Antrean jadwal ronda penuh!');
end;

procedure Dequeue;
var
  JamWaspada: integer;
begin
  if Head > Tail then
    Writeln('Tidak ada petugas di jadwal! Silakan tambah petugas (Enqueue) dulu.')
  else
  begin
    // Keluarkan dari antrean dan jadikan petugas aktif
    PetugasAktif := AntreanRonda[Head];
    StatusPatroli := True;
    Inc(Head);

    Writeln('----------------------------------------------------');
    Writeln('PETUGAS DIBERANGKATKAN: ', PetugasAktif.Nama, ' (Blok ', PetugasAktif.Blok, ')');

    // Inovasi: Simulasi Patroli Pintar
    JamWaspada := CariJamRawan;
    if JamWaspada <> -1 then
    begin
      Writeln('[SIMULASI PINTAR AKTIF]');
      Writeln('=> Sistem mendeteksi jam rawan historis pada pukul ', JamWaspada:2, ':00.');
      Writeln('=> Instruksi Sistem: Alokasikan 70% waktu patroli di area rawan pada jam tersebut!');
    end else
      Writeln('=> Instruksi Sistem: Lakukan patroli standar. Belum ada pola bahaya.');
    Writeln('----------------------------------------------------');
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


{ ================= PROSEDUR FILE HANDLING ================= }
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
    Rewrite(FileLaporan); // Buat file baru jika belum ada
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
  Writeln('=== INPUT LAPORAN KEAMANAN ===');
  if JumlahLaporan < MAX_DATA then
  begin
    Inc(JumlahLaporan);
    with DataLaporan[JumlahLaporan] do
    begin
      Write('Waktu Kejadian (Format HH:MM) : '); Readln(Waktu);
      Write('Titik/Lokasi Kejadian         : '); Readln(Lokasi);
      Write('Kategori/Deskripsi            : '); Readln(Kategori);
      Write('Tingkat Bahaya (1:Rendah - 3:Tinggi): '); Readln(TingkatBahaya);
    end;
    SaveDataLaporan;
    Writeln('Laporan berhasil disimpan ke Database!');
  end else
    Writeln('Kapasitas penyimpanan penuh!');
  Readln;
end;


{ ================= PROSEDUR SORTING & DASHBOARD ================= }
procedure UrutkanLaporanByBahaya;
var
  i, j: integer;
  Temp: TKejadian;
begin
  // Bubble Sort: Mengurutkan dari Bahaya Tertinggi (Descending)
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
  if JumlahLaporan = 0 then
    Writeln('Belum ada data laporan keamanan.')
  else
  begin
    UrutkanLaporanByBahaya;
    Writeln('DATA STATISTIK KEJADIAN (Diurutkan Prioritas Bahaya):');
    Writeln('-----------------------------------------------------------------');
    Writeln('No | Waktu | Lokasi               | Kategori           | Level');
    Writeln('-----------------------------------------------------------------');
    for i := 1 to JumlahLaporan do
    begin
      with DataLaporan[i] do
        Writeln(i:2, ' | ', Waktu:5, ' | ', Lokasi:20, ' | ', Kategori:18, ' | ', TingkatBahaya:3);
    end;
    Writeln('-----------------------------------------------------------------');
  end;
  Readln;
end;

// Inovasi: Dashboard Keamanan Warga
procedure TampilDashboard;
var
  JamWaspada: integer;
begin
  JamWaspada := CariJamRawan;
  Writeln('==================================================');
  Writeln('           DASHBOARD KEAMANAN RT/RW               ');
  Writeln('==================================================');
  Writeln(' [Statistik Ringkas]');
  Writeln(' - Total Laporan Masuk : ', JumlahLaporan, ' Kejadian');

  if StatusPatroli then
    Writeln(' - Status Patroli      : AKTIF (Petugas: ', PetugasAktif.Nama, ')')
  else
    Writeln(' - Status Patroli      : KOSONG / STANDBY');

  Writeln(' - Peringatan Keamanan : ');
  if JamWaspada <> -1 then
    Writeln('   [!] WASPADA: Jam Rawan terdeteksi pada pukul ', JamWaspada:2, ':00 [!]')
  else
    Writeln('   (Aman) Belum ada pola jam rawan terdeteksi.');
  Writeln('==================================================');
end;


{ ================= MULTI-LEVEL MENU ================= }
procedure SubMenuRonda;
var
  Pilihan: char;
  PBaru: TPetugas;
begin
  repeat
    ClrScr;
    Writeln('=== MODUL MANAJEMEN PETUGAS & RONDA ===');
    Writeln('1. Enqueue (Tambah Petugas ke Jadwal)');
    Writeln('2. Dequeue (Berangkatkan / Simulasi Patroli)');
    Writeln('3. Monitoring Antrean Petugas');
    Writeln('0. Kembali');
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
    TampilDashboard; // Panggil Dashboard sebagai Header Menu
    Writeln('1. Input Laporan Baru');
    Writeln('2. Tampilkan Detail Statistik (Sorted by Bahaya)');
    Writeln('0. Kembali');
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
  // Inisialisasi awal
  InitQueue;
  LoadDataLaporan;

  repeat
    ClrScr;
    Writeln('==================================================');
    Writeln('   SISTEM MONITORING KEAMANAN LINGKUNGAN RT/RW    ');
    Writeln('==================================================');
    Writeln('1. Manajemen Patroli (Queue & Simulasi)');
    Writeln('2. Laporan & Dashboard Warga (Array, Sort, File)');
    Writeln('0. Keluar Aplikasi');
    Writeln('==================================================');
    Write('Pilihan Anda: '); Readln(MenuUtama);

    case MenuUtama of
      '1': SubMenuRonda;
      '2': SubMenuLaporan;
    end;
  until MenuUtama = '0';

  Writeln('Program Selesai. Data tersimpan di ', NAMA_FILE);
  Sleep(1000);
end.
