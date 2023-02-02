WITH _tmp_unpack_json AS (
SELECT
    {{ json_extract_scalar ("_airbyte_data", ['id']) }} AS "id",
    cast({{ json_extract_scalar ("_airbyte_data", ['amount']) }} AS integer) AS "amount",
    {{ json_extract_scalar ("_airbyte_data", ['balance_transaction']) }} AS "balance_transaction_id",
    {{ json_extract_scalar ("_airbyte_data", ['charge']) }} AS "charge_id",
    cast({{ json_extract_scalar ("_airbyte_data", ['created']) }} AS integer) AS "created",
    {{ json_extract_scalar ("_airbyte_data", ['currency']) }} AS "currency",
    NULL AS "description",
    {{ json_extract_scalar ("_airbyte_data", ['metadata']) }} AS "metadata",
    {{ json_extract_scalar ("_airbyte_data", ['reason']) }} AS "reason",
    {{ json_extract_scalar ("_airbyte_data", ['receipt_number']) }} AS "receipt_number",
    {{ json_extract_scalar ("_airbyte_data", ['status']) }} AS "status",
    _airbyte_emitted_at
FROM {{ var('airbyte_raw_refunds') }}
), 
_tmp_dedup_pk AS (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY "id" ORDER BY "_airbyte_emitted_at" DESC) AS _tmp_pk_row_number
    FROM _tmp_unpack_json
)
SELECT
    "id",
    "amount",
    "balance_transaction_id",
    "charge_id",
    "created",
    "currency",
    "description",
    "metadata",
    "reason",
    "receipt_number",
    "status"
FROM _tmp_dedup_pk
WHERE _tmp_pk_row_number = 1