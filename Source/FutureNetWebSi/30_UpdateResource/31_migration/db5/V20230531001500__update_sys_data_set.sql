delete from sys_data_set where sql_cd in (-2280,-2300,-2420,-2430,-2440);
INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2440,'WITH  ntss_db5_mst_mr2 AS (
    SELECT
        ntss_db5_mst_mr.contents #>> ''{47}'' AS contents_47
        , ntss_db5_mst_mr.contents #>> ''{43}'' AS contents_43
        , ntss_db5_mst_mr.contents #>> ''{44}'' AS contents_44
        , ntss_db5_mst_mr.contents #>> ''{48}'' AS contents_48
        , ntss_db5_mst_mr.contents #>> ''{46}'' AS contents_46
        , ntss_db5_mst_mr.contents #>> ''{45}'' AS contents_45
        , ntss_db5_mst_mr.contents #>> ''{49}'' AS contents_49
        , ntss_db5_mst_m.machine_serial AS machine_serial
        , ntss_db5_mst_mr.machine_type_cd AS machine_type_cd
        , CASE WHEN ntss_db5_mst_mr.contents #>> ''{47}'' IS NOT NULL THEN ntss_db5_mst_mr.event_reg_date END AS event_reg_date
    FROM
        mst_machine ntss_db5_mst_m
        LEFT JOIN mnt_motion_record ntss_db5_mst_mr
            ON ntss_db5_mst_mr.machine_serial = ntss_db5_mst_m.machine_serial
    WHERE
        ntss_db5_mst_m.facility_cd = @facilityCd
        AND ntss_db5_mst_mr.test_type = ''1''
        AND ntss_db5_mst_mr.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
)
SELECT
    ntss_db5_mst_m.machine_no AS deviceno       --装置番号
    , ntss_db5_mst_m.machine_name AS devicename --装置名称
    , ntss_db5_mst_m.machine_serial AS deviceserial --製造番号
    , to_char(ntss_db5_mst_mr2.event_reg_date, ''YYYYMMDD'') AS meintedate --測定日付
    , to_char(ntss_db5_mst_mr2.event_reg_date, ''hh24mi'') AS meintetime --測定時刻
    , case
        when ntss_db5_mst_mr2.contents_47 = ''0001''
            then ''ＵＦＲＣ自己診断正常終了''
        when ntss_db5_mst_mr2.contents_47 = ''0002''
            then ''配管漏れ異常''
        when ntss_db5_mst_mr2.contents_47 = ''0003''
            then ''脱ガス器フロートＳＷ異常''
        when ntss_db5_mst_mr2.contents_47 = ''0004''
            then ''配管漏れ異常＆脱ガス器フロートＳＷ異常''
        when ntss_db5_mst_mr2.contents_47 = ''0005''
            then ''カスケードポンプ異常、またはＳＶ５閉塞''
        when ntss_db5_mst_mr2.contents_47 = ''0006''
            then ''配管漏れ異常＆カスケードポンプ異常、またはＳＶ５閉塞''
        when ntss_db5_mst_mr2.contents_47 = ''0007''
            then ''脱ガス器フロートＳＷ異常＆カスケードポンプ異常、またはＳＶ５閉塞''
        when ntss_db5_mst_mr2.contents_47 = ''0008''
            then ''配管漏れ異常＆脱ガス器フロートＳＷ異常＆カスケードポンプ異常、またはＳＶ５閉塞''
        when ntss_db5_mst_mr2.contents_47 = ''0009''
            then ''ＳＶ４異常''
        when ntss_db5_mst_mr2.contents_47 = ''000A''
            then ''透析液圧センサ異常''
        when ntss_db5_mst_mr2.contents_47 = ''000B''
            then ''バランス異常（－）''
        when ntss_db5_mst_mr2.contents_47 = ''000C''
            then ''バランス異常（＋）''
        when ntss_db5_mst_mr2.contents_47 = ''000D''
            then ''バランス温度異常''
        when ntss_db5_mst_mr2.contents_47 = ''000E''
            then ''除水異常''
        when ntss_db5_mst_mr2.contents_47 = ''000F''
            then ''バランス異常（－）＆除水異常''
        when ntss_db5_mst_mr2.contents_47 = ''0010''
            then ''バランス異常（＋）＆除水異常''
        when ntss_db5_mst_mr2.contents_47 = ''0011''
            then ''バランス温度異常＆除水異常''
        when ntss_db5_mst_mr2.contents_47 = ''0012''
            then ''給液圧センサ異常''
        when ntss_db5_mst_mr2.contents_47 = ''0013''
            then ''ＳＶ１２異常''
        when ntss_db5_mst_mr2.contents_47 = ''0014''
            then ''微粒子除去フィルター漏れ異常''
        when ntss_db5_mst_mr2.contents_47 = ''0015''
            then ''ＳＶ１０異常''
        when ntss_db5_mst_mr2.contents_47 = ''0016''
            then ''ＳＶ３異常''
        when ntss_db5_mst_mr2.contents_47 = ''0102''
            then ''配管漏れ異常''
        when ntss_db5_mst_mr2.contents_47 = ''0103''
            then ''脱ガス器フロートＳＷ異常''
        when ntss_db5_mst_mr2.contents_47 = ''0104''
            then ''配管漏れ異常＆脱ガス器フロートＳＷ異常''
        when ntss_db5_mst_mr2.contents_47 = ''0105''
            then ''カスケードポンプ異常、またはＳＶ３閉塞''
        when ntss_db5_mst_mr2.contents_47 = ''0106''
            then ''配管漏れ異常＆カスケードポンプ異常、またはＳＶ３閉塞''
        when ntss_db5_mst_mr2.contents_47 = ''0107''
            then ''脱ガス器フロートＳＷ異常＆カスケードポンプ異常、またはＳＶ３閉塞''
        when ntss_db5_mst_mr2.contents_47 = ''0108''
            then ''配管漏れ異常＆脱ガス器フロートＳＷ異常＆カスケードポンプ異常、またはＳＶ３閉塞''
        when ntss_db5_mst_mr2.contents_47 = ''0109''
            then ''ＳＶ２異常''
        when ntss_db5_mst_mr2.contents_47 = ''010A''
            then ''透析液圧センサ異常''
        when ntss_db5_mst_mr2.contents_47 = ''010B''
            then ''バランス異常（－）''
        when ntss_db5_mst_mr2.contents_47 = ''010C''
            then ''バランス異常（＋）''
        when ntss_db5_mst_mr2.contents_47 = ''010D''
            then ''バランス温度異常''
        when ntss_db5_mst_mr2.contents_47 = ''010E''
            then ''除水異常''
        when ntss_db5_mst_mr2.contents_47 = ''010F''
            then ''バランス異常（－）＆除水異常''
        when ntss_db5_mst_mr2.contents_47 = ''0110''
            then ''バランス異常（＋）＆除水異常''
        when ntss_db5_mst_mr2.contents_47 = ''0111''
            then ''バランス温度異常＆除水異常''
        when ntss_db5_mst_mr2.contents_47 = ''0112''
            then ''給液圧センサ異常''
        when ntss_db5_mst_mr2.contents_47 = ''0113''
            then ''ＳＶ７異常''
        when ntss_db5_mst_mr2.contents_47 = ''0114''
            then ''微粒子除去フィルター漏れ異常''
        when ntss_db5_mst_mr2.contents_47 = ''0115''
            then ''ＳＶ４異常''
        when ntss_db5_mst_mr2.contents_47 = ''0116''
            then ''ＳＶ５異常''
        when ntss_db5_mst_mr2.contents_47 = ''0201''
            then ''配管自己診断正常終了''
        when ntss_db5_mst_mr2.contents_47 = ''0202''
            then ''配管漏れ異常''
        when ntss_db5_mst_mr2.contents_47 = ''0203''
            then ''脱ガス器フロートＳＷ異常''
        when ntss_db5_mst_mr2.contents_47 = ''0204''
            then ''配管漏れ異常＆脱ガス器フロートＳＷ異常''
        when ntss_db5_mst_mr2.contents_47 = ''0205''
            then ''カスケードポンプ異常、またはＳＶ５閉塞''
        when ntss_db5_mst_mr2.contents_47 = ''0206''
            then ''配管漏れ異常＆カスケードポンプ異常、またはＳＶ５閉塞''
        when ntss_db5_mst_mr2.contents_47 = ''0207''
            then ''脱ガス器フロートＳＷ異常＆カスケードポンプ異常、またはＳＶ５閉塞''
        when ntss_db5_mst_mr2.contents_47 = ''0208''
            then ''配管漏れ異常＆脱ガス器フロートＳＷ異常＆カスケードポンプ異常、またはＳＶ５閉塞''
        when ntss_db5_mst_mr2.contents_47 = ''0209''
            then ''ＳＶ４異常''
        when ntss_db5_mst_mr2.contents_47 = ''020A''
            then ''透析液圧センサ異常''
        when ntss_db5_mst_mr2.contents_47 = ''020B''
            then ''バランス異常（－）''
        when ntss_db5_mst_mr2.contents_47 = ''020C''
            then ''バランス異常（＋）''
        when ntss_db5_mst_mr2.contents_47 = ''020D''
            then ''バランス温度異常''
        when ntss_db5_mst_mr2.contents_47 = ''020E''
            then ''除水異常''
        when ntss_db5_mst_mr2.contents_47 = ''020F''
            then ''バランス異常（－）＆除水異常''
        when ntss_db5_mst_mr2.contents_47 = ''0210''
            then ''バランス異常（＋）＆除水異常''
        when ntss_db5_mst_mr2.contents_47 = ''0211''
            then ''バランス温度異常＆除水異常''
        when ntss_db5_mst_mr2.contents_47 = ''0212''
            then ''給液圧センサ異常''
        when ntss_db5_mst_mr2.contents_47 = ''0213''
            then ''ＳＶ７異常''
        when ntss_db5_mst_mr2.contents_47 = ''0214''
            then ''微粒子除去フィルター漏れ異常''
        when ntss_db5_mst_mr2.contents_47 = ''0215''
            then ''ＳＶ７異常 and 除水異常''
        when ntss_db5_mst_mr2.contents_47 = ''0216''
            then ''微粒子除去フィルター漏れ and 除水異常''
        when ntss_db5_mst_mr2.contents_47 = ''0217''
            then ''ＳＶ２異常''
        when ntss_db5_mst_mr2.contents_47 = ''0218''
            then ''ＳＶ３異常''
        when ntss_db5_mst_mr2.contents_47 = ''0301''
            then ''配管自己診断正常終了''
        when ntss_db5_mst_mr2.contents_47 = ''0302''
            then ''透析液圧センサ テスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''0303''
            then ''減圧テスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''0307''
            then ''フロートスイッチテスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''0308''
            then ''ＳＶ７異常''
        when ntss_db5_mst_mr2.contents_47 = ''0309''
            then ''配管漏れ テスト（陰圧方式）不合格''
        when ntss_db5_mst_mr2.contents_47 = ''030A''
            then ''給水圧センサ テスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''030B''
            then ''熱交換器漏れテスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''030C''
            then ''配管漏れ テスト（陽圧方式）不合格''
        when ntss_db5_mst_mr2.contents_47 = ''030D''
            then ''除水ポンプ テスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''030E''
            then ''除水ポンプ リレーテスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''030F''
            then ''ＳＶ４１ テスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''0310''
            then ''ＣＦ漏れテスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''0311''
            then ''ヒータ電源遮断テスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''0312''
            then ''ＳＶ４締め切り検出器テスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''0313''
            then ''ＳＶ５締め切り検出器テスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''0314''
            then ''ＳＶ６締め切り検出器テスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''0315''
            then ''ＳＶ７締め切り検出器テスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''0316''
            then ''ＳＶ８締め切り検出器テスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''0317''
            then ''ＳＶ９締め切り検出器テスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''0318''
            then ''バランステスト不合格（－）''
        when ntss_db5_mst_mr2.contents_47 = ''0319''
            then ''バランステスト不合格（＋）''
        when ntss_db5_mst_mr2.contents_47 = ''031A''
            then ''バランステスト中の温度変化異常''
        when ntss_db5_mst_mr2.contents_47 = ''031B''
            then ''ＳＶ10締め切り検出器テスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''031C''
            then ''ＣＦ1漏れテスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''031D''
            then ''ＣＦ2漏れテスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''031E''
            then ''給液圧／透析液圧センサ比較テスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''031F''
            then ''ＳＶ３１締め切り検出器テスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''0320''
            then ''ＳＶ３１/３２リレーテスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''0321''
            then ''ＳＶ３2締め切り検出器テスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''0322''
            then ''CV32テスト不合格''
        when ntss_db5_mst_mr2.contents_47 = ''3001''
            then ''濃度自己診断結果(正常)''
        when ntss_db5_mst_mr2.contents_47 = ''3002''
            then ''濃度自己診断結果(バイカーボ濃度－１０％高異常)''
        when ntss_db5_mst_mr2.contents_47 = ''3003''
            then ''濃度自己診断結果(バイカーボ濃度－１０％低異常)''
        when ntss_db5_mst_mr2.contents_47 = ''3004''
            then ''濃度自己診断結果(バイカーボ濃度０％高異常)''
        when ntss_db5_mst_mr2.contents_47 = ''3005''
            then ''濃度自己診断結果(バイカーボ濃度０％低異常)''
        when ntss_db5_mst_mr2.contents_47 = ''3006''
            then ''濃度自己診断結果(透析液濃度－１０％高異常)''
        when ntss_db5_mst_mr2.contents_47 = ''3007''
            then ''濃度自己診断結果(透析液濃度－１０％低異常)''
        when ntss_db5_mst_mr2.contents_47 = ''3008''
            then ''濃度自己診断結果(透析液濃度０％高異常)''
        when ntss_db5_mst_mr2.contents_47 = ''3009''
            then ''濃度自己診断結果(透析液濃度０％低異常)''
        when ntss_db5_mst_mr2.contents_47 = ''3101''
            then ''正常''
        when ntss_db5_mst_mr2.contents_47 = ''3102''
            then ''濃度自己診断警報　Ｂ液下限''
        when ntss_db5_mst_mr2.contents_47 = ''3103''
            then ''濃度自己診断警報　Ｂ液上限''
        when ntss_db5_mst_mr2.contents_47 = ''3104''
            then ''濃度自己診断警報　透析液下限''
        when ntss_db5_mst_mr2.contents_47 = ''3105''
            then ''濃度自己診断警報　透析液上限''
        when ntss_db5_mst_mr2.contents_47 = ''3106''
            then ''濃度自己診断　測定不可''
        when ntss_db5_mst_mr2.contents_47 = ''3107''
            then ''濃度自己診断警報　B液下限＋透析液下限''
        when ntss_db5_mst_mr2.contents_47 = ''3108''
            then ''濃度自己診断警報　B液下限＋透析液上限''
        when ntss_db5_mst_mr2.contents_47 = ''3109''
            then ''濃度自己診断警報　B液上限＋透析液下限''
        when ntss_db5_mst_mr2.contents_47 = ''310A''
            then ''濃度自己診断警報　B液上限＋透析液上限''
        when ntss_db5_mst_mr2.contents_47 = ''310B''
            then ''濃度自己診断警報　B液下限＋濃度自己診断　測定不可''
        when ntss_db5_mst_mr2.contents_47 = ''310C''
            then ''濃度自己診断警報　B液上限＋濃度自己診断　測定不可''
        end AS meinteresult                     --配管自己診断結果
    , ntss_db5_mst_mr2.contents_43 AS meintegen --減圧テスト
    , ntss_db5_mst_mr2.contents_43 AS meintemore --配管系漏れ（陰圧)
    , ntss_db5_mst_mr2.contents_44 AS meinteymore --配管系漏れ（陽圧）
    , ntss_db5_mst_mr2.contents_48 AS meintejyo --除水テスト
    , ntss_db5_mst_mr2.contents_46 AS meintebara --バランステスト
    , ntss_db5_mst_mr2.contents_45 AS meinteetcf --ＣＦフィルタ漏れ
    , ntss_db5_mst_mr2.contents_49 AS meinteetcf2 --ＣＦ２フィルタ漏れ
