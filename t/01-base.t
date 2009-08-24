use strict;
use warnings;

use Test::More tests => 7;

use_ok('Net::Lighthouse');
can_ok( 'Net::Lighthouse', 'new' );
my $lh = Net::Lighthouse->new;
isa_ok( $lh, 'Net::Lighthouse' );
for (qw/account email password token/) {
    can_ok( $lh, $_ );
}

