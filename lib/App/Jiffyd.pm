package App::Jiffyd;

use strict;
use warnings;

use Dancer;
use App::Jiffy::TimeEntry;
use App::Jiffy::Util::TimeParsing qw/parse_time/;
use YAML::Any qw( LoadFile );

my $cfg = LoadFile( $ENV{HOME} . '/.jiffy.yml' ) || {};

post '/timeentry' => sub {
  my $start_time = parse_time(param 'start_time');

  my $title = param 'title';

  # Create and save Entry
  App::Jiffy::TimeEntry->new(
    title        => $title,
    start_time   => $start_time,
    cfg          => $cfg,
  )->save;
};

1;
