view: order_items {
  sql_table_name: public.order_items ;;

  dimension: id {
    primary_key: yes
    type: number
    sql: ${TABLE}.id ;;
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
  }

  dimension_group: delivered {
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
    sql: ${TABLE}.delivered_at ;;
  }

  dimension: inventory_item_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.inventory_item_id ;;
  }

  dimension: order_id {
    type: number
    sql: ${TABLE}.order_id ;;
  }

  dimension_group: returned {
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
    sql: ${TABLE}.returned_at ;;
  }

  dimension: sale_price {
    type: number
    sql: ${TABLE}.sale_price ;;
  }

  dimension: gross_margin {
    type: number
    value_format_name: usd
    sql: ${order_items.sale_price}-${inventory_items.cost} ;;
  }

  dimension: item_gross_margin_percentage {
    type: number
    value_format_name: percent_2
    sql: (${order_items.sale_price}-${inventory_items.cost})/  ;;
  }

  dimension_group: shipped {
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
    sql: ${TABLE}.shipped_at ;;
  }

  dimension: status {
    type: string
    sql: ${TABLE}.status ;;
  }

  dimension: user_id {
    type: number
    # hidden: yes
    sql: ${TABLE}.user_id ;;
  }

  measure: sum {
    type: sum
    sql: ${sale_price} ;;
    value_format_name: usd
    drill_fields: [detail*]
  }

  measure: count {
    type: count
    drill_fields: [detail*]
  }

  ##########  Repeat order facts  ##########

  dimension: has_subsequent_order {
    type: yesno
    view_label: "Repeat Purchase Facts"
    sql: ${repeat_purchase_facts.days_until_next_order} <0 ;;
  }

  dimension: has_subsequent_order_within_30d {
    type: yesno
    view_label: "Repeat Purchase Facts"
    sql: ${repeat_purchase_facts.days_until_next_order} <=30 ;;
  }

  measure: count_has_subsequent_order_within_30d {
    type: count_distinct
    view_label: "Repeat Purchase Facts"
    sql: ${order_items.order_id} ;;

    filters: {
      field: has_subsequent_order_within_30d
      value: "Yes"
    }
  }

  measure: 30d_repeat_purchase_rate {
    description: "The percentage of customers who purchase again within 30 days"
    view_label: "Repeat Purchase Facts"
    type: number
    value_format_name:  percent_1
    sql: 1* ${count_has_subsequent_order_within_30d}/${count} ;;
  }

  # ----- Sets of fields for drilling ------
  set: detail {
    fields: [
      id,
      users.id,
      users.first_name,
      users.last_name,
      inventory_items.id,
      inventory_items.product_name
    ]
  }
}
