use strict;
use warnings;

use Test::More tests => 14;

use_ok('Net::Lighthouse::Project::Ticket::Attachment');
can_ok( 'Net::Lighthouse::Project::Ticket::Attachment', 'new' );

my $version = Net::Lighthouse::Project::Ticket::Attachment->new;
isa_ok( $version, 'Net::Lighthouse::Project::Ticket::Attachment' );

my @attrs = (
    'width',        'created_at',  'height',   'size',
    'content_type', 'uploader_id', 'filename', 'url',
    'type',         'id',          'code'
);

for my $attr (@attrs) {
    can_ok( $version, $attr );
}

