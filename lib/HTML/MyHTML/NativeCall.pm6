#| The bare C API of MyHTML
unit module HTML::MyHTML::NativeCall;

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

use HTML::MyHTML::Encoding;
use HTML::MyHTML::Lib;
use HTML::MyHTML::Namespace;
use HTML::MyHTML::Status;
use HTML::MyHTML::String;
use HTML::MyHTML::Tag;
use HTML::MyHTML::Tree;

enum MyHTMLOptions is export (
  DEFAULT                 => 0x00,
  PARSE_MODE_SINGLE       => 0x01,
  PARSE_MODE_ALL_IN_ONE   => 0x02,
  PARSE_MODE_SEPARATELY   => 0x04,
  PARSE_MODE_WORKER_TREE  => 0x08,
  PARSE_MODE_WORKER_INDEX => 0x10,
  PARSE_MODE_TREE_INDEX   => 0x20
);

class MCharAsync is repr('CPointer') {}
# class MyHTMLStatus is repr('CPointer') {}

# class MyHTMLString is repr('CStruct') {
#   has Str $.data;
#   has size_t $.size;
#   has size_t $.length;
#
#   has Pointer $.mchar;
#   has size_t $.node_idx;
# }

=head2 MyHTML

class MyHTML is repr('CStruct') is export {

  has Pointer #`{mythread_t*}       $.thread;
  has Pointer #`{mcobject_async_t*} $.async_incoming_buf;
  has MCharAsync                    $.mchar; # for all
  has Pointer #`{mcobject_async_t*} $.tag_index;

  has Pointer #`{myhtml_tokenizer_state_f*} $.parse_state_func;
  has Pointer #`{myhtml_insertion_f*}       $.insertion_func;

  has int32 #`{enum myhtml_options}   $.opt;
  has Pointer #`{myhtml_tree_node_t*} $.marker;


  #| Create a MyHTML structure
  #|
  #| @return myhtml_t* if successful, otherwise an NULL value.
  sub myhtml_create() is native(&lib) returns MyHTML {*}

  #| Allocating and Initialization resources for a MyHTML structure
  #|
  #| @param[in] myhtml_t*
  #| @param[in] work options, how many threads will be.
  #| Default: MyHTML_OPTIONS_PARSE_MODE_SEPARATELY
  #|
  #| @param[in] thread count, it depends on the choice of work options
  #| Default: 1
  #|
  #| @param[in] queue size for a tokens. Dynamically increasing the
  #| specified number here. Default: 4096
  #|
  #| @return MyHTML_STATUS_OK if successful, otherwise an error status value.
  sub myhtml_init(MyHTML, int32, size_t, size_t)
      returns int32
      is native(&lib)
      { * }