FROM
    mst_machine ntss_db5_mst_m
    LEFT JOIN ntss_db5_mst_mr2
        ON ntss_db5_mst_mr2.machine_serial = ntss_db5_mst_m.machine_serial
        AND ntss_db5_mst_mr2.machine_type_cd = ntss_db5_mst_m.machine_type_cd
WHERE
    ntss_db5_mst_m.is_del = ''0''
    AND ntss_db5_mst_m.facility_cd = @facilityCd
    AND ntss_db5_mst_m.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL)
  , (-2300,'WITH ntss_db5_om_mnt_mr AS (

    SELECT

         ntss_db5_om.ord_no AS ord_no

        ,ntss_db5_om_mnt_mr.event_reg_date AS event_reg_date

        ,ntss_db5_om_mnt_mr.machine_record_cd

    FROM

        ntss.ord_main ntss_db5_om

        INNER JOIN ntss.mnt_motion_record ntss_db5_om_mnt_mr

        ON ntss_db5_om_mnt_mr.motion_record_no = ntss_db5_om.rst_machine_no

        AND ntss_db5_om_mnt_mr.machine_record_cd in (''F407'',''4000'')

    WHERE ntss_db5_om.facility_cd = @facilityCd

    AND ntss_db5_om.up_date BETWEEN to_timestamp( @fromDate, ''YYYYMMDDHH24MISS'' )

    AND to_timestamp( @toDate, ''YYYYMMDDHH24MISS'' )

)

