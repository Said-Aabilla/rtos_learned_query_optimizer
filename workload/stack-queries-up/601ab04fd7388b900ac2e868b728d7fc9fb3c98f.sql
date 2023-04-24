SELECT acc.location, COUNT(*) FROM site AS s, so_user AS u1, question AS q1, answer AS a1, tag AS t1, tag_question AS tq1, badge AS b, account AS acc WHERE s.site_id = q1.site_id AND s.site_id = u1.site_id AND s.site_id = a1.site_id AND s.site_id = t1.site_id AND s.site_id = tq1.site_id AND s.site_id = b.site_id AND q1.id = tq1.question_id AND q1.id = a1.question_id AND a1.owner_user_id = u1.id AND t1.id = tq1.tag_id AND b.user_id = u1.id AND acc.id = u1.account_id AND s.site_name IN ('askubuntu', 'codereview', 'gis', 'magento', 'unix') AND t1.name IN ('apache2', 'boot', 'css', 'fedora', 'gnome-shell', 'google-chrome', 'gui', 'leaflet', 'live-usb', 'qgis', 'software-center', 'suspend', 'text-processing', 'wms') AND q1.view_count >= 100 AND q1.view_count <= 100000 AND u1.downvotes >= 0 AND u1.downvotes <= 1 AND b.name IN ('Cleanup', 'Explainer', 'Fanatic', 'Good Question', 'Organizer', 'Peer Pressure', 'Tag Editor', 'Talkative') GROUP BY acc.location ORDER BY COUNT(*) DESC LIMIT 100