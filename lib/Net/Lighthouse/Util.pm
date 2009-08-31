use strict;
use warnings;

package Net::Lighthouse::Util;
use XML::Simple;
use DateTime;
use YAML::Syck;

sub translate_from_xml {
    my $class = shift;
    my $ref = shift;
    $ref = XMLin( $ref, KeyAttr => [] ) unless ref $ref;
    %$ref = map { my $new = $_; $new =~ s/-/_/g; $new => $ref->{$_} } keys %$ref;
    for my $k ( keys %$ref ) {
        if ( ref $ref->{$k} eq 'HASH' ) {
            if ( $ref->{$k}{nil} && $ref->{$k}{nil} eq 'true' ) {
                $ref->{$k} = undef;
            }
            elsif ( $ref->{$k}{type} && $ref->{$k}{type} eq 'boolean' ) {
                if ( $ref->{$k}{content} eq 'true' ) {
                    $ref->{$k} = 1;
                }
                else {
                    $ref->{$k} = 0;
                }
            }
            elsif ( $ref->{$k}{type} && $ref->{$k}{type} eq 'datetime' ) {
                    $ref->{$k} =
                      $class->datetime_from_string( $ref->{$k}{content} );
            }
            elsif ( $ref->{$k}{type} && $ref->{$k}{type} eq 'yaml' ) {
                    $ref->{$k} = Load( $ref->{$k}{content} );
            }
            elsif ( $ref->{$k}{type} && $ref->{$k}{type} eq 'integer' ) {
                    $ref->{$k} =
                      defined $ref->{$k}{content} ? $ref->{$k}{content} : undef;
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

sub datetime_from_string {
    my $class  = shift;
    my $string = shift;
    if (   $string
        && $string =~ /(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})Z/ )
    {

        #    2009-06-01T13:00:10Z
        return DateTime->new(
            year      => $1,
            month     => $2,
            day       => $3,
            hour      => $4,
            minute    => $5,
            second    => $6,
            time_zone => 'UTC',
        );
    }
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

