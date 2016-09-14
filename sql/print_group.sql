
select
	m.insee
	,g.*
from
	"group" g
		join municipality m on g.municipality_id = m.pk
where
	g.name like '%' || :group || '%'
	and
	m.insee = :insee
	;
