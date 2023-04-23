select min(n.name) AS voicing_actress,
min(t.title) AS voiced_movie
from aka_name AS an
inner join name AS n
on n.id = an.person_id AND n.gender = 'f' AND n.name like '%Ang%'
inner join cast_info AS ci
on n.id = ci.person_id AND ci.person_id = an.person_id AND ci.note IN ('(voice)',
'(voice: Japanese version)',
'(voice) (uncredited)',
'(voice: English version)')
inner join char_name AS chn
on chn.id = ci.person_role_id
inner join movie_info AS mi
on mi.movie_id = ci.movie_id AND mi.info IS NOT NULL AND ( mi.info like 'Japan:%200%' OR mi.info like 'USA:%200%')
inner join title AS t
on t.id = mi.movie_id AND t.id = ci.movie_id AND t.production_year BETWEEN 2005 AND 2009
inner join movie_companies AS mc
on mc.movie_id = ci.movie_id AND t.id = mc.movie_id AND mc.movie_id = mi.movie_id AND mc.note IS NOT NULL AND ( mc.note like '%(USA)%' OR mc.note like '%(worldwide)%')
inner join company_name AS cn
on cn.id = mc.company_id AND cn.country_code = '[us]'
inner join info_type AS it
on it.id = mi.info_type_id AND it.info = 'release dates'
inner join role_type AS rt
on rt.id = ci.role_id AND rt.role = 'actress';