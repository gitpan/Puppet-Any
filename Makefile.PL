use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
              'NAME'	   => 'Puppet::Any',
              'VERSION_FROM' => 'Any.pm', # finds $VERSION
              'dist' => {COMPRESS=>'gzip -9f', SUFFIX => 'gz'},
              'PREREQ_PM' =>
              {
               'Tk' => 0,
               'Puppet::Log'=> 0
              }
             );
