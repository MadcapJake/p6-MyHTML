#| The bare C API of MyHTML
unit module HTML::MyHTML;

=begin pod
This is the raw bindings of MyHTML and allows you to skip over the
more perl6 API that I've built in L<HTML::MyHTML>. See the
L<MyHTML repo|https://github.com/lexborisov/myhtml> for more info.
=end pod

=head2 Example Usage

=begin pod
Here is a basic example that doesn't really do anything but load and
then destroy afterwards:

    use HTML::MyHTML::Raw;

    my $html = "<div><span> HTML </span></div>";

    my $myhtml = myhtml_create();
    is 0, myhtml_init($myhtml, 0x00, 1, 0);

    my $tree = myhtml_tree_create();
    is 0, myhtml_tree_init($tree, $myhtml);

    is 0, myhtml_parse($tree, 0, $html, $html.chars);

    myhtml_tree_destroy($tree);
    myhtml_destroy($myhtml);

I need to add another example that shows how to use it.
=end pod

use NativeCall;

use HTML::MyHTML::Lib;
use HTML::MyHTML::Tag;

enum HTML::MyHTML::Encoding (
    MyHTML_ENCODING_DEFAULT          => 0x00,
    MyHTML_ENCODING_AUTO             => 0x01, # future
    MyHTML_ENCODING_CUSTOM           => 0x02, # future
    MyHTML_ENCODING_UTF_8            => 0x00, # default encoding
    MyHTML_ENCODING_UTF_16LE         => 0x04,
    MyHTML_ENCODING_UTF_16BE         => 0x05,
    MyHTML_ENCODING_X_USER_DEFINED   => 0x06,
    MyHTML_ENCODING_BIG5             => 0x07,
    MyHTML_ENCODING_EUC_KR           => 0x08,
    MyHTML_ENCODING_GB18030          => 0x09,
    MyHTML_ENCODING_IBM866           => 0x0a,
    MyHTML_ENCODING_ISO_8859_10      => 0x0b,
    MyHTML_ENCODING_ISO_8859_13      => 0x0c,
    MyHTML_ENCODING_ISO_8859_14      => 0x0d,
    MyHTML_ENCODING_ISO_8859_15      => 0x0e,
    MyHTML_ENCODING_ISO_8859_16      => 0x0f,
    MyHTML_ENCODING_ISO_8859_2       => 0x10,
    MyHTML_ENCODING_ISO_8859_3       => 0x11,
    MyHTML_ENCODING_ISO_8859_4       => 0x12,
    MyHTML_ENCODING_ISO_8859_5       => 0x13,
    MyHTML_ENCODING_ISO_8859_6       => 0x14,
    MyHTML_ENCODING_ISO_8859_7       => 0x15,
    MyHTML_ENCODING_ISO_8859_8       => 0x16,
    MyHTML_ENCODING_KOI8_R           => 0x17,
    MyHTML_ENCODING_KOI8_U           => 0x18,
    MyHTML_ENCODING_MACINTOSH        => 0x19,
    MyHTML_ENCODING_WINDOWS_1250     => 0x1a,
    MyHTML_ENCODING_WINDOWS_1251     => 0x1b,
    MyHTML_ENCODING_WINDOWS_1252     => 0x1c,
    MyHTML_ENCODING_WINDOWS_1253     => 0x1d,
    MyHTML_ENCODING_WINDOWS_1254     => 0x1e,
    MyHTML_ENCODING_WINDOWS_1255     => 0x1f,
    MyHTML_ENCODING_WINDOWS_1256     => 0x20,
    MyHTML_ENCODING_WINDOWS_1257     => 0x21,
    MyHTML_ENCODING_WINDOWS_1258     => 0x22,
    MyHTML_ENCODING_WINDOWS_874      => 0x23,
    MyHTML_ENCODING_X_MAC_CYRILLIC   => 0x24,
    MyHTML_ENCODING_LAST_ENTRY       => 0x25
);

enum HTML::MyHTML::Options is export (
  MyHTML_OPTIONS_DEFAULT                 => 0x00,
  MyHTML_OPTIONS_PARSE_MODE_SINGLE       => 0x01,
  MyHTML_OPTIONS_PARSE_MODE_ALL_IN_ONE   => 0x02,
  MyHTML_OPTIONS_PARSE_MODE_SEPARATELY   => 0x04,
  MyHTML_OPTIONS_PARSE_MODE_WORKER_TREE  => 0x08,
  MyHTML_OPTIONS_PARSE_MODE_WORKER_INDEX => 0x10,
  MyHTML_OPTIONS_PARSE_MODE_TREE_INDEX   => 0x20
);

enum HTML::MyHTML::Namespace is export (
  MyHTML_NAMESPACE_UNDEF      => 0x00,
  MyHTML_NAMESPACE_HTML       => 0x01,
  MyHTML_NAMESPACE_MATHML     => 0x02,
  MyHTML_NAMESPACE_SVG        => 0x03,
  MyHTML_NAMESPACE_XLINK      => 0x04,
  MyHTML_NAMESPACE_XML        => 0x05,
  MyHTML_NAMESPACE_XMLNS      => 0x06,
  MyHTML_NAMESPACE_LAST_ENTRY => 0x07
);

