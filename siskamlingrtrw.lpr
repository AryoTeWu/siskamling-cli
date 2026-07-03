program SistemPemantauanKeamananPintarV2;

{$mode objfpc}{$H+}

uses
  SysUtils, CRT;

const
  MAKS_LAPORAN = 100;
  MAKS_ANTREAN = 100;
  MAKS_PETUGAS = 100;
  FILE_LAPORAN = 'laporan.dat';
  FILE_PETUGAS = 'petugas.dat';

type
  TLaporan = record
    id: integer;
    waktu: string[10];
    pelapor: string[50];
    lokasi: string[50];
    kategori: string[30];
    prioritas: integer;
    status: string[20];
  end;

  TPetugas = record
    nama: string[50];
    blok: string[10];
  end;

var
  laporan: array[1..MAKS_LAPORAN] of TLaporan;
  antreanLaporan: array[1..MAKS_ANTREAN] of integer;

  petugas: array[1..MAKS_PETUGAS] of TPetugas;

  totalLaporan: integer;
  totalPetugas: integer;

  alDepan, alBelakang: integer; { al = antrean laporan }
  apDepan, apBelakang: integer; { ap = antrean petugas }

  petugasAktif: string;
  patroliAktif: boolean;

{ ================= UTILITAS ================= }

procedure Jeda;
begin
  writeln;
  writeln('Tekan ENTER...');
  readln;
end;

procedure ResetAntrean;
begin
  alDepan := 1;
  alBelakang := 0;
  apDepan := 1;
  apBelakang := 0;
end;

function JumlahTertunda: integer;
begin
  JumlahTertunda := alBelakang - alDepan + 1;
  if JumlahTertunda < 0 then
    JumlahTertunda := 0;
end;

function JumlahDiproses: integer;
var
  i, cnt: integer;
begin
  cnt := 0;
  for i := 1 to totalLaporan do
    if laporan[i].status = 'Diproses' then
      Inc(cnt);
  JumlahDiproses := cnt;
end;

function CariJamRawan: integer;
var
  jamCount: array[0..23] of integer;
  i, maxCount, jamRawan, jamAktual: integer;
  jamStr: string;
begin
  for i := 0 to 23 do
    jamCount[i] := 0;

  maxCount := 0;
  jamRawan := -1;

  for i := 1 to totalLaporan do
  begin
    jamStr := Copy(laporan[i].waktu,1,2);
    jamAktual := StrToIntDef(jamStr,-1);

    if (jamAktual >= 0) and (jamAktual <= 23) then
      Inc(jamCount[jamAktual]);
  end;

  for i := 0 to 23 do
  begin
    if jamCount[i] > maxCount then
    begin
      maxCount := jamCount[i];
      jamRawan := i;
    end;
  end;

  CariJamRawan := jamRawan;
end;

{ ================= ANTREAN PRIORITAS LAPORAN ================= }

procedure MasukAntreanLaporan(indeksLaporan: integer);
var
  i, j, temp: integer;
begin
  if alBelakang < MAKS_ANTREAN then
  begin
    Inc(alBelakang);
    antreanLaporan[alBelakang] := indeksLaporan;

    for i := alDepan to alBelakang - 1 do
    begin
      for j := alDepan to alBelakang - 1 do
      begin
        if laporan[antreanLaporan[j]].prioritas < laporan[antreanLaporan[j+1]].prioritas then
        begin
          temp := antreanLaporan[j];
          antreanLaporan[j] := antreanLaporan[j+1];
          antreanLaporan[j+1] := temp;
        end;
      end;
    end;
  end;
end;

procedure KeluarAntreanLaporan;
begin
  if alDepan <= alBelakang then
    Inc(alDepan);
end;

{ ================= ANTREAN PETUGAS ================= }

procedure MasukAntreanPetugas(p: TPetugas);
begin
  if apBelakang < MAKS_PETUGAS then
  begin
    Inc(apBelakang);
    petugas[apBelakang] := p;
  end;
end;

procedure KeluarAntreanPetugas;
begin
  if apDepan <= apBelakang then
    Inc(apDepan);
end;

{ ================= PENANGANAN FILE ================= }

procedure SimpanLaporan;
var
  f: file of TLaporan;
  i: integer;
begin
  Assign(f, FILE_LAPORAN);
  Rewrite(f);

  for i := 1 to totalLaporan do
    Write(f, laporan[i]);

  Close(f);
end;

procedure MuatLaporan;
var
  f: file of TLaporan;
  temp: TLaporan;
begin
  totalLaporan := 0;

  Assign(f, FILE_LAPORAN);
  {$I-}
  Reset(f);
  {$I+}

  if IOResult = 0 then
  begin
    while not EOF(f) do
    begin
      Read(f, temp);
      Inc(totalLaporan);
      laporan[totalLaporan] := temp;

      if temp.status = 'Tertunda' then
        MasukAntreanLaporan(totalLaporan);
    end;
    Close(f);
  end;
