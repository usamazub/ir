#!/usr/local/bin/perl

# men-generate kata unik yang ada di korpus
sub vocabulary_list_generator {
    open(IN, "korpus-tugas2.txt");
    open($OUT, ">", "vocabulary_list.txt");
    
    %vocabularies = ();
    $is_text = 0;

    while ($line = <IN>) {
        chop $line;

        if ($line =~ /<TEXT>/) {
            $is_text = 1;
        } elsif ($line =~ /<\/TEXT>/) {
            $is_text = 0;
        }

        if ($is_text == 0) {
            goto NEXT_LINE;
        }

        $line = lc $line;
        $line =~ s/[\,\(\)\[\]]//g;
        $line =~ s/[\'\"\/\.\?\!]//g;

        @spl = split(" ", $line);

        foreach $word (@spl) {
            if ($word =~ /[^a-zA-Z]+/) {
                # do nothing
            } elsif (exists($vocab{$word})) {
                # do nothing
            } else {
                $vocab{$word} = 1;
                print $OUT "$word\n";
            }
        }

        NEXT_LINE:
    }

    close(IN);
    close(OUT);
}

# algoritma soundex bahasa indonesia
sub soundex {
	($word) = @_;
	
    $first_char = substr $word, 0, 1;
	$first_char = uc $first_char;
	$result = $word;
	$result =~ s/[aeiouyhw]/0/g;
	$result =~ s/[bfpv]/1/g;
	$result =~ s/[cgjkqsxz]/2/g;
	$result =~ s/[dt]/3/g;
	$result =~ s/[l]/4/g;
	$result =~ s/[mn]/5/g;
	$result =~ s/[r]/6/g;
	$result =~ s/(.)\1{1,}/\1/g;
	$result =~ s/[0]//g;
	$result =~ s/[-]//g;

	$result = $result . '000';
	$result = $first_char . substr($result, 0, 3);

	return $result;
}

%soundex_map;

# menempatkan kaya berdasarkan kode fonetik-nya
sub soundex_mapping {
    open(IN, "vocabulary_list.txt");
    open($OUT, ">", "soundex_result.txt");

    while ($line = <IN>) {
        chop $line;

        $code = soundex($line);

        # print untuk soal nomor 4
        print $OUT "$line $code\n";

        if (exists $soundex_map{$code}) {
            push @{$soundex_map{$code}}, $line;
        } else {
            $soundex_map{$code} = ($line);
        }
    }

    close(IN);
    close(OUT);
}

# melakukan stem, sesuai dengan algoritma yang telah ditentukan.
sub stemming {
    open(IN, "vocabulary_list.txt");
    open($OUT, ">", "stemmer_result.txt");

    while ($line = <IN>) {
        chop $line;

        $code = soundex($line);
        $stem = $line;
        $length = length $line;

        $ed_now = -1;
        $lcs_now = 100000;

        foreach $word (@{$soundex_map{$code}}) {
            $edit_distance = levenshtein($line, $word);
            $lcs = lcs($line, $word);
            $sum = $edit_distance + $lcs;

            if ($sum == $length && $edit_distance < $lcs) {
                if ($edit_distance > $ed_now) {
                    $stem = $word;
                    $ed_now = $edit_distance;
                } elsif ($edit_distance == $ed_now) {
                    if ($lcs < $lcs_now) {
                        $stem = $word;
                        $lcs_now = $ed_now;
                    } elsif ($lcs == $lcs_now) {
                        if ((length $word) < (length $stem)) {
                            $stem = $word;
                        }
                    }
                }
            }
        }

        if ($line eq $stem) {
            # do nothing
        } else {
            print $OUT "$line $stem\n";
        }

    }

    close(IN);
    close(OUT);
}

# edit distance
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

# longest common subsequence dengan unigram overlap
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
        }
    }

    return $mat{$len1}{$len2};
}

# fungsi minimum
sub min {
    @list = @{$_[0]};
    $min = $list[0];

    foreach $i (@list) {
        $min = $i if ($i < $min);
    }

    return $min;
}

# fungsi maksimum
sub max {
    ($a, $b) = @_;

    return $a if $a > $b;
    return $b;
}

# generator untuk nomor 5
sub edit_distance_unigram_overlap_generator {
    open($OUT, ">", "edit_distance_unigram_overlap.txt");

    my @words = ("kitten", "sitten", "sittin", "kitty");

    print $OUT "Edit Distance\n";

    for (my $i = 0; $i < 4; $i++) {
        for (my $j = $i; $j < 4; $j++) {
            $edit_distance = levenshtein(@words[$i], @words[$j]);
            print $OUT "@words[$i] @words[$j] $edit_distance\n";
        }
    }

    print $OUT "\nUnigram Overlap\n";

    for (my $i = 0; $i < 4; $i++) {
        for (my $j = $i; $j < 4; $j++) {
            $lcs = lcs(@words[$i], @words[$j]);
            print $OUT "@words[$i] @words[$j] $lcs\n";
        }
    }

    close(OUT);
}

# solve nomor 1
vocabulary_list_generator();

# solve nomor 4 dan mapping vocab dengan kode fonetiknya
soundex_mapping();

# solve nomor 2
stemming();

# solve nomor 5
edit_distance_unigram_overlap_generator();