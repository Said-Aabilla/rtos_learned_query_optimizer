select min(t.title) AS movie_title
from keyword AS k
inner join movie_keyword AS mk
on k.id = mk.keyword_id AND k.keyword like '%sequel%'
inner join title AS t
on t.id = mk.movie_id AND t.production_year > 2010
inner join movie_info AS mi
on mk.movie_id = mi.movie_id AND t.id = mi.movie_id AND mi.info IN ('Bulgaria');