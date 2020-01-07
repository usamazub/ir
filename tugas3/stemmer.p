#!/usr/local/bin/perl

sub stem {
    ($word) = @_;

    my @args = ("python3", "stemmer.py", "$word");
    system(@args);

    open(INSTEM, "hasil_stem.txt");
    
    my $word;

    while (my $line = <INSTEM>) {
        chop $line;
        $word = $line;
        last;
    }

    close(INSTEM);

    return $word;
}

sub stem_korpus {
    open(IN, "korpus-tugas2.txt");
    open($OUT, ">", "korpus-tugas2-stem.txt");

    while (my $line = <IN>) {
        chop $line;

        my $word = $line;

        if (($word =~ /<DOC>/) || ($word =~ /<\/DOC>/)) {
           # do nothing
        } elsif ($word =~ /<DOCID>/) {
            # do nothing
        } elsif ($word =~ /<SO>/) {
            # do nothing
        } elsif ($word =~ /<SECTION>/) {
            # do nothing
        } elsif ($word =~ /<DATE>/) {
            # do nothing
        } elsif (($word =~ /<TEXT>/) || ($word =~ /<\/TEXT>/)) {
            # do nothing
        } else {
            $word = stem($word);
        }

        $word =~ s/title/<TITLE>/;
        $word =~ s/ title/ <\/TITLE>/;

        print $OUT "$word\n";
    }

    close(IN);
    close(OUT);
}

# stem_korpus();