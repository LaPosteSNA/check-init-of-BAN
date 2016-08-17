--
-- print delta on Housenumber items
--

select
	'BAN' "db"
	,m.insee
	-- libellé normé, en majuscule (sans accent, sans trait union)
	,regexp_replace(translate(upper(unaccent(g.name)), $$-'$$, '  '), '[ ]+', ' ') "name"
	,to_number(hn.number, '99999') "number"
	,hn.ordinal
	,hn.laposte "cea"
	,p.code
	,d.delta
from
	Housenumber hn
		join public.Group g on hn.parent_id = g.pk
		join Municipality m on g.municipality_id = m.pk
		join Postcode p on hn.postcode_id = p.pk
		join Delta d on m.insee = d.insee and regexp_replace(translate(upper(unaccent(g.name)), $$-'$$, '  '), '[ ]+', ' ') = d.key1 and hn.number = d.key2 and coalesce(hn.ordinal, ' ') = coalesce(d.key3, ' ')
where
        d.db = 'BAN'
        and
        d.data = 'Housenumber'
        and
        d.delta in ('+', '!')

	and
	hn.number is not null
	
	and
	getDepartment(m.insee) in ('06', '33', '90')

union

select
	'RAN' "db"
	,(CASE WHEN z.ID_TYP_LOC < 3 THEN z.CO_INSEE ELSE z.CO_INSEE_R END) "insee"
	,v.lb_voie "name"
	--,v.co_voie "id"
	,n.no_voie "number"
	,n.lb_ext "ordinal"
	,n.co_cea "cea"
	,z.co_postal "code"
	,d.delta
from
	ran.numero_ra33 n
		join ran.adresse_ra49 a on n.co_cea = a.co_cea_numero
		join ran.voie_ra41 v on a.co_cea_voie = v.co_cea
		join ran.za_ra18 z on z.co_cea = a.co_cea_za
		join delta d on (CASE WHEN z.ID_TYP_LOC < 3 THEN z.CO_INSEE ELSE z.CO_INSEE_R END) = d.insee and v.lb_voie = d.key1 and n.no_voie = to_number(d.key2, '99999') and coalesce(n.lb_ext, ' ') = coalesce(d.key3, ' ')
where
        d.db = 'BAN'
        and
        d.data = 'Housenumber'
        and
        d.delta in ('-', '!')

        and
	n.fl_etat = 1
	and
	n.fl_diffusable = 1
	and
	a.co_cea_l3 is null
	
	and
	getDepartment((CASE WHEN z.ID_TYP_LOC < 3 THEN z.CO_INSEE ELSE z.CO_INSEE_R END)) in ('06', '33', '90')

order by
	2, 3, 4, 5, 1
;

