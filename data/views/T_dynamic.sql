DROP VIEW IF EXISTS potential_encounters CASCADE;
CREATE VIEW potential_encounters AS
SELECT
    pr.id project_id
    , p.id post_id
    , date_trunc('second', p.ig_taken_at_timestamp) post_created
    , p.ig_user_id post_user_id
    , d.donor_id
    , d.id donation_id
    , date_trunc('second', d.created) donation_created
FROM ig_observer_project pr
INNER JOIN ig_observer_iguser u ON u.project_id = pr.id
INNER JOIN ig_observer_igpost p ON p.ig_user_id = u.id
CROSS JOIN data_donors_datadonation d
WHERE 
    d.created BETWEEN 
        p.ig_taken_at_timestamp AND 
        p.ig_taken_at_timestamp + (7 || 'days')::interval
;

DROP MATERIALIZED VIEW IF EXISTS T_dynamic;
CREATE MATERIALIZED VIEW T_dynamic AS
SELECT DISTINCT ON (project_id, post_id, donation_id)
    pe.project_id
    , pe.post_id
    , pe.post_created
    , pe.donor_id
    , pe.donation_id
    , pe.donation_created
    , e.id IS NOT NULL encounter
    , f.id IS NOT NULL follows_poster
    , f2.follows
    , g.id engagement_id
    , date_trunc('second', g.created) engagement_created
    , g.likes_count
    , g.comments_count
FROM potential_encounters pe
LEFT JOIN data_donors_donor_following f ON 
    f.donor_id = pe.donor_id AND
    f.iguser_id = pe.post_user_id
LEFT JOIN (
    SELECT donor_id , COUNT(DISTINCT following_ig_username) follows
    FROM data_donors_donorfollowing
    GROUP BY donor_id
) f2 ON f2.donor_id = pe.donor_id
LEFT JOIN data_donors_encounter e ON
    e.data_donation_id = pe.donation_id AND
    e.ig_post_id = pe.post_id
INNER JOIN ig_observer_igengagements g ON g.ig_post_id = pe.post_id
WHERE 
    f.id IS NOT NULL AND -- keep followed accounts only.
    g.created BETWEEN pe.donation_created - (1 || 'hour')::interval AND pe.donation_created
ORDER BY pe.project_id, pe.post_id, pe.donation_id, g.created DESC;