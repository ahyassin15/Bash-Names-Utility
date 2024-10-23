#!/bin/bash

#Help function to display help message
help() {

    #Outputs utility name and version
    echo "bn utility v1.0.0"
    #Output how to correctly use the command (f/F for female, m/M for male, b/B for both)
    echo "Usage: bn <year> <assigned gender: f|F|m|M|b|B>"
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

    #Define path to the baby names data file for the specific year
    local file="us_baby_names/yob${year}.txt"

    #Check if the data file for the specific year exists
    if [[ ! -f $file ]]; then
        
        #If the file does not exist, print an error message to stderr and exit 4
        echo "No data for $year" >&2
        exit 4

    fi

    #Select gender-specific data and rank
    if [[ "$gender" == [fF] ]]; then
        #If gender is female (f/F), search for the name in the female records
        result=$(grep -i "^${name}," "$file" | grep ",F," | head -n 1)
    
    elif [[ "$gender" == [mM] ]]; then
        #If gender is male (m/M), search for the name in the male records
        result=$(grep -i "^${name}," "$file" | grep ",M," | head -n 1)
    
    elif [[ "$gender" == [bB] ]]; then
        #If gender is both (b/B), search for the name in both male and female records
        male_result=$(grep -i "^${name}," "$file" | grep ",M," | head -n 1)
        female_result=$(grep -i "^${name}," "$file" | grep ",F," | head -n 1)

        #If male names found, print results
        if [[ -n $male_result ]]; then
            #Extract the rank for the male name
            rank=$(echo "$male_result" | cut -d',' -f2)
            #Count the number of male names in the file
            total=$(grep -c ",M," "$file")
            #Print rank and total male names
            echo "$year: $name ranked $rank out of $total male names."

        else
            #Print message if no male result found
            echo "$year: $name not found among male names."

        fi

        #If female names found, print results
        if [[ -n $female_result ]]; then
            #Extract the rank for the female name
            rank=$(echo "$female_result" | cut -d',' -f2)
            #Count the number of female names in the file
            total=$(grep -c ",F," "$file")
            #Print rank and total female names
            echo "$year: $name ranked $rank out of $total female names."

        else
            #Print message if no female result found
            echo "$year: $name not found among female names."

        fi
        
        return
    
    fi

    #If result is a specific gender (male or female)
    if [[ -n $result ]]; then
        #Extract the rank for the name
        rank=$(echo "$result" | cut -d',' -f2)
        #Count the total number of names for the specific gender in the file
        total=$(grep -c ",$gender," "$file")
        #Print rank and total names for the specific gender
        echo "$year: $name ranked $rank out of $total ${gender,,} names."

    else
        #If no result is found, print message that the name is not found for the specific gender
        echo "$year: $name not found among ${gender,,} names."

    fi
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

    #Call usage function and exit 2 for invalid argument format
    usage
    exit 2
fi

#Verify that the gender format is either f, F, m, M, b, or B
if ! [[ $2 =~ ^[fFmMbB]$ ]]; then

    #If the second argument is not one of the allowed gender values, output an error message to stderr
    echo "Invalid gender format." >&2

    #Call usage function and exit 2 for invalid argument format
    usage
    exit 2
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