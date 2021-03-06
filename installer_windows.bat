:: Vyond Remastered Installer
:: License: MIT
title Vyond Remastered Installer [Initializing...]

::::::::::::::::::::
:: Initialization ::
::::::::::::::::::::

:: Stop commands from spamming stuff, cleans up the screen
@echo off && cls

:: Lets variables work or something idk im not a nerd
SETLOCAL ENABLEDELAYEDEXPANSION

::check for admin
set "params=%*"
cd /d "%~dp0" && ( if exist "%temp%\getadmin.vbs" del "%temp%\getadmin.vbs" ) && fsutil dirty query %systemdrive% 1>nul 2>nul || (  echo Set UAC = CreateObject^("Shell.Application"^) : UAC.ShellExecute "cmd.exe", "/k cd ""%~sdp0"" && %~s0 %params%", "", "runas", 1 >> "%temp%\getadmin.vbs" && "%temp%\getadmin.vbs" && exit /B )
)

:: Make sure we're starting in the correct folder
pushd "%~dp0"
:: Check *again* because it seems like sometimes it doesn't go into dp0 the first time???
pushd "%~dp0"

::::::::::::::::::::::
:: Dependency Check ::
::::::::::::::::::::::

title Vyond Remastered Installer [Checking for dependencies...]
echo Checking for dependencies...
echo:

:: Preload variables
set DEPENDENCIES_NEEDED=n
set GIT_DETECTED=n
set NODE_DETECTED=n
set HTTPSERVER_DETECTED=n
set FLASH_DETECTED=y

:: Git check
echo Checking for Git installation...
for /f "delims=" %%i in ('git --version 2^>nul') do set goutput=%%i
IF "!goutput!" EQU "" (
	echo Git could not be found.
	set DEPENDENCIES_NEEDED=y
) else (
	echo Git is installed.
	echo:
	set GIT_DETECTED=y
)

:: Node.JS check
echo Checking for Node.JS installation...
for /f "delims=" %%i in ('node -v 2^>nul') do set noutput=%%i
IF "!noutput!" EQU "" (
	echo Node.JS could not be found.
	set DEPENDENCIES_NEEDED=y
) else (
	echo Node.JS is installed.
	echo:
	set NODE_DETECTED=y
)

:: Flash check
echo Checking for Flash installation...
if exist "!windir!\SysWOW64\Macromed\Flash\*pepper.exe" set FLASH_DETECTED=y
if exist "!windir!\System32\Macromed\Flash\*pepper.exe" set FLASH_DETECTED=y
if !FLASH_DETECTED!==n (
	echo Flash could not be found.
	echo:
	set DEPENDENCIES_NEEDED=y
) else (
	echo Flash is installed.
	echo:
)

::::::::::::::::::::::::
:: Dependency Install ::
::::::::::::::::::::::::

if !DEPENDENCIES_NEEDED!==y (
	title Vyond Remastered Installer [Installing Dependencies...]
	echo:
	echo Installing dependencies...
	echo:

	set INSTALL_FLAGS=ALLUSERS=1 /norestart
	set SAFE_MODE=n
	if /i "!SAFEBOOT_OPTION!"=="MINIMAL" set SAFE_MODE=y
	if /i "!SAFEBOOT_OPTION!"=="NETWORK" set SAFE_MODE=y
	set CPU_ARCHITECTURE=what
	if /i "!processor_architecture!"=="x86" set CPU_ARCHITECTURE=32
	if /i "!processor_architecture!"=="AMD64" set CPU_ARCHITECTURE=64
	if /i "!PROCESSOR_ARCHITEW6432!"=="AMD64" set CPU_ARCHITECTURE=64
)

if !GIT_DETECTED!==n (
	cls
	echo Installing Git...
	echo:
	if not exist "git_installer.exe" (
		powershell -Command "Invoke-WebRequest https://github.com/git-for-windows/git/releases/download/v2.35.1.windows.2/Git-2.35.1.2-32-bit.exe -OutFile git_installer.exe"
	)
	echo Proper Git installation doesn't seem possible to do automatically.
	echo You can just keep clicking next until it finishes,
	echo and the V:R installer will continue once it closes.
	git_installer.exe
	goto git_installed
	
	:git_installed
	del git_installer.exe
	echo Git has been installed.
)

