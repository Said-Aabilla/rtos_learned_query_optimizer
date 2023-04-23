select min(cn.name) AS movie_company,
min(mi_idx.info) AS rating,
min(t.title) AS western_violent_movie
from info_type AS it1
inner join movie_info AS mi
on it1.id = mi.info_type_id AND it1.info = 'countries' AND mi.info IN ('Germany',
'German',
'USA',
'American')
inner join movie_keyword AS mk
on mk.movie_id = mi.movie_id
inner join keyword AS k
on k.id = mk.keyword_id AND k.keyword IN ('murder',
'murder-in-title',
'blood',
'violence')
inner join title AS t
on t.id = mk.movie_id AND t.id = mi.movie_id AND t.production_year > 2008
inner join movie_companies AS mc
on t.id = mc.movie_id AND mk.movie_id = mc.movie_id AND mi.movie_id = mc.movie_id AND mc.note not like '%(USA)%' AND mc.note like '%(200%)%'
inner join movie_info_idx AS mi_idx
on t.id = mi_idx.movie_id AND mc.movie_id = mi_idx.movie_id AND mk.movie_id = mi_idx.movie_id AND mi.movie_id = mi_idx.movie_id AND mi_idx.info < '7.0'
inner join kind_type AS kt
on kt.id = t.kind_id AND kt.kind IN ('movie',
'episode')
inner join company_type AS ct
on ct.id = mc.company_type_id
inner join info_type AS it2
on it2.id = mi_idx.info_type_id AND it2.info = 'rating'
inner join company_name AS cn
on cn.id = mc.company_id AND cn.country_code <> '[us]';