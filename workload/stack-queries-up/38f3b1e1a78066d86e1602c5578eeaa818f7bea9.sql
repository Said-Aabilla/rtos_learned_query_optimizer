SELECT acc.location, COUNT(*) FROM site AS s, so_user AS u1, question AS q1, answer AS a1, tag AS t1, tag_question AS tq1, badge AS b, account AS acc WHERE s.site_id = q1.site_id AND s.site_id = u1.site_id AND s.site_id = a1.site_id AND s.site_id = t1.site_id AND s.site_id = tq1.site_id AND s.site_id = b.site_id AND q1.id = tq1.question_id AND q1.id = a1.question_id AND a1.owner_user_id = u1.id AND t1.id = tq1.tag_id AND b.user_id = u1.id AND acc.id = u1.account_id AND s.site_name IN ('stackoverflow') AND t1.name IN ('amazon-redshift', 'asp.net-mvc-3', 'authorization', 'google-oauth', 'handlebars.js', 'inner-join', 'java-native-interface', 'macos', 'max', 'pagination', 'pivot', 'pycharm', 'ssrs-2012', 'tkinter', 'visual-studio-2012') AND q1.view_count >= 10 AND q1.view_count <= 1000 AND u1.reputation >= 0 AND u1.reputation <= 100 AND b.name IN ('Announcer', 'Civic Duty', 'Disciplined', 'Fanatic', 'Investor', 'Nice Answer', 'Quorum', 'Self-Learner', 'Tag Editor', 'Talkative', 'Vox Populi', 'Yearling') GROUP BY acc.location ORDER BY COUNT(*) DESC LIMIT 100