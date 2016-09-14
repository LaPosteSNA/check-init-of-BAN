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

select
	round((nr_grp_id / nr_grp_total)* 100, 2) "% VOIES avec ID_POSTE"
	,round((nr_grp_cea / nr_grp_total)* 100, 2) "% VOIES avec CEA_POSTE"
	,round((nr_hn_cea / nr_hn_total)* 100, 2) "% NUMEROS avec CEA_POSTE"
	,round((nr_hn_postcode / nr_hn_total)* 100, 2) "% NUMEROS avec CP_POSTE"
from
	nr_group
	,nr_group_cea
	,nr_housenumber

	;
