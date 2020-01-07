#!/usr/local/bin/perl
sub min
{
    @list = @{$_[0]};
    $min = $list[0];

    foreach $i (@list)
    {
        $min = $i if ($i < $min);
    }

    return $min;
}

sub max {
    ($a, $b) = @_;

    if ($a > $b) {
        return $a;
    }

    return $b;
}

sub lcs {
    ($word1, $word2) = @_;
    $len1 = length $word1;
    $len2 = length $word2;

    %mat;

    for ($i = 0; $i <= $len1; ++$i) {
        for ($j = 0; $j <= $len2; ++$j) {
            if (($i == 0) || ($j == 0)) {
                $mat{$i}{$j} = 0;
            } elsif ((substr $word1, ($i - 1), 1) eq (substr $word2, ($j - 1), 1)) {
                $mat{$i}{$j} = $mat{($i - 1)}{$j - 1} + 1;
            } else {
                $mat{$i}{$j} = max($mat{($i - 1)}{$j}, $mat{$i}{($j - 1)});
            }

            printf "%d %d %d\n", $i, $j, $mat{$i}{$j};
        }
    }

    return $mat{$len1}{$len2};
}

sub levenshtein {
    ($s1, $s2) = @_;
    ($len1, $len2) = (length $s1, length $s2);

    return $len2 if ($len1 == 0);
    return $len1 if ($len2 == 0);

    %mat;

    for ($i = 0; $i <= $len1; ++$i) {
        for ($j = 0; $j <= $len2; ++$j) {
            $mat{$i}{$j} = 0;
            $mat{0}{$j} = $j;
        }

        $mat{$i}{0} = $i;
    }

    @ar1 = split(//, $s1);
    @ar2 = split(//, $s2);

    for ($i = 1; $i <= $len1; ++$i) {
        for ($j = 1; $j <= $len2; ++$j) {

            $cost = ($ar1[$i-1] eq $ar2[$j-1]) ? 0 : 1;

            $mat{$i}{$j} = min([$mat{$i-1}{$j} + 1,
                                $mat{$i}{$j-1} + 1,
                                $mat{$i-1}{$j-1} + $cost]);
        }
    }

    return $mat{$len1}{$len2};
}

# $x = "tulis";
# $y = "ditulis";

# printf "%d\n", lcs($x, $y);
# printf "%d\n", levenshtein($x, $y);

@array = (1, 2, 3);

print "@array[2]\n";