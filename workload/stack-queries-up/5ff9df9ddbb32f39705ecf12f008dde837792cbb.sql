SELECT COUNT(*) FROM site AS s, so_user AS u1, question AS q1, answer AS a1, tag AS t1, tag_question AS tq1, badge AS b, account AS acc WHERE s.site_id = q1.site_id AND s.site_id = u1.site_id AND s.site_id = a1.site_id AND s.site_id = t1.site_id AND s.site_id = tq1.site_id AND s.site_id = b.site_id AND q1.id = tq1.question_id AND q1.id = a1.question_id AND a1.owner_user_id = u1.id AND t1.id = tq1.tag_id AND b.user_id = u1.id AND acc.id = u1.account_id AND s.site_name IN ('physics', 'ru', 'stackoverflow', 'tex') AND t1.name IN ('angular-cli', 'doctrine', 'electromagnetic-radiation', 'glsl', 'google-bigquery', 'sbt', 'signalr', 'singleton', 'stack', 'time-complexity', 'uiimageview') AND q1.favorite_count >= 0 AND q1.favorite_count <= 1 AND u1.upvotes >= 1 AND u1.upvotes <= 100 AND b.name IN ('Altruist', 'Deputy', 'Documentation User', 'Guru', 'Inquisitive', 'Populist', 'Strunk & White', 'Suffrage', 'Taxonomist', 'Tenacious', 'Vox Populi')