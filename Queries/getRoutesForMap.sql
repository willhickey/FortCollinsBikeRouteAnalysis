select pop2010, ageunder18, pct_u18, '[{color: ''' + d.color + ''',
weight: 10,
opacity: ' + cast(ageunder18/200.0 as varchar) + '},' + overviewpolyline + '],'--, *
from route r join destination d on r.destinationid = d.id
			 join origin o on r.originid = o.id
			 join CensusBlock cb on o.censusblockid = cb.id
where overviewpolyline is not null 
		and bikedistance < 1609		--<1 mile for elementary, 1.5 miles for middle 
		--and destinationid = 11
		and DestinationTypeid = 2		--2=elementary, 3=middle
		and d.latitude <> 0 --some online schools have no location
UNION
select pop2010, ageunder18, pct_u18, '[{color: ''' + d.color + ''',
weight: 10,
opacity: ' + cast(ageunder18/200.0 as varchar) + '},' + overviewpolyline + '],'--, *
from route r join destination d on r.destinationid = d.id
			 join origin o on r.originid = o.id
			 join CensusBlock cb on o.censusblockid = cb.id
where overviewpolyline is not null 
		and bikedistance < 2413		--<1 mile for elementary, 1.5 miles for middle 
		--and destinationid = 11
		and DestinationTypeid = 3		--2=elementary, 3=middle
		and d.latitude <> 0 --some online schools have no location
		AND r.source = 'ORS'