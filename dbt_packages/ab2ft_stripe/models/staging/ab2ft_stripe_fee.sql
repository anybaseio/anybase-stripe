SELECT
    NULL AS "balance_transaction_id",
    NULL AS "amount",
    NULL AS "application",
    NULL AS "currency",
    NULL AS "description",
    NULL AS "type"
FROM {{ var('airbyte_raw_balance_transactions') }}