--	
-- eval delta on Group items (by LAPOSTE-id, well known as co_voie)
--

delete from delta where db = 'BAN' and data = 'Group';

insert into delta(db, data, insee, delta, key1)
with
d1 as
(
	select
		m.insee
		-- libellé normé, en majuscule (sans accent, sans trait union)
		,regexp_replace(translate(upper(unaccent(g.name)), $$-'$$, '  '), '[ ]+', ' ') "name"
		,m.insee "l5_insee"
		,case
			when g.laposte is null then
				g.pk + 10000000
			else
				to_number(g.laposte, '99999999')
		end "id"
		,hn.laposte "cea"
	from
		public.Group g
			join Municipality m on g.municipality_id = m.pk
			left outer join Housenumber hn on g.pk = hn.parent_id	
	where
		hn.number is null

--		and
--		m.insee = '06001'

--		and
--		getDepartment(m.insee) in ('06', '33', '90')

)
,d2 as
(
	select
		rv.co_insee "insee"
		,rv.lb_voie "name"
		,rz.co_insee "l5_insee"
		,rv.co_voie "id"
		,rv.co_cea "cea"
	from
		ran.voie_ra41 rv
			join ran.adresse_ra49 ra on rv.co_cea = ra.co_cea_voie
			join ran.za_ra18 rz on rz.co_cea = ra.co_cea_za
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

--		and
--		rv.co_insee = '06001'

--		and
--		getDepartment((CASE WHEN rz.ID_TYP_LOC < 3 THEN rz.CO_INSEE ELSE rz.CO_INSEE_R END)) in ('06', '33', '90')
)

select
	'BAN' "db"
	,'Group' "data"
	,d.insee
	,'+' "delta"
	,d.id
from
(
	select
		insee
		,id
	from
		d1
	except
	select
		insee
		,id
	from
		d2
) d
  
union
select
	'BAN' "db"
	,'Group' "data"
	,d.insee
	,'-'
	,d.id
from
(
	select
		insee
		,id
	from
		d2
	except
	select
		insee
		,id
	from
		d1
) d

union
select
	'BAN' "db"
	,'Group' "data"
	,d.insee
	,'!'
	,d.id
from
(
	select
		d1.insee
		,d1.id
	from
		d1
			join d2 on d1.insee = d2.insee and d1.id = d2.id
	where
		(d1.l5_insee != d2.l5_insee)
		or
		(d1.name != d2.name)
		or
		(d1.cea != d2.cea)
) d

--order by
--	1, 2, 3
;

