
@echo off
setlocal EnableExtensions EnableDelayedExpansion

REM Folder with .tex figures (relative to where you run this .bat)
set "FIGS=figs"

REM Check tools on PATH
where pdflatex >nul 2>&1 || (echo [ERROR] pdflatex not found in PATH. Install MiKTeX or TeX Live, then reopen the shell.& exit /b 1)
where dvisvgm  >nul 2>&1 || (echo [ERROR] dvisvgm not found in PATH. Install via MiKTeX/TeX Live, then reopen the shell.& exit /b 1)

echo Processing directory: "%FIGS%"

REM Find .tex files; call subroutine per file
set "found="
for %%F in ("%FIGS%\*.tex") do (
  set "found=1"
  call :process "%%~fF"
)

if not defined found (
  echo No .tex files found in "%FIGS%". Nothing to do.
  goto :eof
)

echo(
echo Done.
goto :eof


:process
REM %~1 is the full path to the .tex file passed by the caller
set "FULL=%~1"
set "DIR=%~dp1"
set "NAME=%~nx1"
set "BASE=%~n1"

echo(
echo --- %NAME% ---

REM Enter the file's directory to avoid trailing-backslash and & issues
pushd "%DIR%" >nul 2>&1

set "TEX=%NAME%"
set "PDF=%BASE%.pdf"
set "SVG=%BASE%.svg"

REM 1) Compile to PDF in the current directory
pdflatex -interaction=batchmode -halt-on-error -output-directory "." "%TEX%"
if errorlevel 1 (
  echo [FAIL] pdflatex failed for %NAME%
  popd >nul 2>&1
  exit /b 1
)

REM 2) Convert PDF to SVG
dvisvgm --pdf --page=1 "%PDF%" -o "%SVG%"
if errorlevel 1 (
  echo [FAIL] dvisvgm failed for %NAME%
  popd >nul 2>&1
  exit /b 1
)

echo [OK]  %NAME% ^> %PDF%, %SVG%

REM Optional: clean up common LaTeX by-products
del /q "%BASE%.aux" "%BASE%.log" "%BASE%.out" "%BASE%.toc" >nul 2>&1

REM Return to the original directory
popd >nul 2>&1

exit /b 0