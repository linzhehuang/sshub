#!/bin/sh

# Global variables.
CWD="$( cd `dirname "${0}"` && pwd )"
JSON_CONTENT=`cat "${CWD}/demo.json"`
# Import the shell_JSON.sh.
source "${CWD}/shell_JSON.sh"

shell_JSON_setContent "${JSON_CONTENT}"

echo -n "string = "
shell_JSON_getValueByKey "string"
echo ""

echo -n "number = "
shell_JSON_getValueByKey "number"
echo ""

echo -n "array = "
shell_JSON_getValueByKey "array"
echo ""

echo -n "object = "
shell_JSON_getValueByKey "object"
echo ""
