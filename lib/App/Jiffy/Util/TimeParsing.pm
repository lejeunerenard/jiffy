package App::Jiffy::Util::TimeParsing;
use strict;
use warnings;

use DateTime::Format::Strptime;
use DateTime::Format::ISO8601;

use Exporter 'import';

our @EXPORT_OK = qw/parse_time/;

sub parse_time {
  my $time_string = shift // '';

  my $start_time;
  my $LocalTZ = DateTime::TimeZone->new( name => 'local' );
  my $now = DateTime->now( time_zone => $LocalTZ );

  # Testing goes from the least specific to the most, but because the
  # Format::Strptime solutions are too lenient and catch ISO8601 formats even
  # with the 'Z' at the end, we need to test for a 'T' or 'Z' assuming that only
  # ISO8601 strings will have those characters
  if ( $time_string =~ /T|Z/ ) {
    my $strp = DateTime::Format::ISO8601->new();
    eval {
      $start_time = $strp->parse_datetime($time_string);

      if ( $start_time->time_zone()->name eq 'floating' ) {
        $start_time->set_time_zone($LocalTZ);
      }
    };
  }

  # First consistent try F H:M:S
  if ( not $start_time ) {
    my $strp = DateTime::Format::Strptime->new(
      pattern   => '%F %T',
      time_zone => $LocalTZ,
    );
    $start_time = $strp->parse_datetime($time_string);
  }

  # If no time found try just H:M:S
  if ( not $start_time ) {
    my $strp = DateTime::Format::Strptime->new(
      pattern   => '%T',
      time_zone => $LocalTZ,
    );
    $start_time = $strp->parse_datetime($time_string);
  }

  # If no time found try just H:M
  if ( not $start_time ) {
    my $strp = DateTime::Format::Strptime->new(
      pattern   => '%R',
      time_zone => $LocalTZ,
    );
    $start_time = $strp->parse_datetime($time_string);
  }

  # As a last resort attemp testing again against ISO08601 if nothing else catches
  if ( not $start_time ) {
    my $strp = DateTime::Format::ISO8601->new();
    eval {
      $start_time = $strp->parse_datetime($time_string);

      if ( $start_time->time_zone()->name eq 'floating' ) {
        $start_time->set_time_zone($LocalTZ);
      }
    };
  }

  # Make sure the date part of the datetime is not set to the
  # beginning of time.
  if ( $start_time and $start_time->year == 1 ) {
    $start_time->set(
      day   => $now->day,
      month => $now->month,
      year  => $now->year,
    );
  }

  return $start_time // $now;
}

1;
