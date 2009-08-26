use strict;
use warnings;

use Test::More tests => 19;

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

can_ok( $token, 'load_from_xml' );

my $xml = do {
    local $/;
    open my $fh, '<', 't/data/token.xml' or die $!;
    <$fh>;
};
my $m = $token->load_from_xml($xml);
is( $m, $token, 'load return $self' );
my %hash = (
    'created_at' => '2007-04-21T18:17:32Z',
    'account'    => 'http://activereload.lighthouseapp.com',
    'read_only'  => 'false',
    'user_id'    => '1',
    'token'      => '01234567890123456789012345678900123456789',
    'project_id' => '',
    'note'       => 'test 1'
);

for my $k ( keys %hash ) {
    is( $m->$k, $hash{$k}, "$k is loaded" );
}
