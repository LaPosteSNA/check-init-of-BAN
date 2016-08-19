/*
 * table: words
 */

-- On créé la table si elle n'existe pas
CREATE TABLE IF NOT EXISTS words
(
	word varchar(100) not null
	,count integer not null
)
WITH (
  OIDS=FALSE
);

-- Valeurs par défaut valorisées

-- Commentaires
COMMENT ON TABLE words IS 'liste Mots utilisés dans le libellé Voie';
COMMENT ON COLUMN words.word IS 'Mot';
COMMENT ON COLUMN words.count IS 'nb occurences';


DROP INDEX IF EXISTS words_word; 

-- Création des indexes pour accélérer l'accès au données
create unique index words_word on words(word);
