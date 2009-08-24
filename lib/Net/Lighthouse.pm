package Net::Lighthouse;

use Moose;
use MooseX::ClassAttribute;
use MIME::Base64;
use LWP::UserAgent;

our $VERSION = '0.01';
class_has ['account', 'email', 'password', 'token'] => (
    isa      => 'Str',
    is       => 'rw',
);

no Moose;
no MooseX::ClassAttribute;
__PACKAGE__->meta->make_immutable;

sub base_url {
    my $self = shift;
    return 'http://' . $self->account . '.lighthouseapp.com';
}

sub ua {
    my $self = shift;
    my $ua = LWP::UserAgent->new( agent => 'net-lighthouse/' . $VERSION );

    # email and password have high priority
    if ( $self->email && $self->password ) {
        my $base64 = encode_base64( $self->email . ':' . $self->password );
        chomp $base64;
        $ua->default_header( Authorization => 'Basic ' . $base64 );
    }
    elsif ( $self->token ) {
        $ua->default_header( 'X-LighthouseToken', $self->token );
    }

    return $ua;
}

1;

__END__

=head1 NAME

Net::Lighthouse - 


=head1 VERSION

This document describes Net::Lighthouse version 0.01


=head1 SYNOPSIS

    use Net::Lighthouse;

=head1 DESCRIPTION


=head1 INTERFACE



=head1 DEPENDENCIES


None.


=head1 INCOMPATIBILITIES

None reported.


=head1 BUGS AND LIMITATIONS

No bugs have been reported.

=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

