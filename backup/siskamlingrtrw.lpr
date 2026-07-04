program siskamlingrtrw;

{$mode objfpc}{$H+}

uses
  SysUtils, CRT;

const
  MAX_PETUGAS = 50;
  MAX_LAPORAN = 100;
  MAX_JADWAL = 7;

type
  TPetugas = record
    id: integer;
    nama: string[50];
    blok: string[20];
  end;

  TJadwal = record
    hari: string[20];
    petugas: array[1..5] of integer;
    jumlahPetugas: integer;
  end;

  TLaporan = record
    id: integer;
    waktu: string[10];
    pelapor: string[50];
    lokasi: string[50];
    kategori: string[30];
    prioritas: integer;
    status: string[20];
  end;

var
  petugas: array[1..MAX_PETUGAS] of TPetugas;
  jumlahPetugas: integer = 0;

  jadwal: array[1..MAX_JADWAL] of TJadwal;

  laporan: array[1..MAX_LAPORAN] of TLaporan;
  jumlahLaporan: integer = 0;

  filePetugas: file of TPetugas;
  fileJadwal: file of TJadwal;
  fileLaporan: file of TLaporan;

procedure Jeda;
begin
  writeln;
  writeln('Tekan Enter...');
  readln;
end;

procedure SavePetugas;
var
  i: integer;
begin
  Assign(filePetugas, 'petugas.dat');
  Rewrite(filePetugas);

  for i := 1 to jumlahPetugas do
    Write(filePetugas, petugas[i]);

  Close(filePetugas);
end;

procedure LoadPetugas;
var
  temp: TPetugas;
begin
  jumlahPetugas := 0;

  Assign(filePetugas, 'petugas.dat');
  {$I-}
  Reset(filePetugas);
  {$I+}

  if IOResult = 0 then
  begin
    while not EOF(filePetugas) do
    begin
      Read(filePetugas, temp);
      Inc(jumlahPetugas);
      petugas[jumlahPetugas] := temp;
    end;

    Close(filePetugas);
  end;
end;

procedure SaveJadwal;
var
  i: integer;
begin
  Assign(fileJadwal, 'jadwal.dat');
  Rewrite(fileJadwal);

  for i := 1 to 7 do
    Write(fileJadwal, jadwal[i]);

  Close(fileJadwal);
end;

procedure LoadJadwal;
var
  i: integer;
begin
  Assign(fileJadwal, 'jadwal.dat');

  {$I-}
  Reset(fileJadwal);
  {$I+}

  if IOResult = 0 then
  begin
    for i := 1 to 7 do
      Read(fileJadwal, jadwal[i]);

    Close(fileJadwal);
  end;
end;

procedure SaveLaporan;
var
  i: integer;
begin
  Assign(fileLaporan, 'laporan.dat');
  Rewrite(fileLaporan);

  for i := 1 to jumlahLaporan do
    Write(fileLaporan, laporan[i]);

  Close(fileLaporan);
end;

procedure LoadLaporan;
var
  temp: TLaporan;
begin
  jumlahLaporan := 0;

  Assign(fileLaporan, 'laporan.dat');

  {$I-}
  Reset(fileLaporan);
  {$I+}

  if IOResult = 0 then
  begin
    while not EOF(fileLaporan) do
    begin
      Read(fileLaporan, temp);
      Inc(jumlahLaporan);
      laporan[jumlahLaporan] := temp;
    end;

    Close(fileLaporan);
  end;
end;

procedure SaveSemua;
begin
  SavePetugas;
  SaveJadwal;
  SaveLaporan;
end;

procedure LoadSemua;
begin
  LoadPetugas;
  LoadJadwal;
  LoadLaporan;
end;

function HariSekarang: string;
var
  h: string;
begin
  h := FormatDateTime('dddd', Now);

  if h = 'Monday' then Result := 'Senin'
  else if h = 'Tuesday' then Result := 'Selasa'
  else if h = 'Wednesday' then Result := 'Rabu'
  else if h = 'Thursday' then Result := 'Kamis'
  else if h = 'Friday' then Result := 'Jumat'
  else if h = 'Saturday' then Result := 'Sabtu'
  else Result := 'Minggu';
end;

function PetugasSudahAda(hari, idPetugas: integer): boolean;
var
  i: integer;
