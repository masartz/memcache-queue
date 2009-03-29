use strict;
use warnings;

use Test::More tests => 7;
use Memcache::Queue;

my $mem_q = Memcache::Queue->new();
my $logger = $mem_q->manager->logger;
#Log methods
{
    isa_ok( $logger , 'Memcache::Queue::Log' , 'Log object OK');
    can_ok( $logger , qw/ dispatch_conf dispatch
                          output _build_dispatch / );
    is( $logger->dispatch_conf->{class} , 'Screen' , 'Log::Dispatch::Screen Obj OK');
    is_deeply( $logger->dispatch_conf->{attribute} , 
                { name      => 'Mem-Queue-Logger',
                  min_level => 'debug', 
                  stderr    => 0, 
                } 
                , 'Log::Dispatch::Screen attribute OK');
}

# edit log object
{
    my %conf_hash = (
        class => 'File',
        attribute  => { 
            name      => 'Test-Logger',
            min_level => 'info', 
            stderr    => 1, 
        },
    );
    my $q = Memcache::Queue->new();
    my $manager= $q->manager();
    $manager->log_conf(\%conf_hash);
    my $log_file= $manager->logger();
    is_deeply( $log_file->dispatch_conf , \%conf_hash , 'Log::Dispatch::File Conf OK');
}

my $dispatch = $logger->dispatch();
#Dispatch methods
{
    isa_ok( $dispatch , 'Log::Dispatch' , 'Dispatch object OK');
    can_ok( $dispatch , qw/ log / );
}