class MCharAsync is repr('CPointer') {}
class MyHTMLStatus is repr('CPointer') {}

class MyHTMLTag is repr('CStruct') {}

class MyHTMLString is repr('CStruct') {
  has Str $.data;
  has size_t $.size;
  has size_t $.length;

  has Pointer $.mchar;
  has size_t $.node_idx;
}

class MyHTMLCollection is repr('CStruct') {
  has CArray[Pointer] $.list;
  has size_t $.size;
  has size_t $.length;
}

=head2 API

=head3 MyHTML

class MyHTML is repr('CPointer') is export {

  class MyHTMLTree is repr('CPointer') {}

  #| Create a MyHTML structure
  #|
  #| @return myhtml_t* if successful, otherwise an NULL value.
  sub myhtml_create() is native(&lib) returns MyHTML is export {*}

  #| Allocating and Initialization resources for a MyHTML structure
  #|
  #| @param[in] myhtml_t*
  #| @param[in] work options, how many threads will be.
  #| Default: MyHTML_OPTIONS_PARSE_MODE_SEPARATELY
  #|
  #| @param[in] thread count, it depends on the choice of work options
  #| Default: 1
  #|
  #| @param[in] queue size for a tokens. Dynamically increasing the specified number here. Default: 4096
  #|
  #| @return MyHTML_STATUS_OK if successful, otherwise an error status value.
  sub myhtml_init(MyHTML, int32, size_t, size_t) is native(&lib) returns int32 is export {*}

  method new(HTML::MyHTML::Options $opt, Int $threads, Int $queue) {
    my $p = myhtml_create();
    myhtml_init($p, $opt, $threads, $queue);
    return $p;
  }

  #| Clears queue and threads resources
  #|
  #| @param[in] myhtml_t*
  sub myhtml_clean(MyHTML) is native(&lib) is export {*}

  method clean { myhtml_clean(self) }

  #| Destroy of a MyHTML structure
  #|
  #| @param[in] myhtml_t*
  #| @return NULL if successful, otherwise an MyHTML structure.
  sub myhtml_destroy(MyHTML) is native(&lib) is export {*}

  method dispose { myhtml_destroy(self) }

  #| Parsing HTML
  #|
  #| @param[in] previously created structure myhtml_tree_t*
  #| @param[in] Input character encoding; Default: MyHTML_ENCODING_UTF_8 or MyHTML_ENCODING_DEFAULT or 0
  #| @param[in] HTML
  #| @param[in] HTML size
  #|
  #| All input character encoding decode to utf-8
  #|
  #| @return MyHTML_STATUS_OK if successful, otherwise an error status
  sub myhtml_parse(MyHTMLTree, int32, Str, size_t) is native(&lib) returns int32 is export {*}

