############################################################
#
# $Header: /mnt/barrayar/d06/home/domi/Tools/perlDev/Puppet_Any/RCS/Any.pm,v 1.8 1998/06/22 16:13:06 domi Exp $
#
# $Source: /mnt/barrayar/d06/home/domi/Tools/perlDev/Puppet_Any/RCS/Any.pm,v $
# $Revision: 1.8 $
# $Locker:  $
# 
############################################################

package Puppet::Any ;

use Carp ;
use Tk::Multi::Manager ;
use Tk::Multi::Text ;
use Tk::ObjScanner ;
use Puppet::Log ;
use AutoLoader 'AUTOLOAD' ;

use strict ;
use vars qw($VERSION) ;
$VERSION = '0.02' ;

# stubs
sub acquire ;
sub drop;
sub dropAll ;
sub acquiredBy ;
sub droppedBy ;
sub display ;
sub closeDisplay ;
sub printDebug ;
sub printEvent ;
sub storeDbInfo ;
sub deleteDbInfo ;


# see loadspecs for other names
sub new 
  {
    my $type = shift ;
    my $self = {} ;
    my %args = @_ ;
    
    foreach (qw/name topTk dbHash keyRoot/)
      {
        $self->{$_} = delete $args{$_} ;
      }

    # parameter check
    if (defined $self->{dbHash} or defined $self->{keyRoot})
      {
        foreach (qw/name dbHash keyRoot/)
          {
            croak("You must pass parameter $_ to $type $self->{name}\n") 
              unless defined $self->{$_};
          }
        $self->{myDbKey} = $self->{keyRoot}.";".$self->{name} ;
        $self->{"myDbHash"} = $self->{dbHash}{ $self->{myDbKey} } ;
      }

    # config debug window
    foreach (qw(debug event))
      {
        $self->{'log'}{$_} = new Puppet::Log ($_,%args);
      }

    bless $self,$type ;
  }

1;

__END__

=head1 NAME

Puppet::Any - Common base class for lab development tools

=head1 SYNOPSIS

 use Puppet::Any ;

 package myClass ;

 @myClass::ISA=('Puppet::Any') ;

 package main ;
 my $file = 'test.db';
 my %dbhash;
 tie %dbhash,  'MLDBM',    $file , O_CREAT|O_RDWR, 0640 or die $! ;

 my $test = new myClass (name => 'test',
                           dbHash => \%dbhash,
                           keyRoot => 'key root'
                          );

 $test->display;
 $test->setDbInfo(toto => 'toto val', 
                 'titi' => 'titi val',
                dummy => 'null') ;

 $test->deleteDbInfo('dummy');

 MainLoop ; # Tk's

 untie %dbhash ;

=head1 DESCRIPTION

Puppet::* classes are designed to provide an access to the "puppeted"
object using a GUI based on Tk.

The basic idea is when you construct a Puppet::* object, you have all the
functionnality of the object without the GUI. Then, when the need arises,
you may (or the class may decide to) open the GUI of the object and then
the user may perform any interactive he wishes.

On the other hand, if the need does not arise, you may instanciate a lot of 
objects without cluttering your display.

For instance, if you have an object (say a ProcessGroup) 
controlling a set of processes (Process objects). The user may start the
ProcessGroup through its GUI. Then all processes are run. If one of them
fails, it will raise its own GUI to display the cause of the problem and 
let the user decide what to do. 

This class named Puppet::Any is the base class inherited by all other 
Puppet classes. In this example, Process and Process group both will 
inherit Puppet::Any.

The base class features :
- A Tk::Multi::Manager to show or hide the different display of the base class
  (or of the derived class)
- A menu bar
- An event log display so derived object may log their activity
- A Debug log display so derived object may log their "accidental"
  activities
- An Object Scanner to display the attribute of the derived object
- A set of functions to managed "has-a" relationship between Puppet objects.
  The menu bar feature a "content" bar which enabled the user to open the
  display of all "contained" objects.
- a facility to store data on a database file tied to a hash.

The class is designed to store its data in a SINGLE entry of the database
file. (For this you should use MLDBM if you want to store more than a scalar
in the database). The key for this entry is "$keyRoot;$name". keyRoot and
name being passed to the constructor of the object. Needless to say, it's a bad
idea to create two instances of Puppet::WithDb with the same keyRoot and name.


=head1 default bindings

<Meta-d> is bound to pop-up a Tk object scanner widget. This will be handy
to debug the child class you're going to develop.

=cut

#'

=head1 Object attributes

=head2 name

name of the instance. No treatment or special signification to it except that
it can be handy for the debug. 

=head2 content

Hash containing the reference of all acquired objects ('name' => ref).

=head2 topTk

Reference of the Tk main window.

=head2 log

hash array which contains 'event' and 'debug' Puppet::Log objects.
Do not squash it.

=head2 tk

