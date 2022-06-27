@echo off

cd %~dp0
set MYPATH=%CD%
echo.

git checkout feat_vcpkg
git pull

rem F:/Scanner/G2/Dev/App/current/CS8 ...CSbadslam?
rem F:/Scanner/G2/Dev/3rdparty/vcpkg/vcpkg-export/
rem VCPKG-EXPORT=F:\Scanner\G2\Dev\3rdparty\vcpkg\vcpkg-export-28.06.2022
rem INSTALL_DIR= F:\Scanner\G2\Dev\App\current\install 
rem              F:/Scanner/G2/Dev/App/current/CSBadSlam/

rem set VCPKG_EXPORT=%MYPATH%\..\..\..\3rdparty\vcpkg\vcpkg-export
set CMAKE_GENERATOR=Ninja

set VCPKG_EXPORT="\vcpkg-export"
set INSTALL_DIR=%MYPATH%\..\install
set BADSLAM_DIR=\CSBadSlam

set QTOPENSSL=C:\Qt\Tools\OpenSSL\Win_x64\bin

echo 1.TRY WITH  %VCPKG_EXPORT%
if not exist %VCPKG_EXPORT% (
	set VCPKG_EXPORT=%MYPATH%\..\vcpkg-export 
)
echo 2.TRY WITH  %VCPKG_EXPORT%
if not exist %VCPKG_EXPORT% (
	set VCPKG_EXPORT=\vcpkg-export 
)

set USE_VS2022=0

echo --------------------
echo USING VCPKG_EXPORT %VCPKG_EXPORT%
echo USING INSTALL_DIR %INSTALL_DIR%
echo --------------------

rem https://github.com/facebookresearch/pytorch3d/issues/1227
rem https://github.com/NVIDIA/cub/tree/1.16.X


if exist         "C:\Program Files\Microsoft Visual Studio\2022\Community\Msbuild\Microsoft\VC\v150\BuildCustomizations" ( 
	echo check   "C:\Program Files\Microsoft Visual Studio\2022\Community\Msbuild\Microsoft\VC\v150\BuildCustomizations\CUDA 11.6.xml"
	if not exist "C:\Program Files\Microsoft Visual Studio\2022\Community\Msbuild\Microsoft\VC\v150\BuildCustomizations\CUDA 11.6.xml" ( 
		echo ERROR::: CUDA BUILD EXTENSIONS MISSING, PLEASE INSTALL \\DESKTOP-R6C2DTL\vcpkg-registry\packages\BuildCustomizations.7z
	)
)
if exist         "C:\Program Files\Microsoft Visual Studio\2022\Community\Msbuild\Microsoft\VC\v160\BuildCustomizations" ( 
	echo check   "C:\Program Files\Microsoft Visual Studio\2022\Community\Msbuild\Microsoft\VC\v160\BuildCustomizations\CUDA 11.6.xml"
	if not exist "C:\Program Files\Microsoft Visual Studio\2022\Community\Msbuild\Microsoft\VC\v160\BuildCustomizations\CUDA 11.6.xml" ( 
		echo ERROR::: CUDA BUILD EXTENSIONS MISSING, PLEASE INSTALL \\DESKTOP-R6C2DTL\vcpkg-registry\packages\BuildCustomizations.7z
	)
)
if exist         "C:\Program Files\Microsoft Visual Studio\2022\Community\Msbuild\Microsoft\VC\v170\BuildCustomizations" ( 
	echo check   "C:\Program Files\Microsoft Visual Studio\2022\Community\Msbuild\Microsoft\VC\v170\BuildCustomizations\CUDA 11.6.xml"
	if not exist "C:\Program Files\Microsoft Visual Studio\2022\Community\Msbuild\Microsoft\VC\v170\BuildCustomizations\CUDA 11.6.xml" ( 
		echo ERROR::: CUDA BUILD EXTENSIONS MISSING, PLEASE INSTALL \\DESKTOP-R6C2DTL\vcpkg-registry\packages\BuildCustomizations.7z
	)
)

if exist         "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Microsoft\VC\v150\BuildCustomizations" ( 
	echo check   "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Microsoft\VC\v150\BuildCustomizations\CUDA 11.6.xml"
	if not exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Microsoft\VC\v150\BuildCustomizations\CUDA 11.6.xml" ( 
		echo ERROR::: CUDA BUILD EXTENSIONS MISSING, PLEASE INSTALL \\DESKTOP-R6C2DTL\vcpkg-registry\packages\BuildCustomizations.7z
	)
)
if exist         "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Microsoft\VC\v160\BuildCustomizations" ( 
	echo check   "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Microsoft\VC\v160\BuildCustomizations\CUDA 11.6.xml"
	if not exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Microsoft\VC\v160\BuildCustomizations\CUDA 11.6.xml" ( 
		echo ERROR::: CUDA BUILD EXTENSIONS MISSING, PLEASE INSTALL \\DESKTOP-R6C2DTL\vcpkg-registry\packages\BuildCustomizations.7z
	)
)
echo "."

reg add "HKLM\SYSTEM\CurrentControlSet\Control\FileSystem" /v LongPathsEnabled /t REG_DWORD /d 1 /f

