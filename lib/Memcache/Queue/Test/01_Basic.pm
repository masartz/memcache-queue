package Memcache::Queue::Test::01_Basic;
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
