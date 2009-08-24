use strict;
use warnings;

use Test::More tests => 14;
use MIME::Base64;

use_ok('Net::Lighthouse');
can_ok( 'Net::Lighthouse', 'new' );
for my $class_attr (qw/account email password token base_url ua/) {
    can_ok( 'Net::Lighthouse', $class_attr );
}

my $lh = Net::Lighthouse->new;
isa_ok( $lh, 'Net::Lighthouse' );

Net::Lighthouse->account('sunnavy');
is( Net::Lighthouse->base_url, 'http://sunnavy.lighthouseapp.com', 'base_url' );
isa_ok( Net::Lighthouse->ua, 'LWP::UserAgent' );
is(
    Net::Lighthouse->ua->default_header('user-agent'),
    "net-lighthouse/$Net::Lighthouse::VERSION",
    'agent of ua'
);

my $token = 'a' x 40;
Net::Lighthouse->token($token);
is( Net::Lighthouse->ua->default_header('X-LighthouseToken'),
    $token, 'X-LighthouseToken of ua' );
Net::Lighthouse->email('mark@twain.org');
Net::Lighthouse->password('huckleberry');
my $auth_base64 =
  encode_base64( Net::Lighthouse->email . ':' . Net::Lighthouse->password );
chomp $auth_base64;
is(
    Net::Lighthouse->ua->default_header('Authorization'),
    'Basic ' . $auth_base64,
    'Authorization of ua'
);
