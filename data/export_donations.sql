CREATE TEMPORARY VIEW export_donations AS (
SELECT 
    donor_id
    , donation_created::timestamp(3)
    , post_id
    , post_created::timestamp(3)
    , likes_count
    , comments_count
    , encounter::int
    , follows_poster::int
    , follows::int
FROM T_dynamic
WHERE project_id=2
ORDER BY donor_id, post_id, donation_created
);

\copy (SELECT * FROM export_donations) TO 'data/donations.csv' WITH CSV HEADER;