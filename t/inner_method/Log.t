use strict;
use warnings;

use Test::More tests => 4;
use Memcache::Queue;

my $mem_q = Memcache::Queue->new();
my $logger = $mem_q->manager->logger;
#Log methods
{
    isa_ok( $logger , 'Memcache::Queue::Log' , 'Log object OK');
    can_ok( $logger , qw/ dispatch_class dispatch_conf dispatch
                          output _build_dispatch / );
}

my $dispatch = $logger->dispatch();
#Dispatch methods
{
    isa_ok( $dispatch , 'Log::Dispatch' , 'Dispatch object OK');
    can_ok( $dispatch , qw/ log / );
}