reg query "HKEY_LOCAL_MACHINE\SOFTWARE\NVIDIA Corporation\GPU Computing Toolkit\CUDA\v11.6" /v 64BitInstalled
if %ERRORLEVEL% NEQ 0 goto CUDA_11_6_VAR_INSTALLED
reg query "HKEY_LOCAL_MACHINE\SOFTWARE\NVIDIA Corporation\GPU Computing Toolkit\CUDA\v11.6" /v InstallDir
if %ERRORLEVEL% EQU 0 goto CUDA_11_6_VAR_INSTALLED
reg add   "HKEY_LOCAL_MACHINE\SOFTWARE\NVIDIA Corporation\GPU Computing Toolkit\CUDA\v11.6" /v InstallDir /t REG_SZ /d "C:\Program Files\NVIDIA GPU Computing Toolkit\CUDA\v11.6" /f
:CUDA_11_6_VAR_INSTALLED

rem set DEBUG_COMPILE="CONFIG+=debug"

if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" ( 
	set USE_VS2022=1
	call "C:\Program Files\Microsoft Visual Studio\2022\Community\VC\Auxiliary\Build\vcvarsall.bat" x64 
) else ( 
	if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" ( 
		call "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\VC\Auxiliary\Build\vcvarsall.bat" x64 
	) else ( 
		call "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\VC\Auxiliary\Build\vcvarsall.bat" x64 
	)
)

set MSDEVDIR="C:\Program Files (x86)\Microsoft Visual Studio 14.0"
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2017\Community" set MSDEVDIR="C:\Program Files (x86)\Microsoft Visual Studio\2017\Community"
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community" set MSDEVDIR="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community"
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community" set MSDEVDIR="C:\Program Files\Microsoft Visual Studio\2022\Community"
echo %MSDEVDIR%

set MSBUILDDIR="C:\Program Files (x86)\Microsoft Visual Studio\2017\Community\MSBuild\15.0\Bin"
if exist "C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin" set MSBUILDDIR="C:\Program Files (x86)\Microsoft Visual Studio\2019\Community\MSBuild\Current\Bin"
if exist "C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin" set MSBUILDDIR="C:\Program Files\Microsoft Visual Studio\2022\Community\MSBuild\Current\Bin"
echo 

set QTDIR="C:\Qt\5.15.0"
if exist  "C:\Qt\5.15.1" set QTDIR="C:\Qt\5.15.1"
if exist  "C:\Qt\5.15.2" set QTDIR="C:\Qt\5.15.2"
if exist  "C:\Qt\5.15.3" set QTDIR="C:\Qt\5.15.3"
echo %QTDIR%

set QTBIN=%QTDIR%\msvc2015_64\bin
if  exist %QTDIR%\msvc2019_64\bin set QTBIN=%QTDIR%\msvc2019_64\bin
echo %QTBIN%


if exist %VCPKG_EXPORT%\installed\x64-windows\include\qt5 set QTDIR=%VCPKG_EXPORT%\installed\x64-windows\include\qt5
if exist %VCPKG_EXPORT%\installed\x64-windows\bin set QTBIN=%VCPKG_EXPORT%\installed\x64-windows\bin
if exist %VCPKG_EXPORT%\installed\x64-windows\tools\openssl set QTOPENSSL=%VCPKG_EXPORT%\installed\x64-windows\tools\openssl

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

set TOOLCHAIN="%VCPKG_EXPORT%/scripts/buildsystems/vcpkg.cmake"
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

set VS_SEL=-G "Visual Studio 16 2019"
if %USE_VS2022% == 1 (
	set VS_SEL=-G "Visual Studio 17 2022"
) else (   
)   

rem cmake %VS_SEL% -DCMAKE_CUDA_ARCHITECTURES="61;75;86" -DCMAKE_TOOLCHAIN_FILE=%TOOLCHAIN% -A x64 -T cuda=11.6 -DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% -DBADSLAM_DIR=%BADSLAM_DIR% -DBADSLAM_BUILD_DIR=%BADSLAM_DIR%/build -DCMAKE_CUDA_ARCHITECTURES="75;86" -DWITH_REALSENSE=OFF ..
cmake .. %VS_SEL% -DCMAKE_CUDA_ARCHITECTURES="61;75" -DCMAKE_TOOLCHAIN_FILE=%TOOLCHAIN% -DWITH_REALSENSE=OFF -DWITH_K4A=OFF -DCMAKE_INSTALL_PREFIX=%INSTALL_DIR% -DBADSLAM_DIR=%BADSLAM_DIR% -DBADSLAM_BUILD_DIR=%BADSLAM_DIR%/build -A x64

if %COMPILE_DEBUG% == 0 (
	cmake --build . --target install --config Release -j
) else (
	if %COMPILE_DEBUG% == 1 (
		cmake --build . --target install --config Debug -j
	) else (
		if %COMPILE_DEBUG% == 2 (
			cmake --build . --target install --config RelWithDebInfo -j
		) else (
			if %COMPILE_DEBUG% == 3 (
				cmake --build . --target install --config MinSizeRel -j		
			) else (
				cmake --build . --target install --config Debug -j
				cmake --build . --target install --config Release -j
				cmake --build . --target install --config RelWithDebInfo -j
				cmake --build . --target install --config MinSizeRel -j
			)
		)
	)
)

cd %MYPATH%


