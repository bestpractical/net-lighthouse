use strict;
use warnings;

use Test::More tests => 21;
use Test::Mock::LWP;

use_ok('Net::Lighthouse::Project');
use_ok('Net::Lighthouse::Project::Message');
can_ok( 'Net::Lighthouse::Project::Message', 'new' );

my $message = Net::Lighthouse::Project::Message->new;
isa_ok( $message, 'Net::Lighthouse::Project::Message' );
isa_ok( $message, 'Net::Lighthouse' );

my @attrs = (
    'created_at',        'comments',
    'body_html',         'user_name',
    'permalink',         'body',
    'comments_count',    'parent_id',
    'url',               'updated_at',
    'id',                'user_id',
    'project_id',        'all_attachments_count',
    'attachments_count', 'title',
);

for my $attr (@attrs) {
    can_ok( $message, $attr );
}

