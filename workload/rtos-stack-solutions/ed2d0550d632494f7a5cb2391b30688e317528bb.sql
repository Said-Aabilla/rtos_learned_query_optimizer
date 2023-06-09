/*+
Leading((((tq t) s) q))
*/
SELECT COUNT(*) FROM tag AS t, site AS s, question AS q, tag_question AS tq WHERE t.site_id = s.site_id AND q.site_id = s.site_id AND tq.site_id = s.site_id AND tq.question_id = q.id AND tq.tag_id = t.id AND s.site_name IN ('scifi') AND t.name IN ('books', 'short-stories', 'story-identification') AND q.view_count >= 100 AND q.view_count <= 100000