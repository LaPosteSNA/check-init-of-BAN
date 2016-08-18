--	
-- count delta on Group items
--

select data, delta, count(*) from delta where db = 'BAN' and data = 'Group' group by data, delta order by data, delta ;


-- match

select
	'l5_insee' "delta"
	,count(*) "count"
from
	public.Group g
		join Municipality m on g.municipality_id = m.pk
		--left outer join Housenumber hn on g.pk = hn.parent_id		
		--left outer join Postcode p on hn.postcode_id = p.pk
		join ran.voie_ra41 rv on to_number(g.laposte, '99999999') = rv.co_voie
		join ran.adresse_ra49 ra on rv.co_cea = ra.co_cea_voie
		join ran.za_ra18 rz on rz.co_cea = ra.co_cea_za
where
	--hn.number is null
	--and

	rv.fl_etat = 1
	and
	rv.fl_adr = 1
	and
	rv.fl_diffusable = 1

	and
	ra.co_cea_numero is null
	and
	ra.co_cea_l3 is null

	and
	m.insee != rz.co_insee

union

select
	'cea' "delta"
	,count(*) "count"
from
	public.Group g
		join Municipality m on g.municipality_id = m.pk
		left outer join Housenumber hn on g.pk = hn.parent_id		
		--left outer join Postcode p on hn.postcode_id = p.pk
		join ran.voie_ra41 rv on to_number(g.laposte, '99999999') = rv.co_voie
		--join ran.adresse_ra49 ra on rv.co_cea = ra.co_cea_voie
		--join ran.za_ra18 rz on rz.co_cea = ra.co_cea_za
where
	hn.number is null
	and

	rv.fl_etat = 1
	and
	rv.fl_adr = 1
	and
	rv.fl_diffusable = 1

	--and
	--ra.co_cea_numero is null
	--and
	--ra.co_cea_l3 is null

	and
	hn.laposte != rv.co_cea

	;

