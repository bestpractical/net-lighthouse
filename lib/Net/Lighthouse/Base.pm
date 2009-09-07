package Net::Lighthouse::Base;

use Any::Moose;
use MIME::Base64;
use LWP::UserAgent;

has 'account' => (
    isa => 'Str',
    is  => 'ro',
);

has 'auth' => (
    isa     => 'HashRef',
    is      => 'rw',
    default => sub { {} },
    lazy    => 1,
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
    my $auth = $self->auth;
    if ( $auth->{email} && $auth->{password} ) {
        my $base64 = encode_base64( $auth->{email} . ':' . $auth->{password} );
        chomp $base64;
        $ua->default_header( Authorization => 'Basic ' . $base64 );
    }
    elsif ( $auth->{token} ) {
        $ua->default_header( 'X-LighthouseToken', $auth->{token} );
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

