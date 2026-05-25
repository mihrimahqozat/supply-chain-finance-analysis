-- Monthly cash flow proxy and shipping efficiency
WITH monthly_cashflow AS (
    SELECT
        order_year,
        order_month,
        order_quarter,
        shipping_mode,
        COUNT(DISTINCT order_id)                    AS total_orders,
        ROUND(SUM(sales)::NUMERIC, 2)               AS total_sales,
        ROUND(SUM(order_profit_per_order)
              ::NUMERIC, 2)                         AS total_profit,
        ROUND(AVG(days_for_shipping_real)
              ::NUMERIC, 2)                         AS avg_actual_days,
        ROUND(AVG(days_for_shipment_scheduled)
              ::NUMERIC, 2)                         AS avg_scheduled_days,
        ROUND(AVG(shipping_delay)::NUMERIC, 2)      AS avg_shipping_delay,
        SUM(CASE WHEN is_late = 1
            THEN 1 ELSE 0 END)                      AS late_orders,
        ROUND(SUM(order_item_discount)
              ::NUMERIC, 2)                         AS total_discounts_given
    FROM orders
    GROUP BY 
		order_year, 
		order_month, 
		order_quarter, 
		shipping_mode
),
cashflow_growth AS (
    SELECT *,
        LAG(total_sales) OVER (
            PARTITION BY shipping_mode
            ORDER BY order_year, order_month)       AS prev_month_sales,
        ROUND((total_sales -
            LAG(total_sales) OVER (
                PARTITION BY shipping_mode
                ORDER BY order_year, order_month)) * 100.0
            / NULLIF(LAG(total_sales) OVER (
                PARTITION BY shipping_mode
                ORDER BY order_year, order_month), 0)
            ::NUMERIC, 2)                           AS mom_sales_growth
    FROM monthly_cashflow
)
SELECT *,
    ROUND(late_orders * 100.0 /
        NULLIF(total_orders, 0)::NUMERIC, 2)        AS late_rate_pct
FROM cashflow_growth
ORDER BY 
	order_year, 
	order_month, 
	shipping_mode;