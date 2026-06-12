\set ON_ERROR_STOP on

\echo [init] start all databases

\ir init_convert_db.sql
\ir init_ntss_db4.sql
\ir init_ntss_db5.sql
\ir init_ntss_db6.sql

\echo [init] all databases complete
