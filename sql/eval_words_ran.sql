--
-- eval RAN's occurences of words into Group label
--

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
		lb_voie like 'ALLEE %'
	) rv

	on w.word = rv.word

	when matched then count = count + 1
	when not matched then insert values (rv.word, 1)

	;
	

	
