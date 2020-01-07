#!/usr/local/bin/perl

use Set::Similarity::Jaccard;
use Text::Trim;

my $jaccard = Set::Similarity::Jaccard->new;

%positives = (); # kata positf
%negatives = (); # kata negatif
%clusters = (); # map cluster -> clusters[tweet_id] = cluster
%centroid_test_iter = (); # checker untuk menentukan centroid selanjutnya
@tweets = (); # berisi [tweet_id, tweet_text]

# array sentiment untuk mengerjakan soal b
@sentiments = (
    [],
    [0, 0, 0],
    [0, 0, 0],
    [0, 0, 0]
);

# centroid awal berdasar soal, akan diupdate seperlunya
@centroid = (
    "",
    "relawan jokowi dan seknas pdip didesak kumpulkan uang untuk memperkuat rupiah aduh",
    "rt intelijen apabila jokowi berani memecat puan maharani maka rupiah bisa menguat dan kepercayaan rakyat terhadap jokowi akan kembali m",
    "charles honoris optimis jokowi bangun bangsa via ekonomi rupiah melemah gubernur bi klaim perbankan dprkerja",
    "rt kandargalang mantaaap jokowi moharifwidarto paket kebijakan ekonomi akan diumumkan rupiah menguat hebat"
);

# fungsi untuk menyimpan kata-kata sentiment (positif dan negatif)
sub generate_sentiment_words {
    open(in_pos, "data/positif.txt");
    open(in_neg, "data/negatif.txt");

    while (my $pos_word = <in_pos>) {
        chop $pos_word;
        $positives{$pos_word} = 1;
    }

    while (my $neg_word = <in_neg>) {
        chop $neg_word;
        $negatives{$neg_word} = 1;
    }

    close(in_pos);
    close(in_neg);
}

# update centroid
# parameter -> (cluster_index, iterasi_ke)
sub update_centroid {
    (my $idx, my $iteration) = @_;

    # jalankan untuk setiap tweet
    foreach my $tweet (@tweets) {
        my $tweet_id = @$tweet[0];
        my $tweet_text = @$tweet[1];
        my $max_similarity = 0;

        # cek kandidat centroid untuk cluster ke cluster_index
        if ($clusters{$tweet_id} == $idx && $centroid_test_iter{$tweet_id} < $iteration) {
            $centroid_test_iter{$tweet_id} = $iteration;
            my $total_twt = 0;
            my $sum_sim = 0;

            foreach $twt (@tweets) {
                my $twt_id = @$tweet[0];
                my $twt_text = @$tweet[1];

                if ($clusters{$twt_id} == $idx) {
                    $total_twt++;

                    my $sim = $jaccard->similarity($tweet_text,$twt_text);

                    $sum_sim = $sum_sim + $sim;
                }
            }

            my $mean_sim = $sum_sim / $total_twt;

            if ($max_similarity < $mean_sim) {
                $max_similarity = $mean_sim;
                $centroid[$idx] = $tweet_text;
            }
        }
    }
}

# clustering tweets
sub find_cluster {
    # lakukan k means max sebanyak 10x, jika ternyata centroid tidak berubah langsung stop.
    for (my $iter = 1; $iter <= 10; $iter++) {
        # cek setiap tweet
        foreach my $tweet (@tweets) {
            my $tweet_id = @$tweet[0];
            my $tweet_text = @$tweet[1];

            my $distance = -1;
            my $cluster_number = 0;

            # masukkan tweet ke cluster yang sesuai
            for (my $k = 1; $k <= 4; $k++) {
                my $tmp = $jaccard->similarity($centroid[$k],$tweet_text);

                if ($tmp > $distance) {
                    $distance = $tmp;
                    $cluster_number = $k;
                }
            }

            $clusters{$tweet_id} = $cluster_number;
        }

        my $done = 0;

        # untuk setiap cluster, cari centroid baru
        for (my $k = 1; $k <= 4; $k++) {
            my $before = $centroid[$k];
            update_centroid($k, $iter);

            if ($before ne $centroid[$k]) {
                $done = 1;
            }
        }

        # jika centroid tidak ada yang berubah, maka stop k-means karena tidak akan ada perubahan setelahnya
        if ($done == 0) {
            $iter = 100;
        }
    }
}

# print sesuai soal
sub print_cluster {
    open($out, ">", "output/1606862766_output_a.txt");

    my $no_urut = 0;

    foreach my $tweet (@tweets) {
        my $id = @$tweet[0];
        my $text = @$tweet[1];
        my $cluster_number = $clusters{$id};

        $no_urut++;

        printf $out "%d\t%d\t%s\t%s\n", $cluster_number, $no_urut, $id, $text
    }

    close($out);
}

# hitung nilai sentiment kalimat
sub check_sentiment {
    (my @words) = @_;

    my $sentiment = 0;

    foreach my $word (@words) {
        if (exists $positives{$word}) {
            $sentiment++;
        } elsif (exists $negatives{$word}) {
            $sentiment--;
        }
    }

    return $sentiment;
}

# menghitung sentiment dari setiap cluster, namun pengerjaan dilakukan untuk setiap tweet karena kita sudah mencatata tweet_id tweet berada di cluster berapa
sub tweet_sentiments {
    open($out, ">", "output/1606862766_output_b.txt");

    foreach my $tweet (@tweets) {
        my $id = @$tweet[0];
        my $text = @$tweet[1];
        my @txt = split(" ", $text);
        my $value = check_sentiment(@txt);
        my $cluster = $clusters{$id};

        if ($value > 0) {
            $sentiments[$cluster][0]++;
        } elsif ($value < 0) {
            $sentiments[$cluster][1]++;
        } else {
            $sentiments[$cluster][2]++;
        }
    }

    for ($k = 1; $k <= 4; $k++) {
        printf $out "%d\t%d\t%d\t%d\n", $k, $sentiments[$k][0], $sentiments[$k][1], $sentiments[$k][2];
    }

    close($out);
}

# dapatkan tweet kemudian simpan di array
sub collect_tweets {
    open(in_data_twitter, "data/twitter_rupiah.txt");

    while (my $line = <in_data_twitter>) {
        chop $line;

        my $tweet_id = substr $line, 0, 18;
        my $tweet_text = trim(substr $line, 18);

        push @tweets, [$tweet_id, $tweet_text];

        $centroid_test_iter{$tweet_id} = 0;
    }

    close(in_data_twitter);
}

collect_tweets();
find_cluster();
print_cluster();
generate_sentiment_words();
tweet_sentiments();
