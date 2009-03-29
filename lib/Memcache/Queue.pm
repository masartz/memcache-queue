package Memcache::Queue;

use Moose;
use Memcache::Queue::Manager;
our $VERSION = '0.01';

has 'manager' => (
    is         => 'ro',
    isa        => 'Memcache::Queue::Manager',
    lazy_build => 1,
);

__PACKAGE__->meta->make_immutable;
no Moose;

use constant {
    SERVERS => ['localhost:11211' , 'localhost:11211'],
};

sub _build_manager{
    my $self = shift;

    Memcache::Queue::Manager->new(
        cache  => Cache::Memcached->new(
            {
                servers            => SERVERS,
                compress_threshold => 50_000,
                ketama_points      => 150,
                max_failures       => 3,
                failure_timeout    => 2,
            }
        ),
    );
}


1;


__END__

=head1 NAME

Memcache::Queue -

=head1 SYNOPSIS

  use Memcache::Queue;

=head1 DESCRIPTION

Memcache::Queue is

=head1 AUTHOR

Masartz E<lt>masartz {at} gmail.comE<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
