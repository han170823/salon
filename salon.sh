#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~\n"
echo -e "Welcome to My Salon, how can I help you?\n"

main_menu() {
  services_list=$($PSQL "SELECT service_id, name FROM services ORDER BY service_id")
  echo "$services_list" | while read service_id bar service_name
  do
    echo "$service_id) $service_name"
  done

  read selected_service_id
  selected_service_name=$($PSQL "SELECT name FROM services WHERE service_id=$selected_service_id")

  if [[ -z $selected_service_name ]]
  then
    echo -e "\nI could not find that service. What would you like today?"
    main_menu
  else
    echo -e "\nWhat's your phone number?"
    read customer_phone

    customer_name=$($PSQL "SELECT name FROM customers WHERE phone='$customer_phone'")

    if [[ -z $customer_name ]]
    then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read customer_name
      insert_customer=$($PSQL "INSERT INTO customers(name, phone) VALUES('$customer_name', '$customer_phone')")
    fi

    customer_id=$($PSQL "SELECT customer_id FROM customers WHERE phone='$customer_phone'")
    service_name_clean=$(echo $selected_service_name | sed -e 's/^ *//g')
    customer_name_clean=$(echo $customer_name | sed -e 's/^ *//g')

    echo -e "\nWhat time would you like your $service_name_clean, $customer_name_clean?"
    read appointment_time

    insert_appointment=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($customer_id, $selected_service_id, '$appointment_time')")

    echo -e "\nI have put you down for a $service_name_clean at $appointment_time, $customer_name_clean."
  fi
}

main_menu
