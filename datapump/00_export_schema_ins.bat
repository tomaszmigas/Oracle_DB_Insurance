@echo off
SET HOUR=%time:~0,2%
SET dt1=%date:~-4%-%date:~3,2%-%date:~0,2%__0%time:~1,1%_%time:~3,2%_%time:~6,2%
SET dt2=%date:~-4%-%date:~3,2%-%date:~0,2%__%time:~0,2%_%time:~3,2%_%time:~6,2%
if "%HOUR:~0,1%" == " " (SET dtStamp=%dt1%) else (SET dtStamp=%dt2%)
SET plik_log=insurance_schema_%dtStamp%.log
SET plik_dmp=insurance_schema_%dtStamp%.dmp

expdp ins/ins@xepdb3 directory = ins_datapump dumpfile = %plik_dmp% logfile=%plik_log% schemas = INS