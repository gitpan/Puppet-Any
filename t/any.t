# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl test.pl'

######################### We start with some black magic to print on failure.

# test Puppet::Any

# Change 1..1 below to 1..last_test_to_print .
# (It may become useful if the test is moved to ./t subdirectory.)

BEGIN { $| = 1; print "1..1\n"; }
END {print "not ok 1\n" unless $loaded;}
use Tk ;
use ExtUtils::testlib;
use Puppet::Any ;
use Tk::ErrorDialog; 
$loaded = 1;
print "ok 1\n";

######################### End of black magic.

# Insert your test code below (better if it prints "ok 13"
# (correspondingly "not ok 13") depending on the success of chunk 13
# of the test code):

use strict ;

package MyTest ;
use vars qw(@ISA) ;

@ISA=('Puppet::Any') ;

sub new
  {
    my $type = shift ;
    my $self = new Puppet::Any(@_) ;

    $self->{podName} = 'Puppet::Any';
    $self->{podSection} = 'DESCRIPTION';
    
    bless $self,$type ;
  }

sub addChildren
  {
    my $self = shift ;

    # create myself some children
    foreach my $n (qw/albert charlotte raymond spirou zorglub/)
      {
        $self->acquire($n, new MyTest (name => $n, 'topTk' => $self->{topTk} , 
                      'factory' => $self->{factory})) ;
      }
  }

sub display
  {
    my $self = shift ;
    return unless $self->SUPER::display(@_ );

    $self->{tk}{menu}{'File'} -> command
      (
       '-label' => 'acquire toto', 
       -command => sub{        
         $self->acquire('toto', new MyTest (name => 'toto', 'topTk' => $self->{topTk} , 
                                      'factory' => $self->{factory})) ;
       }
      ) ;
    $self->{tk}{menu}{'File'} -> command('-label' => 'rm toto', 
                                         -command => sub{$self->drop('toto')}) ;
    $self->{tk}{menu}{'File'} -> command
      (
       '-label' => 'acquire common', 
       -command => sub{$self->acquire('common',$main::common);}
      ) ;
    $self->{tk}{menu}{'File'} -> command
      (
       '-label' => 'close raymond', 
       -command => sub{
         if (defined $self->{content}{'raymond'})
           {
             $self->{content}{'raymond'}->closeDisplay ;
           } 
         else {$self->{tk}{toplevel}->bell;}
       }
      ) ;

    $self->{tk}{menubar}->Menubutton(-text => 'More')-> pack(side => 'left' )
      ->command(-label => 'Dummy',  -command => sub{print "Dummy button\n";} );
  }

package main ;

my $mw = MainWindow-> new ;

my $w_menu = $mw->Frame(-relief => 'raised', -borderwidth => 2);
$w_menu->pack(-fill => 'x');

my $f = $w_menu->Menubutton(-text => 'File', -underline => 0) 
  -> pack(side => 'left' );

print "creating manager\n";
my $wmgr = $mw -> MultiManager ( 'title' => 'Any test' ,
                             'menu' => $w_menu ) 
  -> pack (expand => 1, fill => 'both');

my $test = new MyTest(name => 'under_test', 'topTk' => $mw ) ;

$::common = new MyTest(name => 'common' , 'topTk' => $mw ) ;

$f->command(-label => 're-display',  -command => sub{$test->display} );

$f->command(-label => 'Quit',  -command => sub{exit;} );

$test->addChildren() ;

$test->display;

$test->showEvent;

MainLoop ; # Tk's

