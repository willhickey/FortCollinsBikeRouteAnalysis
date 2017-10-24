/*<kml xmlns="http://earth.google.com/kml/2.0"> <Document>

<Placemark> 
 <name> New point</name> 
 <Point>
  <coordinates>
   135.2, 35.4, 0.
  </coordinates>
 </Point> 
</Placemark>

</Document> </kml>*/

select top 10 female+male, male, female, pct_fem, pct_male, geom.EnvelopeCenter().Lat, geom.EnvelopeCenter().Long

declare @fc as geography
select @fc=placemark from ftcollinsplaceboundary

select top 100 geom.STIntersects(@fc), '<Placemark><name> ' + cast(female+male as varchar) + '</name><Point><coordinates>' + 
		cast(geom.EnvelopeCenter().Long as varchar) + ', ' + cast(geom.EnvelopeCenter().Lat as varchar) + 
		'</coordinates></Point> </Placemark>'
from censusblock
WHERE geom.STIntersects(@fc)=1



--distance from each censu block to each school... get the minimums and save them in the routes table.
declare @fc as geography
select @fc=placemark from ftcollinsplaceboundary

select cb.ID, d.name, geom.EnvelopeCenter().Lat, geom.EnvelopeCenter().Long , d.latitude, d.longitude, 
		abs(geom.EnvelopeCenter().Lat - d.latitude) LatDiff, abs(geom.EnvelopeCenter().Long - d.longitude) LongDiff,
		geography::STGeomFromText('POINT(' + cast(d.longitude as varchar) + ' ' +  cast(d.latitude as varchar) + ')', 4326),
		geom.EnvelopeCenter().STDistance(geography::STGeomFromText('POINT(' + cast(d.longitude as varchar) + ' ' +  cast(d.latitude as varchar) + ')', 4326)) as DistanceToDestination
from censusblock cb inner join destination d on 1=1
WHERE geom.STIntersects(@fc)=1
order by cb.ID, geom.EnvelopeCenter().STDistance(geography::STGeomFromText('POINT(' + cast(d.longitude as varchar) + ' ' +  cast(d.latitude as varchar) + ')', 4326))

