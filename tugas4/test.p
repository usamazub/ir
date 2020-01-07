#!/usr/local/bin/perl

use Set::Similarity::Jaccard;
 
my $jaccard = Set::Similarity::Jaccard->new;
my $sim1 = $jaccard->similarity('Photographer','Fotograf');
my $sim2 = $jaccard->similarity('Photographerr','Photographer');

printf "%s %s\n", $sim1, $sim2;
print "------\n";

@a = ([2, 3], [200, 300]);
$a[1][0]++;

print ">> @$a\n";

print "$a[1][0]\n";

# push @a, [55, 66];

@b = (1, 2, 3, 4);

sub pepega {
    (my @input) = @_;

    @input = split(" ", "usama ganteng pol");

    foreach my $k (@input) {
        print ">> $k\n";
    }
}

pepega(@b);