begin
  Result := False;

  for i := 1 to jadwal[hari].jumlahPetugas do
  begin
    if jadwal[hari].petugas[i] = idPetugas then
    begin
      Result := True;
      Exit;
    end;
  end;
end;

procedure TambahPetugasKeJadwal(hari, idPetugas: integer);
begin
  if jadwal[hari].jumlahPetugas >= 5 then
  begin
    writeln('Jadwal hari ini sudah penuh (max 5 petugas).');
    Exit;
  end;

  if PetugasSudahAda(hari, idPetugas) then
  begin
    writeln('Petugas sudah terdaftar di hari tersebut.');
    Exit;
  end;

  Inc(jadwal[hari].jumlahPetugas);
  jadwal[hari].petugas[jadwal[hari].jumlahPetugas] := idPetugas;
end;


procedure InitJadwal;
var
  i, j: integer;
begin
  jadwal[1].hari := 'Senin';
  jadwal[2].hari := 'Selasa';
  jadwal[3].hari := 'Rabu';
  jadwal[4].hari := 'Kamis';
  jadwal[5].hari := 'Jumat';
  jadwal[6].hari := 'Sabtu';
  jadwal[7].hari := 'Minggu';

  for i := 1 to 7 do
  begin
    jadwal[i].jumlahPetugas := 0;

    for j := 1 to 5 do
      jadwal[i].petugas[j] := 0;
  end;
end;

procedure TampilPetugas;
var
  i: integer;
begin
  ClrScr;
  writeln('===== DAFTAR PETUGAS =====');

  if jumlahPetugas = 0 then
  begin
    writeln('Belum ada petugas.');
    Jeda;
    Exit;
  end;

  for i := 1 to jumlahPetugas do
  begin
    writeln('ID   : ', petugas[i].id);
    writeln('Nama : ', petugas[i].nama);
    writeln('Blok : ', petugas[i].blok);
    writeln('-------------------------');
  end;

  Jeda;
end;

procedure TambahPetugas;
begin
  ClrScr;


  Inc(jumlahPetugas);

  petugas[jumlahPetugas].id := jumlahPetugas;

  writeln('===== TAMBAH PETUGAS =====');

  write('Nama: ');
  readln(petugas[jumlahPetugas].nama);

  write('Blok: ');
  readln(petugas[jumlahPetugas].blok);

  writeln('Petugas berhasil ditambahkan.');
  SaveSemua;
  Jeda;
end;

procedure EditPetugas;
var
  id, i: integer;
begin
  ClrScr;

  if jumlahPetugas = 0 then
  begin
    writeln('Belum ada petugas.');
    Jeda;
    Exit;
  end;

  writeln('===== EDIT PETUGAS =====');
  for i := 1 to jumlahPetugas do
    writeln(petugas[i].id, '. ', petugas[i].nama);

  write('Masukkan ID petugas: ');
  readln(id);

  if (id < 1) or (id > jumlahPetugas) then
  begin
    writeln('ID tidak valid.');
    Jeda;
    Exit;
  end;

  write('Nama baru: ');
  readln(petugas[id].nama);

  write('Blok baru: ');
  readln(petugas[id].blok);

  writeln('Data berhasil diupdate.');
  SaveSemua;
  Jeda;
end;

procedure HapusPetugas;
var
  id, i: integer;
begin
  ClrScr;

  if jumlahPetugas = 0 then
  begin
    writeln('Belum ada petugas.');
    Jeda;
    Exit;
  end;

  writeln('===== HAPUS PETUGAS =====');
  for i := 1 to jumlahPetugas do
    writeln(petugas[i].id, '. ', petugas[i].nama);

  write('Masukkan ID petugas: ');
  readln(id);

  if (id < 1) or (id > jumlahPetugas) then
  begin
    writeln('ID tidak valid.');
    Jeda;
    Exit;
  end;

  for i := id to jumlahPetugas - 1 do
  begin
    petugas[i] := petugas[i + 1];
    petugas[i].id := i;
  end;

  Dec(jumlahPetugas);

  writeln('Petugas berhasil dihapus.');
  SaveSemua;
  Jeda;
end;

function CariJamRawan: integer;
var
  jamCount: array[0..23] of integer;
  i, jam, maxCount: integer;
  jamStr: string[2];
