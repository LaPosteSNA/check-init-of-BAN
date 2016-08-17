--
-- print delta on Group items
--

select
	'BAN' "db"
	,m.insee
	-- libellé normé, en majuscule (sans accent, sans trait union)
	,regexp_replace(translate(upper(unaccent(g.name)), $$-'$$, '  '), '[ ]+', ' ') "name"
	,to_number(g.laposte, '99999999') "idvoie"
	,hn.laposte "cea"
	--,g.id
	,d.delta
from
	public.Group g
		join Municipality m on g.municipality_id = m.pk
		join delta d on m.insee = d.insee and regexp_replace(translate(upper(unaccent(g.name)), $$-'$$, '  '), '[ ]+', ' ') = d.key1
		left outer join Housenumber hn on g.pk = hn.parent_id
		
where
	d.db = 'BAN'
        and
        d.data = 'Group'
	and
	d.delta in ('+', '!')
        
	and
	hn.number is null

--	and
--	m.insee = '06001'
--	and
--	regexp_replace(translate(upper(unaccent(g.name)), $$-'$$, '  '), '[ ]+', ' ') = 'LA MAGDELAINE'

union

select
	'RAN' "db"
	,rv.co_insee "insee"
	,rv.lb_voie "name"
	,rv.co_voie "idvoie"
	,rv.co_cea "cea"
	--,null
	,d.delta
from
	ran.voie_ra41 rv
		join delta d on rv.co_insee = d.insee and rv.lb_voie = d.key1
where
	d.db = 'BAN'
        and
        d.data = 'Group'
	and
	d.delta in ('-', '!')

	and
	rv.fl_etat = 1
	and
	rv.fl_adr = 1
	and
	rv.fl_diffusable = 1


--	and
--	co_insee = '06001'
--	and
--	lb_voie = 'LA MAGDELAINE'

order by
	2, 3, 1
;

