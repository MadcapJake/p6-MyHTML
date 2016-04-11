unit class MyHTMLTagIndex is repr('CPointer');

use NativeCall;

use HTML::MyHTML::Lib;
use HTML::MyHTML::Node;
use HTML::MyHTML::Status;
use HTML::MyHTML::Tag;

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
sub myhtml_tag_index_add(MyHTMLTag, MyHTMLTagIndex, TreeNode) is native(&lib) returns MyHTMLStatus {*}

method add(TreeNode $node) { myhtml_tag_index_add($!tag, self, $node) }

#| Get root tag index. Is the initial entry for a tag. It contains statistics and other items by tag
#|
#| @param[in] myhtml_tag_index_t*
#| @param[in] myhtml_tag_id_t
#|
#| @return myhtml_tag_index_entry_t* if successful, otherwise a NULL value.
sub myhtml_tag_index_entry(MyHTMLTagIndex, int32) is native(&lib) returns MyHTMLTagIndexEntry {*}

method entry(MyHTMLTagType $tag-id) { myhtml_tag_index_entry(self, $tag-id) }

#| Get first index node for tag
#|
#| @param[in] myhtml_tag_index_t*
#| @param[in] myhtml_tag_id_t
#|
#| @return myhtml_tag_index_node_t* if exists, otherwise a NULL value.
sub myhtml_tag_index_first(MyHTMLTagIndex, int32) is native(&lib) returns MyHTMLTagIndexNode {*}

method first-node(MyHTMLTagType $tag-id) { myhtml_tag_index_first(self, $tag-id) }

#| Get last index node for tag
#|
#| @param[in] myhtml_tag_index_t*
#| @param[in] myhtml_tag_id_t
#|
#| @return myhtml_tag_index_node_t* if exists, otherwise a NULL value.
sub myhtml_tag_index_last(MyHTMLTagIndex, int32) is native(&lib) returns MyHTMLTagIndexNode {*}

method last-node(MyHTMLTagType $tag-id) { myhtml_tag_index_last(self, $tag-id) }

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
sub myhtml_tag_index_tree_node(MyHTMLTagIndexNode) is native(&lib) returns TreeNode {*}

method tree-node(MyHTMLTagIndexNode $node) { myhtml_tag_index_tree_node($node) }

#| Get count of elements in index by tag id
#|
#| @param[in] myhtml_tag_index_t*
#| @param[in] tag id
#|
#| @return count of elements
sub myhtml_tag_index_entry_count(MyHTMLTagIndex, int32) is native(&lib) returns TreeNode {*}

method entry-count(MyHTMLTagType $tag-id) { myhtml_tag_index_entry_count(self, $tag-id) }
