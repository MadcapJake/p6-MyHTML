unit module HTML::MyHTML::String;

use NativeCall;

use HTML::MyHTML::Lib;

class MyHTMLString is repr('CPointer') is export {

  has $!mchar;
  has $!tree;
  has $!node;
  has $!node-id;
  has $!string;
  has $!size;

  my class MCharAsync is repr('CPointer') {}

  #| Init myhtml_string_t structure
  #|
  #| @param[in] mchar_async_t*. It can be obtained from myhtml_tree_t object
  #|  (see myhtml_tree_get_mchar function) or create manualy
  #|  For each Tree creates its object, I recommend to use it (myhtml_tree_get_mchar).
  #|
  #| @param[in] node_id. For all threads (and Main thread) identifier that is unique.
  #|  if created mchar_async_t object manually you know it, if not then take from the Tree
  #|  (see myhtml_tree_get_mchar_node_id)
  #|
  #| @param[in] myhtml_string_t*. It can be obtained from myhtml_tree_node_t object
  #|  (see myhtml_node_string function) or create manualy
  #|
  #| @param[in] data size. Set the size you want for char*
  #|
  #| @return char* of the size if successful, otherwise a NULL value
  sub myhtml_string_init(MCharAsync, size_t, MyHTMLString, size_t)
      returns Str
      is native(&lib)
      { * }

  submethod BUILD(:$!tree, :$!node, :$!mchar,
                  :$!node-id, :$!string, :$!size) {
    $!mchar   //= $!tree.mchar;
    $!node-id //= $!tree.mchar-node-id;
    $!string  //= $!node.Str;
    $!size      = $!string.encode.elems * 8;
    myhtml_string_init($!mchar, $!node-id, $!string, $!size)
  }

  #| Increase the current size for myhtml_string_t object
  #|
  #| @param[in] mchar_async_t*. See description for myhtml_string_init function
  #| @param[in] node_id. See description for myhtml_string_init function
  #| @param[in] myhtml_string_t*. See description for myhtml_string_init function
  #| @param[in] data size. Set the new size you want for myhtml_string_t object
  #|
  #| @return char* of the size if successful, otherwise a NULL value
  sub myhtml_string_realloc(MCharAsync, size_t, MyHTMLString, size_t)
      returns Str
      is native(&lib)
      { * }

  method resize(size_t(Int) $new-size) {
    myhtml_string_realloc($!mchar, $!node-id, $!string, $new-size);
  }

  #| Clean myhtml_string_t object. In reality, data length set to 0
  #| Equivalently: myhtml_string_length_set(str, 0);
  #|
  #| @param[in] myhtml_string_t*. See description for myhtml_string_init function
  sub myhtml_string_clean(MyHTMLString)
      is native(&lib)
      { * }

  multi method clean() { myhtml_string_clean($!string) }

  #| Clean myhtml_string_t object. Equivalently: memset(str, 0, sizeof(myhtml_string_t))
  #|
  #| @param[in] myhtml_string_t*. See description for myhtml_string_init function
  sub myhtml_string_clean_all(MyHTMLString)
      is native(&lib)
      { * }

  multi method clean(:$all) { myhtml_string_clean($!string) }

  #| Release all resources for myhtml_string_t object
  #|
  #| @param[in] myhtml_string_t*. See description for myhtml_string_init function
  #| @param[in] call free function for current object or not
  #|
  #| @return NULL if destroy_obj set true, otherwise a current myhtml_string_t object
  sub myhtml_string_destroy(MyHTMLString, bool)
      returns MyHTMLString
      is native(&lib)
      { * }

  method dispose(:$obj = False) {
    myhtml_string_destroy($!string, $obj);
  }

  #| Get data (char*) from a myhtml_string_t object
  #|
  #| @param[in] myhtml_string_t*. See description for myhtml_string_init function
  #|
  #| @return char* if exists, otherwise a NULL value
  sub myhtml_string_data(MyHTMLString)
      returns Str
      is native(&lib)
      { * }

  method Str { myhtml_string_data($!string) }

