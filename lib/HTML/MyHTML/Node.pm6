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

#| Get next sibling node
#|
#| @param[in] myhtml_tree_node_t*
#|
#| @return myhtml_tree_node_t* if exists, otherwise an NULL value
sub myhtml_node_next(TreeNode) is native(&lib) returns TreeNode {*}

multi method sibling(:$next) { myhtml_node_next(self) }

#| Get previous sibling node
#|
#| @param[in] myhtml_tree_node_t*
#|
#| @return myhtml_tree_node_t* if exists, otherwise an NULL value
sub myhtml_node_prev(TreeNode) is native(&lib) returns TreeNode {*}

multi method sibling(:$prev) { myhtml_node_prev(self) }

#| Get parent node
#|
#| @param[in] myhtml_tree_node_t*
#|
#| @return myhtml_tree_node_t* if exists, otherwise an NULL value
sub myhtml_node_parent(TreeNode) is native(&lib) returns TreeNode {*}

method parent { myhtml_node_parent(self) }

#| Get child (first child) of node
#|
#| @param[in] myhtml_tree_node_t*
#|
#| @return myhtml_tree_node_t* if exists, otherwise an NULL value
sub myhtml_node_child(TreeNode) is native(&lib) returns TreeNode {*}

multi method child(:$first) { myhtml_node_child(self) }

#| Get last child of node
#|
#| @param[in] myhtml_tree_node_t*
#|
#| @return myhtml_tree_node_t* if exists, otherwise an NULL value
sub myhtml_node_last_child(TreeNode) is native(&lib) returns TreeNode {*}

multi method child(:$last) { myhtml_node_last_child(self) }

#| Create new node
#|
#| @param[in] myhtml_tree_t*
#| @param[in] tag id, see enum myhtml_tags
#| @param[in] enum myhtml_namespace
#|
#| @return myhtml_tree_node_t* if successful, otherwise a NULL value
sub myhtml_node_create(Tree, int32, int32) is native(&lib) returns TreeNode {*}

method new(Tree $tree, MyHTMLTagType $tag, MyHTMLNamespace $ns) {
  $!tree = $tree;
  myhtml_node_create($tree, $tag, $ns);
}

#| Release allocated resources
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t*
sub myhtml_node_free(Tree, TreeNode) is native(&lib) {*}

method free { myhtml_node_free($!tree, self) }

#| Remove node of tree
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t*
#|
#| @return myhtml_tree_node_t* if successful, otherwise a NULL value
sub myhtml_node_remove(Tree, TreeNode) is native(&lib) returns TreeNode {*}

method remove { myhtml_node_remove($!tree, self) }

#| Remove node of tree and release allocated resources
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t*
sub myhtml_node_delete(Tree, TreeNode) is native(&lib) {*}

multi method delete() { myhtml_node_delete($!tree, self) }

#| Remove nodes of tree recursively and release allocated resources
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t*
sub myhtml_node_delete_recursive(Tree, TreeNode) is native(&lib) {*}

multi method delete(:$recursive) { myhtml_node_delete_recursive($!tree, self) }

#| The appropriate place for inserting a node. Insertion with validation.
#| If try insert <a> node to <table> node, then <a> node inserted before <table> node
#|
#| @param[in] myhtml_tree_t*
#| @param[in] target node
#| @param[in] insertion node
#|
#| @return insertion node if successful, otherwise a NULL value
sub myhtml_node_insert_to_appropriate_place(Tree, TreeNode, TreeNode) is native(&lib) returns TreeNode {*}

multi method insert(TreeNode $loc) { myhtml_node_insert_to_appropriate_place($!tree, self, $loc) }

#| Append to target node as last child. Insertion without validation.
#|
#| @param[in] myhtml_tree_t*
#| @param[in] target node
#| @param[in] insertion node
#|
#| @return insertion node if successful, otherwise a NULL value
sub myhtml_node_insert_append_child(Tree, TreeNode, TreeNode) is native(&lib) returns TreeNode {*}

multi method insert(TreeNode $loc, :$append) { myhtml_node_insert_append_child($!tree, self, $loc) }

#| Append sibling node after target node. Insertion without validation.
#|
#| @param[in] myhtml_tree_t*
#| @param[in] target node
#| @param[in] insertion node
#|
#| @return insertion node if successful, otherwise a NULL value
sub myhtml_node_insert_after(Tree, TreeNode, TreeNode) is native(&lib) returns TreeNode {*}

multi method insert(TreeNode $loc, :$after) { myhtml_node_insert_after($!tree, self, $loc) }

#| Append sibling node before target node. Insertion without validation.
#|
#| @param[in] myhtml_tree_t*
#| @param[in] target node
#| @param[in] insertion node
#|
#| @return insertion node if successful, otherwise a NULL value
sub myhtml_node_insert_before(Tree, TreeNode, TreeNode) is native(&lib) returns TreeNode {*}

