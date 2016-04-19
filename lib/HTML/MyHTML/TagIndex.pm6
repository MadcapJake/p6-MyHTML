unit class HTML::MyHTML::TagIndex;

use NativeCall;

use HTML::MyHTML::Lib;
use HTML::MyHTML::Node;
use HTML::MyHTML::Status;
use HTML::MyHTML::Tag;

has $!tag;

method new(MyHTMLTag $tag) {
  $!tag = $tag;
  my $tag-index = myhtml_tag_index_create($tag);
  my $status = myhtml_tag_index_init($tag, $tag-index);
  $status == 0 ?? $tag-index !! $status;
}

method clean { myhtml_tag_index_clean($!tag, self) }

method destroy { myhtml_tag_index_destroy($!tag, self) }

method add(TreeNode $node) { myhtml_tag_index_add($!tag, self, $node) }

method entry(MyHTMLTagType $tag-id) { myhtml_tag_index_entry(self, $tag-id) }

method first-node(MyHTMLTagType $tag-id) { myhtml_tag_index_first(self, $tag-id) }

method last-node(MyHTMLTagType $tag-id) { myhtml_tag_index_last(self, $tag-id) }

method next(MyHTMLTagIndexNode $node) { myhtml_tag_index_next($node) }

method prev(MyHTMLTagIndexNode $node) { myhtml_tag_index_prev($node) }

method tree-node(MyHTMLTagIndexNode $node) { myhtml_tag_index_tree_node($node) }

method entry-count(MyHTMLTagType $tag-id) { myhtml_tag_index_entry_count(self, $tag-id) }
