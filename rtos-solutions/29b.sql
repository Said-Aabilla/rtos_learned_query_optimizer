select min(chn.name) AS voiced_char,
min(n.name) AS voicing_actress,
min(t.title) AS voiced_animation
from char_name AS chn
inner join cast_info AS ci
on chn.id = ci.person_role_id AND chn.name = 'Queen' AND ci.note IN ('(voice)',
'(voice) (uncredited)',
'(voice: English version)')
inner join movie_keyword AS mk
on ci.movie_id = mk.movie_id
inner join movie_info AS mi
on mi.movie_id = ci.movie_id AND mi.movie_id = mk.movie_id AND mi.info like 'USA:%200%'
inner join movie_companies AS mc
on mc.movie_id = ci.movie_id AND mc.movie_id = mk.movie_id AND mc.movie_id = mi.movie_id
inner join name AS n
on n.id = ci.person_id AND n.gender = 'f' AND n.name like '%An%'
inner join title AS t
on t.id = ci.movie_id AND t.id = mk.movie_id AND t.id = mc.movie_id AND t.id = mi.movie_id AND t.title = 'Shrek 2' AND t.production_year BETWEEN 2000 AND 2005
inner join person_info AS pi
on ci.person_id = pi.person_id AND n.id = pi.person_id
inner join complete_cast AS cc
on ci.movie_id = cc.movie_id AND t.id = cc.movie_id AND mk.movie_id = cc.movie_id AND mc.movie_id = cc.movie_id AND mi.movie_id = cc.movie_id
inner join comp_cast_type AS cct1
on cct1.id = cc.subject_id AND cct1.kind = 'cast'
inner join aka_name AS an
on ci.person_id = an.person_id AND n.id = an.person_id
inner join company_name AS cn
on cn.id = mc.company_id AND cn.country_code = '[us]'
inner join info_type AS it3
on it3.id = pi.info_type_id AND it3.info = 'height'
inner join keyword AS k
on k.id = mk.keyword_id AND k.keyword = 'computer-animation'
inner join role_type AS rt
on rt.id = ci.role_id AND rt.role = 'actress'
inner join comp_cast_type AS cct2
on cct2.id = cc.status_id AND cct2.kind = 'complete+verified'
inner join info_type AS it
on it.id = mi.info_type_id AND it.info = 'release dates';