PUSHD .
FOR %%I IN (C:\WinDDK\7600.16385.1) DO CALL %%I\bin\setenv.bat %%I fre %Platform% WIN7 no_oacr
POPD

IF %_BUILDARCH%==x86 SET Lib=%Lib%\Crt\i386;%DDK_LIB_DEST%\i386;%Lib%
IF %_BUILDARCH%==AMD64 SET Lib=%Lib%\Crt\amd64;%DDK_LIB_DEST%\amd64;%Lib%

FOR %%I IN (C:\msys64\usr\bin\sed.exe) DO (

%%I -e "$a #undef Z7_DESTRUCTOR_override" -e "$a #define Z7_DESTRUCTOR_override" -i CPP\Common\Common.h

FOR %%J IN (CPP\Build.mak Build.mak) DO IF EXIST %%J (
	%%I "1i CFLAGS = $(CFLAGS) -D_LZMA_SIZE_OPT /GL /GS-" -i %%J

	FOR %%K IN (
		" -O2	 -O1"
		" -WX	 "
	) DO FOR /F "TOKENS=1,2 DELIMS=	" %%L IN (%%K) DO %%I "s@%%L@%%M@" -i %%J
)

FOR /F "DELIMS=" %%J IN ('DIR /B /S /A:D "SFXSetup" ^| %%I "s@%CD:\=\\\%\\\@@"') DO (
FOR /F "DELIMS=" %%K IN ('ECHO %%J^| %%I "s@[^\\]\+@..@g"') DO (

CD %%J
ECHO void __cpuid^( int cpuInfo[4], int function_id^);> intrin.h
FOR %%L IN (makefile makefile_con) DO IF EXIST %%L (
	FOR %%M IN (
		"7zVersion.rc"
		"MyVersionInfo.rc"
		"MY_VERSION_INFO_APP"
		"setup.ico"
	) DO %%I "/%%~M/d" -i resource.rc

	CALL :label %%L %%K
	%BUILD_MAKE_PROGRAM% /f %%L clean PLATFORM=%Platform%
)
CD %%K

)
)

)

GOTO :EOF

:label
%BUILD_MAKE_PROGRAM% /f %1 LFLAGS="/MANIFEST /MANIFESTUAC:level='requireAdministrator'" Include=%Include%;%CRT_INC_PATH%;%CD% PLATFORM=%Platform% MY_DYNAMIC_LINK=1
FOR %%I IN (%Platform%\*.sfx) DO (
	"C:\Program Files\Microsoft SDKs\Windows\v7.1\Bin\mt.exe" -manifest %%I.manifest -outputresource:%%I;1
	MOVE %%I %2
)
