/*-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
 * tests BAN
 *  compare data w/ RAN (LA POSTE)
 */

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- chargement DUMP
--

dropdb banapi
createdb -D ban_tablespace banapi -O ban
C:\Users\nrm430\Devel>"C:\Program Files\PostgreSQL\9.4\bin\pg_restore" -h 200.108.141.207 -j 3 -U ban -d banapi C:\Users\nrm430\Downloads\ban-dump\ban.dump 1>\DATA\LOG\pg.log 2>\DATA\LOG\pgerr.log

SELECT * from pg_stat_activity ;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- plugins
--

-- calcul code Département (à partir INSEE)
drop function getdepartment(character varying);
CREATE OR REPLACE FUNCTION getDepartment(citycode VARCHAR(5)) 
RETURNS VARCHAR(3) AS 
$$
DECLARE
	dept VARCHAR(3);
BEGIN
	dept := case
		when substr(citycode, 1, 2) between '97' and '98' then
			substr(citycode, 1, 3)
		else
			substr(citycode, 1, 2)
		end;

	return dept;
END;
$$ LANGUAGE plpgsql;	

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- totaux
--

select
	'BAN' "db"
	,1 "id"
	,'Municipality' "data"
	,count(*) "count"
from
	Municipality
union
select
	'RAN' "db"
	,1 "id"
	,'Municipality' "data"
	,count(*)
from
	za
where
	fl_etat = 1
	and id_typ_loc in (1, 2)
union
select
	'BAN' "db"
	,2 "id"
	,'Postcode' "data"
	,count(distinct p.code || p.name)
from
	Postcode p
		join Municipality m on p.municipality_id = m.pk
union
select
	'RAN' "db"
	,2 "id"
	,'Postcode' "data"
	,count(distinct co_postal || lb_ach_nn)
from
	za
where
	fl_etat = 1
	and id_typ_loc in (1, 2)
union
select
	'BAN' "db"
	,3 "id"
	,'Group' "data"
	,count(*)
from
	public.Group g
		join Municipality m on g.municipality_id = m.pk
union
select
	'RAN' "db"
	,3 "id"
	,'Group' "data"
	,count(*)
from
	voie
where
	fl_etat = 1
	and
	fl_adr = 1
	and
	fl_diffusable = 1
union

order by
	2, 1
	;
	
--
-- Municipality
--

-- BAN

select
	getdepartment(insee)
	,count(*)
from
	Municipality
group by
	getdepartment(insee)
order by
	1
	;

-- RAN

select
	getdepartment(co_insee)
	,count(*)
from
	za
where
	fl_etat = 1
	and id_typ_loc in (1, 2)
group by
	getdepartment(co_insee)
order by
	1
	;

--	
-- Postcode
--

-- BAN

select
	getdepartment(m.insee)
	--,count(distinct p.code)
	,count(distinct p.code || p.name)
from
	Postcode p
		join Municipality m on p.municipality_id = m.pk
group by
	getdepartment(m.insee)
order by
	1
	;

-- RAN

select
	getdepartment(co_insee)
	,count(distinct co_postal || lb_ach_nn)
from
	za
where
	fl_etat = 1
	and id_typ_loc in (1, 2)
group by
	getdepartment(co_insee)
order by
	1
	;

--
-- Group
--

-- BAN

select
	getdepartment(m.insee)
	,count(*)
from
	public.Group g
		join Municipality m on g.municipality_id = m.pk
group by
	getdepartment(m.insee)
order by
	1
	;

-- RAN

select
	getdepartment(co_insee)
	,count(*)
from
	voie
where
	fl_etat = 1
	and
	fl_adr = 1
	and
	fl_diffusable = 1
group by
	getdepartment(co_insee)
order by
	1
	;

--
-- Housenumber
--

-- BAN

select
	getdepartment(m.insee)
	,count(*)	
from
	housenumber hn
		join "group" g on hn.parent_id = g.pk
		join municipality m on g.municipality_id = m.pk
where
	hn.number is not null
group by
	getdepartment(m.insee)
order by
	1
	;

-- RAN

select
	getdepartment((CASE WHEN z.ID_TYP_LOC < 3 THEN z.CO_INSEE ELSE z.CO_INSEE_R END))
	,count(*)