Hash containing the following keys :

 - toplevel: toplevel window ref of this object.
 - menubar: Frame containing the menu buttons. (you may call MenuButton on it)
 - contentMnb: ref to the menu managing content (private)
 - menu: hash containing menu widgets. ('File' for instance) 
  ( you may call command on
   $self->{tk}{menu}{'File'} to define a new command in the menu for instance)
 - multiMgr Tk::Multi::Manager buddy ref.

When the closeDisplay method is called, it will destroy $self->{tk}{toplevel},
thus it will destroy all Tk widgets and then it will delete the $self->{tk}
 hash, thus it will delete all internal reference to the destroyed widgets.
So you can also test whether your widget has a display by testing if 
$self->{tk} is defined.

The sub-class MUST abide to this rule if the closeDisplay is to work properly.

=head2 dbHash

Tied hash to the database.

=head2 keyRoot

First part of the key to access the database

=head2 myDbKey

The key to access the database

=head1 Methods

=head2 new( ... )

Creates new Puppet object.

parameters are :
 - name
 - topTk (optionnal, will create a MainWindow if ommitted)
 - keyRoot
 - dbHash: ref of the tied hash

Note that all other arguments are passed to the Puppet::Log constructors. 
I.e. you can also specify arguments specific to Puppet::Log->new() through 
Puppet::Any->new() function.

=head2 acquire(a_name, a_ref)

Acquire the object ref as a child. a_ref must be an object derived of 
Puppet::Any.

Each acquired object must have different names.

=head2 drop('name')

Destroy child 'name'.

=head2 display()

defines a top level display for each object, contains a MultiText ,a manager
and a objScanner.

<Meta-d> will create an object scanner to scan this object.

A debug and an events log objects (Puppet::Log) are created for use 
by the child class

Return 1 if a display is actually created. 0 otherwise (i.e is the display
already exists).

When overloading display, you may write you function like this :

 sub display
  {
    my $self = shift ;
    return unless $self->SUPER::display(@_ );

 ...
 }

So the display instruction you add will be run only when creating the display.

=head2 closeDisplay

Close the display. Note that the display can be re-invoked later.

=head2 printDebug(text)

Will log the passed text into the debug log object.

=head2 printEvent(text)

Will log the passed text into the events log object.

=head2 showEvent(text)

Will display the 'event' log window.

=head2 storeDbInfo( key => value, ...)

Store the passed hash in the database. You may also pass a hash ref as single
argument.

=head2 deleteDbInfo( key, ...)

delete the "key" entries from the database.

=head1 AUTHOR

Dominique Dumont, Dominique_Dumont@grenoble.hp.com

Copyright (c) 1998 Dominique Dumont. All rights reserved.
This program is free software; you can redistribute it and/or
modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Tk(3), Puppet::Log(3)

=cut

sub acquire
  {
    my $self = shift ;
    my $name = shift;
    my $ref  = shift ;

    return if defined $self->{content}{$name} ;
    $self->{content}{$name}=$ref ;
    $ref->acquiredBy($self) ;

    return if not defined $self->{tk}{contentMnb} ;

    my %hash;
    my $i = 1 ;
    map($hash{$_}= $i++, sort keys %{$self->{content}}) ;

    my $pos = $hash{$name} == ($i-1) ? 'end' : $hash{$name} ;
    $self->{tk}{contentMnb} -> menu -> insert
      (
       $pos,'command',
       -label => $name,
       command => sub{$self->{content}{$name}->display(); }
      );
  }

sub dropAll
  {
    my $self = shift ;
    
    my @array = sort keys %{$self->{content}} ;
    # beware that drop will delete $self->{content}
    $self->drop(@array);
  }  

sub drop
  {
    my $self = shift ;

    my %hash;
    my $i = 1;
    map($hash{$_}= $i++, sort keys %{$self->{content}}) ;

    foreach (@_)
      {
        next unless defined $self->{content}{$_} ;
        
        my $pos = $hash{$_} == ($i-1) ? 'end' : $hash{$_} ;

        $self->{content}{$_} -> droppedBy($self) ;
        $self->{tk}{contentMnb} -> menu ->delete($pos) ;
        delete $self->{content}{$_} ;
      }
  }

sub acquiredBy
  {
    my $self = shift ;
    my $ref  = shift ;
    # the key is the ref evaluated in string context (i.e HASH(0x...)
    $self->{container}{"$ref"}=$ref ;
  }

sub droppedBy
  {
    my $self = shift ;
    my $ref = shift;

    delete $self->{container}{"$ref"} ;

    return if scalar %{$self->{container}} ;

    # suicide if I have no more father
    if (defined $self->{content})
      {
        # will also destroy display of content
        foreach (values %{$self->{content}}) {$_ -> droppedBy($self)};
      } 

    # last thing to do
    $self->closeDisplay if defined $self->{tk} ;
  }

# defines a top level display for each object, contains a MultiText ,amager
# and a objScanner.

