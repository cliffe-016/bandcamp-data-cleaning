{{ config(
    materialized='table'
) }}

WITH staging AS (
    SELECT * FROM {{ ref('stg_bandcamp_sales') }}
),

unique_items AS (
    SELECT DISTINCT
        album_title,
        item_type,
        song_medium
    FROM staging
)

SELECT 
    -- Generate a Surrogate Key based on the combination of attributes
    {{ dbt_utils.generate_surrogate_key(['album_title', 'item_type', 'song_medium']) }} AS item_key,
    
    album_title,
    item_type,
    song_medium
FROM unique_items