  multi method parse($tree, Str $html, HTML::MyHTML::Encoding :$enc) {
    explicitly-manage($html);
    myhtml_parse($tree, $enc // 0, $html, $html.chars);
  }

  #| Parsing fragment of HTML
  #|
  #| @param[in] previously created structure myhtml_tree_t*
  #| @param[in] Input character encoding; Default: MyHTML_ENCODING_UTF_8 or MyHTML_ENCODING_DEFAULT or 0
  #| @param[in] HTML
  #| @param[in] HTML size
  #| @param[in] fragment base (root) tag id. Default: MyHTML_TAG_DIV if set 0
  #| @param[in] fragment NAMESPACE. Default: MyHTML_NAMESPACE_HTML if set 0
  #|
  #| All input character encoding decode to utf-8
  #|
  #| @return MyHTML_STATUS_OK if successful, otherwise an error status
  sub myhtml_parse_fragment(MyHTMLTree, int32, Str, size_t, int32, int32) is native(&lib) returns int32 is export {*}

  multi method parse($tree, Str $html, :$fragment,
                     HTML::MyHTML::Tag :$base, HTML::MyHTML::Namespace :$ns, HTML::MyHTML::Encoding :$enc) {
    explicitly-manage($html);
    myhtml_parse_fragment($tree, $enc // 0, $html, $html.chars, $base // 0, $ns // 0);
  }

  #| Parsing HTML in Single Mode.
  #| No matter what was said during initialization MyHTML
  #|
  #| @param[in] previously created structure myhtml_tree_t*
  #| @param[in] Input character encoding; Default: MyHTML_ENCODING_UTF_8 or MyHTML_ENCODING_DEFAULT or 0
  #| @param[in] HTML
  #| @param[in] HTML size
  #|
  #| All input character encoding decode to utf-8
  #|
  #| @return MyHTML_STATUS_OK if successful, otherwise an error status
  sub myhtml_parse_single(MyHTMLTree, int32, Str, size_t) is native(&lib) returns int32 is export {*}

  multi method parse($tree, Str $html, :$single, HTML::MyHTML::Encoding :$enc) {
    explicitly-manage($html);
    myhtml_parse_single($tree, $enc // 0, $html, $html.chars);
  }

  #| Parsing fragment of HTML in Single Mode.
  #| No matter what was said during initialization MyHTML
  #|
  #| @param[in] previously created structure myhtml_tree_t*
  #| @param[in] Input character encoding; Default: MyHTML_ENCODING_UTF_8 or MyHTML_ENCODING_DEFAULT or 0
  #| @param[in] HTML
  #| @param[in] HTML size
  #| @param[in] fragment base (root) tag id. Default: MyHTML_TAG_DIV if set 0
  #| @param[in] fragment NAMESPACE. Default: MyHTML_NAMESPACE_HTML if set 0
  #|
  #| All input character encoding decode to utf-8
  #|
  #| @return MyHTML_STATUS_OK if successful, otherwise an error status
  sub myhtml_parse_fragment_single(MyHTMLTree, int32, Str, size_t, int32, int32) is native(&lib) returns int32 is export {*}

  multi method parse($tree, Str $html, :$fragment, :$single,
                     HTML::MyHTML::Tag :$base, HTML::MyHTML::Namespace :$ns, HTML::MyHTML::Encoding :$enc) {
    explicitly-manage($html);
    myhtml_parse_fragment_single($tree, $enc // 0, $html, $html.chars, $base // 0, $ns // 0);
  }

  #| Parsing HTML chunk. For end parsing call myhtml_parse_chunk_end function
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] HTML
  #| @param[in] HTML size
  #|
  #| @return MyHTML_STATUS_OK if successful, otherwise an error status
  sub myhtml_parse_chunk(MyHTMLTree, Str, size_t) is native(&lib) returns int32 is export {*}

  multi method parse($tree, Str $html, :$chunk) {
    explicitly-manage($html);
    myhtml_parse_chunk($tree, $html, $html.chars);
  }

  #| Parsing chunk of fragment HTML. For end parsing call myhtml_parse_chunk_end function
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] HTML
  #| @param[in] HTML size
  #| @param[in] fragment base (root) tag id. Default: MyHTML_TAG_DIV if set 0
  #| @param[in] fragment NAMESPACE. Default: MyHTML_NAMESPACE_HTML if set 0
  #|
  #| @return MyHTML_STATUS_OK if successful, otherwise an error status
  sub myhtml_parse_chunk_fragment(MyHTMLTree, Str, size_t, int32, int32) is native(&lib) returns int32 is export {*}

  multi method parse($tree, Str $html, :$fragment, :$chunk,
                     HTML::MyHTML::Tag :$base, HTML::MyHTML::Namespace :$ns) {
    explicitly-manage($html);
    myhtml_parse_chunk_fragment($tree, $html, $html.chars, $base // 0, $ns // 0);
  }

  #| Parsing HTML chunk in Single Mode.
  #| No matter what was said during initialization MyHTML
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] HTML
  #| @param[in] HTML size
  #|
  #| @return MyHTML_STATUS_OK if successful, otherwise an error status
  sub myhtml_parse_chunk_single(MyHTMLTree, Str, size_t) is native(&lib) returns int32 is export {*}

  multi method parse($tree, Str $html, :$chunk, :$single) {
    explicitly-manage($html);
    myhtml_parse_chunk_single($tree, $html, $html.chars);
  }

  #| Parsing chunk of fragment of HTML in Single Mode.
  #| No matter what was said during initialization MyHTML
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] HTML
  #| @param[in] HTML size
  #| @param[in] fragment base (root) tag id. Default: MyHTML_TAG_DIV if set 0
  #| @param[in] fragment NAMESPACE. Default: MyHTML_NAMESPACE_HTML if set 0
  #|
  #| @return MyHTML_STATUS_OK if successful, otherwise an error status
  sub myhtml_parse_chunk_fragment_single(MyHTMLTree, Str, size_t, int32, int32) is native(&lib) returns int32 is export {*}

  multi method parse($tree, Str $html, :$fragment, :$chunk, :$single,
                     HTML::MyHTML::Tag :$base, HTML::MyHTML::Namespace :$ns) {
    explicitly-manage($html);
    myhtml_parse_chunk_fragment_single($tree, $html, $html.chars, $base // 0, $ns // 0);
  }

  #| End of parsing HTML chunks
  #|
  #| @param[in] myhtml_tree_t*
  #|
  #| @return MyHTML_STATUS_OK if successful, otherwise an error status
  sub myhtml_parse_chunk_end(MyHTMLTree) is native(&lib) returns int32 is export {*}

  method chunk-end(MyHTMLTree $tree) { myhtml_parse_chunk_end($tree) }
}

=head3 Tree

class MyHTMLTree is repr('CPointer') is export {

  class MyHTMLTreeNode is repr('CPointer') {}
  class MyHTMLTag is repr('CPointer') {}
  class MyHTMLTagIndex is repr('CPointer') {}
  class FILE is repr('CPointer') {}

  #| Create a MyHTML_TREE structure
  #|
  #| @return myhtml_tree_t* if successful, otherwise an NULL value.
  sub myhtml_tree_create() is native(&lib) returns MyHTMLTree {*}

  #| Allocating and Initialization resources for a MyHTML_TREE structure
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] workmyhtml_t*
  #|
  #| @return MyHTML_STATUS_OK if successful, otherwise an error status
  sub myhtml_tree_init(MyHTMLTree, MyHTML) is native(&lib) returns int32 {*}

  method new(MyHTML $html) {
    my $p = myhtml_tree_create();
    myhtml_tree_init($p, $html);
    return $p;
  }

  #| Clears resources before new parsing
  #|
  #| @param[in] myhtml_tree_t*
  sub myhtml_tree_clean(MyHTMLTree) is native(&lib) {*}

  method clean { myhtml_tree_clean(self) }

  #| Add child node to node. If children already exists it will be added to the last
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] myhtml_tree_node_t* The node to which we add child node
  #| @param[in] myhtml_tree_node_t* The node which adds
  sub myhtml_tree_node_add_child(MyHTMLTree, MyHTMLTreeNode, MyHTMLTreeNode) is native(&lib) {*}

