SELECT MIN(mi_idx.info) AS rating,
       MIN(t.title) AS northern_dark_movie
FROM info_type AS it1,
     info_type AS it2,
     keyword AS k,
     kind_type AS kt,
     movie_info AS mi,
     movie_info_idx AS mi_idx,
     movie_keyword AS mk,
     title AS t
WHERE it1.info ='countries'
  AND it2.info ='rating'
  AND kt.id = t.kind_id
  AND t.id = mi.movie_id
  AND t.id = mk.movie_id
  AND t.id = mi_idx.movie_id
  AND mk.movie_id = mi.movie_id
  AND mk.movie_id = mi_idx.movie_id
  AND mi.movie_id = mi_idx.movie_id
  AND k.id = mk.keyword_id
  AND it1.id = mi.info_type_id
  AND it2.id = mi_idx.info_type_id
  AND k.keyword IN ('fight',
'murder',
'murder-in-title',
'travel')
AND kt.kind ='tv series'
AND mi.info IN ('Denmark',
'Norway',
'Bulgaria',
'German',
'Denish',
'Sweden',
'Danish',
'Norwegian',
'Germany',
'USA')
AND mi_idx.info < '7.6'
AND t.production_year > 2005;