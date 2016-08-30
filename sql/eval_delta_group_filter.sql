--	
-- Group (filter: 06, 33, 90)
--

delete from delta where db = 'BAN' and data = 'Group';

-- delta

insert into delta(db, data, insee, delta, key1)
with
d1 as
(
	select
		m.insee
		-- libellé normé, en majuscule (sans accent, sans trait union)
		,regexp_replace(translate(upper(unaccent(g.name)), $$-'$$, '  '), '[ ]+', ' ') "name"
		,to_number(g.laposte, '99999999') "id"
		,hn.laposte "cea"
	from
		public.Group g
			join Municipality m on g.municipality_id = m.pk
			left outer join Housenumber hn on g.pk = hn.parent_id	
	where
		hn.number is null
		
		and
		getDepartment(m.insee) in ('06', '33', '90')
)
,d2 as
(
	select
		rv.co_insee "insee"
		,rv.lb_voie "name"
		,rv.co_voie "id"
		,rv.co_cea "cea"
	from
		ran.voie_ra41 rv
			join ran.adresse_ra49 ra on rv.co_cea = ra.co_cea_voie
			join ran.za_ra18 rz on ra.co_cea_za = rz.co_cea
	where
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
		getDepartment((CASE WHEN rz.ID_TYP_LOC < 3 THEN rz.CO_INSEE ELSE rz.CO_INSEE_R END)) in ('06', '33', '90')
)

select
	'BAN' "db"
	,'Group' "data"
	,d.insee
	,'+' "delta"
	,d.name
from
(
	select
		insee
		,name
	from
		d1
	except
	select
		insee
		,name
	from
		d2
) d
  
union
select
	'BAN' "db"
	,'Group' "data"
	,d.insee
	,'-'
	,d.name
from
(
	select
		insee
		,name
	from
		d2
	except
	select
		insee
		,name
	from
		d1
) d

union
select
	'BAN' "db"
	,'Group' "data"
	,d.insee
	,'!'
	,d.name
from
(
	select
		d1.insee
		,d1.name
	from
		d1
			join d2 on d1.insee = d2.insee and d1.name = d2.name
	where
		(d1.id != d2.id)
		or
		(d1.cea != d2.cea)
) d

--order by
--	1, 2, 3
;

