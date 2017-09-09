view: user_order_facts {
  derived_table: {
    sql:
      SELECT
        user_id,
        COUNT(*) AS "lifetime_orders",
        SUM(order_items.sale_price) AS "lifetime_sales",
        MIN(order_items.created_at) as "first_order_date",
        MAX(order_items.created_at) as "recent_order_date"
      FROM public.order_items  AS order_items
      GROUP BY user_id ;;
    distribution: "user_id"
    sql_trigger_value: SELECT max(created_at) FROM public.order_items ;;
    sortkeys: ["first_order_date"]
}

  dimension: user_id {
    primary_key: yes
    type: number
    sql: ${TABLE}.user_id ;;
    hidden: yes
  }

  dimension: lifetime_orders {
    type: number
    sql: ${TABLE}.lifetime_orders ;;
  }

  dimension: lifetime_sales {
    type: number
    sql: ${TABLE}.lifetime_sales ;;
  }

  dimension: recent_order_date {
    type: number
    sql: ${TABLE}.recent_order_date ;;
  }

  dimension: is_active {
    type: yesno
    sql: datediff('days', ${recent_order_date}, current_date)<=30 ;;
  }

  measure: is_active_count {
    type: count_distinct
    sql: ${user_id} ;;

    filters: {
      field: is_active
      value: "Yes"
    }
  }

  measure: is_active_percent {
    type: number
    sql: 1.0*${is_active_count}/NULLIF(${users.count}, 0)  ;;
    value_format_name: percent_2
  }

  dimension_group: first_order_date {
    type: time
    timeframes: [
      raw,
      time,
      date,
      week,
      month,
      quarter,
      year
    ]
    sql: ${TABLE}.first_order_date ;;
  }

  measure: average_lifetime_sales {
    type: average
    sql: round(${lifetime_sales}, 2) ;;
  }

  measure: average_lifetime_orders {
    type: average
    sql: ${lifetime_orders} ;;
  }

}
