SELECT COUNT(*) FROM tag AS t, site AS s, question AS q, tag_question AS tq WHERE t.site_id = s.site_id AND q.site_id = s.site_id AND tq.site_id = s.site_id AND tq.question_id = q.id AND tq.tag_id = t.id AND s.site_name IN ('stackoverflow') AND t.name IN ('android-ndk', 'buffer', 'cryptography', 'filesystems', 'grid', 'gson', 'ibm-cloud', 'microservices', 'ms-access-2010', 'office365', 'openssl', 'pipe', 'rx-java') AND q.view_count >= 0 AND q.view_count <= 100