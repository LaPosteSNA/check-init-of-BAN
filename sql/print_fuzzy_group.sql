-- before call, set insee variable, as:
--  \set insee '''06004'''

select
	m1.insee
	,g1.name "v1"
	,g1.attributes -> 'source' "s1"
	,g2.name "v2"
	,g2.attributes -> 'source' "s2"
	,levenshtein(g1.name, g2.name)
from
	"group" g1
		join municipality m1 on g1.municipality_id = m1.pk
	,"group" g2
		join municipality m2 on g2.municipality_id = m2.pk
where
	g1.pk < g2.pk
	and
	m1.insee = :insee
	and
	m2.insee = :insee
	and
	levenshtein(g1.name, g2.name) < 3

order by
	1, 4 desc
	;
