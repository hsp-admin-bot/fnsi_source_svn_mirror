UPDATE "mst_coop_distribute" 
SET distribute_setting = ( '{"protocolInfo":' || ( ( distribute_setting -> 'protocolInfo' ) - 'retryTime' ) :: TEXT || '}' ) :: jsonb
   , up_date = CURRENT_TIMESTAMP
WHERE
    ( ( distribute_setting ->> 'protocolInfo' ) :: JSON ) ->> 'protocol' IN ( 'socket', 'filesocket', 'headsocket', 'tshsocket' )
    AND ( ( distribute_setting ->> 'protocolInfo' ) :: JSON ) ->> 'retryTime' IS NOT NULL;

UPDATE "mst_coop_distribute" 
SET distribute_setting = ( '{"protocolInfo":' || ( ( distribute_setting -> 'protocolInfo' ) || ('{"retryInterval": 10}') :: jsonb) :: text || '}') :: jsonb
   , up_date = CURRENT_TIMESTAMP
WHERE
    ( ( distribute_setting ->> 'protocolInfo' ) :: JSON ) ->> 'protocol' IN ( 'socket', 'filesocket', 'headsocket', 'tshsocket' )
    AND ( ( distribute_setting ->> 'protocolInfo' ) :: JSON ) ->> 'retryInterval' IS NOT NULL;

UPDATE "mst_coop_distribute" 
SET distribute_setting = ( '{"protocolInfo":' || ( ( distribute_setting -> 'protocolInfo' ) || ('{"timeout": 60}') :: jsonb) :: text || '}') :: jsonb
   , up_date = CURRENT_TIMESTAMP
WHERE
    ( ( distribute_setting ->> 'protocolInfo' ) :: JSON ) ->> 'protocol' IN ( 'socket', 'filesocket', 'headsocket', 'tshsocket' );

UPDATE "mst_coop_distribute" 
SET distribute_setting = ( '{"protocolInfo":' || ( ( distribute_setting -> 'protocolInfo' ) || ('{"timeout": 60}') :: jsonb) :: text || '}') :: jsonb
   , up_date = CURRENT_TIMESTAMP
WHERE
    ( ( distribute_setting ->> 'protocolInfo' ) :: JSON ) ->> 'protocol' = 'soap';
