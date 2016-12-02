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
		count(*) nr_grp_ran
	from
		ran.voie_ra41 rv
	where
		rv.fl_etat = 1
		and
		rv.fl_adr = 1
		and
		rv.fl_diffusable = 1
)
,nr_housenumber_ran as (
	select
		count(*) nr_hn_ran
	from
		ran.numero_ra33 rn
	where
		rn.fl_etat = 1
		and
		rn.fl_diffusable = 1
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
