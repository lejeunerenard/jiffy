package App::Jiffy::View::Timesheet;

use strict;
use warnings;

use App::Jiffy::TimeEntry;
use DateTime;

sub render {
  my $entries = shift;
  my $options = shift;

  my $current_day = $entries->[0]->start_time->clone->truncate( to => 'day' );

  foreach my $entry (@$entries) {

    my $start_time = $entry->start_time->clone;

    if (
      DateTime->compare( $current_day, $start_time->truncate( to => 'day' ) )
      == -1 )
    {
      $current_day = $start_time->truncate( to => 'day' );
      print "\nDate: " . $current_day->mdy('/') . "\n";
    }

    # Get the deltas
    my $duration = $entry->duration;

    if ( $options->{round} ) {
      # Round seconds
      my $seconds = $duration->seconds;
      if ( $seconds >= 30 ) {
        $duration->add( minutes => 1 );
      }
      $duration->subtract( seconds => $seconds );

      # Round minutes
      my $minutes = $duration->minutes;
      if ( $minutes % 15 >= 15 / 2 ) {
        $duration->add( minutes => 15 - ($minutes % 15) );
      } else {
        $duration->subtract( minutes => $minutes % 15 );
      }
    }

    my %deltas = $duration->deltas;

    foreach my $unit ( sort keys %deltas ) {
      next unless $deltas{$unit};
      print $deltas{$unit} . " " . $unit . " ";
    }

    # Print entry
    if ( $options->{verbose} ) {
      my ( $clock_time ) = $entry->start_time->hms =~ /(.*):.*$/;
      print "\t " .
      # Time
        $clock_time .
      # Title
        "\t" . $entry->title . "\n";
    } else {
      print "\t " . $entry->title . "\n";
    }
  }
}

1;
