select min(lt.link) AS link_type,
min(t1.title) AS first_movie,
min(t2.title) AS second_movie
from title AS t1
inner join movie_keyword AS mk
on t1.id = mk.movie_id AND mk.movie_id = t1.id
inner join keyword AS k
on mk.keyword_id = k.id AND k.keyword = '10,000-mile-club'
inner join movie_link AS ml
on ml.movie_id = t1.id
inner join title AS t2
on ml.linked_movie_id = t2.id
inner join link_type AS lt
on lt.id = ml.link_type_id;