#!/usr/local/bin/perl

open(IN, "text.txt");

while ($line = <IN>) {
    $cnt = 0;

    chop($line);
    $omega = "Mapan";

    $line =~ s/<[\/]*$omega>//g;

    print "$line\n"
}

close(IN);