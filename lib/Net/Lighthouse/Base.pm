package Net::Lighthouse::Base;

use Any::Moose;
use MIME::Base64;
use LWP::UserAgent;

has 'account' => (
    isa => 'Str',
    is  => 'ro',
);

has [ 'email', 'password', 'token' ] => (
    isa => 'Str',
    is  => 'rw',
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

sub base_url {
    my $self = shift;
    return 'http://' . $self->account . '.lighthouseapp.com';
}

sub ua {
    my $self = shift;
    require Net::Lighthouse;
    my $ua =
      LWP::UserAgent->new(
        agent => 'net-lighthouse/' . $Net::Lighthouse::VERSION );
    $ua->default_header( 'Content-Type' => 'application/xml' );
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

Net::Lighthouse::Base - Base class

=head1 SYNOPSIS

    use Net::Lighthouse::Base;

=head1 DESCRIPTION


=head1 INTERFACE


=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

