use v6.c;
use lib 'lib';
use Test;

use HTML::MyHTML;

my $html = "<div></div>";

my MyHTML $myhtml   .= new: opt => PARSE_MODE_SEPARATELY;

is $myhtml.parse($html):fragment, 0, 'myhtml_parse_fragment returns OK';

$myhtml.dispose;
