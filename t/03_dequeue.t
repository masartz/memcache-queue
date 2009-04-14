use strict;
use warnings;

use Test::More tests => 5;
use Test::Output qw/ stdout_is /;
use Memcache::Queue;
use Memcache::Queue::Test;

my $TEST_CLASS = 'Memcache::Queue::Test::03_Dequeue';


# memcache clear
Memcache::Queue::Test::init_memcache();


my $mem_q = Memcache::Queue->new();
my $manager = $mem_q->manager;

# single dequeue
{
    $manager->enqueue($TEST_CLASS, {'arg'=>'TTTEEESSSTTT'} );
    my $dequeue_cnt = $manager->enqueue($TEST_CLASS , {'arg'=>'TEST2'} );
    $manager->enqueue($TEST_CLASS , {'arg'=>'test3'} );
    my $ret = $manager->dequeue($TEST_CLASS , $dequeue_cnt );
    stdout_is( sub { $manager->work_start( $TEST_CLASS );  } , 'TTTEEESSSTTT'.'test3');
    is( $ret , 1 , 'dequeue OK');
}

# multi dequeue
{
    $manager->enqueue($TEST_CLASS, {'arg'=>'TTTEEESSSTTT'} );
    my $de_cnt1 = $manager->enqueue($TEST_CLASS , {'arg'=>'TEST2'} );
    $manager->enqueue($TEST_CLASS , {'arg'=>'test3'} );
    my $de_cnt2 = $manager->enqueue($TEST_CLASS , {'arg'=>'TesT4'} );
    $manager->enqueue($TEST_CLASS , {'arg'=>'tESt5'} );

    my $ret1 = $manager->dequeue($TEST_CLASS , $de_cnt1 );
    my $ret2 = $manager->dequeue($TEST_CLASS , $de_cnt2 );

    stdout_is( sub { $manager->work_start( $TEST_CLASS );  } , 'TTTEEESSSTTT'.'test3'.'tESt5');
    is( $ret1 , 1 , 'multi dequeue1 OK');
    is( $ret2 , 1 , 'multi dequeue2 OK');
}

1;
