# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk ;
use Fcntl ;
use MLDBM qw(DB_File) ;
use ExtUtils::testlib;
use Puppet::Any ;
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

use strict ;
my $file = 'test.db';
my %dbhash;
tie %dbhash,  'MLDBM',    $file , O_CREAT|O_RDWR, 0640 or die $! ;

my $test = new Puppet::Any (name => 'test',
                           dbHash => \%dbhash,
                           keyRoot => 'key root'
                          );

$test->display;
$test->storeDbInfo(toto => 'toto val', 
                 'titi' => 'titi val',
                dummy => 'null') ;

$test->deleteDbInfo('dummy');

MainLoop ; # Tk's

warn "You may see the content of the DB file using db_dump -p $file\n";

untie %dbhash ;
