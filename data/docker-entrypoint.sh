#!/usr/bin/env bash

# Be strict
set -e
set -u
set -o pipefail


###
### Globals
###
ARG_SORT_OBJECTS=                 # jsonlint arg for sort objects
ARG_CHAR=                         # jsonlint arg for indentation character(s)
ARG_IGNORE=                       # jsonlint arg to ignore files found via glob
REG_GLOB='(\*.+)|(.+\*)|(.+\*.+)' # Regex pattern to identify valid glob supported by 'find'


###
### Show Usage
###
print_usage() {
	>&2 echo "Error, Unsupported command."
	>&2 echo "Usage: cytopia/jsonlint jsonlint [-sti] <PATH-TO-FILE>"
	>&2 echo "       cytopia/jsonlint jsonlint [-sti] <GLOB-PATTERN>"
	>&2 echo "       cytopia/jsonlint jsonlint --version"
	>&2 echo "       cytopia/jsonlint jsonlint --help"
	>&2 echo
	>&2 echo " -s                 sort object keys"
	>&2 echo " -t CHAR            character(s) to use for indentation"
	>&2 echo " -i <GLOB-PATTERN>  Ignore glob pattern when using the GLOB-PATTERN for file search."
	>&2 echo "                    (e.g.: -i '\.terraform*.json')"
	>&2 echo " <PATH-TO-FILE>     Path to file to validate"
	>&2 echo " <GLOB-PATTERN>     Glob pattern for recursive scanning. (e.g.: *\\.json)"
	>&2 echo "                    Anything that \"find . -name '<GLOB-PATTERN>'\" will take is valid."
}


###
### Validate JSON file
###
### @param  string Jsonlint arguments.
### @param  string Path to file.
### @return int    Success (0: success, >0: Failure)
###
_jsonlint() {
	local args="${1}"
	local file="${2}"
	# shellcheck disable=SC2155
	local temp="/tmp/$(basename "${file}")"
	local ret=0
	local cmd="jsonlint -c ${args} ${file}"

	echo "${cmd}"
	if ! eval "${cmd}" > "${temp}"; then
		ret=$(( ret + 1 ))
	fi
	if !  diff "${file}" "${temp}"; then
		ret=$(( ret + 1 ))
	fi

	return "${ret}"
}


###
### Arguments appended?
###
if [ "${#}" -gt "0" ]; then

	while [ "${#}" -gt "0"  ]; do
		case "${1}" in
			# Show Help and exit
			--help)
				print_usage
				exit 0
				;;
			# Show Version and exit
			--version)
				jsonlint --version || true
				exit 0
				;;
			# Add jsonlint argument sort-objects (-s)
			-s)
				shift
				ARG_SORT_OBJECTS="-s"
				;;
			# Add jsonlint argument indent character(s) (-t)
			-t)
				shift
				if [ "${#}" -lt "1" ]; then
					>&2 echo "Error, -t requires an argument"
				fi
				ARG_CHAR="-t '${1}'"
				shift
				;;
			# Ignore glob patterh
			-i)
				shift
				if [ "${#}" -lt "1" ]; then
					>&2 echo "Error, -i requires an argument"
				fi
				ARG_IGNORE="${1}"
				shift
				;;
			# Anything else is handled here
			*)
				# Case 1/2: Its a file
				if [ -f "${1}" ]; then
					# Argument check
					if [ "${#}" -gt "1" ]; then
						>&2 echo "Error, you cannot specify arguments after the file position."
						print_usage
						exit 1
					fi
					_jsonlint "${ARG_SORT_OBJECTS} ${ARG_CHAR}" "${1}"
					exit "${?}"
				# Case 2/2:  Its a glob
				else
					# Glob check
					if ! echo "${1}" | grep -qE "${REG_GLOB}"; then
						>&2 echo "Error, wrong glob format. Allowed: '${REG_GLOB}'"
						exit 1
					fi
					# Argument check
					if [ "${#}" -gt "1" ]; then
						>&2 echo "Error, you cannot specify arguments after the glob position."
						print_usage
						exit 1
					fi

					# Iterate over all files found by glob and jsonlint them
					if [ -z "${ARG_IGNORE}" ]; then
						find_cmd="find . -name \"${1}\" -type f -print0"
					else
						find_cmd="find . -not \( -path \"${ARG_IGNORE}\" \) -name \"${1}\" -type f -print0"
					fi

					echo "${find_cmd}"
					ret=0
					while IFS= read -rd '' file; do
						if ! _jsonlint "${ARG_SORT_OBJECTS} ${ARG_CHAR}" "${file}"; then
							ret=$(( ret + 1 ))
						fi
					done < <(eval "${find_cmd}")
					exit "${ret}"
				fi
				;;
		esac
	done

###
### No arguments appended
###
else
	print_usage
	exit 0
fi
