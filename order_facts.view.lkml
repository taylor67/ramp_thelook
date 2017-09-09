view: order_facts {
  derived_table: {
    sql: select user_id
                , order_id
                , count(*) as number_of_items
                , min(created_at) as created_at
                , sum(sale_price) as order_amount
                , rank() over (PARTITION BY user_id ORDER BY created_at) as rank_order_number
          from order_items
          group by order_id, user_id, created_at ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
    primary_key: yes
    hidden: yes
  }

  dimension: number_of_items {
    type: number
    sql: ${TABLE}.number_of_items ;;
  }

  dimension: rank_order_number {
    type: number
    sql: ${TABLE}.rank_order_number ;;
    hidden: yes
  }

  dimension: is_first_order {
    type: yesno
    sql: ${rank_order_number}=1 ;;
  }

  dimension_group: created_at {
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
    sql: ${TABLE}.created_at ;;
    hidden:  yes
  }

  dimension: order_amount {
    type: number
    sql: ${TABLE}.order_amount ;;
  }

  measure: average_order_amount {
    type: average
    sql: ${order_amount} ;;
    value_format_name: usd
  }

  measure: first_order_count {
    type: count_distinct
    sql: ${order_id} ;;

    filters: {
      field: is_first_order
      value: "Yes"
    }
  }

  measure: count_orders {
    type: count_distinct
    sql:  ${TABLE}.order_id;;
  }

}
