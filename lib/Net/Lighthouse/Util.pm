use strict;
use warnings;

package Net::Lighthouse::Util;
use DateTime;
use XML::Simple;

BEGIN {
    local $@;
    eval { require YAML::Syck; };
    if ($@) {
        require YAML;
        *_Load     = *YAML::Load;
    }
    else {
        *_Load     = *YAML::Syck::Load;
    }
}

sub read_xml {
    my $self = shift;
    return XMLin( @_, KeyAttr => [] );
}

sub write_xml {
    my $self = shift;
    return XMLout( @_, KeepRoot => 1 );
}


sub translate_from_xml {
    my $class = shift;
    my $ref = shift;
    return unless $ref;
    $ref = Net::Lighthouse::Util->read_xml( $ref ) unless ref $ref;
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
                    $ref->{$k} = _Load( $ref->{$k}{content} );
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
        && $string =~
        /(\d{4})-(\d{2})-(\d{2})T(\d{2}):(\d{2}):(\d{2})(Z|[+-]\d{2}:\d{2})/ )
    {

        #    2009-06-01T13:00:10Z
        my $dt = DateTime->new(
            year      => $1,
            month     => $2,
            day       => $3,
            hour      => $4,
            minute    => $5,
            second    => $6,
            time_zone => $7 eq 'Z' ? 'UTC' : $7,
        );
        $dt->set_time_zone( 'UTC' );
    }
}

1;

__END__

=head1 NAME

Net::Lighthouse::Util - Util

=head1 SYNOPSIS

    use Net::Lighthouse::Util;

=head1 DESCRIPTION

utility methods live here

=head1 INTERFACE

=over 4

=item translate_from_xml( $hashref | $xml_string )

translate from xml, the general translation map is:
'foo-bar' => 'foo_bar',
value bool false | true => 0 | 1,
value yaml string => object
value datetime string => L<DateTime> object

=item datetime_from_string

parse string to a L<DateTime> object, and translate its timezone to UTC

=back

=head1 SEE ALSO

L<DateTime>, L<YAML::Syck>

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

