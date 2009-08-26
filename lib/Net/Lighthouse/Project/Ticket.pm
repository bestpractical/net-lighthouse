package Net::Lighthouse::Project::Ticket;
use Any::Moose;
use XML::Simple;
use Params::Validate ':all';
extends 'Net::Lighthouse';
# read only attr
has [
    'priority',          'raw_data',
    'number',            'milestone_due_on',
    'created_at',        'user_name',
    'state',             'permalink',
    'versions',          'url',
    'updated_at',        'closed',
    'attachments',       'latest_body',
    'user_id',           'project_id',
    'attachments_count', 'creator_id',
    'creator_name',      'assigned_user_name',
  ] => (
    isa => 'Maybe[Str]',
    is  => 'ro',
  );

# read&write attr
has [qw/title state assigned_user_id milestone_id tag/] => (
    isa => 'Maybe[Str]',
    is  => 'rw',
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;


1;

__END__

=head1 NAME

Net::Lighthouse::Project::Ticket - 

=head1 SYNOPSIS

    use Net::Lighthouse::Project::Ticket;

=head1 DESCRIPTION


=head1 INTERFACE


=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

