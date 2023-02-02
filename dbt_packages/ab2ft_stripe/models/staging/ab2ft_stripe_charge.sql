WITH _tmp_unpack_json AS (
SELECT
    to_timestamp(cast({{ json_extract_scalar ("_airbyte_data", ['created']) }} AS numeric)) AS "created",
    {{ json_extract_scalar ("_airbyte_data", ['id']) }} AS "id",
    cast({{ json_extract_scalar ("_airbyte_data", ['amount']) }} AS integer) AS "amount",
    cast({{ json_extract_scalar ("_airbyte_data", ['amount_refunded']) }} AS integer) AS "amount_refunded",
    NULL AS "application_fee_amount",
    {{ json_extract_scalar ("_airbyte_data", ['balance_transaction']) }} AS "balance_transaction_id",
    cast({{ json_extract_scalar ("_airbyte_data", ['captured']) }} AS boolean) AS "captured",
    {{ json_extract_scalar ("_airbyte_data", ['card']) }} AS "card_id",
    {{ json_extract_scalar ("_airbyte_data", ['customer']) }} AS "customer_id",
    {{ json_extract_scalar ("_airbyte_data", ['description']) }} AS "description",
    {{ json_extract_scalar ("_airbyte_data", ['failure_code']) }} AS "failure_code",
    {{ json_extract_scalar ("_airbyte_data", ['failure_message']) }} AS "failure_message",
    {{ json_extract_scalar ("_airbyte_data", ['metadata']) }} AS "metadata",
    cast({{ json_extract_scalar ("_airbyte_data", ['paid']) }} AS boolean) AS "paid",
    {{ json_extract_scalar ("_airbyte_data", ['payment_intent']) }} AS "payment_intent_id",
    {{ json_extract_scalar ("_airbyte_data", ['receipt_email']) }} AS "receipt_email",
    {{ json_extract_scalar ("_airbyte_data", ['receipt_number']) }} AS "receipt_number",
    cast({{ json_extract_scalar ("_airbyte_data", ['refunded']) }} AS boolean) AS "refunded",
    {{ json_extract_scalar ("_airbyte_data", ['status']) }} AS "status",
    {{ json_extract_scalar ("_airbyte_data", ['invoice']) }} AS "invoice_id",
    {{ json_extract_scalar ("_airbyte_data", ['currency']) }} AS "currency",
    cast({{ json_extract_scalar ("_airbyte_data", ['livemode']) }} AS boolean) AS "livemode",
    _airbyte_emitted_at
FROM {{ var('airbyte_raw_charges') }}
), 
_tmp_dedup_pk AS (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY "id" ORDER BY "_airbyte_emitted_at" DESC) AS _tmp_pk_row_number
    FROM _tmp_unpack_json
)
SELECT
    "created",
    "id",
    "amount",
    "amount_refunded",
    "application_fee_amount",
    "balance_transaction_id",
    "captured",
    "card_id",
    "customer_id",
    "description",
    "failure_code",
    "failure_message",
    "metadata",
    "paid",
    "payment_intent_id",
    "receipt_email",
    "receipt_number",
    "refunded",
    "status",
    "invoice_id",
    "currency",
    "livemode"
FROM _tmp_dedup_pk
WHERE _tmp_pk_row_number = 1