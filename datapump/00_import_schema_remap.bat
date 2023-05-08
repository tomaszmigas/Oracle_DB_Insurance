@echo off
rem  impdp ins/ins@xepdb3 PARFILE = parfile_schema.par
impdp 'sys@xepdb3 as sysdba' directory = ins_datapump dumpfile = insurance_schema_2023-05-08__09_25_12.dmp logfile = import.log remap_schema = INS:INS3