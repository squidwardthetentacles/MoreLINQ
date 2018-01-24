@echo off
pushd "%~dp0"
call :main %*
popd
goto :EOF

:main
setlocal
for %%i in (dotnet.exe) do set dotnet=%%~dpnx$PATH:i
if "%dotnet%"=="" goto :nodotnet
if "%1"=="docs" shift & goto :docs
dotnet --info ^
  && dotnet restore ^
  && dotnet restore MoreLinq.NoConflictGenerator/MoreLinq.NoConflictGenerator.csproj ^
  && call :codegen MoreLinq\NoConflict.g.cs -x "[/\\](ToDataTable|Fold16\.g)\.cs$" -u System.Linq -u System.Collections MoreLinq ^
  && call :codegen MoreLinq\NoConflict.Fold.g.cs -i "[/\\]Fold16\.g\.cs$" -u System.Linq --no-class-lead MoreLinq ^
  && call :codegen MoreLinq\NoConflict.ToDataTable.g.cs -i "[/\\]ToDataTable\.cs$" -u System.Data -u System.Linq.Expressions MoreLinq ^
  && for %%i in (debug release) do call msbuild.cmd "MoreLinq.sln" /v:m /p:Configuration=%%i %* || exit /b 1
goto :EOF

:docs
call msbuild.cmd MoreLinq.shfbproj %1 %2 %3 %4 %5 %6 %7 %8 %9
goto :EOF

:nodotnet
echo>&2 dotnet executable not found in PATH
echo>&2 For more on dotnet, see https://www.microsoft.com/net/core
exit /b 2

:codegen
echo | set /p=Generating no-conflict wrappers (%1)...
dotnet run -p MoreLinq.NoConflictGenerator/MoreLinq.NoConflictGenerator.csproj -c Release -- %2 %3 %4 %5 %6 %7 %8 %9 > "%temp%\%~nx1" ^
  && move "%temp%\%~nx1" "%~dp1" > nul ^
  && echo Done.
goto :EOF
