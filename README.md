# HTML::MyHTML

A wrapper for [MyHTML](http://lexborisov.github.io/myhtml/) an HTML parser.

## Usage

```
panda install HTML::MyHTML
```
```
zef install HTML::MyHTML
```
### Example
Currently only provides a NativeCall interface:
```perl6
use HTML::MyHTML::Raw;

my $html = "<div><span>HTML</span></div>".encode;

# basic init
my $myhtml = myhtml_create();
myhtml_init($myhtml, 0, 1, 0);

# first tree init
my $tree = myhtml_tree_create();
myhtml_tree_init($tree, $myhtml);

# parse html
myhtml_parse($tree, 0, $html, $html.bytes);

# release resources
myhtml_tree_destroy($tree);
myhtml_destroy($myhtml);
```
