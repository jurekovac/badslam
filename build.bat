@echo off

cd %~dp0
set MYPATH=%CD%
echo.

rem set DEBUG_COMPILE="CONFIG+=debug"

if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" ( 
call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" x64 
) else ( 
call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" x64 
)

set MSDEVDIR="C:\Program Files (x86)\Microsoft Visual Studio 14.0"
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community" set MSDEVDIR="C:\Program Files (x86)\Microsoft Visual Studio\2017\Community"
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community" set MSDEVDIR="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community"
echo %MSDEVDIR%

set MSBUILDDIR="C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin"
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin" set MSBUILDDIR="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin"
echo %MSBUILDDIR%

set QTDIR="C:\Qt\5.15.0"
if exist  "C:\Qt\5.15.1" set QTDIR="C:\Qt\5.15.1"
if exist  "C:\Qt\5.15.2" set QTDIR="C:\Qt\5.15.2"
if exist  "C:\Qt\5.15.3" set QTDIR="C:\Qt\5.15.3"
echo %QTDIR%

set QTBIN=%QTDIR%\msvc2015_64\bin
if  exist %QTDIR%\msvc2019_64\bin set QTBIN=%QTDIR%\msvc2019_64\bin
echo %QTBIN%

set QTOPENSSL=%QTBIN%\Tools\OpenSSL\Win_x64\bin

if exist \vcpkg-export\installed\x64-windows\include\qt5 set QTDIR=\vcpkg-export\installed\x64-windows\include\qt5
if exist \vcpkg-export\installed\x64-windows\bin set QTBIN=\vcpkg-export\installed\x64-windows\bin
if exist \vcpkg-export\installed\x64-windows\tools\openssl set QTOPENSSL=\vcpkg-export\installed\x64-windows\tools\openssl

set QTROOT=%QTDIR%\..
set DEVENV=start /b /wait ""  devenv.com
set MSBUILD=start /b /wait "" %MSBUILDDIR%\msbuild.exe -maxcpucount:3 
set WRITEABLE=attrib -r
set DELETE=del /f /q /s 
set XCOPY=xcopy /Y /R /H /K /Q /C /D /S /I
set XCOPYDIR=xcopy /Y /D /Q /E /H /C /I
set RMDIR=rmdir /Q /S 
set PATH=%QTROOT%\Tools\QtCreator\bin\jom;%MSKITS%\bin\x64;%MSBUILDDIR%;%QTOPENSSL%;%PATH%

rem if exist build %RMDIR% build
if not exist build mkdir build
cd build

set TOOLCHAIN="/vcpkg-export/scripts/buildsystems/vcpkg.cmake"
set COMPILE_DEBUG=0
set COMPILE_KEYW="Release"

echo "%1"
if "%1"==""     set COMPILE_DEBUG=0
if "%1" NEQ ""  set COMPILE_DEBUG=1
if "%1" EQU "0" set COMPILE_DEBUG=0
if "%1" EQU "2" set COMPILE_DEBUG=2
if "%1" EQU "3" set COMPILE_DEBUG=3
if "%1" EQU "4" set COMPILE_DEBUG=4

if %COMPILE_DEBUG% == 0 set COMPILE_KEYW=Release
if %COMPILE_DEBUG% == 1 set COMPILE_KEYW=Debug
if %COMPILE_DEBUG% == 2 set COMPILE_KEYW=RelWithDebInfo
if %COMPILE_DEBUG% == 3 set COMPILE_KEYW=MinSizeRel
if %COMPILE_DEBUG% == 4 set COMPILE_KEYW=All

echo .
echo .
echo ================= COMPILE BADSLAM %COMPILE_KEYW% ======================
echo .
echo .

cmake -G "Visual Studio 16 2019" -DCMAKE_TOOLCHAIN_FILE=%TOOLCHAIN% -A x64 -T cuda=11.6 -DBADSLAM_DIR=/CSBadSlam -DBADSLAM_BUILD_DIR=/CSBadSlam/build -DCMAKE_CUDA_ARCHITECTURES="75;86"  ..

if %COMPILE_DEBUG% == 0 (
	cmake --build . --target install --config Release
) else (
	if %COMPILE_DEBUG% == 1 (
		cmake --build . --target install --config Debug
	) else (
		if %COMPILE_DEBUG% == 2 (
			cmake --build . --target install --config RelWithDebInfo
		) else (
			if %COMPILE_DEBUG% == 3 (
				cmake --build . --target install --config MinSizeRel			
			) else (
				cmake --build . --target install --config Debug
				cmake --build . --target install --config Release
				cmake --build . --target install --config RelWithDebInfo
				cmake --build . --target install --config MinSizeRel
			)
		)
	)
)

cd %MYPATH%


