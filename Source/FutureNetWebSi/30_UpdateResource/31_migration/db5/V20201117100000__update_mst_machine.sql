update
  mst_machine
set
  machine_serial = trim(machine_serial)
where
  machine_serial like ' %'
or
  machine_serial like '% ';
