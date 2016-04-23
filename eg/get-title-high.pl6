use v6.c;
use lib 'lib';

use HTML::MyHTML;

# basic init
my HTML::MyHTML $parser .= new;

# gather some html
my $website = qx{curl -s http://www.example.com};

# parse html
$parser.parse($website);

# collect title tags
my @collection := $parser.tree.nodes('title');

# take first node in collection
my $node = @collection[0];

# $parser.tree.print($node):i;

say "Title: {@collection[0].Str}";

@collection.dispose;
$parser.dispose;
