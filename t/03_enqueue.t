use strict;
use warnings;

use Test::More tests => 2;
use Test::Output qw/ stdout_is /;
use Memcache::Queue;
use Memcache::Queue::Test;

my $TEST_CLASS = 'Memcache::Queue::Test::03_Enqueue';


# memcache clear
Memcache::Queue::Test::init_memcache();


my $mem_q = Memcache::Queue->new();
my $manager = $mem_q->manager;

# single enqueue
{
    $manager->enqueue($TEST_CLASS, {'arg'=>'TTTEEESSSTTT'} );
    stdout_is( sub { $manager->work_start( $TEST_CLASS );  } , 'TTTEEESSSTTT');
}

# multi enqueue
{
    $manager->enqueue($TEST_CLASS , {'arg'=>'TEST2'} );
    $manager->enqueue($TEST_CLASS , {'arg'=>'test3'} );
    stdout_is( sub { $manager->work_start( $TEST_CLASS  );  } , 'test3'.'TEST2');
}

1;
