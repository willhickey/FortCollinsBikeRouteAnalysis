//https://openrouteservice.org/directions?n1=40.556575&n2=-105.117735&n3=16&b=0&k1=en-US&k2=km
//https://go.openrouteservice.org/dev-dashboard/
package main

import (
	"bufio"
	"database/sql"
	"fmt"
	"io/ioutil"
	"net/http"
	"net/url"
	"os"
	"strings"
	"time"
	//"encoding/json"
	_ "github.com/denisenkom/go-mssqldb"
	"github.com/tidwall/gjson"
)

func main() {
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

	//TODO: get Trusted Connection working to eliminate password

	//connectString := "sqlserver://scriptuser:"+ strings.TrimSpace(pw) + "@localhost:12345?database=FortCollinsBikeRouteAnalysis&encrypt=disable"
	//dbConnection, errdb := sql.Open("mssql", connectString)
	//dbConnection, errdb := sql.Open("mssql", "Server=W520\\SQLEXPRESS;user id=;encrypt=disable;database=FortCollinsBikeRouteAnalysis")
	//dbConnection, errdb := sql.Open("mssql", "Server=127.0.0.1;port=12345;user id=;password=;database=FortCollinsBikeRouteAnalysis")
	dbConnection, errdb := sql.Open("mssql", "Server=localhost\\SQLEXPRESS;user id=scriptuser;password="+strings.TrimSpace(pw)+";database=FortCollinsBikeRouteAnalysis") //works with Browser running
	if errdb != nil {
		fmt.Println(" Error open db:", errdb.Error())
	}


	getRouteSQL := `SELECT TOP 2000 r.id, o.latitude olatitude, o.longitude olongitude, d.latitude dlatitude, d.longitude dlongitude
			FROM route r JOIN origin o ON r.originid = o.id
					JOIN destination d ON r.destinationid = d.id
			WHERE Source = 'ors' AND RawDirections IS NULL`

	rows, err := dbConnection.Query(getRouteSQL)
	if err != nil {
		fmt.Println("Error querying db:", err.Error())
	}
	for rows.Next() {
		var (
			id        int
			originLat string
			originLon string
			destLat   string
			destLon   string
		)

		rows.Scan(&id, &originLat, &originLon, &destLat, &destLon)
		coords := url.Values{}
		coords.Add("coordinates", originLon+","+originLat+"|"+destLon+","+destLat)
		url := baseurl + params.Encode() + "&" + coords.Encode()
		//fmt.Println(url)
		//fmt.Println()
		response, err := http.Get(url)
		if err != nil {
			fmt.Println("Error: " + err.Error())
		}

		body, err := ioutil.ReadAll(response.Body)
		if err != nil {
			fmt.Println("Error: " + err.Error())
		}
		response.Body.Close()

		value := gjson.Get(string(body), "routes.0.geometry")
		distance := gjson.Get(string(body), "routes.0.summary.distance")

		//build the route polyline in lat,lon format. ORS returns lon,lat but I'm consuming this data in leaflet so transposing before writing to db.
		routePolyline := "["
		for _, point := range value.Array() {
			routePolyline = routePolyline + "[" + point.Array()[1].String() + "," + point.Array()[0].String() + "],"
		}
		routePolyline = routePolyline + "]"

		fmt.Println(id)
		updateSQL := fmt.Sprintf("UPDATE dbo.route SET RawDirections = '%v', BikeDistance = %v, OverviewPolyline = '%v' WHERE ID = %v", string(body), distance, routePolyline, id)
		//fmt.Println(updateSQL)
		dbConnection.Exec(updateSQL)

		//ORS free account only allows 40 requests per minute, so sleep a bit
		time.Sleep(2000000000) //2 seconds
	}

}
