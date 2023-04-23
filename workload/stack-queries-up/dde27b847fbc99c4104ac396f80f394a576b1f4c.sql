SELECT COUNT(*) FROM tag AS t, site AS s, question AS q, tag_question AS tq WHERE t.site_id = s.site_id AND q.site_id = s.site_id AND tq.site_id = s.site_id AND tq.question_id = q.id AND tq.tag_id = t.id AND s.site_name IN ('apple') AND t.name IN ('icloud', 'ipad', 'itunes', 'macbook', 'mavericks', 'mountain-lion', 'network', 'yosemite') AND q.score >= 1 AND q.score <= 10