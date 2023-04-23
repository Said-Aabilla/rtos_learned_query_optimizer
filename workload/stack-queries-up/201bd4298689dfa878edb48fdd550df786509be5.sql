SELECT COUNT(*) FROM tag AS t, site AS s, question AS q, tag_question AS tq WHERE t.site_id = s.site_id AND q.site_id = s.site_id AND tq.site_id = s.site_id AND tq.question_id = q.id AND tq.tag_id = t.id AND s.site_name IN ('stackoverflow') AND t.name IN ('asp.net-membership', 'c99', 'entity-relationship', 'minecraft', 'nsdateformatter', 'ram', 'scala-collections', 'tracking') AND q.view_count >= 10 AND q.view_count <= 1000