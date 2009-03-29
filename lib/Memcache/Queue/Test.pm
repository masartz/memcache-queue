package Memcache::Queue::Test;
use strict;
use warnings;
    
use Cache::Memcached;

sub init_memcache{
    my $self = shift;

    my $mem = Cache::Memcached->new({
        servers => 'localhost:11211'
    });
    $mem->flush_all();
}

1;
