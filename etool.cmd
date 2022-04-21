@rem Configuration
set ETOOL_DIR=C:%HOMEPATH%\Documents\etool
set TAG=6

@rem Locate IP-address, needed to setup X11 DISPLAY 
set ip_address_string="IPv4 Address"
@rem Uncomment the following line when using older versions of Windows without IPv6 support (by removing "rem")
@rem set ip_address_string="IP Address"
for /f "usebackq tokens=2 delims=:" %%f in (`ipconfig ^| findstr /c:%ip_address_string%`) do (
    echo Your SIP Address is: %%f
    set IP=%%f
    goto jatkuu
)
:jatkuu

set DISPLAY=%IP%:0
@rem Cleanup spaces
set DISPLAY=%DISPLAY: =%


@rem --- 
rem Create data directory, unless it exists
if exist %ETOOL_DIR%   goto aja
mkdir %ETOOL_DIR%
icacls %ETOOL_DIR% /grant Everyone:(OI)(CI)F /T


@rem and kick off...
:aja
echo DISPLAY=%DISPLAY% HOME=%HOMEPATH% TAG=%TAG%

@rem usage if no parameters given

if [%1]==[] goto usage
set ARGS=%*
goto ajavaan
:usage
docker run -it --user 1000 --rm -e DISPLAY=%DISPLAY% -v %ETOOL_DIR%:/etool marcus2002/etool:%TAG% 
@echo -----------------------------------------------------------------------------------------------------------
@echo Instructions above (scroll backwards to see them all, run 'etool.cmd --help' to seem them again)
@echo Configurations and geber/gcode -files in directory %ETOOL_DIR%
pause

cmd
exit




:ajavaan
@rem ARGS is contains paremters to run
@rem docker run -it --user 1000 --rm -e DISPLAY=%DISPLAY% -v %ETOOL_DIR%:/etool marcus2002/etool:%TAG%  %*
@rem Set LIBGL_ALWAYS_INDIRECT=1 to avoid error
@rem libGL error: No matching fbConfigs or visuals found
@rem libGL error: failed to load driver: swrast
@rem Ref: https://askubuntu.com/questions/1127011/win10-linux-subsystem-libgl-error-no-matching-fbconfigs-or-visuals-found-libgl
@rem This error prevents simulator command from displaying machine preview tab
@rem In spite of this "fix" need to click DRO tab to make linuxcnc to refresh machine preview

docker run -it --user 1000 --rm -e DISPLAY=%DISPLAY% -v %ETOOL_DIR%:/etool marcus2002/etool:%TAG% exe export LIBGL_ALWAYS_INDIRECT=1 -- %ARGS%
