SELECT b1.name, COUNT(*) FROM site AS s, so_user AS u1, tag AS t1, tag_question AS tq1, question AS q1, badge AS b1, account AS acc WHERE s.site_id = u1.site_id AND s.site_id = b1.site_id AND s.site_id = t1.site_id AND s.site_id = tq1.site_id AND s.site_id = q1.site_id AND t1.id = tq1.tag_id AND q1.id = tq1.question_id AND q1.owner_user_id = u1.id AND acc.id = u1.account_id AND b1.user_id = u1.id AND q1.view_count >= 10 AND q1.view_count <= 1000 AND s.site_name IN ('dba', 'gis', 'mathoverflow', 'physics', 'superuser') AND t1.name IN ('air', 'arcgis-javascript-api-4', 'basemap', 'electroweak', 'group-policy', 'macbook-pro', 'maintenance', 'monitoring', 'qgis-modeler', 'route', 'stochastic-differential-equations', 'text-editing', 'wordpress') AND acc.website_url LIKE '%com' GROUP BY b1.name ORDER BY COUNT(*) DESC LIMIT 100