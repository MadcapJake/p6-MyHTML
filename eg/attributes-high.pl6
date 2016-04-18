use v6.c;
use lib 'lib';

use HTML::MyHTML;

my $html = "<div></div>";

my HTML::MyHTML $myhtml .= new;

$myhtml.parse($html, :fragment);

my $tag-index = $myhtml.tree.tag-index;
my $tag-index-node =

$myhtml.dispose;
