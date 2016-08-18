-- match

select
	m.insee
	,to_number(g.laposte, '99999999') "idvoie"
	,hn.laposte "cea"
	-- libellé normé, en majuscule (sans accent, sans trait union)
	,g.name "lb_ban"
	,rv.lb_voie "lb_ran"
	,regexp_replace(translate(upper(unaccent(g.name)), $$-'$$, '  '), '[ ]+', ' ') "lb_match"
from
	public.Group g
		join Municipality m on g.municipality_id = m.pk
		left outer join Housenumber hn on g.pk = hn.parent_id		
		--left outer join Postcode p on hn.postcode_id = p.pk
		join ran.voie_ra41 rv on to_number(g.laposte, '99999999') = rv.co_voie
where
	hn.number is null
order by
	1, 4
	;

