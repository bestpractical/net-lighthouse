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

sub load {
    my $self = shift;
    validate_pos( @_, { type => SCALAR, regex => qr/^\d+$/ } );
    my $id = shift;
    my $ua = $self->ua;
    my $url =
        $self->base_url
      . '/projects/'
      . $self->project_id . '/messages/'
      . $id . '.xml';
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
        if ( $k eq 'comments' ) {
            # if has parent_id, then it's comment, comment can't have comments
            if ( $ref->{parent_id} ) {
                delete $ref->{comments};
                next;
            }

            if ( $ref->{comments} ) {
                my $comments = $ref->{comments}{comment};
                $ref->{comments} = [
                    map {
                        my $v = Net::Lighthouse::Project::Message->new;
                        $v->load_from_xml($_)
                      } @$comments
                ];
            }
            else {
                $ref->{comments} = [];
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
            title => { type     => SCALAR },
            body  => { type     => SCALAR },
        }
    );
    my %args = @_;

    for my $field (qw/title body/) {
        next unless exists $args{$field};
        $args{$field} = { content => $args{$field} };
    }

    my $xml = XMLout( { message => \%args }, KeepRoot => 1);
    my $ua = $self->ua;

    my $url = $self->base_url . '/projects/' . $self->project_id . '/messages.xml';

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

sub create_comment {
    my $self = shift;
    validate(
        @_,
        {
            body  => { type     => SCALAR },
        }
    );
    my %args = @_;

    for my $field (qw/body/) {
        next unless exists $args{$field};
        $args{$field} = { content => $args{$field} };
    }

    # doc says <message>, but it doesn't work actually.
    # comment can work, though still with a problem
    my $xml = XMLout( { comment => \%args }, KeepRoot => 1);
    my $ua = $self->ua;

    my $url =
        $self->base_url
      . '/projects/'
      . $self->project_id
      . '/messages/'
      . $self->id
      . '/comments.xml';

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
        }
    );
    my %args = @_;

    for my $field (qw/title body/) {
        next unless exists $args{$field};
        $args{$field} = { content => $args{$field} };
    }

    my $xml = XMLout( { message => \%args }, KeepRoot => 1);
    my $ua = $self->ua;
    my $url =
        $self->base_url
      . '/projects/'
      . $self->project_id . '/messages/'
      . $self->id . '.xml';

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
    my $url =
        $self->base_url
      . '/projects/'
      . $self->project_id . '/messages/'
      . $self->id . '.xml';

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
    my $url =
      $self->base_url . '/projects/' . $self->project_id . '/messages.xml';

    my $ua  = $self->ua;
    my $res = $ua->get($url);
    if ( $res->is_success ) {
        my $ts = XMLin( $res->content, KeyAttr => [] )->{message};
        $ts = [ $ts ] unless ref $ts eq 'ARRAY';
        return map {
            my $t = Net::Lighthouse::Project::Message->new(
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
      $self->base_url . '/projects/' . $self->project_id . '/messages/new.xml';
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