  #| Add a node immediately before the existing node
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] myhtml_tree_node_t* add for this node
  #| @param[in] myhtml_tree_node_t* add this node
  sub myhtml_tree_node_insert_before(MyHTMLTree, MyHTMLTreeNode, MyHTMLTreeNode) is native(&lib) {*}

  #| Add a node immediately after the existing node
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] myhtml_tree_node_t* add for this node
  #| @param[in] myhtml_tree_node_t* add this node
  sub myhtml_tree_node_insert_after(MyHTMLTree, MyHTMLTreeNode, MyHTMLTreeNode) is native(&lib) {*}

  multi method add(MyHTMLTreeNode $loc, MyHTMLTreeNode $node) { myhtml_tree_node_add_child(self, $loc, $node) }
  multi method add(MyHTMLTreeNode $loc, MyHTMLTreeNode $node, :$before) { myhtml_tree_node_insert_before(self, $loc, $node) }
  multi method add(MyHTMLTreeNode $loc, MyHTMLTreeNode $node, :$after) { myhtml_tree_node_insert_after(self, $loc, $node) }

  #| Destroy of a MyHTML_TREE structure
  #|
  #| @param[in] myhtml_tree_t*
  #|
  #| @return NULL if successful, otherwise an MyHTML_TREE structure
  sub myhtml_tree_destroy(MyHTMLTree) is native(&lib) returns MyHTMLTree {*}

  method dispose { myhtml_tree_destroy(self) }

  #| Get myhtml_t* from a myhtml_tree_t*
  #|
  #| @param[in] myhtml_tree_t*
  #|
  #| @return myhtml_t* if exists, otherwise a NULL value
  sub myhtml_tree_get_myhtml(MyHTMLTree) is native(&lib) returns MyHTML {*}

  method myhtml { myhtml_tree_get_myhtml(self) }

  #| Get myhtml_tag_t* from a myhtml_tree_t*
  #|
  #| @param[in] myhtml_tree_t*
  #|
  #| @return myhtml_tag_t* if exists, otherwise a NULL value
  sub myhtml_tree_get_tag(MyHTMLTree) is native(&lib) returns MyHTMLTag {*}

  method tag { myhtml_tree_get_tag(self) }

  #| Get myhtml_tag_index_t* from a myhtml_tree_t*
  #|
  #| @param[in] myhtml_tree_t*
  #|
  #| @return myhtml_tag_index_t* if exists, otherwise a NULL value
  sub myhtml_tree_get_tag_index(MyHTMLTree) is native(&lib) returns MyHTMLTagIndex {*}

  method tag-index { myhtml_tree_get_tag_index(self) }

  #| Get Tree Document (Root of Tree)
  #|
  #| @param[in] myhtml_tree_t*
  #|
  #| @return myhtml_tree_node_t* if successful, otherwise a NULL value
  sub myhtml_tree_get_document(MyHTMLTree) is native(&lib) returns MyHTMLTreeNode {*}

  method document { myhtml_tree_get_document(self) }

  #| Get node HTML (Document -> HTML, Root of HTML Document)
  #|
  #| @param[in] myhtml_tree_t*
  #|
  #| @return myhtml_tree_node_t* if successful, otherwise a NULL value
  sub myhtml_tree_get_node_html(MyHTMLTree) is native(&lib) returns MyHTMLTreeNode {*}

  method node-html { myhtml_tree_get_node_html(self) }

  #| Get node BODY (Document -> HTML -> BODY)
  #|
  #| @param[in] myhtml_tree_t*
  #|
  #| @return myhtml_tree_node_t* if successful, otherwise a NULL value
  sub myhtml_tree_get_node_body(MyHTMLTree) is native(&lib) returns MyHTMLTreeNode {*}

  method node-body { myhtml_tree_get_node_body(self) }

  #| Get mchar_async_t object
  #|
  #| @param[in] myhtml_tree_t*
  #|
  #| @return mchar_async_t* if exists, otherwise a NULL value
  sub myhtml_tree_get_mchar(MyHTMLTree) is native(&lib) returns MCharAsync {*}

  method mchar { myhtml_tree_get_mchar(self) }

  #| Get node_id from main thread for mchar_async_t object
  #|
  #| @param[in] myhtml_tree_t*
  #|
  #| @return size_t, node id
  sub myhtml_tree_get_mchar_node_id(MyHTMLTree) is native(&lib) returns size_t {*}

  method mchar-node-id { myhtml_tree_get_mchar_node_id(self) }

  #| Print tree of a node. Print including current node
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] myhtml_tree_node_t*
  #| @param[in] file handle, for example use stdout
  #| @param[in] tab (\t) increment for pretty print, set 0
  sub myhtml_tree_print_by_node(MyHTMLTree, MyHTMLTreeNode, FILE, size_t) is native(&lib) {*}

  #| Print tree of a node. Print excluding current node
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] myhtml_tree_node_t*
  #| @param[in] file handle, for example use stdout
  #| @param[in] tab (\t) increment for pretty print, set 0
  sub myhtml_tree_print_node_childs(MyHTMLTree, MyHTMLTreeNode, FILE, size_t) is native(&lib) {*}

  #| Print a node
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] myhtml_tree_node_t*
  #| @param[in] file handle, for example use stdout
  sub myhtml_tree_print_node(MyHTMLTree, MyHTMLTreeNode, FILE) is native(&lib) {*}

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
  sub myhtml_node_first(MyHTMLTree) is native(&lib) returns MyHTMLTreeNode {*}

  method root { myhtml_node_first(self) }

  #| Get nodes by tag id
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] myhtml_collection_t*, creates new collection if NULL
  #| @param[in] tag id
  #| @param[out] status of this operation
  #|
  #| @return myhtml_collection_t* if successful, otherwise an NULL value
  sub myhtml_get_nodes_by_tag_id(MyHTMLTree, MyHTMLCollection, int32, MyHTMLStatus) is native(&lib) returns MyHTMLCollection {*}

  multi method get-nodes(MyHTMLCollection $collection, HTML::MyHTML::Tag $tag-id) {
    my Int $status;
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
  sub myhtml_get_nodes_by_name(MyHTMLTree, MyHTMLCollection, Str, size_t, MyHTMLStatus) is native(&lib) returns MyHTMLCollection {*}

  multi method get-nodes(MyHTMLCollection $collection, Str $tag-name) {
    explicitly-manage($tag-name);
    my Int $status;
    my $col = myhtml_get_nodes_by_name(self, $collection, $tag-name, $tag-name.chars, $status);
    $status == 0 ?? return $col !! return $status;
  }

}

