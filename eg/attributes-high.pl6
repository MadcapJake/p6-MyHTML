use v6.c;
use lib 'lib';

use NativeCall;

use HTML::MyHTML::Raw;

my $html = "<div></div>";
my CArray[uint] $chs .= new: $html.encode('UTF-8').list;

# basic init
my $myhtml = myhtml_create();
myhtml_init($myhtml, 0, 1, 0);

# init tree
my $tree = myhtml_tree_create();
myhtml_tree_init($tree, $myhtml);

# parse html
myhtml_parse_fragment($tree, 0, $chs, nativesizeof($chs) + 2, 0x02a, 0x01);

# get first DIV from index
my $tag-idx = myhtml_tree_get_tag_index($tree);
my $idx-node = myhtml_tag_index_first($tag-idx, 0x02a);

my $node = myhtml_tag_index_tree_node($idx-node);

# print original tree
say "Original tree:";
myhtml_tree_print_node_childs(
  $tree,
  myhtml_tree_get_document($tree),
  FILE.fd(1),
  0
);

=for testing
say "For a test; Create and delete 100_000 attrs...";
for ^100_000 {
  my CArray[uint] $key   .= new("key".encode.list);
  my CArray[uint] $value .= new("value".encode.list);
  my $attr = myhtml_attribute_add($tree, $node, $key, 3, $value, 5, 0x00);
  myhtml_attribute_delete($tree, $node, $attr);
}

=finish
# add first attr in first div in tree
myhtml_attribute_add($tree, $node, "key", 3, "value", 5, 0x00);

say "Modified tree:";
myhtml_tree_print_node_childs(
  $tree,
  myhtml_tree_get_document($tree),
  FILE.new(1),
  0
);

# get attr by key name
my $gets-attr = myhtml_attribute_by_key($node, "key", 3);
my Str $attr-char = myhtml_attribute_value($gets-attr);
say "Get attr by key name\n key: $attr-char";

# release resources
myhtml_tree_destroy($tree);
myhtml_destroy($myhtml);
