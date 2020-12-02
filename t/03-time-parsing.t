use strict;
use warnings;

use Test::More;
use Test::Deep;    # (); # uncomment to stop prototype errors
use Test::Exception;

use lib 't/lib';

use MongoDBTest 'test_db_or_skip';

use YAML::Any 'LoadFile';

my $cfg = LoadFile('t/test.yml');

test_db_or_skip($cfg);

my $client = MongoDB::MongoClient->new;
my $db     = $client->get_database( $cfg->{db} );

use_ok('App::Jiffy::Util::TimeParsing', qw/parse_time/);

subtest 'parse_time' => sub {
  my $LocalTZ = DateTime::TimeZone->new( name => 'local' );    # For caching
  my $now = DateTime->now( time_zone => $LocalTZ );

  is parse_time(), $now, 'returns now by default';
  is parse_time('arstien'), $now, 'returns now with unparsable time';

  subtest 'parses H:M' => sub {
    my $time = parse_time('13:34');
    is $time->hour,   13, 'parses hours correctly';
    is $time->minute, 34, 'parses minutes correctly';
    is $time->second, 0, 'assumes seconds are 0';
    is $time->day,   $now->day, 'assumes the day is today\'s day';
    is $time->month, $now->month, 'assumes the month is today\'s month';
    is $time->year, $now->year, 'assumes the year is today\'s years';
  };

  subtest 'parses H:M w/ it being next day in UTC' => sub {
    my $tomorrow = $now->clone();

    $tomorrow->set_day($tomorrow->day + 1);
    $tomorrow->set_time_zone('UTC');
    $tomorrow->truncate(to => 'day');
    my $tomorrow_epoch = $tomorrow->epoch();

    no warnings 'redefine';
    local *DateTime::_core_time = sub { $tomorrow_epoch; };

    my $now = DateTime->now( time_zone => $LocalTZ );

    my $time = parse_time('13:34');
    is $time->hour,   13, 'parses hours correctly';
    is $time->minute, 34, 'parses minutes correctly';
    is $time->second, 0, 'assumes seconds are 0';
    is $time->day,   $now->day, 'assumes the day is today\'s day';
    is $time->month, $now->month, 'assumes the month is today\'s month';
    is $time->year, $now->year, 'assumes the year is today\'s years';
  };

  subtest 'parses H:M:S' => sub {
    my $time = parse_time('03:28:57');
    is $time->hour,   3, 'parses hours correctly';
    is $time->minute, 28, 'parses minutes correctly';
    is $time->second, 57, 'parses seconds correctly';
    is $time->day,   $now->day, 'assumes the day is today\'s day';
    is $time->month, $now->month, 'assumes the month is today\'s month';
    is $time->year, $now->year, 'assumes the year is today\'s years';
  };

  subtest 'parses F H:M:S' => sub {
    my $time = parse_time('1903-07-13 03:28:57');
    is $time->hour,   3, 'parses hours correctly';
    is $time->minute, 28, 'parses minutes correctly';
    is $time->second, 57, 'parses seconds correctly';
    is $time->day,   13, 'parses day correctly';
    is $time->month, 7, 'parses month correctly';
    is $time->year, 1903, 'parses year correctly';
  };

  subtest 'parses ISO 8601' => sub {
    my $time = parse_time('1805-12-23T15:33:03.0123Z');
    is $time->hour,   15, 'parses hours correctly';
    is $time->minute, 33, 'parses minutes correctly';
    is $time->second, 3, 'parses seconds correctly';
    is $time->millisecond, 12, 'parses milliseconds correctly';
    is $time->day,   23, 'parses day correctly';
    is $time->month, 12, 'parses month correctly';
    is $time->year, 1805, 'parses year correctly';
  };
};

done_testing;
