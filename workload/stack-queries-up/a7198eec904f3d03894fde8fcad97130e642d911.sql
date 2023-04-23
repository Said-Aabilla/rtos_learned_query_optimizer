SELECT acc.location, COUNT(*) FROM site AS s, so_user AS u1, question AS q1, answer AS a1, tag AS t1, tag_question AS tq1, badge AS b, account AS acc WHERE s.site_id = q1.site_id AND s.site_id = u1.site_id AND s.site_id = a1.site_id AND s.site_id = t1.site_id AND s.site_id = tq1.site_id AND s.site_id = b.site_id AND q1.id = tq1.question_id AND q1.id = a1.question_id AND a1.owner_user_id = u1.id AND t1.id = tq1.tag_id AND b.user_id = u1.id AND acc.id = u1.account_id AND s.site_name IN ('stackoverflow', 'superuser') AND t1.name IN ('alamofire', 'analytics', 'azure-active-directory', 'cryptography', 'hdfs', 'hide', 'jaxb', 'opengl', 'precision', 'request', 'user-input', 'web-applications', 'web-services', 'yii') AND q1.view_count >= 10 AND q1.view_count <= 1000 AND u1.downvotes >= 0 AND u1.downvotes <= 1 AND b.name IN ('Altruist', 'Great Question', 'Guru', 'Quorum') GROUP BY acc.location ORDER BY COUNT(*) DESC LIMIT 100