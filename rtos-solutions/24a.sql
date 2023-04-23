select min(chn.name) AS voiced_char_name,
min(n.name) AS voicing_actress_name,
min(t.title) AS voiced_action_movie_jap_eng
from movie_info AS mi
inner join movie_keyword AS mk
on mi.movie_id = mk.movie_id AND mi.info IS NOT NULL AND ( mi.info like 'Japan:%201%' OR mi.info like 'USA:%201%')
inner join keyword AS k
on k.id = mk.keyword_id AND k.keyword IN ('hero',
'martial-arts',
'hand-to-hand-combat')
inner join movie_companies AS mc
on mc.movie_id = mi.movie_id AND mc.movie_id = mk.movie_id
inner join title AS t
on t.id = mk.movie_id AND t.id = mi.movie_id AND t.id = mc.movie_id AND t.production_year > 2010
inner join company_name AS cn
on cn.id = mc.company_id AND cn.country_code = '[us]'
inner join cast_info AS ci
on mi.movie_id = ci.movie_id AND t.id = ci.movie_id AND mc.movie_id = ci.movie_id AND ci.movie_id = mk.movie_id AND ci.note IN ('(voice)',
'(voice: Japanese version)',
'(voice) (uncredited)',
'(voice: English version)')
inner join name AS n
on n.id = ci.person_id AND n.gender = 'f' AND n.name like '%An%'
inner join char_name AS chn
on chn.id = ci.person_role_id
inner join aka_name AS an
on ci.person_id = an.person_id AND n.id = an.person_id
inner join info_type AS it
on it.id = mi.info_type_id AND it.info = 'release dates'
inner join role_type AS rt
on rt.id = ci.role_id AND rt.role = 'actress';