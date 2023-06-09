/*+
Leading((((tq t) s) q))
*/
SELECT COUNT(*) FROM tag AS t, site AS s, question AS q, tag_question AS tq WHERE t.site_id = s.site_id AND q.site_id = s.site_id AND tq.site_id = s.site_id AND tq.question_id = q.id AND tq.tag_id = t.id AND s.site_name IN ('stackoverflow') AND t.name IN ('background', 'binary', 'console', 'django-views', 'google-bigquery', 'html-parsing', 'iis-7', 'jmeter', 'joomla', 'png') AND q.favorite_count >= 0 AND q.favorite_count <= 1