view: user_order_facts {
  derived_table: {
    sql:
      SELECT
        user_id as "id",
        COUNT(*) AS "order_items_count",
        SUM(order_items.sale_price) AS "lifetime_sales",
        MIN(order_items.created_at) as "first_order_date"
      FROM public.order_items  AS order_items
      GROUP BY user_id ;;
    distribution: "id"
    sql_trigger_value: SELECT max(created_at) FROM public.order_items ;;
    sortkeys: ["first_order_date"]
}

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
  }

  dimension: order_items_count {
    type: number
    sql: ${TABLE}.order_items_count ;;
  }

  dimension: lifetime_sales {
    type: number
    sql: ${TABLE}.lifetime_sales ;;
  }

  dimension: first_order_date {
    type: number
    sql: ${TABLE}.first_order_date ;;
  }

  measure: average_lifetime_sales {
    type: average
    sql: round(${TABLE}.lifetime_sales, 2) ;;
  }

}
