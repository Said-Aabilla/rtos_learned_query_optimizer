SELECT COUNT(*) FROM tag AS t, site AS s, question AS q, tag_question AS tq WHERE t.site_id = s.site_id AND q.site_id = s.site_id AND tq.site_id = s.site_id AND tq.question_id = q.id AND tq.tag_id = t.id AND s.site_name IN ('serverfault') AND t.name IN ('active-directory', 'amazon-ec2', 'apache-2.4', 'backup', 'centos', 'firewall', 'iis', 'iptables', 'security', 'ssh', 'windows-server-2003') AND q.view_count >= 10 AND q.view_count <= 1000