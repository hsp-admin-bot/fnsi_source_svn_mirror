UPDATE "ntss"."mst_coop_facility"
SET if_edge_setting = if_edge_setting - 'check_connect_items'
    , up_date = CURRENT_TIMESTAMP
WHERE "ctl_no" IN (-701, -601, -501, -401, -301, -201, -101);
