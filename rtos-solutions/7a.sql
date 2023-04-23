select min(n.name) AS of_person,
min(t.title) AS biography_movie
from link_type AS lt
inner join movie_link AS ml
on lt.id = ml.link_type_id AND lt.link = 'features'
inner join title AS t
on ml.linked_movie_id = t.id AND t.production_year BETWEEN 1980 AND 1995
inner join cast_info AS ci
on t.id = ci.movie_id AND ci.movie_id = ml.linked_movie_id
inner join name AS n
on ci.person_id = n.id AND n.name_pcode_cf BETWEEN 'A' AND 'F' AND ( n.gender = 'm' OR ( n.gender = 'f' AND n.name like 'B%'))
inner join person_info AS pi
on n.id = pi.person_id AND pi.person_id = ci.person_id AND pi.note = 'Volker Boehm'
inner join info_type AS it
on it.id = pi.info_type_id AND it.info = 'mini biography'
inner join aka_name AS an
on n.id = an.person_id AND pi.person_id = an.person_id AND an.person_id = ci.person_id AND an.name like '%a%';