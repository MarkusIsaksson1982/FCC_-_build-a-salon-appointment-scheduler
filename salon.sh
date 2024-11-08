#!/bin/bash
# I have utilized ChatGPT as a resource for guidance and learning throughout this project. My approach reflects the growing trend of modern developers using AI tools to enhance their coding processes. However, all the final code presented here is my own work, based on own independently thought out prompts and without copying prompts or code from others other than snippets. I believe this practice aligns with the principles of academic honesty, as it emphasizes learning and using technology responsibly. 

psql --username=freecodecamp --dbname=salon -c "
CREATE TABLE IF NOT EXISTS customers(
  customer_id SERIAL PRIMARY KEY,
  phone VARCHAR UNIQUE,
  name VARCHAR
);

CREATE TABLE IF NOT EXISTS services(
  service_id SERIAL PRIMARY KEY,
  name VARCHAR
);

CREATE TABLE IF NOT EXISTS appointments(
  appointment_id SERIAL PRIMARY KEY,
  customer_id INT REFERENCES customers(customer_id),
  service_id INT REFERENCES services(service_id),
  time VARCHAR
);"

psql --username=freecodecamp --dbname=salon -c "
INSERT INTO services (service_id, name) VALUES 
  (1, 'cut'), 
  (2, 'color'), 
  (3, 'perm')
ON CONFLICT DO NOTHING;
" >/dev/null

display_services() {
  echo -e "\n~~~~~ MY SALON ~~~~~"
  echo -e "\nWelcome to My Salon, how can I help you?"

  SERVICES=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT service_id, name FROM services")
  echo "$SERVICES" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
  SERVICE_NAME=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED" | xargs)

  if [[ -z $SERVICE_NAME ]]; then
    echo -e "\nI could not find that service. What would you like today?"
    display_services
  else
    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE'" | xargs)

    if [[ -z $CUSTOMER_NAME ]]; then
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      psql --username=freecodecamp --dbname=salon -c "INSERT INTO customers (phone, name) VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')" >/dev/null
    fi

    CUSTOMER_ID=$(psql --username=freecodecamp --dbname=salon -t -c "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE'" | xargs)

    echo -e "\nWhat time would you like your $SERVICE_NAME, $CUSTOMER_NAME?"
    read SERVICE_TIME

    psql --username=freecodecamp --dbname=salon -c "INSERT INTO appointments (customer_id, service_id, time) VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')" >/dev/null

    echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
  fi
}

display_services
