-- This test will FAIL if a single row is returned with a negative number.
SELECT 
    id, 
    amount_over_usd
FROM {{ ref('stg_bandcamp_sales') }}
WHERE amount_over_usd < 0
