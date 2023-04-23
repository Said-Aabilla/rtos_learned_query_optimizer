select min(mi.info) AS movie_budget,
min(mi_idx.info) AS movie_votes,
min(n.name) AS male_writer,
min(t.title) AS violent_movie_title
from info_type AS it1
inner join movie_info AS mi
on it1.id = mi.info_type_id AND it1.info = 'genres' AND mi.info = 'Horror'
inner join cast_info AS ci
on ci.movie_id = mi.movie_id AND ci.note IN ('(writer)',
'(head writer)',
'(written by)',
'(story)',
'(story editor)')
inner join movie_info_idx AS mi_idx
on ci.movie_id = mi_idx.movie_id AND mi.movie_id = mi_idx.movie_id
inner join info_type AS it2
on it2.id = mi_idx.info_type_id AND it2.info = 'votes'
inner join title AS t
on t.id = ci.movie_id AND t.id = mi.movie_id AND t.id = mi_idx.movie_id
inner join movie_keyword AS mk
on t.id = mk.movie_id AND ci.movie_id = mk.movie_id AND mi.movie_id = mk.movie_id AND mi_idx.movie_id = mk.movie_id
inner join keyword AS k
on k.id = mk.keyword_id AND k.keyword IN ('murder',
'blood',
'gore',
'death',
'female-nudity')
inner join name AS n
on n.id = ci.person_id AND n.gender = 'm';