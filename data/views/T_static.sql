DROP VIEW IF EXISTS post_tags CASCADE;
CREATE VIEW post_tags AS
SELECT 
    p.id post_id 
    , unnest(regexp_matches(p.ig_media_caption, '#(\w\w\w+)', 'g')) hashtag
FROM ig_observer_igpost p;

DROP TYPE IF EXISTS safe_search CASCADE;
CREATE TYPE safe_search AS ENUM (
    'VERY_UNLIKELY', 'UNLIKELY', 'POSSIBLE', 'LIKELY', 'VERY_LIKELY'
);

DROP VIEW IF EXISTS post_image_labels CASCADE;
CREATE VIEW post_image_labels AS (
SELECT 
    i.ig_post_id post_id
    , i.id image_id
    , jsonb_path_query(gv.analyse, '$.labelAnnotations[*].description')->>0 "label"
FROM ig_observer_gvisionanalyse gv
INNER JOIN ig_observer_igimage i ON i.id = gv.ig_image_id
);

DROP VIEW IF EXISTS post_image_safesearch CASCADE;
CREATE VIEW post_image_safesearch AS (
SELECT 
    i.ig_post_id post_id
    , i.id image_id
    , (gv.analyse->'safeSearchAnnotation'->>'adult')::safe_search adult
    , (gv.analyse->'safeSearchAnnotation'->>'medical')::safe_search medical
    , (gv.analyse->'safeSearchAnnotation'->>'racy')::safe_search racy
    , (gv.analyse->'safeSearchAnnotation'->>'spoof')::safe_search spoof
    , (gv.analyse->'safeSearchAnnotation'->>'violence')::safe_search violence
FROM ig_observer_gvisionanalyse gv
INNER JOIN ig_observer_igimage i ON i.id = gv.ig_image_id
);

DROP MATERIALIZED VIEW IF EXISTS T_static;
CREATE MATERIALIZED VIEW T_static AS
WITH ht AS (
    SELECT
        post_id
        , array_agg(DISTINCT hashtag) FILTER (WHERE hashtag IS NOT NULL) hashtags
    FROM post_tags
    GROUP BY post_id
), ss AS (
    SELECT
        post_id
        , MAX(array_length(enum_range(NULL, adult), 1)) image_adult
        , MAX(array_length(enum_range(NULL, medical), 1)) image_medical
        , MAX(array_length(enum_range(NULL, racy), 1)) image_racy
        , MAX(array_length(enum_range(NULL, spoof), 1)) image_spoof
        , MAX(array_length(enum_range(NULL, violence), 1)) image_violence
    FROM post_image_safesearch
    GROUP BY post_id
), il AS (
    SELECT
        post_id
        , array_agg(DISTINCT "label") image_labels
    FROM post_image_labels
    GROUP BY post_id
)
SELECT
    p.id post_id
    , p.ig_taken_at_timestamp post_created
    , p.ig_user_id poster_id
    , p.ig_shortcode post_short_code
    , p.ig_type post_type
    , p.ig_media_caption
    , ht.hashtags
    , ss.image_adult
    , ss.image_medical
    , ss.image_racy
    , ss.image_spoof
    , ss.image_violence
    , il.image_labels
FROM ig_observer_igpost p
LEFT JOIN ht ON ht.post_id = p.id
LEFT JOIN ss ON ss.post_id = p.id
LEFT JOIN il ON il.post_id = p.id
;