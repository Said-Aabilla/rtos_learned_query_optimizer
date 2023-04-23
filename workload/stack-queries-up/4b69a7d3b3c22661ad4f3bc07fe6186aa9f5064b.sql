SELECT COUNT(*) FROM tag AS t, site AS s, question AS q, tag_question AS tq WHERE t.site_id = s.site_id AND q.site_id = s.site_id AND tq.site_id = s.site_id AND tq.question_id = q.id AND tq.tag_id = t.id AND s.site_name IN ('dba') AND t.name IN ('backup', 'join', 'mariadb', 'mongodb', 'optimization', 'oracle-11g-r2', 'permissions', 'restore', 'sql-server-2005', 'sql-server-2016', 'trigger') AND q.score >= 0 AND q.score <= 5