use strict;
use warnings;

use Test::More tests => 12;
use Memcache::Queue;
use Memcache::Queue::Test;

# memcache clear
Memcache::Queue::Test::init_memcache();

my $mem_q = Memcache::Queue->new();
my $manager = $mem_q->manager;
#manager methods
{
    isa_ok( $manager , 'Memcache::Queue::Manager' , 'Manager object OK');
    can_ok( $manager , qw/ logger cache log_conf
                           enqueue work_start job_failed
                           _get_current_cnt _get_done_cnt _update_done_cnt
                           _assign_cnt _make_key _make_current_key _make_done_key
                           / );
}

# cache methods
{
    my $cache = $manager->cache;
    isa_ok( $cache , 'Cache::Memcached' , 'Cache object OK');
    can_ok( $manager , qw/ cache_get cache_set cache_del 
                         cache_get_multi cache_incr cache_decr / );
}

# _make_current_key
{
    is( $manager->_make_current_key('TEST') , 'TEST' ,  '_make_current_key OK');
}

# _get_current_cnt
{
    $manager->cache_set(
        $manager->_make_current_key('TEST') , 10 , 5
    );
    is( $manager->_get_current_cnt('TEST') , 10 ,  '_get_current_cnt OK');
}

# _make_done_key
{
    is( $manager->_make_done_key('TEST') , 'TEST_done' ,  '_make_done_key OK');
}

# _get_done_cnt
{
    $manager->cache_set(
        $manager->_make_done_key('TEST') , 20 , 5
    );
    is( $manager->_get_done_cnt('TEST') , 20 ,  '_get_done_cnt OK');
}

# _udpate_done_cnt
{
    $manager->_update_done_cnt( 'TEST' , 30 );
    is( 30 , $manager->_get_done_cnt('TEST') , '_udpate_done_cnt OK');
}


# _assign_cnt
{
    $manager->cache_del( 'TEST' );
    is( $manager->_assign_cnt('TEST') , 1 ,  '_assign_cnt from init OK');
    $manager->cache_set( 'TEST' , 10 , 5 );
    is( $manager->_assign_cnt('TEST') , 11 ,  '_assign_cnt OK');
}

# _make_key
{
    my ( $name , $num ) = qw/ TEST 10 /;
    is( $manager->_make_key( $name , $num ) , $name.'_'.$num ,  '_make_key OK');
}