# can be called with no parameter -> show itself
sub display
  {
    my $self =shift ;
    
    if (defined $self->{tk}{toplevel})
      {
        $self->{tk}{toplevel}->deiconify() 
          if ($self->{tk}{toplevel}->state() eq 'iconic') ;
	$self->{tk}{toplevel}->raise();
	return 0 ;
      }
    
    my $type = ref($self) ;
    $type =~ s/^.*::// ;
    my $labelName = $type.': '.$self->{'name'} ;
    
    $self->printDebug("Creating Toplevel display for ".ref($self)."\n") ;

    my $poof ;
    if (defined $self->{topTk})
      {
        $self->{tk}{toplevel} = $self->{topTk} -> Toplevel();
        $poof = 'poof';
      }
    else
      {
        $self->{topTk} = $self->{tk}{toplevel} = MainWindow-> new ;
        $poof = 'Quit' ;
      }

    $self->{tk}{toplevel} -> title($labelName) ;

    my $showDebug = sub 
      { 
        # must not create 2 scanner windows
        unless (scalar grep(ref($_ ) eq 'Tk::ObjScanner',
                            $self->{tk}{toplevel}->children))
          {
            $self->{tk}{toplevel} -> ObjScanner('caller' => $self) -> pack;
          }
      } ;

    # create common menu bar
    my $w_menu = $self->{tk}{toplevel} ->
      Frame(-relief => 'raised', -borderwidth => 2) -> pack(-fill => 'x');

    $self->{tk}{menu}{File} = 
      $w_menu->Menubutton(-text => 'File', -underline => 0) 
        -> pack(side => 'left' );
    $self->{tk}{menu}{File}->command(-label => $poof,  
                                 -command => sub{$self->closeDisplay();} );
    $self->{tk}{menu}{File}->command(-label => 'show internals',  
                                 -command => $showDebug );
    # currently core dumps
    #$self->{tk}{menu}{File}->command(-label => 'Quit',  -command => sub{exit;} );

    $self->{tk}{menubar} = $w_menu ;

# frame for name and status ??? 
#    my $nsf = $self->{tk}{toplevel} -> Frame 
#      (-borderwidth => 2 , relief => 'sunken' ) -> pack (-fill => 'x') ;
#    $nsf -> Label ( text => $labelName.' ')
#      -> pack (side => 'left');
    
#    $nsf -> Label (textvariable => \$self->{'status'}) 
#      -> pack (side => 'right');
#    $nsf -> Label ( text => "status: " ) 
#      -> pack (side => 'right');
#    $self->{nameFrame} = $nsf ;

    
    # load MultiText::manager
    $self->{tk}{multiMgr} = $self->{tk}{toplevel} -> MultiManager 
      ( 'title' => 'log' , 'menu' => $w_menu ) -> pack ();
    
    # bind dump info 
    $self->{tk}{toplevel}->bind ('<Meta-d>', $showDebug);
    
    # config debug window
    foreach (qw(debug event))
      {
        $self->{'log'}{$_} -> display ($self->{tk}{multiMgr},1);
      }
   
    $self->{tk}{contentMnb} = $self->{tk}{menubar} -> 
      Menubutton (-text => 'content') -> 
        pack ( fill => 'x' , side => 'left');

    return 1 unless defined $self->{content} ;

    foreach my $name (sort keys %{$self->{content}})
      {
        $self->{tk}{contentMnb}->command
          ( 
           -label => $name,
           command => sub{$self->{content}{$name}->display(); } 
          ) ;
      }

    return 1 ;
  }

sub closeDisplay
  {
    my $self = shift ;
    # must delete all values stored during display creation
    unless (defined $self->{tk})
      {
        $self->printDebug
          ("$self->{name} closeDisplay called while not displaying\n") ;
        return ;
      }

    $self->{tk}{toplevel}->destroy;
    delete $self->{tk} ;
  }

sub printDebug
  {
    my $self= shift ;
    my $text=shift ;
    $self->{'log'}{debug}->log($text) ;
  }

sub printEvent
  {
    my $self= shift ;
    my $text=shift ;
    $self->{'log'}{'event'}->log($text) ;
  }

sub showEvent
  {
    my $self= shift ;
    $self->{'log'}{'event'} -> show ();
  }

sub storeDbInfo
  {
    my $self = shift ;
    my $h ;
    if (scalar(@_) == 1) {$h = shift ;}
    else {%$h = @_ ;}

    # MLDBM hackery
    my $hash = $self->{dbHash}{ $self->{myDbKey} };

    @$hash{keys %$h} = values %$h ;

    $self->{dbHash}{ $self->{myDbKey} } = $hash ; # register it in MLDBM
    $self->{"myDbHash"} = $hash ;
  }

sub deleteDbInfo
  {
    my $self = shift ;
    my @args = @_ ;

    if (scalar @args)
      {
        # MLDBM hackery
        my $hash = $self->{dbHash}{ $self->{myDbKey} };
        map(delete $hash->{$_},@args) ;
        $self->{dbHash}{ $self->{myDbKey} } = $hash ; # register it in MLDBM
        $self->{"myDbHash"} = $hash ;
      }
    else
      {
        delete $self->{dbHash}{ $self->{myDbKey} } ; # destroy all
        delete $self->{"myDbHash"} ;
      }
  }