begin
  for i := 0 to 23 do
    jamCount[i] := 0;

  for i := 1 to jumlahLaporan do
  begin
    jamStr := Copy(laporan[i].waktu, 1, 2);
    jam := StrToIntDef(jamStr, -1);

    if (jam >= 0) and (jam <= 23) then
      Inc(jamCount[jam]);
  end;

  Result := -1;
  maxCount := 0;

  for i := 0 to 23 do
  begin
    if jamCount[i] > maxCount then
    begin
      maxCount := jamCount[i];
      Result := i;
    end;
  end;
end;

function KategoriTerbanyak: string;
var
  i, j, count, maxCount: integer;
begin
  Result := '-';
  maxCount := 0;

  for i := 1 to jumlahLaporan do
  begin
    count := 0;

    for j := 1 to jumlahLaporan do
    begin
      if laporan[i].kategori = laporan[j].kategori then
        Inc(count);
    end;

    if count > maxCount then
    begin
      maxCount := count;
      Result := laporan[i].kategori;
    end;
  end;
end;

function CariDangerZone: string;
var
  i, j, count, maxCount: integer;
begin
  Result := '-';
  maxCount := 0;

  for i := 1 to jumlahLaporan do
  begin
    count := 0;

    for j := 1 to jumlahLaporan do
    begin
      if laporan[i].lokasi = laporan[j].lokasi then
        Inc(count);
    end;

    if count > maxCount then
    begin
      maxCount := count;
      Result := laporan[i].lokasi;
    end;
  end;
end;



procedure MenuPetugas;
var
  pilih: char;
begin
  repeat
    ClrScr;
    writeln('===== MENU PETUGAS =====');
    writeln('1. Tambah Petugas');
    writeln('2. Lihat Petugas');
    writeln('3. Edit Petugas');
    writeln('4. Hapus Petugas');
    writeln('0. Kembali');
    write('Pilih: ');
    readln(pilih);

    case pilih of
      '1': TambahPetugas;
      '2': TampilPetugas;
      '3': EditPetugas;
      '4': HapusPetugas;
    end;
  until pilih = '0';
end;

procedure TampilJadwal;
var
  i, j: integer;
begin
  ClrScr;
  writeln('===== JADWAL PATROLI =====');

  for i := 1 to 7 do
  begin
    writeln(jadwal[i].hari);

    if jadwal[i].jumlahPetugas = 0 then
      writeln('Belum ada petugas.')
    else
    begin
      for j := 1 to jadwal[i].jumlahPetugas do
      begin
        writeln(
          'Petugas ', j, ': ',
          petugas[jadwal[i].petugas[j]].nama
        );
      end;
    end;

    writeln('---------------------------');
  end;

  Jeda;
end;

procedure AturJadwal;
var
  hari, idPetugas, i: integer;
begin
  ClrScr;

  writeln('===== ATUR JADWAL =====');
  writeln('1. Senin');
  writeln('2. Selasa');
  writeln('3. Rabu');
  writeln('4. Kamis');
  writeln('5. Jumat');
  writeln('6. Sabtu');
  writeln('7. Minggu');
  writeln('0. Kembali');

  write('Pilih hari (0-7): ');
  readln(hari);

  if hari = 0 then Exit;

  if (hari < 1) or (hari > 7) then
  begin
    writeln('Pilihan hari tidak valid.');
    Jeda;
    Exit;
  end;

  writeln;
  writeln('Daftar Petugas:');

  for i := 1 to jumlahPetugas do
  begin
    if not PetugasSudahAda(hari, petugas[i].id) then
      writeln(petugas[i].id, '. ', petugas[i].nama);
  end;

  write('Pilih ID petugas: ');
  readln(idPetugas);

  // Cek apakah ID yang dimasukkan valid
  if (idPetugas < 1) or (idPetugas > jumlahPetugas) then
  begin
    writeln('ID Petugas tidak ditemukan.');
    Jeda;
    Exit;
  end;

  TambahPetugasKeJadwal(hari, idPetugas);

  SaveSemua;
  writeln('Petugas berhasil ditambahkan ke jadwal.');
  Jeda;
end;

procedure TampilPetugasHariIni;
var
  hariSek: string;
  i, j: integer;
