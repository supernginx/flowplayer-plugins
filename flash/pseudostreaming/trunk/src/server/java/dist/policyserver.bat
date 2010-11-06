@echo off

SETLOCAL

if NOT DEFINED POLICYSERVER_HOME set POLICYSERVER_HOME=%CD%

set POLICYSERVER_PORT=1008

if NOT DEFINED JAVA_HOME goto err

goto launchRed5

:launchRed5
echo Starting Red5
"%JAVA_HOME%\bin\java" "%POLICYSERVER_HOME%\policyserver.jar" %POLICYSERVER_PORT%
goto finally

:err
echo JAVA_HOME environment variable not set! 
pause

:finally
ENDLOCAL
