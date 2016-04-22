unit class HTML::MyHTML::Tree;

use HTML::MyHTML::Raw;

use HTML::MyHTML::Collection;
use HTML::MyHTML::Node;
use HTML::MyHTML::Tag;

has Tree $.raw;

submethod BUILD(:$myhtml) {
  $!raw = myhtml_tree_create();
  myhtml_tree_init($!raw, $myhtml);
}

method clean { myhtml_tree_clean($!raw) }

method dispose { myhtml_tree_destroy($!raw) }

method myhtml { myhtml_tree_get_myhtml($!raw) }

method tag { myhtml_tree_get_tag($!raw) }

method tag-index { myhtml_tree_get_tag_index($!raw) }

method document { myhtml_tree_get_document($!raw) }

method node-html { myhtml_tree_get_node_html($!raw) }

method node-body { myhtml_tree_get_node_body($!raw) }

method mchar(:$node-id) {
  with $node-id { myhtml_tree_get_mchar_node_id($!raw) }
  else { myhtml_tree_get_mchar($!raw) }
}

multi method print($node, Str :$file) {
  myhtml_tree_print_node(
    $!raw,
    ($node ~~ HTML::MyHTML::Node) ?? $node.raw !! $node,
    $file.defined && $file.IO.e ?? FILE.path($file) !! FILE.fd(1)
  );
}
multi method print(
  $node,
  Bool :all(:$a)! where $a.so,
  Str :$file,
  Int :increment(:$inc) = 0
) {
  myhtml_tree_print_by_node(
    $!raw,
    $node,
    $file.defined && $file.IO.e ?? FILE.path($file) !! FILE.fd(1),
    $inc
  );
}
multi method print(
  $node,
  :all(:$a)! where not $a.so,
  Str :$file,
  Int :increment(:$inc) = 0
) {
  myhtml_tree_print_node_childs(
    $!raw,
    $node,
    $file.defined && $file.IO.e ?? FILE.path($file) !! FILE.fd(1),
    $inc
  );
}

method root { myhtml_node_first($!raw) }

method nodes(Str $tag, HTML::MyHTML::Collection :collection(:$co)) {
  return $co.add($!raw, $tag) if $co.defined;
  my int64 $status;
  my $coll = do if Tag.{$tag}:exists {
    myhtml_get_nodes_by_tag_id($!raw, Collection, Tag.{$tag}, $status);
  } else {
    my $b = $tag.encode('UTF-8');
    myhtml_get_nodes_by_name($!raw, Collection, $b, $b.bytes, $status);
  }
  # TODO: Implement MyHTML X exception classes
  if $status == 0 {
    return HTML::MyHTML::Collection.new: :raw($coll) :tree($!raw)
  } else { return $status }
}
