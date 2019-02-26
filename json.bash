#!/usr/bin/env bash

set -e

readonly TOKEN_STRING=1
readonly TOKEN_VALUE=3
readonly TOKEN_OBJECT_START=4
readonly TOKEN_OBJECT_END=5

TOKENS=()

function flatjson_lexer() {
  local DOC="$1"
  local CHAR=
  local STRING=
  local READING_STRING=
  local READING_NUMBER=

  for (( i=0; i<"${#DOC}"; i++ )); do
    CHAR="${DOC:$i:1}"

    if [ $READING_STRING ]; then
      if [ ! $CHAR == '"' ]; then
        STRING+="${CHAR}"
      else
        TOKENS+=("$TOKEN_STRING")
        TOKENS+=("$STRING")
        STRING=""
        READING_STRING=
      fi
      continue
    fi

    if [ $READING_NUMBER ]; then
      if [[ "$CHAR" =~ [0-9] ]]; then
        STRING+="$CHAR"
        continue
      else
        TOKENS+=("$TOKEN_STRING")
        TOKENS+=("x$STRING")
        STRING=""
        READING_NUMBER=
      fi
    fi

    if [ "$CHAR" == '{' ]; then
      TOKENS+=("$TOKEN_OBJECT_START")
    elif [ "$CHAR" == '}' ]; then
      TOKENS+=("$TOKEN_OBJECT_END")
    elif [ "$CHAR" == '"' ]; then
      READING_STRING=true
    elif [ "$CHAR" == ':' ]; then
      TOKENS+=("$TOKEN_VALUE")
    elif [[ $CHAR =~ [0-9] ]]; then
      READING_NUMBER=true
      STRING="${CHAR}"
    fi
  done
}

function flatjson_parser() {
  local DOC="$1"
  local TOKEN=
  local PATH=()
  local APPEND=
  local IS_VALUE=

  lexer "$DOC"

  for (( i=0; i < "${#TOKENS[@]}"; i++ )); do
    TOKEN="${TOKENS[i]}"

    if [ "$TOKEN" == $TOKEN_OBJECT_START ]; then
      APPEND=true
      IS_VALUE=
    elif [ "$TOKEN" == $TOKEN_OBJECT_END ]; then
      IS_VALUE=
      PATH=("${PATH[@]:0:${#PATH[@]} - 1}")
    elif [ "$TOKEN" == $TOKEN_STRING ]; then
      if [ ! $IS_VALUE ]; then
        # pop
        if [ ! $APPEND ]; then
          PATH=("${PATH[@]:0:${#PATH[@]} - 1}")
        fi
        APPEND=true
      fi
    elif [ "$TOKEN" == $TOKEN_VALUE ]; then
      IS_VALUE=true
      APPEND=
    else
      if [ $IS_VALUE ]; then
        (
          IFS="."
          echo "${PATH[@]}: ${TOKEN}"
        )
      elif [ $APPEND ]; then
        PATH+=("$TOKEN")
      fi

      IS_VALUE=
      APPEND=
    fi
  done
}

function flatjson() {
  flatjson_parser "$1"
}
