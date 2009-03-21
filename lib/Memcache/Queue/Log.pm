package Memcache::Queue::Log;
use Moose;
use Log::Dispatch;
use UNIVERSAL::require;

with qw/ Memcache::Queue::Role::Log /;

has 'dispatch_class' => (
    is => 'ro',
    isa => 'Str',
    required => 1,
    default => 'Screen',
);

has 'dispatch_conf' => (
    is => 'ro',
    isa => 'HashRef[Str]',
    required => 1,
    default => sub { 
        +{
            name      => 'Mem-Queue-Logger',
            min_level => 'debug',
            stderr    => 0,
        }
    },
);

has 'dispatch' =>(
    is => 'ro',
    isa => 'Log::Dispatch',
    lazy_build => 1,
);

__PACKAGE__->meta->make_immutable;
no Moose;

sub _build_dispatch{
    my $self  = shift;
    
    my $dispatcher = Log::Dispatch->new;
    my $class = "Log::Dispatch::$self->{dispatch_class}";
    $class->use or die $@;
    $dispatcher->add(
       $class->new( %{$self->{dispatch_conf}} )
    ) or die $@;
   
    return $dispatcher;
};


sub output{
    my ($self, $job , $e) = @_;

    $self->dispatch->log(level => 'debug', message => $e );
}

1;
