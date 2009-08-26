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

