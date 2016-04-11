unit module HTML::MyHTML::Encoding;

use NativeCall;

use HTML::MyHTML::Lib;

enum MyHTMLEncoding is export (
    MyHTML_ENCODING_DEFAULT          => 0x00,
    MyHTML_ENCODING_AUTO             => 0x01, # future
    MyHTML_ENCODING_CUSTOM           => 0x02, # future
    MyHTML_ENCODING_UTF_8            => 0x00, # default encoding
    MyHTML_ENCODING_UTF_16LE         => 0x04,
    MyHTML_ENCODING_UTF_16BE         => 0x05,
    MyHTML_ENCODING_X_USER_DEFINED   => 0x06,
    MyHTML_ENCODING_BIG5             => 0x07,
    MyHTML_ENCODING_EUC_KR           => 0x08,
    MyHTML_ENCODING_GB18030          => 0x09,
    MyHTML_ENCODING_IBM866           => 0x0a,
    MyHTML_ENCODING_ISO_8859_10      => 0x0b,
    MyHTML_ENCODING_ISO_8859_13      => 0x0c,
    MyHTML_ENCODING_ISO_8859_14      => 0x0d,
    MyHTML_ENCODING_ISO_8859_15      => 0x0e,
    MyHTML_ENCODING_ISO_8859_16      => 0x0f,
    MyHTML_ENCODING_ISO_8859_2       => 0x10,
    MyHTML_ENCODING_ISO_8859_3       => 0x11,
    MyHTML_ENCODING_ISO_8859_4       => 0x12,
    MyHTML_ENCODING_ISO_8859_5       => 0x13,
    MyHTML_ENCODING_ISO_8859_6       => 0x14,
    MyHTML_ENCODING_ISO_8859_7       => 0x15,
    MyHTML_ENCODING_ISO_8859_8       => 0x16,
    MyHTML_ENCODING_KOI8_R           => 0x17,
    MyHTML_ENCODING_KOI8_U           => 0x18,
    MyHTML_ENCODING_MACINTOSH        => 0x19,
    MyHTML_ENCODING_WINDOWS_1250     => 0x1a,
    MyHTML_ENCODING_WINDOWS_1251     => 0x1b,
    MyHTML_ENCODING_WINDOWS_1252     => 0x1c,
    MyHTML_ENCODING_WINDOWS_1253     => 0x1d,
    MyHTML_ENCODING_WINDOWS_1254     => 0x1e,
    MyHTML_ENCODING_WINDOWS_1255     => 0x1f,
    MyHTML_ENCODING_WINDOWS_1256     => 0x20,
    MyHTML_ENCODING_WINDOWS_1257     => 0x21,
    MyHTML_ENCODING_WINDOWS_1258     => 0x22,
    MyHTML_ENCODING_WINDOWS_874      => 0x23,
    MyHTML_ENCODING_X_MAC_CYRILLIC   => 0x24,
    MyHTML_ENCODING_LAST_ENTRY       => 0x25
);

#| Convert Int to Enum
sub Enc(Int $enum) returns MyHTMLEncoding is export {
  MyHTMLEncoding.enums.invert.Hash{$enum};
}

#| Convert Unicode Codepoint to UTF-8
#|
#| @param[in] Codepoint
#| @param[in] Data to set characters. Minimum data length is 1 bytes, maximum is 4 byte
#|   data length must be always available 4 bytes
#|
#| @return size character set
sub codepoint-to-utf8(size_t, Str)
    returns size_t
    is native(&lib)
    is symbol<myhtml_encoding_codepoint_to_ascii_utf_8>
    is export
    { * }



#| Convert Unicode Codepoint to UTF-16LE
#|
#| I advise not to use UTF-16! Use UTF-8 and be happy!
#|
#| @param[in] Codepoint
#| @param[in] Data to set characters. Data length is 2 or 4 bytes
#|   data length must be always available 4 bytes
#|
#| @return size character set
sub codepoint-to-utf16(size_t, Str)
    returns size_t
    is native(&lib)
    is symbol<myhtml_encoding_codepoint_to_ascii_utf_16>
    is export
    { * }

