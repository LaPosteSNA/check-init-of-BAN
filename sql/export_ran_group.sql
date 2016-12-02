-- export as csv: Copy (Select * From foo) To '/tmp/test.csv' With CSV DELIMITER ',';

Copy (
	-- voies
	select
	  rv.co_insee
	  ,rv.co_voie
	  ,rz.co_postal
	  ,coalesce(rv.lb_abr_nn, rv.lb_abr_an) lb_type_voie
	  ,rv.lb_voie
	  ,rv.co_cea "cea"
	  ,rz.lb_l5_nn "lb_l5"
	  ,case when rz.id_typ_loc > 2 then rz.co_insee else null end "co_insee_l5"
	from
	  ran.adresse_ra49 ra
	    join ran.za_ra18 rz on ra.co_cea_za = rz.co_cea
	    join ran.voie_ra41 rv on ra.co_cea_voie = rv.co_cea
	where
	  rz.fl_etat = 1
	  and
	  rv.fl_etat = 1
	  and
	  rv.fl_adr = 1
	  and
	  rv.fl_diffusable = 1
	  and
	  ra.co_cea_numero is null
	  and
	  ra.co_cea_l3 is null
	order by
	  1, 5
) to '/data/tmp/ran_group.csv' with CSV DELIMITER ';' HEADER ;

