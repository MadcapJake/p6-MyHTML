unit module HTML::MyHTML;

use HTML::MyHTML::NativeCall;
use HTML::MyHTML::Tree;

class HTML::MyHTML is export {

  has MyHTML $!myhtml;
  has Tree $.tree is rw;

  submethod BUILD {
    $!myhtml = MyHTML.new :opt(PARSE_MODE_SEPARATELY);
    $!tree = Tree.new: $!myhtml;
  }

  method clean { $!tree.clean; $!myhtml.clean }
  method dispose { $!tree.dispose; $!myhtml.dispose }
  multi method parse($html, :$enc) {
    $!myhtml.parse: $html, :$!tree, :$enc
  }
  multi method parse($html, :$fragment, :$base, :$ns, :$enc) {
    $!myhtml.parse: $html, :$!tree, :$fragment, :$base, :$ns, :$enc
  }
  multi method parse($html, :$single, :$enc) {
    $!myhtml.parse: $html, :$!tree, :$single, :$enc
  }
  multi method parse($html, :$fragment, :$single, :$base, :$ns, :$enc) {
    $!myhtml.parse: $html, :$!tree, :$fragment, :$single, :$base, :$ns, :$enc
  }
  multi method parse($html, :$chunk) {
    $!myhtml.parse: $html, :$!tree, :$chunk
  }
  multi method parse($html, :$chunk, :$fragment, :$base, :$ns, :$enc) {
    $!myhtml.parse: $html, :$!tree, :$chunk, :$fragment, :$base, :$ns, :$enc
  }
  multi method parse($html, :$chunk, :$single) {
    $!myhtml.parse: $html, :$!tree, :$chunk, :$single
  }
  method chunk-end { $!myhtml.chunk-end($!tree) }
}
