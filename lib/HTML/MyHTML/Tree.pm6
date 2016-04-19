unit class HTML::MyHTML::Tree;

=head2 Methods

method new(\myhtml) {
  my \mytree := myhtml_tree_create();
  debug status myhtml_tree_init(mytree, myhtml);
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
