delete from total;
insert into total(db, data, count)
select
	'BAN' "db"
	--,1 "id"
	,'Municipality' "data"
	,count(*) "count"
from
	Municipality
union
select
	'RAN' "db"
	--,1 "id"
	,'Municipality' "data"
	,count(*)
from
	ran.za_ra18
where
	fl_etat = 1
	and id_typ_loc in (1, 2)
union
select
	'BAN' "db"
	--,2 "id"
	,'Postcode' "data"
	,count(distinct p.code || p.name)
from
	Postcode p
		join Municipality m on p.municipality_id = m.pk
union
select
	'RAN' "db"
	--,2 "id"
	,'Postcode' "data"
	,count(distinct co_postal || lb_ach_nn)
from
	ran.za_ra18
where
	fl_etat = 1
	and id_typ_loc in (1, 2)
union
select
	'BAN' "db"
	--,3 "id"
	,'Group' "data"
	,count(*)
from
	public.Group g
--		join Municipality m on g.municipality_id = m.pk
--where
--	getDepartment(m.insee) in ('06', '33', '90')
union
select
	'RAN' "db"
	--,3 "id"
	,'Group' "data"
	,count(*)
from
	ran.voie_ra41
where
	fl_etat = 1
	and
	fl_adr = 1
	and
	fl_diffusable = 1
	
--	and
--	getDepartment(co_insee) in ('06', '33', '90')
union
select
	'BAN' "db"
	--,4 "id"
	,'Housenumber' "data"
	,count(*)	
from
	housenumber hn
		join "group" g on hn.parent_id = g.pk
--		join municipality m on g.municipality_id = m.pk
where
	hn.number is not null
--	and
--	getDepartment(m.insee) in ('06', '33', '90')
union
select
	'RAN' "db"
	--,4 "id"
	,'Housenumber' "data"
	,count(*)
from
	ran.numero_ra33 n
--		join adresse a on n.co_cea = a.co_cea_numero
--		join ran.za_ra18 z on z.co_cea = a.co_cea_za
where
	n.fl_etat = 1
	and
	n.fl_diffusable = 1
--	and
--	a.co_cea_l3 is null

--	and
--	getDepartment((CASE WHEN z.ID_TYP_LOC < 3 THEN z.CO_INSEE ELSE z.CO_INSEE_R END)) in ('06', '33', '90')

--order by
--	2, 1
	;

