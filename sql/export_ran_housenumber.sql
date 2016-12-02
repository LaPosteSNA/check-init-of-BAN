-- export as csv: Copy (Select * From foo) To '/tmp/test.csv' With CSV DELIMITER ',';

Copy (
	-- housenumber

	select
	  rv.co_insee
	  ,rv.co_voie
	  ,rz.co_postal
	  ,rn.NO_VOIE
	  ,rn.LB_EXT
	  ,rn.co_cea
	from
	   ran.adresse_ra49 ra
	    join ran.za_ra18 rz on ra.co_cea_za = rz.co_cea
	    join ran.voie_ra41 rv on ra.co_cea_voie = rv.co_cea
	    join ran.numero_ra33 rn on ra.co_cea_numero = rn.co_cea
	where
	  rz.fl_etat = 1
	  and
	  rv.fl_etat = 1
	  and
	  rv.fl_adr = 1
	  and
	  rv.fl_diffusable = 1
	  and
	  ra.co_cea_l3 is null
	  and
	  rn.fl_etat = 1
	  and
	  rn.fl_diffusable = 1
	order by
	  1, 2, 4, 5

) to '/data/tmp/ran_housenumber.csv' with CSV DELIMITER ';' HEADER ;

