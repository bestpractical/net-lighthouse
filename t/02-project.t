use strict;
use warnings;

use Test::More tests => 25;

use_ok( 'Net::Lighthouse::Project' );
can_ok( 'Net::Lighthouse::Project', 'new' );
my $project = Net::Lighthouse::Project->new;
isa_ok( $project, 'Net::Lighthouse::Project' );
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

