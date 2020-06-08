@ECHO OFF&@PUSHD %~DP0 &TITLE Win32Loader
setlocal enabledelayedexpansion
::Author MoeClub Modify By Lyhiving
color 87
cd.>%windir%\GetAdmin
if exist %windir%\GetAdmin (del /f /q "%windir%\GetAdmin") else (
echo CreateObject^("Shell.Application"^).ShellExecute "%~s0", "%*", "", "runas", 1 >> "%temp%\Admin.vbs"
"%temp%\Admin.vbs"
del /s /q "%temp%\Admin.vbs"
exit /b 2)
cls

echo * Init Win32Loader.
set download=0
set try_download=1
set URL=https://github.com/lyhiving/win2linux/raw/master

:InitCheck
mkdir "%SystemDrive%\win32-loader" >NUL 2>NUL
if exist "%SystemDrive%\Windows\System32\WindowsPowerShell" (
set use_ps=1
) else (
set use_ps=0
echo Not found PowerShell.
)

:Init
if %use_ps% equ 1 (
goto InitIt
) else (
goto InitFail
)

:InitIt
set try_download=0
call:DownloadFile "!URL!/g2ldr/g2ldr","%SystemDrive%\g2ldr"
call:DownloadFile "!URL!/g2ldr/g2ldr.mbr","%SystemDrive%\g2ldr.mbr"
call:DownloadFile "!URL!/g2ldr/pxe.lkrn","%SystemDrive%\win32-loader\pxe.lkrn"
call:DownloadFile "!URL!/g2ldr/grub.cfg","%SystemDrive%\win32-loader\grub.cfg"
goto InitDone

:InitFail
echo.
echo Go to "!URL!/g2ldr",
echo Please download them by yourself.
echo '%SystemDrive%\g2ldr'
echo '%SystemDrive%\g2ldr.mbr'
echo '%SystemDrive%\win32-loader\grub.cfg'
echo Press [ENTER] when you finished.
pause >NUL 2>NUL
goto InitDone

:InitDone
if !try_download! equ 0 (
set InitOption=InitFail
) else (
set InitOption=Init
)
if not exist "%SystemDrive%\g2ldr" goto !InitOption!
if not exist "%SystemDrive%\g2ldr.mbr" goto !InitOption!
if not exist "%SystemDrive%\win32-loader\grub.cfg" goto !InitOption!

:Image
echo.
echo * Please select initrd mode.
echo     [1] Online download
echo     [2] Local file
choice /n /c 12 /m Select:
if errorlevel 2 goto LocalMode
if errorlevel 1 goto OnlineMode
goto Image

