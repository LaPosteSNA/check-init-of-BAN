--
-- print delta on Group items (by LAPOSTE-id, well known as co_voie)
--

select delta, count(*) from delta where db = 'BAN' and data = 'Group' group by delta ;

select
	'BAN' "db"
	,m.insee
	-- libellé normé, en majuscule (sans accent, sans trait union)
	,case
		when g.laposte is null then
			g.pk + 10000000
		else
			to_number(g.laposte, '99999999')
	end "id"
	,hn.laposte "cea"
	,regexp_replace(translate(upper(unaccent(g.name)), $$-'$$, '  '), '[ ]+', ' ') "name"
	,m.insee "l5_insee"
	--,g.id
	,d.delta
from
	public.Group g
		join Municipality m on g.municipality_id = m.pk
		join delta d on m.insee = d.insee and
			case
				when g.laposte is null then
					g.pk + 10000000
				else
					to_number(g.laposte, '99999999')
			end = to_number(d.key1, '99999999')
		left outer join Housenumber hn on g.pk = hn.parent_id
		
where
	d.db = 'BAN'
        and
        d.data = 'Group'
	and
--	d.delta in ('+', '!')
	d.delta = '!'
        
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
	,rv.co_voie "idvoie"
	,rv.co_cea "cea"
	,rv.lb_voie "name"
	,rz.co_insee "l5_insee"
	--,null
	,d.delta
from
	ran.voie_ra41 rv
		join delta d on rv.co_insee = d.insee and to_number(d.key1, '99999999') = rv.co_voie
		join ran.adresse_ra49 ra on rv.co_cea = ra.co_cea_voie
		join ran.za_ra18 rz on rz.co_cea = ra.co_cea_za
where
	d.db = 'BAN'
        and
        d.data = 'Group'
	and
--	d.delta in ('-', '!')
	d.delta = '!'

	and
	rv.fl_etat = 1
	and
	rv.fl_adr = 1
	and
	rv.fl_diffusable = 1

	and
	ra.co_cea_numero is null
	and
	ra.co_cea_l3 is null

--	and
--	co_insee = '06001'
--	and
--	lb_voie = 'LA MAGDELAINE'

order by
	2, 3, 1
;