  #| Get data length from a myhtml_string_t object
  #|
  #| @param[in] myhtml_string_t*. See description for myhtml_string_init function
  #|
  #| @return data length
  sub myhtml_string_length(MyHTMLString)
      returns size_t
      is native(&lib)
      { * }

  method length { myhtml_string_length($!string) }

  #| Get data size from a myhtml_string_t object
  #|
  #| @param[in] myhtml_string_t*. See description for myhtml_string_init function
  #|
  #| @return data size
  sub myhtml_string_size(MyHTMLString)
      returns size_t
      is native(&lib)
      { * }

  method size { myhtml_string_size($!string) }

  #| Set data (char *) for a myhtml_string_t object.
  #|
  #| Attention!!! Attention!!! Attention!!!
  #|
  #| You can assign only that it has been allocated from functions:
  #| myhtml_string_data_alloc
  #| myhtml_string_data_realloc
  #| or obtained manually created from mchar_async_t object
  #|
  #| Attention!!! Do not try set char* from allocated by malloc or realloc!!!
  #|
  #| @param[in] myhtml_string_t*. See description for myhtml_string_init function
  #| @param[in] you data to want assign
  #|
  #| @return assigned data if successful, otherwise a NULL value
  sub myhtml_string_data_set(MyHTMLString, Str)
      returns Str
      is native(&lib)
      { * }

  #| Set data size for a myhtml_string_t object.
  #|
  #| @param[in] myhtml_string_t*. See description for myhtml_string_init function
  #| @param[in] you size to want assign
  #|
  #| @return assigned size
  sub myhtml_string_size_set(MyHTMLString, size_t)
      returns size_t
      is native(&lib)
      { * }

  #| Set data length for a myhtml_string_t object.
  #|
  #| @param[in] myhtml_string_t*. See description for myhtml_string_init function
  #| @param[in] you length to want assign
  #|
  #| @return assigned length
  sub myhtml_string_length_set(MyHTMLString, size_t)
      returns size_t
      is native(&lib)
      { * }

  method set(Str :$data, Int :$size, Int :$length) {
    # TODO: Perhaps run the data-alloc/data-realloc automatically?
    myhtml_string_data_set\ ($!string, $_) with $data;
    myhtml_string_size_set\ ($!string, $_) with $size;
    myhtml_string_length_set($!string, $_) with $length;
  }


  #| Allocate data (char*) from a mchar_async_t object
  #|
  #| @param[in] mchar_async_t*. See description for myhtml_string_init function
  #| @param[in] node id. See description for myhtml_string_init function
  #| @param[in] you size to want assign
  #|
  #| @return data if successful, otherwise a NULL value
  sub myhtml_string_data_alloc(MCharAsync, size_t, size_t)
      returns Str
      is native(&lib)
      { * }

  method alloc(Int $size) {
    myhtml_string_data_alloc($!mchar, $!node-id, $size);
  }

  #| Allocate data (char*) from a mchar_async_t object
  #|
  #| @param[in] mchar_async_t*. See description for myhtml_string_init function
  #| @param[in] node id. See description for myhtml_string_init function
  #| @param[in] old data
  #| @param[in] how much data is copied from the old data to new data
  #| @param[in] new size
  #|
  #| @return data if successful, otherwise a NULL value
  sub myhtml_string_data_realloc(MCharAsync, size_t, Str, size_t, size_t)
      returns Str
      is native(&lib)
      { * }

  method realloc(Int $copy, Int $size) {
    myhtml_string_data_realloc($!mchar, $!node-id, self.Str,
                               $copy,   $size);
  }

  #| Release allocated data
  #|
  #| @param[in] mchar_async_t*. See description for myhtml_string_init function
  #| @param[in] node id. See description for myhtml_string_init function
  #| @param[in] data to release
  #|
  #| @return data if successful, otherwise a NULL value
  sub myhtml_string_data_free(MCharAsync, size_t, Str)
      is native(&lib)
      { * }

  method release(Str $data) {
    myhtml_string_data_free($!mchar, $!node-id, $data);
  }

}
