WITH _tmp_unpack_json AS (
SELECT
    to_timestamp(cast({{ json_extract_scalar ("_airbyte_data", ['created']) }} AS numeric)) AS "created",
    to_timestamp(cast({{ json_extract_scalar ("_airbyte_data", ['available_on']) }} AS numeric)) AS "available_on",
    {{ json_extract_scalar ("_airbyte_data", ['id']) }} AS "id",
    cast({{ json_extract_scalar ("_airbyte_data", ['amount']) }} AS integer) AS "amount",
    {{ json_extract_scalar ("_airbyte_data", ['currency']) }} AS "currency",
    {{ json_extract_scalar ("_airbyte_data", ['description']) }} AS "description",
    cast({{ json_extract_scalar ("_airbyte_data", ['exchange_rate']) }} AS numeric) AS "exchange_rate",
    cast({{ json_extract_scalar ("_airbyte_data", ['fee']) }} AS integer) AS "fee",
    cast({{ json_extract_scalar ("_airbyte_data", ['net']) }} AS integer) AS "net",
    {{ json_extract_scalar ("_airbyte_data", ['source']) }} AS "source",
    {{ json_extract_scalar ("_airbyte_data", ['status']) }} AS "status",
    {{ json_extract_scalar ("_airbyte_data", ['type']) }} AS "type",
    _airbyte_emitted_at
FROM {{ var('airbyte_raw_balance_transactions') }}
), 
_tmp_dedup_pk AS (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY "id" ORDER BY "_airbyte_emitted_at" DESC) AS _tmp_pk_row_number
    FROM _tmp_unpack_json
)
SELECT
    "created",
    "available_on",
    "id",
    "amount",
    "currency",
    "description",
    "exchange_rate",
    "fee",
    "net",
    "source",
    "status",
    "type"
FROM _tmp_dedup_pk
WHERE _tmp_pk_row_number = 1