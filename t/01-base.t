use strict;
use warnings;

use Test::More tests => 15;
use MIME::Base64;

use_ok('Net::Lighthouse');
can_ok( 'Net::Lighthouse', 'new' );
my $lh = Net::Lighthouse->new;
isa_ok( $lh, 'Net::Lighthouse' );
for (qw/account email password token base_url ua/) {
    can_ok( $lh, $_ );
}

$lh->account('sunnavy');
is( $lh->base_url, 'http://sunnavy.lighthouseapp.com', 'base_url' );
isa_ok( $lh->ua, 'LWP::UserAgent' );
is(
    $lh->ua->default_header('User-Agent'),
    "net-lighthouse/$Net::Lighthouse::VERSION",
    'agent of ua'
);

is( $lh->ua->default_header('Content-Type'),
    'application/xml', 'content-type of ua' );

my $token = 'a' x 40;
$lh->token($token);
is( $lh->ua->default_header('X-LighthouseToken'),
    $token, 'X-LighthouseToken of ua' );
$lh->email('mark@twain.org');
$lh->password('huckleberry');
my $auth_base64 = encode_base64( $lh->email . ':' . $lh->password );
chomp $auth_base64;
is(
    $lh->ua->default_header('Authorization'),
    'Basic ' . $auth_base64,
    'Authorization of ua'
);
