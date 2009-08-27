use strict;
use warnings;

use Test::More tests => 70;
use Test::Mock::LWP;

use_ok( 'Net::Lighthouse::Project' );
can_ok( 'Net::Lighthouse::Project', 'new' );

my $project = Net::Lighthouse::Project->new;
isa_ok( $project, 'Net::Lighthouse::Project' );
isa_ok( $project, 'Net::Lighthouse' );
for my $attr( qw/archived created_at default_assigned_user_id
        default_milestone_id description description_html hidden
        id license name open_tickets_count permalink public 
        send_changesets_to_events updated_at open_states_list 
        closed_states_list open_states closed_states/ ) {
    can_ok( $project, $attr );
}

for my $method (
    qw/create update delete load load_from_xml list
    initial_state tickets ticket_bins messages milestones changesets/
  )
{
    can_ok( $project, $method );
}

$project->account('sunnavy');

$Mock_ua->mock( get => sub { $Mock_response } );
$Mock_ua->mock( default_header => sub { } ); # to erase warning
$Mock_response->mock(
    content => sub {
        local $/;
        open my $fh, '<', 't/data/find_project_35918.xml' or die $!;
        <$fh>
    }
);

my $sd = Net::Lighthouse::Project->new( account => 'sunnavy' );
my $load = $sd->load( 35918 );
is( $sd, $load, 'load return $self' );

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

$Mock_response->mock(
    content => sub {
        local $/;
        open my $fh, '<', 't/data/projects.xml' or die $!;
        <$fh>
    }
);

my $p = Net::Lighthouse::Project->new( account => 'sunnavy', id => 35918 );
my @projects = $p->list;
is( scalar @projects, 2, 'number of projects' );
is( $projects[0]->id, 35918, 'id of 2nd project' );
is( $projects[1]->id, 36513, 'id of 2nd project' );
is_deeply( $projects[0], $sd,
    'load and list should return the same info for one project' );

# test for initial_state
$Mock_response->mock(
    content => sub {
        local $/;
        open my $fh, '<', 't/data/project_new.xml' or die $!;
        <$fh>
    }
);

my $initial_state = $p->initial_state;
my $expected_initial_state = {
    'description_html' => undef,
    'open_states_list' => 'new,open',
    'open_states'      => 'new/f17  # You can add comments here
open/aaa # if you want to.',
    'permalink'                 => undef,
    'default_assigned_user_id'  => undef,
    'default_milestone_id'      => undef,
    'created_at'                => undef,
    'send_changesets_to_events' => 'true',
    'public'                    => 'false',
    'open_tickets_count'        => '0',
    'closed_states'             => 'resolved/6A0 # You can customize colors
hold/EB0     # with 3 or 6 character hex codes
invalid/A30  # \'A30\' expands to \'AA3300\'',
    'name'               => undef,
    'license'            => undef,
    'description'        => undef,
    'archived'           => 'false',
    'updated_at'         => undef,
    'closed_states_list' => 'resolved,hold,invalid',
    'hidden'             => 'false'
};

is_deeply( $initial_state, $expected_initial_state, 'initial state' );


# test tickets
$Mock_response->mock(
    content => sub {
        local $/;
        open my $fh, '<', 't/data/bins.xml' or die $!;
        <$fh>
    }
);

my @bins = $p->ticket_bins;
is( scalar @bins, 3, 'found tickets' );
isa_ok( $bins[0], 'Net::Lighthouse::Project::TicketBin' );
is( $bins[0]->id, 48889, 'bin id' );

for my $method (qw/milestones messages changesets tickets/) {
    $Mock_response->mock(
        content => sub {
            local $/;
            open my $fh, '<', "t/data/$method.xml" or die $!;
            <$fh>;
        }
    );
    my @list = $p->$method;
    ok( scalar @list, 'found list' );

    my $class = ucfirst $method;
    $class =~ s/s$//;
    isa_ok( $list[0], "Net::Lighthouse::Project::$class" );
}
