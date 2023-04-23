SELECT COUNT(*) FROM tag AS t, site AS s, question AS q, tag_question AS tq WHERE t.site_id = s.site_id AND q.site_id = s.site_id AND tq.site_id = s.site_id AND tq.question_id = q.id AND tq.tag_id = t.id AND s.site_name IN ('codereview') AND t.name IN ('algorithm', 'array', 'beginner', 'c', 'c++', 'html', 'java', 'javascript', 'performance', 'sql', 'strings') AND q.score >= 0 AND q.score <= 5