=head3 Node

class MyHTMLTreeNode is repr('CPointer') {
  has $!tree;

  my class MyHTMLAttr is repr('CPointer') {}

  #| Get next sibling node
  #|
  #| @param[in] myhtml_tree_node_t*
  #|
  #| @return myhtml_tree_node_t* if exists, otherwise an NULL value
  sub myhtml_node_next(MyHTMLTreeNode) is native(&lib) returns MyHTMLTreeNode {*}

  multi method sibling(:$next) { myhtml_node_next(self) }

  #| Get previous sibling node
  #|
  #| @param[in] myhtml_tree_node_t*
  #|
  #| @return myhtml_tree_node_t* if exists, otherwise an NULL value
  sub myhtml_node_prev(MyHTMLTreeNode) is native(&lib) returns MyHTMLTreeNode {*}

  multi method sibling(:$prev) { myhtml_node_prev(self) }

  #| Get parent node
  #|
  #| @param[in] myhtml_tree_node_t*
  #|
  #| @return myhtml_tree_node_t* if exists, otherwise an NULL value
  sub myhtml_node_parent(MyHTMLTreeNode) is native(&lib) returns MyHTMLTreeNode {*}

  method parent { myhtml_node_parent(self) }

  #| Get child (first child) of node
  #|
  #| @param[in] myhtml_tree_node_t*
  #|
  #| @return myhtml_tree_node_t* if exists, otherwise an NULL value
  sub myhtml_node_child(MyHTMLTreeNode) is native(&lib) returns MyHTMLTreeNode {*}

  multi method child(:$first) { myhtml_node_child(self) }

  #| Get last child of node
  #|
  #| @param[in] myhtml_tree_node_t*
  #|
  #| @return myhtml_tree_node_t* if exists, otherwise an NULL value
  sub myhtml_node_last_child(MyHTMLTreeNode) is native(&lib) returns MyHTMLTreeNode {*}

  multi method child(:$last) { myhtml_node_last_child(self) }

