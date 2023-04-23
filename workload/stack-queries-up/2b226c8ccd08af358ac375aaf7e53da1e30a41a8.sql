SELECT COUNT(*) FROM tag AS t, site AS s, question AS q, tag_question AS tq WHERE t.site_id = s.site_id AND q.site_id = s.site_id AND tq.site_id = s.site_id AND tq.question_id = q.id AND tq.tag_id = t.id AND s.site_name IN ('stackoverflow') AND t.name IN ('android-service', 'decimal', 'dialog', 'docusignapi', 'echo', 'jasmine', 'jwt', 'laravel-5.4', 'node-modules', 'text-files') AND q.view_count >= 0 AND q.view_count <= 100