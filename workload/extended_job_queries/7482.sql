SELECT MIN(t.title) AS movie_title
FROM keyword AS k,
     movie_info AS mi,
     movie_keyword AS mk,
     title AS t
WHERE k.keyword LIKE '%sequel%'
  AND t.id = mi.movie_id
  AND t.id = mk.movie_id
  AND mk.movie_id = mi.movie_id
  AND k.id = mk.keyword_id
  AND mi.info IN ('Denmark',
'Denish',
'Bulgaria',
'Danish',
'German',
'Norwegian',
'USA',
'Sweden',
'Norway',
'American')
AND t.production_year > 2006;