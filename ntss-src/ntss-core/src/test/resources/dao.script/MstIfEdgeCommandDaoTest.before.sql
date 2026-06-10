DELETE FROM mst_if_edge_command;

  INSERT INTO
    mst_if_edge_command
  (
    command_key
    ,command
    ,is_del
    ,reg_date
    ,up_date

  )
  VALUES
   (
     'start'
   , 'commandtest'
   , '0'
   , '2019-11-12 15:00:00'
   , '2019-11-12 15:00:00'
   );
INSERT INTO
    mst_if_edge_command
  (
    command_key
    ,command
    ,is_del
    ,reg_date
    ,up_date

  )
  VALUES
   (
     'end'
   , 'commandtest'
   , '1'
   , '2019-11-12 15:00:00'
   , '2019-11-12 15:00:00'
   );