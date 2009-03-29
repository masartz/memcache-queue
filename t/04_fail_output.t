use strict;
use warnings;

use Test::More tests => 1;
use Test::Output qw/ stdout_like /;
use Memcache::Queue;
use Memcache::Queue::Test;

my $TEST_CLASS = 'Memcache::Queue::Test::04_Fail';

# memcache clear
Memcache::Queue::Test::init_memcache();

my $mem_q = Memcache::Queue->new();

my $manager = $mem_q->manager;

# single enqueue
{
    $manager->enqueue($TEST_CLASS, {'arg'=>'TTTEEESSSTTT'} );
    stdout_like( sub { $manager->work_start( $TEST_CLASS );  } , qr/^$TEST_CLASS ERROR !!!/ );
}

1;
