use strict;
use warnings;

use Test::More tests => 18;
use Test::Mock::LWP;

use_ok('Net::Lighthouse::Project');
use_ok('Net::Lighthouse::Project::Milestone');
can_ok( 'Net::Lighthouse::Project::Milestone', 'new' );

my $milestone = Net::Lighthouse::Project::Milestone->new;
isa_ok( $milestone, 'Net::Lighthouse::Project::Milestone' );
isa_ok( $milestone, 'Net::Lighthouse' );

my @attrs = (
    'open_tickets_count', 'created_at',
    'goals_html',            'user_name',
    'permalink',             'project_id',
    'due_on',                'tickets_count',
    'url',                   'updated_at',
    'id',                    'title',
    'goals'
);

for my $attr (@attrs) {
    can_ok( $milestone, $attr );
}

