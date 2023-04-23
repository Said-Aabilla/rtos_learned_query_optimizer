SELECT COUNT(*) FROM tag AS t, site AS s, question AS q, tag_question AS tq WHERE t.site_id = s.site_id AND q.site_id = s.site_id AND tq.site_id = s.site_id AND tq.question_id = q.id AND tq.tag_id = t.id AND s.site_name IN ('physics') AND t.name IN ('black-holes', 'classical-mechanics', 'condensed-matter', 'cosmology', 'electromagnetism', 'electrostatics', 'fluid-dynamics', 'forces', 'newtonian-mechanics', 'optics', 'particle-physics', 'quantum-mechanics', 'special-relativity', 'thermodynamics') AND q.favorite_count >= 1 AND q.favorite_count <= 10