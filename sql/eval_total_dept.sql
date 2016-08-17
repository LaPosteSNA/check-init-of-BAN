--
-- Municipality
--

-- BAN

insert into total(db, data, zone, count)
select
	'BAN' "db"
	,'Municipality' "data"
	,getdepartment(insee) "zone"
	,count(*) "count"
from
	Municipality
group by
	getdepartment(insee)
--order by
--	1
	;

-- RAN

insert into total(db, data, zone, count)
select
	'RAN' "db"
	,'Municipality' "data"
	,getdepartment(co_insee) "zone"
	,count(*) "count"
from
	ran.za_ra18
where
	fl_etat = 1
	and id_typ_loc in (1, 2)
group by
	getdepartment(co_insee)
--order by
--	1
	;

--	
-- Postcode
--

-- BAN

insert into total(db, data, zone, count)
select
	'BAN' "db"
	,'Postcode' "data"
	,getdepartment(m.insee) "zone"
	--,count(distinct p.code)
	,count(distinct p.code || p.name) "count"
from
	Postcode p
		join Municipality m on p.municipality_id = m.pk
group by
	getdepartment(m.insee)
--order by
--	1
	;

-- RAN

insert into total(db, data, zone, count)
select
	'RAN' "db"
	,'Postcode' "data"
	,getdepartment(co_insee) "zone"
	,count(distinct co_postal || lb_ach_nn) "count"
from
	ran.za_ra18
where
	fl_etat = 1
	and id_typ_loc in (1, 2)
group by
	getdepartment(co_insee)
order by
	1
	;

--
-- Group
--

-- BAN

insert into total(db, data, zone, count)
select
	'BAN' "db"
	,'Group' "data"
	,getdepartment(m.insee) "zone"
	,count(*) "count"
from
	public.Group g
		join Municipality m on g.municipality_id = m.pk
--where
--	getDepartment(m.insee) in ('06', '33', '90')
group by
	getdepartment(m.insee)
--order by
--	1
	;

-- RAN

insert into total(db, data, zone, count)
select
	'RAN' "db"
	,'Group' "data"
	,getdepartment(co_insee) "zone"
	,count(*) "count"
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
group by
	getdepartment(co_insee)
--order by
--	1
	;

--
-- Housenumber
--

-- BAN

insert into total(db, data, zone, count)
select
	'BAN' "db"
	,'Housenumber' "data"
	,getdepartment(m.insee) "zone"
	,count(*) "count"
from
	housenumber hn
		join "group" g on hn.parent_id = g.pk
		join municipality m on g.municipality_id = m.pk
where
	hn.number is not null
--	and
--	getDepartment(m.insee) in ('06', '33', '90')
group by
	getdepartment(m.insee)
--order by
--	1
	;

-- RAN

insert into total(db, data, zone, count)
select
	'RAN' "db"
	,'Housenumber' "data"
	,getdepartment((CASE WHEN z.ID_TYP_LOC < 3 THEN z.CO_INSEE ELSE z.CO_INSEE_R END)) "zone"
	,count(*) "count"
from
	ran.numero_ra33 n
		join ran.adresse_ra49 a on n.co_cea = a.co_cea_numero
		join ran.za_ra18 z on z.co_cea = a.co_cea_za
where
	n.fl_etat = 1
	and
	n.fl_diffusable = 1
	and
	a.co_cea_l3 is null
	
--	and
--	getDepartment((CASE WHEN z.ID_TYP_LOC < 3 THEN z.CO_INSEE ELSE z.CO_INSEE_R END)) in ('06', '33', '90')
group by
	getdepartment((CASE WHEN z.ID_TYP_LOC < 3 THEN z.CO_INSEE ELSE z.CO_INSEE_R END))
--order by
--	1
	;

