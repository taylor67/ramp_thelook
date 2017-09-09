view: sessions {
  derived_table: {
    sql:
    select
      session_id
      , max(ip_address) as ip_address
      , min(created_at) as start_time
      , max(created_at) as end_time
      , count(*) as events_in_session
      , max(user_id) as user_id
      , sum(CASE WHEN event_type in ('Category', 'Brand') THEN 1 else 0 END) as browse_events
      , sum(CASE WHEN event_type='Product' THEN 1 else 0 END) as product_events
      , sum(CASE WHEN event_type='Cart' THEN 1 else 0 END) as cart_events
      , sum(CASE WHEN event_type='Purchase' THEN 1 else 0 END) as purchase_events
    from events
    group by session_id ;;
  }

  dimension: session_id {
    type: string
    sql: ${TABLE}.session_id ;;
    primary_key: yes
    hidden: yes
  }

  dimension: ip_address {
    type: string
    sql: ${TABLE}.ip_address ;;
    hidden: yes
  }

  dimension_group: start_time {
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
    sql: ${TABLE}.start_time ;;
  }

  dimension_group: end_time {
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
    sql: ${TABLE}.end_time ;;
  }

  dimension: duration {
    label: "Duration (sec)"
    type: number
    sql: datediff('seconds', ${start_time_raw}, ${end_time_raw}) ;;
  }

  dimension: duration_seconds_tier {
    type: tier
    tiers: [0, 60, 120, 180, 320]
    sql:  ;;
  }

  measure: average_duration {
    type: average
    sql: ${duration} ;;
  }

  dimension: events_in_session {
    type: number
    sql: ${TABLE}.events_in_session ;;
  }

  dimension: user_id {
    type: number
    sql:  ${TABLE}.user_id ;;
    hidden: yes
  }

  dimension: number_of_browse_events_in_session {
    type: number
    sql: ${TABLE}.browse_events ;;
  }

  dimension: number_of_product_events_in_session {
    type: number
    sql: ${TABLE}.product_events ;;
  }

  dimension: number_of_cart_events_in_session {
    type: number
    sql: ${TABLE}.cart_events ;;
  }

  dimension: has_cart_event {
    type: yesno
    sql: ${number_of_cart_events_in_session}>0 ;;
  }

  dimension: number_of_purchase_events_in_session {
    type: number
    sql: ${TABLE}.purchase_events ;;
  }

  dimension: has_purchase_event {
    type: yesno
    sql: ${number_of_purchase_events_in_session}>0 ;;
  }

  dimension: furthest_funnel_step {
    sql: CASE
      WHEN ${number_of_purchase_events_in_session} > 0 THEN '(5) Purchase'
      WHEN ${number_of_cart_events_in_session} > 0 THEN '(4) Add to Cart'
      WHEN ${number_of_product_events_in_session} > 0 THEN '(3) View Product'
      WHEN ${number_of_browse_events_in_session} > 0 THEN '(2) Browse'
      ELSE '(1) Land'
      END
       ;;
  }

  measure: count_purchase {
    type: count

    filters: {
      field: has_purchase_event
      value: "Yes"
    }
  }

  measure: count_cart {
    type: count

    filters: {
      field: has_cart_event
      value: "Yes"
    }
  }

  measure: overall_conversion {
    type: number
    sql: 1.0 * ${count_purchase}/nullif(${count}, 0) ;;
    value_format_name: percent_2
  }

  measure: cart_to_checkout_conversion {
    type: number
    sql: 1.0 * ${count_purchase}/nullif(${count_cart}, 0) ;;
    value_format_name: percent_2
  }
  measure: unique_visitors {
    type: count_distinct
    sql: ${ip_address} ;;
    description: "Uniqueness determined by IP address"
  }

  measure: count {
    type: count
    description: "Count of sessions"
  }
}
