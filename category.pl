########################################################
## Author Name : Kalyanaraman K R
## Code Name   : Category
## PROJECT     : Indix
## Date Created: 19-Feb-2013
########################################################
#!/usr/bin/perl
use strict;
my @input_data=();
open(filehandler1,"<DEinput-2.txt");
while(my $input=<filehandler1>)
{
	push(@input_data,$input);
}
close filehandler1;
open(output1,">DEoutput-2.txt");
print output1 "Input Data\tOutput Data\n";
close output1;
open(output2,">>DEoutput-2.txt");
foreach my $input_dta (@input_data)
{
chomp($input_dta);
	if($input_dta=~m/\b[\d\,\.\s]+ghz\b|\b[\d\,\.\s]+GB\b|\b[\d\,\.\s]+MB\b|\b[\d\,\.\s\'\"]+inch\b|\b[\d\,\.\s\'\"]+CM\b|\bAndroid\b|\bTablet\s*PC\b|\bipad\b|\bBluetooth\b|\bWifi\b|\bNotebook\b|\bNetbook\b/is)
	{
		print output2 "$input_dta\tComputers\n";
	}
	else
	{
		print output2 "$input_dta\tMedicine\n";
	}
}
close output2;