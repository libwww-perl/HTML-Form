#!perl

use strict;
use warnings;

use Test::More tests => 15;
use HTML::Form;

my @warn;
$SIG{__WARN__} = sub { push( @warn, $_[0] ) };

my $f = HTML::Form->parse( <<'EOT', "http://localhost/" );
<form action="abc" name="foo">
<input name="name">
<input name="latin">
</form>
<form></form>
EOT

is( $f->value("name"),  "" );
is( $f->accept_charset, "UNKNOWN" );
my $req = $f->click;
is( $req->uri, "http://localhost/abc?name=&latin=" );

$f->value( name  => "\x{0424}" );    # capital cyrillic ef
$f->value( latin => "\xE5" );        # aring
$req = $f->click;
is( $req->method, "GET" );
is( $req->uri,    "http://localhost/abc?name=%D0%A4&latin=%C3%A5" );

$f->method('POST');
$f->enctype('multipart/form-data');

$req = $f->click;
is( $req->uri, "http://localhost/abc" );
is(
    $req->content,
    "--xYzZY\r\nContent-Disposition: form-data; name=\"name\"\r\n\r\n\xD0\xA4\r\n--xYzZY\r\nContent-Disposition: form-data; name=\"latin\"\r\n\r\n\xC3\xA5\r\n--xYzZY--\r\n"
);

$f->accept_charset('koi8-r');
$req = $f->click;
is( $req->uri, "http://localhost/abc" );
is(
    $req->content,
    "--xYzZY\r\nContent-Disposition: form-data; name=\"name\"\r\n\r\n\xE6\r\n--xYzZY\r\nContent-Disposition: form-data; name=\"latin\"\r\n\r\n?\r\n--xYzZY--\r\n"
);

$f->method('GET');
$req = $f->click;
is( $req->uri, "http://localhost/abc?name=%E6&latin=%3F" );

$f = HTML::Form->parse( <<'EOT', "http://localhost/" );
<form action="abc" name="foo" accept-charset="koi8-r">
<input name="name">
</form>
<form></form>
EOT

is( $f->accept_charset, 'koi8-r' );

$f->value( name => "\x{0425}" );    # capital cyrillic kha
$req = $f->click;
is( $req->method, "GET" );
is( $req->uri,    "http://localhost/abc?name=%E8" );

$f->method('POST');
$f->enctype('multipart/form-data');

$req = $f->click;
is( $req->uri, "http://localhost/abc" );
is(
    $req->content,
    "--xYzZY\r\nContent-Disposition: form-data; name=\"name\"\r\n\r\n\xE8\r\n--xYzZY--\r\n"
);
