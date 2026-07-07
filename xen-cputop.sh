#!/bin/bash --posix

# ------------------------------------------------------------------------------
# Copyright (C) 2026 Atrate
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as
# published by the Free Software Foundation, either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
# ------------------------------------------------------------------------------


# ------------------------------------------------------------------------------
# Wrapper for xenpm start that uses AWK to colorize and reformat its output
# --------------------
# Version: 1.0.0
# --------------------
# Exit code listing:
#   0: All good
#   1: Unspecified
#   2: Error in environment configuration or arguments
# ------------------------------------------------------------------------------

## -----------------------------------------------------------------------------
## SECURITY SECTION
## NO EXECUTABLE CODE CAN BE PRESENT BEFORE THIS SECTION
## -----------------------------------------------------------------------------

# Set POSIX-compliant mode for security and unset possible overrides
# NOTE: This does not mean that we are restricted to POSIX-only constructs
# ------------------------------------------------------------------------
POSIXLY_CORRECT=1
set -o posix
readonly POSIXLY_CORRECT
export POSIXLY_CORRECT

# Set IFS explicitly. POSIX does not enforce whether IFS should be inherited
# from the environment, so it's safer to set it expliticly
# --------------------------------------------------------------------------
IFS=$' \t\n'
export IFS

# ------------------------------------------------------------------------------
# For additional security, you may want to specify hard-coded values for:
#   SHELL, PATH, HISTFILE, ENV, BASH_ENV
# They will be made read-only by set -r later in the script.
# ------------------------------------------------------------------------------

# Populate this array with **all** commands used in the script for security.
# The following builtins do not need to be included, POSIX mode handles that:
# break : . continue eval exec exit export readonly return set shift trap unset
# The following keywords are also supposed not to be overridable in bash itself
# ! case  coproc  do done elif else esac fi for function if in
# select then until while { } time [[ ]]
# ------------------------------------------------------------------------------
UTILS=(
    'awk'
    'column'
    'command'
    'cut'
    'echo'
    'getopt'
    'grep'
    'hash'
    'local'
    'logger'
    'paste'
    'read'
    'sed'
    'tr'
    'xenpm'
)

# Unset all commands used in the script - prevents exported functions
# from overriding them, leading to unexpected behavior
# -------------------------------------------------------------------
for util in "${UTILS[@]}"
do
    \unset -f -- "$util"
done

# Clear the command hash table
# ----------------------------
hash -r

# Set up fd 3 for discarding output, necessary for set -r
# -------------------------------------------------------
exec 3>/dev/null

# ------------------------------------------------------------------------------
# Options description:
#   -o pipefail: exit on error in any part of pipeline
#   -eE:         exit on any error, go through error handler
#   -u:          exit on accessing uninitialized variable
#   -r:          set bash restricted mode for security
# The restricted mode option necessitates the usage of tee
# instead of simple output redirection when writing to files
# ------------------------------------------------------------------------------
set -o pipefail -eEur

## -----------------------------------------------------------------------------
## END OF SECURITY SECTION
## Make sure to populate the $UTILS array above
## -----------------------------------------------------------------------------

# Speed up script by not using unicode
# ------------------------------------
LC_ALL=C
LANG=C

# Because who needs multiple files for a program
# ----------------------------------------------
readonly AWKSCRIPT='
# Colour functions by CodeMedic (written with some greek letters) on Stack

function isnumeric(x)
{
    return ( x == x+0 );
}

function name_to_number(name, predefined)
{
    if (isnumeric(name))
        return name;

        if (name in predefined)
            return predefined[name];

            return name;
        }

    function colour(v1, v2, v3)
    {
        if (v3 == "" && v2 == "" && v1 == "")
            return;

            if (v3 == "" && v2 == "")
                return sprintf("%c[%dm", 27, name_to_number(v1, fgcolours));
            else if (v3 == "")
                return sprintf("%c[%d;%dm", 27, name_to_number(v1, bgcolours), name_to_number(v2, fgcolours));
            else
                return sprintf("%c[%d;%d;%dm", 27, name_to_number(v1, attributes), name_to_number(v2, bgcolours), name_to_number(v3, fgcolours));
            }

        BEGIN {
            # Use 1 decimal place in calculations
            OFMT = "%.1f"

    # hack to use attributes for just "None"
    fgcolours["None"] = 0;

    fgcolours["Black"] = 90;
    fgcolours["Red"] = 91;
    fgcolours["Green"] = 92;
    fgcolours["Yellow"] = 93;
    fgcolours["Blue"] = 94;
    fgcolours["Magenta"] = 95;
    fgcolours["Cyan"] = 96;
    fgcolours["White"] = 97;
    fgcolours["Grey"] = 37;

    bgcolours["None"] = 0;
    bgcolours["Black"] = 40;
    bgcolours["Red"] = 41;
    bgcolours["Green"] = 42;
    bgcolours["Yellow"] = 43;
    bgcolours["Blue"] = 44;
    bgcolours["Magenta"] = 45;
    bgcolours["Cyan"] = 46;
    bgcolours["White"] = 47;

    attributes["None"] = 0;
    attributes["Bold"] = 1;
    attributes["Underscore"] = 4;
    attributes["Blink"] = 5;
    attributes["ReverseVideo"] = 7;
    attributes["Concealed"] = 8;
}
{
    # CORE
    {printf "%11s ", colour("None")$1}

    # CPU(%)
    # Ugly workaround to actually display even whole numbers with .0
    $2 = sprintf("%.1f", $2) + 0
    if (!($2 ~ /\./))
        $2 = $2".0"

        if ($2 ~ /^[0-9\.]+$/)
            if ($2 + 0 >= 75)
                {printf "%10s", colour("Red")$2}
            else if ($2 + 0 >= 50)
                {printf "%10s", colour("Yellow")$2}
            else if ($2 + 0 >= 25)
                {printf "%10s", colour("Green")$2}
            else if ($2 + 0 >=5)
                {printf "%10s", colour("White")$2}
            else
                {printf "%10s", colour("Grey")$2}
            else
                {printf "%10s", colour("None")$2}

    # TOTAL/AVERAGE CPU(%) set-up
    sum += $2; n++

    # Reset colour
    printf "%s\n", colour("None")

}
END {
    if (NOTOTALS != "true")
        {
            # Print totals
            CONVFMT = "%.1f"
            if (n > 0)
                printf "%17s", colour("ReverseVideo", "Black", "White")"TOTAL:"
                avg = sum / n
                if (avg >= 75)
                    {printf "%11s", colour("Red")avg}
                else if (avg >= 50)
                    {printf "%11s", colour("Yellow")avg}
                else if (avg >= 25)
                    {printf "%11s", colour("Green")avg}
                else if (avg >=5)
                    {printf "%11s", colour("White")avg}
                else
                    {printf "%11s", colour("Grey")avg}
                    # Reset colour
                    printf "%s\n", colour("None")
                }
        }
    '

