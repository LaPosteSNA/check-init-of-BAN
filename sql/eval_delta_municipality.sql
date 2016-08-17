--	
-- Municipality
--

insert into delta(db, data, insee, delta)
with
d1 as
(
	select
		insee
		-- libellé normé, en majuscule (sans accent, sans trait union, et SAINT[E] abrégé en ST[E])
		--  inner replace: abréviation SAINT[E]
		--  outer replace: transformation n espaces en 1 seul		
		,regexp_replace(regexp_replace(translate(upper(unaccent(name)), $$-'$$, '  '), 'SAINT([E]?) ', 'ST\1 '), '[ ]+', ' ') "name"
	from
		Municipality
)
,d2 as
(
	select
		co_insee "insee"
		,lb_ach_nn "name"
	from
		ran.za_ra18
	where
		fl_etat = 1
		and id_typ_loc in (1, 2)
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
