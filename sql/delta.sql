/*
 * table: Ecarts BAN/RAN
 */

-- On créé la table si elle n'existe pas
CREATE TABLE IF NOT EXISTS delta
(
	db varchar(5) not null
	,data varchar(20) not null
	,insee varchar(5) not null
	,delta char(1) not null
	,key1 varchar(100) null
	,key2 varchar(100) null
	,key3 varchar(100) null
	,key4 varchar(100) null
)
WITH (
  OIDS=FALSE
);

-- Valeurs par défaut valorisées

-- Commentaires
COMMENT ON TABLE delta IS 'Ecarts BAN/RAN';
COMMENT ON COLUMN delta.db IS 'Base source (BAN/RAN)';
COMMENT ON COLUMN delta.data IS 'Elément d''adresse (Commune, Voie, ...)';
COMMENT ON COLUMN delta.insee IS 'code INSEE';
COMMENT ON COLUMN delta.delta IS 'Ecart (+|-|!)';
COMMENT ON COLUMN delta.key1 IS 'clé élément adresse #1';
COMMENT ON COLUMN delta.key2 IS 'clé élément adresse #2';
COMMENT ON COLUMN delta.key3 IS 'clé élément adresse #3';
COMMENT ON COLUMN delta.key4 IS 'clé élément adresse #4';

-- On vide la table ou cas ou elle existait et contenait des données
TRUNCATE TABLE delta;

-- Supression des indexes s'ils existent déjà pour accélérer le chargement des données
-- Cf. http://www.postgresql.org/docs/current/static/populate.html
DROP INDEX IF EXISTS delta_data_insee_delta; 

-- Création des indexes pour accélérer l'accès au données
create index delta_data_insee_delta on delta(db, data, insee, delta);

