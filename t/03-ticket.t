use strict;
use warnings;

use Test::More tests => 28;
use Test::Mock::LWP;

use_ok( 'Net::Lighthouse::Project' );
use_ok( 'Net::Lighthouse::Project::Ticket' );
can_ok( 'Net::Lighthouse::Project', 'new' );

my $ticket = Net::Lighthouse::Project::Ticket->new;
isa_ok( $ticket, 'Net::Lighthouse::Project::Ticket' );
isa_ok( $ticket, 'Net::Lighthouse' );

my @attrs = (
    'priority',          'raw_data',
    'number',            'milestone_due_on',
    'created_at',        'user_name',
    'state',             'permalink',
    'versions',          'url',
    'updated_at',        'tag',
    'closed',            'attachments',
    'latest_body',       'user_id',
    'milestone_id',      'project_id',
    'attachments_count', 'assigned_user_id',
    'creator_id',        'title',
    'creator_name'
);

for my $attr( @attrs ) {
    can_ok( $ticket, $attr );
}