# Print script usage
# ------------------
print_usage()
{
    cat << USAGE >&2
Usage:  $(basename "$0"): [-h] [-d NUMBER] [-u REGEX] [-c NUMBER] [-n]

Options:
  -h, --help               print this usage information
  -d, --delay              refresh delay in seconds
  -u, --underline-cores    regex indicating which CPU cores to underline.
                           For example: -u '[0-7]|1[6-9]' will underline cores
                           0-7 and 16-19, so the p-cores on an Ultra 7 155H
  -c, --columns            number of columns to use for display
  -n, --no-totals          don't print the TOTAL row
USAGE
return 0
}

# Print to stderr and user.err
# ----------------------------
err()
{
    echo "$@" | tee /dev/fd/2 | logger --priority user.err --tag "$0"
}


# Parse commandline options
# Adapted from https://stackoverflow.com/a/29754866
# -------------------------------------------------
parse_options()
{
    # Check whether getopt version is "enhanced"
    # shellcheck disable=SC2251
    # ------------------------------------------
    ! getopt --test >&3
    if [[ ${PIPESTATUS[0]} -ne 4 ]]
    then
        err 'This script requres getopt enhanced to work properly'
        exit 2
    fi

    # Set available options
    # ---------------------
    LONGOPTS=help,no-totals,delay:,underline-cores:,columns:
    OPTIONS=hnd:u:c:

    # Get arguments from "$@" using getopt
    # ------------------------------------
    IFS=" " read -r -a PARSED <<< "$(getopt --options=$OPTIONS --longoptions=$LONGOPTS --name "$0" -- "$@")"
    eval set -- "${PARSED[*]}"

    # Declare argument variables' default values
    # ------------------------------------------
    declare -g DELAY=2
    declare -g ULCORES=""
    declare -g NOTOTALS="false"
    declare -ga COLUMNS=(-)

    # Write to argument variables
    # ---------------------------
    while true
    do
        case "$1" in
            -h|--help)
                print_usage
                exit 0
                ;;
            -n|--no-totals)
                NOTOTALS="true"
                shift 1
                ;;
            -u|--underline-cores)
                ULCORES="$2"
                shift 2
                ;;
            -c|--columns)
                # While some people would see the below as a reason to use
                # anything but bash, this only brings a smile to my face
                # --------------------------------------------------------
                COLUMNS=()
                for ((i=0; i<$2; i++))
                do
                    COLUMNS+=(-)
                done
                shift 2
                ;;
            -d|--delay)
                DELAY="$2"
                shift 2
                ;;
            --)
                shift
                break
                ;;
            *)
                echo "Invalid argument: $1"
                print_usage
                exit 2
                ;;
        esac
    done

    return
}


# Check the environment the script is running in
# ----------------------------------------------
check_environment()
{
    # Check available utilities
    # -------------------------
    for util in "${UTILS[@]}"
    do
        command -v -- "$util" >&3 || { echo "This script requires $util to be installed and in PATH!"; exit 2; }
    done

    return
}


# Main program functionality
# --------------------------
main()
{
    while :
    do
        buffer=""
        # Parse xenpm output...
        # ---------------------
        buffer+="$(xenpm start "$DELAY" \
            | grep -B 1 -E '^\s*C0[^%]*%' \
            | paste -d ' ' - - - \
            | tr --squeeze '	(' ' ' \
            | cut -d ' ' -f 1,9 \
            | cut -d '%' -f1 \
            | column -t)"

            # Colour output and calculate total usage
            # ---------------------------------------
            buffer="$(clear; echo -e "$buffer" \
                | awk -v NOTOTALS="$NOTOTALS" "$AWKSCRIPT" \
                | paste -d ' ' "${COLUMNS[@]}")"

                # Skip sed if ULCORES is not provided for performance
                # ---------------------------------------------------
                if [ ! -z "$ULCORES" ]
                then
                    # Highlight selected cores (underline)
                    # ------------------------------------
                    buffer="$(echo -e "$buffer" \
                        | sed -E "s/(CPU($ULCORES):)/\x1b[4m\1\x1b[0m/g")"
                fi

                echo -e "$buffer"
            done
}

check_environment
parse_options "$@"
main

## END OF FILE #################################################################
# vim: set tabstop=4 softtabstop=4 expandtab shiftwidth=4 smarttab:
# End:
