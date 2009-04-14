use strict;
use warnings;

use Test::More tests => 4;
use Test::Output qw/ stdout_is /;
use Memcache::Queue;
use Memcache::Queue::Test;

my $TEST_CLASS = 'Memcache::Queue::Test::02_Enqueue';


# memcache clear
Memcache::Queue::Test::init_memcache();


my $mem_q = Memcache::Queue->new();
my $manager = $mem_q->manager;

# single enqueue
{
    my $ret_cnt = $manager->enqueue($TEST_CLASS, {'arg'=>'TTTEEESSSTTT'} );
    stdout_is( sub { $manager->work_start( $TEST_CLASS );  } , 'TTTEEESSSTTT');
    is( $ret_cnt , 1 , 'enqueue cnt OK');
}

# multi enqueue
{
    my $ret_cnt2 = $manager->enqueue($TEST_CLASS , {'arg'=>'TEST2'} );
    my $ret_cnt3 = $manager->enqueue($TEST_CLASS , {'arg'=>'test3'} );
    stdout_is( sub { $manager->work_start( $TEST_CLASS  );  } , 'TEST2'.'test3');
    is( $ret_cnt3 , 3 , 'enqueue cnt OK');
}

1;
