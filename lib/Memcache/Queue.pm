package Memcache::Queue;

use Moose;
use Memcache::Queue::Manager;
our $VERSION = '0.01';

has 'manager' => (
    is         => 'ro',
    isa        => 'Memcache::Queue::Manager',
    lazy_build => 1,
);

__PACKAGE__->meta->make_immutable;
no Moose;

use constant {
    SERVERS => ['localhost:11211' , 'localhost:11211'],
};

sub _build_manager{
    my $self = shift;

    Memcache::Queue::Manager->new(
        cache  => Cache::Memcached->new(
            {
                servers            => SERVERS,
                compress_threshold => 50_000,
                ketama_points      => 150,
                max_failures       => 3,
                failure_timeout    => 2,
            }
        ),
    );
}


1;


__END__

=head1 NAME

Memcache::Queue - cheap Queue System using Memcached

=head1 SYNOPSIS

  ## sample_client.pl
  use Memcache::Queue;

  my $mem_q = Memcache::Queue->new();
  my $manager = $mem_q->manager;

  $manager->enqueue(
        'Test::Sample01',
        {'arg'=>'sample_test'}
  );


  ## sample_worker.pl
  use Memcache::Queue;

  my $mem_q = Memcache::Queue->new();
  my $manager = $mem_q->manager;

  while(1){
      $manager->work_start( 'Test::Sample01' );
  }


  ## lib/Test/Sample01.pm
  package Test::Sample01;

  use Moose;
  extends 'Memcache::Queue::Worker';

  override 'work' => sub {
      my ($class, $job) = @_;

      # output [sample_test]
      print STDOUT $job->{arg};

      return 1;
  };

  __PACKAGE__->meta->make_immutable;
  no Moose;


=head1 DESCRIPTION

Memcache::Queue is cheap Queue System.
which use Memcached for Data Saving.

This module repeat saving job like stack,
so latest job is accepted faster than older job.


=head1 AUTHOR

Masartz E<lt>masartz {at} gmail.comE<gt>

=head1 SEE ALSO

L<TheSchwartz>

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
