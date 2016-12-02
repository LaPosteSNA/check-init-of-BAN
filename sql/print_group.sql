-- voies approchantes ':group'
select
	m.insee
	,g.name
	,g.laposte
from
	"group" g
		join municipality m on g.municipality_id = m.pk
where
	upper(g.name) like '%' || :group || '%'
	and
	m.insee = :insee
	;

select
	m.insee
	,g.name
	,g.laposte "cea"
from
	"group" g
		join municipality m on g.municipality_id = m.pk
where
	upper(unaccent(g.name)) like '%' || 'CHENES' || '%'
	and
	m.insee = '06004'
	;

-- toutes les voies
select
	m.insee
	,g.name
	,g.laposte
from
	"group" g
		join municipality m on g.municipality_id = m.pk
where
	m.insee = '06004'
order by
	2
	;

-- numéros des voies approchantes ':group'
select
	'BAN'
	,m.insee
	,g.name
	,to_number(g.laposte, '99999999') "id"
	,to_number(hn.number, '9999')
	,hn.ordinal
	,p.code
	,hn.laposte "cea"
from
	"group" g
		join municipality m on g.municipality_id = m.pk
		join housenumber hn on hn.parent_id = g.pk
		join postcode p on hn.postcode_id = p.pk
where
	--upper(g.name) like '%' || :group || '%'
	upper(unaccent(g.name)) like '%' || 'CHENES' || '%'
	and
	--m.insee = :insee
	m.insee = '06004'

union

select
	'RAN'
	,rv.co_insee
	,rv.lb_voie
	,rv.co_voie "id"
	,rn.no_voie
	,rn.lb_ext
	,rz.co_postal
	,rn.co_cea "cea"
from
	ran.numero_ra33 rn
		join ran.adresse_ra49 ra on rn.co_cea = ra.co_cea_numero
		join ran.voie_ra41 rv on rv.co_cea = ra.co_cea_voie
		join ran.za_ra18 rz on rz.co_cea = ra.co_cea_za
where
	rn.co_cea in (
		select
			hn.laposte
		from
			"group" g
				join municipality m on g.municipality_id = m.pk
				join housenumber hn on hn.parent_id = g.pk
				join postcode p on hn.postcode_id = p.pk
		where
			--upper(g.name) like '%' || :group || '%'
			upper(unaccent(g.name)) like '%' || 'CHENES' || '%'
			and
			--m.insee = :insee
			m.insee = '06004'
	)
order by
	5, 6, 1, 3
	;
