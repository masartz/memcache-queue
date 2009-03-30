package Memcache::Queue::Test::05_Log_File;
use Moose;
extends 'Memcache::Queue::Worker';


override 'work' => sub {
    my ($class, $job) = @_;

    die __PACKAGE__.' ERROR !!!';
};

__PACKAGE__->meta->make_immutable;
no Moose;


1;
