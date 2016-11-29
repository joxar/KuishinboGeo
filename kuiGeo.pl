use strict;
use warnings;
use diagnostics;
use open IO => ":utf8";
use LWP::Simple;
use LWP::UserAgent;
use HTTP::Lite;
use HTML::TreeBuilder;
use HTML::Element;
use Encode qw(decode_utf8);

my $INPUT_FILE = 'INPUT\urlList.txt';
my $OUTPUT_FILE = 'OUTPUT\restaurantList.csv';

my @resultList;
#####################################################
# initialize
unlink "$OUTPUT_FILE";

# read & write
open(DATAFILE, "< $INPUT_FILE") or die("Error:$!");

my $line;
while ($line = <DATAFILE>) {
	print "Processing: $line";
	chomp $line;
	my $url = $line;
	push(@resultList, &getKeywords($url));
}

close(DATAFILE);

exit;


#####################################################
sub getKeywords {
	
	my $givenUrl = $_[0];
	
	my $user_agent = "Mozilla/4.0 (compatible; MSIE 8.0; Windows NT 6.1; Trident/4.0)";
	my $ua = LWP::UserAgent->new('agent' => $user_agent);
	
	my $res = $ua -> get($givenUrl);
	
	my $content = $res -> content;
	
	my $tree = HTML::TreeBuilder->new;
	$tree -> utf8_mode(1);
	$tree -> parse($content); 
	
	#01.ƒWƒƒƒ“ƒ‹&“X–¼
	my @items1 = $tree -> look_down('name', 'keywords');
	#02.ZŠ
	my @items2 = $tree -> look_down('rel', 'address');
	
	open(DATAFILE2, ">>", $OUTPUT_FILE) or die("Error:!");
	
	my $res1;
	my $res2;
	$res1 = decode_utf8($_ -> attr_get_i('content') . "") for @items1;
	$res1=~s/,/-/g;
	$res2 = decode_utf8($_ -> as_text . "") for @items2;
	
	print DATAFILE2 "$res1,$res2\n";
	
	close(DATAFILE2);
	
}
