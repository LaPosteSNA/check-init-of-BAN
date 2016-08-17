--
-- print delta on Postcode items
--

select
	'BAN' "db"
	,m.insee
	,p.code
	,p.name
	,d.delta
from
	Postcode p
		join Municipality m on p.municipality_id = m.pk
		join delta d on m.insee = d.insee and p.code = d.key1 and p.name = d.key2
where
	d.db = 'BAN'
	and
	d.data = 'Postcode'
	and
	d.delta in ('+', '!')

union

select
	'RAN' "db"
	,z.co_insee "insee"
	,z.co_postal "code"
	,z.lb_ach_nn "name"
	,d.delta
from
	ran.za_ra18 z
		join delta d on z.co_insee = d.insee and z.co_postal = d.key1 and z.lb_ach_nn = d.key2
where
	d.db = 'BAN'
	and
	d.data = 'Postcode'
	and
	d.delta in ('-', '!')

	and
	z.fl_etat = 1
	and 
	z.id_typ_loc in (1, 2)

order by
	3, 4, 1
	;

