use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
              'NAME'	   => 'Puppet::Any',
              'VERSION_FROM' => 'Any.pm', # finds $VERSION
              'dist' => {COMPRESS=>'gzip -9f', SUFFIX => 'gz'},
              ($] >= 5.005 ?
               (ABSTRACT   => 'Base class for an optionnal GUI',
                AUTHOR     => 'Dominique Dumont (domi@barrayar.grenoble.hp.com)') : ()),
              'PREREQ_PM' =>
              {
               'Tk' => 0,
               'Tk::ObjScanner' => '0.5',
               'Tk::Multi::Text' => '2.001',
               'Puppet::Log'=> '0.4',
               'Tk::Pod' => 0,
               'MLDBM' => 0,
               'DB_File' => 0
              }
             );
