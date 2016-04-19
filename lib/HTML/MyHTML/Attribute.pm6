unit class MyHTMLAttr is repr('CPointer');

use NativeCall;

use HTML::MyHTML::Lib;
use HTML::MyHTML::Node;

method next { myhtml_attribute_next(self) }

method prev { myhtml_attribute_prev(self) }

method namespace { myhtml_attribute_namespace(self) }

method name { myhtml_attribute_name(self) }

method value { myhtml_attribute_value(self) }

method by-key(TreeNode $node, Str $name) {
  my CArray[uint8] $chs .= new: $name.encode.list;
  myhtml_attribute_by_key($node, $chs, $chs.elems);
}

method add($tree, $node, Str $name, Str $value, :$enc) {
  my CArray[uint8] $name-chs  .= $name.encode.list;
  my CArray[uint8] $value-chs .= $value.encode.list;
  myhtml_attribute_add($tree, $node, $name-chs, $name-chs.elems, $value-chs, $value-chs.elems, $enc // 0)
}

multi method remove(TreeNode $node, MyHTMLAttr $attr) { myhtml_attribute_remove($node, $attr) }

multi method remove(TreeNode $node, Str $name) { myhtml_attribute_remove_by_key($node, $name, $name.chars) }

method delete(MyHTMLTree $tree, TreeNode $node, MyHTMLAttr $attr) { myhtml_attribute_delete($tree, $node, $attr) }

method free(MyHTMLTree $tree, MyHTMLAttr $attr) { myhtml_attribute_free($tree, $attr) }