end;

procedure SimpanPetugas;
var
  f: file of TPetugas;
  i: integer;
begin
  Assign(f, FILE_PETUGAS);
  Rewrite(f);

  for i := apDepan to apBelakang do
    Write(f, petugas[i]);

  Close(f);
end;

procedure MuatPetugas;
var
  f: file of TPetugas;
  temp: TPetugas;
begin
  apDepan := 1;
  apBelakang := 0;
  Assign(f, FILE_PETUGAS);

  {$I-}
  Reset(f);
  {$I+}

  if IOResult = 0 then
  begin
    while not EOF(f) do
    begin
      Read(f,temp);
      MasukAntreanPetugas(temp);
    end;
    Close(f);
  end;
end;

procedure SimpanSemua;
begin
  SimpanLaporan;
  SimpanPetugas;
end;

procedure CariLaporanByID;
var
  idCari, i: integer;
  ketemu: boolean;
begin
  ClrScr;
  ketemu := False;

  write('Masukkan ID laporan: ');
  readln(idCari);

  for i := 1 to totalLaporan do
  begin
    if laporan[i].id = idCari then
    begin
      ketemu := True;
      writeln('===== DATA DITEMUKAN =====');
      writeln('ID        : ', laporan[i].id);
      writeln('Waktu     : ', laporan[i].waktu);
      writeln('Pelapor   : ', laporan[i].pelapor);
      writeln('Lokasi    : ', laporan[i].lokasi);
      writeln('Kategori  : ', laporan[i].kategori);
      writeln('Prioritas : ', laporan[i].prioritas);
      writeln('Status    : ', laporan[i].status);
    end;
  end;

  if not ketemu then
    writeln('Laporan tidak ditemukan.');

  Jeda;
end;

procedure CariLaporanByLokasi;
var
  lokasiCari: string;
  i: integer;
begin
  ClrScr;

  write('Masukkan lokasi: ');
  readln(lokasiCari);

  for i := 1 to totalLaporan do
  begin
    if LowerCase(laporan[i].lokasi) = LowerCase(lokasiCari) then
    begin
      writeln('ID: ', laporan[i].id,
              ' | Kategori: ', laporan[i].kategori,
              ' | Status: ', laporan[i].status);
    end;
  end;

  Jeda;
end;

function CariZonaBahaya: string;
var
  i, j, count, maxCount: integer;
  lokasiRawan: string;
begin
  maxCount := 0;
  lokasiRawan := '-';

  for i := 1 to totalLaporan do
  begin
    count := 0;

    for j := 1 to totalLaporan do
      if laporan[i].lokasi = laporan[j].lokasi then
        Inc(count);

    if count > maxCount then
    begin
      maxCount := count;
      lokasiRawan := laporan[i].lokasi;
    end;
  end;

  CariZonaBahaya := lokasiRawan;
end;

function KategoriTerbanyak: string;
var
  i, j, count, maxCount: integer;
  kategoriMax: string;
begin
  maxCount := 0;
  kategoriMax := '-';

  for i := 1 to totalLaporan do
  begin
    count := 0;

    for j := 1 to totalLaporan do
      if laporan[i].kategori = laporan[j].kategori then
        Inc(count);

    if count > maxCount then
    begin
      maxCount := count;
      kategoriMax := laporan[i].kategori;
    end;
  end;

  KategoriTerbanyak := kategoriMax;
end;

procedure EksporTXT;
var
  f: Text;
  i: integer;
begin
  Assign(f, 'laporan_export.txt');
  Rewrite(f);

  writeln(f, '===== LAPORAN KEAMANAN =====');

  for i := 1 to totalLaporan do
  begin
    writeln(f, 'ID: ', laporan[i].id);
    writeln(f, 'Waktu: ', laporan[i].waktu);
    writeln(f, 'Pelapor: ', laporan[i].pelapor);
    writeln(f, 'Lokasi: ', laporan[i].lokasi);
    writeln(f, 'Kategori: ', laporan[i].kategori);
    writeln(f, 'Prioritas: ', laporan[i].prioritas);
    writeln(f, 'Status: ', laporan[i].status);
    writeln(f, '----------------------');
  end;

  Close(f);

  writeln('Ekspor TXT berhasil.');
  Jeda;
end;

procedure MuatSemua;
begin
  MuatLaporan;
  MuatPetugas;
end;

{ ================= DASBOR ================= }

procedure TampilDasbor;
var
  jam: integer;