multi method insert(TreeNode $loc, :$before) { myhtml_node_insert_before($!tree, self, $loc) }

#| Add text for a node with convert character encoding.
#|
#| @param[in] myhtml_tree_t*
#| @param[in] target node
#| @param[in] text
#| @param[in] text length
#| @param[in] character encoding
#|
#| @return myhtml_string_t* if successful, otherwise a NULL value
sub myhtml_node_text_set(Tree, TreeNode, CArray[uint8], size_t, int32) is native(&lib) returns MyHTMLString {*}

multi method text(Str $text, :$enc) {
  my CArray[uint8] $chs .= new: $text.encode.list;
  myhtml_node_text_set($!tree, self, $chs, $chs.elems, $enc // MyHTML_ENCODING_UTF_8);
}

#| Add text for a node with convert character encoding.
#|
#| @param[in] myhtml_tree_t*
#| @param[in] target node
#| @param[in] text
#| @param[in] text length
#| @param[in] character encoding
#|
#| @return myhtml_string_t* if successful, otherwise a NULL value
sub myhtml_node_text_set_with_charef(Tree, TreeNode, CArray[uint8], size_t, int32) is native(&lib) returns MyHTMLString {*}

multi method text(Str $text, :$charef!, :$enc) {
  my CArray[uint8] $chs .= new: $text.encode.list;
  myhtml_node_text_set_with_charef($!tree, self, $chs, $chs.elems, $enc // MyHTML_ENCODING_UTF_8);
}

#| Get node namespace
#|
#| @param[in] myhtml_tree_node_t*
#|
#| @return enum myhtml_namespace
sub myhtml_node_namespace(TreeNode) is native(&lib) returns int32 {*}

method namespace { myhtml_node_namespace(self) }

#| Get node tag id
#|
#| @param[in] myhtml_tree_node_t*
#|
#| @return myhtml_tag_id_t
sub myhtml_node_tag_id(TreeNode) is native(&lib) returns int32 {*}

method tag-id { myhtml_node_tag_id(self) }

#| Get tag name by tag id
#|
#| @param[in] myhtml_tree_t*
#| @param[in] tag id
#| @param[out] optional, name length
#|
#| @return const char* if exists, otherwise a NULL value
sub myhtml_tag_name_by_id(Tree, int32) is native(&lib) returns Str {*}

method tag-name-by-id(MyHTMLTagType $tag-id) { myhtml_tag_name_by_id($!tree, $tag-id) }

#| Get tag id by name
#|
#| @param[in] myhtml_tree_t*
#| @param[in] tag name
#| @param[in] tag name length
#|
#| @return tag id
sub myhtml_tag_id_by_name(Tree, CArray[uint8], size_t) is native(&lib) returns int32 {*}

method tag-id-by-name(Str $name) {
  my CArray[uint8] $chs = $name.encode.list;
  myhtml_tag_id_by_name($!tree, $chs, $chs.elems);
}

#| Node has self-closing flag?
#|
#| @param[in] myhtml_tree_node_t*
#|
#| @return true or false (1 or 0)
sub myhtml_node_is_close_self(TreeNode) is native(&lib) returns bool {*}

method is-self-closing { myhtml_node_is_close_self(self) }

#| Get first attribute of a node
#|
#| @param[in] myhtml_tree_node_t*
#|
#| @return myhtml_tree_attr_t* if exists, otherwise an NULL value
sub myhtml_node_attribute_first(TreeNode) is native(&lib) returns MyHTMLAttr {*}

multi method attribute(:$first) { myhtml_node_attribute_first(self) }

#| Get last attribute of a node
#|
#| @param[in] myhtml_tree_node_t*
#|
#| @return myhtml_tree_attr_t* if exists, otherwise an NULL value
sub myhtml_node_attribute_last(TreeNode) is native(&lib) returns MyHTMLAttr {*}

multi method attribute(:$last) { myhtml_node_attribute_last(self) }

#| Get text of a node. Only for a MyHTML_TAG__TEXT or MyHTML_TAG__COMMENT tags
#|
#| @param[in] myhtml_tree_node_t*
#| @param[out] optional, text length
#|
#| @return const char* if exists, otherwise an NULL value
sub myhtml_node_text(TreeNode) is native(&lib) returns Str {*}

multi method text() { myhtml_node_text(self) }

#| Get myhtml_string_t object by Tree node
#|
#| @param[in] myhtml_tree_node_t*
#|
#| @return myhtml_string_t* if exists, otherwise an NULL value
sub myhtml_node_string(TreeNode) is native(&lib) returns MyHTMLString {*}

method Str() { myhtml_node_string(self) }
