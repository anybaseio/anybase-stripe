WITH _tmp_unpack_json AS (
SELECT
    cast(False AS boolean) AS "is_deleted",
    to_timestamp(cast({{ json_extract_scalar ("_airbyte_data", ['created']) }} AS numeric)) AS "created",
    {{ json_extract_scalar ("_airbyte_data", ['id']) }} AS "id",
    cast({{ json_extract_scalar ("_airbyte_data", ['account_balance']) }} AS integer) AS "account_balance",
    {{ json_extract_scalar ("_airbyte_data", ['currency']) }} AS "currency",
    {{ json_extract_scalar ("_airbyte_data", ['default_card']) }} AS "default_card_id",
    cast({{ json_extract_scalar ("_airbyte_data", ['delinquent']) }} AS boolean) AS "delinquent",
    {{ json_extract_scalar ("_airbyte_data", ['description']) }} AS "description",
    {{ json_extract_scalar ("_airbyte_data", ['email']) }} AS "email",
    {{ json_extract_scalar ("_airbyte_data", ['metadata']) }} AS "metadata",
    NULL AS "shipping_address_city",
    NULL AS "shipping_address_country",
    NULL AS "shipping_address_line_1",
    NULL AS "shipping_address_line_2",
    NULL AS "shipping_address_postal_code",
    NULL AS "shipping_address_state",
    NULL AS "shipping_name",
    NULL AS "shipping_phone",
    cast({{ json_extract_scalar ("_airbyte_data", ['livemode']) }} AS boolean) AS "livemode",
    _airbyte_emitted_at
FROM {{ var('airbyte_raw_customers') }}
), 
_tmp_dedup_pk AS (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY "id" ORDER BY "_airbyte_emitted_at" DESC) AS _tmp_pk_row_number
    FROM _tmp_unpack_json
)
SELECT
    "is_deleted",
    "created",
    "id",
    "account_balance",
    "currency",
    "default_card_id",
    "delinquent",
    "description",
    "email",
    "metadata",
    "shipping_address_city",
    "shipping_address_country",
    "shipping_address_line_1",
    "shipping_address_line_2",
    "shipping_address_postal_code",
    "shipping_address_state",
    "shipping_name",
    "shipping_phone",
    "livemode"
FROM _tmp_dedup_pk
WHERE _tmp_pk_row_number = 1