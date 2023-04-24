SELECT COUNT(*) FROM tag AS t, site AS s, question AS q, tag_question AS tq WHERE t.site_id = s.site_id AND q.site_id = s.site_id AND tq.site_id = s.site_id AND tq.question_id = q.id AND tq.tag_id = t.id AND s.site_name IN ('stackoverflow') AND t.name IN ('arangodb', 'correlation', 'cut', 'facebook-ios-sdk', 'http-live-streaming', 'http-status-code-403', 'jdeveloper', 'joomla2.5', 'jtree', 'kill', 'lm', 'vuforia') AND q.score >= 0 AND q.score <= 1000