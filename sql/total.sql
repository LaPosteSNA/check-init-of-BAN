/*
 * table: Total éléments BAN/RAN
 */

-- On créé la table si elle n'existe pas
CREATE TABLE IF NOT EXISTS total
(
	db varchar(5) not null
	,data varchar(20) not null
	,zone varchar(10) null
	,count integer not null
)
WITH (
  OIDS=FALSE
);

-- Valeurs par défaut valorisées

-- Commentaires
COMMENT ON TABLE total IS 'Totaux éléments (éventuellement par Zone)';
COMMENT ON COLUMN total.db IS 'Base source (BAN/RAN)';
COMMENT ON COLUMN total.data IS 'Elément d''adresse (Commune, Voie, ...)';
COMMENT ON COLUMN total.zone IS 'Zone éventuelle pour le comptage';
COMMENT ON COLUMN total.count IS 'Comptage résultat';

-- On vide la table ou cas ou elle existait et contenait des données
TRUNCATE TABLE total;

