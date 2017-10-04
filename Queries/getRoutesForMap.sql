select pop2010, ageunder18, pct_u18, '[{color: ''' + d.color + ''',
			weight: 10,
			opacity: ' + cast(ageunder18/200.0 as varchar) + '},' + overviewpolyline + '],', *
from route r join destination d on r.destinationid = d.id
			 join origin o on r.originid = o.id
			 join CensusBlock cb on o.censusblockid = cb.id
where overviewpolyline is not null 
		and bikedistance < 3000 
		and destinationid = 11
		and d.latitude <> 0 --some online schools have no location