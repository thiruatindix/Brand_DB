
### This is thiru's test file###
use strict;
use LWP::UserAgent;
use URI::Escape;
use HTTP::Cookies;
use DBI;
my $ua=LWP::UserAgent->new;
$ua->agent("User-Agent:  Mozilla/5.0 (Windows; U; Windows NT 5.1; en-US; rv:1.9.1.2) Gecko/20090729 Firefox/3.5.2 ( .NET4.0E)");
#################Database Connection###################
my $dsn ='driver={SQL Server};Server=;database=;uid=;pwd=;';
my $dbh = &sql_connect;
$dbh-> {'LongTruncOk'} = 1; 
$dbh-> {'LongReadLen'} = 90000;
########################################################
my @medicine_array=("Nutrition & Wellness","Sports Nutrition","Vitamins & Supplements","Weight Management","Nutrition Bars","Nutrition Drinks & Shakes","Nutrition Gels","Weight Loss Products","Appetite Control & Suppressants","Diet Bars","Diet Shakes","Diuretics","Supplements","Vitamins ","Minerals","Baby & Child Care","Diaper Care","Health Care","Personal Care","Baby Wipes","Diaper Pails & Refills","Disposable Diapers","Training Pants","Allergy Medicine","Bandages","Cold & Flu Remedies","Pain Relievers","Children's Vitamins","Baby Bath","Baby Skin Care","Hair Care","Nursing Pads","Oral Hygiene","Household Supplies","Bathroom Cleaners","Kitchen Cleaners"," Bathroom Cleaners","Carpet Cleaners & Deodorizers","Cleaning Tools","Cloths & Wipes","Drain Openers ","Floor Cleaners","Furniture & Wood Polishes","Glass Cleaners","Kitchen Cleaners","Metal Polishes","Paper Towels","Upholstery Cleaners","Medical Supplies & Equipment"," Bathroom Aids & Safety","Beds & Accessories","Braces, Splints & Slings","Daily Living Aids","Health Monitors","Mobility Aids & Equipment","Occupational & Physical Therapy Aids","Tests","Personal Care"," Bath & Body","Body Art","Deodorants & Antiperspirants","Ear Care","Eye Care","Feminine Care","Foot Care","Hair Care","Lip Care Products","Oral Hygiene","Shaving & Hair Removal","Skin Care","Sexual Wellness","Safer Sex","Adult Toys & Games","Bondage Gear & Accessories","Fetish Wear","Sensual Delights","Sex Furniture","Sexual Enhancers","Novelties","Stationery & Party Supplies","Gift Wrapping Supplies","Party Supplies","Stationery ","Gift Bags","Gift Boxes","Gift Wrap Bows","Gift Wrap Cellophane","Gift Wrap Paper","Gift Wrap Ribbons","Wrapping Sets","Wrapping Tissue","Enclosure Cards","Gift Wrap Tags","Cake Decorations","Cards","Decorations","Favors","Hats","Invitations","Party Packs","Tableware ","Children's Party Supplies","Sky Lanterns","Coffee & Espresso Machine Cleaning Products");
my @computer_array=("Computers & Accessories ","Desktop Computers","Laptop Computers","Netbook Computers","Electronics");
########################################################
open sm,"Indix_input.txt";

while(<sm>)
{
	my $input_title=$_;		
	my $input_title1=$input_title;
	$input_title1=~s/(?:\d+)?\s*Tablets//igs;	
	print "$input_title\n";
	my $product_url="http://www.amazon.com/s/ref=nb_sb_noss?url=search-alias%3Daps&field-keywords=".$input_title1;
	my $product_content = &agent_get ( $product_url );	
	my($breadcrumb,$status);
	if($product_content=~m/<h2\s*>Department<\/h2>\s*([\w\W]*?)\s*<\/a>\s*<\/li>\s*<\/ul>\s*<\/li>/is)
	{
		$breadcrumb=$1;		
		$breadcrumb=~s/amp\;//igs;
		$breadcrumb=~s/\&\#8250\;/\>/igs;
		$breadcrumb=~s/\s+/ /igs;
		$breadcrumb=~s/<[^>]*?>//igs;
	}	
	for(my $ca=0;$ca<@computer_array;$ca++)
	{
		if($breadcrumb=~m/$computer_array[$ca]/is)
		{
			$status='Computers';			
			goto insert;
		}
		if($input_title1=~m/\biPed|Electronics|Bluetooth|Camera|Android|Dual\s*core\b/is)
		{
			print "Computer category..\n";				
			$status='Computers';			
			goto insert;			
		}
		elsif($input_title1=~m/\b(\d+[\-\/\d\.]*)\s*(?:GB|Inch|RAM|GHz|mb)\b/is)
		{		
			print "Computer category..\n";				
			$status='Computers';			
			goto insert;			
		}
	}		
	for(my $pw=0;$pw<@medicine_array;$pw++)
	{
		if($breadcrumb=~m/$medicine_array[$pw]/is)
		{
			$status='Medicine';			
			goto insert;
		}
		if($input_title1=~m/\bAntacid|Melatonin|Activox|Calcium|Iron|Magnesium|Selenium|MetagenicsVasotensin\b/is)
		{
			print "Medicine category..\n";				
			$status='Medicine';			
			goto insert;
		}
		$status='Medicine' if($breadcrumb=~m/Health/is);
	}
			
	my $category=$1 if($product_content=~m/\=\"bold\s*orng\">\s*([^>]*?)\s*<\/span>/is);	
	$status='Medicine' if($category=~m/Health/is);	
	insert:	
	print "Breadcrumb=>$breadcrumb\n";
	print "Status=>$status\n";
	$product_url =~s/\'/\'\'/igs;	$input_title =~s/\'/\'\'/igs;
	my $query = "insert into merchant_site_crawling_output (Category,product_url,Title,site_name) values (\'$status\',\'$product_url\',\'$input_title\',\'Indix.com\')";
	&sql_execute($query);	
}
sub agent_get()
{
	my $url = shift;
	my $status_count=0;
	ping2:	
	my $cookie_file = "Cookie_indix.txt";
	unlink ($cookie_file);
	my $cookie = HTTP::Cookies->new(file=>$cookie_file,autosave=>1);
	$ua->cookie_jar($cookie);
	my $req = HTTP::Request->new(GET=>"$url");
	$req->header("Content-Type"=> "application/x-www-form-urlencoded");
	$req->header("Accept"=> "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
	my $res = $ua->request($req);
	$cookie->extract_cookies($res);
	$cookie->save;
	$cookie->add_cookie_header($req);
	my $code=$res->code;
	print "CODE :: $code\n";
	my $content;	
	if($code =~m/50/is)
	{		
		print "\nNET FAILURE";		
		sleep 100;
		goto ping2;				
	}
	elsif($code =~m/404/is)
	{
		print "\nProduct Not Found\n";
		$content = $res->content;
	}
	elsif($code =~m/40/is)
	{
		print "\nPlease Wait getting products\n";		
		sleep 100;
		goto ping2;				
	}
	elsif($code =~m/20/is)
	{
		$content = $res->content;
	}	
	return ($content);
}

sub sql_execute
{
	my $query = shift;	
	reexecute:
	my $data;	
	$dbh-> {'LongTruncOk'} = 1; 
	$dbh-> {'LongReadLen'} = 90000;
	
	$data = $dbh->prepare($query) 	or die $dbh->errstr;	
	if ($data->execute())
	{
		$data->finish;
	}
	else
	{
		$dbh  = DBI->connect("DBI:ODBC:$dsn") or warn "$DBI::errstr\a\a\n";
		goto reexecute;
	}
}
sub sql_connect
{
	Reconnect:my $dbh  = DBI->connect("DBI:ODBC:$dsn") or warn "$DBI::errstr\a\a\n";
	
	if(defined $dbh)
	{
		print "Data base Connected successfully\n";
	}
	else
	{
		print "Please Check Ur Network\n";
		sleep(10);
		goto Reconnect;
	}
	return $dbh;
}