  #| Create new node
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] tag id, see enum myhtml_tags
  #| @param[in] enum myhtml_namespace
  #|
  #| @return myhtml_tree_node_t* if successful, otherwise a NULL value
  sub myhtml_node_create(MyHTMLTree, int32, int32) is native(&lib) returns MyHTMLTreeNode {*}

  method new(MyHTMLTree $tree, HTML::MyHTML::Tag $tag, HTML::MyHTML::Namespace $ns) {
    $!tree = $tree;
    myhtml_node_create($tree, $tag, $ns);
  }

  #| Release allocated resources
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] myhtml_tree_node_t*
  sub myhtml_node_free(MyHTMLTree, MyHTMLTreeNode) is native(&lib) {*}

  method free { myhtml_node_free($!tree, self) }

  #| Remove node of tree
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] myhtml_tree_node_t*
  #|
  #| @return myhtml_tree_node_t* if successful, otherwise a NULL value
  sub myhtml_node_remove(MyHTMLTree, MyHTMLTreeNode) is native(&lib) returns MyHTMLTreeNode {*}

  method remove { myhtml_node_remove($!tree, self) }

  #| Remove node of tree and release allocated resources
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] myhtml_tree_node_t*
  sub myhtml_node_delete(MyHTMLTree, MyHTMLTreeNode) is native(&lib) {*}

  multi method delete() { myhtml_node_delete($!tree, self) }

  #| Remove nodes of tree recursively and release allocated resources
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] myhtml_tree_node_t*
  sub myhtml_node_delete_recursive(MyHTMLTree, MyHTMLTreeNode) is native(&lib) {*}

  multi method delete(:$recursive) { myhtml_node_delete_recursive($!tree, self) }

  #| The appropriate place for inserting a node. Insertion with validation.
  #| If try insert <a> node to <table> node, then <a> node inserted before <table> node
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] target node
  #| @param[in] insertion node
  #|
  #| @return insertion node if successful, otherwise a NULL value
  sub myhtml_node_insert_to_appropriate_place(MyHTMLTree, MyHTMLTreeNode, MyHTMLTreeNode) is native(&lib) returns MyHTMLTreeNode {*}

  multi method insert(MyHTMLTreeNode $loc) { myhtml_node_insert_to_appropriate_place($!tree, self, $loc) }

  #| Append to target node as last child. Insertion without validation.
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] target node
  #| @param[in] insertion node
  #|
  #| @return insertion node if successful, otherwise a NULL value
  sub myhtml_node_insert_append_child(MyHTMLTree, MyHTMLTreeNode, MyHTMLTreeNode) is native(&lib) returns MyHTMLTreeNode {*}

  multi method insert(MyHTMLTreeNode $loc, :$append) { myhtml_node_insert_append_child($!tree, self, $loc) }

  #| Append sibling node after target node. Insertion without validation.
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] target node
  #| @param[in] insertion node
  #|
  #| @return insertion node if successful, otherwise a NULL value
  sub myhtml_node_insert_after(MyHTMLTree, MyHTMLTreeNode, MyHTMLTreeNode) is native(&lib) returns MyHTMLTreeNode {*}

  multi method insert(MyHTMLTreeNode $loc, :$after) { myhtml_node_insert_after($!tree, self, $loc) }

  #| Append sibling node before target node. Insertion without validation.
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] target node
  #| @param[in] insertion node
  #|
  #| @return insertion node if successful, otherwise a NULL value
  sub myhtml_node_insert_before(MyHTMLTree, MyHTMLTreeNode, MyHTMLTreeNode) is native(&lib) returns MyHTMLTreeNode {*}

  multi method insert(MyHTMLTreeNode $loc, :$before) { myhtml_node_insert_before($!tree, self, $loc) }

  #| Add text for a node with convert character encoding.
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] target node
  #| @param[in] text
  #| @param[in] text length
  #| @param[in] character encoding
  #|
  #| @return myhtml_string_t* if successful, otherwise a NULL value
  sub myhtml_node_text_set(MyHTMLTree, MyHTMLTreeNode, Str, size_t, int32) is native(&lib) returns MyHTMLString {*}

  multi method text(Str $text, :$enc) {
    explicitly-manage($text);
    myhtml_node_text_set($!tree, self, $text, $text.chars, $enc // MyHTML_ENCODING_UTF_8);
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
  sub myhtml_node_text_set_with_charef(MyHTMLTree, MyHTMLTreeNode, Str, size_t, int32) is native(&lib) returns MyHTMLString {*}

  multi method text(Str $text, :$charef!, :$enc) {
    explicitly-manage($text);
    myhtml_node_text_set_with_charef($!tree, self, $text, $text.chars, $enc // MyHTML_ENCODING_UTF_8);
  }

  #| Get node namespace
  #|
  #| @param[in] myhtml_tree_node_t*
  #|
  #| @return enum myhtml_namespace
  sub myhtml_node_namespace(MyHTMLTreeNode) is native(&lib) returns int32 {*}

  method namespace { myhtml_node_namespace(self) }

  #| Get node tag id
  #|
  #| @param[in] myhtml_tree_node_t*
  #|
  #| @return myhtml_tag_id_t
  sub myhtml_node_tag_id(MyHTMLTreeNode) is native(&lib) returns int32 {*}

  method tag-id { myhtml_node_tag_id(self) }

  #| Get tag name by tag id
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] tag id
  #| @param[out] optional, name length
  #|
  #| @return const char* if exists, otherwise a NULL value
  sub myhtml_tag_name_by_id(MyHTMLTree, int32) is native(&lib) returns Str {*}

  method tag-name-by-id(HTML::MyHTML::Tag $tag-id) { myhtml_tag_name_by_id($!tree, $tag-id) }

  #| Get tag id by name
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] tag name
  #| @param[in] tag name length
  #|
  #| @return tag id
  sub myhtml_tag_id_by_name(MyHTMLTree, Str, size_t) is native(&lib) returns int32 {*}

  method tag-id-by-name(Str $name) {
    explicitly-manage($name);
    myhtml_tag_id_by_name($!tree, $name, $name.chars);
  }

  #| Node has self-closing flag?
  #|
  #| @param[in] myhtml_tree_node_t*
  #|
  #| @return true or false (1 or 0)
  sub myhtml_node_is_close_self(MyHTMLTreeNode) is native(&lib) returns bool {*}

  method is-self-closing { myhtml_node_is_close_self(self) }

  #| Get first attribute of a node
  #|
  #| @param[in] myhtml_tree_node_t*
  #|
  #| @return myhtml_tree_attr_t* if exists, otherwise an NULL value
  sub myhtml_node_attribute_first(MyHTMLTreeNode) is native(&lib) returns MyHTMLAttr {*}

  multi method attribute(:$first) { myhtml_node_attribute_first(self) }

  #| Get last attribute of a node
  #|
  #| @param[in] myhtml_tree_node_t*
  #|
  #| @return myhtml_tree_attr_t* if exists, otherwise an NULL value
  sub myhtml_node_attribute_last(MyHTMLTreeNode) is native(&lib) returns MyHTMLAttr {*}

  multi method attribute(:$last) { myhtml_node_attribute_last(self) }

  #| Get text of a node. Only for a MyHTML_TAG__TEXT or MyHTML_TAG__COMMENT tags
  #|
  #| @param[in] myhtml_tree_node_t*
  #| @param[out] optional, text length
  #|
  #| @return const char* if exists, otherwise an NULL value
  sub myhtml_node_text(MyHTMLTreeNode) is native(&lib) returns Str {*}

  multi method text() { myhtml_node_text(self) }

  #| Get myhtml_string_t object by Tree node
  #|
  #| @param[in] myhtml_tree_node_t*
  #|
  #| @return myhtml_string_t* if exists, otherwise an NULL value
  sub myhtml_node_string(MyHTMLTreeNode) is native(&lib) returns MyHTMLString {*}

  method Str() { myhtml_node_string(self) }

}

