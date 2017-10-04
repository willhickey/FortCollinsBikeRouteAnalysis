{"type":"Feature","id":"08","properties":{"name":"Colorado","density":49.33},"geometry":{"type":"Polygon","coordinates":[[[-107.919731,41.003906],[-105.728954,40.998429],[-104.053011,41.003906],[-102.053927,41.003906],[-102.053927,40.001626],[-102.042974,36.994786],[-103.001438,37.000263],[-104.337812,36.994786],[-106.868158,36.994786],[-107.421329,37.000263],[-109.042503,37.000263],[-109.042503,38.166851],[-109.058934,38.27639],[-109.053457,39.125316],[-109.04798,40.998429],[-107.919731,41.003906]]]}},



select geom, 44160*ageunder18/geom.STArea(), 
255-(44160*ageunder18/geom.STArea()),
convert(varbinary(8), cast(coalesce(255-(44160*ageunder18/geom.STArea()), 256) as int)),
'#FF' 
			+ right(master.dbo.fn_varbintohexstr(convert(varbinary(8), cast(coalesce(255-(44160*ageunder18/geom.STArea()), 255) as int))), 2)
			+ right(master.dbo.fn_varbintohexstr(convert(varbinary(8), cast(coalesce(255-(44160*ageunder18/geom.STArea()), 255) as int))), 2)
			+ 'FF' as FillColor, 'gray' as LineColor

from censusblock cb 
	join origin o on o.censusblockid = cb.id
	join route r on r.originid = o.id
--Where DestinationID = 11