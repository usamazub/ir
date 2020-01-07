#!/usr/local/bin/perl

use Scalar::Util qw(looks_like_number);

open(IN, "korpus-1.txt");

%vocab = ();
$total_kalimat = 0;
$total_number = 0;

while ($line = <IN>) {
    chop($line);

    # menghitung kata dengan cara membuat hurufnya lowercase. Kemudian hilangkan punctuation agar sisanya hanya huruf.

    # untuk "-" dan "/" ganti dengan spasi karena terdapat format tanggal yang menggunakan - dan /.
    $line = lc($line);
    $line =~ s/<[\/]*[A-Za-z]*>//g;
    $line =~ s/[\,\(\)\[\]]//g;
    $line =~ s/[\'\"]//g;
    $line =~ s/[\-\/]/ /g;

    # hitung banyak kalimat disini
    $temp = () = $line =~ /[\.\?\!]/g;
    $total_kalimat += $temp;

    $line =~ s/[\.\?\!]//g;

    @spl = split(" ", $line);

    # tambahkan kata ke daftar vocab jika belum ada. Jika sudah ada tambahkan frekuensinya untuk menghitung banyaknya token
    foreach $word (@spl) {
        if (exists($vocab{$word})) {
            $vocab{$word}++;
        } else {
            $vocab{$word} = 1;
        }
    }
}

$vocab_len = keys %vocab;

# cek number (desimal maupun romawi).
# regex romawi didapatkan dari https://stackoverflow.com/questions/267399/how-do-you-match-only-valid-roman-numerals-with-a-regular-expression

foreach $number (keys %vocab) {
    if (looks_like_number($number)) {
        $total_number += $vocab{$number};
    } elsif ($number =~ /^m{0,4}(cm|cd|d?c{0,3})(xc|xl|l?x{0,3})(ix|iv|v?i{0,3})$/) {
        $total_number += $vocab{$number};
    }
}

print "unik vocab : $vocab_len\n";
print "total kalimat : $total_kalimat\n";
print "total number : $total_number\n";

$i = 0;

my @vocab_by_value = sort {$vocab{$b} <=> $vocab{$a}} keys %vocab;

foreach my $key (@vocab_by_value) {
    if ($i == 5) {
        last;
    }

    printf "%20s = %2d\n", $key, $vocab{$key};
    $i++;
}

close(IN);