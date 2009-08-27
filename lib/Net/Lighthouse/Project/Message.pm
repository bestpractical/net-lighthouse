package Net::Lighthouse::Project::Message;
use Any::Moose;
use XML::Simple;
use Params::Validate ':all';
use Net::Lighthouse::Util;
extends 'Net::Lighthouse';
# read only attr
has [
    'created_at',     'body_html',
    'user_name',      'permalink',
    'comments_count', 'parent_id',
    'url',            'updated_at',
    'id',             'user_id',
    'project_id',     'all_attachments_count',
    'attachments_count',
  ] => (
    isa => 'Maybe[Str]',
    is  => 'ro',
  );

has 'comments' => (
    isa => 'ArrayRef[Net::Lighthouse::Project::Message]',
    is  => 'ro',
);

# read&write attr
has [qw/title body/] => (
    isa => 'Maybe[Str]',
    is  => 'rw',
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;


1;

__END__

=head1 NAME

Net::Lighthouse::Project::Message - 

=head1 SYNOPSIS

    use Net::Lighthouse::Project::Message;

=head1 DESCRIPTION


=head1 INTERFACE


=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

