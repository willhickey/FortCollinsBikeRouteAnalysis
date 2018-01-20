package main
import "io/ioutil"
import "net/url"
import "database/sql"
import "bufio"
import "os"
import "strings"
//import "net/http"
import "fmt"
import _ "github.com/denisenkom/go-mssqldb"

func main(){
	orsKey, _ := ioutil.ReadFile("openrouteservicekey.txt")
	baseurl := "https://api.openrouteservice.org/directions?"
	params := url.Values{}
	params.Add("profile", "foot-walking")
	params.Add("api_key", string(orsKey[:]))
	params.Add("preference", "recommended")
	params.Add("units", "m")
	params.Add("language", "en")
	params.Add("geometry", "true")
	params.Add("geometry_format", "polyline") //encodedpolyline
	params.Add("geometry_simplify", "")
	params.Add("instructions", "true")
	params.Add("instructions_format", "text")
	params.Add("roundabout_exits", "")
	params.Add("attributes", "")
	params.Add("maneuvers", "")
	params.Add("radiuses", "")
	params.Add("bearings", "")
	params.Add("continue_straight", "")
	params.Add("elevation", "")
	params.Add("extra_info", "steepness")
	params.Add("optimized", "true")
	params.Add("options", "{}")


	reader := bufio.NewReader(os.Stdin)
	fmt.Print("Enter password: ")
	pw, _ := reader.ReadString('\n')
	connectString := "sqlserver://scriptuser:"+ strings.TrimSpace(pw) + "@localhost:1433?database=FtCollins&encrypt=disable"
	dbConnection, errdb := sql.Open("mssql", connectString)
	if errdb != nil {
		fmt.Println(" Error open db:", errdb.Error())
	}


	getRouteSQL := `SELECT TOP 1 r.id, o.latitude olatitude, o.longitude olongitude, d.latitude dlatitude, d.longitude dlongitude
			FROM route r JOIN origin o ON r.originid = o.id
					JOIN destination d ON r.destinationid = d.id
			WHERE Source = 'ors' AND RawDirections IS NULL`

	rows, err := dbConnection.Query(getRouteSQL)
	if err!= nil {
		fmt.Println("Error querying db:", err.Error())
	}
	for rows.Next(){
		var (
				id int
				originLat string
				originLon string
				destLat string
				destLon string
			)
		
		rows.Scan(&id, &originLat, &originLon, &destLat, &destLon)
		coords := url.Values{}
		coords.Add("coordinates", originLon + "," + originLat + "|" + destLon + "," + destLat)
		url := baseurl + params.Encode() + "&" + coords.Encode()
		fmt.Println(url)
	}
}
