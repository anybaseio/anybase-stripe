WITH _tmp_unpack_json AS (
SELECT
    to_timestamp(cast({{ json_extract_scalar ("_airbyte_data", ['created']) }} AS numeric)) AS "created",
    {{ json_extract_scalar ("_airbyte_data", ['id']) }} AS "id",
    cast({{ json_extract_scalar ("_airbyte_data", ['amount']) }} AS integer) AS "amount",
    cast({{ json_extract_scalar ("_airbyte_data", ['arrival_date']) }} AS integer) AS "arrival_date",
    cast({{ json_extract_scalar ("_airbyte_data", ['automatic']) }} AS boolean) AS "automatic",
    {{ json_extract_scalar ("_airbyte_data", ['balance_transaction']) }} AS "balance_transaction_id",
    {{ json_extract_scalar ("_airbyte_data", ['currency']) }} AS "currency",
    {{ json_extract_scalar ("_airbyte_data", ['description']) }} AS "description",
    {{ json_extract_scalar ("_airbyte_data", ['metadata']) }} AS "metadata",
    {{ json_extract_scalar ("_airbyte_data", ['method']) }} AS "method",
    {{ json_extract_scalar ("_airbyte_data", ['source_type']) }} AS "source_type",
    {{ json_extract_scalar ("_airbyte_data", ['status']) }} AS "status",
    {{ json_extract_scalar ("_airbyte_data", ['type']) }} AS "type",
    cast({{ json_extract_scalar ("_airbyte_data", ['livemode']) }} AS boolean) AS "livemode",
    _airbyte_emitted_at
FROM {{ var('airbyte_raw_payouts') }}
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
    "arrival_date",
    "automatic",
    "balance_transaction_id",
    "currency",
    "description",
    "metadata",
    "method",
    "source_type",
    "status",
    "type",
    "livemode"
FROM _tmp_dedup_pk
WHERE _tmp_pk_row_number = 1