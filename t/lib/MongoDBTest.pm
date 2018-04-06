package MongoDBTest;

use strict;
use warnings;

use Exporter 'import';
use Test::More;
use MongoDB;

our @EXPORT_OK = qw(
  test_db_or_skip
);

sub test_db_or_skip {
  my $cfg = shift;
  eval {
    my $client = MongoDB::MongoClient->new;
    my $db     = $client->get_database($cfg->{db});
  };

  if ($@) {
    ( my $err = $@ ) =~ s/\n//g;
    if ( $err =~ /couldn't connect|connection refused/i ) {
      $err = "no mongod on localhost:27017";
    }

    plan skip_all => "$err";
  }
}

