SELECT COUNT(*) FROM tag AS t, site AS s, question AS q, tag_question AS tq WHERE t.site_id = s.site_id AND q.site_id = s.site_id AND tq.site_id = s.site_id AND tq.question_id = q.id AND tq.tag_id = t.id AND s.site_name IN ('physics') AND t.name IN ('electric-circuits', 'electric-fields', 'energy', 'fluid-dynamics', 'kinematics', 'newtonian-gravity', 'quantum-field-theory', 'reference-frames') AND q.score >= 0 AND q.score <= 0