unit class Tree is repr('CPointer');

use NativeCall;

use HTML::MyHTML::Collection;
use HTML::MyHTML::Encoding;
use HTML::MyHTML::Lib;
use HTML::MyHTML::Status;
use HTML::MyHTML::Tag;

class FILE is repr('CPointer') {}
class MCharAsync is repr('CPointer') {}
class MyHTML is repr('CPointer') {}
# class MyHTMLTag is repr('CPointer') {}
class MyHTMLTagIndex is repr('CPointer') {}
class MyHTMLTreeNode is repr('CPointer') {}

class TreeDocType is repr('CStruct') {
  has bool $.is_html;
  has Str  $.attr_name;
  has Str  $.attr_public;
  has Str  $.attr_system;
}

class TreeStruct is repr('CStruct') {
  # ref
  has Pointer #`{myhtml_t*}                    $.myhtml;
  has Pointer #`{mchar_async_t*}               $.mchar;
  has Pointer #`{myhtml_token_t*}              $.token;
  has Pointer #`{mcobject_async_t*}            $.tree_obj;
  has Pointer #`{mcsync_t*}                    $.sync;
  has Pointer #`{mythread_queue_list_entry_t*} $.queue_entry;
  has Pointer #`{mythread_queue_t*}            $.queue;
  has Pointer #`{myhtml_tag_t*}                $.tags;

  # init id's
  has size_t                              $.mcasync_token_id;
  has size_t                              $.mcasync_attr_id;
  has size_t                              $.mcasync_tree_id;
  has size_t                              $.mchar_node_id;
  has size_t                              $.mcasync_incoming_buf_id;
  has Pointer #`{myhtml_token_attr_t*}    $.attr_current;
  has size_t #`{myhtml_tag_id_t}          $.tmp_tag_id;
  has Pointer #`{mythread_queue_node_t*}  $.current_qnode;
  has Pointer #`{myhtml_incoming_buf_t*}  $.incoming_buf;
  has Pointer #`{myhtml_incoming_buf_t*}  $.incoming_buf_first;

  has Pointer #`{myhtml_tree_indexes_t*}  $.indexes;

  # ref for nodes
  has Pointer #`{myhtml_tree_node_t*}     $.document;
  has Pointer #`{myhtml_tree_node_t*}     $.fragment;
  has Pointer #`{myhtml_tree_node_t*}     $.node_head;
  has Pointer #`{myhtml_tree_node_t*}     $.node_html;
  has Pointer #`{myhtml_tree_node_t*}     $.node_body;
  has Pointer #`{myhtml_tree_node_t*}     $.node_form;
  has TreeDocType                         $.doctype;

  # for build tree
  has Pointer #`{myhtml_tree_list_t*}           $.active_formatting;
  has Pointer #`{myhtml_tree_list_t*}           $.open_elements;
  has Pointer #`{myhtml_tree_list_t*}           $.other_elements;
  has Pointer #`{myhtml_tree_token_list_t*}     $.token_list;
  has Pointer #`{myhtml_tree_insertion_list_t*} $.template_insertion;
  has Pointer #`{myhtml_async_args_t*}          $.async_args;
  has Pointer #`{myhtml_tree_temp_stream_t*}    $.temp_stream;
  has Pointer #`{myhtml_token_node_t* volatile} $.token_last_done is rw;

  # for detect namespace out of tree builder
  has Pointer #`{myhtml_token_node_t*}          $.token_namespace;

  # tree params
  has int32 #`{enum myhtml_tokenizer_state}     $.state;
  has int32 #`{enum myhtml_tokenizer_state}     $.state_of_builder;
  has int32 #`{enum myhtml_insertion_mode}      $.insert_mode;
  has int32 #`{enum myhtml_insertion_mode}      $.orig_insert_mode;
  has int32 #`{enum myhtml_tree_compat_mode}    $.compat_mode;
  has int32 #`{volatile enum myhtml_tree_flags} $.flags is rw;
  has bool                                      $.foster_parenting;
  has size_t                                    $.global_offset;

  has int32 #`{myhtml_encoding_t}            $.encoding;
  has int32 #`{myhtml_encoding_t}            $.encoding_usereq;
  has int32 #`{myhtml_tree_temp_tag_name_t}  $.temp_tag_name;

}

#| Create a MyHTML_TREE structure
#|
#| @return myhtml_tree_t* if successful, otherwise an NULL value.
sub myhtml_tree_create() is native(&lib) returns TreeStruct {*}

