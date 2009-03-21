use strict;
use warnings;

use Test::More tests => 1;
use Test::Output qw/ stdout_like /;
use Memcache::Queue;

my $mem_q = Memcache::Queue->new();

my $manager = $mem_q->manager;

# single enqueue
{
    $manager->enqueue('Worker::Test', {'arg'=>'TTTEEESSSTTT'} );
    use Data::Dumper;
    stdout_like( sub { $manager->work_start( 'Worker::Test' );  } , qr/^Worker::Test ERROR !!!/ );
}

package Worker::Test;
use base qw/ Memcache::Queue::Worker /;

sub work {
    my ($class, $job) = @_;

    die 'Worker::Test ERROR !!!';

    return ;
}
