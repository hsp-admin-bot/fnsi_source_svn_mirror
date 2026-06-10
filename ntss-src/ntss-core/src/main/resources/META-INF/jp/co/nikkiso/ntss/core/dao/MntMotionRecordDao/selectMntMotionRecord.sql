SELECT mnt.machine_serial                                                      -- 製造番号
    , mnt.machine_record_cd                                                   -- 装置記録コード
    --mod FNSI7367-自己診断結果の合格/不合格の集計が更新されない begin
     --mod FNSI7801-合格しているのにもかかわらず不合格としてカウントされる。 chen start
    , mnt.event_reg_date                                                            -- 登録日時
     --mod FNSI7801-合格しているのにもかかわらず不合格としてカウントされる。 chen end
    , mnt.up_date AS eventupdate                                              -- 更新日時
    --mod FNSI7367-自己診断結果の合格/不合格の集計が更新されない end
 FROM mnt_motion_record mnt                                                   -- 装置動作記録テーブル
INNER JOIN mst_machine_type mst                                               -- 型式マスタテーブル
   ON mnt.machine_type_cd = mst.machine_type_cd                               -- 型式コード
  AND mst.model BETWEEN '004' AND '005'                                       -- 機種
WHERE mnt.facility_cd = /*facilityCd*/NULL                                    -- 施設コード
  --mod FNSI7801-合格しているのにもかかわらず不合格としてカウントされる。 chen start
  AND mnt.event_reg_date >= /*startDate*/NULL                                       -- 登録日時
  AND mnt.event_reg_date <= /*endDate*/NULL                                         -- 登録日時
  --mod FNSI7801-合格しているのにもかかわらず不合格としてカウントされる。 chen end
  --AND mnt.machine_record_cd IN ('-   ', '-  ', '- ')                         -- 装置記録コード
  --AND mnt.machine_record_cd IN ('G100', 'G101', 'G102')                         -- 装置記録コード
  AND mnt.machine_record_cd IN /* montionRecordList */(null)
  --add FNSI7801-合格しているのにもかかわらず不合格としてカウントされる。 房 start
  ORDER BY mnt.machine_serial, mnt.event_reg_date DESC, mnt.up_date DESC
  --add FNSI7801-合格しているのにもかかわらず不合格としてカウントされる。 房 end
