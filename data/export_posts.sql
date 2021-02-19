CREATE TEMPORARY VIEW export_posts AS (
SELECT
      s.post_id
    , s.post_created::timestamp(3)
    , s.post_short_code
    , s.poster_id
    , s.post_type
    , s.ig_media_caption
    , to_json(s.image_labels) image_labels
    , s.image_adult
    , s.image_medical
    , s.image_racy
    , s.image_spoof
    , s.image_violence
    , u.ig_username poster_username
FROM T_static s
LEFT JOIN ig_observer_iguser u ON s.poster_id = u.id
WHERE u.project_id = 2
ORDER BY post_id
);

\copy (SELECT * FROM export_posts) TO 'data/posts.csv' WITH CSV HEADER;