begin
  ClrScr;

  jam := CariJamRawan;

  writeln('=========================================');
  writeln('    SISTEM PEMANTAUAN KEAMANAN PINTAR');
  writeln('=========================================');
  writeln('Total Laporan     : ', totalLaporan);
  writeln('Laporan Tertunda  : ', JumlahTertunda);
  writeln('Laporan Diproses  : ', JumlahDiproses);
  writeln('Petugas Siaga     : ', apBelakang - apDepan + 1);
  writeln('Zona Bahaya       : ', CariZonaBahaya);
  writeln('Kasus Terbanyak   : ', KategoriTerbanyak);

  if jam <> -1 then
    writeln('Jam Rawan         : ', jam:2, ':00')
  else
    writeln('Jam Rawan         : Belum ada data');

  if patroliAktif then
    writeln('Patroli Aktif     : ', petugasAktif)
  else
    writeln('Patroli Aktif     : Tidak ada');

  writeln('=========================================');
  Jeda;
end;
{ ================= MANAJEMEN LAPORAN ================= }

procedure InputLaporan;
begin
  ClrScr;

  if totalLaporan >= MAKS_LAPORAN then
  begin
    writeln('Kapasitas laporan penuh.');
    Jeda;
    Exit;
  end;

  Inc(totalLaporan);

  laporan[totalLaporan].id := totalLaporan;

  writeln('===== INPUT LAPORAN =====');
  write('Waktu (HH:MM)      : ');
  readln(laporan[totalLaporan].waktu);

  write('Nama Pelapor       : ');
  readln(laporan[totalLaporan].pelapor);

  write('Lokasi             : ');
  readln(laporan[totalLaporan].lokasi);

  write('Kategori Kejadian  : ');
  readln(laporan[totalLaporan].kategori);

  write('Prioritas (1-3)    : ');
  readln(laporan[totalLaporan].prioritas);

  laporan[totalLaporan].status := 'Tertunda';

  MasukAntreanLaporan(totalLaporan);

  SimpanSemua;

  writeln;
  writeln('Laporan berhasil ditambahkan.');
  Jeda;
end;

procedure TampilSemuaLaporan;
var
  i: integer;
begin
  ClrScr;

  writeln('================================================================================================');
  writeln('ID | WAKTU | PELAPOR        | LOKASI         | KATEGORI       | PRIORITAS | STATUS');
  writeln('================================================================================================');

  for i := 1 to totalLaporan do
  begin
    writeln(
      laporan[i].id:2,' | ',
      laporan[i].waktu:5,' | ',
      laporan[i].pelapor:14,' | ',
      laporan[i].lokasi:14,' | ',
      laporan[i].kategori:14,' | ',
      laporan[i].prioritas:9,' | ',
      laporan[i].status
    );
  end;

  writeln('================================================================================================');

  Jeda;
end;


procedure UrutkanSemuaLaporan;
var
  i, j: integer;
  temp: TLaporan;
begin
  for i := 1 to totalLaporan - 1 do
  begin
    for j := 1 to totalLaporan - i do
    begin
      if laporan[j].prioritas < laporan[j+1].prioritas then
      begin
        temp := laporan[j];
        laporan[j] := laporan[j+1];
        laporan[j+1] := temp;
      end;
    end;
  end;

  writeln('Semua laporan berhasil diurutkan.');
  Jeda;
end;

procedure TampilAntreanLaporan;
var
  i, idx: integer;
begin
  ClrScr;
  writeln('========= ANTREAN LAPORAN =========');

  if alDepan > alBelakang then
  begin
    writeln('Antrean kosong.');
    Jeda;
    Exit;
  end;

  for i := alDepan to alBelakang do
  begin
    idx := antreanLaporan[i];

    writeln('ID        : ', laporan[idx].id);
    writeln('Lokasi    : ', laporan[idx].lokasi);
    writeln('Kategori  : ', laporan[idx].kategori);
    writeln('Prioritas : ', laporan[idx].prioritas);
    writeln('Status    : ', laporan[idx].status);
    writeln('--------------------------');
  end;

  Jeda;
end;

procedure ProsesLaporan;
var
  idx: integer;
begin
  ClrScr;

  if alDepan > alBelakang then
  begin
    writeln('Tidak ada laporan yang belum diproses.');
    Jeda;
    Exit;
  end;

  idx := antreanLaporan[alDepan];

  laporan[idx].status := 'Diproses';

  writeln('Laporan diproses:');
  writeln('ID       : ', laporan[idx].id);
  writeln('Lokasi   : ', laporan[idx].lokasi);
  writeln('Kategori : ', laporan[idx].kategori);

  KeluarAntreanLaporan;
  SimpanSemua;

  writeln;
  writeln('Laporan berhasil diproses.');
  Jeda;
end;

procedure MenuLaporan;
var
  pilih: char;
