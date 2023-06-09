/*+
Leading((((t s) tq) q))
*/
SELECT COUNT(*) FROM tag AS t, site AS s, question AS q, tag_question AS tq WHERE t.site_id = s.site_id AND q.site_id = s.site_id AND tq.site_id = s.site_id AND tq.question_id = q.id AND tq.tag_id = t.id AND s.site_name IN ('magento') AND t.name IN ('magento-1.7', 'magento-1.9', 'magento-2.1', 'module', 'php', 'product') AND q.score >= 0 AND q.score <= 0