begin
  ClrScr;
  writeln('===== PETUGAS HARI INI =====');

  hariSek := HariSekarang;
  writeln('Hari ini: ', hariSek);
  writeln;

  for i := 1 to 7 do
  begin
    if hariSek = jadwal[i].hari then
    begin
      if jadwal[i].jumlahPetugas = 0 then
      begin
        writeln('Belum ada petugas dijadwalkan hari ini.');
      end
      else
      begin
        writeln('Jumlah Petugas: ', jadwal[i].jumlahPetugas);
        writeln;

        for j := 1 to jadwal[i].jumlahPetugas do
        begin
          writeln(
            j, '. ',
            petugas[jadwal[i].petugas[j]].nama,
            ' - Blok ',
            petugas[jadwal[i].petugas[j]].blok
          );
        end;
      end;

      Break;
    end;
  end;

  Jeda;
end;

procedure MenuJadwal;
var
  pilih: char;
begin
  repeat
    ClrScr;
    writeln('===== MENU JADWAL =====');
    writeln('1. Lihat Jadwal');
    writeln('2. Atur Jadwal');
    writeln('3. Petugas Hari Ini');
    writeln('0. Kembali');
    write('Pilih: ');
    readln(pilih);

    case pilih of
      '1': TampilJadwal;
      '2': AturJadwal;
      '3': TampilPetugasHariIni;
    end;
  until pilih = '0';
end;

procedure InputLaporan;
begin
  ClrScr;

  if jumlahLaporan >= MAX_LAPORAN then
  begin
    writeln('Kapasitas laporan penuh.');
    Jeda;
    Exit;
  end;

  Inc(jumlahLaporan);
  laporan[jumlahLaporan].id := jumlahLaporan;

  writeln('===== INPUT LAPORAN =====');

  write('Waktu (HH:MM): ');
  readln(laporan[jumlahLaporan].waktu);

  write('Nama Pelapor: ');
  readln(laporan[jumlahLaporan].pelapor);

  write('Lokasi: ');
  readln(laporan[jumlahLaporan].lokasi);

  write('Kategori: ');
  readln(laporan[jumlahLaporan].kategori);

  write('Prioritas (1-3): ');
  readln(laporan[jumlahLaporan].prioritas);

  laporan[jumlahLaporan].status := 'Pending';

  writeln('Laporan berhasil ditambahkan.');
  SaveSemua;
  Jeda;
end;

procedure TampilLaporan;
var
  i: integer;
begin
  ClrScr;
  writeln('===== DAFTAR LAPORAN =====');

  if jumlahLaporan = 0 then
  begin
    writeln('Belum ada laporan.');
    Jeda;
    Exit;
  end;

  for i := 1 to jumlahLaporan do
  begin
    writeln('ID        : ', laporan[i].id);
    writeln('Waktu     : ', laporan[i].waktu);
    writeln('Pelapor   : ', laporan[i].pelapor);
    writeln('Lokasi    : ', laporan[i].lokasi);
    writeln('Kategori  : ', laporan[i].kategori);
    writeln('Prioritas : ', laporan[i].prioritas);
    writeln('Status    : ', laporan[i].status);
    writeln('-----------------------------');
  end;

  Jeda;
end;

procedure DispatchDarurat;
var
  i, j: integer;
begin
  writeln;
  writeln('===== DISPATCH DARURAT =====');

  for i := 1 to 7 do
  begin
    if jadwal[i].hari = HariSekarang then
    begin
      if jadwal[i].jumlahPetugas = 0 then
      begin
        writeln('Tidak ada petugas standby hari ini.');
      end
      else
      begin
        writeln('Petugas standby hari ini:');

        for j := 1 to jadwal[i].jumlahPetugas do
        begin
          writeln(
            j, '. ',
            petugas[jadwal[i].petugas[j]].nama
          );
        end;
      end;

      Break;
    end;
  end;
end;

procedure ProcessLaporan;
var
  i, idx, maxPrio: integer;
begin
  ClrScr;

  idx := -1;
  maxPrio := -1;

  for i := 1 to jumlahLaporan do
  begin
    if (laporan[i].status = 'Pending') and
       (laporan[i].prioritas > maxPrio) then
    begin
      maxPrio := laporan[i].prioritas;
      idx := i;
    end;
  end;

  if idx = -1 then
  begin
    writeln('Tidak ada laporan pending.');
    Jeda;
    Exit;
  end;

  writeln('===== PROCESS LAPORAN =====');
  writeln('ID       : ', laporan[idx].id);
  writeln('Lokasi   : ', laporan[idx].lokasi);
  writeln('Kategori : ', laporan[idx].kategori);
  writeln('Prioritas: ', laporan[idx].prioritas);

  laporan[idx].status := 'Processed';

  if laporan[idx].prioritas = 3 then
    DispatchDarurat;

  writeln;
  writeln('Laporan selesai diproses.');
  SaveSemua;
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
    writeln('2. Lihat Laporan');
    writeln('3. Process Laporan');
    writeln('0. Kembali');
    write('Pilih: ');
    readln(pilih);

    case pilih of
      '1': InputLaporan;
      '2': TampilLaporan;
      '3': ProcessLaporan;
    end;
  until pilih = '0';
