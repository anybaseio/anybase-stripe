{{ dbt_utils.date_spine(
    datepart="month",
    start_date="cast('2018-01-01' as date)",
    end_date="date_trunc('month', now())"
   )
}}