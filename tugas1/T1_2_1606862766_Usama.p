#!/usr/local/bin/perl

@dates = ();
$days = "Senin|Selasa|Rabu|Kamis|Jumat|Sabtu|Minggu";
$months = "Januari|Februari|Maret|April|Mei|Juni|Juli|Agustus|September|Oktober|November|Desember";

# open(IN, "text.txt");
open(IN, "korpus-1.txt");
open($OUT, ">", "hasil_text.txt");

while ($line = <IN>) {
    # jika sudah masuk berita dengan id 31, stop
    if ($line =~ /KPS-310818-031/) {
        last;
    }

    chop($line);

    # cari tempat
    if ($line !~ /<TITLE>/) {
        $line =~ s/((di|ke|dari)( [a-z]+)*(( [A-Z]+[a-z]+[\,]*)+))/$1<\/ENT>/g;
        $line =~ s/(([A-Z]+[a-z]+[ \,]*)+<\/ENT>)/<ENT TYPE="LOKASI">$1/g;
        $line =~ s/<ENT TYPE="LOKASI"> / <ENT TYPE="LOKASI">/g;
    }

    # cari tanggal
    if ($line !~ /<DATE>/ && $line !~ /<TITLE>/) {
        $line =~ s/((?:$days)?[ ]*[0-9]{1,2} (?:$months)[ ]*[0-9]{0,4})/<ENT TYPE="TANGGAL">$1<\/ENT>/g;

        $line =~ s/((?:$days)?[ ]*\([0-9]{1,2}\/[0-9]{1,2}\/[0-9]{4}\))/<ENT TYPE="TANGGAL">$1<\/ENT>/g;

        $line =~ s/<ENT TYPE="TANGGAL">([ ]*)/$1<ENT TYPE="TANGGAL">/g;
    }

    # bersihkan whitespace disekitar entitas di belakang
    $line =~ s/([ ]+)<\/ENT>/<\/ENT>$1/g;
    $line =~ s/($days)<\/ENT> <ENT TYPE="TANGGAL">/<\/ENT> <ENT TYPE="TANGGAL">$1/g;
    $line =~ s/([, ]+)<\/ENT>/<\/ENT>$1/g;

    print $OUT "$line\n";
}

close(IN);
close(OUT);