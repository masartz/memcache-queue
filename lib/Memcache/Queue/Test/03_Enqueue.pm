package Memcache::Queue::Test::03_Enqueue;
use Moose;
extends 'Memcache::Queue::Worker';


override 'work' => sub {
    my ($class, $job) = @_;

    print STDOUT $job->{arg};

    return 1;
};

__PACKAGE__->meta->make_immutable;
no Moose;


1;
