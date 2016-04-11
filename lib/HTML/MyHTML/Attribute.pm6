unit class MyHTMLAttr is repr('CPointer');

use NativeCall;

use HTML::MyHTML::Lib;
use HTML::MyHTML::Node;

#| Get next sibling attribute of one node
#|
#| @param[in] myhtml_tree_attr_t*
#|
#| @return myhtml_tree_attr_t* if exists, otherwise an NULL value
sub myhtml_attribute_next(MyHTMLAttr) is native(&lib) returns MyHTMLAttr {*}

method next { myhtml_attribute_next(self) }

#| Get previous sibling attribute of one node
#|
#| @param[in] myhtml_tree_attr_t*
#|
#| @return myhtml_tree_attr_t* if exists, otherwise an NULL value
sub myhtml_attribute_prev(MyHTMLAttr) is native(&lib) returns MyHTMLAttr {*}

method prev { myhtml_attribute_prev(self) }

#| Get attribute namespace
#|
#| @param[in] myhtml_tree_attr_t*
#|
#| @return enum myhtml_namespace
sub myhtml_attribute_namespace(MyHTMLAttr) is native(&lib) returns int32 {*}

method namespace { myhtml_attribute_namespace(self) }

#| Get attribute name (key)
#|
#| @param[in] myhtml_tree_attr_t*
#| @param[out] optional, name length
#|
#| @return const char* if exists, otherwise an NULL value
sub myhtml_attribute_name(MyHTMLAttr) is native(&lib) returns Str {*}

method name { myhtml_attribute_name(self) }

#| Get attribute value
#|
#| @param[in] myhtml_tree_attr_t*
#| @param[out] optional, value length
#|
#| @return const char* if exists, otherwise an NULL value
sub myhtml_attribute_value(MyHTMLAttr) is native(&lib) returns Str {*}

method value { myhtml_attribute_value(self) }

#| Get attribute by key
#|
#| @param[in] myhtml_tree_node_t*
#| @param[in] attr key name
#| @param[in] attr key name length
#|
#| @return myhtml_tree_attr_t* if exists, otherwise a NULL value
sub myhtml_attribute_by_key(TreeNode, CArray[uint8], size_t) is native(&lib) returns Str {*}

method by-key(TreeNode $node, Str $name) {
  my CArray[uint8] $chs .= new: $name.encode.list;
  myhtml_attribute_by_key($node, $chs, $chs.elems);
}

#| Added attribute to tree node
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t*
#| @param[in] attr key name
#| @param[in] attr key name length
#| @param[in] attr value name
#| @param[in] attr value name length
#| @param[in] character encoding; Default: MyHTML_ENCODING_UTF_8 or MyHTML_ENCODING_DEFAULT or 0
#|
#| @return created myhtml_tree_attr_t* if successful, otherwise a NULL value
sub myhtml_attribute_add(MyHTMLTree, TreeNode, CArray[uint8], size_t, CArray[uint8], size_t, int32) is native(&lib) returns MyHTMLAttr {*}

method add($tree, $node, Str $name, Str $value, :$enc) {
  my CArray[uint8] $name-chs  .= $name.encode.list;
  my CArray[uint8] $value-chs .= $value.encode.list;
  myhtml_attribute_add($tree, $node, $name-chs, $name-chs.elems, $value-chs, $value-chs.elems, $enc // 0)
}

#| Remove attribute reference. Do not release the resources
#|
#| @param[in] myhtml_tree_node_t*
#| @param[in] myhtml_tree_attr_t*
#|
#| @return myhtml_tree_attr_t* if successful, otherwise a NULL value
sub myhtml_attribute_remove(TreeNode, MyHTMLAttr) is native(&lib) returns MyHTMLAttr {*}

multi method remove(TreeNode $node, MyHTMLAttr $attr) { myhtml_attribute_remove($node, $attr) }

#| Remove attribute by key reference. Do not release the resources
#|
#| @param[in] myhtml_tree_node_t*
#| @param[in] attr key name
#| @param[in] attr key name length
#|
#| @return myhtml_tree_attr_t* if successful, otherwise a NULL value
sub myhtml_attribute_remove_by_key(TreeNode, Str, size_t) is native(&lib) returns MyHTMLAttr {*}

multi method remove(TreeNode $node, Str $name) { myhtml_attribute_remove_by_key($node, $name, $name.chars) }

#| Remove attribute and release allocated resources
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t*
#| @param[in] myhtml_tree_attr_t*
sub myhtml_attribute_delete(MyHTMLTree, TreeNode, MyHTMLAttr) is native(&lib) {*}

method delete(MyHTMLTree $tree, TreeNode $node, MyHTMLAttr $attr) { myhtml_attribute_delete($tree, $node, $attr) }

#| Release allocated resources
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_attr_t*
sub myhtml_attribute_free(MyHTMLTree, MyHTMLAttr) is native(&lib) {*}

method free(MyHTMLTree $tree, MyHTMLAttr $attr) { myhtml_attribute_free($tree, $attr) }
