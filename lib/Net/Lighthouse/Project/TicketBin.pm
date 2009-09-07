package Net::Lighthouse::Project::TicketBin;
use Any::Moose;
use XML::Simple;
use Params::Validate ':all';
use Net::Lighthouse::Util;
extends 'Net::Lighthouse::Base';

# read only attr
has 'updated_at' => (
    isa => 'DateTime',
    is  => 'ro',
);

has [ 'user_id', 'position', 'project_id', 'tickets_count', 'id' ] => (
    isa => 'Int',
    is  => 'ro',
);

has 'shared' => (
    isa => 'Bool',
    is  => 'ro',
);

# read&write attr
has 'default' => (
    isa => 'Bool',
    is  => 'rw',
);

has [qw/name query/] => (
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
      . $self->project_id
      . '/bins/'
      . $id . '.xml';
    my $res = $ua->get($url);
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
    my $ref  = Net::Lighthouse::Util->translate_from_xml(shift);

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
            name    => { type     => SCALAR },
            query   => { type     => SCALAR },
            default => { optional => 1, type => BOOLEAN },
        }
    );
    my %args = @_;

    if ( exists $args{default} ) {
        if ( $args{default} ) {
            $args{default} = { content => 'true', type => 'boolean' };
        }
        else {
            $args{default} = { content => 'false', type => 'boolean' };
        }
    }
    

    for my $field (qw/name query/) {
        next unless exists $args{$field};
        $args{$field} = { content => $args{$field} };
    }

    my $xml = XMLout( { bin => \%args }, KeepRoot => 1 );
    my $ua = $self->ua;

    my $url = $self->base_url . '/projects/' . $self->project_id . '/bins.xml';

    my $request = HTTP::Request->new( 'POST', $url, undef, $xml );
    my $res = $ua->request($request);
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
            name    => { optional => 1, type     => SCALAR },
            query   => { optional => 1, type     => SCALAR },
            default => { optional => 1, type => BOOLEAN },
        }
    );
    my %args = @_;

    if ( exists $args{default} ) {
        if ( $args{default} ) {
            $args{default} = { content => 'true', type => 'boolean' };
        }
        else {
            $args{default} = { content => 'false', type => 'boolean' };
        }
    }

    for my $field (qw/name query/) {
        next unless exists $args{$field};
        $args{$field} = { content => $args{$field} };
    }

    my $xml = XMLout( { bin => \%args }, KeepRoot => 1 );
    my $ua = $self->ua;
    my $url =
        $self->base_url
      . '/projects/'
      . $self->project_id
      . '/bins/'
      . $self->id . '.xml';

    my $request = HTTP::Request->new( 'PUT', $url, undef, $xml );
    my $res = $ua->request($request);
    if ( $res->is_success ) {
        $self->load( $self->id );    # let's reload
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
    my $ua   = $self->ua;
    my $url =
        $self->base_url
      . '/projects/'
      . $self->project_id
      . '/bins/'
      . $self->id . '.xml';

    my $request = HTTP::Request->new( 'DELETE', $url );
    my $res = $ua->request($request);
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
    my $url  = $self->base_url . '/projects/' . $self->project_id . '/bins.xml';
    my $ua   = $self->ua;
    my $res  = $ua->get($url);
    if ( $res->is_success ) {
        my $ts = XMLin( $res->content, KeyAttr => [] )->{'ticket-bin'};
        $ts = [$ts] unless ref $ts eq 'ARRAY';
        return map {
            my $t = Net::Lighthouse::Project::TicketBin->new(
                map { $_ => $self->$_ }
                  grep { $self->$_ } qw/account auth project_id/
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

1;

__END__

=head1 NAME

Net::Lighthouse::Project::TicketBin - 

=head1 SYNOPSIS

    use Net::Lighthouse::Project::TicketBin;

=head1 DESCRIPTION


=head1 INTERFACE


=head1 AUTHOR

sunnavy  C<< <sunnavy@bestpractical.com> >>


=head1 LICENCE AND COPYRIGHT

Copyright 2009 Best Practical Solutions.

This program is free software; you can redistribute it and/or modify it
under the same terms as Perl itself.

