#!/bin/bash
#
# A simple framework for testing the bn scripts
#
# Returns the number of failed test cases.
#
# Format of a test:
#     test 'command' expected_return_value 'stdin text' 'expected stdout' 'expected stderr'
#
# Some example test cases are given. You should add more test cases.
#
# Sam Scott, McMaster University, 2024


# GLOBALS: tc = test case number, fails = number of failed cases
declare -i tc=0
declare -i fails=0

############################################
# Run a single test. Runs a given command 3 times
# to check the return value, stdout, and stderr
#
# GLOBALS: tc, fails
# PARAMS: $1 = command
#         $2 = expected return value
#         $3 = standard input text to send
#         $4 = expected stdout
#         $5 = expected stderr
# RETURNS: 0 = success, 1 = bad return, 
#          2 = bad stdout, 3 = bad stderr
############################################
test() {
    tc=tc+1

    local COMMAND=$1
    local RETURN=$2
	local STDIN=$3
    local STDOUT=$4
    local STDERR=$5

    # CHECK RETURN VALUE
    $COMMAND <<< "$STDIN" >/dev/null 2>/dev/null
    local A_RETURN=$?

    if [[ "$A_RETURN" != "$RETURN" ]]; then
        echo "Test $tc Failed"
        echo "   $COMMAND"
        echo "   Expected Return: $RETURN"
        echo "   Actual Return: $A_RETURN"
        fails=$fails+1
        return 1
    fi

    # CHECK STDOUT
    local A_STDOUT=$($COMMAND <<< "$STDIN" 2>/dev/null)

    if [[ "$STDOUT" != "$A_STDOUT" ]]; then
        echo "Test $tc Failed"
        echo "   $COMMAND"
        echo "   Expected STDOUT: $STDOUT"
        echo "   Actual STDOUT: $A_STDOUT"
        fails=$fails+1
        return 2
    fi
    
    # CHECK STDERR
    local A_STDERR=$($COMMAND <<< "$STDIN" 2>&1 >/dev/null)

    if [[ "$STDERR" != "$A_STDERR" ]]; then
        echo "Test $tc Failed"
        echo "   $COMMAND"
        echo "   Expected STDERR: $STDERR"
        echo "   Actual STDERR: $A_STDERR"
        fails=$fails+1
        return 3
    fi
    
    # SUCCESS
    echo "Test $tc Passed"
    return 0
}

##########################################
# EXAMPLE TEST CASES
##########################################

# simple success
test './bn 2022 m' 0 'Sam' '2022: Sam ranked 658 out of 14255 male names.' ''

# multi line success
test './bn 2022 B' 0 'Sam' '2022: Sam ranked 658 out of 14255 male names.
2022: Sam ranked 6628 out of 17660 female names.' ''

# error case
test './bn 2022 F' 3 'Sam2' '' 'Badly formatted name: Sam2'  

# multi line error case #2
test './bn 1111 X' 2 '' '' 'Badly formatted assigned gender: X
bn <year> <assigned gender: f|F|m|M|b|B>'

# return code
exit $fails

##########################################
# ADDED TEST CASES
##########################################

# Test help flag (testing exit 0)
test './bn --help' 0 '' 'bn utility v1.0.0
Usage: bn <year> <assigned gender: f|F|m|M|b|B>
Search for baby name rankings based on year and gender.' ''

#Missing arguments provided (testing exit 1)
test_case './bn' 1 '' '' "Usage: bn <year> <assigned gender: f|F|m|M|b|B>"

#Error case for invalid year format (testing exit 2)
test_case './bn 202 m' 2 '' '' "Invalid year format.
Usage: bn <year> <assigned gender: f|F|m|M|b|B>"

#Error case for invalid name format for containing a number (testing exit 3)
test './bn 2020 m' 3 'Tyler1234567' '' 'Badly formatted name: Tyler1234567'

#Error case for non-existent year data file (testing exit 4)
test './bn 1700 m' 4 '' '' 'No data for 1700'

#Success case for a male name
test './bn 2015 M' 0 'Liam' '2015: Liam ranked  out of  male names.' ''

#Success case for a female name
test './bn 2020 F' 0 'Emma' '2020: Emma ranked 1 out of 17108 female names.' ''

#Success case for both female and male genders
test './bn 2010 B' 0 'Taylor' '2010: Taylor ranked 360 out of 13477 male names.
2010: Taylor ranked 121 out of 17238 female names.' ''

#Error case for an invalid gender
test './bn 2020 X' 2 '' '' 'Invalid gender format.
Usage: bn <year> <assigned gender: f|F|m|M|b|B>'

#Edge case for valid year and gender, but the name is not found
test './bn 2020 m' 0 'ZUWHyzx' '2020: ZUWHyzx not found among male names.' ''

#Edge case for valid year and gender, but the name exists only for one gender
test './bn 2020 B' 0 'Emily' '2020: Emily ranked 18 out of 17108 female names.
2020: Emily not found among male names.' ''hassan: