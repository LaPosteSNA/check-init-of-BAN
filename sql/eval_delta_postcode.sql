--	
-- Postcode
--

delete from delta where db = 'BAN' and data = 'Postcode';

insert into delta(db, data, insee, delta, key1, key2)
with
d1 as
(
	select
		p.code
		,p.name
		,m.insee
	from
		Postcode p
			join Municipality m on p.municipality_id = m.pk
--	where
--		getDepartment(m.insee) in ('06', '33', '90')
)
,d2 as
(
	select
		co_postal "code"
		,lb_ach_nn "name"
		,co_insee "insee"
	from
		ran.za_ra18 rz
	where
		fl_etat = 1
		and
		id_typ_loc in (1, 2)
--		and
--		getDepartment((CASE WHEN rz.ID_TYP_LOC < 3 THEN rz.CO_INSEE ELSE rz.CO_INSEE_R END)) in ('06', '33', '90')
)

select
	'BAN' "db"
	,'Postcode' "data"
	,d1.insee
	,'+' "delta"
	,d.code
	,d.name
from
(
	select
		code
		,name
	from
		d1
	except
	select
		code
		,name
	from
		d2
) d
	join d1 on d.code = d1.code and d.name = d1.name
	
union
select
	'BAN' "db"
	,'Postcode' "data"
	,d2.insee
	,'-' "delta"
	,d.code
	,d.name
from
(
	select
		code
		,name
	from
		d2
	except
	select
		code
		,name
	from
		d1
) d
	join d2 on d.code = d2.code and d.name = d2.name
  
union
select
	'BAN' "db"
	,'Postcode' "data"
	,d1.insee
	,'-' "delta"
	,d.code
	,d.name
from
(
	select
		d1.code
		,d1.name
	from
		d1
			join d2 on d1.code = d2.code and d1.name = d2.name
	where
		(d1.insee != d2.insee)
) d
	join d1 on d.code = d1.code and d.name = d1.name

--order by
--	1, 2, 3

;

