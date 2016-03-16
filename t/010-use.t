use v6;
use Test;

use-ok('HTML::MyHTML');

use HTML::MyHTML;

my Str $html = "<div><span>HTML</span></div>";

my $myhtml = MyHTML.new(MyHTML_OPTIONS_DEFAULT, 1, 0);

my $tree = MyHTMLTree.new($myhtml);

is 0, $myhtml.parse($tree, $html), 'parsing returns successful exit code';

$tree.dispose;
$myhtml.dispose;

done-testing;
