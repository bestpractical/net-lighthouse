use strict;
use warnings;

use Test::More tests => 7;
use Test::Mock::LWP;

use_ok( 'Net::Lighthouse::User::Membership' );
can_ok( 'Net::Lighthouse::User::Membership', 'new' );

my $ms = Net::Lighthouse::User::Membership->new;
isa_ok( $ms, 'Net::Lighthouse::User::Membership' );

for my $attr( qw/id user_id account project/ ) {
    can_ok( $ms, $attr );
}

