
select
	m.insee
	,g.name
	,count(*)
from
	"group" g
		join municipality m on g.municipality_id = m.pk
group by
	m.insee
	,g.name
having
	count(*) > 1
	;