end;

procedure Dashboard;
var
  totalPending, totalProcessed: integer;
  i, j: integer;
begin
  ClrScr;

  totalPending := 0;
  totalProcessed := 0;

  for i := 1 to jumlahLaporan do
  begin
    if laporan[i].status = 'Pending' then
      Inc(totalPending)
    else if laporan[i].status = 'Processed' then
      Inc(totalProcessed);
  end;

  writeln('===== DASHBOARD SISTEM =====');
  writeln('Hari                : ', HariSekarang);
  writeln('Jumlah Petugas      : ', jumlahPetugas);
  writeln('Total Laporan       : ', jumlahLaporan);
  writeln('Laporan Pending     : ', totalPending);
  writeln('Laporan Processed   : ', totalProcessed);
  writeln;

  writeln('Petugas Aktif Hari Ini:');

  for i := 1 to 7 do
  begin
    if jadwal[i].hari = HariSekarang then
    begin
      if jadwal[i].jumlahPetugas = 0 then
      begin
        writeln('- Tidak ada petugas');
      end
      else
      begin
        for j := 1 to jadwal[i].jumlahPetugas do
        begin
          writeln(
            '- ',
            petugas[jadwal[i].petugas[j]].nama
          );
        end;
      end;

      Break;
    end;
  end;

  Jeda;
end;

procedure Statistik;
var
  i, tinggi, sedang, rendah: integer;
  pending, processed, jamRawan: integer;
begin
  ClrScr;

  tinggi := 0;
  sedang := 0;
  rendah := 0;
  pending := 0;
  processed := 0;

  for i := 1 to jumlahLaporan do
  begin
    if laporan[i].status = 'Pending' then
      Inc(pending)
    else if laporan[i].status = 'Processed' then
      Inc(processed);

    case laporan[i].prioritas of
      1: Inc(rendah);
      2: Inc(sedang);
      3: Inc(tinggi);
    end;
  end;

  writeln('===== STATISTIK KEAMANAN =====');
  writeln('Total Laporan       : ', jumlahLaporan);
  writeln('Menunggu            : ', pending);
  writeln('Diproses            : ', processed);
  writeln;
  writeln('Prioritas Rendah    : ', rendah);
  writeln('Prioritas Sedang    : ', sedang);
  writeln('Prioritas Tinggi    : ', tinggi);
  writeln;

  jamRawan := CariJamRawan;
  if jamRawan = -1 then
    writeln('Jam Rawan           : Belum ada data')
  else
    writeln('Jam Rawan           : ', jamRawan:2, ':00');

  writeln('Kategori Terbanyak  : ', KategoriTerbanyak);
  writeln('Zona Bahaya         : ', CariDangerZone);

  Jeda;
end;

procedure ExportPetugasCSV;
var
  f: Text;
  i: integer;
begin
  Assign(f, 'petugas.csv');
  Rewrite(f);

  writeln(f, 'ID,Nama,Blok');

  for i := 1 to jumlahPetugas do
    writeln(f,
      petugas[i].id, ',',
      petugas[i].nama, ',',
      petugas[i].blok
    );

  Close(f);

  writeln('Export petugas selesai.');
  Jeda;
end;

procedure ExportJadwalCSV;
var
  f: Text;
  i, j: integer;
  namaPetugas: array[1..5] of string;
begin
  Assign(f, 'jadwal.csv');
  Rewrite(f);

  writeln(f, 'Hari,Petugas1,Petugas2,Petugas3,Petugas4,Petugas5');

  for i := 1 to 7 do
  begin
    for j := 1 to 5 do
      namaPetugas[j] := '-';

    for j := 1 to jadwal[i].jumlahPetugas do
    begin
      namaPetugas[j] :=
        petugas[jadwal[i].petugas[j]].nama;
    end;

    writeln(f,
      jadwal[i].hari, ',',
      namaPetugas[1], ',',
      namaPetugas[2], ',',
      namaPetugas[3], ',',
      namaPetugas[4], ',',
      namaPetugas[5]
    );
  end;

  Close(f);

  writeln('Export jadwal selesai.');
  Jeda;
