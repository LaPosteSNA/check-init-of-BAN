--
-- print delta on Municipality items
--

select
	'BAN' "db"
	,m.insee
	,m.name
	-- libellé normé, en majuscule (sans accent, sans trait union, et SAINT[E] abrégé en ST[E])
	,regexp_replace(regexp_replace(translate(upper(unaccent(m.name)), $$-'$$, '  '), 'SAINT([E]?) ', 'ST\1 '), '[ ]+', ' ') "norme"
	,d.delta
from
	Municipality m
		join delta d on m.insee = d.insee
where
	d.db = 'BAN'
	and
	d.data = 'Municipality'
	and
	d.delta in ('+', '!')
union
select
	'RAN' "db"
	,z.co_insee "insee"
	,z.lb_nn "name"
	,z.lb_ach_nn "norme"
	,d.delta
from
	ran.za_ra18 z
		join delta d on z.co_insee = d.insee
where
	d.db = 'BAN'
	and
	d.data = 'Municipality'
	and
	d.delta in ('-', '!')

	and
	z.fl_etat = 1
	and 
	z.id_typ_loc in (1, 2)

order by
	2, 1
;
