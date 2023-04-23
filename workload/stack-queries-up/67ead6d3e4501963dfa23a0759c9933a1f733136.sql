SELECT COUNT(*) FROM tag AS t, site AS s, question AS q, tag_question AS tq WHERE t.site_id = s.site_id AND q.site_id = s.site_id AND tq.site_id = s.site_id AND tq.question_id = q.id AND tq.tag_id = t.id AND s.site_name IN ('stackoverflow') AND t.name IN ('applescript', 'applet', 'cdi', 'celery', 'dataset', 'django-templates', 'drupal-7', 'escaping', 'local-storage', 'pinvoke', 'pivot', 'scheme', 'signalr', 'web-config', 'windows-store-apps') AND q.favorite_count >= 1 AND q.favorite_count <= 10