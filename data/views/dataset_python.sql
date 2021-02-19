DROP TABLE IF EXISTS dataset;
CREATE TABLE dataset AS (
    SELECT
        -- Add identifiers.
        d.post_id
        , d.post_created
        , d.donor_id
        , d.donation_created
        , d.encounter
        -- Add post properties.
        , s.post_short_code
        , s.post_type
        , to_json(s.hashtags) post_hashtags
        , s.image_adult post_img_adult
        , s.image_medical post_img_medical
        , s.image_racy post_img_racy
        , s.image_spoof post_img_spoof
        , s.image_violence post_img_violence
        , to_json(s.image_labels) post_img_labels
        -- Add poster properties.
        -- TODO party, followers at time of post.
        , poster.id poster_id
        , poster.ig_username poster_username
        -- Add engagement data.
        , d.follows donor_follows_count
        , d.follows_poster donor_follows_poster
        , d.likes_count
        , d.comments_count
    FROM T_dynamic d
    LEFT JOIN T_static s on s.post_id = d.post_id
    LEFT JOIN ig_observer_iguser poster on poster.id = s.poster_id
    WHERE d.project_id = 2
    ORDER BY post_id, donor_id, donation_created
);
\copy dataset TO 'TAMI-project2.csv' WITH CSV HEADER