view: repeat_purchase_facts {
  derived_table: {
    sql: select
            order_items.order_id
            , MIN(repeat_order_items.order_id) as next_order_id
            , MIN(repeat_order_items.created_at) as next_order_date
            , datediff('days', order_items.created_at, repeat_order_items.created_at) as days_until_next_order
        from order_items
        left join order_items as repeat_order_items
            on repeat_order_items.user_id=order_items.user_id
            and repeat_order_items.created_at>order_items.created_at
        group by order_items.order_id;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
    hidden: yes
  }

  dimension: next_order_id {
    type: number
    sql: ${TABLE}.next_order_id ;;
  }

  dimension_group: next_order_date {
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
    sql: ${TABLE}.next_order_date ;;
  }

  dimension: days_until_next_order {
    type: number
    sql: ${TABLE}.days_until_next_order ;;
    description: "Number of days after this order that the same user makes the next order"
  }
}
