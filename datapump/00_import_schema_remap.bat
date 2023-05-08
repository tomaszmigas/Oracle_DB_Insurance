@echo off
rem  impdp ins/ins@xepdb3 PARFILE = parfile_schema.par
impdp 'sys@xepdb3 as sysdba' directory = ins_datapump dumpfile = INSURANCE_SCHEMA_2023-05-08__16_12_06.DMP logfile = import.log remap_schema = INS:INS