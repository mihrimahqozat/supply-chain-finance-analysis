-- Working capital metrics by market and department
WITH working_capital AS (
    SELECT
        market,
        department_name,
        order_year,
        order_quarter,
        COUNT(DISTINCT order_id)                    AS total_orders,
        ROUND(SUM(sales)::NUMERIC, 2)               AS total_sales,
        ROUND(SUM(order_profit_per_order)
              ::NUMERIC, 2)                         AS total_profit,
        ROUND(AVG(days_for_shipping_real)
              ::NUMERIC, 2)                         AS avg_shipping_days,
        ROUND(AVG(days_for_shipment_scheduled)
              ::NUMERIC, 2)                         AS avg_scheduled_days,
        ROUND(AVG(order_item_discount_rate)
              ::NUMERIC, 4)                         AS avg_discount_rate,
        SUM(CASE WHEN late_delivery_risk = 1
            THEN 1 ELSE 0 END)                      AS late_orders,
        ROUND(AVG(order_item_quantity)
              ::NUMERIC, 2)                         AS avg_order_quantity
    FROM orders
    GROUP BY 
		market,
		department_name,
		order_year, 
		order_quarter
)
SELECT *,
    ROUND(total_profit * 100.0 /
        NULLIF(total_sales, 0)::NUMERIC, 2)         AS profit_margin_pct,
    ROUND(late_orders * 100.0 /
        NULLIF(total_orders, 0)::NUMERIC, 2)        AS late_rate_pct,
    RANK() OVER (
        PARTITION BY order_year, order_quarter
        ORDER BY total_profit DESC)                 AS quarterly_profit_rank
FROM working_capital
ORDER BY 
	order_year, 
	order_quarter, 
	quarterly_profit_rank;