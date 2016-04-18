use v6.c;
use lib 'lib';

use HTML::MyHTML;

my $html = "<div></div>";

say 'running now...';
my HTML::MyHTML $myhtml .= new;
say $myhtml.parse: $html, :fragment;

$myhtml.dispose;
