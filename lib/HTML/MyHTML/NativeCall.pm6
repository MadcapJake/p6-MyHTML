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

  method new(MyHTMLOptions :$opt, int64 :$threads, int64 :$queue) {
    my MyHTML $p := myhtml_create();
    debug status myhtml_init($p, $opt, $threads // 1, $queue // 4096);
    return $p;
  }

  method clean { myhtml_clean(self) }



  method dispose { myhtml_destroy(self) }

  multi method parse(Str $html, :$tree, MyHTMLEncoding :$enc) {
    my CArray[uint8] $chs .= new: $html.encode.list;
    myhtml_parse($tree, $enc // 0, $chs, $chs.elems);
  }

  multi method parse(Str $html, :$tree, Bool :$fragment, MyHTMLTagType :$base, MyHTMLNamespace :$ns, MyHTMLEncoding :$enc) {
    my CArray[uint8] $chs .= new: $html.encode.list;
    myhtml_parse_fragment($tree, $enc // 0, $chs, $chs.elems, $base // 0, $ns // 0);
  }



  multi method parse(Str $html, :$tree, :$single, MyHTMLEncoding :$enc) {
    my CArray[uint] $chs .= new: $html.encode.list;
    myhtml_parse_single($tree, $enc // 0, $chs, $chs.elems);
  }



  multi method parse(Str $html, :$tree, :$fragment, :$single,
                     MyHTMLTagType :$base, MyHTMLNamespace :$ns, MyHTMLEncoding :$enc) {
    my CArray[uint] $chs = $html.encode.list;
    myhtml_parse_fragment_single($tree, $enc // 0, $chs, $chs.elems, $base // 0, $ns // 0);
  }



  multi method parse(Str $html, :$tree, :$chunk) {
    my CArray[uint] $chs .= new: $html.encode.list;
    myhtml_parse_chunk($tree, $chs, $chs.elems);
  }



  multi method parse(Str $html, :$tree, :$fragment, :$chunk,
                     MyHTMLTagType :$base, MyHTMLNamespace :$ns) {
    my CArray[uint] $chs = $html.encode.list;
    myhtml_parse_chunk_fragment($tree, $chs, $chs.elems, $base // 0, $ns // 0);
  }



  multi method parse(Str $html, :$tree, :$chunk, :$single) {
    my CArray[uint] $chs .= new: $html.encode.list;
    myhtml_parse_chunk_single($tree, $chs, $chs.elems);
  }



  multi method parse(Str $html, :$tree, :$fragment, :$chunk, :$single,
                     MyHTMLTagType :$base, MyHTMLNamespace :$ns) {
    my CArray[uint] $chs .= new: $html.encode.list;
    myhtml_parse_chunk_fragment_single($tree, $chs, $chs.elems, $base // 0, $ns // 0);
  }



  method chunk-end(:$tree) { myhtml_parse_chunk_end($tree) }
}
