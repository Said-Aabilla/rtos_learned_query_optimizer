SELECT COUNT(DISTINCT (q1.id))
FROM site AS s,
     post_link AS pl1,
     post_link AS pl2,
     question AS q1,
     question AS q2,
     question AS q3
WHERE s.site_name = 'stackapps'
  AND q1.site_id = s.site_id
  AND q1.site_id = q2.site_id
  AND q2.site_id = q3.site_id
  AND pl1.site_id = q1.site_id
  AND pl1.post_id_from = q1.id
  AND pl1.post_id_to = q2.id
  AND pl2.site_id = q1.site_id
  AND pl2.post_id_from = q2.id
  AND pl2.post_id_to = q3.id
  AND q1.score > q3.score