--	
-- Municipality
--

delete from delta where db = 'BAN' and data = 'Municipality';

insert into delta(db, data, insee, delta)
with
d1 as
(
	select
		insee
		-- libellé normé, en majuscule (sans accent, sans trait union, et SAINT[E] abrégé en ST[E])
		--  inner replace: abréviation SAINT[E]
		--  outer replace: transformation n espaces en 1 seul		
		--,regexp_replace(regexp_replace(translate(upper(unaccent(name)), $$-'$$, '  '), 'SAINT([E]?) ', 'ST\1 '), '[ ]+', ' ') "name"

		-- libellé normé, en majuscule (sans accent, sans trait union)
		,regexp_replace(translate(upper(unaccent(name)), $$-'$$, '  '), '[ ]+', ' ') "name"
	from
		Municipality m
--	where
--		getDepartment(m.insee) in ('06', '33', '90')
)
,d2 as
(
	select
		co_insee "insee"
		,lb_in_ext_loc "name"
	from
		ran.za_ra18 rz
	where
		fl_etat = 1
		and id_typ_loc in (1, 2)

--		and
--		getDepartment((CASE WHEN rz.ID_TYP_LOC < 3 THEN rz.CO_INSEE ELSE rz.CO_INSEE_R END)) in ('06', '33', '90')
)

select
	'BAN' "db"
	,'Municipality' "data"
	,d.insee
	,'+' "delta"
from
(
	select
		insee
	from
		d1
	except
	select
		insee
	from
		d2
) d
  
union
select
	'BAN' "db"
	,'Municipality' "data"
	,d.insee
	,'-' "delta"
from
(
	select
		insee
	from
		d2
	except
	select
		insee
	from
		d1
) d

union
select
	'BAN' "db"
	,'Municipality' "data"
	,d.insee
	,'!' "delta"
from
(
	select
		d1.insee
	from
		d1
			join d2 on d1.insee = d2.insee
	where
		(d1.name != d2.name)
) d

--order by
--	1, 2

;
