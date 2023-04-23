SELECT COUNT(DISTINCT(acc.display_name)) FROM tag AS t1, site AS s1, question AS q1, tag_question AS tq1, so_user AS u1, comment AS c1, account AS acc WHERE s1.site_name = 'german' AND t1.name IN ('possessive-pronouns', 'hyphen', 'gender-neutrality', 'particles', 'prepositions') AND t1.site_id = s1.site_id AND q1.site_id = s1.site_id AND tq1.site_id = s1.site_id AND tq1.question_id = q1.id AND tq1.tag_id = t1.id AND q1.owner_user_id = u1.id AND q1.site_id = u1.site_id AND c1.site_id = q1.site_id AND c1.post_id = q1.id AND c1.score > q1.score AND acc.id = u1.account_id