#| Allocating and Initialization resources for a MyHTML_TREE structure
#|
#| @param[in] myhtml_tree_t*
#| @param[in] workmyhtml_t*
#|
#| @return MyHTML_STATUS_OK if successful, otherwise an error status
sub myhtml_tree_init(TreeStruct, MyHTML) is native(&lib) returns int32 {*}

method new(\myhtml) {
  my \mytree := myhtml_tree_create();
  say 'tree created';
  say status myhtml_tree_init(mytree, myhtml);
  return mytree;
}

#| Clears resources before new parsing
#|
#| @param[in] myhtml_tree_t*
sub myhtml_tree_clean(Tree) is native(&lib) {*}

method clean { myhtml_tree_clean(self) }

#| Add child node to node. If children already exists it will be added to the last
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t* The node to which we add child node
#| @param[in] myhtml_tree_node_t* The node which adds
sub myhtml_tree_node_add_child(Tree, MyHTMLTreeNode, MyHTMLTreeNode) is native(&lib) {*}

#| Add a node immediately before the existing node
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t* add for this node
#| @param[in] myhtml_tree_node_t* add this node
sub myhtml_tree_node_insert_before(Tree, MyHTMLTreeNode, MyHTMLTreeNode) is native(&lib) {*}

#| Add a node immediately after the existing node
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t* add for this node
#| @param[in] myhtml_tree_node_t* add this node
sub myhtml_tree_node_insert_after(Tree, MyHTMLTreeNode, MyHTMLTreeNode) is native(&lib) {*}

multi method add(MyHTMLTreeNode $loc, MyHTMLTreeNode $node) { myhtml_tree_node_add_child(self, $loc, $node) }
multi method add(MyHTMLTreeNode $loc, MyHTMLTreeNode $node, :$before) { myhtml_tree_node_insert_before(self, $loc, $node) }
multi method add(MyHTMLTreeNode $loc, MyHTMLTreeNode $node, :$after) { myhtml_tree_node_insert_after(self, $loc, $node) }

#| Destroy of a MyHTML_TREE structure
#|
#| @param[in] myhtml_tree_t*
#|
#| @return NULL if successful, otherwise an MyHTML_TREE structure
sub myhtml_tree_destroy(Tree) is native(&lib) returns Tree {*}

method dispose { myhtml_tree_destroy(self) }

#| Get myhtml_t* from a myhtml_tree_t*
#|
#| @param[in] myhtml_tree_t*
#|
#| @return myhtml_t* if exists, otherwise a NULL value
sub myhtml_tree_get_myhtml(Tree) is native(&lib) returns MyHTML {*}

method myhtml { myhtml_tree_get_myhtml(self) }

#| Get myhtml_tag_t* from a myhtml_tree_t*
#|
#| @param[in] myhtml_tree_t*
#|
#| @return myhtml_tag_t* if exists, otherwise a NULL value
sub myhtml_tree_get_tag(Tree) is native(&lib) returns MyHTMLTag {*}

method tag { myhtml_tree_get_tag(self) }

#| Get myhtml_tag_index_t* from a myhtml_tree_t*
#|
#| @param[in] myhtml_tree_t*
#|
#| @return myhtml_tag_index_t* if exists, otherwise a NULL value
sub myhtml_tree_get_tag_index(Tree) is native(&lib) returns MyHTMLTagIndex {*}

method tag-index { myhtml_tree_get_tag_index(self) }

#| Get Tree Document (Root of Tree)
#|
#| @param[in] myhtml_tree_t*
#|
#| @return myhtml_tree_node_t* if successful, otherwise a NULL value
sub myhtml_tree_get_document(Tree) is native(&lib) returns MyHTMLTreeNode {*}

method document { myhtml_tree_get_document(self) }

#| Get node HTML (Document -> HTML, Root of HTML Document)
#|
#| @param[in] myhtml_tree_t*
#|
#| @return myhtml_tree_node_t* if successful, otherwise a NULL value
sub myhtml_tree_get_node_html(Tree) is native(&lib) returns MyHTMLTreeNode {*}

method node-html { myhtml_tree_get_node_html(self) }

#| Get node BODY (Document -> HTML -> BODY)
#|
#| @param[in] myhtml_tree_t*
#|
#| @return myhtml_tree_node_t* if successful, otherwise a NULL value
sub myhtml_tree_get_node_body(Tree) is native(&lib) returns MyHTMLTreeNode {*}

method node-body { myhtml_tree_get_node_body(self) }

