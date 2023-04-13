SELECT MIN(mi_idx.info) AS rating,
       MIN(t.title) AS north_european_dark_production
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
  AND k.keyword IS NOT NULL
  AND it2.id = mi_idx.info_type_id
  AND k.keyword IN ('based-on-comic',
'based-on-novel',
'based-on-comic',
'black-lace-panties')
AND kt.kind IN ('tv movie',
'tv series')
AND mi.info IN ('American',
'English',
'Norway',
'Bulgaria',
'Norwegian',
'USA',
'Germany',
'Danish',
'America',
'UK')
AND mi_idx.info < '9'
AND t.production_year > 1980;