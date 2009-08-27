use strict;
use warnings;

use Test::More tests => 15;
use Test::Mock::LWP;

use_ok('Net::Lighthouse::Project');
use_ok('Net::Lighthouse::Project::TicketBin');
can_ok( 'Net::Lighthouse::Project::TicketBin', 'new' );

my $bin = Net::Lighthouse::Project::TicketBin->new;
isa_ok( $bin, 'Net::Lighthouse::Project::TicketBin' );
isa_ok( $bin, 'Net::Lighthouse' );

my @attrs = (
    'query',      'user_id', 'position',   'name',
    'default',    'shared',  'project_id', 'tickets_count',
    'updated_at', 'id'
);

for my $attr (@attrs) {
    can_ok( $bin, $attr );
}

