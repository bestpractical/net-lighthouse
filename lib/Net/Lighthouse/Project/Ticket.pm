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

sub load {
    my $self = shift;
    validate_pos( @_, { type => SCALAR, regex => qr/^\d+$/ } );
    my $number = shift;
    my $ua = $self->ua;
    my $url =
        $self->base_url
      . '/projects/'
      . $self->project_id . '/'
      . $number . '.xml';
    my $res = $ua->get( $url );
    if ( $res->is_success ) {
        $self->load_from_xml( $res->content );
    }
    else {
        die "try to get $url failed: "
          . $res->status_line . "\n"
          . $res->content;
    }
}

sub load_from_xml {
    my $self = shift;
    validate_pos( @_,
        { type => SCALAR | HASHREF, regex => qr/^<\?xml|^HASH\(\w+\)$/ } );
    my $ref = $self->_translate_from_xml( shift );

    # dirty hack: some attrs are read-only, and Mouse doesn't support
    # writer => '...'
    for my $k ( keys %$ref ) {
        $self->{$k} = $ref->{$k};
    }
    return $self;
}

sub _translate_from_xml {
    my $self = shift;
    validate_pos( @_,
        { type => SCALAR | HASHREF, regex => qr/^<\?xml|^HASH\(\w+\)$/ } );
    my $ref = shift;
    $ref = XMLin( $ref ) unless ref $ref;
    %$ref = map { my $old = $_; s/-/_/g; $_ => $ref->{$old} } keys %$ref;
    if ( $ref->{versions} ) {
        # TODO: need Ticket::Version object
        delete $ref->{versions};
    }

    if ( $ref->{attachments} ) {
        # TODO: need Ticket::Attachment object
        delete $ref->{attachments};
    }

    for my $k ( keys %$ref ) {
        if ( ref $ref->{$k} eq 'HASH' ) {
            if ( $ref->{$k}{nil} && $ref->{$k}{nil} eq 'true' ) {
                $ref->{$k} = undef;
            }
            elsif ( defined $ref->{$k}{content} ) {
                $ref->{$k} = $ref->{$k}{content};
            }
            elsif ( keys %{$ref->{$k}} == 0 ) {
                $ref->{$k} = '';
            }
            else {
                warn 'no idea how to handle ' . $ref->{$k};
            }
        }
    }
    return $ref;
}


sub list {
    my $self = shift;
    my $ua = $self->ua;
    my $url =
      $self->base_url . '/projects/' . $self->project_id . '/tickets.xml';
    my $res = $ua->get( $url );
    if ( $res->is_success ) {
        my $ts = XMLin( $res->content, KeyAttr => [] )->{ticket};
        return map {
            my $t = Net::Lighthouse::Project::Ticket->new(
                map { $_ => $self->$_ }
                  grep { $self->$_ } qw/account email password token project_id/
            );
            $t->load_from_xml($_);
        } @$ts;
    }
    else {
        die "try to get $url failed: "
          . $res->status_line . "\n"
          . $res->content;
    }

}

sub initial_state {
    my $self = shift;
    my $ua = $self->ua;
    my $url = $self->base_url . '/projects/' . $self->project_id . '/new.xml';
    my $res = $ua->get( $url );
    if ( $res->is_success ) {
        return $self->_translate_from_xml( $res->content );
    }
    else {
        die "try to get $url failed: "
          . $res->status_line . "\n"
          . $res->content;
    }
}

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

