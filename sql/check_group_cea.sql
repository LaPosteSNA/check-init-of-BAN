-- list of groups (w/ CEA)

select
	m.insee
	-- libellé normé, en majuscule (sans accent, sans trait union)
	,regexp_replace(translate(upper(unaccent(g.name)), $$-'$$, '  '), '[ ]+', ' ') "name"
	,to_number(g.laposte, '99999999') "idvoie"
	,hn.laposte "cea"
	--,g.id "idban"
	,coalesce(p.code, '<SANS>')
from
	public.Group g
		join Municipality m on g.municipality_id = m.pk
		left outer join Housenumber hn on g.pk = hn.parent_id
		left outer join Postcode p on hn.postcode_id = p.pk
		
where
	hn.number is null
	and
	g.laposte is not null
order by
	1, 2
	;


