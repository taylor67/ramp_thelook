connection: "thelook_events"

# include all the views
include: "*.view"

# include all the dashboards
include: "*.dashboard"

explore: distribution_centers {
  join: products {
    type: left_outer
    sql_on: ${distribution_centers.id}=${products.distribution_center_id} ;;
    relationship: one_to_many
    fields: [products.count]
  }
}

explore: events {
  join: users {
    type: left_outer
    sql_on: ${events.user_id} = ${users.id} ;;
    relationship: many_to_one
  }
  always_filter: {
    filters: {
      field: traffic_source
      value: "Display"
    }
  }
}

explore: inventory_items {
  join: products {
    type: left_outer
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}

explore: order_items {
  # The following 2 lines make the extension explore work (returned_order_items).
  view_name: order_items
  from: order_items
  label: "Orders, Backlog, and Users"
  join: users {
    type: left_outer
    sql_on: ${order_items.user_id} = ${users.id} ;;
    relationship: many_to_one
  }

  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: one_to_one
  }

  join: products {
    type: inner
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }

  join: order_facts {
    type: left_outer
    sql_on: ${order_items.order_id}=${order_facts.order_id} ;;
    relationship: many_to_one
  }

  join: repeat_purchase_facts {
    type: left_outer
    sql_on: ${order_items.order_id}= ${repeat_purchase_facts.order_id} ;;
    relationship: many_to_one
  }

}
explore: returned_order_items {
  view_label: "Returned Order Items"
  extends: [order_items]
  label: "Returned Orders, Backlog, and Users"
  sql_always_where: ${status}='Returned' ;;
}

explore: products {
  join: distribution_centers {
    type: left_outer
    sql_on: ${products.distribution_center_id} = ${distribution_centers.id} ;;
    relationship: many_to_one
  }
}

explore: users {}

# explore: inactive_users {
#   from: users
#   join: order_items {
#     type: left_outer
#     sql_on: ${inactive_users.id} = ${order_items.user_id} ;;
#     relationship: one_to_many
#   }
#   sql_always_where: ${order_items.order_id} IS NULL ;;
# }

explore: user_order_facts {
  join: users {
    type: inner
    sql_on: ${users.id}=${user_order_facts.id} ;;
    relationship: one_to_one
  }

  join: order_items {
    type: left_outer
    sql_on: ${order_items.user_id}=${users.id} ;;
    relationship: one_to_many
  }

  join: inventory_items {
    type: left_outer
    sql_on: ${order_items.inventory_item_id} = ${inventory_items.id} ;;
    relationship: one_to_one
    fields: []
  }

  join: products {
    type: inner
    sql_on: ${inventory_items.product_id} = ${products.id} ;;
    relationship: many_to_one
  }

  join: repeat_purchase_facts {
    type: left_outer
    sql_on: ${order_items.order_id}= ${repeat_purchase_facts.order_id} ;;
    relationship: many_to_one
  }
}
