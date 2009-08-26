package Net::Lighthouse::User;
use Any::Moose;
use XML::Simple;
use Params::Validate ':all';
extends 'Net::Lighthouse';

# read only attr
has [qw/id avatar_url/] => (
    isa => 'Maybe[Str]',
    is  => 'ro',
);

# read&write attr
has [qw/name job website/] => (
    isa => 'Maybe[Str]',
    is  => 'rw',
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;


1;

__END__

=head1 NAME

Net::Lighthouse::User - 

=head1 SYNOPSIS

    use Net::Lighthouse::User;

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