:OnlineMode
echo.
echo * Please select source.
echo     [1] by Github [Linux](CentOS7, DHCP or VNC Support)
echo     [2] by Github [Linux](Debian8, DHCP or VNC Support)
echo     [3] by Github [Windows](Win7EMB, DHCP or VNC Support)
echo     [4] by Github [Windows](Win8.1EMB, DHCP or VNC Support)
echo     [5] by yourself
choice /n /c 12345 /m Select:
if errorlevel 5 goto Yourself
if errorlevel 4 goto Github_Win8.1EMB
if errorlevel 3 goto Github_Win7EMB
if errorlevel 2 goto Github_Debian
if errorlevel 1 goto Github
goto OnlineMode
:Yourself
echo.
echo if 'initrd.img' URL is 'http://mirrors.aliyun.com/centos/7/os/x86_64/images/pxeboot/initrd.img', 
echo Please input 'http://mirrors.aliyun.com/centos/7/os/x86_64/images/pxeboot'.
set /p IMG_URL_TMP=URL :
if defined IMG_URL_TMP (
set IMG_URL=%IMG_URL_TMP%
goto Download
) else (
goto Github
)
:Github_Win8.1EMB
set IMG_URL=https://github.com/lyhiving/win2linux/raw/master/loader/Win8.1EMB
set INITRD_SHA1=473617320316CCB5A88EDE72CBA6AF501B148071
set VMLINUZ_SHA1=C84BF89869868B0325F56F1C0E62604A83B9443F
goto Download
:Github_Win7EMB
set IMG_URL=https://github.com/lyhiving/win2linux/raw/master/loader/Win7EMB
set INITRD_SHA1=C1BF2A50802BC23A7EC7373AB4CB8F5A905D5860
set VMLINUZ_SHA1=C84BF89869868B0325F56F1C0E62604A83B9443F
goto Download
:Github
set IMG_URL=https://github.com/lyhiving/win2linux/raw/master/loader/CentOS
set INITRD_SHA1=934CFCD5DC855F360AE72AFCB8E6276FABFBCDD5
set VMLINUZ_SHA1=C84BF89869868B0325F56F1C0E62604A83B9443F
goto Download
:Github_Debian
set IMG_URL=https://github.com/lyhiving/win2linux/raw/master/loader/Debian
set INITRD_SHA1=934CFCD5DC855F360AE72AFCB8E6276FABFBCDD5
set VMLINUZ_SHA1=C84BF89869868B0325F56F1C0E62604A83B9443F
goto Download
:Download
if %use_ps% equ 1 (
echo.
echo Downloading 'initrd.img'...
call:DownloadFile "!IMG_URL!/initrd.img","%SystemDrive%\win32-loader\initrd.img"
call:CheckFile "%SystemDrive%\win32-loader\initrd.img"
call:CheckSUM "%SystemDrive%\win32-loader\initrd.img","%INITRD_SHA1%"
echo Downloading 'vmlinuz'...
call:DownloadFile "!IMG_URL!/vmlinuz","%SystemDrive%\win32-loader\vmlinuz"
call:CheckFile "%SystemDrive%\win32-loader\vmlinuz"
call:CheckSUM "%SystemDrive%\win32-loader\vmlinuz","%VMLINUZ_SHA1%"
set download=1
) else (
echo Not support online download, auto change Local initrd.
goto LocalMode
)

:LocalMode
if !download! equ 0 (
echo.
echo Please put 'initrd.img' and 'vmlinuz' to '%SystemDrive%\win32-loader' .
echo Press [ENTER] when you finished.
pause >NUL 2>NUL
)

:Done0
set download=0
if exist "%SystemDrive%\win32-loader\initrd.img" (
goto Done1
) else (
echo Not found '%SystemDrive%\win32-loader\initrd.img' .
goto LocalMode
)

:Done1
set download=0
if exist "%SystemDrive%\win32-loader\vmlinuz" (
goto Done
) else (
echo Not found '%SystemDrive%\win32-loader\vmlinuz' .
goto LocalMode
)

:Done
echo.
echo Press [ENTER] to continue...
echo Please CHECK IP SETTING '%SystemDrive%\win32-loader\grub.cfg' 
echo IT WILL REBOOT IMMEDIATELY
pause >NUL 2>NUL
echo.

set id={01234567-89ab-cdef-fedc-ba9876543210}
bcdedit /create %id% /d "Network Install CentOS 7" /application bootsector >NUL 2>NUL
bcdedit /set %id% device partition=%SystemDrive% >NUL 2>NUL
bcdedit /set %id% path \g2ldr.mbr >NUL 2>NUL
bcdedit /displayorder %id% /addlast >NUL 2>NUL
bcdedit /bootsequence %id% /addfirst >NUL 2>NUL
shutdown -r -t 0

:CheckSUM

GOTO:EOF

:CheckFile
if not exist %1 (
echo Not found %1 .
call:ErrorExit
)
GOTO:EOF

:DownloadFile
powershell.exe -command "& {$client = new-object System.Net.WebClient; $client.DownloadFile('%1','%2')}" >NUL 2>NUL
GOTO:EOF

:ErrorExit
echo. 
echo Error, Clear CACHE...
del /S /F /Q "%SystemDrive%\g2ldr" >NUL 2>NUL
del /S /F /Q "%SystemDrive%\g2ldr.mbr" >NUL 2>NUL
rd /S /Q "%SystemDrive%\win32-loader" >NUL 2>NUL
echo Press [ENTER] to exit.
pause >NUL 2>NUL
exit 1
GOTO:EOF