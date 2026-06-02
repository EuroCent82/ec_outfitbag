@echo off
set MYSQL=C:\laragon\bin\mysql\mysql-8.4.7-winx64\bin\mysql.exe
set SQL=%~dp0install.sql

"%MYSQL%" -h 127.0.0.1 -P 3306 -u root ESXLegacy_F9E16F < "%SQL%"
"%MYSQL%" -h 127.0.0.1 -P 3306 -u root QBCore_0E64EF < "%SQL%"
"%MYSQL%" -h 127.0.0.1 -P 3306 -u root Qbox_0E6853 < "%SQL%"
echo ec_outfitbag Tabellen importiert.
pause
