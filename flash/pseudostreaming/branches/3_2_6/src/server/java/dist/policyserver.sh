#!/bin/bash

if [ -z "$POLICYSERVER_HOME" ]; then 
  export POLICYSERVER_HOME=`pwd`; 
fi

P=":" # The default classpath separator
OS=`uname`
case "$OS" in
  CYGWIN*|MINGW*) # Windows Cygwin or Windows MinGW
  P=";" # Since these are actually Windows, let Java know
  ;;
  Darwin*)

  ;;
  *)
  # Do nothing
  ;;
esac

echo "Running on " $OS


export POLICYSERVER_PORT=1008



for JAVA in "${JAVA_HOME}/bin/java" "${JAVA_HOME}/Home/bin/java" "/usr/bin/java" "/usr/local/bin/java"
do
  if [ -x "$JAVA" ]
  then
    break
  fi
done

if [ ! -x "$JAVA" ]
then
  echo "Unable to locate Java. Please set JAVA_HOME environment variable."
  exit
fi


# start Policy Server
echo "Starting Red5"
exec "$JAVA" -jar "${POLICYSERVER_HOME}/policyserver.jar" ${POLICYSERVER_PORT}