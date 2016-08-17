--	
-- eval delta on Group items
--

--insert into delta(db, data, insee, delta, key1)
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
		m.insee = '06001'
)
,d2 as
(
	select
		co_insee "insee"
		,lb_voie "name"
		,co_voie "id"
		,co_cea "cea"
	from
		ran.voie_ra41 rv
	where
		rv.fl_etat = 1
		and
		rv.fl_adr = 1
		and
		rv.fl_diffusable = 1

		and
		co_insee = '06001'
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

