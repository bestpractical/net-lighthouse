package Net::Lighthouse::Project;
use Any::Moose;
use XML::Simple;
use Params::Validate ':all';
extends 'Net::Lighthouse';
# read only attr
has [
    qw/created_at default_assigned_user_id default_milestone_id description
      description_html hidden id open_tickets_count permalink
      send_changesets_to_events updated_at open_states_list closed_states_list
      open_states closed_states access license/
  ] => (
    isa => 'Maybe[Str]',
    is  => 'ro',
  );

# read&write attr
has [qw/archived name public/] => (
    isa => 'Maybe[Str]',
    is  => 'rw',
);

no Any::Moose;
__PACKAGE__->meta->make_immutable;

sub load {
    my $self = shift;
    validate_pos( @_, { type => SCALAR, regex => qr/^\d+$/ } );
    my $id = shift;
    my $ua = $self->ua;
    my $url = $self->base_url . '/projects/' . $id . '.xml';
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
    validate_pos( @_, { type => SCALAR | HASHREF, regex => qr/^<\?xml|HASH/ } );
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
    validate_pos( @_, { type => SCALAR | HASHREF, regex => qr/^<\?xml|HASH/ } );
    my $ref = shift;
    $ref = XMLin( $ref ) unless ref $ref;
    %$ref = map { my $old = $_; s/-/_/g; $_ => $ref->{$old} } keys %$ref;
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

sub create {
    my $self = shift;
    validate(
        @_,
        {
            archived => { optional => 1, type => BOOLEAN },
            name     => { optional => 1, type => SCALAR },
            public   => { optional => 1, type => BOOLEAN },
        }
    );
    my %args = @_;

    if ( defined $args{name} ) {
        $args{name} = { content => $args{name} };
    }

    for my $bool (qw/archived public/) {
        next unless exists $args{$bool};
        if ( $args{$bool} ) {
            $args{$bool} = { content => 'true', type => 'boolean' };
        }
        else {
            $args{$bool} = { content => 'false', type => 'boolean' };
        }
    }

    my $xml = XMLout( { project => \%args }, KeepRoot => 1);
    my $ua = $self->ua;

    my $url = $self->base_url . '/projects.xml';

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
            archived => { optional => 1, type => BOOLEAN },
            name     => { optional => 1, type => SCALAR },
            public   => { optional => 1, type => BOOLEAN },
        }
    );
    my %args = @_;

    if ( defined $args{name} ) {
        $args{name} = { content => $args{name} };
    }

    for my $bool (qw/archived public/) {
        next unless exists $args{$bool};
        if ( $args{$bool} ) {
            $args{$bool} = { content => 'true', type => 'boolean' };
        }
        else {
            $args{$bool} = { content => 'false', type => 'boolean' };
        }
    }

    my $xml = XMLout( { project => \%args }, KeepRoot => 1);
    my $ua = $self->ua;
    my $url = $self->base_url . '/projects/' . $self->id . '.xml';

    my $request = HTTP::Request->new( 'PUT', $url, undef, $xml );
    my $res = $ua->request( $request );
    if ( $res->is_success ) {
        $self->load( $self->id ); # let's reload
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
    my $url = $self->base_url . '/projects/' . $self->id . '.xml';

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
    my $ua = $self->ua;
    my $url = $self->base_url . '/projects.xml';
    my $res = $ua->get( $url );
    if ( $res->is_success ) {
        my $ps = XMLin( $res->content, KeyAttr => [] )->{project};
        return map {
            my $p = Net::Lighthouse::Project->new(
                map { $_ => $self->$_ }
                  grep { $self->$_ } qw/account email password token/
            );
            $p->load_from_xml($_);
        } @$ps;
    }
    else {
        die "try to get $url failed: "
          . $res->status_line . "\n"
          . $res->content;
    }

}

sub tickets {
    my $self = shift;
}

1;

__END__

=head1 NAME

Net::Lighthouse::Project - 

=head1 SYNOPSIS

    use Net::Lighthouse::Project;

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

