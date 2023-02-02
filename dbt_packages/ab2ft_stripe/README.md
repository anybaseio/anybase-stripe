# Fivetran dbt model adapter for the Airbyte Stripe source

This is a dbt package that lets you use the raw JSON data output by
[Airbyte's Stripe source](https://docs.airbyte.com/integrations/sources/stripe)
with the [fivetran/dbt_stripe](https://github.com/fivetran/dbt_stripe) dbt model
created by Fivetran for their Stripe connector.

## How it works

By default, the data flow with Fivetran's Stripe connector is:

* Fivetran outputs raw data in a certain schema (
  see [the Fivetran documentation](https://fivetran.com/docs/applications/stripe)
  and [the entity-relationship diagram](https://docs.google.com/presentation/d/1zyxgbaOjgBt3NsY0OfsiGsWDIefcBc-R1lHWlMltCYU/))
* [fivetran/dbt_stripe_source](https://github.com/fivetran/dbt_stripe_source)
  builds ephemeral staging models
* [fivetran/dbt_stripe](https://github.com/fivetran/dbt_stripe) builds final
  models with transactions, invoices, daily/weekly/monthly overviews etc.

This package contains models that unpack Airbyte's raw JSON data and transform
it into the format that `dbt_stripe_source` expects. It then passes those models
as sources to `dbt_stripe_source`.

## Note on autogeneration

Note that this was automatically generated from:

* [JSONSchema output by Airbyte's Stripe source](https://github.com/airbytehq/airbyte/tree/master/airbyte-integrations/connectors/source-stripe/source_stripe/schemas)
* [schema required by Fivetran's Stripe source](https://github.com/fivetran/dbt_stripe_source/blob/main/models/src_stripe.yml)

Some manual matching has been done but some columns expected by Fivetran's
package don't exist in Airbyte's output schema. For a full list, see the
[stripe.yml](./stripe.yml) file: columns without a `source_name` attribute are
unmapped.

In particular, the `payment_method` stream isn't replicated by Airbyte, so the
corresponding feature has been disabled in `dbt_project.yml`:

```yaml
vars:
  ...
  # The payment_method stream doesn't seem to be replicated by Airbyte, so set this to False.
  using_payment_method: False
```

## Available models

With `using_payment_method` disabled, all other Fivetran models build and tests
pass. See
[the original repository](https://github.com/fivetran/dbt_stripe) for more
information.

* `stripe__balance_transactions`:  Each record represents a change to your
  account balance, enriched with data about the transaction.
* `stripe__invoice_line_items`: Each record represents an invoice line item,
  enriched with details about the associated charge, customer, subscription, and
  plan.
* `stripe__subscription_details`: Each record represents a subscription,
  enriched with customer details and payment aggregations.
* `stripe__subscription_line_items`: Each record represents a subscription
  invoice line item, enriched with details about the associated charge,
  customer, subscription, and plan. Use this table as the starting point for
  your company-specific churn and MRR calculations.
* `stripe__customer_overview`: Each record represents a customer, enriched with
  metrics about their associated transactions.
* `stripe__daily_overview`: Each record represents a single day, enriched with
  metrics about balances, payments, refunds, payouts, and other transactions.
* `stripe__weekly_overview`: Each record represents a single week, enriched with
  metrics about balances, payments, refunds, payouts, and other transactions.
* `stripe__monthly_overview`: Each record represents a single month, enriched
  with metrics about balances, payments, refunds, payouts, and other
  transactions.
* `stripe__quarterly_overview`: Each record represents a single quarter,
  enriched with metrics about balances, payments, refunds, payouts, and other
  transactions.

## Usage in other dbt projects

### Installation

Check [dbt Hub](https://hub.getdbt.com/) for the latest installation
instructions,
or [read the dbt docs](https://docs.getdbt.com/docs/package-management) for more
information on installing packages.

Add this to your `packages.yml`:

```yaml
packages:
  - git: "https://github.com/splitgraph/ab2ft_stripe.git"
    revision: 0.1.0
```

### Configuration

By default, this package will look for raw Airbyte data in the 
`airbyte-raw/stripe` schema of your target database. You can override it as 
follows:

```yaml
# dbt_project.yml

...
config-version: 2

vars:
  ab2ft_stripe:
    stripe_database: your_database_name
    stripe_schema: your_schema_name
```

You can also override the names of the raw Airbyte tables with the streams 
as follows:

```yaml
# dbt_project.yml

...
config-version: 2

vars:
  ab2ft_stripe:
    airbyte_raw_subscriptions: '{{ ref(''some_other_model'') }}'
```

See [the original Fivetran repository](https://github.com/fivetran/dbt_stripe)
for the configuration of the downstream Fivetran model.

### Database support

This package has been tested on PostgreSQL.

## Usage on [Splitgraph Cloud](https://www.splitgraph.com)

Write a
[`splitgraph.yml`](https://www.splitgraph.com/docs/splitgraph-cloud/splitgraph-yml)
file with the required Stripe credentials (or add it to your existing file):

**`splitgraph.credentials.yml`**:

```yaml
credentials:
  dbt:
    plugin: dbt
    # Point the dbt plugin to this repository
    data:
      git_url: https://github.com/splitgraph/ab2ft_stripe.git
  airbyte-stripe:
    plugin: airbyte-stripe
    data:
      client_secret: "rk_live_XXXXXX"
```

**`splitgraph.yml`**:

```yaml
repositories:
  # Raw Airbyte data (JSON streams) goes here
  - namespace: MY_SPLITGRAPH_USERNAME
    repository: airbyte-raw-stripe
    external:
      plugin: airbyte-stripe
      credential: airbyte-stripe
      is_live: false
      params:
        account_id: acct_XXXXXXX
        start_date: "2020-01-01T00:00:00Z"
        # Disable Airbyte's default normalization
        normalization_mode: none
      # Load all tables from the Stripe data source
      tables: [ ]
    metadata:
      topics:
        - analytics
        - raw
        - airbyte
        - stripe
      description: Raw Stripe data

  # Transformed Airbyte data (Fivetran's Stripe models) goes here
  - namespace: MY_SPLITGRAPH_USERNAME
    repository: stripe
    external:
      plugin: dbt
      credential: dbt
      is_live: false
      params:
        sources:
          - dbt_source_name: airbyte_raw_stripe
            namespace: MY_SPLITGRAPH_USERNAME
            repository: airbyte-raw-stripe
      # Build all models in the dbt data source
      tables: [ ]
    metadata:
      topics:
        - analytics
        - transformed
        - stripe
      description: Transformed Stripe data
```

Log in to Splitgraph:

```bash
sgr cloud login --username MY_SPLITGRAPH_USERNAME
```

Run the ingestion (making sure the data is private by default):

```bash
sgr cloud sync --initial-private \
  -u -f splitgraph.yml -f splitgraph.credentials.yml --wait \
  MY_SPLITGRAPH_USERNAME/airbyte-raw-stripe && \
sgr cloud sync --initial-private \
  -u -f splitgraph.yml -f splitgraph.credentials.yml --wait \
  MY_SPLITGRAPH_USERNAME/stripe
```

Update the metadata/descriptions:

```bash
sgr cloud load --skip-external
```

The results will be available at
[https://www.splitgraph.com/MY_SPLITGRAPH_USERNAME/stripe](https://www.splitgraph.com/MY_SPLITGRAPH_USERNAME/stripe).

For advanced configuration, including getting Splitgraph Cloud to run this for
you on a schedule, see the
[documentation for `splitgraph.yml`](https://www.splitgraph.com/docs/splitgraph-cloud/splitgraph-yml).
