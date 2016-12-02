--
-- print delta on Housenumber items (by LAPOSTE-key, well known as CEA)
--

select delta, count(*) from delta where db = 'BAN' and data = 'Housenumber' group by delta ;
--select * from delta where db = 'BAN' and data = 'Housenumber' and delta = '!' order by insee ;
--select * from delta where db = 'BAN' and data = 'Group' and delta = '!' order by insee ;

select
	'BAN' "db"
	,m.insee
	,hn.laposte "cea"
	-- libellé normé, en majuscule (sans accent, sans trait union)
	,regexp_replace(translate(upper(unaccent(g.name)), $$-'$$, '  '), '[ ]+', ' ') "name"
	,to_number(hn.number, '99999') "number"
	,hn.ordinal
	,p.code
	,to_number(g.laposte, '99999999') "id"
	,d.delta
from
	Housenumber hn
		join public.Group g on hn.parent_id = g.pk
		join Municipality m on g.municipality_id = m.pk
		join Postcode p on hn.postcode_id = p.pk
		join Delta d on m.insee = d.insee and
			case
				when hn.laposte is null then
					to_char(hn.pk + 1000000000, '9999999999')
				else
					hn.laposte
			end = d.key1
where
        d.db = 'BAN'
        and
        d.data = 'Housenumber'
        and
--	d.delta in ('+', '!')
	d.delta = '!'

	and
	hn.number is not null
	
--	and
--	getDepartment(m.insee) in ('06', '33', '90')

	-- not already detected for Group ?
	and
	not exists(
		select
			1
		from
			Delta d2
		where
			d2.db = 'BAN'
			and
			d2.data = 'Group'
			and
			d2.delta = '!'
			and
			d2.key1 = g.laposte
	)
union

select
	'RAN' "db"
	,(CASE WHEN z.ID_TYP_LOC < 3 THEN z.CO_INSEE ELSE z.CO_INSEE_R END) "insee"
	,n.co_cea "cea"
	,v.lb_voie "name"
	,n.no_voie "number"
	,n.lb_ext "ordinal"
	,z.co_postal "code"
	,v.co_voie "id"
	,d.delta
from
	ran.numero_ra33 n
		join ran.adresse_ra49 a on n.co_cea = a.co_cea_numero
		join ran.voie_ra41 v on a.co_cea_voie = v.co_cea
		join ran.za_ra18 z on z.co_cea = a.co_cea_za
		join delta d on (CASE WHEN z.ID_TYP_LOC < 3 THEN z.CO_INSEE ELSE z.CO_INSEE_R END) = d.insee and n.co_cea = d.key1
where
        d.db = 'BAN'
        and
        d.data = 'Housenumber'
        and
--	d.delta in ('-', '!')
	d.delta = '!'

        and
	n.fl_etat = 1
	and
	n.fl_diffusable = 1
	and
	a.co_cea_l3 is null
	
--	and
--	getDepartment((CASE WHEN z.ID_TYP_LOC < 3 THEN z.CO_INSEE ELSE z.CO_INSEE_R END)) in ('06', '33', '90')

	-- not already detected for Group ?
	and
	not exists(
		select
			1
		from
			Delta d2
		where
			d2.db = 'BAN'
			and
			d2.data = 'Group'
			and
			d2.delta = '!'
			and
			to_number(d2.key1, '99999999') = v.co_voie
	)

order by
	2, 4, 5, 6, 1
;

