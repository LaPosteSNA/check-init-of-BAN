\i sql/print_total.sql
\i sql/print_delta.sql

with
nr_group as (
	select count(*)::numeric nr_grp_total, count(laposte)::numeric nr_grp_id from "group" 
)
,nr_group_cea as (
	select count(laposte)::numeric nr_grp_cea from housenumber where number is null
)
,nr_housenumber as (
	select count(*)::numeric nr_hn_total, count(laposte)::numeric nr_hn_cea, count(postcode_id)::numeric nr_hn_postcode from housenumber where number is not null

)

,nr_group_ran as (
	select
		count(distinct rv.co_voie) nr_grp_ran
	from

		ran.voie_ra41 rv
			join ran.adresse_ra49 ra on rv.co_cea = ra.co_cea_voie
			join ran.za_ra18 rz on rz.co_cea = ra.co_cea_za
	where
		rv.fl_etat = 1
		and
		rv.fl_adr = 1
		and
		rv.fl_diffusable = 1

		and
		ra.co_cea_numero is null
		and
		ra.co_cea_l3 is null

--		and
--		rv.co_insee = '06001'

		and
		getDepartment((CASE WHEN rz.ID_TYP_LOC < 3 THEN rz.CO_INSEE ELSE rz.CO_INSEE_R END)) in ('06', '33')

)

,nr_housenumber_ran as (
	select
		count(distinct rn.co_cea) nr_hn_ran
	from

		ran.numero_ra33 rn
			join ran.adresse_ra49 ra on rn.co_cea = ra.co_cea_numero
			join ran.za_ra18 rz on rz.co_cea = ra.co_cea_za
	where
		rn.fl_etat = 1
		and
		rn.fl_diffusable = 1

		and
		ra.co_cea_l3 is null

--		and
--		rv.co_insee = '06001'

		and
		getDepartment((CASE WHEN rz.ID_TYP_LOC < 3 THEN rz.CO_INSEE ELSE rz.CO_INSEE_R END)) in ('06', '33')

)

select
	round((nr_grp_id / nr_grp_total)* 100, 2) "% VOIES avec ID_POSTE"
	,round((nr_grp_cea / nr_grp_total)* 100, 2) "% VOIES avec CEA_POSTE"
	,round((nr_hn_cea / nr_hn_total)* 100, 2) "% NUMEROS avec CEA_POSTE"
	,round((nr_hn_postcode / nr_hn_total)* 100, 2) "% NUMEROS avec CP_POSTE"
	,round((nr_grp_id / nr_grp_ran)* 100, 2) "% VOIES rapprochées POSTE (ID)"
	,round((nr_grp_cea / nr_grp_ran)* 100, 2) "% VOIES rapprochées POSTE (CEA)"
	,round((nr_hn_cea / nr_hn_ran)* 100, 2) "% NUMEROS rapprochés POSTE (CEA)"
from
	nr_group
	,nr_group_cea
	,nr_housenumber
	,nr_group_ran
	,nr_housenumber_ran

	;