#| Detect character encoding
#|
#| Now available for detect UTF-8, UTF-16LE, UTF-16BE
#| and Russians: windows-1251,  koi8-r, iso-8859-5, x-mac-cyrillic, ibm866
#| Other in progress
#|
#| @param[in]  text
#| @param[in]  text length
#| @param[out] detected encoding
#|
#| @return true if encoding found, otherwise false
sub myhtml_encoding_detect(CArray[uint8], size_t, int32 is rw)
    returns bool
    is native(&lib)
    { * }

sub detect-encoding(Str $text, $enc is rw) is export {
  my CArray[uint8] $chs .= new: $text.encode.list;
  myhtml_encoding_detect: $chs, $chs.elems * 8, $enc;
}

#| Detect Russian character encoding
#|
#| Now available for detect windows-1251,  koi8-r, iso-8859-5, x-mac-cyrillic, ibm866
#|
#| @param[in]  text
#| @param[in]  text length
#| @param[out] detected encoding
#|
#| @return true if encoding found, otherwise false
sub myhtml_encoding_detect_russian(CArray[uint8], size_t, int32 is rw)
    returns bool
    is native(&lib)
    { * }

sub detect-russian(Str $text, $enc is rw) is export {
  my CArray[uint8] $chs .= new: $text.encode.list;
  myhtml_encoding_detect_russian: $chs, $chs.elems * 8, $enc;
}

#| Detect Unicode character encoding
#|
#| Now available for detect UTF-8, UTF-16LE, UTF-16BE
#|
#| @param[in]  text
#| @param[in]  text length
#| @param[out] detected encoding
#|
#| @return true if encoding found, otherwise false
sub mythml_encoding_detect_unicode(CArray[uint8], size_t, int32 is rw)
    returns bool
    is native(&lib)
    { * }

sub detect-unicode(Str $text, $enc is rw) is export {
  my CArray[uint8] $chs .= new: $text.encode.list;
  myhtml_encoding_detect_unicode: $chs, $chs.elems * 8, $enc;
}

#| Detect Unicode character encoding by BOM
#|
#| Now available for detect UTF-8, UTF-16LE, UTF-16BE
#|
#| @param[in]  text
#| @param[in]  text length
#| @param[out] detected encoding
#|
#| @return true if encoding found, otherwise false
sub myhtml_encoding_detect_bom(CArray[uint8], size_t, int32 is rw)
    is native(&lib)
    returns bool
    { * }

sub detect-bom(Str $text, $enc is rw) is export {
  my CArray[uint8] $chs .= new: $text.encode.list;
  myhtml_encoding_detect_bom: $chs, $chs.elems * 8, $enc;
}

#| Detect Unicode character encoding by BOM. Cut BOM if will be found
#|
#| Now available for detect UTF-8, UTF-16LE, UTF-16BE
#|
#| @param[in]  text
#| @param[in]  text length
#| @param[out] detected encoding
#| @param[out] new text position
#| @param[out] new size position
#|
#| @return true if encoding found, otherwise false
sub myhtml_encoding_detect_and_cut_bom(CArray[uint8], size_t, int32 is rw, CArray[uint8] is rw, size_t is rw)
    returns bool
    is native(&lib)
    { * }

sub detect-and-cut-bom(
  Str:D  $text,  #= Text to be detected and cut
  Bool  :$hash   #= Whether to return Bool or the details
) is export {
  my CArray[uint8] $chs .= new: $text.encode.list;
  my ($enc, $pos, $size);
  my bool $res = myhtml_encoding_detect_and_cut_bom($chs, $enc, $pos, $size);
  $hash.defined ?? {
    res  => ?$res,
    enc  => Enc($enc),
    pos  => +$pos,
    size => +$size
  } !! $res;
}
