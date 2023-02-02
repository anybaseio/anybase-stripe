WITH _tmp_unpack_json AS (
SELECT
    {{ json_extract_scalar ("_airbyte_data", ['id']) }} AS "id",
    cast({{ json_extract_scalar ("_airbyte_data", ['amount']) }} AS integer) AS "amount",
    cast({{ json_extract_scalar ("_airbyte_data", ['amount_capturable']) }} AS integer) AS "amount_capturable",
    cast({{ json_extract_scalar ("_airbyte_data", ['amount_received']) }} AS integer) AS "amount_received",
    {{ json_extract_scalar ("_airbyte_data", ['application']) }} AS "application",
    cast({{ json_extract_scalar ("_airbyte_data", ['application_fee_amount']) }} AS integer) AS "application_fee_amount",
    cast({{ json_extract_scalar ("_airbyte_data", ['canceled_at']) }} AS integer) AS "canceled_at",
    {{ json_extract_scalar ("_airbyte_data", ['cancellation_reason']) }} AS "cancellation_reason",
    {{ json_extract_scalar ("_airbyte_data", ['capture_method']) }} AS "capture_method",
    {{ json_extract_scalar ("_airbyte_data", ['confirmation_method']) }} AS "confirmation_method",
    {{ json_extract_scalar ("_airbyte_data", ['currency']) }} AS "currency",
    {{ json_extract_scalar ("_airbyte_data", ['customer']) }} AS "customer_id",
    {{ json_extract_scalar ("_airbyte_data", ['description']) }} AS "description",
    {{ json_extract_scalar ("_airbyte_data", ['metadata']) }} AS "metadata",
    {{ json_extract_scalar ("_airbyte_data", ['payment_method']) }} AS "payment_method_id",
    {{ json_extract_scalar ("_airbyte_data", ['receipt_email']) }} AS "receipt_email",
    NULL AS "statement_descriptor",
    {{ json_extract_scalar ("_airbyte_data", ['status']) }} AS "status",
    cast({{ json_extract_scalar ("_airbyte_data", ['livemode']) }} AS boolean) AS "livemode",
    _airbyte_emitted_at
FROM {{ var('airbyte_raw_payment_intents') }}
), 
_tmp_dedup_pk AS (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY "id" ORDER BY "_airbyte_emitted_at" DESC) AS _tmp_pk_row_number
    FROM _tmp_unpack_json
)
SELECT
    "id",
    "amount",
    "amount_capturable",
    "amount_received",
    "application",
    "application_fee_amount",
    "canceled_at",
    "cancellation_reason",
    "capture_method",
    "confirmation_method",
    "currency",
    "customer_id",
    "description",
    "metadata",
    "payment_method_id",
    "receipt_email",
    "statement_descriptor",
    "status",
    "livemode"
FROM _tmp_dedup_pk
WHERE _tmp_pk_row_number = 1