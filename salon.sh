#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ My Salon ~~~~~\n"

MAIN_MENU() {
  if [[ $1 ]] 
  then
    echo -e "$1\n"
  else
    echo -e "Welcome to my salon, how may I help you?\n"
  fi

  # display a list of services
  AVAILABLE_SERVICES=$($PSQL "SELECT * FROM services")
  # check for service
  if [[ -z $AVAILABLE_SERVICES ]]
  then
    MAIN_MENU "Sorry, We currently have no services."
  else
    # show services
    echo "$AVAILABLE_SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
    do
      echo "$SERVICE_ID) $SERVICE_NAME"
    done

    # ask for a service to schedule

    # if input is not a number
    read SERVICE_ID_SELECTED
    if [[ ! $SERVICE_ID_SELECTED =~ ^[0-9]+$ ]]
    then
    MAIN_MENU "\nI could not find that service. What would you like today"
    else
      #if input is not found
      SERVICE_ID_SELECTED=$($PSQL "SELECT service_id FROM services WHERE service_id = $SERVICE_ID_SELECTED")
      if [[ -z $SERVICE_ID_SELECTED ]]
      then
        MAIN_MENU "\nI could not find that service. What would you like today" 
      else
        SCHEDULE_APPOINTMENT     
      fi
    fi
  fi
}

SCHEDULE_APPOINTMENT() {
  # look up customer
  echo -e "\nWhat's your phone number?"
  read CUSTOMER_PHONE
  CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  # if not found
  if [[ -z $CUSTOMER_ID ]]
  then
    # add new customer
    echo -e "\nI don't have a record for that phone number. What's your name?"
    read CUSTOMER_NAME
    INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    # get new customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  fi

  # get customer name and service name
  CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")
  SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
  # get appointment time
  echo -e "\nWhat time would you like your $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g'), $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g')?"
  read SERVICE_TIME
  # add the appointment
  APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
  echo -e "\nI have put you down for a $(echo $SERVICE_NAME | sed -r 's/^ *| *$//g') at $SERVICE_TIME, $(echo $CUSTOMER_NAME | sed -r 's/^ *| *$//g').\n"
}

MAIN_MENU
