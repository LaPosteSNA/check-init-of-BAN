--	
-- Housenumber
--

delete from delta where db = 'BAN' and data = 'Housenumber';

-- delta

insert into delta(db, data, insee, delta, key1, key2, key3)
with
d1 as
(
	select
		m.insee
		-- libellé normé, en majuscule (sans accent, sans trait union)
		,regexp_replace(translate(upper(unaccent(g.name)), $$-'$$, '  '), '[ ]+', ' ') "name"
		--,g.laposte "id"
		,to_number(hn.number, '99999') "number"
		,hn.ordinal
		,hn.laposte "cea"
		,p.code
	from
		housenumber hn
			join "group" g on hn.parent_id = g.pk
			join municipality m on g.municipality_id = m.pk
			join postcode p on hn.postcode_id = p.pk
	where
		hn.number is not null
		
		--and
		--getDepartment(m.insee) in ('06', '33', '90')
)
,d2 as
(
	select
		(CASE WHEN z.ID_TYP_LOC < 3 THEN z.CO_INSEE ELSE z.CO_INSEE_R END) "insee"
		,v.lb_voie "name"
		--,v.co_voie "id"
		,n.no_voie "number"
		,n.lb_ext "ordinal"
		,n.co_cea "cea"
		,z.co_postal "code"
	from
		ran.numero_ra33 n
			join ran.adresse_ra49 a on n.co_cea = a.co_cea_numero
			join ran.voie_ra41 v on a.co_cea_voie = v.co_cea
			join ran.za_ra18 z on z.co_cea = a.co_cea_za
	where
		n.fl_etat = 1
		and
		n.fl_diffusable = 1
		and
		a.co_cea_l3 is null
		
		--and
		--getDepartment((CASE WHEN z.ID_TYP_LOC < 3 THEN z.CO_INSEE ELSE z.CO_INSEE_R END)) in ('06', '33', '90')
)

select
	'BAN' "db"
	,'Housenumber' "data"
	,d.insee
	,'+' "delta"
	,d.name
	,d.number
	,d.ordinal
from
(
	select
		insee
		,name
		,"number"
		,ordinal
	from
		d1
	except
	select
		insee
		,name
		,"number"
		,ordinal
	from
		d2
) d
  
union
select
	'BAN' "db"
	,'Housenumber' "data"
	,d.insee
	,'-'
	,d.name
	,d.number
	,d.ordinal
from
(
	select
		insee
		,name
		,"number"
		,ordinal
	from
		d2
	except
	select
		insee
		,name
		,"number"
		,ordinal
	from
		d1
) d

union
select
	'BAN' "db"
	,'Housenumber' "data"
	,d.insee
	,'!'
	,d.name
	,d.number
	,d.ordinal
from
(
	select
		d1.insee
		,d1.name
		,d1."number"
		,d1.ordinal
	from
		d1
			join d2 on d1.insee = d2.insee and d1.name = d2.name and d1.number = d2.number and coalesce(d1.ordinal, ' ') = coalesce(d2.ordinal, ' ')
	where
		(d1.cea != d2.cea)
		or
		(d1.code != d2.code)
) d

;

