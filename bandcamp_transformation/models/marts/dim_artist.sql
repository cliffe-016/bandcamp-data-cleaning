{{ config(
    materialized='table'
) }}

WITH staging AS (
    SELECT * FROM {{ ref('stg_bandcamp_sales') }}
),

unique_artists AS (
    SELECT DISTINCT
        artist_name
    FROM staging
)

SELECT 
    -- Generate a Surrogate Key for the dimension
    {{ dbt_utils.generate_surrogate_key(['artist_name']) }} AS artist_key,
    artist_name
FROM unique_artists
