unit class MyHTMLCollection is repr('CStruct');

use NativeCall;

use HTML::MyHTML::Lib;
use HTML::MyHTML::Status;

has CArray[Pointer] $.list;
has size_t $.size;
has size_t $.length;

#| Create collection
#|
#| @param[in] list size
#| @param[out] optional, status of operation
#|
#| @return myhtml_collection_t* if successful, otherwise an NULL value
sub myhtml_collection_create(size_t, int32 is rw) is native(&lib) returns MyHTMLCollection {*}

method new(UInt $size) {
  my int32 $status;
  my $coll = myhtml_collection_create($size, $status);
  die "Error: {status($status)}" unless $status ~~ MyHTML_STATUS_OK;
}

#| Clears collection
#|
#| @param[in] myhtml_collection_t*
sub myhtml_collection_clean(MyHTMLCollection) is native(&lib) {*}

method empty { myhtml_collection_clean(self) }

#| Destroy allocated resources
#|
#| @param[in] myhtml_collection_t*
#|
#| @return NULL if successful, otherwise an myhtml_collection_t* structure
sub myhtml_collection_destroy(MyHTMLCollection) is native(&lib) {*}

submethod DESTROY { myhtml_collection_destroy(self) }
method dispose { self.DESTROY }

#| Check size by length and increase if necessary
#|
#| @param[in] myhtml_collection_t*
#| @param[in] count of add nodes
#|
#| @return NULL if successful, otherwise an myhtml_collection_t* structure
sub myhtml_collection_check_size(MyHTMLCollection, size_t) is native(&lib) returns int32 {*}

method check-size(size_t(Int) $up-to-length) {
  myhtml_collection_check_size(self, $up-to-length)
}
