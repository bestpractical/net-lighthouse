package Net::Lighthouse::User::Membership;
use Any::Moose;
use XML::Simple;
use Params::Validate ':all';

# read only attr
has [qw/id user_id account project/] => (
    isa => 'Maybe[Str]',
    is  => 'ro',
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;


1;

__END__

=head1 NAME

Net::Lighthouse::User::Membership - 

=head1 SYNOPSIS

    use Net::Lighthouse::User::Membership;

=head1 DESCRIPTION


=head1 INTERFACE


=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

