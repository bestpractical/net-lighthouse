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

sub load {
    my $self = shift;
    validate_pos( @_, { type => SCALAR, regex => qr/^\d+$/ } );
    my $id = shift;
    my $ua = $self->ua;
    my $url =
        $self->base_url
      . '/projects/'
      . $self->project_id . '/milestones/'
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
    my $ref = Net::Lighthouse::Util->translate_from_xml( shift );

    # dirty hack: some attrs are read-only, and Mouse doesn't support
    # writer => '...'
    for my $k ( keys %$ref ) {
        $self->{$k} = $ref->{$k};
    }
    return $self;
}

sub create {
    my $self = shift;
    validate(
        @_,
        {
            goals  => { type     => SCALAR },
            title  => { type     => SCALAR },
            due_on => { optional => 1, type => SCALAR },
        }
    );
    my %args = @_;

    for my $field (qw/goals title due_on/) {
        next unless exists $args{$field};
        $args{$field} = { content => $args{$field} };
    }

    my $xml = XMLout( { milestone => \%args }, KeepRoot => 1);
    my $ua = $self->ua;

    my $url = $self->base_url . '/projects/' . $self->project_id . '/milestones.xml';

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
            goals  => { optional => 1, type     => SCALAR },
            title  => { optional => 1, type     => SCALAR },
            due_on => { optional => 1, type => SCALAR },
        }
    );
    my %args = @_;

    for my $field (qw/goals title due_on/) {
        next unless exists $args{$field};
        $args{$field} = { content => $args{$field} };
    }

    my $xml = XMLout( { milestone => \%args }, KeepRoot => 1);
    my $ua = $self->ua;
    my $url =
        $self->base_url
      . '/projects/'
      . $self->project_id . '/milestones/'
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
      . $self->project_id . '/milestones/'
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
      $self->base_url . '/projects/' . $self->project_id . '/milestones.xml';
    my $ua  = $self->ua;
    my $res = $ua->get($url);
    if ( $res->is_success ) {
        my $ts = XMLin( $res->content, KeyAttr => [] )->{milestone};
        $ts = [ $ts ] unless ref $ts eq 'ARRAY';
        return map {
            my $t = Net::Lighthouse::Project::Milestone->new(
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
      $self->base_url . '/projects/' . $self->project_id . '/milestones/new.xml';
    my $res = $ua->get( $url );
    if ( $res->is_success ) {
        return Net::Lighthouse::Util->translate_from_xml( $res->content );
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

