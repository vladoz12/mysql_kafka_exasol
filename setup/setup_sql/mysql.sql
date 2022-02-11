CREATE DATABASE IF NOT EXISTS connect_test;
USE connect_test;
set GLOBAL gtid_mode=OFF_PERMISSIVE;
set GLOBAL gtid_mode=ON_PERMISSIVE;
set GLOBAL enforce_gtid_consistency=ON;
set GLOBAL gtid_mode=ON;
set global binlog_rows_query_log_events=ON;
DROP TABLE IF EXISTS OLD_TABLE;
CREATE TABLE IF NOT EXISTS OLD_TABLE (
    id serial NOT NULL PRIMARY KEY,
    name varchar(100),
    email varchar(200),
    department varchar(200)
);