  method new(MyHTMLOptions :$opt, int64 :$threads, int64 :$queue) {
    my MyHTML $p := myhtml_create();
    debug status myhtml_init($p, $opt, $threads // 1, $queue // 4096);
    return $p;
  }

  #| Clears queue and threads resources
  #|
  #| @param[in] myhtml_t*
  sub myhtml_clean(MyHTML) is native(&lib) { * }

  method clean { myhtml_clean(self) }

  #| Destroy of a MyHTML structure
  #|
  #| @param[in] myhtml_t*
  #| @return NULL if successful, otherwise an MyHTML structure.
  sub myhtml_destroy(MyHTML) is native(&lib) { * }

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
  sub myhtml_parse(Tree, int32, CArray[uint8], size_t)
      returns int32
      is native(&lib)
      { * }

  multi method parse(Str $html, :$tree, MyHTMLEncoding :$enc) {
    my CArray[uint8] $chs .= new: $html.encode.list;
    myhtml_parse($tree, $enc // 0, $chs, $chs.elems);
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
  sub myhtml_parse_fragment(Tree, int32, CArray[uint8], size_t, int32, int32)
      returns int32
      is native(&lib)
      { * }

  multi method parse(Str $html, :$tree, Bool :$fragment, MyHTMLTagType :$base, MyHTMLNamespace :$ns, MyHTMLEncoding :$enc) {
    my CArray[uint8] $chs .= new: $html.encode.list;
    myhtml_parse_fragment($tree, $enc // 0, $chs, $chs.elems, $base // 0, $ns // 0);
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
  sub myhtml_parse_single(Tree, int32, CArray[uint8], size_t)
      returns int32
      is native(&lib)
      { * }

  multi method parse(Str $html, :$tree, :$single, MyHTMLEncoding :$enc) {
    my CArray[uint] $chs .= new: $html.encode.list;
    myhtml_parse_single($tree, $enc // 0, $chs, $chs.elems);
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
  sub myhtml_parse_fragment_single(Tree, int32, CArray[uint8], size_t, int32, int32)
      returns int32
      is native(&lib)
      { * }

  multi method parse(Str $html, :$tree, :$fragment, :$single,
                     MyHTMLTagType :$base, MyHTMLNamespace :$ns, MyHTMLEncoding :$enc) {
    my CArray[uint] $chs = $html.encode.list;
    myhtml_parse_fragment_single($tree, $enc // 0, $chs, $chs.elems, $base // 0, $ns // 0);
  }

  #| Parsing HTML chunk. For end parsing call myhtml_parse_chunk_end function
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] HTML
  #| @param[in] HTML size
  #|
  #| @return MyHTML_STATUS_OK if successful, otherwise an error status
  sub myhtml_parse_chunk(Tree, CArray[uint8], size_t)
      returns int32
      is native(&lib)
      { * }

  multi method parse(Str $html, :$tree, :$chunk) {
    my CArray[uint] $chs .= new: $html.encode.list;
    myhtml_parse_chunk($tree, $chs, $chs.elems);
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
  sub myhtml_parse_chunk_fragment(Tree, CArray[uint8], size_t, int32, int32)
      returns int32
      is native(&lib)
      { * }

  multi method parse(Str $html, :$tree, :$fragment, :$chunk,
                     MyHTMLTagType :$base, MyHTMLNamespace :$ns) {
    my CArray[uint] $chs = $html.encode.list;
    myhtml_parse_chunk_fragment($tree, $chs, $chs.elems, $base // 0, $ns // 0);
  }

  #| Parsing HTML chunk in Single Mode.
  #| No matter what was said during initialization MyHTML
  #|
  #| @param[in] myhtml_tree_t*
  #| @param[in] HTML
  #| @param[in] HTML size
  #|
  #| @return MyHTML_STATUS_OK if successful, otherwise an error status
  sub myhtml_parse_chunk_single(Tree, CArray[uint8], size_t)
      returns int32
      is native(&lib)
      { * }

  multi method parse(Str $html, :$tree, :$chunk, :$single) {
    my CArray[uint] $chs .= new: $html.encode.list;
    myhtml_parse_chunk_single($tree, $chs, $chs.elems);
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
  sub myhtml_parse_chunk_fragment_single(Tree, CArray[uint8], size_t, int32, int32)
      returns int32
      is native(&lib)
      { * }

  multi method parse(Str $html, :$tree, :$fragment, :$chunk, :$single,
                     MyHTMLTagType :$base, MyHTMLNamespace :$ns) {
    my CArray[uint] $chs .= new: $html.encode.list;
    myhtml_parse_chunk_fragment_single($tree, $chs, $chs.elems, $base // 0, $ns // 0);
  }

  #| End of parsing HTML chunks
  #|
  #| @param[in] myhtml_tree_t*
  #|
  #| @return MyHTML_STATUS_OK if successful, otherwise an error status
  sub myhtml_parse_chunk_end(Tree) is native(&lib) returns int32 { * }

  method chunk-end(:$tree) { myhtml_parse_chunk_end($tree) }
}
