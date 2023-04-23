SELECT COUNT(*) FROM tag AS t, site AS s, question AS q, tag_question AS tq WHERE t.site_id = s.site_id AND q.site_id = s.site_id AND tq.site_id = s.site_id AND tq.question_id = q.id AND tq.tag_id = t.id AND s.site_name IN ('stackoverflow') AND t.name IN ('android-fragments', 'cookies', 'django-models', 'enums', 'jsf', 'machine-learning', 'memory-management', 'msbuild', 'react-native') AND q.score >= 10 AND q.score <= 1000