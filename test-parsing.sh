#!/bin/bash

COMMAND_WITH_WEIRD_COLLECTION_NAME="collection run 'postman/collections/Scribe Service #blueprint.postman_collection.json'"

echo "- Example input command using weird collection name:"
echo "   $COMMAND_WITH_WEIRD_COLLECTION_NAME"
echo ""

echo "Arguments parsed when sent as:"
echo ""

set -- $COMMAND_WITH_WEIRD_COLLECTION_NAME
echo "\`postman \$POSTMAN_COMMAND\` (original line 94):"
    for arg in "$@"; do echo "     • [$arg]"; done
echo ""

set -- "$COMMAND_WITH_WEIRD_COLLECTION_NAME"
echo "\`postman \"\$POSTMAN_COMMAND\"\`:"
    for arg in "$@"; do echo "     • [$arg]"; done
echo ""

eval "set -- "$COMMAND_WITH_WEIRD_COLLECTION_NAME""
echo "\`eval \"postman \$POSTMAN_COMMAND\"\`:"
    for arg in "$@"; do echo "     • [$arg]"; done
echo ""
