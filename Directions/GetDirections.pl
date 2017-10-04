use DBI;
use Geo::Google::PolylineEncoder;
use JSON;
use WWW::Mechanize;
use USNaviguide_Google_Encode;


my $mech = WWW::Mechanize->new();
my $connectionString = 'driver={SQL Server};Server=localhost\MSSQLSERVER,1433;Database=FtCollins;UID=scriptuser;PWD=password';
my $dbConn = DBI->connect( "DBI:ODBC:$connectionString" ,{ RaiseError => 1, AutoCommit => 1}) or die $DBI::errstr;
my $sql =  'SELECT TOP 200 r.id, o.latitude olatitude, o.longitude olongitude, d.latitude dlatitude, d.longitude dlongitude
			FROM route r JOIN origin o ON r.originid = o.id
					JOIN destination d ON r.destinationid = d.id
			WHERE RawDirections IS NULL';
my $googleAPIKey = 'AIzaSyAtB9M4Ma8ARAWIucpYGhmLyqiE2Tj078I';
my $rows = $dbConn->selectall_arrayref($sql);
foreach my $row (@$rows)
{
	#print @$row[1];
	my $bicyclingURL = 'https://maps.googleapis.com/maps/api/directions/json?origin='.@$row[1].','.@$row[2].'&destination='.@$row[3].','.@$row[4].'&avoid=highways&mode=bicycling&key='.$googleAPIKey;
	my $drivingURL = 'https://maps.googleapis.com/maps/api/directions/json?origin='.@$row[1].','.@$row[2].'&destination='.@$row[3].','.@$row[4].'&key='.$googleAPIKey;
	print "$bicyclingURL\n";
	print "$drivingURL\n";
	$mech->get($bicyclingURL);
	my $bicyclingDirectionsJSON = $mech->content;
	$mech->get($drivingURL);
	my $drivingDirectionsJSON = $mech->content;
	$bicyclingData = decode_json $bicyclingDirectionsJSON;
	$drivingData = decode_json $drivingDirectionsJSON;
	print $$bicyclingData{'routes'}[0]{'legs'}[0]{'distance'}{'value'}."\n";
	print $$drivingData{'routes'}[0]{'legs'}[0]{'distance'}{'value'}."\n";
	my $bicyclingDistance = $$bicyclingData{'routes'}[0]{'legs'}[0]{'distance'}{'value'};
	
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
	
	
	
	
	if($$bicyclingData{'status'} eq 'ZERO_RESULTS')
	{
		#print "nulling distance!\n";
		$bicyclingDistance = 'NULL'
	}
	my $drivingDistance = $$drivingData{'routes'}[0]{'legs'}[0]{'distance'}{'value'};
	$bicyclingDirectionsJSON =~ s|'|''|sig;		#replace ' with '' to escape the SQL Statement
	my $routePolyline = '[';
	my $lastStep;
	foreach my $step (@{$$bicyclingData{'routes'}[0]{'legs'}[0]{'steps'}})
	{
		$routePolyline = $routePolyline.'['.$$step{'start_location'}{'lat'}.','.$$step{'start_location'}{'lng'}.'],';
		$lastStep = $step;
		#print $$step{'start_location'}{'lat'}.",";
		#print $$step{'start_location'}{'lng'}." -> ";
		#print $$step{'end_location'}{'lat'}.",";
		#print $$step{'end_location'}{'lng'}."\n";
	}
	$routePolyline = $routePolyline.'['.$$lastStep{'end_location'}{'lat'}.','.$$lastStep{'end_location'}{'lng'}.']]';
	my $updateSQL = 		"UPDATE route ";
	$updateSQL = $updateSQL . "SET RawDirections = '$bicyclingDirectionsJSON', RoutePolyline = '$routePolyline', BikeDistance = $bicyclingDistance, CarDistance = $drivingDistance, OverviewPolyline = '$polyline' ";
	$updateSQL = $updateSQL . "WHERE ID = @$row[0]";
	#print "\n$updateSQL\n";
	my $sth = $dbConn->prepare($updateSQL);
	$sth->execute();
	sleep(1);
}
exit;
#https://maps.googleapis.com/maps/api/directions/json?origin=40.507656,-105.007048&destination=40.589363,-105.12461&avoid=highways&mode=bicycling&key=AIzaSyAtB9M4Ma8ARAWIucpYGhmLyqiE2Tj078I
