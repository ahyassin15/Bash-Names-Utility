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
# ADDED TEST CASES
##########################################

# --help flag success
test './bn.sh --help' 0 '' 'bn utility v1.0.0
The bn utility is designed to allow users to search for baby name rankings in the United States based on gender and year from 1880-2022.
Usage: bn <year> <assigned gender: f|F|m|M|b|B>
Arguments:
  <year>            The year to search (between 1880 and 2022)
  <assigned gender> The gender of the name. Can either be: (f/F for Female) or (m/M for Male) or (b/B for Both Genders)' ''


# Simple success (m)
test './bn.sh 2022 m' 0 'Sam' '2022: Sam ranked 658 out of 14255 male names.' ''


# Simple success (F)
test './bn.sh 2003 F' 0 'Emily' '2003: Emily ranked 1 out of 18435 female names.' ''


# Multi line success (B)
test './bn.sh 2022 B' 0 'Sam' '2022: Sam ranked 6628 out of 17660 female names.
2022: Sam ranked 658 out of 14255 male names.' ''


# Multi line success (b)
test './bn.sh 1980 b' 0 'ellie SEBASTIAN JoSePh' '1980: ellie ranked 1554 out of 12163 female names.
1980: ellie not found among male names.
1980: SEBASTIAN ranked 11771 out of 12163 female names.
1980: SEBASTIAN ranked 671 out of 7294 male names.
1980: JoSePh ranked 763 out of 12163 female names.
1980: JoSePh ranked 10 out of 7294 male names.' ''


# Error case: exit code 1
test './bn.sh 1980' 1 '' '' 'Wrong number of command line arguments
Usage: bn <year> <assigned gender: f|F|m|M|b|B>'


# Error case: exit code 1
test './bn.sh 1961 M Bob WILLIAM' 1 '' '' 'Wrong number of command line arguments
Usage: bn <year> <assigned gender: f|F|m|M|b|B>'


# Multi line error case: exit code 2
test './bn.sh twenty-twenty b' 2 '' '' 'Badly formatted year: twenty-twenty
Usage: bn <year> <assigned gender: f|F|m|M|b|B>'


# Multi line error case: exit code 2
test './bn.sh 1111 X' 2 '' '' 'Badly formatted assigned gender: X
Usage: bn <year> <assigned gender: f|F|m|M|b|B>'


# Multi line error case: exit code 2
test './bn.sh 1922 Female' 2 '' '' 'Badly formatted assigned gender: Female
Usage: bn <year> <assigned gender: f|F|m|M|b|B>'


# Error case: exit code 3
test './bn.sh 2022 F' 3 'Sam123' '' 'Badly formatted name: Sam123'


# Error case: exit code 3
test './bn.sh 1996 m' 3 'Daniel_ Smith' '' 'Badly formatted name: Daniel_'


# Error case: exit code 4
test './bn.sh 2025 m' 4 '' '' 'No data for 2025'


# return code
exit $fails