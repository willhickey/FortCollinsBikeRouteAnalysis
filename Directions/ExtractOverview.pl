#GetDirections only gets the intersection coordinates, but I saved the raw json response in Route.RawDirections. That contains an encoded "Overview Polyline" that snaps
#to roads. This script will populate the new field route.OverviewPolyline from that data.
use DBI;
use JSON;
use WWW::Mechanize;
use USNaviguide_Google_Encode;
use Geo::Google::PolylineEncoder;

my $mech = WWW::Mechanize->new();
my $connectionString = 'driver={SQL Server};Server=localhost\MSSQLSERVER,1433;Database=FtCollins;UID=scriptuser;PWD=password';
my $dbConn = DBI->connect( "DBI:ODBC:$connectionString" ,{ RaiseError => 1, AutoCommit => 1}) or die $DBI::errstr;
my $sql =  'SELECT TOP 5000 id, RawDirections
			FROM route
			WHERE OverviewPolyline IS NULL';
my $googleAPIKey = 'AIzaSyAtB9M4Ma8ARAWIucpYGhmLyqiE2Tj078I';
$dbConn->{LongReadLen} = 10000000;
my $rows = $dbConn->selectall_arrayref($sql);
foreach my $row (@$rows)
{
	my ($id, $rawJSON) = @$row;
	print $id."\t";
	$bicyclingData = decode_json $rawJSON;
	my $encodedPolyline = $$bicyclingData{'routes'}[0]{'overview_polyline'}{'points'}."\n";
	print "$encodedPolyline\n";
	my $encoder = Geo::Google::PolylineEncoder->new();
	my $points = $encoder->decode_points($encodedPolyline);
	my $polyline = "[";
	foreach my $point (@$points)
	{
		$polyline = $polyline."[".$$point{'lat'}.",".$$point{'lon'}."],";
		#print "\t".$$point{'lat'}.",".$$point{'lon'}."\n";
	}
	$polyline =~ s|,$|]|;
	print "$polyline\n";
	my $updateSQL = 		"UPDATE route ";
	$updateSQL = $updateSQL . "SET OverviewPolyline = '$polyline' ";
	$updateSQL = $updateSQL . "WHERE ID = $id";
	my $sth = $dbConn->prepare($updateSQL);
	$sth->execute();
}
