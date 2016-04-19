unit class TreeNode is repr('CPointer');

use NativeCall;

use HTML::MyHTML::Lib;
use HTML::MyHTML::Encoding;
use HTML::MyHTML::Namespace;
use HTML::MyHTML::String;
use HTML::MyHTML::Tag;
use HTML::MyHTML::Tree;

has Tree $!tree;

my class MyHTMLAttr is repr('CPointer') {}

multi method sibling(:$next) { myhtml_node_next(self) }

multi method sibling(:$prev) { myhtml_node_prev(self) }

method parent { myhtml_node_parent(self) }

multi method child(:$first) { myhtml_node_child(self) }

multi method child(:$last) { myhtml_node_last_child(self) }

method new(Tree $tree, MyHTMLTagType $tag, MyHTMLNamespace $ns) {
  $!tree = $tree;
  myhtml_node_create($tree, $tag, $ns);
}

method free { myhtml_node_free($!tree, self) }

method remove { myhtml_node_remove($!tree, self) }

multi method delete() { myhtml_node_delete($!tree, self) }

multi method delete(:$recursive) { myhtml_node_delete_recursive($!tree, self) }

multi method insert(TreeNode $loc) { myhtml_node_insert_to_appropriate_place($!tree, self, $loc) }

multi method insert(TreeNode $loc, :$append) { myhtml_node_insert_append_child($!tree, self, $loc) }

multi method insert(TreeNode $loc, :$after) { myhtml_node_insert_after($!tree, self, $loc) }

multi method insert(TreeNode $loc, :$before) { myhtml_node_insert_before($!tree, self, $loc) }

multi method text(Str $text, :$enc) {
  my CArray[uint8] $chs .= new: $text.encode.list;
  myhtml_node_text_set($!tree, self, $chs, $chs.elems, $enc // MyHTML_ENCODING_UTF_8);
}

multi method text(Str $text, :$charef!, :$enc) {
  my CArray[uint8] $chs .= new: $text.encode.list;
  myhtml_node_text_set_with_charef($!tree, self, $chs, $chs.elems, $enc // MyHTML_ENCODING_UTF_8);
}

method namespace { myhtml_node_namespace(self) }

method tag-id { myhtml_node_tag_id(self) }

method tag-name-by-id(MyHTMLTagType $tag-id) { myhtml_tag_name_by_id($!tree, $tag-id) }

method tag-id-by-name(Str $name) {
  my CArray[uint8] $chs = $name.encode.list;
  myhtml_tag_id_by_name($!tree, $chs, $chs.elems);
}

method is-self-closing { myhtml_node_is_close_self(self) }

multi method attribute(:$first) { myhtml_node_attribute_first(self) }

multi method attribute(:$last) { myhtml_node_attribute_last(self) }

multi method text() { myhtml_node_text(self) }

method Str() { myhtml_node_string(self) }