begin
  repeat
    ClrScr;
    writeln('===== MENU LAPORAN =====');
    writeln('1. Input Laporan');
    writeln('2. Lihat Semua Laporan');
    writeln('3. Lihat Laporan Belum Diproses');
    writeln('4. Proses Laporan');
    writeln('5. Cari Laporan berdasarkan ID');
    writeln('6. Cari Laporan berdasarkan Lokasi');
    writeln('7. Urutkan Semua Laporan');
    writeln('0. Kembali');
    write('Pilih: ');
    readln(pilih);

    case pilih of
      '1': InputLaporan;
      '2': TampilSemuaLaporan;
      '3': TampilAntreanLaporan;
      '4': ProsesLaporan;
      '5': CariLaporanByID;
      '6': CariLaporanByLokasi;
      '7': UrutkanSemuaLaporan;
    end;
  until pilih = '0';
end;

{ ================= MANAJEMEN PATROLI ================= }

procedure TambahPetugas;
var
  p: TPetugas;
begin
  ClrScr;
  writeln('===== TAMBAH PETUGAS =====');

  write('Nama Petugas : ');
  readln(p.nama);

  write('Blok Area    : ');
  readln(p.blok);

  MasukAntreanPetugas(p);
  SimpanSemua;

  writeln('Petugas ditambahkan.');
  Jeda;
end;

procedure TampilAntreanPetugas;
var
  i: integer;
begin
  ClrScr;
  writeln('===== ANTREAN PETUGAS =====');

  if apDepan > apBelakang then
  begin
    writeln('Antrean kosong.');
    Jeda;
    Exit;
  end;

  for i := apDepan to apBelakang do
  begin
    writeln(i - apDepan + 1, '. ', petugas[i].nama, ' - Blok ', petugas[i].blok);
  end;

  Jeda;
end;

procedure BerangkatkanPetugas;
var
  jam: integer;
begin
  ClrScr;

  if apDepan > apBelakang then
  begin
    writeln('Tidak ada petugas.');
    Jeda;
    Exit;
  end;

  patroliAktif := True;
  petugasAktif := petugas[apDepan].nama;

  writeln('Petugas diberangkatkan: ', petugas[apDepan].nama);

  jam := CariJamRawan;
  if jam <> -1 then
    writeln('Sistem mendeteksi jam rawan: ', jam:2, ':00');

  KeluarAntreanPetugas;
  SimpanSemua;
  Jeda;
end;

procedure MenuPatroli;
var
  pilih: char;
begin
  repeat
    ClrScr;
    writeln('===== MENU PATROLI =====');
    writeln('1. Tambah Petugas');
    writeln('2. Lihat Antrean Petugas');
    writeln('3. Berangkatkan Petugas');
    writeln('0. Kembali');
    write('Pilih: ');
    readln(pilih);

    case pilih of
      '1': TambahPetugas;
      '2': TampilAntreanPetugas;
      '3': BerangkatkanPetugas;
    end;
  until pilih = '0';
end;

{ ================= STATISTIK ================= }

procedure TampilStatistik;
var
  i, tinggi: integer;
begin
  ClrScr;
  tinggi := 0;

  for i := 1 to totalLaporan do
    if laporan[i].prioritas = 3 then
      Inc(tinggi);

  writeln('===== STATISTIK =====');
  writeln('Total Laporan            : ', totalLaporan);
  writeln('Laporan Tertunda         : ', JumlahTertunda);
  writeln('Laporan Diproses         : ', JumlahDiproses);
  writeln('Laporan Prioritas Tinggi : ', tinggi);

  Jeda;
end;



{ ================= MENU UTAMA ================= }

procedure MenuUtama;
var
  pilih: char;
begin
  repeat
    ClrScr;

    writeln('=========================================');
    writeln('    SISTEM PEMANTAUAN KEAMANAN PINTAR');
    writeln('=========================================');
    writeln('1. Dasbor');
    writeln('2. Manajemen Laporan');
    writeln('3. Manajemen Petugas dan Patroli');
    writeln('4. Statistik');
    writeln('5. Simpan Data (As TXT)');
    writeln('6. Impor Data (TXT)');
    writeln('0. Keluar');
    writeln('=========================================');

    write('Pilih menu: ');
    readln(pilih);

    case pilih of
      '1': TampilDasbor;
      '2': MenuLaporan;
      '3': MenuPatroli;
      '4': TampilStatistik;
      '5': begin
             SimpanSemua;
             writeln('Data berhasil disimpan.');
             Jeda;
           end;
      '6': EksporTXT;
    end;

  until pilih = '0';
end;

begin
  totalLaporan := 0;
  totalPetugas := 0;
  patroliAktif := False;

  ResetAntrean;
  MuatSemua;
  MenuUtama;
end.
