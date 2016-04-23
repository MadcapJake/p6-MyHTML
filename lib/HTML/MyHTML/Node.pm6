unit class HTML::MyHTML::Node;

use HTML::MyHTML::Raw;

has $.raw;
has Tree $!tree;

method create(:$tree, :$tag, :$ns) {
  self.bless(:raw(myhtml_node_create($tree, $tag, $ns)) :$tree)
}

method next { myhtml_node_next($!raw) }

method prev { myhtml_node_prev($!raw) }

method parent { myhtml_node_parent($!raw) }

method child(:$last) {
  $last ?? myhtml_node_last_child($!raw) !! myhtml_node_child($!raw)
}

method free { myhtml_node_free($!tree, $!raw) }

method remove { myhtml_node_remove($!raw) }

method delete(Bool :recursive(:rec(:$r))) {
  !$r
    ?? myhtml_node_delete($!tree, $!raw)
    !! myhtml_node_delete_recursive($!tree, $!raw);
}

method Str {;
  my $mystring = myhtml_node_string($!raw);
  say $mystring.data;
  say myhtml_string_data($mystring);
  say myhtml_string_length($mystring);
}
