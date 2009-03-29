use strict;
use warnings;

use Test::More tests => 8;
use Memcache::Queue;
use Memcache::Queue::Test;

# memcache clear
Memcache::Queue::Test::init_memcache();

my $mem_q = Memcache::Queue->new();
my $manager = $mem_q->manager;
#manager methods
{
    isa_ok( $manager , 'Memcache::Queue::Manager' , 'Manager object OK');
    can_ok( $manager , qw/ enqueue work_start 
                           _get_cnt _assign_cnt _make_key / );
}

# cache methods
{
    my $cache = $manager->cache;
    isa_ok( $cache , 'Cache::Memcached' , 'Cache object OK');
    can_ok( $manager , qw/ cache_get cache_set cache_del 
                         cache_get_multi cache_incr cache_decr / );
}

# _get_cnt
{
    $manager->cache_set( 'TEST' , 10 , 5 );
    is( $manager->_get_cnt( 'TEST') , 10 ,  '_get_cnt OK');
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