from
	numero n
		join adresse a on n.co_cea = a.co_cea_numero
		join za z on z.co_cea = a.co_cea_za
where
	n.fl_etat = 1
	and
	n.fl_diffusable = 1
	and
	a.co_cea_l3 is null
group by
	getdepartment((CASE WHEN z.ID_TYP_LOC < 3 THEN z.CO_INSEE ELSE z.CO_INSEE_R END))
order by
	1
	;
	

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- delta (d1= BAN, d2= RAN)
--

--	
-- Municipality
--

with
d1 as
(
	select
		insee
		-- libellé normé, en majuscule (sans accent, sans trait union, et SAINT[E] abrégé en ST[E])
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
		za
	where
		fl_etat = 1
		and id_typ_loc in (1, 2)
)

select
	'-' "delta"
	,d.insee
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
	'+'
	,d.insee
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
	'!'
	,d.insee
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

order by
	1, 2
;


--	
-- Postcode
--

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
		za
	where
		fl_etat = 1
		and id_typ_loc in (1, 2)
)

select
	'-' "delta"
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
  
union
select
	'+'
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
  
union
select
	'!'
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

order by
	1, 2, 3
;


--	
-- Group
--

-- delta

with
d1 as
(
	select
		m.insee
		-- libellé normé, en majuscule (sans accent, sans trait union)
		,regexp_replace(translate(upper(unaccent(g.name)), $$-'$$, '  '), '[ ]+', ' ') "name"
		,to_number(g.laposte, '99999999') "id"
		,hn.laposte "cea"
	from
		public.Group g
			join Municipality m on g.municipality_id = m.pk
			left outer join Housenumber hn on g.pk = hn.parent_id
			
	where
		hn.number is null
)
,d2 as
(
	select
		co_insee "insee"
		,lb_voie "name"
		,co_voie "id"
		,co_cea "cea"
	from
		voie
	where
		fl_etat = 1
		and
		fl_adr = 1
		and
		fl_diffusable = 1
)

select
	'-' "delta"
	,d.insee
	,d.name
from
(
	select
		insee
		,name
	from
		d1
	except
	select
		insee
		,name
	from
		d2
) d
  
union
select
	'+'
	,d.insee
	,d.name
from
(
	select
		insee
		,name
	from
		d2
	except
	select
		insee
		,name
	from
		d1
) d

union
select
	'!'
	,d.insee
	,d.name
from
(
	select
		d1.insee
		,d1.name
	from
		d1
			join d2 on d1.insee = d2.insee and d1.name = d2.name
	where
		(d1.id != d2.id)
		or
		(d1.cea != d2.cea)
) d

order by
	1, 2, 3
;

-- détails (BAN/RAN)

select
	'BAN' "db"
	,m.insee
	-- libellé normé, en majuscule (sans accent, sans trait union)
	,regexp_replace(translate(upper(unaccent(g.name)), $$-'$$, '  '), '[ ]+', ' ') "name"
	,to_number(g.laposte, '99999999') "id"
	,hn.laposte "cea"
from
	public.Group g
		join Municipality m on g.municipality_id = m.pk
		left outer join Housenumber hn on g.pk = hn.parent_id
		
where
	hn.number is null
	and
	m.insee = '33463'
	and
	regexp_replace(translate(upper(unaccent(g.name)), $$-'$$, '  '), '[ ]+', ' ') = 'LA MAGDELAINE'

union

select
	'RAN' "db"
	,co_insee "insee"
	,lb_voie "name"
	,co_voie "id"
	,co_cea "cea"
from
	voie
where
	fl_etat = 1
	and
	fl_adr = 1
	and
	fl_diffusable = 1
	and
	co_insee = '33463'
	and
	lb_voie = 'LA MAGDELAINE'

order by
	2, 3, 1
;

-- constats
-- libellé BAN avec tv abrégé (ALL, AV, BD, SEN, SQ, CHE, RES, LOT, ...) à étendre (sans abréviation)


---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- accentuation
--

create extension unaccent;

select insee, name, regexp_replace(upper(unaccent(name)), $q$'-$q$, ' ') from municipality;
+select insee, name, translate(upper(unaccent(name)), $q$-'$q$, ' ') from municipality;
select insee, name, regexp_replace(translate(upper(unaccent(name)), $$-'$$, ' '), 'SAINT([E]?) ', 'ST\1 ') from municipality where insee = '01342';

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- accès distant image RAN (BC2A)
--

create extension postgres_fdw;

drop server bc2a_server;
CREATE SERVER bc2a_server FOREIGN DATA WRAPPER postgres_fdw OPTIONS (host 'localhost', port '5432', dbname 'ban');

CREATE USER MAPPING FOR ban SERVER bc2a_server OPTIONS (user 'ran', password 'pgran+123');

-- 9.5!
--IMPORT FOREIGN SCHEMA ran LIMIT TO (adresse_ra49, za_ra18, voie_ra41, numero_ra33, l3_ra34) FROM SERVER bc2a_server INTO ran;

CREATE FOREIGN TABLE adresse (
	co_cea_l3 character(10), -- CEA de l'adresse L3
	co_cea_numero character(10), -- CEA de l'adresse NUMERO
	co_cea_voie character(10), -- CEA de l'adresse VOIE
	co_cea_za character(10) -- CEA de l'adresse ZA
)
        SERVER bc2a_server
        OPTIONS (schema_name 'ran', table_name 'adresse_ra49');

CREATE FOREIGN TABLE za (
	id character varying(12) NOT NULL, -- Identifiant zone d'adresses
	co_cea character(10) NOT NULL, -- CEA de la zone d'adresses
	co_insee character(5), -- Code INSEE...
	lb_in_ext_loc character varying(72) NOT NULL, -- Libellé in-extenso de la localité...
	lb_an character varying(32) NOT NULL, -- Libellé Commune AN...
	lb_nn character varying(38) NOT NULL, -- Libellé Commune NN...
	id_typ_loc integer NOT NULL, -- Identifiant type de localité...
	lb_l5_an character varying(32), -- Ligne 5 AN
	lb_l5_nn character varying(38), -- Ligne 5 NN
	co_postal character varying(5) NOT NULL, -- Code Postal
	lb_ach_an character varying(32) NOT NULL, -- Libelle acheminement AN
	lb_ach_nn character varying(38) NOT NULL, -- Libelle acheminement NN
	co_insee_r character(5), -- Code INSEE commune de rattachement...
	fl_etat integer NOT NULL -- Flag d'activité de la ZA...
)
        SERVER bc2a_server
        OPTIONS (schema_name 'ran', table_name 'za_ra18');

CREATE FOREIGN TABLE voie (
	co_cea character(10), -- CEA de l'adresse ran.voie_ra41
	co_voie numeric(8,0) NOT NULL, -- Matricule de la ran.voie_ra41
	co_insee character varying(5), -- Code INSEE
	lb_voie character varying(60), -- Libellé ran.voie_ra41 in extenso
	lb_voie_an character varying(27), -- Libellé normalisé AN...
	lb_voie_nn character varying(32),
	--lb_abr_an character varying(4), -- Libellé type de ran.voie_ra41 abrégé NN...
	lb_abr_nn character varying(4), -- Libellé type de ran.voie_ra41 abrégé AN...
	--lb_desc_an character varying(10), -- Libellé descripteur AN...
	lb_desc_nn character varying(10), -- Libellé descripteur NN...
	lb_md character varying(20), -- Libellé mot directeur...
	co_insee_anc character varying(5), -- Code INSEE (ancienne commune)...
	fl_etat numeric(1,0), -- Etat de la ran.voie_ra41...
	fl_adr numeric(1,0) DEFAULT 1, -- Etat de l'adresse...
	lb_in_ext_typ_voie character varying(38), -- Libellé type de ran.voie_ra41 in extenso...
	fl_diffusable numeric(1,0) NOT NULL -- Etat diffusable...
)
        SERVER bc2a_server
        OPTIONS (schema_name 'ran', table_name 'voie_ra41');

CREATE FOREIGN TABLE numero (
	co_cea character(10) NOT NULL, -- CEA de l'adresse numéro
	no_voie integer, -- Numéro dans la voie
	lb_ext character varying(10), -- Libellé extension longue...
	--lb_abr_an character varying(1), -- Libellé extension abrégée AN...
	lb_abr_nn character varying(1), -- Libellé extension abrégée NN...
	fl_etat integer, -- Etat de l'adresse...
	fl_diffusable integer -- Etat diffusable...
)
        SERVER bc2a_server
        OPTIONS (schema_name 'ran', table_name 'numero_ra33');

CREATE FOREIGN TABLE l3 (
	co_cea character(10) NOT NULL, -- CEA de l'adresse ligne 3
	id_type_groupe1_l3 integer, -- Type groupe 1
	lb_type_groupe1_l3 character varying(38), -- Libellé type groupe 1
	--lb_abrev_g1_an character varying(10), -- Libellé type groupe 1 abrégé AN
	lb_abrev_g1_nn character varying(10), -- Libellé type groupe 1 abrégé NN
	lb_groupe1 character varying(38), -- Libellé groupe 1
	id_type_groupe2_l3 integer, -- Type groupe 2
	lb_type_groupe2_l3 character varying(38), -- Libellé type groupe 2
	--lb_abrev_g2_an character varying(10), -- Libellé type groupe 2 abrégé AN
	lb_abrev_g2_nn character varying(10), -- Libellé type groupe 2 abrégé NN
	lb_groupe2 character varying(38), -- Libellé groupe 2
	id_type_groupe3_l3 integer, -- Type groupe 3
	lb_type_groupe3_l3 character varying(38), -- Libellé type groupe 3
	--lb_abrev_g3_an character varying(10), -- Libellé type groupe 3 abrégé AN
	lb_abrev_g3_nn character varying(10), -- Libellé type groupe 3 abrégé NN
	lb_groupe3 character varying(38), -- Libellé groupe 3
	--lb_descr_an_groupe1 character varying(10), -- Libellé descripteur groupe 1 AN
	lb_descr_nn_groupe1 character varying(10), -- Libellé descripteur groupe 1 NN
	lb_mot_dir_groupe1 character varying(38), -- Libellé mot directeur groupe 1 NN
	--lb_descr_an_groupe2 character varying(10), -- Libellé descripteur groupe 2 AN
	lb_descr_nn_groupe2 character varying(10), -- Libellé descripteur groupe 2 NN
	lb_mot_dir_groupe2 character varying(38), -- Libellé mot directeur groupe 2 NN
	--lb_descr_an_groupe3 character varying(10), -- Libellé descripteur groupe 3 AN
	lb_descr_nn_groupe3 character varying(10), -- Libellé descripteur groupe 3 NN
	lb_mot_dir_groupe3 character varying(38), -- Libellé mot directeur groupe 3 NN
	fl_zone character varying(1), -- Type zone...
	lb_standard_an character varying(32), -- Libellé normalisé AN
	lb_standard_nn character varying(38), -- Libellé normalisé NN
	fl_etat_adresse integer, -- Etat de l'adresse...
	fl_diffusable integer NOT NULL -- Etat diffusable...
)
        SERVER bc2a_server
        OPTIONS (schema_name 'ran', table_name 'l3_ra34');

-- permissions (lecture)

grant select on adresse to ban;
grant select on za to ban;
grant select on voie to ban;
grant select on numero to ban;
grant select on l3 to ban;

-- tests

select * from za;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

--
-- tests
--

select user;
select * from dblink('dbname=ban host=200.108.141.207 user=ran password=pgran+123', 'select * from za_ra18') as za(
  id character varying(12)
  ,co_cea character(10)
  ,co_insee character(5)
  ,lb_in_ext_loc character varying(72)
  ,lb_an character varying(32)
  ,lb_nn character varying(38)
  ,id_typ_loc integer
  ,lb_l5_an character varying(32)
  ,lb_l5_nn character varying(38)
  ,co_postal character varying(5)
  ,lb_ach_an character varying(32)
  ,lb_ach_nn character varying(38)
  ,co_insee_r character(5)
  ,fl_etat integer
);
select * from "group" limit 100;
select * from municipality where pk = 36704;
select * from municipality where insee = '01342'

select
	m.name
	,g.name
	,g.kind
	,g.laposte
	,hn.number
	,hn.ordinal
	,hn.laposte
	
from
	housenumber hn
		join "group" g on hn.parent_id = g.pk
		join municipality m on g.municipality_id = m.pk
where
	m.pk = (select pk from municipality where insee = '33001')
order by
	g.name
	,hn.number
	,hn.ordinal
	;

-- test
select getDepartment('01001');
select getDepartment('97120');