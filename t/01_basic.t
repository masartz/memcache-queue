use strict;
use warnings;

use Test::More tests => 3;
use Test::Output qw/ stdout_is /;
use Memcache::Queue;
use Memcache::Queue::Test;

my $TEST_CLASS = 'Memcache::Queue::Test::01_Basic';

# memcache clear
Memcache::Queue::Test::init_memcache();

my $mem_q = Memcache::Queue->new();
isa_ok( $mem_q , 'Memcache::Queue' , 'object new OK');
can_ok( $mem_q , qw/ manager / );

my $manager = $mem_q->manager;

$manager->enqueue($TEST_CLASS, {'arg'=>'TTTEEESSSTTT'} );
stdout_is( sub { $manager->work_start( $TEST_CLASS );  } , 'TTTEEESSSTTT');

1;
