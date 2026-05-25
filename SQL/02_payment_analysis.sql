-- Payment type analysis with profitability
WITH payment_stats AS (
    SELECT
        payment_type,
        customer_segment,
        COUNT(DISTINCT order_id)                    AS total_orders,
        ROUND(SUM(sales)::NUMERIC, 2)               AS total_sales,
        ROUND(AVG(sales)::NUMERIC, 2)               AS avg_order_value,
        ROUND(SUM(order_profit_per_order)
              ::NUMERIC, 2)                         AS total_profit,
        ROUND(AVG(order_item_profit_ratio)
              ::NUMERIC, 4)                         AS avg_profit_ratio,
        ROUND(AVG(order_item_discount_rate)
              ::NUMERIC, 4)                         AS avg_discount_rate,
        COUNT(CASE WHEN late_delivery_risk = 1
              THEN 1 END)                           AS late_delivery_count
    FROM orders
    WHERE payment_type IS NOT NULL
    GROUP BY 
		payment_type, 
		customer_segment
)
SELECT *,
    ROUND(total_profit * 100.0 /
        NULLIF(total_sales, 0)::NUMERIC, 2)         AS profit_margin_pct,
    ROUND(late_delivery_count * 100.0 /
        NULLIF(total_orders, 0)::NUMERIC, 2)        AS late_delivery_rate_pct,
    RANK() OVER (ORDER BY total_profit DESC)        AS profit_rank
FROM payment_stats
ORDER BY profit_rank;