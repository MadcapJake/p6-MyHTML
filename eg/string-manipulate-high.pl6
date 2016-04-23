use v6.c;
use lib 'lib';

use HTML::MyHTML;

# basic init
my HTML::MyHTML $parser .= new;

my $div = "<div>text for manipulate </div>";

# parse html
$parser.parse($div);

# print original tree
"Original Tree".say;
$parser.tree.print($parser.tree.document):e;

$parser.dispose;
