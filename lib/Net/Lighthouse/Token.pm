package Net::Lighthouse::Token;
use Any::Moose;
use XML::Simple;
use Params::Validate ':all';

# read only attr
has [
    'project_id', 'account',   'user_id', 'created_at',
    'token',      'read_only', 'note'
  ] => (
    isa => 'Maybe[Str]',
    is  => 'ro',
  );

no Any::Moose;
__PACKAGE__->meta->make_immutable;

sub load_from_xml {
    my $self = shift;
    validate_pos( @_,
        { type => SCALAR | HASHREF, regex => qr/^\s*<token|^HASH\(\w+\)$/ } );
    my $ref = $self->_translate_from_xml(shift);

    # dirty hack: some attrs are read-only, and Mouse doesn't support
    # writer => '...'
    for my $k ( keys %$ref ) {
        $self->{$k} = $ref->{$k};
    }
    return $self;
}

sub _translate_from_xml {
    my $self = shift;
    validate_pos( @_,
        { type => SCALAR | HASHREF, regex => qr/^\s*<token|^HASH\(\w+\)$/ } );
    my $ref = shift;
    $ref = XMLin($ref) unless ref $ref;
    %$ref = map { my $new = $_; $new =~ s/-/_/g; $new => $ref->{$_} } keys %$ref;

    for my $k ( keys %$ref ) {
        if ( ref $ref->{$k} eq 'HASH' ) {
            if ( $ref->{$k}{nil} && $ref->{$k}{nil} eq 'true' ) {
                $ref->{$k} = undef;
            }
            elsif ( defined $ref->{$k}{content} ) {
                $ref->{$k} = $ref->{$k}{content};
            }
            elsif ( keys %{ $ref->{$k} } == 0
                || keys %{ $ref->{$k} } == 1 && exists $ref->{$k}{type} )
            {
                $ref->{$k} = '';
            }
            else {
                warn 'no idea how to handle ' . $ref->{$k};
            }
        }
    }
    return $ref;
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

