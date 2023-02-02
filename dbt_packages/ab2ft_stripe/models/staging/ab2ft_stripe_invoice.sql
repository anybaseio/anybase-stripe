WITH _tmp_unpack_json AS (
SELECT
    to_timestamp(cast({{ json_extract_scalar ("_airbyte_data", ['due_date']) }} AS numeric)) AS "due_date",
    to_timestamp(cast({{ json_extract_scalar ("_airbyte_data", ['created']) }} AS numeric)) AS "created",
    {{ json_extract_scalar ("_airbyte_data", ['id']) }} AS "id",
    cast({{ json_extract_scalar ("_airbyte_data", ['amount_due']) }} AS integer) AS "amount_due",
    cast({{ json_extract_scalar ("_airbyte_data", ['amount_paid']) }} AS integer) AS "amount_paid",
    cast({{ json_extract_scalar ("_airbyte_data", ['amount_remaining']) }} AS integer) AS "amount_remaining",
    cast({{ json_extract_scalar ("_airbyte_data", ['attempt_count']) }} AS integer) AS "attempt_count",
    cast({{ json_extract_scalar ("_airbyte_data", ['auto_advance']) }} AS boolean) AS "auto_advance",
    {{ json_extract_scalar ("_airbyte_data", ['billing_reason']) }} AS "billing_reason",
    {{ json_extract_scalar ("_airbyte_data", ['charge']) }} AS "charge_id",
    {{ json_extract_scalar ("_airbyte_data", ['currency']) }} AS "currency",
    {{ json_extract_scalar ("_airbyte_data", ['customer']) }} AS "customer_id",
    {{ json_extract_scalar ("_airbyte_data", ['description']) }} AS "description",
    {{ json_extract_scalar ("_airbyte_data", ['metadata']) }} AS "metadata",
    {{ json_extract_scalar ("_airbyte_data", ['number']) }} AS "number",
    cast({{ json_extract_scalar ("_airbyte_data", ['paid']) }} AS boolean) AS "paid",
    {{ json_extract_scalar ("_airbyte_data", ['receipt_number']) }} AS "receipt_number",
    {{ json_extract_scalar ("_airbyte_data", ['status']) }} AS "status",
    cast({{ json_extract_scalar ("_airbyte_data", ['subtotal']) }} AS integer) AS "subtotal",
    cast({{ json_extract_scalar ("_airbyte_data", ['tax']) }} AS integer) AS "tax",
    cast({{ json_extract_scalar ("_airbyte_data", ['tax_percent']) }} AS numeric) AS "tax_percent",
    cast({{ json_extract_scalar ("_airbyte_data", ['total']) }} AS integer) AS "total",
    cast({{ json_extract_scalar ("_airbyte_data", ['livemode']) }} AS boolean) AS "livemode",
    _airbyte_emitted_at
FROM {{ var('airbyte_raw_invoices') }}
), 
_tmp_dedup_pk AS (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY "id" ORDER BY "_airbyte_emitted_at" DESC) AS _tmp_pk_row_number
    FROM _tmp_unpack_json
)
SELECT
    "due_date",
    "created",
    "id",
    "amount_due",
    "amount_paid",
    "amount_remaining",
    "attempt_count",
    "auto_advance",
    "billing_reason",
    "charge_id",
    "currency",
    "customer_id",
    "description",
    "metadata",
    "number",
    "paid",
    "receipt_number",
    "status",
    "subtotal",
    "tax",
    "tax_percent",
    "total",
    "livemode"
FROM _tmp_dedup_pk
WHERE _tmp_pk_row_number = 1