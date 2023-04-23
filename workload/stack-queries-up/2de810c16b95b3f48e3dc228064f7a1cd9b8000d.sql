SELECT COUNT(*) FROM tag AS t, site AS s, question AS q, tag_question AS tq WHERE t.site_id = s.site_id AND q.site_id = s.site_id AND tq.site_id = s.site_id AND tq.question_id = q.id AND tq.tag_id = t.id AND s.site_name IN ('stackoverflow') AND t.name IN ('bots', 'dynamics-crm', 'ienumerable', 'jquery-select2', 'nodes', 'process', 'server', 'sqlite', 'tsql', 'vb6', 'xamarin') AND q.view_count >= 100 AND q.view_count <= 100000