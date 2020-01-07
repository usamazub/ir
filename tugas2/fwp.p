use strict;
use Plucene::Document;
use Plucene::Analysis::SimpleAnalyzer;
use Plucene::Index::Writer;
use Plucene::QueryParser;
use Plucene::Search::HitCollector;
use Plucene::Search::IndexSearcher;

open(IN, "<", "korpus-tugas2.txt");

my $doc;
my $is_in_text = 0;
my $line;
my $tmp_input;
my $hasil;
my $tag;
my $content;
my $stemmed_title;
my $stemmed_text;
my $tugas3_ir_index = "tugas3_ir_index";

my $analyzer = Plucene::Analysis::SimpleAnalyzer->new();
my $writer = Plucene::Index::Writer->new($tugas3_ir_index, $analyzer, 1);

sub searchQuery {
	my $queryInput = python injectedStemmer.py $_[0];

	my $parser = Plucene::QueryParser->new({
		analyzer => Plucene::Analysis::SimpleAnalyzer->new(),
		default  => "TITLE", "TEXT"
	});

	print "queryInput: $queryInput\n";

	my $query = $parser->parse("TEXT:\"$queryInput\" OR TITLE:\"$queryInput\"");

	my $searcher = Plucene::Search::IndexSearcher->new($tugas3_ir_index);

	my @matchedDocuments = ();
	my $hc = Plucene::Search::HitCollector->new(
		collect => sub {
			my ($self, $doc, $score) = @_;
			my $res = eval { $searcher->doc($doc); };

			if ($res) {
				my $tuple;
				@$tuple = ($score, $res->get('DOCID')->string);
				push @matchedDocuments, $tuple;	
			}
			
		}
	);

	$searcher->search_hc($query, $hc);

	@matchedDocuments = sort { $a->[0] < $b->[0] } @matchedDocuments;
	 
	print "Results:\n";
	foreach my $matchedDocument (@matchedDocuments) {
		print "\t@$matchedDocument[0]\n";
	}
}

my $cnt = 0;
my $dcc_cnt = 0;

while ($line = <IN>) {
	if ($line =~ /^<DOC>$/g) {
		$doc = Plucene::Document->new;
		# print "New document created\n";
	}
	elsif ($line =~ /^<\/DOC>$/g) {
		$dcc_cnt++;
		# print "dcc_cnt: $dcc_cnt\n";
		$writer->add_document($doc);
		undef $doc;
	}
	elsif ($line =~ /^<TEXT>$/g) {
		# print "Enter text mode\n";
		$is_in_text = 1;
		open($tmp_input, ">", "tmp_input.txt");
	}
	elsif ($line =~ /^<\/TEXT>$/g) {
		# print "Exit text mode\n";
		$is_in_text = 0;
		close($tmp_input);
		$stemmed_text=`python injectedStemmer.py`;
		# print "$stemmed_text";
		$doc->add(Plucene::Document::Field->Text(TEXT => $stemmed_text));
		# print $stemmed_text;
	}
	elsif ($is_in_text == 1) {
		# print "writing to tmp file\n";
		print $tmp_input $line;
	}
	elsif ($line =~ /^<([A-Z]+)> (.+) <\/\1>$/) {
		$tag = $1;
		$content = $2;
		if ($tag eq "TITLE") {
			# print "Fetching title\n";
			open($tmp_input, ">", "tmp_input.txt");
			print $tmp_input $content;
			close($tmp_input);
			$stemmed_title=`python injectedStemmer.py`;
			$doc->add(Plucene::Document::Field->Text(TITLE => $stemmed_title));
		}
		if ($tag eq "DOCID") {
			# print "Fetching docid\n";
			$doc->add(Plucene::Document::Field->Keyword(DOCID => $content));
		}
	}
	$cnt++;
	if (($cnt % 100) == 0) {
		print "$cnt\n";
	}
}

$writer->optimize;
undef $writer;



searchQuery("Pemilihan Umum");