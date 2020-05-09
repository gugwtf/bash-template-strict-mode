#!/bin/bash

#===================================================
#  SCRIPT NAME: <Write script name here>
#  DESCRIPTION: <Write relevant description here>
#        NOTES: <Add relevant notes here>
#       AUTHOR: <Add author name>
#      VERSION: <Add Version>
#===================================================

# set: Change the value of a shell option and set the positional parameters, or display the names and values of shell variables.
# -e: instructs bash to immediately exit if any command has a non-zero exit status.
# -u: a reference to any variable you haven't previously defined - with the exceptions of $* and $@ - is an error, and causes the program to immediately exit.
# -o pipefail: this setting prevents errors in a pipeline from being masked. If any command in a pipeline fails, that return code will be used as the return code of the whole pipeline.
set -euo pipefail

# IFS: controls word splitting characters
IFS=$'\n\t'

# If you want to import anv variables, you have to disable the "u" flag
# set +u
# source some/bad/file.env
# set -u

# Color and effects variables to apply to text
readonly RED="\033[31m"
readonly YELLOW="\033[33m"
readonly GREEN="\033[32m"
readonly MAGENTA="\033[35m"
readonly CYAN="\033[36m"
readonly BLINK="\033[5m"
readonly BOLD="\033[1m"
readonly UNDERLINE="\033[4m"

# RC (Reset Color): use it to end the effect 
readonly RC="\033[0m"

# Pre-set strings with color effects
readonly ALERT="${RED}${BOLD}[ALERT] ${RC}"
readonly WARNING="${YELLOW}${BOLD}[WARNING] ${RC}"
readonly INFO="${CYAN}${BOLD}[INFO] ${RC}"
readonly DEBUG="${MAGENTA}${BOLD}[DEBUG] ${RC}"
readonly SUCCESS="${GREEN}${BOLD}[SUCCESS] ${RC}"
readonly OK="${GREEN}[OK] ${RC}"
readonly NOK="${RED}[NOK] ${RC}"

# Pre-set void
readonly OUT=/dev/null

# User-defined variables
# Name of your program
readonly PROGNAME=$(basename $0)
# Get path to script
readonly SCRIPT_PATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )"
# Version of your program
readonly VERSION="0.1"
# Date of th day
readonly DATE=$(date +%Y-%m-%d)
# Arguments sent to program
readonly ARGS="$@"

# Log related settings
# Log file
readonly LOG_FILE="${SCRIPT_PATH}/${PROGNAME:0:-3}.log"
# log levels
readonly -A levels=([DEBUG]=0 [INFO]=1 [WARN]=2 [ERROR]=3)
# Default log level
readonly LOG_LEVEL_DEFAULT="WARN"
log_level_set=${LOG_LEVEL_DEFAULT}

init_check_log_file() {
  # If log file doesn't exist, create it.
  if [[ ! -f ${LOG_FILE} ]]; then
    log "INFO" "Creation of log file..."
    set +e
    touch ${LOG_FILE}
    if [[ $? -eq 0 ]]; then
      log "INFO" "Creation of log file, done!"
    else
      log "ERROR" "Failed to create log file"
    fi
    set -e
  fi
}

# Function to get arguments and act accordingly with some default values already set
# -v|--version: get version
# -h|--help: get help
# -l|--log: set log level
cmdline() {
  if [[ -z $ARGS ]]; then
    main
  else
    options=$(getopt -l "help,version,log" -o "hvl" -a -- "$@")
    while true
    do
      case ${1} in
        -v|--version)
          version 
          exit 0
          ;;
        -l|--log)
            case ${2} in "0") log_level_set="DEBUG" ;; 1) log_level_set="INFO" ;; 2) log_level_set="WARN" ;; 3) log_level_set="ERROR" ;; *) log_level_set=${LOG_LEVEL_DEFAULT} ;; esac;
            shift
          ;;
        -h|--help|*) 
          usage
          exit 0
          ;;
      esac
    done
  fi
}

# Function to log parameters with some leveling
# Call it: log "<LOG LEVEL>" "<MESSAGE>"
# Example: log "WARN" "Demo Message"
log (){
  default_message="no information set."
 
  log_level=${1:?${LOG_LEVEL_DEFAULT}}
  message=${2:?$default_message}
  log_date=$(date +%Y-%m-%d_%H:%M:%S)

  case ${log_level} in
    "DEBUG")
      if (( ${levels[${log_level_set}]} == ${levels[${log_level}]} )); then
        echo -e "${log_date} - ${DEBUG} | ${message}" | tee -a ${LOG_FILE}
      fi
      ;;
    "INFO")
      if (( ${levels[${log_level_set}]} <= ${levels[${log_level}]} )); then
        echo -e "${log_date} - ${INFO} | ${message}" | tee -a ${LOG_FILE}
      fi
      ;;
    "WARN")
      if (( ${levels[${log_level_set}]} <= ${levels[${log_level}]} )); then
        echo -e "${log_date} - ${WARNING} | ${message}" | tee -a ${LOG_FILE}
      fi
      ;;
    "ERROR")
      if (( ${levels[${log_level_set}]} <= ${levels[${log_level}]} )); then
        echo -e "${log_date} - ${ALERT} | ${message}" | tee -a ${LOG_FILE}
      fi
      ;;
    *)
      log "ERROR" "Failed to write log with log level set to: "${log_level}"."
      ;;
  esac
}

# Display the version of our script
version() {
  echo "${PROGNAME} - Version ${VERSION}"
}

# Display the help of our script
usage() {
  cat <<- EOF
	usage: ./$PROGNAME [-h|-v|-l (0|1|2|3)]
	
	This program backup bookstack
	
	OPTIONS:
	
		-h --help : show this help
		-v --version : show the version
		-l --log : set log level
		  0 - DEBUG
		  1 - INFO	
		  2 - WARNING (default)	
		  3 - ERROR

	Examples:
	
	Backup bookstack:
	\$ $PROGNAME

	Backup bookstack and set log value to "DEBUG":
	\$ $PROGNAME -l 0

	Get help:
	\$ $PROGNAME -h

	Get version:
	\$ $PROGNAME -v

EOF
}

# This function will be executed on program EXIT thanks to the trap set below
demo_function_trap(){
  echo "trap function"
}

trap demo_function_trap EXIT

# Main function
main() {
  log "DEBUG" "Debug log"
  log "INFO" "Info log"
  log "WARN" "Warning log"
  log "ERROR" "Error log"
}

init_check_log_file
cmdline ${ARGS}
