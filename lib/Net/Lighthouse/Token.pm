package Net::Lighthouse::Token;
use Any::Moose;
use XML::Simple;
use Params::Validate ':all';
use Net::Lighthouse::Util;

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

