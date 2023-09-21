#!/bin/bash
PSQL="psql -t -X --username=freecodecamp --dbname=salon -c"


MAIN_MENU() {
	if [[ $1 ]] 
	then 
		echo -e "\n$1\n"
	fi
	echo Welcome to the salon cli app, have fun
	
	SCHEDULE_APPOINTMENT
	
}
SCHEDULE_APPOINTMENT() {
	echo -e "\nHere are the services we offer"
	SERVICES_RESULT=$($PSQL "select * from services")
	if [[ -z $SERVICES_RESULT ]]
	then
		MAIN_MENU "Sorry we don't have any services currently"
	else 
		echo -e "\nChoose a service:"
		echo "$SERVICES_RESULT" | while read SERVICE_ID BAR SERVICE_NAME
		do 
			echo "$SERVICE_ID) $SERVICE_NAME"
		done
		
		read SERVICE_ID_SELECTED
		SERVICE_ID=$($PSQL "select service_id from services where service_id ='$SERVICE_ID_SELECTED'")  
		if [[ -z $SERVICE_ID ]]
		then
			MAIN_MENU "That service doesn't exist"
		else
			echo -e "\nEnter your phone number:"
			read CUSTOMER_PHONE
			CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
			if [[ -z $CUSTOMER_ID ]] 
			then
				echo -e "\nEnter your name:"
				read CUSTOMER_NAME
				INSERT_CUSTOMER_RESULT=$($PSQL "insert into customers (phone, name) values ('$CUSTOMER_PHONE','$CUSTOMER_NAME')")
			CUSTOMER_ID=$($PSQL "select customer_id from customers where phone = '$CUSTOMER_PHONE'")
				
			fi
			echo -e "\nEnter the time for the appointement"
			read SERVICE_TIME

			INSERT_APPOINTEMENT_RESULT=$($PSQL "insert into appointments (customer_id, service_id, time) values ($CUSTOMER_ID, $SERVICE_ID, '$SERVICE_TIME')")
			if [[ $INSERT_APPOINTEMENT_RESULT = 'INSERT 0 1' ]]
			then
				SERVICE_NAME=$($PSQL "select name from services where service_id = $SERVICE_ID")

				echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
			fi
		fi
	fi
}


MAIN_MENU
