City boundary data available here:
http://www.census.gov/geo/maps-data/data/cbf/cbf_place.html


Shapefile upaloader for sql server 2008
C:\github\FCStreetAnalysis\data\cb_2014_us_ua10_500k\cb_2014_us_ua10_500k.shp
SRID 4269 
cb_2014_us_ua10_500k

KML2SQL
C:\github\FCStreetAnalysis\data\cb_2014_08_place_500k\FortCollinsSimplified.kml
FtCollinsPlaceBoundary
Geography mode



select top 100 '<Placemark><name> ' + cast(female+male as varchar) + '</name><Point><coordinates>' + 
		cast(geom.EnvelopeCenter().Long as varchar) + ', ' + cast(geom.EnvelopeCenter().Lat as varchar) + 
		'</coordinates></Point> </Placemark>'
		, geom.STAsText()
from censusblock
where ID < 100

select top 10 *, geom.STAsText()
from cityboundary
where name10 like '%collins%'


select *
from ftcollinsplaceboundary


declare @fc as geography
select @fc=placemark from ftcollinsplaceboundary
select top 5000 geom.STIntersects(@fc), female+male as [pop], '<Placemark><name> ' + cast(female+male as varchar) + '</name><Point><coordinates>' + 
		cast(geom.EnvelopeCenter().Long as varchar) + ', ' + cast(geom.EnvelopeCenter().Lat as varchar) + 
		'</coordinates></Point> </Placemark>', geom
from censusblock
WHERE geom.STIntersects(@fc)=1



select top 10 geom.STNumPoints(), geom.STGeometryType(), geom.STStartPoint().Long
from censusblock

declare @fc as geography
set @fc = geography::STGeomFromText('POLYGON((-105.0517540000001 40.608334000000042, -105.05032900000012 40.607230000000037, -105.0499970000001 40.607054000000034, -105.0498750000001 40.606951000000038, -105.0497830000001 40.606829000000033, -105.0497290000001 40.606696000000035, -105.0497130000001 40.606553000000041, -105.0497410000001 40.606169000000037, -105.0496590000001 40.606176000000033, -105.0493530000001 40.606161000000043, -105.0491300000001 40.606119000000042, -105.0488520000001 40.606022000000038, -105.0486070000001 40.60589200000004, -105.0483990000001 40.605826000000036, -105.0482020000001 40.605791000000032, -105.0480780000001 40.605789000000037, -105.04789600000009 40.605787000000035, -105.0477200000001 40.605769000000038, -105.04754800000011 40.605731000000041, -105.0473380000001 40.605658000000034, -105.0469430000001 40.606171000000039, -105.0472240000001 40.606489000000032, -105.0474540000001 40.606659000000036, -105.0476060000001 40.60672500000004, -105.0477930000001 40.606775000000042, -105.04795200000011 40.606804000000039, -105.04842000000009 40.606890000000043, -105.04862200000009 40.606951000000038, -105.0487660000001 40.607011000000035, -105.0488880000001 40.607077000000039, -105.0490040000001 40.607159000000038, -105.04911200000009 40.607264000000036, -105.04920500000011 40.607374000000043, -105.0494070000001 40.607566000000034, -105.04958000000011 40.607665000000033, -105.0498680000001 40.607797000000041, -105.05027200000011 40.607945000000043, -105.05061000000011 40.608049000000037, -105.05140300000009 40.608231000000039, -105.0516770000001 40.608308000000036, -105.0517540000001 40.608334000000042))', 4326)

select male, female, geom.STAsText()
from dbo.CensusBlock
where geom.STIntersects(@fc) = 1

WHERE Geom.STStartPoint().Lat between 40.58 and 40.62
and geom.STStartPoint().Long > -105.1 and geom.STStartPoint().Long < -105.05