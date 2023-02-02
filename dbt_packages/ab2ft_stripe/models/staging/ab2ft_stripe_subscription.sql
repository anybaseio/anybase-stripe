WITH _tmp_unpack_json AS (
SELECT
    to_timestamp(cast({{ json_extract_scalar ("_airbyte_data", ['created']) }} AS numeric)) AS "created",
    {{ json_extract_scalar ("_airbyte_data", ['id']) }} AS "id",
    {{ json_extract_scalar ("_airbyte_data", ['status']) }} AS "status",
    {{ json_extract_scalar ("_airbyte_data", ['billing']) }} AS "billing",
    cast({{ json_extract_scalar ("_airbyte_data", ['billing_cycle_anchor']) }} AS numeric) AS "billing_cycle_anchor",
    NULL AS "cancel_at",
    cast({{ json_extract_scalar ("_airbyte_data", ['cancel_at_period_end']) }} AS boolean) AS "cancel_at_period_end",
    cast({{ json_extract_scalar ("_airbyte_data", ['canceled_at']) }} AS numeric) AS "canceled_at",
    cast({{ json_extract_scalar ("_airbyte_data", ['current_period_start']) }} AS integer) AS "current_period_start",
    cast({{ json_extract_scalar ("_airbyte_data", ['current_period_end']) }} AS numeric) AS "current_period_end",
    {{ json_extract_scalar ("_airbyte_data", ['customer']) }} AS "customer_id",
    cast({{ json_extract_scalar ("_airbyte_data", ['days_until_due']) }} AS integer) AS "days_until_due",
    {{ json_extract_scalar ("_airbyte_data", ['metadata']) }} AS "metadata",
    NULL AS "start_date",
    cast({{ json_extract_scalar ("_airbyte_data", ['ended_at']) }} AS numeric) AS "ended_at",
    cast({{ json_extract_scalar ("_airbyte_data", ['livemode']) }} AS boolean) AS "livemode",
    _airbyte_emitted_at
FROM {{ var('airbyte_raw_subscriptions') }}
), 
_tmp_dedup_pk AS (
    SELECT *,
    ROW_NUMBER() OVER (PARTITION BY "id" ORDER BY "_airbyte_emitted_at" DESC) AS _tmp_pk_row_number
    FROM _tmp_unpack_json
)
SELECT
    "created",
    "id",
    "status",
    "billing",
    "billing_cycle_anchor",
    "cancel_at",
    "cancel_at_period_end",
    "canceled_at",
    "current_period_start",
    "current_period_end",
    "customer_id",
    "days_until_due",
    "metadata",
    "start_date",
    "ended_at",
    "livemode"
FROM _tmp_dedup_pk
WHERE _tmp_pk_row_number = 1