unit module HTML::MyHTML::Namespace;

enum MyHTMLNamespace is export (
  UNDEF      => 0x00,
  HTML       => 0x01,
  MATHML     => 0x02,
  SVG        => 0x03,
  XLINK      => 0x04,
  XML        => 0x05,
  XMLNS      => 0x06,
  LAST_ENTRY => 0x07
);
