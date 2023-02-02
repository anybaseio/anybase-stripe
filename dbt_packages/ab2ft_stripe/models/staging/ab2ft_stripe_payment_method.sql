SELECT
    cast({{ json_extract_scalar ("_airbyte_data", ['livemode']) }} AS boolean) AS "livemode",
    NULL AS "id",
    NULL AS "created",
    NULL AS "customer_id",
    NULL AS "metadata",
    NULL AS "type"
FROM {{ var('airbyte_raw_payment_intents') }}