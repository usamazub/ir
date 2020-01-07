#!/usr/local/bin/perl

use Plucene::Document::DateSerializer;
use Plucene::Analysis::SimpleAnalyzer;
use Plucene::Index::Writer;
use Plucene::QueryParser;
use Plucene::Search::HitCollector;
use Plucene::Search::IndexSearcher;
use Data::Dumper;

# fungsi yang melakukan stem
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

# analyzer dan writer yang digunakan berdasarkan https://metacpan.org/pod/Plucene
my $analyzer = Plucene::Analysis::SimpleAnalyzer->new();
my $writer = Plucene::Index::Writer->new("tugas3_index", $analyzer, 1);

# melakukan pengindeksan dokumen
sub index_docs {
    open(IN, "korpus-tugas2-stem.txt");

    my $is_text = 0;
    my $doc;
    my @texts = ();
    my $doc_id;
    my $title;

    while (my $line = <IN>) {
        chop $line;

        if ($line =~ /<DOC>/) { # terdapat dokumen baru
            $doc = Plucene::Document->new;
        } elsif ($line =~ /<\/DOC>/) {
            $writer->add_document($doc);
            undef $doc;
        } elsif ($line =~ /<DOCID>/) {
            # setiap DOCID berada pada kolom ke-9 dan memiliki panjang 16
            $doc_id = substr $line, 8, 16;
        } elsif (($line =~ /<SO>/) || ($line =~ /<SECTION>/)) {
            # do nothing
        } elsif ($line =~ /<DATE>/) {
            # do nothing
        } elsif ($line =~ /<TITLE>/) {
            # dapatkan title dari dokumen
            $title = $line;
            $title =~ s/<TITLE> //;
            $title =~ s/ <\/TITLE>//;
        } elsif ($line =~ /<TEXT>/) { # baris setelah ini merupakan text dari dokument
            $is_text = 1;

            goto NEXT_LINE;
        } elsif ($line =~ /<\/TEXT>/) {
            # concat text yang telah didapatkan
            my $text = $title."\n";

            foreach $txt (@texts) {
                $text = $text.$txt."\n";
            }

            # membuat dokumen dengan menambahkan field yang sesuai
            $doc->add(Plucene::Document::Field->Text(TEXT => $text));
            $doc->add(Plucene::Document::Field->Keyword(DOCID => $doc_id));

            $is_text = 0;
            @texts = ();
        }
        
        if ($is_text == 1) {
            push @texts, $line;
        }

        NEXT_LINE:
    }

    # analyzer berdasarkan https://metacpan.org/pod/Plucene
    $writer->optimize;
    undef $writer;
}

# mencari dokumen berdasarkan query
sub search_doc {
    (my $input) = @_;

    my $output_name = $input."_documents.txt";

    $input = stem($input);

    # parser berdasarkan https://metacpan.org/pod/Plucene
    my $parser = Plucene::QueryParser->new({
		analyzer => Plucene::Analysis::SimpleAnalyzer->new(),
		default  => "TEXT"
	});

    my @spl = split(' ', $input);

    $parser_parameter = "";

    # buat boolean model dengan or, misalkan query a b c -> maka querynya menjadi "a or b or c"
    foreach my $i (@spl) {
        if ($parser_parameter == "") {
            $parser_parameter = $parser_parameter."TEXT:\"$i\"";
        } else {
            $parser_parameter = $parser_parameter." OR "."TEXT:\"$i\"";
        }
    }

    # membuat query
    my $query = $parser->parse("$parser_parameter");
    
    # pass query ke IndexSearcher dan collect hits
    my $searcher = Plucene::Search::IndexSearcher->new("tugas3_index");

    my @docs;

    my $hc = Plucene::Search::HitCollector->new(collect => sub {
        my ($self, $doc, $score) = @_;
        my $doc_id = $searcher->doc($doc)->get("DOCID")->string;

        push @docs, [$score, $doc_id];
    });

    $searcher->search_hc($query, $hc);

    # sort berdasarkan nilai yang tertinggi
    @docs = sort { $a->[0] <=> $b->[0] } @docs;
    @docs = reverse(@docs);

    open($output_file, ">", $output_name);

    printf $output_file "%-20s %s\n", "SCORE", "DOCUMENT ID";

    foreach $document (@docs) {
        printf $output_file "%-20.15lf %s\n", @$document[0], @$document[1];
    }

    close($output_file);
}

index_docs();
search_doc("pemilihan umum");
search_doc("pemilihan umum presiden");
search_doc("penetapan pemilihan umum presiden");
