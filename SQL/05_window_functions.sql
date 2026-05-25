-- Profitability ranking by category and market with running totals and percentiles
WITH category_profit AS (
    SELECT
        category_name,
        department_name,
        market,
        COUNT(DISTINCT order_id)                    AS total_orders,
        ROUND(SUM(sales)::NUMERIC, 2)               AS total_sales,
        ROUND(SUM(order_profit_per_order)
              ::NUMERIC, 2)                         AS total_profit,
        ROUND(AVG(order_item_profit_ratio)
              ::NUMERIC, 4)                         AS avg_profit_ratio,
        ROUND(AVG(order_item_discount_rate)
              ::NUMERIC, 4)                         AS avg_discount_rate,
        SUM(CASE WHEN late_delivery_risk = 1
            THEN 1 ELSE 0 END)                      AS late_orders
    FROM orders
    GROUP BY 
		category_name, 
		department_name, 
		market
),
ranked AS (
    SELECT *,
        ROUND(total_profit * 100.0 /
            NULLIF(total_sales, 0)::NUMERIC, 2)     AS profit_margin_pct,
        RANK() OVER (
            ORDER BY total_profit DESC)             AS global_profit_rank,
        RANK() OVER (
            PARTITION BY market
            ORDER BY total_profit DESC)             AS market_profit_rank,
        NTILE(4) OVER (
            ORDER BY total_profit DESC)             AS profit_quartile,
        ROUND(SUM(total_profit) OVER (
            ORDER BY total_profit DESC
            ROWS BETWEEN UNBOUNDED PRECEDING
            AND CURRENT ROW)::NUMERIC, 2)           AS cumulative_profit,
        ROUND(late_orders * 100.0 /
            NULLIF(total_orders, 0)::NUMERIC, 2)    AS late_rate_pct
    FROM category_profit
)
SELECT *
FROM ranked
ORDER BY global_profit_rank;