WITH _tmp_unpack_json AS (
SELECT
    cast({{ json_extract_scalar ("_airbyte_data", ['amount']) }} AS integer) AS "amount",
    {{ json_extract_scalar ("_airbyte_data", ['id']) }} AS "id",
    {{ json_extract_scalar ("_airbyte_data", ['invoice']) }} AS "invoice_id",
    {{ json_extract_scalar ("_airbyte_data", ['currency']) }} AS "currency",
    {{ json_extract_scalar ("_airbyte_data", ['description']) }} AS "description",
    cast({{ json_extract_scalar ("_airbyte_data", ['discountable']) }} AS boolean) AS "discountable",
    {{ json_extract_scalar ("_airbyte_data", ['plan']) }} AS "plan_id",
    cast({{ json_extract_scalar ("_airbyte_data", ['proration']) }} AS boolean) AS "proration",
    cast({{ json_extract_scalar ("_airbyte_data", ['quantity']) }} AS integer) AS "quantity",
    {{ json_extract_scalar ("_airbyte_data", ['subscription']) }} AS "subscription_id",
    {{ json_extract_scalar ("_airbyte_data", ['subscription_item']) }} AS "subscription_item_id",
    {{ json_extract_scalar ("_airbyte_data", ['type']) }} AS "type",
    NULL AS "unique_id",
    cast({{ json_extract_scalar ("_airbyte_data", ['livemode']) }} AS boolean) AS "livemode",
    _airbyte_emitted_at
FROM {{ var('airbyte_raw_invoice_line_items') }}
), 
_tmp_dedup_pk AS (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY "id" ORDER BY "_airbyte_emitted_at" DESC) AS _tmp_pk_row_number
    FROM _tmp_unpack_json
)
SELECT
    "amount",
    "id",
    "invoice_id",
    "currency",
    "description",
    "discountable",
    "plan_id",
    "proration",
    "quantity",
    "subscription_id",
    "subscription_item_id",
    "type",
    "unique_id",
    "livemode"
FROM _tmp_dedup_pk
WHERE _tmp_pk_row_number = 1