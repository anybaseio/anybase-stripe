WITH _tmp_unpack_json AS (
SELECT
    {{ json_extract_scalar ("_airbyte_data", ['id']) }} AS "id",
    {{ json_extract_scalar ("_airbyte_data", ['brand']) }} AS "brand",
    {{ json_extract_scalar ("_airbyte_data", ['country']) }} AS "country",
    NULL AS "created",
    {{ json_extract_scalar ("_airbyte_data", ['customer']) }} AS "customer_id",
    {{ json_extract_scalar ("_airbyte_data", ['name']) }} AS "name",
    NULL AS "recipient",
    {{ json_extract_scalar ("_airbyte_data", ['funding']) }} AS "funding",
    _airbyte_emitted_at
FROM {{ var('airbyte_raw_charges') }}
), 
_tmp_dedup_pk AS (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY "id" ORDER BY "_airbyte_emitted_at" DESC) AS _tmp_pk_row_number
    FROM _tmp_unpack_json
)
SELECT
    "id",
    "brand",
    "country",
    "created",
    "customer_id",
    "name",
    "recipient",
    "funding"
FROM _tmp_dedup_pk
WHERE _tmp_pk_row_number = 1