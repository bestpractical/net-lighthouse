use strict;
use warnings;

use Test::More tests => 13;
use MIME::Base64;

use_ok('Net::Lighthouse');
can_ok( 'Net::Lighthouse', 'new' );
my $lh = Net::Lighthouse->new( account => 'sunnavy' );
isa_ok( $lh, 'Net::Lighthouse' );
for (qw/account auth base_url ua/) {
    can_ok( $lh, $_ );
}

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
$lh->auth->{token} = $token;
is( $lh->ua->default_header('X-LighthouseToken'),
    $token, 'X-LighthouseToken of ua' );
$lh->auth->{email} = 'mark@twain.org';
$lh->auth->{password} = 'huckleberry';
my $auth_base64 = encode_base64( $lh->auth->{email} . ':' . $lh->auth->{password} );
chomp $auth_base64;
is(
    $lh->ua->default_header('Authorization'),
    'Basic ' . $auth_base64,
    'Authorization of ua'
);
