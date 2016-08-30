--
-- eval RAN's occurences of words into Group label
--

/*
 * oracle-like
merge into words w using (
	select
		unnest(string_to_array(lb_voie, ' ')) "word"
	from
		ran.voie_ra41
	where
		fl_etat = 1
		and
		fl_adr = 1
		and
		fl_diffusable = 1

		and
		lb_voie like 'COUR %'
	) rv

	on w.word = rv.word

	when matched then count = count + 1
	when not matched then insert values (rv.word, 1)
	;
*/
	
/*
 * w/ insert on conflict, but problem on update condition !
insert into words as w (word, count)
	select
		unnest(string_to_array(lb_voie, ' ')) "word"
		,1
	from
		ran.voie_ra41
	where
		fl_etat = 1
		and
		fl_adr = 1
		and
		fl_diffusable = 1

		and
		lb_voie like 'ALLEE %'

	on conflict (word)
	do
		update set count = w.count + 1
		where w.word = ?
;
*/
	
truncate table words;

BEGIN;

CREATE TEMPORARY TABLE newvals(word varchar(100));

INSERT INTO newvals(word) 
	select
		unnest(string_to_array(lb_voie, ' ')) "word"
	from
		ran.voie_ra41
	where
		fl_etat = 1
		and
		fl_adr = 1
		and
		fl_diffusable = 1

		--and
		--lb_voie like 'SQUARE %'
	;

insert into words
	select
		word
		,count(*)
	from
		newvals
	group by
		word
	;

COMMIT;
