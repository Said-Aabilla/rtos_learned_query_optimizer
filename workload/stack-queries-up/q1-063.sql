SELECT COUNT(*)
FROM tag AS t,
     site AS s,
     question AS q,
     tag_question AS tq
WHERE s.site_name = 'music'
  AND t.name = 'sight-reading'
  AND t.site_id = s.site_id
  AND q.site_id = s.site_id
  AND tq.site_id = s.site_id
  AND tq.question_id = q.id
  AND tq.tag_id = t.id