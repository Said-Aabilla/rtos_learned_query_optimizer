select min(an1.name) AS actress_pseudonym,
min(t.title) AS japanese_movie_dubbed
from name AS n1
inner join aka_name AS an1
on an1.person_id = n1.id AND n1.name like '%Yo%' AND n1.name not like '%Yu%'
inner join cast_info AS ci
on an1.person_id = ci.person_id AND n1.id = ci.person_id AND ci.note = '(voice: English version)'
inner join title AS t
on ci.movie_id = t.id
inner join movie_companies AS mc
on ci.movie_id = mc.movie_id AND t.id = mc.movie_id AND mc.note like '%(Japan)%' AND mc.note not like '%(USA)%'
inner join company_name AS cn
on mc.company_id = cn.id AND cn.country_code = '[jp]'
inner join role_type AS rt
on ci.role_id = rt.id AND rt.role = 'actress';