end;

procedure ExportLaporanCSV;
var
  f: Text;
  i: integer;
begin
  Assign(f, 'laporan.csv');
  Rewrite(f);

  writeln(f, 'ID,Waktu,Pelapor,Lokasi,Kategori,Prioritas,Status');

  for i := 1 to jumlahLaporan do
  begin
    writeln(f,
      laporan[i].id, ',',
      laporan[i].waktu, ',',
      laporan[i].pelapor, ',',
      laporan[i].lokasi, ',',
      laporan[i].kategori, ',',
      laporan[i].prioritas, ',',
      laporan[i].status
    );
  end;

  Close(f);

  writeln('Export laporan selesai.');
  Jeda;
end;

procedure ExportStatistikCSV;
var
  f: Text;
  i, pending, processed, tinggi, sedang, rendah, jamR: integer;
  jamRStr: string;
begin
  pending := 0;
  processed := 0;
  tinggi := 0;
  sedang := 0;
  rendah := 0;

  for i := 1 to jumlahLaporan do
  begin
    if laporan[i].status = 'Pending' then Inc(pending);
    if laporan[i].status = 'Processed' then Inc(processed);

    case laporan[i].prioritas of
      1: Inc(rendah);
      2: Inc(sedang);
      3: Inc(tinggi);
    end;
  end;

  Assign(f, 'statistik.csv');
  Rewrite(f);

  writeln(f, 'Metric,Value');
  writeln(f, 'Total Petugas,', jumlahPetugas);
  writeln(f, 'Total Laporan,', jumlahLaporan);
  writeln(f, 'Pending,', pending);
  writeln(f, 'Processed,', processed);
  writeln(f, 'Prioritas Rendah,', rendah);
  writeln(f, 'Prioritas Sedang,', sedang);
  writeln(f, 'Prioritas Tinggi,', tinggi);

  jamR := CariJamRawan;
  if jamR = -1 then
    jamRStr := 'Belum ada data'
  else
    jamRStr := IntToStr(jamR) + ':00';

  writeln(f, 'Jam Rawan,', jamRStr);
  writeln(f, 'Kategori Terbanyak,', KategoriTerbanyak);
  writeln(f, 'Danger Zone,', CariDangerZone);

  Close(f);

  writeln('Export statistik selesai.');
  Jeda;
end;

procedure ExportSemua;
begin
  ExportPetugasCSV;
  ExportJadwalCSV;
  ExportLaporanCSV;
  ExportStatistikCSV;

  writeln('Semua data berhasil diexport.');
  Jeda;
end;

procedure MenuExport;
var
  pilih: char;
begin
  repeat
    ClrScr;
    writeln('===== MENU EXPORT =====');
    writeln('1. Export Petugas CSV');
    writeln('2. Export Jadwal CSV');
    writeln('3. Export Laporan CSV');
    writeln('4. Export Statistik CSV');
    writeln('5. Export Semua');
    writeln('0. Kembali');
    write('Pilih: ');
    readln(pilih);

    case pilih of
      '1': ExportPetugasCSV;
      '2': ExportJadwalCSV;
      '3': ExportLaporanCSV;
      '4': ExportStatistikCSV;
      '5': ExportSemua;
    end;
  until pilih = '0';
end;

procedure MenuUtama;
var
  pilih: char;
begin
  repeat
    ClrScr;
    writeln('========================================');
    writeln('      SMART SECURITY SYSTEM RT/RW');
    writeln('========================================');
    writeln('1. Dashboard');
    writeln('2. Menu Petugas');
    writeln('3. Jadwal Patroli');
    writeln('4. Laporan Keamanan');
    writeln('5. Statistik');
    writeln('6. Export Data');
    writeln('0. Keluar');
    writeln('========================================');
    write('Pilih: ');
    readln(pilih);

    case pilih of
      '1': Dashboard;
      '2': MenuPetugas;
      '3': MenuJadwal;
      '4': MenuLaporan;
      '5': Statistik;
      '6': MenuExport;
    end;
  until pilih = '0';
end;

begin
  InitJadwal;
  LoadSemua;
  MenuUtama;
  SaveSemua;
end.
