use strict;
use warnings;

use Test::More tests => 2;
use Test::Output qw/ stdout_is /;
use Memcache::Queue;

my $mem_q = Memcache::Queue->new();

my $manager = $mem_q->manager;

# single enqueue
{
    $manager->enqueue('Worker::Test', {'arg'=>'TTTEEESSSTTT'} );
    stdout_is( sub { $manager->work_start( 'Worker::Test' );  } , 'TTTEEESSSTTT');
}

# multi enqueue
{
    $manager->enqueue('Worker::Test', {'arg'=>'TEST2'} );
    $manager->enqueue('Worker::Test', {'arg'=>'test3'} );
    stdout_is( sub { $manager->work_start( 'Worker::Test' );  } , 'test3'.'TEST2');
}

package Worker::Test;
use base qw/ Memcache::Queue::Worker /;

sub work {
    my ($class, $job) = @_;

    print STDOUT $job->{arg};

    return 1;
}
