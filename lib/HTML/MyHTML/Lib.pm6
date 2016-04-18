unit module HTML::MyHTML::Lib;

sub lib() is export { '/usr/local/lib/libmyhtml.so' }

sub debug($s) is export { say $s if %*ENV<P6_MYHTML_DEBUG> }
