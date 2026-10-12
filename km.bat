@echo off
setlocal
cd /d "%~dp0"
title KM 密码管理 - 本地服务器

rem ============================================================
rem  KM 本地服务器启动脚本
rem
rem  用法：
rem    km.bat            以 8080 端口启动（默认）
rem    km.bat 8000       换一个端口启动
rem
rem  作用：
rem    以本目录为根启动一个 HTTP 服务器，再用浏览器打开
rem    http://localhost:8080/km.html
rem    这样 km.html 会自动载入同目录的 km.ini，不用每次手动导入。
rem
rem  说明：
rem    - 未安装 Python 时，退化为直接用 file:// 打开 km.html。
rem    - 服务器只监听 127.0.0.1，不对局域网开放；关闭本窗口即停止。
rem    - 设 KM_NO_BROWSER=1 可只启动服务器、不打开浏览器（调试用）。
rem
rem  注意：本文件必须保存为 GBK（cp936）编码 + CRLF 换行，
rem        cmd 才能正确解析其中的中文和行结构。
rem ============================================================

set "PORT=%~1"
if not defined PORT set "PORT=8080"

if not exist "%~dp0km.html" (
  echo [x] 未找到 km.html，请把本脚本与 km.html 放在同一目录。
  echo.
  pause
  exit /b 1
)

rem ---- 找一个可用的 Python ----
set "PY="
py -3 -c "import sys" >nul 2>&1
if not errorlevel 1 set "PY=py -3"
if defined PY goto pyfound
python -c "import sys" >nul 2>&1
if not errorlevel 1 set "PY=python"
if defined PY goto pyfound
python3 -c "import sys" >nul 2>&1
if not errorlevel 1 set "PY=python3"
:pyfound

if not defined PY (
  echo [!] 未检测到 Python，无法启动本地服务器。
  echo     改为直接用 file:// 打开 km.html。
  echo.
  echo     这种方式下页面不会自动载入 km.ini，需要先点「导入文件」
  echo     手动选择 km.ini；之后顶栏才会出现「保存」按钮，改动才能写回。
  echo.
  if not "%KM_NO_BROWSER%"=="1" start "" "%~dp0km.html"
  exit /b 0
)

echo ============================================================
echo   KM 密码管理 - 本地服务器
echo ============================================================
echo   目录： %~dp0
echo   地址： http://localhost:%PORT%/km.html
echo.
echo   页面会自动载入同目录的 km.ini（只读）。
echo   若要把改动写回 km.ini，请在页面里点「导入文件」重新选择该文件，
echo   之后顶栏会出现「保存」按钮。
echo.
echo   服务器只监听本机，关掉本窗口即停止。
echo ============================================================
echo.

rem 延迟约 1 秒再开浏览器，等服务器先起来，避免首次打开是连接错误页。
rem 这里用 ping 而不是 timeout：ping 不依赖 stdin，被重定向时仍能正常计时。
if not "%KM_NO_BROWSER%"=="1" (
  start "" /min cmd /c "ping -n 2 127.0.0.1 >nul & start http://localhost:%PORT%/km.html"
)

%PY% -m http.server %PORT% --bind 127.0.0.1

echo.
if errorlevel 1 echo [!] 服务器已退出。若提示端口被占用，换个端口重试即可，例如：km.bat 8000
echo 服务器已停止。
pause
endlocal
