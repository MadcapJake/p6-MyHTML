unit class Tree is repr('CPointer');

use NativeCall;

use HTML::MyHTML::Collection;
use HTML::MyHTML::Encoding;
use HTML::MyHTML::Lib;
use HTML::MyHTML::Status;
use HTML::MyHTML::Tag;

class FILE is repr('CPointer') {}
class MCharAsync is repr('CPointer') {}
class MyHTML is repr('CStruct') {}
# class MyHTMLTag is repr('CPointer') {}
class MyHTMLTagIndex is repr('CPointer') {}
class MyHTMLTreeNode is repr('CPointer') {}

class TreeDocType is repr('CStruct') {
  has bool $.is_html;
  has Str  $.attr_name;
  has Str  $.attr_public;
  has Str  $.attr_system;
}

=begin Struct
=head2 Struct fields
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
=end Struct



method new(\myhtml) {
  my Tree \mytree := myhtml_tree_create();
  say 'tree created';
  myhtml_tree_init(mytree, myhtml);
  say 'tree initialized';
  return mytree;
}



method clean { myhtml_tree_clean(self) }



multi method add(MyHTMLTreeNode $loc, MyHTMLTreeNode $node) { myhtml_tree_node_add_child(self, $loc, $node) }
multi method add(MyHTMLTreeNode $loc, MyHTMLTreeNode $node, :$before) { myhtml_tree_node_insert_before(self, $loc, $node) }
multi method add(MyHTMLTreeNode $loc, MyHTMLTreeNode $node, :$after) { myhtml_tree_node_insert_after(self, $loc, $node) }



method dispose { myhtml_tree_destroy(self) }



method myhtml { myhtml_tree_get_myhtml(self) }



method tag { myhtml_tree_get_tag(self) }



method tag-index { myhtml_tree_get_tag_index(self) }



method document { myhtml_tree_get_document(self) }



method node-html { myhtml_tree_get_node_html(self) }



method node-body { myhtml_tree_get_node_body(self) }


method mchar { myhtml_tree_get_mchar(self) }



method mchar-node-id { myhtml_tree_get_mchar_node_id(self) }



multi method print($node, IO::Handle :$file) {
  myhtml_tree_print_node(self, $node, $file.native-descriptor // $*OUT.native-descriptor);
}
multi method print($node, IO::Handle :$file, :$tree where $tree.so, Int :$pretty = 0) {
  myhtml_tree_print_by_node(self, $node, $file.native-descriptor // $*OUT.native-descriptor, $pretty);
}
multi method print($node, IO::Handle :$file, :$tree where not $tree.so, Int :$pretty = 0) {
  myhtml_tree_print_node_childs(self, $node, $file.native-descriptor // $*OUT.native-descriptor, $pretty);
}



method root { myhtml_node_first(self) }



multi method get-nodes(MyHTMLCollection $collection, MyHTMLTagType $tag-id) {
  my int32 $status;
  my $col = myhtml_get_nodes_by_tag_id(self, $collection, $tag-id, $status);
  $status == 0 ?? return $col !! return $status;
}



multi method get-nodes(MyHTMLCollection $collection, Str $tag-name) {
  my CArray[uint8] $tag-chs = $tag-name.encode.list;
  my int32 $status;
  my $col = myhtml_get_nodes_by_name(self, $collection, $tag-chs, $tag-chs.elems, $status);
  $status == 0 ?? return $col !! return $status;
}


multi method encoding(MyHTMLEncoding $e) { myhtml_encoding_set(self, $e) }



multi method encoding() { myhtml_encoding_get(self) }
