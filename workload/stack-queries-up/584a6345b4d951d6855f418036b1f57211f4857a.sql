SELECT acc.location, COUNT(*) FROM site AS s, so_user AS u1, question AS q1, answer AS a1, tag AS t1, tag_question AS tq1, badge AS b, account AS acc WHERE s.site_id = q1.site_id AND s.site_id = u1.site_id AND s.site_id = a1.site_id AND s.site_id = t1.site_id AND s.site_id = tq1.site_id AND s.site_id = b.site_id AND q1.id = tq1.question_id AND q1.id = a1.question_id AND a1.owner_user_id = u1.id AND t1.id = tq1.tag_id AND b.user_id = u1.id AND acc.id = u1.account_id AND s.site_name IN ('codereview', 'ru') AND t1.name IN ('css3', 'delphi', 'excel', 'html5', 'ios', 'object-oriented', 'pandas', 'postgresql', 'qt', 'ubuntu', 'windows', 'xml', 'алгоритм') AND q1.view_count >= 0 AND q1.view_count <= 100 AND u1.reputation >= 10 AND u1.reputation <= 100000 AND b.name IN ('Civic Duty', 'Cleanup', 'Enlightened', 'Explainer', 'Good Answer', 'Necromancer', 'Organizer', 'Quorum', 'Reviewer', 'Self-Learner', 'Suffrage', 'Tag Editor', 'Talkative', 'Vox Populi') GROUP BY acc.location ORDER BY COUNT(*) DESC LIMIT 100