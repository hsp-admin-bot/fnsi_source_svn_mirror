UPDATE "ntss"."mst_coop_facility"
SET if_edge_setting = (if_edge_setting :: jsonb) || (('{"timerLogUpload":{"send_time":"05:00","description": "アップロードログ時刻"}}') :: jsonb)
    , up_date = CURRENT_TIMESTAMP
WHERE "ctl_no" IN (-701, -601, -501, -401, -301, -201, -101);