SELECT

    ntss_db5_om.up_date

    ,'''' AS hosppatid --患者ID

    ,ntss_db5_om.pat_id AS patid

    ,ntss_db5_om.treat_date AS dialysisdate --透析日

    ,to_char(ntss_db5_om.rst_start_date, ''HH24MISS'') AS dialysistime --透析開始時刻

    ,CASE WHEN ntss_db5_om.rst_dialysis_state IN (''0'',''1'',''2'')

          THEN NULL

          WHEN ntss_db5_om.rst_dialysis_state IN (''3'',''4'',''5'',''6'')

          THEN to_char(ntss_db5_om.rec_set_date, ''YYYY-MM-DD hh24:mi:ss'')

      END AS startplandate --予定開始日時

    ,CASE WHEN ntss_db5_om.rst_cond_send_date IS NULL

          THEN ''0''

          ELSE ''1''

      END AS enterflg --入室フラグ（前体重測定）

    ,to_char(ntss_db5_om.rst_cond_send_date, ''YYYY-MM-DD hh24:mi:ss'') AS enterdate --初回入室日時

    ,CASE WHEN ntss_db5_om_mnt_mr.machine_record_cd = ''F407'' AND ntss_db5_om_mnt_mr.event_reg_date IS NULL

          THEN ''0''

          ELSE ''1''

      END AS machinecheckflg --透析装置確認フラグ

    ,CASE WHEN ntss_db5_om_mnt_mr.machine_record_cd = ''F407''

          THEN to_char(ntss_db5_om_mnt_mr.event_reg_date, ''YYYY-MM-DD hh24:mi:ss'')

          ELSE null

          END AS machinecheckdate --透析装置確認日時X

    ,CASE WHEN ntss_db5_om.rst_start_date IS NULL

          THEN ''0''

          ELSE ''1''

      END AS dialsisstartflg --透析運転開始フラグ

    ,to_char(ntss_db5_om.rst_start_date, ''YYYY-MM-DD hh24:mi:ss'') AS dialsissstartdate--透析運転開始日時

    ,CASE WHEN ntss_db5_om_mnt_mr.machine_record_cd = ''4000'' AND ntss_db5_om_mnt_mr.event_reg_date IS NULL

          THEN ''0''

          ELSE ''1''

      END AS offwaterflg --除水完了フラグ

    ,CASE WHEN ntss_db5_om_mnt_mr.machine_record_cd = ''4000''

          THEN to_char(ntss_db5_om_mnt_mr.event_reg_date, ''YYYY-MM-DD hh24:mi:ss'')

          ELSE null

          END AS offwaterdate --除水完了日時

    ,CASE WHEN ntss_db5_om.rst_end_date IS NULL

          THEN ''0''

          ELSE ''1''

      END AS wastefluidflg --排液フラグ

    ,to_char(ntss_db5_om.rst_end_date, ''YYYY-MM-DD hh24:mi:ss'') AS wastefluiddate --排液日時

    ,CASE WHEN ntss_db5_om.rst_weight_info #>> ''{weight_after_date}'' IS NULL

          THEN ''0''

          ELSE ''1''

      END AS weightafterflg --後体重測定

    ,to_char(CAST(ntss_db5_om.rst_weight_info #>> ''{weight_after_date}'' AS TIMESTAMP), ''YYYY-MM-DD hh24:mi:ss'') AS weightafterdate --後体重測定日時

    ,CASE WHEN ntss_db5_om.rec_set_date IS NULL

          THEN ''0''

          ELSE ''1''

      END AS recoverybtnflg --準備回収確認ボタンフラグ

    ,to_char(ntss_db5_om.rec_set_date, ''YYYY-MM-DD hh24:mi:ss'') AS recoverybtndate --準備回収確認ボタン日時

    ,to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --最終更新日時

FROM

    ntss.ord_main ntss_db5_om

    LEFT JOIN ntss_db5_om_mnt_mr

    ON ntss_db5_om_mnt_mr.ord_no = ntss_db5_om.ord_no

WHERE

    ntss_db5_om.is_del = ''0''

    AND ntss_db5_om.facility_cd = @facilityCd

    AND ntss_db5_om.up_date BETWEEN to_timestamp( @fromDate, ''YYYYMMDDHH24MISS'' )

    AND to_timestamp( @toDate, ''YYYYMMDDHH24MISS'' )

    AND ntss_db5_om.rst_weight_info IS NOT NULL

		AND ntss_db5_om.rst_start_date IS NOT NULL

		AND ntss_db5_om.pat_id IS NOT NULL;',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL)
  , (-2430,'WITH ntss_db5_mm AS (
			SELECT
				ntss_db5_om.ord_no AS ord_no
				,ntss_db5_mm.occur_date AS occur_date
				,ntss_db5_mm.monitor_data AS monitor_data
				,ntss_db5_mm.up_date AS up_date
			FROM
				ord_main ntss_db5_om
				LEFT JOIN mni_monitor ntss_db5_mm
				ON ntss_db5_mm.ord_no = ntss_db5_om.ord_no
			WHERE ntss_db5_mm.facility_cd = @facilityCd
				AND ntss_db5_mm.data_type = ''1''
				AND ntss_db5_mm.is_del = ''0''
				AND cast(ntss_db5_om.rst_dialysis_state AS integer) > 0
				AND ntss_db5_mm.occur_date BETWEEN to_timestamp( @fromDate, ''YYYYMMDDHH24MISS'' )
				AND to_timestamp( @toDate, ''YYYYMMDDHH24MISS'' )
		)
		SELECT
			ntss_db5_mst_b.bed_no AS bedno --ベッド番号
			,ntss_db5_mst_m.machine_no AS deviceno --装置番号
			,to_char(ntss_db5_mm.occur_date, ''YYYY-MM-DD hh24:mi:ss'') AS occurdate --発生日時
			,'''' AS hosppatid --患者ID
			,ntss_db5_om.pat_id AS patid
			,''1'' AS moniname1 --モニタ項目名1
			,ntss_db5_mm.monitor_data #>> ''{1}'' AS moniitem1 --モニタ項目値1
			,''2'' AS moniname2 --モニタ項目名2
			,ntss_db5_mm.monitor_data #>> ''{2}'' AS moniitem2 --モニタ項目値2
			,''3'' AS moniname3 --モニタ項目名3
			,ntss_db5_mm.monitor_data #>> ''{3}'' AS moniitem3 --モニタ項目値3
			,''4'' AS moniname4 --モニタ項目名4
			,ntss_db5_mm.monitor_data #>> ''{4}'' AS moniitem4 --モニタ項目値4
			,''5'' AS moniname5 --モニタ項目名5
			,ntss_db5_mm.monitor_data #>> ''{5}'' AS moniitem5 --モニタ項目値5
			,''6'' AS moniname6 --モニタ項目名6
			,ntss_db5_mm.monitor_data #>> ''{6}'' AS moniitem6 --モニタ項目値6
			,''7'' AS moniname7 --モニタ項目名7
			,ntss_db5_mm.monitor_data #>> ''{7}'' AS moniitem7 --モニタ項目値7
			,''8'' AS moniname8 --モニタ項目名8
			,ntss_db5_mm.monitor_data #>> ''{8}'' AS moniitem8 --モニタ項目値8
			,''9'' AS moniname9 --モニタ項目名9
			,ntss_db5_mm.monitor_data #>> ''{9}'' AS moniitem9 --モニタ項目値9
			,''10'' AS moniname10 --モニタ項目名10
			,ntss_db5_mm.monitor_data #>> ''{10}'' AS moniitem10 --モニタ項目値10
			,''11'' AS moniname11 --モニタ項目名11
			,ntss_db5_mm.monitor_data #>> ''{11}'' AS moniitem11 --モニタ項目値11
			,''12'' AS moniname12 --モニタ項目名12
			,ntss_db5_mm.monitor_data #>> ''{12}'' AS moniitem12 --モニタ項目値12
			,''13'' AS moniname13 --モニタ項目名13
			,ntss_db5_mm.monitor_data #>> ''{13}'' AS moniitem13 --モニタ項目値13
			,''14'' AS moniname14 --モニタ項目名14
			,ntss_db5_mm.monitor_data #>> ''{14}'' AS moniitem14 --モニタ項目値14
			,''15'' AS moniname15 --モニタ項目名15
			,ntss_db5_mm.monitor_data #>> ''{15}'' AS moniitem15 --モニタ項目値15
			,''16'' AS moniname16 --モニタ項目名16
			,ntss_db5_mm.monitor_data #>> ''{16}'' AS moniitem16 --モニタ項目値16
			,''17'' AS moniname17 --モニタ項目名17
			,ntss_db5_mm.monitor_data #>> ''{17}'' AS moniitem17 --モニタ項目値17
			,''18'' AS moniname18 --モニタ項目名18
			,ntss_db5_mm.monitor_data #>> ''{18}'' AS moniitem18 --モニタ項目値18
			,''19'' AS moniname19 --モニタ項目名19
			,ntss_db5_mm.monitor_data #>> ''{19}'' AS moniitem19 --モニタ項目値19
			,''20'' AS moniname20 --モニタ項目名20
			,ntss_db5_mm.monitor_data #>> ''{20}'' AS moniitem20 --モニタ項目値20
			,''21'' AS moniname21 --モニタ項目名21
			,ntss_db5_mm.monitor_data #>> ''{21}'' AS moniitem21 --モニタ項目値21
			,''22'' AS moniname22 --モニタ項目名22
			,ntss_db5_mm.monitor_data #>> ''{22}'' AS moniitem22 --モニタ項目値22
			,''23'' AS moniname23 --モニタ項目名23
			,ntss_db5_mm.monitor_data #>> ''{23}'' AS moniitem23 --モニタ項目値23
			,''24'' AS moniname24 --モニタ項目名24
			,ntss_db5_mm.monitor_data #>> ''{24}'' AS moniitem24 --モニタ項目値24
			,''25'' AS moniname25 --モニタ項目名25
			,ntss_db5_mm.monitor_data #>> ''{25}'' AS moniitem25 --モニタ項目値25
			,''26'' AS moniname26 --モニタ項目名26
			,ntss_db5_mm.monitor_data #>> ''{26}'' AS moniitem26 --モニタ項目値26
			,''27'' AS moniname27 --モニタ項目名27
			,ntss_db5_mm.monitor_data #>> ''{27}'' AS moniitem27 --モニタ項目値27
			,''28'' AS moniname28 --モニタ項目名28
			,ntss_db5_mm.monitor_data #>> ''{28}'' AS moniitem28 --モニタ項目値28
			,''29'' AS moniname29 --モニタ項目名29
			,ntss_db5_mm.monitor_data #>> ''{29}'' AS moniitem29 --モニタ項目値29
			,''30'' AS moniname30 --モニタ項目名30
			,ntss_db5_mm.monitor_data #>> ''{30}'' AS moniitem30 --モニタ項目値30
			,''31'' AS moniname31 --モニタ項目名31
			,ntss_db5_mm.monitor_data #>> ''{31}'' AS moniitem31 --モニタ項目値31
			,''32'' AS moniname32 --モニタ項目名32
			,ntss_db5_mm.monitor_data #>> ''{32}'' AS moniitem32 --モニタ項目値32
			,''33'' AS moniname33 --モニタ項目名33
			,ntss_db5_mm.monitor_data #>> ''{33}'' AS moniitem33 --モニタ項目値33
			,''34'' AS moniname34 --モニタ項目名34
			,ntss_db5_mm.monitor_data #>> ''{34}'' AS moniitem34 --モニタ項目値34
			,''35'' AS moniname35 --モニタ項目名35
			,ntss_db5_mm.monitor_data #>> ''{35}'' AS moniitem35 --モニタ項目値35
			,''36'' AS moniname36 --モニタ項目名36
			,ntss_db5_mm.monitor_data #>> ''{36}'' AS moniitem36 --モニタ項目値36
			,''37'' AS moniname37 --モニタ項目名37
			,ntss_db5_mm.monitor_data #>> ''{37}'' AS moniitem37 --モニタ項目値37
			,''38'' AS moniname38 --モニタ項目名38
			,ntss_db5_mm.monitor_data #>> ''{38}'' AS moniitem38 --モニタ項目値38
			,''39'' AS moniname39 --モニタ項目名39
			,ntss_db5_mm.monitor_data #>> ''{39}'' AS moniitem39 --モニタ項目値39
			,''40'' AS moniname40 --モニタ項目名40
			,ntss_db5_mm.monitor_data #>> ''{40}'' AS moniitem40 --モニタ項目値40
			,''41'' AS moniname41 --モニタ項目名41
			,ntss_db5_mm.monitor_data #>> ''{41}'' AS moniitem41 --モニタ項目値41
			,''42'' AS moniname42 --モニタ項目名42
			,ntss_db5_mm.monitor_data #>> ''{42}'' AS moniitem42 --モニタ項目値42
			,''43'' AS moniname43 --モニタ項目名43
			,ntss_db5_mm.monitor_data #>> ''{43}'' AS moniitem43 --モニタ項目値43
			,''44'' AS moniname44 --モニタ項目名44
			,ntss_db5_mm.monitor_data #>> ''{44}'' AS moniitem44 --モニタ項目値44
			,''45'' AS moniname45 --モニタ項目名45
			,ntss_db5_mm.monitor_data #>> ''{45}'' AS moniitem45 --モニタ項目値45
			,''46'' AS moniname46 --モニタ項目名46
			,ntss_db5_mm.monitor_data #>> ''{46}'' AS moniitem46 --モニタ項目値46
			,''47'' AS moniname47 --モニタ項目名47
			,ntss_db5_mm.monitor_data #>> ''{47}'' AS moniitem47 --モニタ項目値47
			,''48'' AS moniname48 --モニタ項目名48
			,ntss_db5_mm.monitor_data #>> ''{48}'' AS moniitem48 --モニタ項目値48
			,''49'' AS moniname49 --モニタ項目名49
			,ntss_db5_mm.monitor_data #>> ''{49}'' AS moniitem49 --モニタ項目値49
			,''50'' AS moniname50 --モニタ項目名50
			,ntss_db5_mm.monitor_data #>> ''{50}'' AS moniitem50 --モニタ項目値50
			,''51'' AS moniname51 --モニタ項目名51
			,ntss_db5_mm.monitor_data #>> ''{51}'' AS moniitem51 --モニタ項目値51
			,''52'' AS moniname52 --モニタ項目名52
			,ntss_db5_mm.monitor_data #>> ''{52}'' AS moniitem52 --モニタ項目値52
			,''53'' AS moniname53 --モニタ項目名53
			,ntss_db5_mm.monitor_data #>> ''{53}'' AS moniitem53 --モニタ項目値53
			,''54'' AS moniname54 --モニタ項目名54
			,ntss_db5_mm.monitor_data #>> ''{54}'' AS moniitem54 --モニタ項目値54
			,''55'' AS moniname55 --モニタ項目名55
			,ntss_db5_mm.monitor_data #>> ''{55}'' AS moniitem55 --モニタ項目値55
			,''56'' AS moniname56 --モニタ項目名56
			,ntss_db5_mm.monitor_data #>> ''{56}'' AS moniitem56 --モニタ項目値56
			,''57'' AS moniname57 --モニタ項目名57
			,ntss_db5_mm.monitor_data #>> ''{57}'' AS moniitem57 --モニタ項目値57
			,''58'' AS moniname58 --モニタ項目名58
			,ntss_db5_mm.monitor_data #>> ''{58}'' AS moniitem58 --モニタ項目値58
			,''59'' AS moniname59 --モニタ項目名59
			,ntss_db5_mm.monitor_data #>> ''{59}'' AS moniitem59 --モニタ項目値59
			,''60'' AS moniname60 --モニタ項目名60
			,ntss_db5_mm.monitor_data #>> ''{60}'' AS moniitem60 --モニタ項目値60
			,''61'' AS moniname61 --モニタ項目名61
			,ntss_db5_mm.monitor_data #>> ''{61}'' AS moniitem61 --モニタ項目値61
			,''62'' AS moniname62 --モニタ項目名62
			,ntss_db5_mm.monitor_data #>> ''{62}'' AS moniitem62 --モニタ項目値62
			,''63'' AS moniname63 --モニタ項目名63
			,ntss_db5_mm.monitor_data #>> ''{63}'' AS moniitem63 --モニタ項目値63
			,''64'' AS moniname64 --モニタ項目名64
			,ntss_db5_mm.monitor_data #>> ''{64}'' AS moniitem64 --モニタ項目値64
			,''65'' AS moniname65 --モニタ項目名65
			,ntss_db5_mm.monitor_data #>> ''{65}'' AS moniitem65 --モニタ項目値65
			,''66'' AS moniname66 --モニタ項目名66
			,ntss_db5_mm.monitor_data #>> ''{66}'' AS moniitem66 --モニタ項目値66
			,''67'' AS moniname67 --モニタ項目名67
			,ntss_db5_mm.monitor_data #>> ''{67}'' AS moniitem67 --モニタ項目値67
			,''68'' AS moniname68 --モニタ項目名68
			,ntss_db5_mm.monitor_data #>> ''{68}'' AS moniitem68 --モニタ項目値68
			,''69'' AS moniname69 --モニタ項目名69
			,ntss_db5_mm.monitor_data #>> ''{69}'' AS moniitem69 --モニタ項目値69
			,''70'' AS moniname70 --モニタ項目名70
			,ntss_db5_mm.monitor_data #>> ''{70}'' AS moniitem70 --モニタ項目値70
			,''71'' AS moniname71 --モニタ項目名71
			,ntss_db5_mm.monitor_data #>> ''{71}'' AS moniitem71 --モニタ項目値71
			,''72'' AS moniname72 --モニタ項目名72
			,ntss_db5_mm.monitor_data #>> ''{72}'' AS moniitem72 --モニタ項目値72
			,''73'' AS moniname73 --モニタ項目名73
			,ntss_db5_mm.monitor_data #>> ''{73}'' AS moniitem73 --モニタ項目値73
			,''74'' AS moniname74 --モニタ項目名74
			,ntss_db5_mm.monitor_data #>> ''{74}'' AS moniitem74 --モニタ項目値74
			,''75'' AS moniname75 --モニタ項目名75
			,ntss_db5_mm.monitor_data #>> ''{75}'' AS moniitem75 --モニタ項目値75
			,''76'' AS moniname76 --モニタ項目名76
			,ntss_db5_mm.monitor_data #>> ''{76}'' AS moniitem76 --モニタ項目値76
			,''77'' AS moniname77 --モニタ項目名77
			,ntss_db5_mm.monitor_data #>> ''{77}'' AS moniitem77 --モニタ項目値77
			,''78'' AS moniname78 --モニタ項目名78
			,ntss_db5_mm.monitor_data #>> ''{78}'' AS moniitem78 --モニタ項目値78
			,''79'' AS moniname79 --モニタ項目名79
			,ntss_db5_mm.monitor_data #>> ''{79}'' AS moniitem79 --モニタ項目値79
			,''80'' AS moniname80 --モニタ項目名80
			,ntss_db5_mm.monitor_data #>> ''{80}'' AS moniitem80 --モニタ項目値80
			,''81'' AS moniname81 --モニタ項目名81
			,ntss_db5_mm.monitor_data #>> ''{81}'' AS moniitem81 --モニタ項目値81
			,''82'' AS moniname82 --モニタ項目名82
			,ntss_db5_mm.monitor_data #>> ''{82}'' AS moniitem82 --モニタ項目値82
			,''83'' AS moniname83 --モニタ項目名83
			,ntss_db5_mm.monitor_data #>> ''{83}'' AS moniitem83 --モニタ項目値83
			,''84'' AS moniname84 --モニタ項目名84
			,ntss_db5_mm.monitor_data #>> ''{84}'' AS moniitem84 --モニタ項目値84
			,''85'' AS moniname85 --モニタ項目名85
			,ntss_db5_mm.monitor_data #>> ''{85}'' AS moniitem85 --モニタ項目値85
			,''86'' AS moniname86 --モニタ項目名86
			,ntss_db5_mm.monitor_data #>> ''{86}'' AS moniitem86 --モニタ項目値86
			,''87'' AS moniname87 --モニタ項目名87
			,ntss_db5_mm.monitor_data #>> ''{87}'' AS moniitem87 --モニタ項目値87
			,''88'' AS moniname88 --モニタ項目名88
			,ntss_db5_mm.monitor_data #>> ''{88}'' AS moniitem88 --モニタ項目値88
			,''89'' AS moniname89 --モニタ項目名89
			,ntss_db5_mm.monitor_data #>> ''{89}'' AS moniitem89 --モニタ項目値89
			,''90'' AS moniname90 --モニタ項目名90
			,ntss_db5_mm.monitor_data #>> ''{90}'' AS moniitem90 --モニタ項目値90
			,''91'' AS moniname91 --モニタ項目名91
			,ntss_db5_mm.monitor_data #>> ''{91}'' AS moniitem91 --モニタ項目値91
			,''92'' AS moniname92 --モニタ項目名92
			,ntss_db5_mm.monitor_data #>> ''{92}'' AS moniitem92 --モニタ項目値92
			,''93'' AS moniname93 --モニタ項目名93
			,ntss_db5_mm.monitor_data #>> ''{93}'' AS moniitem93 --モニタ項目値93
			,''94'' AS moniname94 --モニタ項目名94
			,ntss_db5_mm.monitor_data #>> ''{94}'' AS moniitem94 --モニタ項目値94
			,''95'' AS moniname95 --モニタ項目名95
			,ntss_db5_mm.monitor_data #>> ''{95}'' AS moniitem95 --モニタ項目値95
			,''96'' AS moniname96 --モニタ項目名96
			,ntss_db5_mm.monitor_data #>> ''{96}'' AS moniitem96 --モニタ項目値96
			,''97'' AS moniname97 --モニタ項目名97
			,ntss_db5_mm.monitor_data #>> ''{97}'' AS moniitem97 --モニタ項目値97
			,''98'' AS moniname98 --モニタ項目名98
			,ntss_db5_mm.monitor_data #>> ''{98}'' AS moniitem98 --モニタ項目値98
			,''99'' AS moniname99 --モニタ項目名99
			,ntss_db5_mm.monitor_data #>> ''{99}'' AS moniitem99 --モニタ項目値99
			,''100'' AS moniname100 --モニタ項目名100
			,ntss_db5_mm.monitor_data #>> ''{100}'' AS moniitem100 --モニタ項目値100
			,to_char(ntss_db5_mm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --発生日時
		FROM
			ord_main ntss_db5_om
			LEFT JOIN mst_bed ntss_db5_mst_b
			ON ntss_db5_mst_b.bed_cd = ntss_db5_om.rst_bed_cd
			LEFT JOIN mst_machine ntss_db5_mst_m
			ON cast(ntss_db5_mst_m.machine_type_cd AS integer) = ntss_db5_om.rst_machine_no
			INNER JOIN ntss_db5_mm
			ON ntss_db5_mm.ord_no = ntss_db5_om.ord_no
		WHERE ntss_db5_om.is_del = ''0''
			AND ntss_db5_mst_b.bed_no IS NOT NULL
			AND ntss_db5_om.facility_cd = @facilityCd
			AND ntss_db5_om.up_date BETWEEN to_timestamp( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_timestamp( @toDate, ''YYYYMMDDHH24MISS'' );',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL)
  , (-2420,'WITH ntss_db5_mm AS (
		SELECT * FROM (SELECT
			ntss_db5_mst_b.bed_no AS bed_no --ベッド番号
			,
			ntss_db5_mst_m.machine_no AS machine_no --装置番号
			,
			ntss_db5_om.pat_id AS pat_id,
			ntss_db5_mm.occur_date AS occur_date,
			ntss_db5_mm.monitor_data AS monitor_data,
			ntss_db5_mm.up_date AS up_date,
			ROW_NUMBER ( ) OVER (
				PARTITION BY ntss_db5_mst_b.bed_no,
				ntss_db5_mst_m.machine_no,
				ntss_db5_om.pat_id,
				ntss_db5_mm.occur_date,
				ntss_db5_mm.up_date
			ORDER BY
				ntss_db5_mm.up_date DESC
			) AS num
		FROM
			ord_main ntss_db5_om
			LEFT JOIN mst_bed ntss_db5_mst_b ON ntss_db5_mst_b.bed_cd = ntss_db5_om.rst_bed_cd
			LEFT JOIN mst_machine ntss_db5_mst_m ON CAST ( ntss_db5_mst_m.machine_no AS INTEGER ) = ntss_db5_om.rst_machine_no
			LEFT JOIN mni_monitor ntss_db5_mm ON ntss_db5_mm.ord_no = ntss_db5_om.ord_no
		WHERE
			ntss_db5_mm.facility_cd = @facilityCd
			AND ntss_db5_mst_b.bed_no IS NOT NULL
			AND ntss_db5_mm.data_type = ''1''
			AND ntss_db5_mm.is_del = ''0''
			AND ntss_db5_mm.occur_date BETWEEN to_timestamp( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_timestamp( @toDate, ''YYYYMMDDHH24MISS'' )) tb1
		WHERE tb1.num = 1
		)
		SELECT
			ntss_db5_mm.bed_no AS bedno --ベッド番号
			,ntss_db5_mm.machine_no AS deviceno --装置番号
 			,to_char(ntss_db5_mm.occur_date, ''YYYY-MM-DD hh24:mi:ss'') AS occurdate --発生日時
 			,'''' AS hosppatid --患者ID
 			,ntss_db5_mm.pat_id AS patid
			,''1'' AS moniname1 --モニタ項目名1
			,ntss_db5_mm.monitor_data #>> ''{1}'' AS moniitem1 --モニタ項目値1
			,''2'' AS moniname2 --モニタ項目名2
			,ntss_db5_mm.monitor_data #>> ''{2}'' AS moniitem2 --モニタ項目値2
			,''3'' AS moniname3 --モニタ項目名3
			,ntss_db5_mm.monitor_data #>> ''{3}'' AS moniitem3 --モニタ項目値3
			,''4'' AS moniname4 --モニタ項目名4
			,ntss_db5_mm.monitor_data #>> ''{4}'' AS moniitem4 --モニタ項目値4
			,''5'' AS moniname5 --モニタ項目名5
			,ntss_db5_mm.monitor_data #>> ''{5}'' AS moniitem5 --モニタ項目値5
			,''6'' AS moniname6 --モニタ項目名6
			,ntss_db5_mm.monitor_data #>> ''{6}'' AS moniitem6 --モニタ項目値6
			,''7'' AS moniname7 --モニタ項目名7
			,ntss_db5_mm.monitor_data #>> ''{7}'' AS moniitem7 --モニタ項目値7
			,''8'' AS moniname8 --モニタ項目名8
			,ntss_db5_mm.monitor_data #>> ''{8}'' AS moniitem8 --モニタ項目値8
			,''9'' AS moniname9 --モニタ項目名9
			,ntss_db5_mm.monitor_data #>> ''{9}'' AS moniitem9 --モニタ項目値9
			,''10'' AS moniname10 --モニタ項目名10
			,ntss_db5_mm.monitor_data #>> ''{10}'' AS moniitem10 --モニタ項目値10
			,''11'' AS moniname11 --モニタ項目名11
			,ntss_db5_mm.monitor_data #>> ''{11}'' AS moniitem11 --モニタ項目値11
			,''12'' AS moniname12 --モニタ項目名12
			,ntss_db5_mm.monitor_data #>> ''{12}'' AS moniitem12 --モニタ項目値12
			,''13'' AS moniname13 --モニタ項目名13
			,ntss_db5_mm.monitor_data #>> ''{13}'' AS moniitem13 --モニタ項目値13
			,''14'' AS moniname14 --モニタ項目名14
			,ntss_db5_mm.monitor_data #>> ''{14}'' AS moniitem14 --モニタ項目値14
			,''15'' AS moniname15 --モニタ項目名15
			,ntss_db5_mm.monitor_data #>> ''{15}'' AS moniitem15 --モニタ項目値15
			,''16'' AS moniname16 --モニタ項目名16
			,ntss_db5_mm.monitor_data #>> ''{16}'' AS moniitem16 --モニタ項目値16
			,''17'' AS moniname17 --モニタ項目名17
			,ntss_db5_mm.monitor_data #>> ''{17}'' AS moniitem17 --モニタ項目値17
			,''18'' AS moniname18 --モニタ項目名18
			,ntss_db5_mm.monitor_data #>> ''{18}'' AS moniitem18 --モニタ項目値18
			,''19'' AS moniname19 --モニタ項目名19
			,ntss_db5_mm.monitor_data #>> ''{19}'' AS moniitem19 --モニタ項目値19
			,''20'' AS moniname20 --モニタ項目名20
			,ntss_db5_mm.monitor_data #>> ''{20}'' AS moniitem20 --モニタ項目値20
			,''21'' AS moniname21 --モニタ項目名21
			,ntss_db5_mm.monitor_data #>> ''{21}'' AS moniitem21 --モニタ項目値21
			,''22'' AS moniname22 --モニタ項目名22
			,ntss_db5_mm.monitor_data #>> ''{22}'' AS moniitem22 --モニタ項目値22
			,''23'' AS moniname23 --モニタ項目名23
			,ntss_db5_mm.monitor_data #>> ''{23}'' AS moniitem23 --モニタ項目値23
			,''24'' AS moniname24 --モニタ項目名24
			,ntss_db5_mm.monitor_data #>> ''{24}'' AS moniitem24 --モニタ項目値24
			,''25'' AS moniname25 --モニタ項目名25
			,ntss_db5_mm.monitor_data #>> ''{25}'' AS moniitem25 --モニタ項目値25
			,''26'' AS moniname26 --モニタ項目名26
			,ntss_db5_mm.monitor_data #>> ''{26}'' AS moniitem26 --モニタ項目値26
			,''27'' AS moniname27 --モニタ項目名27
			,ntss_db5_mm.monitor_data #>> ''{27}'' AS moniitem27 --モニタ項目値27
			,''28'' AS moniname28 --モニタ項目名28
			,ntss_db5_mm.monitor_data #>> ''{28}'' AS moniitem28 --モニタ項目値28
			,''29'' AS moniname29 --モニタ項目名29
			,ntss_db5_mm.monitor_data #>> ''{29}'' AS moniitem29 --モニタ項目値29
			,''30'' AS moniname30 --モニタ項目名30
			,ntss_db5_mm.monitor_data #>> ''{30}'' AS moniitem30 --モニタ項目値30
			,''31'' AS moniname31 --モニタ項目名31
			,ntss_db5_mm.monitor_data #>> ''{31}'' AS moniitem31 --モニタ項目値31
			,''32'' AS moniname32 --モニタ項目名32
			,ntss_db5_mm.monitor_data #>> ''{32}'' AS moniitem32 --モニタ項目値32
			,''33'' AS moniname33 --モニタ項目名33
			,ntss_db5_mm.monitor_data #>> ''{33}'' AS moniitem33 --モニタ項目値33
			,''34'' AS moniname34 --モニタ項目名34
			,ntss_db5_mm.monitor_data #>> ''{34}'' AS moniitem34 --モニタ項目値34
			,''35'' AS moniname35 --モニタ項目名35
			,ntss_db5_mm.monitor_data #>> ''{35}'' AS moniitem35 --モニタ項目値35
			,''36'' AS moniname36 --モニタ項目名36
			,ntss_db5_mm.monitor_data #>> ''{36}'' AS moniitem36 --モニタ項目値36
			,''37'' AS moniname37 --モニタ項目名37
			,ntss_db5_mm.monitor_data #>> ''{37}'' AS moniitem37 --モニタ項目値37
			,''38'' AS moniname38 --モニタ項目名38
			,ntss_db5_mm.monitor_data #>> ''{38}'' AS moniitem38 --モニタ項目値38
			,''39'' AS moniname39 --モニタ項目名39
			,ntss_db5_mm.monitor_data #>> ''{39}'' AS moniitem39 --モニタ項目値39
			,''40'' AS moniname40 --モニタ項目名40
			,ntss_db5_mm.monitor_data #>> ''{40}'' AS moniitem40 --モニタ項目値40
			,''41'' AS moniname41 --モニタ項目名41
			,ntss_db5_mm.monitor_data #>> ''{41}'' AS moniitem41 --モニタ項目値41
			,''42'' AS moniname42 --モニタ項目名42
			,ntss_db5_mm.monitor_data #>> ''{42}'' AS moniitem42 --モニタ項目値42
			,''43'' AS moniname43 --モニタ項目名43
			,ntss_db5_mm.monitor_data #>> ''{43}'' AS moniitem43 --モニタ項目値43
			,''44'' AS moniname44 --モニタ項目名44
			,ntss_db5_mm.monitor_data #>> ''{44}'' AS moniitem44 --モニタ項目値44
			,''45'' AS moniname45 --モニタ項目名45
			,ntss_db5_mm.monitor_data #>> ''{45}'' AS moniitem45 --モニタ項目値45
			,''46'' AS moniname46 --モニタ項目名46
			,ntss_db5_mm.monitor_data #>> ''{46}'' AS moniitem46 --モニタ項目値46
			,''47'' AS moniname47 --モニタ項目名47
			,ntss_db5_mm.monitor_data #>> ''{47}'' AS moniitem47 --モニタ項目値47
			,''48'' AS moniname48 --モニタ項目名48
			,ntss_db5_mm.monitor_data #>> ''{48}'' AS moniitem48 --モニタ項目値48
			,''49'' AS moniname49 --モニタ項目名49
			,ntss_db5_mm.monitor_data #>> ''{49}'' AS moniitem49 --モニタ項目値49
			,''50'' AS moniname50 --モニタ項目名50
			,ntss_db5_mm.monitor_data #>> ''{50}'' AS moniitem50 --モニタ項目値50
			,''51'' AS moniname51 --モニタ項目名51
			,ntss_db5_mm.monitor_data #>> ''{51}'' AS moniitem51 --モニタ項目値51
			,''52'' AS moniname52 --モニタ項目名52
			,ntss_db5_mm.monitor_data #>> ''{52}'' AS moniitem52 --モニタ項目値52
			,''53'' AS moniname53 --モニタ項目名53
			,ntss_db5_mm.monitor_data #>> ''{53}'' AS moniitem53 --モニタ項目値53
			,''54'' AS moniname54 --モニタ項目名54
			,ntss_db5_mm.monitor_data #>> ''{54}'' AS moniitem54 --モニタ項目値54
			,''55'' AS moniname55 --モニタ項目名55
			,ntss_db5_mm.monitor_data #>> ''{55}'' AS moniitem55 --モニタ項目値55
			,''56'' AS moniname56 --モニタ項目名56
			,ntss_db5_mm.monitor_data #>> ''{56}'' AS moniitem56 --モニタ項目値56
			,''57'' AS moniname57 --モニタ項目名57
			,ntss_db5_mm.monitor_data #>> ''{57}'' AS moniitem57 --モニタ項目値57
			,''58'' AS moniname58 --モニタ項目名58
			,ntss_db5_mm.monitor_data #>> ''{58}'' AS moniitem58 --モニタ項目値58
			,''59'' AS moniname59 --モニタ項目名59
			,ntss_db5_mm.monitor_data #>> ''{59}'' AS moniitem59 --モニタ項目値59
			,''60'' AS moniname60 --モニタ項目名60
			,ntss_db5_mm.monitor_data #>> ''{60}'' AS moniitem60 --モニタ項目値60
			,''61'' AS moniname61 --モニタ項目名61
			,ntss_db5_mm.monitor_data #>> ''{61}'' AS moniitem61 --モニタ項目値61
			,''62'' AS moniname62 --モニタ項目名62
			,ntss_db5_mm.monitor_data #>> ''{62}'' AS moniitem62 --モニタ項目値62
			,''63'' AS moniname63 --モニタ項目名63
			,ntss_db5_mm.monitor_data #>> ''{63}'' AS moniitem63 --モニタ項目値63
			,''64'' AS moniname64 --モニタ項目名64
			,ntss_db5_mm.monitor_data #>> ''{64}'' AS moniitem64 --モニタ項目値64
			,''65'' AS moniname65 --モニタ項目名65
			,ntss_db5_mm.monitor_data #>> ''{65}'' AS moniitem65 --モニタ項目値65
			,''66'' AS moniname66 --モニタ項目名66
			,ntss_db5_mm.monitor_data #>> ''{66}'' AS moniitem66 --モニタ項目値66
			,''67'' AS moniname67 --モニタ項目名67
			,ntss_db5_mm.monitor_data #>> ''{67}'' AS moniitem67 --モニタ項目値67
			,''68'' AS moniname68 --モニタ項目名68
			,ntss_db5_mm.monitor_data #>> ''{68}'' AS moniitem68 --モニタ項目値68
			,''69'' AS moniname69 --モニタ項目名69
			,ntss_db5_mm.monitor_data #>> ''{69}'' AS moniitem69 --モニタ項目値69
			,''70'' AS moniname70 --モニタ項目名70
			,ntss_db5_mm.monitor_data #>> ''{70}'' AS moniitem70 --モニタ項目値70
			,''71'' AS moniname71 --モニタ項目名71
			,ntss_db5_mm.monitor_data #>> ''{71}'' AS moniitem71 --モニタ項目値71
			,''72'' AS moniname72 --モニタ項目名72
			,ntss_db5_mm.monitor_data #>> ''{72}'' AS moniitem72 --モニタ項目値72
			,''73'' AS moniname73 --モニタ項目名73
			,ntss_db5_mm.monitor_data #>> ''{73}'' AS moniitem73 --モニタ項目値73
			,''74'' AS moniname74 --モニタ項目名74
			,ntss_db5_mm.monitor_data #>> ''{74}'' AS moniitem74 --モニタ項目値74
			,''75'' AS moniname75 --モニタ項目名75
			,ntss_db5_mm.monitor_data #>> ''{75}'' AS moniitem75 --モニタ項目値75
			,''76'' AS moniname76 --モニタ項目名76
			,ntss_db5_mm.monitor_data #>> ''{76}'' AS moniitem76 --モニタ項目値76
			,''77'' AS moniname77 --モニタ項目名77
			,ntss_db5_mm.monitor_data #>> ''{77}'' AS moniitem77 --モニタ項目値77
			,''78'' AS moniname78 --モニタ項目名78
			,ntss_db5_mm.monitor_data #>> ''{78}'' AS moniitem78 --モニタ項目値78
			,''79'' AS moniname79 --モニタ項目名79
			,ntss_db5_mm.monitor_data #>> ''{79}'' AS moniitem79 --モニタ項目値79
			,''80'' AS moniname80 --モニタ項目名80
			,ntss_db5_mm.monitor_data #>> ''{80}'' AS moniitem80 --モニタ項目値80
			,''81'' AS moniname81 --モニタ項目名81
			,ntss_db5_mm.monitor_data #>> ''{81}'' AS moniitem81 --モニタ項目値81
			,''82'' AS moniname82 --モニタ項目名82
			,ntss_db5_mm.monitor_data #>> ''{82}'' AS moniitem82 --モニタ項目値82
			,''83'' AS moniname83 --モニタ項目名83
			,ntss_db5_mm.monitor_data #>> ''{83}'' AS moniitem83 --モニタ項目値83
			,''84'' AS moniname84 --モニタ項目名84
			,ntss_db5_mm.monitor_data #>> ''{84}'' AS moniitem84 --モニタ項目値84
			,''85'' AS moniname85 --モニタ項目名85
			,ntss_db5_mm.monitor_data #>> ''{85}'' AS moniitem85 --モニタ項目値85
			,''86'' AS moniname86 --モニタ項目名86
			,ntss_db5_mm.monitor_data #>> ''{86}'' AS moniitem86 --モニタ項目値86
			,''87'' AS moniname87 --モニタ項目名87
			,ntss_db5_mm.monitor_data #>> ''{87}'' AS moniitem87 --モニタ項目値87
			,''88'' AS moniname88 --モニタ項目名88
			,ntss_db5_mm.monitor_data #>> ''{88}'' AS moniitem88 --モニタ項目値88
			,''89'' AS moniname89 --モニタ項目名89
			,ntss_db5_mm.monitor_data #>> ''{89}'' AS moniitem89 --モニタ項目値89
			,''90'' AS moniname90 --モニタ項目名90
			,ntss_db5_mm.monitor_data #>> ''{90}'' AS moniitem90 --モニタ項目値90
			,''91'' AS moniname91 --モニタ項目名91
			,ntss_db5_mm.monitor_data #>> ''{91}'' AS moniitem91 --モニタ項目値91
			,''92'' AS moniname92 --モニタ項目名92
			,ntss_db5_mm.monitor_data #>> ''{92}'' AS moniitem92 --モニタ項目値92
			,''93'' AS moniname93 --モニタ項目名93
			,ntss_db5_mm.monitor_data #>> ''{93}'' AS moniitem93 --モニタ項目値93
			,''94'' AS moniname94 --モニタ項目名94
			,ntss_db5_mm.monitor_data #>> ''{94}'' AS moniitem94 --モニタ項目値94
			,''95'' AS moniname95 --モニタ項目名95
			,ntss_db5_mm.monitor_data #>> ''{95}'' AS moniitem95 --モニタ項目値95
			,''96'' AS moniname96 --モニタ項目名96
			,ntss_db5_mm.monitor_data #>> ''{96}'' AS moniitem96 --モニタ項目値96
			,''97'' AS moniname97 --モニタ項目名97
			,ntss_db5_mm.monitor_data #>> ''{97}'' AS moniitem97 --モニタ項目値97
			,''98'' AS moniname98 --モニタ項目名98
			,ntss_db5_mm.monitor_data #>> ''{98}'' AS moniitem98 --モニタ項目値98
			,''99'' AS moniname99 --モニタ項目名99
			,ntss_db5_mm.monitor_data #>> ''{99}'' AS moniitem99 --モニタ項目値99
			,''100'' AS moniname100 --モニタ項目名100
			,ntss_db5_mm.monitor_data #>> ''{100}'' AS moniitem100 --モニタ項目値100
			,to_char(ntss_db5_mm.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --発生日時
		FROM
			ntss_db5_mm',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL)
  , (-2280,'SELECT

	'''' AS hosppatid --患者ID

	,ntss_db5_pem.pat_id AS patid

	,to_char(ntss_db5_pem.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時

	,ntss_db5_pem.reg_exam_date

	,to_char(ntss_db5_pem.reg_exam_date, ''YYYYMMDD'') AS examdate --検査予定日

	,to_char(ntss_db5_pem.reg_exam_date, ''hh24mi'') AS examtime --検査予定時刻

	,ntss_db5_pem_mst_ei.in_hospital_cd1 AS examsetcd --検査セットNo(院内コード)

	,ntss_db5_pem_oesi_json ->> ''set_name'' AS examsetname --検査セット名称

	,ntss_db5_pem.reg_order_class AS examdivision --検査予定区分

	,ntss_db5_pem.exam_status AS examproccd --検査実施予定コード

	,'''' AS doctorcode --指示者

	,ntss_db5_pem.ind_user_id AS userid

	,'''' AS doctorname --指示者名

	,'''' AS doctorcode --オーダー入力者

	,ntss_db5_pem.up_staff AS userid

	,'''' AS doctorname --オーダ入力者名

	,'''' AS doctorcode --更新者

	,'''' AS doctorname --更新者名

	,ntss_db5_pem.facility_cd

	,ntss_db5_pem.up_date

FROM

	pat_exam_main ntss_db5_pem

	CROSS JOIN LATERAL json_array_elements(ntss_db5_pem.order_exam_set_info::json) ntss_db5_pem_oesi_json

	LEFT JOIN mst_exam_set ntss_db5_pem_mst_ei

	ON ntss_db5_pem_mst_ei.exam_set_cd = cast(ntss_db5_pem_oesi_json ->> ''set_cd'' AS integer)

WHERE

	ntss_db5_pem.is_del = ''0''

	AND ntss_db5_pem.facility_cd = @facilityCd

	AND ntss_db5_pem.up_date BETWEEN to_timestamp( @fromDate, ''YYYYMMDDHH24MISS'' )

	AND to_timestamp( @toDate, ''YYYYMMDDHH24MISS'' )

	AND ntss_db5_pem.order_exam_set_info IS NOT NULL

	AND ntss_db5_pem.order_exam_set_info <> ''[]''

	AND ntss_db5_pem_mst_ei.in_hospital_cd1 IS NOT NULL;',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);
