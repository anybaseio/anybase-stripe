WITH _tmp_unpack_json AS (
SELECT
    {{ json_extract_scalar ("_airbyte_data", ['id']) }} AS "id",
    cast({{ json_extract_scalar ("_airbyte_data", ['active']) }} AS boolean) AS "active",
    cast({{ json_extract_scalar ("_airbyte_data", ['amount']) }} AS integer) AS "amount",
    {{ json_extract_scalar ("_airbyte_data", ['currency']) }} AS "currency",
    {{ json_extract_scalar ("_airbyte_data", ['interval']) }} AS "interval",
    cast({{ json_extract_scalar ("_airbyte_data", ['interval_count']) }} AS integer) AS "interval_count",
    {{ json_extract_scalar ("_airbyte_data", ['metadata']) }} AS "metadata",
    {{ json_extract_scalar ("_airbyte_data", ['nickname']) }} AS "nickname",
    {{ json_extract_scalar ("_airbyte_data", ['product']) }} AS "product",
    cast({{ json_extract_scalar ("_airbyte_data", ['livemode']) }} AS boolean) AS "livemode",
    _airbyte_emitted_at
FROM {{ var('airbyte_raw_plans') }}
), 
_tmp_dedup_pk AS (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY "id" ORDER BY "_airbyte_emitted_at" DESC) AS _tmp_pk_row_number
    FROM _tmp_unpack_json
)
SELECT
    "id",
    "active",
    "amount",
    "currency",
    "interval",
    "interval_count",
    "metadata",
    "nickname",
    "product",
    "livemode"
FROM _tmp_dedup_pk
WHERE _tmp_pk_row_number = 1