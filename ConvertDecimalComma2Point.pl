use strict;
use warnings;

# read path to input file:
my $file;
$file = $ARGV[0];#'D:\users\scw\tmp\ToolScope_read_perl_TEST.csv';
#print "$file\n";

# file name for temporary file:
my $tmpFileName = 'tmp_PERL_ConvertDecimalComma2Point.csv';


open(my $data, '<', $file) or die "Could not open '$file' $!\n";



open(my $fh, '>', $tmpFileName)  or die "Could not open temporary file '$tmpFileName'$!\n";

my $NumLines = 1;

while (my $line = <$data>) {
    chomp $line;
    # print "$line \n"; # prints original line
    $line =~ tr/,/./;
    # print "$line \n"; # prints new line with replaced characters
    # $line =~ tr/;/,/; if you want to replace , with ;,

    print $fh "$line \n";

    $NumLines += 1;
}
close $fh or die $!;
close $data or die $!;

print "$tmpFileName $NumLines";

