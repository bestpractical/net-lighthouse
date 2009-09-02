package Net::Lighthouse::Project::Ticket::Version;
use Any::Moose;
use XML::Simple;
use Params::Validate ':all';
use Net::Lighthouse::Util;

# read only attr
has [qw/created_at updated_at/] => (
    isa => 'DateTime',
    is  => 'ro',
);

has [
    qw/milestone_id assigned_user_id number user_id
      project_id creator_id attachments_count/
  ] => (
    isa => 'Maybe[Int]',
    is  => 'ro',
  );

has [qw/closed/] => (
    isa => 'Bool',
    is  => 'ro',
);

has [qw/diffable_attributes/] => (
    isa => 'HashRef',
    is  => 'ro',
);

has [
    'assigned_user_name', 'body',
    'body_html',          'permalink',
    'state',              'tag',
    'title',              'user_id',
    'user_name',          'creator_name',
    'url', 'milestone_title',
  ] => (
    isa => 'Maybe[Str]',
    is  => 'ro',
  );

no Any::Moose;
__PACKAGE__->meta->make_immutable;

sub load_from_xml {
    my $self = shift;
    my $ref = Net::Lighthouse::Util->translate_from_xml(shift);

    # dirty hack: some attrs are read-only, and Mouse doesn't support
    # writer => '...'
    for my $k ( keys %$ref ) {
        $self->{$k} = $ref->{$k};
    }
    return $self;
}

1;

__END__

=head1 NAME

Net::Lighthouse::Project::Ticket::Version - 

=head1 SYNOPSIS

    use Net::Lighthouse::Project::Ticket::Version;

=head1 DESCRIPTION


=head1 INTERFACE


=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

