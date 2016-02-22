#!/usr/bin/env perl

use Test::More;
use Test::Deep; # (); # uncomment to stop prototype errors
use Test::Exception;

use Capture::Tiny ':all';

use lib qw{ ./t/lib };

use CreateTimeEntries qw/generate/;

use YAML::Any qw( LoadFile );

use_ok('App::Jiffy');

my $cfg = LoadFile('t/test.yml');

my $client = MongoDB::MongoClient->new;
my $db = $client->get_database('jiffy-test');
my $app = App::Jiffy->new(
  cfg => $cfg,
);

subtest 'prep' => sub {
  ok $db->drop, 'cleared db';
};

subtest 'add_entry' => sub {
  subtest 'works on edge cases' => sub {
    {
      no warnings 'redefine';
      local *DateTime::now = sub { DateTime->new(
        day => 10,
        hour => 20,
        minute => 0,
        year => 2016,
        month => 2,
        time_zone => 'local',
      ) };
      $ENV{TZ} = 'America/Chicago';

      $app->add_entry({
        time => '18:37',
      }, 'Next day for UTC');

      my @entries = App::Jiffy::TimeEntry::search(
        $cfg,
        query => {
          title => 'Next day for UTC',
        },
      );
      is scalar @entries, 1, 'created timeEntry w/ time option';

      is $entries[0]->start_time->hour, 0, 'got UTC hour';
      is $entries[0]->start_time->day, 11, 'got UTC day';
      ok $entries[0]->duration->is_positive, 'Doesn\'t go back in time';
    }
  };
};
subtest 'timesheet' => sub {
  ok $db->drop, 'cleared db';

  subtest 'for multiple days' => sub {
    # Seed db
    my $now = DateTime->now;
    generate($cfg,[
      {
        start_time => {
          days => 1,
        },
      },
      {
        start_time => {
          hours => 23,
        },
        title => 'done',
      },
      {}    # Default Entry
    ] );

    my ( $stdout, $stderr, $exit ) = capture {
      $app->time_sheet(2);
    };

    like $stdout, qr/\d{2}\/\d{2}\/\d{4}/, 'returns datetimes';
  };
  subtest 'can be verbase' => sub {
    my ( $stdout, $stderr, $exit ) = capture {
      $app->time_sheet({
        verbose => 1,
      });
    };

    like $stdout, qr/\d{1,2}:\d{2}/, 'found times';
  };
};

done_testing;
