use strict;
use warnings;

use Test::More tests => 10;
use Test::Mock::LWP;

use_ok( 'Net::Lighthouse::User' );
can_ok( 'Net::Lighthouse::User', 'new' );

my $user = Net::Lighthouse::User->new;
isa_ok( $user, 'Net::Lighthouse::User' );
isa_ok( $user, 'Net::Lighthouse' );

for my $attr( qw/id name job name website avatar_url/ ) {
    can_ok( $user, $attr );
}

