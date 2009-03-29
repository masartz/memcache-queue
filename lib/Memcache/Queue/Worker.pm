package Memcache::Queue::Worker;
use Moose;
with 'Memcache::Queue::Role::Worker';

sub work{
    my $self = shift;

    die 'this is abstract method!';
}

no Moose;

sub work_safely {
    my ($class, $manager, $job) = @_;
    my $res;

    eval {
        $res = $class->work($job);
    };
    if (my $e = $@) {
        $manager->job_failed($job, $e);
        return ;
    }
=put
    if (!$job->is_completed) {
        $manager->job_failed($job, 'Job did not explicitly complete, fail, or get replaced');
    }
=cut

    return $res;
}

1;
