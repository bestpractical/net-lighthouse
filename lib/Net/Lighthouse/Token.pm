package Net::Lighthouse::Token;
use Any::Moose;
use Params::Validate ':all';
use Net::Lighthouse::Util;
use base 'Net::Lighthouse';

# read only attr
has 'created_at' => (
    isa => 'DateTime',
    is  => 'ro',
);

has 'user_id' => (
    isa => 'Int',
    is  => 'ro',
);

has 'project_id' => (
    isa => 'Maybe[Int]',
    is  => 'ro',
);

has 'read_only' => (
    isa => 'Bool',
    is  => 'ro',
);

has 'token' => (
    isa => 'Str',
    is  => 'ro',
);

has [ 'account', 'note' ] => (
    isa => 'Maybe[Str]',
    is  => 'ro',
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

sub load {
    my $self = shift;
    validate_pos( @_, { type => SCALAR, regex => qr/^\w{40}$/ } );
    my $token = shift;

    my $ua = $self->ua;
    my $url = $self->base_url . '/tokens/' . $token . '.xml';
    my $res = $ua->get( $url );
    if ( $res->is_success ) {
        $self->load_from_xml( $res->content );
    }
    else {
        die "try to get $url failed: "
          . $res->status_line . "\n"
          . $res->content;
    }
}

sub load_from_xml {
    my $self = shift;
    my $ref = Net::Lighthouse::Util->translate_from_xml(shift);

    # dirty hack: some attrs are read-only, and Mouse doesn't support
    # writer => '...'
    for my $k ( keys %$ref ) {
        $self->{$k} = $ref->{$k};
    }
    return $self;
}

1;

__END__

=head1 NAME

Net::Lighthouse::Token - 

=head1 SYNOPSIS

    use Net::Lighthouse::Token;

=head1 DESCRIPTION


=head1 INTERFACE


=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

