#!/bin/bash

#Help function to display help message
help() {

    #Outputs utility name and version
    echo "bn utility v1.0.0"
    #Explains purpose of the bash script
    echo "Search for baby name rankings based on year and gender."
    
}

#Usage function to display usage information
usage() {

    #Output how to correctly use the command (f/F for female, m/M for male, b/B for both)
    echo "Usage: bn <year> <assigned gender: f|F|m|M|b|B>" >&2
    
    #Indicate an error with exit 1
    exit 1

}

#Rank function to rank a single baby name based on the year and gender
rank() {

    #Initialize local name variable to first argument
    local name=$1
    #Initialize local year variable to second argument
    local year=$2
    #Initialize local gender variable to third argument
    local gender=$3

}

#If user enters the --help flag in first argument
if [[ "$1" == "--help" ]]; then
    
    #Call the help function
    help

    #Exit script successfully with exit 0
    exit 0
fi

#If there isn't exactly two arguments provided by the user
if [[ $# -ne 2 ]]; then
    
    #Call the usage function
    usage

fi

#Verify that the year format is exactly 4 digits
if ! [[ $1 =~ ^[0-9]{4}$ ]]; then
    
    #If the first argument is not a valid 4-digit year, output an error message to stderr
    echo "Invalid year format." >&2

    #Call usage function
    usage

fi

#Verify that the gender format is either f, F, m, M, b, or B
if ! [[ $2 =~ ^[fFmMbB]$ ]]; then

    #If the second argument is not one of the allowed gender values, output an error message to stderr
    echo "Invalid gender format." >&2

    #Call usage function
    usage

fi

#Initialize year and gender variables to first and second arguments respectively
year=$1
gender=$2

#Read names from stdin one at a time
while read -r name; do

#Verify that the names contain valid alphabetical characters only
    if ! [[ $name =~ ^[a-zA-Z]+$ ]]; then
        
        #If the name contains non-alphabetical characters, output an error message to stderr
        echo "Badly formatted name: $name" >&2
        
        #Indicate invalid name format with exit 3
        exit 3

    fi
  
    #Call the rank function to rank the name based on year and gender
    rank "$name" "$year" "$gender"

done