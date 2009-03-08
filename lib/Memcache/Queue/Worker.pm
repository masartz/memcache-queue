package Memcache::Queue::Worker;
use Moose::Role;
requires 'work';

sub work_safely {
    my ($class, $manager, $job) = @_;
    my $res;

    eval {
        $res = $class->work($job);
    };
=put
    if (my $e = $@) {
        $manager->job_failed($job, $e);
    }
    if (!$job->is_completed) {
        $manager->job_failed($job, 'Job did not explicitly complete, fail, or get replaced');
    }
=cut

    return $res;
}

1;
