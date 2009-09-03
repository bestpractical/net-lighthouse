package Net::Lighthouse::Project::Ticket;
use Any::Moose;
use XML::Simple;
use Params::Validate ':all';
use Net::Lighthouse::Util;
extends 'Net::Lighthouse';
# read only attr
has [qw/created_at updated_at milestone_due_on/] => (
    isa => 'Maybe[DateTime]',
    is  => 'ro',
);

has [qw/number priority user_id project_id creator_id attachments_count/] => (
    isa => 'Maybe[Int]',
    is  => 'ro',
);

has [qw/closed /] => (
    isa => 'Bool',
    is  => 'ro',
);

has [
    'raw_data',     'user_name',
    'state',        'permalink',
    'url',          'latest_body',
    'creator_name', 'assigned_user_name',
    'milestone_title',
  ] => (
    isa => 'Maybe[Str]',
    is  => 'ro',
  );

has 'attachments' => (
    isa => 'ArrayRef[Net::Lighthouse::Project::Ticket::Attachment]',
    is  => 'ro',
);

has 'versions' => (
    isa => 'ArrayRef[Net::Lighthouse::Project::Ticket::Version]',
    is  => 'ro',
);

# read&write attr
has [qw/assigned_user_id milestone_id/] => (
    isa => 'Maybe[Int]',
    is  => 'rw',
);

has [qw/title state tag/] => (
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
      . $self->project_id . '/tickets/'
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
    my $ref = Net::Lighthouse::Util->translate_from_xml( shift );
    for my $k ( keys %$ref ) {
        if ( $k eq 'versions' ) {
            my $versions = $ref->{versions}{version};
            $versions = [ $versions ] unless ref $versions eq 'ARRAY';
            require Net::Lighthouse::Project::Ticket::Version;
            $ref->{versions} = [
                map {
                    my $v = Net::Lighthouse::Project::Ticket::Version->new;
                    $v->load_from_xml($_)
                  } @$versions
            ];
        }
        elsif ( $k eq 'attachments' ) {
            my @attachments;
            for ( keys %{$ref->{attachments}} ) {
                my $att = $ref->{attachments}{$_};
                next unless ref $att;
                if ( ref $att eq 'ARRAY' ) {
                    push @attachments, @{$att};
                }
                else {
                    push @attachments, $att;
                }
            }
            next unless @attachments;

            require Net::Lighthouse::Project::Ticket::Attachment;
            $ref->{attachments} = [
                map {
                    my $v =
                      Net::Lighthouse::Project::Ticket::Attachment->new(
                        ua => $self->ua );
                    $v->load_from_xml($_)
                  } @attachments
            ];
        }
    }
    return $ref;
}

sub create {
    my $self = shift;
    validate(
        @_,
        {
            title => { type     => SCALAR },
            body  => { type     => SCALAR },
            state => { optional => 1, type => SCALAR },
            assigned_user_id => {
                optional => 1,
                type     => SCALAR | UNDEF,
                regex    => qr/^(\d+|)$/,
            },
            milestone_id => {
                optional => 1,
                type     => SCALAR | UNDEF,
                regex    => qr/^(\d+|)$/,
            },
            tag => { optional => 1, type => SCALAR },
        }
    );
    my %args = @_;

    for my $field (qw/title body state assigned_user_id milestone_id tag/) {
        next unless exists $args{$field};
        $args{$field} = { content => $args{$field} };
    }

    my $xml = XMLout( { ticket => \%args }, KeepRoot => 1);
    my $ua = $self->ua;

    my $url = $self->base_url . '/projects/' . $self->project_id . '/tickets.xml';

    my $request = HTTP::Request->new( 'POST', $url, undef, $xml );
    my $res = $ua->request( $request );
    if ( $res->is_success ) {
        $self->load_from_xml( $res->content );
        return 1;
    }
    else {
        die "try to POST $url failed: "
          . $res->status_line . "\n"
          . $res->content;
    }
}

sub update {
    my $self = shift;
    validate(
        @_,
        {
            title => { optional => 1, type     => SCALAR },
            body  => { optional => 1, type     => SCALAR },
            state => { optional => 1, type => SCALAR },
            assigned_user_id => {
                optional => 1,
                type     => SCALAR | UNDEF,
                regex    => qr/^(\d+|)$/,
            },
            milestone_id => {
                optional => 1,
                type     => SCALAR | UNDEF,
                regex    => qr/^(\d+|)$/,
            },
            tag => { optional => 1, type => SCALAR },
        }
    );
    my %args = @_;

    for my $field (qw/title body state assigned_user_id milestone_id tag/) {
        next unless exists $args{$field};
        $args{$field} = { content => $args{$field} };
    }

    my $xml = XMLout( { ticket => \%args }, KeepRoot => 1);
    my $ua = $self->ua;
    my $url =
        $self->base_url
      . '/projects/'
      . $self->project_id . '/tickets/'
      . $self->number . '.xml';

    my $request = HTTP::Request->new( 'PUT', $url, undef, $xml );
    my $res = $ua->request( $request );
    if ( $res->is_success ) {
        $self->load( $self->number ); # let's reload
        return 1;
    }
    else {
        die "try to PUT $url failed: "
          . $res->status_line . "\n"
          . $res->content;
    }
}

sub delete {
    my $self = shift;
    my $ua = $self->ua;
    my $url =
        $self->base_url
      . '/projects/'
      . $self->project_id . '/tickets/'
      . $self->number . '.xml';

    my $request = HTTP::Request->new( 'DELETE', $url );
    my $res = $ua->request( $request );
    if ( $res->is_success ) {
        return 1;
    }
    else {
        die "try to DELETE $url failed: "
          . $res->status_line . "\n"
          . $res->content;
    }
}

sub list {
    my $self = shift;
    validate(
        @_,
        {
            query => { optional => 1, type => SCALAR },
            page  => { optional => 1, type => SCALAR, regex => qr/^\d+$/ },
        }
    );
    my %args = @_;

    my $url =
      $self->base_url . '/projects/' . $self->project_id . '/tickets.xml?';
    if ( $args{query} ) {
        require URI::Escape;
        $url .= 'q=' . URI::Escape::uri_escape( $args{query} ) . '&';
    }
    if ( $args{page} ) {
        $url .= 'page=' . uri_escape( $args{page} );
    }

    my $ua  = $self->ua;
    my $res = $ua->get($url);
    if ( $res->is_success ) {
        my $ts = XMLin( $res->content, KeyAttr => [] )->{ticket};
        $ts = [ $ts ] unless ref $ts eq 'ARRAY';
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
    my $url =
      $self->base_url . '/projects/' . $self->project_id . '/tickets/new.xml';
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

