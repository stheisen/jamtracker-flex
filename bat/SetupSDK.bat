:user_configuration

:: Path to Flex SDK
:: set FLEX_SDK=C:\Apache\Flex
set FLEX_SDK=C:\LocalData\Programs\ApacheFlex_4.16.1

:validation
if not exist "%FLEX_SDK%\bin" goto flexsdk
goto succeed

:flexsdk
echo.
echo ERROR: incorrect path to Flex SDK in 'bat\SetupSDK.bat'
echo.
echo Looking for: %FLEX_SDK%\bin
echo.
if %PAUSE_ERRORS%==1 pause
exit

:succeed
set PATH=%FLEX_SDK%\bin;%PATH%

