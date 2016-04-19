unit class MyHTMLCollection is repr('CStruct');

use NativeCall;

use HTML::MyHTML::Lib;
use HTML::MyHTML::Status;



method new(UInt $size) {
  my int32 $status;
  my $coll = myhtml_collection_create($size, $status);
  die "Error: {status($status)}" unless $status ~~ MyHTML_STATUS_OK;
}

method empty { myhtml_collection_clean(self) }

submethod DESTROY { myhtml_collection_destroy(self) }
method dispose { self.DESTROY }

method check-size(size_t(Int) $up-to-length) {
  myhtml_collection_check_size(self, $up-to-length)
}