=head3 Attribute

class MyHTMLAttr is repr('CPointer') {

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
  sub myhtml_attribute_by_key(MyHTMLTreeNode, Str, size_t) is native(&lib) returns Str {*}

  method by-key(MyHTMLTreeNode $node, Str $name) {
    explicitly-manage($name);
    myhtml_attribute_by_key($node, $name, $name.chars);
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
  sub myhtml_attribute_add(MyHTMLTree, MyHTMLTreeNode, Str, size_t, Str, size_t, int32) is native(&lib) returns MyHTMLAttr {*}

  method add($tree, $node, Str $name, Str $value, :$enc) {
    explicitly-manage($name);
    explicitly-manage($value);
    myhtml_attribute_add($tree, $node, $name, $name.chars, $value, $value.chars, $enc // 0)
  }

  #| Remove attribute reference. Do not release the resources
  #|
  #| @param[in] myhtml_tree_node_t*
  #| @param[in] myhtml_tree_attr_t*
  #|
  #| @return myhtml_tree_attr_t* if successful, otherwise a NULL value
  sub myhtml_attribute_remove(MyHTMLTreeNode, MyHTMLAttr) is native(&lib) returns MyHTMLAttr {*}

  multi method remove(MyHTMLTreeNode $node, MyHTMLAttr $attr) { myhtml_attribute_remove($node, $attr) }

  #| Remove attribute by key reference. Do not release the resources
  #|
  #| @param[in] myhtml_tree_node_t*
  #| @param[in] attr key name
  #| @param[in] attr key name length
  #|
  #| @return myhtml_tree_attr_t* if successful, otherwise a NULL value
  sub myhtml_attribute_remove_by_key(MyHTMLTreeNode, Str, size_t) is native(&lib) returns MyHTMLAttr {*}

  multi method remove(MyHTMLTreeNode $node, Str $name) { myhtml_attribute_remove_by_key($node, $name, $name.chars) }

  #| Remove attribute and release allocated resources
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] myhtml_tree_node_t*
  #| @param[in] myhtml_tree_attr_t*
  sub myhtml_attribute_delete(MyHTMLTree, MyHTMLTreeNode, MyHTMLAttr) is native(&lib) {*}

  method delete(MyHTMLTree $tree, MyHTMLTreeNode $node, MyHTMLAttr $attr) { myhtml_attribute_delete($tree, $node, $attr) }

  #| Release allocated resources
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] myhtml_tree_attr_t*
  sub myhtml_attribute_free(MyHTMLTree, MyHTMLAttr) is native(&lib) {*}

  method free(MyHTMLTree $tree, MyHTMLAttr $attr) { myhtml_attribute_free($tree, $attr) }

}

=head3 TagIndex

class MyHTMLTagIndex is repr('CPointer') {
  has $!tag;

  my class MyHTMLTagIndexEntry is repr('CStruct') {}
  my class MyHTMLTagIndexNode is repr('CStruct') {}

  #| Create tag index structure
  #|
  #| @param[in] myhtml_tag_t*
  #|
  #| @return myhtml_tag_index_t* if successful, otherwise a NULL value
  sub myhtml_tag_index_create(MyHTMLTag) is native(&lib) returns MyHTMLTagIndex {*}

  #| Allocating and Initialization resources for a tag index structure
  #|
  #| @param[in] myhtml_tag_t*
  #| @param[in] myhtml_tag_index_t*
  #|
  #| @return MyHTML_STATUS_OK if successful, otherwise an error status.
  sub myhtml_tag_index_init(MyHTMLTag, MyHTMLTagIndex) is native(&lib) returns MyHTMLStatus {*}

