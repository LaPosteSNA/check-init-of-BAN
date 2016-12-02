Copy (
	-- postcode

	select distinct 
	  CASE
	  WHEN id_typ_loc < 3 then
	    co_insee
	  ELSE 
	    co_insee_r
	  END co_insee
	  ,lb_l5_nn
	  ,CASE
	  WHEN id_typ_loc >= 3 then
	    co_insee
	  ELSE 
	    null
	  END co_insee_anc
	  ,co_postal
	  ,LB_ACH_AN lb_l6
	from
	  ran.za_ra18
	where
	  fl_etat = 1
	  
	  and
	  co_insee not like '98%'
	  and
	  co_insee not like '99%'
	  
	order by
	  1, 2

) to '/data/tmp/ran_postcode.csv' with CSV DELIMITER ';' HEADER ;

