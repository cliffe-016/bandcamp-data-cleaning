{{ config(
    materialized='table'
) }}

WITH staging AS (
    SELECT * FROM {{ ref('stg_bandcamp_sales') }}
),

fact_sales AS (
    SELECT 
        sale_key,        
        id AS transaction_id,
        utc_date AS sale_date,
        country,
        -- Foreign Keys 
        {{ dbt_utils.generate_surrogate_key(['artist_name']) }} AS artist_key,
        {{ dbt_utils.generate_surrogate_key(['album_title', 'item_type', 'song_medium']) }} AS item_key,
        item_price_usd,
        discount_usd,
        amount_over_usd,
        amount_paid_usd

    FROM staging
)

SELECT * FROM fact_sales
