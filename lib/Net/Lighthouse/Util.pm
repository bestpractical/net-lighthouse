use strict;
use warnings;

package Net::Lighthouse::Util;
use XML::Simple;

sub translate_from_xml {
    my $self = shift;
    my $ref = shift;
    $ref = XMLin( $ref, KeyAttr => [] ) unless ref $ref;
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
        }
    }
    return $ref;
}

1;

__END__

=head1 NAME

Net::Lighthouse::Util - 

=head1 SYNOPSIS

    use Net::Lighthouse::Util;

=head1 DESCRIPTION


=head1 INTERFACE


=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

