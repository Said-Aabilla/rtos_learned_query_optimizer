select min(mc.note) AS production_note,
min(t.title) AS movie_title,
min(t.production_year) AS movie_year
from movie_companies AS mc
inner join movie_info_idx AS mi_idx
on mc.movie_id = mi_idx.movie_id AND mc.note not like '%(as Metro-Goldwyn-Mayer Pictures)%' AND ( mc.note like '%(co-production)%' OR mc.note like '%(presents)%')
inner join title AS t
on t.id = mc.movie_id AND t.id = mi_idx.movie_id
inner join company_type AS ct
on ct.id = mc.company_type_id AND ct.kind = 'production companies'
inner join info_type AS it
on it.id = mi_idx.info_type_id AND it.info = 'top 250 rank';