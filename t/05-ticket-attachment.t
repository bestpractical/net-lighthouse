use strict;
use warnings;

use Test::More tests => 27;

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

can_ok( $version, 'load_from_xml' );

my $xml = do {
    local $/;
    open my $fh, '<', 't/data/ticket_1_attachment_1.xml' or die $!;
    <$fh>;
};
my $v1 = $version->load_from_xml($xml);
is( $v1, $version, 'load return $self' );
my %hash = (
    'width'        => undef,
    'uploader_id'  => '67166',
    'height'       => undef,
    'size'         => '24',
    'content_type' => 'application/octet-stream',
    'created_at'   => '2009-08-21T11:15:51Z',
    'filename'     => 'first',
    'url'  => 'http://sunnavy.lighthouseapp.com/attachments/249828/first',
    'type' => 'Attachment',
    'id'   => '249828',
    'code' => '5ace4f26de37855e951eb13f5b07a1b1a0919466'

);

for my $k ( keys %hash ) {
    is( $v1->$k, $hash{$k}, "$k is loaded" );
}
