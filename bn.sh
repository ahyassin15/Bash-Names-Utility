#!/bin/bash

########################################
# Ahmed Yassin, 400536694
# The bn program is designed to to allow users to search for baby name rankings in the United States based on gender and year from 1880-2022
########################################

#Help function to display help message
help() {

    #Output utility name, version, and purpose of utility
    echo "bn utility v1.0.0"
    echo "The bn utility is designed to allow users to search for baby name rankings in the United States based on gender and year from 1880-2022."
    
    #Output how to correctly use the command and what the required arguments are
    echo "Usage: bn <year> <assigned gender: f|F|m|M|b|B>"
    echo "Arguments:"
    echo "  <year>            The year to search (between 1880 and 2022)"
    echo "  <assigned gender> The gender of the name. Can either be: (f/F for Female) or (m/M for Male) or (b/B for Both Genders)"

}

#Function to check if the data file for the specific year exists
year_file_exists() { 

    #Set file variable to the path of the baby names file for the given year
    file="us_baby_names/yob$1.txt"

    #Using the -f flag, check if the file doesn't exist 
    if [[ ! -f $file ]]; then
    
        #If the file does not exist, print an error message to stderr and exit 4
        echo "No data for $1" >&2
        exit 4

    fi
}

#If user enters the --help flag in first argument
if [[ $1 == "--help" ]]; then
    
    #Call the help function
    help

    #Exit script successfully with exit 0
    exit 0
fi

#If user does not provide exactly two arguments
if [[ $# != 2 ]]; then
    
    #Print error message indicating they entered the wrong number of arguments
    echo "Wrong number of command line arguments" >&2
    echo "Usage: bn <year> <assigned gender: f|F|m|M|b|B>" >&2

    #Indicate invalid arguments with exit 1
    exit 1
fi

#Verify that the year format is exactly 4 digits
if [[ ! $1 =~ ^[0-9]{4}$ ]]; then
    
    #If the first argument is not a valid 4-digit year, output an error message to stderr
    echo "Badly formatted year: $1" >&2
    echo "Usage: bn <year> <assigned gender: f|F|m|M|b|B>" >&2
    
    #Indicate invalid year format with exit 2
    exit 2
fi

#Verify that the gender format is either f, F, m, M, b, or B
if [[ ! $2 =~ ^[fFmMbB]$ ]]; then

    #If the second argument is not one of the allowed gender values, output an error message to stderr
    echo "Badly formatted assigned gender: $2" >&2
    echo "Usage: bn <year> <assigned gender: f|F|m|M|b|B>" >&2
    
    #Indicate invalid gender format with exit 2
    exit 2
fi

#Check if the data file for the year exists
year_file_exists "$1"

#Rank function to retrieve and display the rank of baby names based on the year and gender given by the user
#First argument ($1) = year, second argument ($2) = gender, third argument ($3) = name
rank() {

    #Count the total number of male names
    total_male=$(grep -c ",M," "us_baby_names/yob$1.txt")
    #Count the total number of female names
    total_female=$(grep -c ",F," "us_baby_names/yob$1.txt")

    #Get the rank of the male name
    rank_male=$(grep -E ",M," "us_baby_names/yob$1.txt" | grep -n -i "^$3,M," | grep -oE "^[0-9]+")
    #Get the rank of the female name
    rank_female=$(grep -E ",F," "us_baby_names/yob$1.txt" | grep -n -i "^$3,F," | grep -oE "^[0-9]+")

    #Check for female gender
    if [[ $2 == [fF] ]]; then

        #Check if rank for female exists
        if [[ -n $rank_female ]]; then
            #Output rank of female name with the total number of female names in the year
            echo "$1: $3 ranked $rank_female out of $total_female female names."
        else
            #Output female name wasn't found
            echo "$1: $3 not found among female names."
        fi
    
    #Check for male gender
    elif [[ $2 == [mM] ]]; then

        #Check if rank for male exists
        if [[ -n $rank_male ]]; then
            #Output rank of male name with the total number of male names in the year
            echo "$1: $3 ranked $rank_male out of $total_male male names."
        else
            #Output male name wasn't found
            echo "$1: $3 not found among male names."
        fi
    
    #Check for both genders
    elif [[ $2 == [bB] ]]; then

        #Check if rank for female exists
        if [[ -n $rank_female ]]; then
            echo "$1: $3 ranked $rank_female out of $total_female female names."
        else
            echo "$1: $3 not found among female names."
        fi

        #Check if rank for male exists
        if [[ -n $rank_male ]]; then
            echo "$1: $3 ranked $rank_male out of $total_male male names."
        else
            echo "$1: $3 not found among male names."
        fi
    fi
}

#Read names from stdin one at a time
while read line; do

    #For the name in the line
    for name in $line; do
    
        #Verify the name only contains valid alphabetical characters
        if [[ ! $name =~ ^[a-zA-Z]+$ ]]; then
            
            #If the name contains non-alphabetical characters, output an error message to stderr
            echo "Badly formatted name: $name" >&2

            #Indicate invalid name format with exit 3
            exit 3
        fi
  
        #Call the rank function to rank the name based on year and gender
        rank "$1" "$2" "$name"

    done
done