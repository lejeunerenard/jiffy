package App::Jiffy::Util::TimeParsing;
use strict;
use warnings;

use DateTime::Format::Strptime;

use Exporter 'import';

our @EXPORT_OK = qw/parse_time/;

sub parse_time {
  my $time_string = shift;

  my $start_time;
  my $LocalTZ = DateTime::TimeZone->new( name => 'local' );    # For caching
  my $now = DateTime->now( time_zone => $LocalTZ );

  # First try H:M:S
  my $strp = DateTime::Format::Strptime->new(
    pattern   => '%F %T',
    time_zone => $LocalTZ,
  );
  $start_time = $strp->parse_datetime($time_string);

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

  # Make sure the date part of the datetime is not set to the
  # beginning of time.
  if ( $start_time and $start_time->year == 1 ) {
    $start_time->set(
      day   => $now->day,
      month => $now->month,
      year  => $now->year,
    );
  }

  return $start_time;
}

1;