  method new(MyHTMLTag $tag) {
    $!tag = $tag;
    my $tag-index = myhtml_tag_index_create($tag);
    my $status = myhtml_tag_index_init($tag, $tag-index);
    $status == 0 ?? $tag-index !! $status;
  }

  #| Clears tag index
  #|
  #| @param[in] myhtml_tag_t*
  #| @param[in] myhtml_tag_index_t*
  sub myhtml_tag_index_clean(MyHTMLTag, MyHTMLTagIndex) is native(&lib) {*}

  method clean { myhtml_tag_index_clean($!tag, self) }

  #| Free allocated resources
  #|
  #| @param[in] myhtml_tag_t*
  #| @param[in] myhtml_tag_index_t*
  #|
  #| @return NULL if successful, otherwise an myhtml_tag_index_t* structure
  sub myhtml_tag_index_destroy(MyHTMLTag, MyHTMLTagIndex) is native(&lib) returns MyHTMLTagIndex {*}

  method destroy { myhtml_tag_index_destroy($!tag, self) }

  #| Adds myhtml_tree_node_t* to tag index
  #|
  #| @param[in] myhtml_tag_t*
  #| @param[in] myhtml_tag_index_t*
  #| @param[in] myhtml_tree_node_t*
  #|
  #| @return MyHTML_STATUS_OK if successful, otherwise an error status.
  sub myhtml_tag_index_add(MyHTMLTag, MyHTMLTagIndex, MyHTMLTreeNode) is native(&lib) returns MyHTMLStatus {*}

  method add(MyHTMLTreeNode $node) { myhtml_tag_index_add($!tag, self, $node) }

  #| Get root tag index. Is the initial entry for a tag. It contains statistics and other items by tag
  #|
  #| @param[in] myhtml_tag_index_t*
  #| @param[in] myhtml_tag_id_t
  #|
  #| @return myhtml_tag_index_entry_t* if successful, otherwise a NULL value.
  sub myhtml_tag_index_entry(MyHTMLTagIndex, int32) is native(&lib) returns MyHTMLTagIndexEntry {*}

  method entry(HTML::MyHTML::Tag $tag-id) { myhtml_tag_index_entry(self, $tag-id) }

  #| Get first index node for tag
  #|
  #| @param[in] myhtml_tag_index_t*
  #| @param[in] myhtml_tag_id_t
  #|
  #| @return myhtml_tag_index_node_t* if exists, otherwise a NULL value.
  sub myhtml_tag_index_first(MyHTMLTagIndex, int32) is native(&lib) returns MyHTMLTagIndexNode {*}

  method first-node(HTML::MyHTML::Tag $tag-id) { myhtml_tag_index_first(self, $tag-id) }

  #| Get last index node for tag
  #|
  #| @param[in] myhtml_tag_index_t*
  #| @param[in] myhtml_tag_id_t
  #|
  #| @return myhtml_tag_index_node_t* if exists, otherwise a NULL value.
  sub myhtml_tag_index_last(MyHTMLTagIndex, int32) is native(&lib) returns MyHTMLTagIndexNode {*}

  method last-node(HTML::MyHTML::Tag $tag-id) { myhtml_tag_index_last(self, $tag-id) }

  #| Get next index node for tag, by index node
  #|
  #| @param[in] myhtml_tag_index_node_t*
  #|
  #| @return myhtml_tag_index_node_t* if exists, otherwise a NULL value.
  sub myhtml_tag_index_next(MyHTMLTagIndexNode) is native(&lib) returns MyHTMLTagIndexNode {*}

  method next(MyHTMLTagIndexNode $node) { myhtml_tag_index_next($node) }

  #| Get previous index node for tag, by index node
  #|
  #| @param[in] myhtml_tag_index_node_t*
  #|
  #| @return myhtml_tag_index_node_t* if exists, otherwise a NULL value.
  sub myhtml_tag_index_prev(MyHTMLTagIndexNode) is native(&lib) returns MyHTMLTagIndexNode {*}

  method prev(MyHTMLTagIndexNode $node) { myhtml_tag_index_prev($node) }

  #| Get myhtml_tree_node_t* by myhtml_tag_index_node_t*
  #|
  #| @param[in] myhtml_tag_index_node_t*
  #|
  #| @return myhtml_tree_node_t* if exists, otherwise a NULL value.
  sub myhtml_tag_index_tree_node(MyHTMLTagIndexNode) is native(&lib) returns MyHTMLTreeNode {*}

  method tree-node(MyHTMLTagIndexNode $node) { myhtml_tag_index_tree_node($node) }

  #| Get count of elements in index by tag id
  #|
  #| @param[in] myhtml_tag_index_t*
  #| @param[in] tag id
  #|
  #| @return count of elements
  sub myhtml_tag_index_entry_count(MyHTMLTagIndex, int32) is native(&lib) returns MyHTMLTreeNode {*}

  method entry-count(HTML::MyHTML::Tag $tag-id) { myhtml_tag_index_entry_count(self, $tag-id) }

}
