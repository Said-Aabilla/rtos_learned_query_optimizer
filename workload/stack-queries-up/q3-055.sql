SELECT COUNT(DISTINCT(acc.display_name)) FROM tag AS t1, site AS s1, question AS q1, answer AS a1, tag_question AS tq1, so_user AS u1, tag AS t2, site AS s2, question AS q2, tag_question AS tq2, so_user AS u2, account AS acc WHERE s1.site_name = 'stackoverflow' AND t1.name = 'if-statement' AND t1.site_id = s1.site_id AND q1.site_id = s1.site_id AND tq1.site_id = s1.site_id AND tq1.question_id = q1.id AND tq1.tag_id = t1.id AND a1.site_id = q1.site_id AND a1.question_id = q1.id AND a1.owner_user_id = u1.id AND a1.site_id = u1.site_id AND s2.site_name = 'math' AND t2.name = 'geometry' AND t2.site_id = s2.site_id AND q2.site_id = s2.site_id AND tq2.site_id = s2.site_id AND tq2.question_id = q2.id AND tq2.tag_id = t2.id AND q2.owner_user_id = u2.id AND q2.site_id = u2.site_id AND u1.account_id = u2.account_id AND acc.id = u1.account_id