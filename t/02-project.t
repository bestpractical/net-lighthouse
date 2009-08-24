use strict;
use warnings;

use Test::More tests => 45;

use_ok( 'Net::Lighthouse::Project' );

for my $class_method ( qw/new find/ ) {
    can_ok( 'Net::Lighthouse::Project', $class_method );
}
my $project = Net::Lighthouse::Project->new;
isa_ok( $project, 'Net::Lighthouse::Project' );
isa_ok( $project, 'Net::Lighthouse' );
for my $attr( qw/archived created_at default_assigned_user_id
        default_milestone_id description description_html hidden
        id license name open_ticket_count permalink public 
        send_changesets_to_events updated_at open_states_list 
        closed_states_list open_states closed_states/ ) {
    can_ok( $project, $attr );
}

for my $method ( qw/find save tickets/ ) {
    can_ok( $project, $method );
}
$project->account('sunnavy');
use Test::Mock::LWP;
$Mock_ua->mock( get => sub { $Mock_response } );
$Mock_response->mock(
    content => sub {
        local $/;
        open my $fh, '<', 't/data/find_project_35918.xml' or die $!;
        <$fh>
    }
);

my $sd = Net::Lighthouse::Project->find(35918);
my %hash = (
    'description_html' => '<div><p>test for sd</p></div>',
    'open_states_list' => 'new,open',
    'open_states'      => 'new/f17  # You can add comments here
open/aaa # if you want to.',
    'default_assigned_user_id'  => undef,
    'permalink'                 => 'sd',
    'created_at'                => '2009-08-21T10:02:21Z',
    'default_milestone_id'      => undef,
    'send_changesets_to_events' => 'true',
    'public'                    => 'false',
    'id'                        => '35918',
    'closed_states'             => 'resolved/6A0 # You can customize colors
hold/EB0     # with 3 or 6 character hex codes
invalid/A30  # \'A30\' expands to \'AA3300\'',
    'name'               => 'sd',
    'license'            => undef,
    'description'        => 'test for sd',
    'archived'           => 'false',
    'closed_states_list' => 'resolved,hold,invalid',
    'updated_at'         => '2009-08-24T05:46:52Z',
    'hidden'             => 'false'
);

for my $k ( keys %hash ) {
    is( $sd->$k, $hash{$k}, "$k is loaded" );
}
