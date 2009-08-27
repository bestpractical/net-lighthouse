package Net::Lighthouse::Project::Milestone;
use Any::Moose;
use XML::Simple;
use Params::Validate ':all';
use Net::Lighthouse::Util;
extends 'Net::Lighthouse';
# read only attr
has [
    'open_tickets_count', 'created_at',
    'goals_html',            'user_name',
    'permalink',             'project_id',
    'tickets_count',      'url',
    'updated_at',            'id',
  ] => (
    isa => 'Maybe[Str]',
    is  => 'ro',
  );

# read&write attr
has [qw/title goals due_on/] => (
    isa => 'Maybe[Str]',
    is  => 'rw',
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;


1;

__END__

=head1 NAME

Net::Lighthouse::Project::Milestone - 

=head1 SYNOPSIS

    use Net::Lighthouse::Project::Milestone;

=head1 DESCRIPTION


=head1 INTERFACE


=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

