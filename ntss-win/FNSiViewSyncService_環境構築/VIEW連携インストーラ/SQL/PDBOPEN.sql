set echo on
spool PDBOPEN.log
show pdbs
-- FNSIVIEW PDB OPEN
alter pluggable database fnsiview open;
-- FNSIVIEW PDB OPENó‘Ô‚ğƒZ[ƒu
alter pluggable database all save state;
spool off
exit

