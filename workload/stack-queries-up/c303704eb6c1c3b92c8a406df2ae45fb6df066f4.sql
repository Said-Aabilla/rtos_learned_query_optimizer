SELECT COUNT(*) FROM tag AS t, site AS s, question AS q, tag_question AS tq WHERE t.site_id = s.site_id AND q.site_id = s.site_id AND tq.site_id = s.site_id AND tq.question_id = q.id AND tq.tag_id = t.id AND s.site_name IN ('stackoverflow') AND t.name IN ('alamofire', 'apache-spark', 'asp.net-core-mvc', 'filenames', 'installer', 'protocol-buffers', 'visual-studio-2017', 'xamarin') AND q.view_count >= 10 AND q.view_count <= 1000