use v6.c;
use lib '../lib';

use HTML::MyHTML

# basic init
my HTML::MyHTML $parser .= new;

# gather some html
my $website = qx{curl -s http://www.example.com};

# parse html
$parser.parse($website);

# collect title tags
my @collection = $parser.tree.nodes:tag<title>;

$parser.tree.print(@collection[0])

# say "Title: {@collection[0].Str}"

@collection.dispose;
$parser.dispose;