#| Get mchar_async_t object
#|
#| @param[in] myhtml_tree_t*
#|
#| @return mchar_async_t* if exists, otherwise a NULL value
sub myhtml_tree_get_mchar(Tree) is native(&lib) returns MCharAsync {*}

method mchar { myhtml_tree_get_mchar(self) }

#| Get node_id from main thread for mchar_async_t object
#|
#| @param[in] myhtml_tree_t*
#|
#| @return size_t, node id
sub myhtml_tree_get_mchar_node_id(Tree) is native(&lib) returns size_t {*}

method mchar-node-id { myhtml_tree_get_mchar_node_id(self) }

#| Print tree of a node. Print including current node
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t*
#| @param[in] file handle, for example use stdout
#| @param[in] tab (\t) increment for pretty print, set 0
sub myhtml_tree_print_by_node(Tree, MyHTMLTreeNode, FILE, size_t) is native(&lib) {*}

#| Print tree of a node. Print excluding current node
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t*
#| @param[in] file handle, for example use stdout
#| @param[in] tab (\t) increment for pretty print, set 0
sub myhtml_tree_print_node_childs(Tree, MyHTMLTreeNode, FILE, size_t) is native(&lib) {*}

#| Print a node
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_tree_node_t*
#| @param[in] file handle, for example use stdout
sub myhtml_tree_print_node(Tree, MyHTMLTreeNode, FILE) is native(&lib) {*}

multi method print($node, IO::Handle :$file) {
  myhtml_tree_print_node(self, $node, $file.native-descriptor // $*OUT.native-descriptor);
}
multi method print($node, IO::Handle :$file, :$tree where $tree.so, Int :$pretty = 0) {
  myhtml_tree_print_by_node(self, $node, $file.native-descriptor // $*OUT.native-descriptor, $pretty);
}
multi method print($node, IO::Handle :$file, :$tree where not $tree.so, Int :$pretty = 0) {
  myhtml_tree_print_node_childs(self, $node, $file.native-descriptor // $*OUT.native-descriptor, $pretty);
}

#| Get first (begin) node of tree
#|
#| @param[in] myhtml_tree_t*
#|
#| @return myhtml_tree_node_t* if successful, otherwise a NULL value
sub myhtml_node_first(Tree) is native(&lib) returns MyHTMLTreeNode {*}

method root { myhtml_node_first(self) }

#| Get nodes by tag id
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_collection_t*, creates new collection if NULL
#| @param[in] tag id
#| @param[out] status of this operation
#|
#| @return myhtml_collection_t* if successful, otherwise an NULL value
sub myhtml_get_nodes_by_tag_id(Tree, MyHTMLCollection, int32, int32) is native(&lib) returns MyHTMLCollection {*}

multi method get-nodes(MyHTMLCollection $collection, MyHTMLTagType $tag-id) {
  my int32 $status;
  my $col = myhtml_get_nodes_by_tag_id(self, $collection, $tag-id, $status);
  $status == 0 ?? return $col !! return $status;
}

#| Get nodes by tag name
#|
#| @param[in] myhtml_tree_t*
#| @param[in] myhtml_collection_t*, creates new collection if NULL
#| @param[in] tag name
#| @param[in] tag name length
#| @param[out] status of this operation
#|
#| @return myhtml_collection_t* if successful, otherwise an NULL value
sub myhtml_get_nodes_by_name(Tree, MyHTMLCollection, CArray[uint8], size_t, int32) is native(&lib) returns MyHTMLCollection {*}

multi method get-nodes(MyHTMLCollection $collection, Str $tag-name) {
  my CArray[uint8] $tag-chs = $tag-name.encode.list;
  my int32 $status;
  my $col = myhtml_get_nodes_by_name(self, $collection, $tag-chs, $tag-chs.elems, $status);
  $status == 0 ?? return $col !! return $status;
}

#| Set character encoding for input stream
#|
#| @param[in] myhtml_tree_t*
#| @param[in] Input character encoding
#|
#| @return NULL if successful, otherwise an myhtml_collection_t* structure
sub myhtml_encoding_set(Tree, int32) is native(&lib) {*}

multi method encoding(MyHTMLEncoding $e) { myhtml_encoding_set(self, $e) }

#| Get character encoding for current stream
#|
#| @param[in] myhtml_tree_t*
#|
#| @return myhtml_encoding_t
sub myhtml_encoding_get(Tree) is native(&lib) {*}

multi method encoding() { myhtml_encoding_get(self) }