if !NODE_DETECTED!==n (	
	cls
	echo Installing Node.js...
	echo:
	:: Install Node.js
	if !CPU_ARCHITECTURE!==64 (
		if !VERBOSEWRAPPER!==y ( echo 64-bit system detected, installing 64-bit Node.js. )
		goto installnode64
	)
	if !CPU_ARCHITECTURE!==32 (
		if !VERBOSEWRAPPER!==y ( echo 32-bit system detected, installing 32-bit Node.js. )
		goto installnode32
	)
	if !CPU_ARCHITECTURE!==what (
		echo:
		echo Well, this is a little embarassing.
		echo Vyond Remastered can't tell if you're on a 32-bit or 64-bit system.
		echo Which means it doesn't know which version of Node.js to install...
		echo:
		echo If you have no idea what that means, press 1 to just try anyway.
		echo If you're in the future with newer architectures or something
		echo and you know what you're doing, then press 3 to keep going.
		echo:
		:architecture_ask
		set /p CPUCHOICE= Response:
		echo:
		if "!cpuchoice!"=="1" echo Attempting 32-bit Node.js installation. && goto installnode32
		if "!cpuchoice!"=="3" echo Node.js will not be installed. && goto after_nodejs_install
		echo You must pick one or the other.&& goto architecture_ask
	)

	:installnode64
	if not exist "node_installer_64.msi" (
		powershell -Command "Invoke-WebRequest https://nodejs.org/dist/v12.18.1/node-v12.18.1-x64.msi -OutFile node_installer_64.msi"
	)
	echo Proper Node.js installation doesn't seem possible to do automatically.
	echo You can just keep clicking next until it finishes, and Vyond Remastered will continue once it closes.
	msiexec /i "node_installer_64.msi" !INSTALL_FLAGS!
	del node_installer_64.msi
	goto nodejs_installed

	:installnode32
	if not exist "node_installer_32.msi" (
		powershell -Command "Invoke-WebRequest https://nodejs.org/dist/v12.18.1/node-v12.18.1-x86.msi -OutFile node_installer_32.msi"
	)
	echo Proper Node.js installation doesn't seem possible to do automatically.
	echo You can just keep clicking next until it finishes, and Vyond Remastered  will continue once it closes.
	msiexec /i "node_installer_32.msi" !INSTALL_FLAGS!
	del node_installer_32.msi
	goto nodejs_installed

	:nodejs_installed
	echo Node.js has been installed.
)

:after_nodejs_install

:: Flash Player
if !FLASH_DETECTED!==n (
	:start_flash_install
	echo Installing Flash Player...
	echo:

	echo To install Flash Player, Vyond Remastered must kill any currently running web browsers.
	echo Please make sure any work in your browser is saved before proceeding.
	echo Vyond Remastered will not continue installation until you press a key.
	echo:
	pause
	echo:

	:: Summon the Browser Slayer
	echo Rip and tear, until it is done.
	for %%i in (firefox,palemoon,iexplore,microsoftedge,chrome,chrome64,opera,brave) do (
		if !VERBOSEWRAPPER!==y (
			 taskkill /f /im %%i.exe /t
			 wmic process where name="%%i.exe" call terminate
		) else (
			 taskkill /f /im %%i.exe /t >nul
			 wmic process where name="%%i.exe" call terminate >nul
		)
	)
	:lurebrowserslayer
	cls
	echo:
	echo Starting Flash installer...
	if not exist "flash_windows_chromium.msi" (
		powershell -Command "Invoke-WebRequest http://wrapper-offline.ga/installer/flash_windows_chromium.msi -OutFile flash_windows_chromium.msi"
	)
	msiexec /i "flash_windows_chromium.msi" !INSTALL_FLAGS! /quiet

	echo Flash has been installed.
	del flash_windows_chromium.msi	
	echo:
)

if !DEPENDENCIES_NEEDED!==y (
	echo Dependencies installed. 
	start installer_windows.bat
	exit
)

:::::::::::::::::::::::::
:: Post-Initialization ::
:::::::::::::::::::::::::

title Vyond Remastered  Installer
:cls
cls

echo:
echo Vyond Remastered  Installer
echo A project from the Vyond Remastered team
echo:
echo Enter 1 to install
echo Enter 0 to close the installer
:wrapperidle
echo:

:::::::::::::
:: Choices ::
:::::::::::::

set /p CHOICE=Choice:
if "!choice!"=="0" goto exit
if "!choice!"=="1" goto downloadmain
:: funni options
if "!choice!"=="shut up" echo Nobody care and who aks && echo No cares
echo Time to choose. && goto wrapperidle

:downloadmain
cls
if not exist "Vyond-Remastered-main" (
	echo Cloning repository from GitHub...
	git clone https://github.com/DavidB2007/vyond-remastered-public.git
) else (
	echo You already have it installed apparently?
	echo If you're trying to install a different version make sure you remove the old folder.
	pause
)
goto npminstall

:downloadbeta
cls
if not exist "Vyond-Remastered-main" (
	echo Cloning repository from GitHub...
	git clone --single-branch --branch beta https://github.com/DavidB2007/vyond-remastered-public.git
) else (
	echo You already have it installed apparently?
	echo If you're trying to install a different version make sure you remove the old folder.
	pause
)
goto npminstall

:npminstall
cls
pushd Vyond-Remastered-main\wrapper
if not exist "package-lock.json" (
	echo Installing Node.JS packages...
	call npm install
) else (
	echo Node.JS packages already installed.
)
popd

:httpserverinstall
cls
npm list -g | findstr "http-server" >nul
if !errorlevel! == 0 (
	echo HTTP-Server already installed.
) else (
	echo Installing HTTP-Server...
	call npm install http-server -g
)

:certinstall
call certutil -addstore -f -enterprise -user root the.crt >nul
popd

:finish
cls
echo:
echo Vyond Remastered has been installed^^! Would you like to start it now?
echo:
echo Enter 1 to exit.
:finalidle
echo:

set /p CHOICE=Choice:
if "!choice!"=="1" goto exit
echo Time to choose. && goto finalidle

:folder
start "" "Vyond-Remastered-main"
pause & exit

:start
pushd Vyond-Remastered-main
start start_vyond.bat

:exit
pause & exit