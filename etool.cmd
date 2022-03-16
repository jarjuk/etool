rem Configuration
set ETOOL_DIR=C:%HOMEPATH%\Documents\etool
set TAG=3

rem Locate IP-address, needed to setup X11 DISPLAY 
set ip_address_string="IPv4 Address"
rem Uncomment the following line when using older versions of Windows without IPv6 support (by removing "rem")
rem set ip_address_string="IP Address"
for /f "usebackq tokens=2 delims=:" %%f in (`ipconfig ^| findstr /c:%ip_address_string%`) do (
    echo Your SIP Address is: %%f
    set IP=%%f
    goto jatkuu
)
:jatkuu

set DISPLAY=%IP%:0
rem Cleanup spaces
set DISPLAY=%DISPLAY: =%


rem --- 
rem Create data directory, unless it exists
if exist %ETOOL_DIR%   goto aja
mkdir %ETOOL_DIR%
icacls %ETOOL_DIR% /grant Everyone:(OI)(CI)F /T


rem and kick off...
:aja
echo DISPLAY=%DISPLAY% HOME=%HOMEPATH% TAG=%TAG%
docker run -it --user 1000 --rm -e DISPLAY=%DISPLAY% -v %ETOOL_DIR%:/etool marcus2002/etool:%TAG% %*
