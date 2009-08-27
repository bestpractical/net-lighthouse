use strict;
use warnings;

use Test::More tests => 13;
use Test::Mock::LWP;

use_ok('Net::Lighthouse::Project');
use_ok('Net::Lighthouse::Project::Changeset');
can_ok( 'Net::Lighthouse::Project::Changeset', 'new' );

my $changeset = Net::Lighthouse::Project::Changeset->new;
isa_ok( $changeset, 'Net::Lighthouse::Project::Changeset' );
isa_ok( $changeset, 'Net::Lighthouse' );

my @attrs = (
    'body',    'revision', 'project_id', 'changed_at',
    'changes', 'user_id',  'title',      'body_html',
);

for my $attr (@attrs) {
    can_ok( $changeset, $attr );
}

