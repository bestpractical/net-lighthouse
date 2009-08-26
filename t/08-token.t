use strict;
use warnings;

use Test::More tests => 10;
use Test::Mock::LWP;

use_ok('Net::Lighthouse::Token');
can_ok( 'Net::Lighthouse::Token', 'new' );

my $token = Net::Lighthouse::Token->new;
isa_ok( $token, 'Net::Lighthouse::Token' );

for my $attr (
    'project_id', 'account',   'user_id', 'created_at',
    'token',      'read_only', 'note'
  )
{
    can_ok( $token, $attr );
}

