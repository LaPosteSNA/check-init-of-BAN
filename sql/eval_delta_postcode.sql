--	
-- Postcode
--

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
)
,d2 as
(
	select
		co_postal "code"
		,lb_ach_nn "name"
		,co_insee "insee"
	from
		ran.za_ra18
	where
		fl_etat = 1
		and id_typ_loc in (1, 2)
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

