@echo off
REM ====================================
REM Windows 本地构建脚本
REM ====================================

echo ==========================================
echo 机油销售管理系统 - 本地构建
echo ==========================================

REM 构建后端
echo.
echo [1/2] 构建后端...
cd backend
call mvn clean package -DskipTests
if %errorlevel% neq 0 (
    echo 后端构建失败！
    pause
    exit /b 1
)
echo 后端构建成功: backend\target\oil-system-1.0.0.jar
cd ..

REM 构建前端
echo.
echo [2/2] 构建前端...
cd frontend
call npm install
call npm run build
if %errorlevel% neq 0 (
    echo 前端构建失败！
    pause
    exit /b 1
)
echo 前端构建成功: frontend\dist\
cd ..

echo.
echo ==========================================
echo 构建完成！
echo ==========================================
echo 后端 JAR: backend\target\oil-system-1.0.0.jar
echo 前端文件: frontend\dist\
echo.
echo 下一步：
echo 1. 上传 backend\target\oil-system-1.0.0.jar 到服务器
echo 2. 上传 frontend\dist 目录到服务器
echo 3. 在服务器上运行部署脚本
echo ==========================================
pause
