use strict;
use warnings;

use Test::More tests => 24;

use_ok('Net::Lighthouse::Project::Ticket::Version');
can_ok( 'Net::Lighthouse::Project::Ticket::Version', 'new' );

my $version = Net::Lighthouse::Project::Ticket::Version->new;
isa_ok( $version, 'Net::Lighthouse::Project::Ticket::Version' );

my @attrs = (
    'assigned_user_name', 'assigned_user_id',
    'attachments_count',  'body',
    'body_html',          'closed',
    'created_at',         'creator_id',
    'milestone_id',       'number',
    'permalink',          'project_id',
    'state',              'tag',
    'title',              'updated_at',
    'user_id',            'user_name',
    'creator_name',       'url',
    'diffable_attributes',
);

for my $attr (@attrs) {
    can_ok( $version, $attr );
}

