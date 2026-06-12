WITH raw_sales AS (
    SELECT * FROM {{ ref('bandcamp_sales') }}
    ),

cleaned_sales AS (
    SELECT
        -- Generate a unique Surrogate Key for line items
        {{ dbt_utils.generate_surrogate_key(['_id', 'artist_name', 'album_title']) }} AS sale_key,
        -- Remove URLs and whitespace from the  id column
        regexp_replace(_id, '\D', '', 'g') as id,
        NULLIF(TRIM(artist_name), '') AS artist_name, 
        NULLIF(TRIM(album_title), '') AS album_title,
        -- Rename items types
        CASE
            WHEN item_type = 'a' THEN 'Digital Albums'
            WHEN item_type = 'b' THEN 'Physical Items'
            ELSE 'Digital Tracks'
        END AS song_medium,
        -- Rename slug types
        CASE 
            WHEN slug_type = 'a' THEN 'Albums'
            WHEN slug_type = 'p' THEN 'Merchandise'
            ELSE 'Tracks'
        END AS item_type,
        -- Standardize the currency
        (item_price::NUMERIC * (amount_paid_usd::NUMERIC / NULLIF(amount_paid::NUMERIC, 0))) AS item_price_usd,
        amount_paid_usd::NUMERIC AS amount_paid_usd,
        -- Calculaate tips accountting for negatives
        GREATEST(0, ((amount_paid::NUMERIC - item_price::NUMERIC) * (amount_paid_usd::NUMERIC / NULLIF(amount_paid::NUMERIC, 0)))) AS amount_over_usd,
        -- Calculate discount 
        GREATEST(0, ((item_price::NUMERIC - amount_paid::NUMERIC) * (amount_paid_usd::NUMERIC / NULLIF(amount_paid::NUMERIC, 0)))) AS discount_usd,
        country,
        -- Convert utc_date to timestamp
        to_timestamp(utc_date::NUMERIC) as utc_date
    FROM raw_sales
)

-- Deduplicate
SELECT DISTINCT * FROM cleaned_sales
