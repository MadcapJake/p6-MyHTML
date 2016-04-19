unit module HTML::MyHTML::String;

use NativeCall;

use HTML::MyHTML::Lib;

class MyHTMLString is repr('CPointer') is export {



  my class MCharAsync is repr('CPointer') {}



  submethod BUILD(:$!tree, :$!node, :$!mchar,
                  :$!node-id, :$!string, :$!size) {
    $!mchar   //= $!tree.mchar;
    $!node-id //= $!tree.mchar-node-id;
    $!string  //= $!node.Str;
    $!size      = $!string.encode.elems * 8;
    myhtml_string_init($!mchar, $!node-id, $!string, $!size)
  }


  method resize(size_t(Int) $new-size) {
    myhtml_string_realloc($!mchar, $!node-id, $!string, $new-size);
  }



  multi method clean() { myhtml_string_clean($!string) }



  multi method clean(:$all) { myhtml_string_clean($!string) }

  method dispose(:$obj = False) {
    myhtml_string_destroy($!string, $obj);
  }



  method Str { myhtml_string_data($!string) }



  method length { myhtml_string_length($!string) }



  method size { myhtml_string_size($!string) }



  method set(Str :$data, Int :$size, Int :$length) {
    # TODO: Perhaps run the data-alloc/data-realloc automatically?
    myhtml_string_data_set\ ($!string, $_) with $data;
    myhtml_string_size_set\ ($!string, $_) with $size;
    myhtml_string_length_set($!string, $_) with $length;
  }



  method alloc(Int $size) {
    myhtml_string_data_alloc($!mchar, $!node-id, $size);
  }



  method realloc(Int $copy, Int $size) {
    myhtml_string_data_realloc($!mchar, $!node-id, self.Str,
                               $copy,   $size);
  }



  method release(Str $data) {
    myhtml_string_data_free($!mchar, $!node-id, $data);
  }

}
