DELETE FROM "ntss"."sys_data_set" where sql_cd in (-2420);

INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2420,'WITH ntss_db5_mm AS (
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
			AND(
				CASE
						WHEN @syncMode = ''update''
									THEN (
											ntss_db5_mst_b.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
									)
									OR (
											ntss_db5_mst_m.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
									)
									OR (
											ntss_db5_om.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
									)
									OR (
											ntss_db5_mm.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
									)
									ELSE
											ntss_db5_mm.occur_date BETWEEN to_timestamp( @fromDate, ''YYYYMMDDHH24MISS'' )
											AND to_timestamp( @toDate, ''YYYYMMDDHH24MISS'' )
									 end
									)) tb1
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
			ntss_db5_mm',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);

DELETE FROM "ntss"."sys_data_set" where sql_cd in (-2170);

INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2170,'with ntss_db5_om_1 as (
    SELECT
        array_agg(ntss_db5_om_1.ord_no) AS arr_ord_no
        , ntss_db5_om_1.pat_id
        , ntss_db5_om_1.treat_date AS treat_date
        , COUNT(ntss_db5_om_1.treat_date) AS treat_date_count
    FROM
        ord_main ntss_db5_om_1
    WHERE
        ntss_db5_om_1.is_del = ''0''
        AND ntss_db5_om_1.facility_cd = @facilityCd
    GROUP BY
        ntss_db5_om_1.pat_id
        , ntss_db5_om_1.treat_date
)
SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , ntss_db5_os.treat_date AS dialysisdate    --透析日
    , ntss_db5_om.ord_no AS bedno               --ベッド番号
    , ntss_db5_om_mst_b.bed_name AS bedname     --ベッド名
    , ntss_db5_om_mst_k.in_hospital_cd_1 AS kurcd --クールコード
    , ntss_db5_om.rst_kur_name AS kurname       --クール名
    , CASE
        WHEN ntss_db5_om_1.treat_date_count > 1
            THEN 1
        ELSE 0
        END AS plural                           --同日複数回
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
    , ntss_db5_om.ord_no AS resultdialysisno    --実績透析番号
    , CASE
        WHEN ntss_db5_om.treat_type = 0
            THEN 1
        ELSE 0
        END AS opeindplan                       --予定作成区分
    , ntss_db5_os.is_dummy AS dummyflg          --ダミーフラグ
    , to_char(ntss_db5_om.rst_start_date, ''hh24:mi'') AS starttime --透析開始時刻
FROM
    ord_main ntss_db5_om
    INNER JOIN ntss_db5_om_1
        ON ntss_db5_om.ord_no = ANY (ntss_db5_om_1.arr_ord_no)
    LEFT JOIN ord_schedule ntss_db5_os
        ON ntss_db5_os.pat_id = ntss_db5_om.pat_id
        AND ntss_db5_os.ord_no = ntss_db5_om.ord_no
    LEFT JOIN mst_bed ntss_db5_om_mst_b
        ON ntss_db5_om_mst_b.bed_cd = ntss_db5_os.bed_cd
    LEFT JOIN mst_kur ntss_db5_om_mst_k
        ON ntss_db5_om_mst_k.kur_cd = ntss_db5_om.rst_kur_cd
WHERE
    ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.facility_cd = @facilityCd
    AND (
        CASE
            WHEN @syncMode = ''update''
                THEN (
                ntss_db5_om.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
            )
            OR (
                ntss_db5_os.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
            )
            OR (
                ntss_db5_om_mst_b.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
            )
            OR (
                ntss_db5_om_mst_k.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
            )
            ELSE ntss_db5_os.treat_date BETWEEN SUBSTR(@fromDate, 0, 9) AND SUBSTR(@toDate, 0, 9)
            END
    )
    AND ntss_db5_om_mst_k.in_hospital_cd_1 IS NOT NULL
    AND ntss_db5_os.treat_date IS NOT NULL;
',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);


DELETE FROM "ntss"."sys_data_set" where sql_cd in (-2180);

INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2180,'with ntss_db5_om_1 as (
    SELECT
        main.ord_no
        , main.ind_kur_cd
        , main.up_date
        , main.treat_type
        , main.ind_treat_start_time
        , subMain.pat_id
        , subMain.treat_date
        , subMain.treat_date_count
    FROM
        ord_main main
        INNER JOIN (
            SELECT
                array_agg(ntss_db5_om_1.ord_no) AS arr_ord_no
                , ntss_db5_om_1.pat_id
                , ntss_db5_om_1.treat_date AS treat_date
                , COUNT(ntss_db5_om_1.treat_date) AS treat_date_count
            FROM
                ord_main ntss_db5_om_1
            WHERE
                ntss_db5_om_1.facility_cd = @facilityCd
                AND ntss_db5_om_1.is_del = ''0''
                AND ntss_db5_om_1.pat_id IS NOT NULL
            GROUP BY
                ntss_db5_om_1.pat_id
                , ntss_db5_om_1.treat_date
        ) AS subMain
            ON main.ord_no = ANY (subMain.arr_ord_no)
)
SELECT
    '''' AS hosppatid
    , ntss_db5_om_1.pat_id AS patid             --患者ID
    , ntss_db5_os.treat_date AS dialysisdate    --透析日
    , ntss_db5_os.ord_no AS bedno               --ベッド番号
    , ntss_db5_om_mst_b.bed_name AS bedname     --ベッド名
    , ntss_db5_om_mst_k.kur_cd AS kurcd         --クールコード
    , ntss_db5_om_mst_k.kur_name AS kurname     --クール名
    , CASE
        WHEN ntss_db5_om_1.treat_date_count > 1
            THEN 1
        ELSE 0
        END AS plural                           --同日複数回
    , to_char(ntss_db5_om_1.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
    , ntss_db5_om_1.ord_no AS resultdialysisno  --実績透析番号
    , CASE
        WHEN ntss_db5_om_1.treat_type = 0
            THEN 1
        ELSE 0
        END AS opeindplan                       --予定作成区分
    , ntss_db5_os.is_dummy AS dummyflg          --ダミーフラグ
    , ntss_db5_om_1.ind_treat_start_time
    , ntss_db5_om_mst_k.kur_start_time
    , CASE
        WHEN ntss_db5_om_1.ind_treat_start_time IS NOT NULL
            THEN to_char(
            ntss_db5_om_1.ind_treat_start_time ::time
            , ''hh24:mi''
        )
        WHEN ntss_db5_om_mst_k.kur_start_time IS NOT NULL
            THEN to_char(
            ntss_db5_om_mst_k.kur_start_time ::time
            , ''hh24:mi''
        )
        ElSE ''未登録''
        END AS starttime                        --透析開始時刻
FROM
    ntss_db5_om_1
    LEFT JOIN ord_schedule ntss_db5_os
        ON ntss_db5_os.pat_id = ntss_db5_om_1.pat_id
        AND ntss_db5_os.ord_no = ntss_db5_om_1.ord_no
    LEFT JOIN mst_bed ntss_db5_om_mst_b
        ON ntss_db5_om_mst_b.bed_cd = ntss_db5_os.bed_cd
    LEFT JOIN mst_kur ntss_db5_om_mst_k
        ON ntss_db5_om_mst_k.kur_cd = ntss_db5_om_1.ind_kur_cd
WHERE
    (
        CASE
            WHEN @syncMode = ''update''
                THEN (
                ntss_db5_om_1.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
            )
            OR (
                ntss_db5_os.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
            )
						OR (
                ntss_db5_om_mst_b.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
            )
						OR (
                ntss_db5_om_mst_k.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
            )
            ELSE ntss_db5_os.treat_date BETWEEN SUBSTR(@fromDate, 0, 9) AND SUBSTR(@toDate, 0, 9)
            END
    )
    AND ntss_db5_os.treat_date IS NOT NULL
    AND ntss_db5_om_mst_k.kur_cd IS NOT NULL;
',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);

DELETE FROM "ntss"."sys_data_set" where sql_cd in (-2164);

INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2164,'SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , ntss_db5_os.treat_date AS dialysisdate    --透析日
    , ntss_db5_om.ord_no AS dialysisno          --透析番号
    , row_number() over (ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
    , ''1'' AS division                           --レセプトメモ区分
    , ntss_db5_mst_a.in_hospital_cd_1 AS codes  --コード
    , to_char(ntss_db5_mst_a.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS codeupdate --コード更新日時
    , ''1'' AS addflg                             --加算有無
    , ntss_db5_mst_a.addition_name AS itemname  --項目名称
    , '''' AS maindialdiff                        --主たる透析困難
    , ntss_db5_mst_a.in_hospital_cd_1 AS inhospitalcd --院内コード
    , ntss_db5_mst_a.in_hospital_cd_2 AS inhospitalcd2 --院内コード２
FROM
    ord_main ntss_db5_om
    CROSS JOIN LATERAL json_array_elements(ntss_db5_om.addition_info ::json) ntss_db5_om_di_json1
    INNER JOIN mst_addition ntss_db5_mst_a
        ON cast(ntss_db5_mst_a.addition_cd AS char (20)) = cast(ntss_db5_om_di_json1 ->> ''cd'' AS char (20))
    LEFT JOIN ord_schedule ntss_db5_os
        ON ntss_db5_os.ord_no = ntss_db5_om.ord_no
WHERE
    ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.facility_cd = @facilityCd
    AND ntss_db5_om.addition_info IS NOT NULL
    AND ntss_db5_om.addition_info <> ''[]''
    AND (
        CASE
            WHEN @syncMode = ''update''
                THEN (
                ntss_db5_om.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
            )
            OR (
                ntss_db5_os.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
						)OR (
                ntss_db5_mst_a.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
            )
            ELSE ntss_db5_om.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
            END
    )
    AND ntss_db5_om.pat_id IS NOT NULL;
',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["dialdiffcd2"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);


DELETE FROM "ntss"."sys_data_set" where sql_cd in (-2210);

INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2210,'WITH ntss_db5_om_1 AS (
    SELECT
        ntss_db5_om_1.ord_no AS ord_no
        , ntss_db5_om_1.pat_id
        , ntss_db5_om_1.treat_date AS treat_date
        , COUNT(ntss_db5_om_1.treat_date) AS treat_date_count
    FROM
        ord_main ntss_db5_om_1
    WHERE
        1 = 1
        AND ntss_db5_om_1.facility_cd = @facilityCd
        AND ntss_db5_om_1.treat_date IS NOT NULL
        AND (
            CASE
                WHEN @syncMode = ''update''
                    THEN ntss_db5_om_1.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                ELSE ntss_db5_om_1.treat_date BETWEEN SUBSTR(@fromDate, 0, 9) AND SUBSTR(@toDate, 0, 9)
                END
        )
    GROUP BY
        ntss_db5_om_1.ord_no
        , ntss_db5_om_1.pat_id
        , ntss_db5_om_1.treat_date
)
, ntss_db5_mst_m AS (
    SELECT
        ntss_db5_om.ord_no AS ord_no
        , ntss_db5_mst_m.in_hospital_cd_1 AS in_hospital_cd_1
        , ntss_db5_mst_m.in_hospital_cd_2 AS in_hospital_cd_2
        , ntss_db5_om_imi_json ->> ''name'' AS name --薬剤名
        , ntss_db5_om_imi_json ->> ''class_name'' AS class_name --薬剤分類名
        , ntss_db5_om_imi_json ->> ''amount'' AS amount --数量
        , ntss_db5_om_imi_json ->> ''unit'' AS unit --単位
        , ntss_db5_om_imi_json ->> ''timing_name'' AS timing_name --投与時間帯名
        , ntss_db5_om_imi_json ->> ''procedure_name'' AS procedure_name --手技名
        , ntss_db5_om_imi_json ->> ''comment'' AS comment --コメント
				, ntss_db5_mst_m.up_date AS up_date
    FROM
        ord_main ntss_db5_om
        CROSS JOIN LATERAL json_array_elements(ntss_db5_om.ind_medi_info ::json) ntss_db5_om_imi_json
        LEFT JOIN mst_medicine ntss_db5_mst_m
            ON cast(ntss_db5_mst_m.medicine_cd as char (10)) = cast(ntss_db5_om_imi_json ->> ''cd'' as char (10))
    WHERE
        ntss_db5_om.facility_cd = @facilityCd
)
, ntss_db5_mst_p AS (
    SELECT
        ntss_db5_om.ord_no AS ord_no
        , ntss_db5_mst_p.in_hospital_cd_a1 AS in_hospital_cd_1
        , ntss_db5_mst_p.in_hospital_cd_a2 AS in_hospital_cd_2
				, ntss_db5_mst_p.up_date AS up_date
    FROM
        ord_main ntss_db5_om
        CROSS JOIN LATERAL json_array_elements(ntss_db5_om.rst_medi_info ::json) ntss_db5_om_rmi_json
        LEFT JOIN mst_procedure ntss_db5_mst_p
            ON cast(ntss_db5_mst_p.procedure_cd as char (10)) = cast(
                ntss_db5_om_rmi_json ->> ''procedure_cd'' as char (10)
            )
    WHERE
        ntss_db5_om.facility_cd = @facilityCd
)
SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , ntss_db5_om.treat_date AS dialysisdate    --透析日
    , CASE
        WHEN ntss_db5_om_1.treat_date_count > 1
            THEN 1
        ELSE 0
        END AS plural                           --同日複数回
    , row_number() over (ORDER BY ntss_db5_om.treat_date DESC) AS ctlno --項目番号
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
    , ntss_db5_mst_m.in_hospital_cd_1 AS medicinecd --薬剤コード(院内コード1)
    , ntss_db5_mst_m.in_hospital_cd_2 AS medicinecd2 --薬剤コード(院内コード2)
    , ntss_db5_mst_m.name AS medicinename       --薬剤名
    , ntss_db5_mst_m.class_name AS mediclassname --薬剤分類名
    , ntss_db5_mst_m.amount AS amount           --数量
    , ntss_db5_mst_m.unit AS unit               --単位
    , ntss_db5_mst_m.timing_name AS timingname  --投与時間帯名
    , ntss_db5_mst_p.in_hospital_cd_1 AS procedurecd --手技コード(院内コード1)
    , ntss_db5_mst_p.in_hospital_cd_2 AS procedurecd2 --手技コード(院内コード2)
    , ntss_db5_mst_m.procedure_name AS procedurename --手技名
    , ntss_db5_mst_m.comment AS comments        --コメント
    , '''' AS indicatorcd                         --指示者
    , ntss_db5_om_iic_json ->> ''ind_user_id'' AS userid
    , CASE
        WHEN ntss_db5_om.treat_type = 0
            THEN ''1''
        ELSE ''0''
        END AS opeindplan                       --予定作成区分
FROM
    ord_main ntss_db5_om
    LEFT JOIN ntss_db5_om_1
        ON ntss_db5_om_1.ord_no = ntss_db5_om.ord_no
    LEFT JOIN ntss_db5_mst_m
        ON ntss_db5_mst_m.ord_no = ntss_db5_om.ord_no
    LEFT JOIN ntss_db5_mst_p
        ON ntss_db5_mst_p.ord_no = ntss_db5_om.ord_no
    CROSS JOIN LATERAL json_array_elements(ntss_db5_om.ind_ind_comment_info ::json) ntss_db5_om_iic_json
WHERE
    ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.facility_cd = @facilityCd
    AND (
        CASE
            WHEN @syncMode = ''update''
                THEN ntss_db5_om.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
								OR
										(
										ntss_db5_mst_m.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
										)
										OR
										(
										ntss_db5_mst_p.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
										)
            ELSE ntss_db5_om.treat_date BETWEEN SUBSTR(@fromDate, 0, 9) AND SUBSTR(@toDate, 0, 9)
            END
    )
    AND ntss_db5_om.pat_id IS NOT NULL;
',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);


DELETE FROM "ntss"."sys_data_set" where sql_cd in (-2200);

INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2200,'WITH ntss_db5_om_1 AS (
	SELECT
		ntss_db5_om_1.ord_no AS ord_no,
		ntss_db5_om_1.pat_id,
		ntss_db5_om_1.treat_date AS treat_date,
		COUNT ( ntss_db5_om_1.treat_date ) AS treat_date_count
	FROM
		ord_main ntss_db5_om_1
	WHERE
		1 = 1
		AND ntss_db5_om_1.facility_cd = @facilityCd
		AND ntss_db5_om_1.treat_date IS NOT NULL
	GROUP BY
		ntss_db5_om_1.ord_no,
		ntss_db5_om_1.pat_id,
		ntss_db5_om_1.treat_date
	),
	ntss_db5_mst_e AS ( SELECT ntss_db5_mst_e.* FROM mst_equipment ntss_db5_mst_e WHERE ntss_db5_mst_e.is_del = ''0'' AND ntss_db5_mst_e.is_disp = ''1'' AND ntss_db5_mst_e.facility_cd = @facilityCd ),
	ntss_db5_om_rei_json AS (
	SELECT
		om.ind_cond_info :: JSON -> ''6'' ->> ''value'' AS value_6,
		om.ind_cond_info :: JSON -> ''7'' ->> ''value'' AS value_7,
		om.ind_cond_info :: JSON -> ''8'' ->> ''value'' AS value_8,
		om.ind_cond_info :: JSON -> ''9'' ->> ''value'' AS value_9,
		om.ind_cond_info :: JSON -> ''10'' ->> ''value'' AS value_10,
		om.ind_cond_info :: JSON -> ''11'' ->> ''value'' AS value_11,
		om.ind_cond_info :: JSON -> ''12'' ->> ''value'' AS value_12,
		om.ind_cond_info :: JSON -> ''13'' ->> ''value'' AS value_13,
		ntss_db5_om_rei_json ->> ''amount'' AS amount,
		ntss_db5_om_rei_json ->> ''class_name'' AS class_name,
		ntss_db5_om_rei_json ->> ''name'' AS NAME,
		ntss_db5_om_rei_json ->> ''cd'' AS cd,
		om.ord_no AS ord_no
	FROM
		ord_main om
		CROSS JOIN LATERAL json_array_elements ( om.rst_equip_info :: JSON ) ntss_db5_om_rei_json
	WHERE
		om.facility_cd = @facilityCd
		AND om.is_del = ''0''
	),
	ntss_db5_om_iei_json AS (
	SELECT
		ntss_db5_om_iei_json ->> ''unit'' AS unit,
		ntss_db5_om_iei_json ->> ''comment'' AS COMMENT,
		ntss_db5_om_iei_json ->> ''cd'' AS cd,
		om.ord_no AS ord_no
	FROM
		ord_main om
		CROSS JOIN LATERAL json_array_elements ( om.ind_equip_info :: JSON ) ntss_db5_om_iei_json
	WHERE
		om.facility_cd = @facilityCd
		AND om.is_del = ''0''
	),
	ind_cond_info_table AS (
	SELECT
		value_6,
		value_7,
		value_8,
		value_9,
		value_10,
		value_11,
		value_12,
		value_13,
		amount,
		unit,
		COMMENT,
		class_name,
		NAME,
		oij.ord_no
	FROM
		ntss_db5_om_rei_json orj
		INNER JOIN ntss_db5_om_iei_json oij ON orj.ord_no = oij.ord_no
		AND orj.cd = oij.cd
	),
	ntss_db5_mst_list AS (
	SELECT
		ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1,
		''0'' AS puncture_class,
		ntss_db5_mst_e.in_hospital_cd_1 || CAST ( om.class_name AS CHAR ( 20 ) ) AS class_name,
		ntss_db5_mst_e.equipment_name || CAST ( om.NAME AS CHAR ( 20 ) ) AS NAMES,
		ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2,
		om.ord_no AS ord_no,
		om.amount AS amount,
		om.unit AS unit,
		om.COMMENT AS comments,
		ntss_db5_mst_e.up_date AS up_date
	FROM
		ind_cond_info_table om
		LEFT JOIN ntss_db5_mst_e ON TO_NUMBER( om.value_6, ''99999999'' ) = ntss_db5_mst_e.equipment_cd
	WHERE
		om.value_6 IS NOT NULL UNION ALL
	SELECT
		ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1,
		''0'' AS puncture_class,
		ntss_db5_mst_e.in_hospital_cd_1 || CAST ( om.class_name AS CHAR ( 20 ) ) AS class_name,
		ntss_db5_mst_e.equipment_name || CAST ( om.NAME AS CHAR ( 20 ) ) AS NAMES,
		ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2,
		om.ord_no AS ord_no,
		om.amount AS amount,
		om.unit AS unit,
		om.COMMENT AS comments,
		ntss_db5_mst_e.up_date AS up_date
	FROM
		ind_cond_info_table om
		LEFT JOIN ntss_db5_mst_e ON TO_NUMBER( om.value_7, ''99999999'' ) = ntss_db5_mst_e.equipment_cd
	WHERE
		om.value_7 IS NOT NULL UNION ALL
	SELECT
		ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1,
		''0'' AS puncture_class,
		ntss_db5_mst_e.in_hospital_cd_1 || CAST ( om.class_name AS CHAR ( 20 ) ) AS class_name,
		ntss_db5_mst_e.equipment_name || CAST ( om.NAME AS CHAR ( 20 ) ) AS NAMES,
		ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2,
		om.ord_no AS ord_no,
		om.amount AS amount,
		om.unit AS unit,
		om.COMMENT AS comments,
		ntss_db5_mst_e.up_date AS up_date
	FROM
		ind_cond_info_table om
		LEFT JOIN ntss_db5_mst_e ON TO_NUMBER( om.value_8, ''99999999'' ) = ntss_db5_mst_e.equipment_cd
	WHERE
		om.value_8 IS NOT NULL UNION ALL
	SELECT
		ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1,
		''1'' AS puncture_class,
		ntss_db5_mst_e.in_hospital_cd_1 || CAST ( om.class_name AS CHAR ( 20 ) ) AS class_name,
		ntss_db5_mst_e.equipment_name || CAST ( om.NAME AS CHAR ( 20 ) ) AS NAMES,
		ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2,
		om.ord_no AS ord_no,
		om.amount AS amount,
		om.unit AS unit,
		om.COMMENT AS comments,
		ntss_db5_mst_e.up_date AS up_date
	FROM
		ind_cond_info_table om
		LEFT JOIN ntss_db5_mst_e ON TO_NUMBER( om.value_9, ''99999999'' ) = ntss_db5_mst_e.equipment_cd
	WHERE
		om.value_9 IS NOT NULL UNION ALL
	SELECT
		ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1,
		''2'' AS puncture_class,
		ntss_db5_mst_e.in_hospital_cd_1 || CAST ( om.class_name AS CHAR ( 20 ) ) AS class_name,
		ntss_db5_mst_e.equipment_name || CAST ( om.NAME AS CHAR ( 20 ) ) AS NAMES,
		ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2,
		om.ord_no AS ord_no,
		om.amount AS amount,
		om.unit AS unit,
		om.COMMENT AS comments,
		ntss_db5_mst_e.up_date AS up_date
	FROM
		ind_cond_info_table om
		LEFT JOIN ntss_db5_mst_e ON TO_NUMBER( om.value_10, ''99999999'' ) = ntss_db5_mst_e.equipment_cd
	WHERE
		om.value_10 IS NOT NULL UNION ALL
	SELECT
		ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1,
		''3'' AS puncture_class,
		ntss_db5_mst_e.in_hospital_cd_1 || CAST ( om.class_name AS CHAR ( 20 ) ) AS class_name,
		ntss_db5_mst_e.equipment_name || CAST ( om.NAME AS CHAR ( 20 ) ) AS NAMES,
		ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2,
		om.ord_no AS ord_no,
		om.amount AS amount,
		om.unit AS unit,
		om.COMMENT AS comments,
		ntss_db5_mst_e.up_date AS up_date
	FROM
		ind_cond_info_table om
		LEFT JOIN ntss_db5_mst_e ON TO_NUMBER( om.value_11, ''99999999'' ) = ntss_db5_mst_e.equipment_cd
	WHERE
		om.value_11 IS NOT NULL UNION ALL
	SELECT
		ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1,
		''0'' AS puncture_class,
		ntss_db5_mst_e.in_hospital_cd_1 || CAST ( om.class_name AS CHAR ( 20 ) ) AS class_name,
		ntss_db5_mst_e.equipment_name || CAST ( om.NAME AS CHAR ( 20 ) ) AS NAMES,
		ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2,
		om.ord_no AS ord_no,
		om.amount AS amount,
		om.unit AS unit,
		om.COMMENT AS comments,
		ntss_db5_mst_e.up_date AS up_date
	FROM
		ind_cond_info_table om
		LEFT JOIN ntss_db5_mst_e ON TO_NUMBER( om.value_12, ''99999999'' ) = ntss_db5_mst_e.equipment_cd
	WHERE
		om.value_12 IS NOT NULL UNION ALL
	SELECT
		ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1,
		''0'' AS puncture_class,
		ntss_db5_mst_e.in_hospital_cd_1 || CAST ( om.class_name AS CHAR ( 20 ) ) AS class_name,
		ntss_db5_mst_e.equipment_name || CAST ( om.NAME AS CHAR ( 20 ) ) AS NAMES,
		ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2,
		om.ord_no AS ord_no,
		om.amount AS amount,
		om.unit AS unit,
		om.COMMENT AS comments,
		ntss_db5_mst_e.up_date AS up_date
	FROM
		ind_cond_info_table om
		LEFT JOIN ntss_db5_mst_e ON TO_NUMBER( om.value_13, ''99999999'' ) = ntss_db5_mst_e.equipment_cd
	WHERE
		om.value_13 IS NOT NULL UNION ALL
	SELECT
		ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1,
		'''' AS puncture_class,
		'''' AS class_name,
		'''' AS NAMES,
		ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2,
		om.ord_no AS ord_no,
		'''' AS amount,
		'''' AS unit,
		'''' AS comments,
		ntss_db5_mst_e.up_date AS up_date
	FROM
		ntss_db5_om_rei_json om
		LEFT JOIN ntss_db5_mst_e ON om.cd = CAST ( ntss_db5_mst_e.equipment_cd AS CHAR ( 4 ) )
	) SELECT
	'''' AS hosppatid --患者ID
	,
	ntss_db5_om.pat_id AS patid,
	ntss_db5_om.treat_date AS dialysisdate --透析日
	,
CASE

		WHEN ntss_db5_om_1.treat_date_count > 1 THEN
		1 ELSE 0
	END AS plural --同日複数回
	,
	ROW_NUMBER ( ) OVER ( ORDER BY ntss_db5_om.treat_date DESC ) AS ctlno --項目番号
	,
	to_char( ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'' ) AS updates --更新日時
	,
	ntss_db5_mst_list.in_hospital_cd_1 AS equipcd --医療材料コード(院内コード1)
	,
	ntss_db5_mst_list.in_hospital_cd_2 AS equipcd2 --医療材料コード(院内コード2)
	,
	ntss_db5_mst_list.class_name AS equipclassname --医療材料分類名
	,
	SUBSTR( ntss_db5_mst_list.NAMES, 0, 14 ) AS equipname --医療材料名
	,
	ntss_db5_mst_list.puncture_class AS punctureclass --医療材料名
	,
	ntss_db5_mst_list.amount AS amount --数量
	,
	ntss_db5_mst_list.unit AS unit --数量
	,
	ntss_db5_mst_list.comments AS comments --コメント
	,
	'''' AS indicatorcd --指示者
	,
	ntss_db5_om_iic_json ->> ''ind_user_id'' AS userid,
CASE

		WHEN ntss_db5_om.treat_type = 0 THEN
		''1'' ELSE''0''
	END AS opeindplan --予定作成区分

FROM
	ord_main ntss_db5_om
	LEFT JOIN ntss_db5_om_1 ON ntss_db5_om_1.ord_no = ntss_db5_om.ord_no
	LEFT JOIN ntss_db5_mst_list ON ntss_db5_mst_list.ord_no = ntss_db5_om.ord_no
	CROSS JOIN LATERAL json_array_elements ( ntss_db5_om.ind_ind_comment_info :: JSON ) ntss_db5_om_iic_json
WHERE
	ntss_db5_om.is_del = ''0''
	AND ntss_db5_om.facility_cd = @facilityCd
	AND (
	CASE

		WHEN @syncMode = ''update'' THEN
			ntss_db5_om.up_date BETWEEN to_timestamp( @fromDate, ''YYYYMMDDHH24MISS'' )
			AND to_timestamp( @toDate, ''YYYYMMDDHH24MISS'' )
			OR ( ntss_db5_mst_list.up_date BETWEEN to_timestamp( @fromDate, ''YYYYMMDDHH24MISS'' ) AND to_timestamp( @toDate, ''YYYYMMDDHH24MISS'' ) ) ELSE ntss_db5_om.treat_date BETWEEN SUBSTR( @fromDate, 0, 9 )
			AND SUBSTR( @toDate, 0, 9 )
		END
		)
	AND ntss_db5_om.pat_id IS NOT NULL;',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);


DELETE FROM "ntss"."sys_data_set" where sql_cd in (-2190);

INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2190,'with ntss_db5_mst_v as (
    SELECT
        ntss_db5_mst_v.*
    FROM
        mst_va ntss_db5_mst_v
    WHERE
        ntss_db5_mst_v.is_del = ''0''
        AND ntss_db5_mst_v.is_disp = ''1''
        AND ntss_db5_mst_v.facility_cd = @facilityCd
)
, ntss_db5_mst_d as (
    SELECT
        ntss_db5_mst_d.*
    FROM
        mst_dialyzer ntss_db5_mst_d
    WHERE
        ntss_db5_mst_d.is_del = ''0''
        AND ntss_db5_mst_d.is_disp = ''1''
        AND ntss_db5_mst_d.facility_cd = @facilityCd
)
, ntss_db5_mst_e as (
    SELECT
        ntss_db5_mst_e.*
    FROM
        mst_equipment ntss_db5_mst_e
    WHERE
        ntss_db5_mst_e.is_del = ''0''
        AND ntss_db5_mst_e.is_disp = ''1''
        AND ntss_db5_mst_e.facility_cd = @facilityCd
)
, ntss_db5_mst_m as (
    SELECT
        ntss_db5_mst_m.*
    FROM
        mst_medicine ntss_db5_mst_m
    WHERE
        ntss_db5_mst_m.is_del = ''0''
        AND ntss_db5_mst_m.is_disp = ''1''
        AND ntss_db5_mst_m.facility_cd = @facilityCd
)
, ntss_db5_mst_t as (
    SELECT
        ntss_db5_mst_t.*
    FROM
        mst_treatment ntss_db5_mst_t
    WHERE
        ntss_db5_mst_t.is_del = ''0''
        AND ntss_db5_mst_t.is_disp = ''1''
        AND ntss_db5_mst_t.facility_cd = @facilityCd
)
, ind_cond_info_table AS (
    SELECT
        om.ind_cond_info ::json ->> ''2'' AS ind_cond_info_2
        , om.ind_cond_info ::json ->> ''5'' AS ind_cond_info_5
        , om.ind_cond_info ::json ->> ''6'' AS ind_cond_info_6
        , om.ind_cond_info ::json ->> ''7'' AS ind_cond_info_7
        , om.ind_cond_info ::json ->> ''8'' AS ind_cond_info_8
        , om.ind_cond_info ::json ->> ''9'' AS ind_cond_info_9
        , om.ind_cond_info ::json ->> ''10'' AS ind_cond_info_10
        , om.ind_cond_info ::json ->> ''11'' AS ind_cond_info_11
        , om.ind_cond_info ::json ->> ''13'' AS ind_cond_info_13
        , om.ind_cond_info ::json ->> ''15'' AS ind_cond_info_15
        , om.ind_cond_info ::json ->> ''19'' AS ind_cond_info_19
        , om.ind_cond_info ::json ->> ''26'' AS ind_cond_info_26
        , ord_no
    FROM
        ord_main om
    WHERE
        om.facility_cd = @facilityCd
        AND om.is_del = ''0''

)
, ntss_db5_mst_list as (
    --VA
    SELECT
        ''003'' AS fnw_code
        , ''VA'' AS fnw_name
        , om.ind_cond_info_2 ::json ->> ''value'' AS value
        , om.ind_cond_info_2 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_2 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_v.in_hospital_cd_2 AS in_hospital_cd_2
				, ntss_db5_mst_v.up_date AS up_date
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_v
            ON TO_NUMBER(
                om.ind_cond_info_2 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_v.va_cd
    WHERE
        om.ind_cond_info_2 ::json ->> ''value'' IS NOT NULL
    UNION ALL                                   --ダイアライザ
    SELECT
        ''008'' AS fnw_code
        , ''ダイアライザ'' AS fnw_name
        , om.ind_cond_info_5 ::json ->> ''value'' AS value
        , om.ind_cond_info_5 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_5 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_d.in_hospital_cd_2 AS in_hospital_cd_2
				, ntss_db5_mst_d.up_date AS up_date
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_d
            ON TO_NUMBER(
                om.ind_cond_info_5 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_d.dialyzer_cd
    WHERE
        om.ind_cond_info_5 ::json ->> ''value'' IS NOT NULL
    UNION ALL                                   --吸着カラム
    SELECT
        ''009'' AS fnw_code
        , ''吸着カラム'' AS fnw_name
        , om.ind_cond_info_6 ::json ->> ''value'' AS value
        , om.ind_cond_info_6 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_6 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
				, ntss_db5_mst_e.up_date AS up_date
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(
                om.ind_cond_info_6 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_e.equipment_cd
    WHERE
        om.ind_cond_info_6 ::json ->> ''value'' IS NOT NULL
    UNION ALL                                   --1次膜
    SELECT
        ''039'' AS fnw_code
        , ''1次膜'' AS fnw_name
        , om.ind_cond_info_7 ::json ->> ''value'' AS value
        , om.ind_cond_info_7 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_7 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
				, ntss_db5_mst_e.up_date AS up_date
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(
                om.ind_cond_info_7 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_e.equipment_cd
    WHERE
        om.ind_cond_info_7 ::json ->> ''value'' IS NOT NULL
    UNION ALL                                   --2次膜
    SELECT
        ''040'' AS fnw_code
        , ''2次膜'' AS fnw_name
        , om.ind_cond_info_8 ::json ->> ''value'' AS value
        , om.ind_cond_info_8 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_8 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
				, ntss_db5_mst_e.up_date AS up_date
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(
                om.ind_cond_info_8 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_e.equipment_cd
    WHERE
        om.ind_cond_info_8 ::json ->> ''value'' IS NOT NULL
    UNION ALL                                   --穿刺針(A針)
    SELECT
        ''999'' AS fnw_code
        , ''穿刺針(A針)'' AS fnw_name
        , om.ind_cond_info_9 ::json ->> ''value'' AS value
        , om.ind_cond_info_9 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_9 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
				, ntss_db5_mst_e.up_date AS up_date
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(
                om.ind_cond_info_9 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_e.equipment_cd
    WHERE
        om.ind_cond_info_9 ::json ->> ''value'' IS NOT NULL
    UNION ALL                                   --穿刺針(V針)
    SELECT
        ''998'' AS fnw_code
        , ''穿刺針(V針)'' AS fnw_name
        , om.ind_cond_info_10 ::json ->> ''value'' AS value
        , om.ind_cond_info_10 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_10 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
				, ntss_db5_mst_e.up_date AS up_date
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(
                om.ind_cond_info_10 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_e.equipment_cd
    WHERE
        om.ind_cond_info_10 ::json ->> ''value'' IS NOT NULL
    UNION ALL                                   --穿刺針(SN)
    SELECT
        ''997'' AS fnw_code
        , ''穿刺針(SN)'' AS fnw_name
        , om.ind_cond_info_11 ::json ->> ''value'' AS value
        , om.ind_cond_info_11 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_11 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
				, ntss_db5_mst_e.up_date AS up_date
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(
                om.ind_cond_info_11 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_e.equipment_cd
    WHERE
        om.ind_cond_info_11 ::json ->> ''value'' IS NOT NULL
    UNION ALL                                   --血液回路
    SELECT
        ''996'' AS fnw_code
        , ''血液回路'' AS fnw_name
        , om.ind_cond_info_13 ::json ->> ''value'' AS value
        , om.ind_cond_info_13 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_13 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_e.in_hospital_cd_2 AS in_hospital_cd_2
				, ntss_db5_mst_e.up_date AS up_date
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_e
            ON TO_NUMBER(
                om.ind_cond_info_13 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_e.equipment_cd
    WHERE
        om.ind_cond_info_13 ::json ->> ''value'' IS NOT NULL
    UNION ALL                                   --透析液
    SELECT
        ''018'' AS fnw_code
        , ''透析液'' AS fnw_name
        , om.ind_cond_info_15 ::json ->> ''value'' AS value
        , om.ind_cond_info_15 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_15 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_m.in_hospital_cd_2 AS in_hospital_cd_2
				, ntss_db5_mst_m.up_date AS up_date
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_m
            ON TO_NUMBER(
                om.ind_cond_info_15 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_m.medicine_cd
    WHERE
        om.ind_cond_info_15 ::json ->> ''value'' IS NOT NULL
    UNION ALL                                   --補液
    SELECT
        ''022'' AS fnw_code
        , ''補液'' AS fnw_name
        , om.ind_cond_info_19 ::json ->> ''value'' AS value
        , om.ind_cond_info_19 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_19 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_m.in_hospital_cd_2 AS in_hospital_cd_2
				, ntss_db5_mst_m.up_date AS up_date
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_m
            ON TO_NUMBER(
                om.ind_cond_info_19 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_m.medicine_cd
    WHERE
        om.ind_cond_info_19 ::json ->> ''value'' IS NOT NULL
    UNION ALL                                   --抗凝固剤ワンショット量
    SELECT
        ''012'' AS fnw_code
        , ''抗凝固剤ワンショット量'' AS fnw_name
        , om.ind_cond_info_26 ::json ->> ''value'' AS value
        , om.ind_cond_info_26 ::json ->> ''value_name_1'' AS value_name_1
        , om.ind_cond_info_26 ::json ->> ''unit'' AS unit
        , om.ord_no AS ord_no
        , ntss_db5_mst_m.in_hospital_cd_2 AS in_hospital_cd_2
				, ntss_db5_mst_m.up_date AS up_date
    FROM
        ind_cond_info_table om
        LEFT JOIN ntss_db5_mst_m
            ON TO_NUMBER(
                om.ind_cond_info_26 ::json ->> ''value''
                , ''99999999''
            ) = ntss_db5_mst_m.medicine_cd
    WHERE
        om.ind_cond_info_26 ::json ->> ''value'' IS NOT NULL
)
, ntss_db5_om_1 as (
    SELECT
        ntss_db5_om_1.ord_no AS ord_no
        , ntss_db5_om_1.pat_id
        , ntss_db5_om_1.treat_date AS treat_date
        , COUNT(ntss_db5_om_1.treat_date) AS treat_date_count
    FROM
        ord_main ntss_db5_om_1
    WHERE
        1 = 1
        AND ntss_db5_om_1.facility_cd = @facilityCd
        AND ntss_db5_om_1.treat_date IS NOT NULL
        AND (
            CASE
                WHEN @syncMode = ''update''
                    THEN ntss_db5_om_1.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                ELSE ntss_db5_om_1.treat_date BETWEEN SUBSTR(@fromDate, 0, 9) AND SUBSTR(@toDate, 0, 9)
                END
        )
    GROUP BY
        ntss_db5_om_1.ord_no
        , ntss_db5_om_1.pat_id
        , ntss_db5_om_1.treat_date
)
SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , ntss_db5_om.treat_date AS dialysisdate    --透析日
    , CASE
        WHEN ntss_db5_om_1.treat_date_count > 1
            THEN 1
        ELSE 0
        END AS plural                           --同日複数回
    , ntss_db5_mst_list.fnw_code AS ctlno       --透析条件項目コード
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時+
    , ntss_db5_mst_list.fnw_name AS dialysisitemname --透析条件項目名
    , ntss_db5_mst_list.value AS value          --設定値
    , ntss_db5_mst_list.value_name_1 AS valuename --名称
    , ntss_db5_mst_list.unit AS unit            --単位
    , ntss_db5_mst_list.in_hospital_cd_2 AS valuecd2 --院内コード2
    , '''' AS indicatorcd                         --指示者
    , ntss_db5_om_iic_json ->> ''ind_user_id'' AS userid
    , CASE
        WHEN ntss_db5_om.treat_type = 0
            THEN ''1''
        ELSE ''0''
        END AS opeindplan                       --予定作成区分
FROM
    ord_main ntss_db5_om
    LEFT JOIN ntss_db5_mst_list
        ON ntss_db5_mst_list.ord_no = ntss_db5_om.ord_no
    LEFT JOIN ntss_db5_om_1
        ON ntss_db5_om_1.ord_no = ntss_db5_om.ord_no
    CROSS JOIN LATERAL json_array_elements(ntss_db5_om.ind_ind_comment_info ::json) ntss_db5_om_iic_json
WHERE
    ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.facility_cd = @facilityCd
    AND (
        CASE
            WHEN @syncMode = ''update''
                THEN ntss_db5_om.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
								OR(
								ntss_db5_mst_list.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
								)
            ELSE ntss_db5_om.treat_date BETWEEN SUBSTR(@fromDate, 0, 9) AND SUBSTR(@toDate, 0, 9)
            END
    )
    AND ntss_db5_om.pat_id IS NOT NULL
    AND ntss_db5_mst_list.fnw_code IS NOT NULL;
',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid,userid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);

DELETE FROM "ntss"."sys_data_set" where sql_cd in (-2110);

INSERT INTO ntss.sys_data_set(sql_cd,"sql",db_class,detail,can_repeat,use_application,report_class,memo,reg_date,up_date,pre_sql_info) VALUES
    (-2110,'WITH ntss_db5_om_key AS (
    SELECT
        ntss_db5_om.ord_no AS ord_no
        , ntss_db5_om_value_json.KEY AS keys
        , ntss_db5_om_value_json.value ::JSON ->> ''value'' AS value
        , ntss_db5_om_value_json.value ::JSON ->> ''value_name_1'' AS value_name_1
        , ntss_db5_om_value_json.value ::JSON ->> ''unit'' AS unit
    FROM
        ord_main ntss_db5_om
        CROSS JOIN LATERAL json_object_keys(ntss_db5_om.rst_cond_info ::JSON) rst_ci_keys_json
        INNER JOIN json_each_text(ntss_db5_om.rst_cond_info ::JSON) ntss_db5_om_value_json
            ON ntss_db5_om_value_json.KEY = rst_ci_keys_json
    WHERE
        ntss_db5_om.rst_cond_info IS NOT NULL
        AND ntss_db5_om.facility_cd = @facilityCd
)
, ntss_db5_mst_m AS (
    SELECT
        ntss_db5_mst_m.*
    FROM
        mst_medicine ntss_db5_mst_m
    WHERE
        ntss_db5_mst_m.is_del = ''0''
        AND ntss_db5_mst_m.is_disp = ''1''
        AND ntss_db5_mst_m.facility_cd = @facilityCd
)
, ntss_db5_om_mst_list AS (
    SELECT
        om.ord_no AS ord_no
        , ntss_db5_mst_e.in_hospital_cd_1 AS in_hospital_cd_1
        , ntss_db5_mst_e.equipment_cd AS equipment_cd_keys
        , ntss_db5_mst_e.up_date AS up_date
    FROM
        ord_main om
        INNER JOIN ntss_db5_om_key
            ON om.ord_no = ntss_db5_om_key.ord_no
        LEFT JOIN mst_equipment ntss_db5_mst_e
            ON CAST(ntss_db5_om_key.keys AS INTEGER) = ntss_db5_mst_e.equipment_cd
    WHERE
        ntss_db5_mst_e.facility_cd = @facilityCd
        AND ntss_db5_mst_e.is_del = ''0''
    UNION ALL
    SELECT
        om.ord_no AS ord_no
        , ntss_db5_mst_m.in_hospital_cd_1 AS in_hospital_cd_1
        , ntss_db5_mst_m.medicine_cd AS equipment_cd_keys
        , ntss_db5_mst_m.up_date AS up_date
    FROM
        ord_main om
        INNER JOIN ntss_db5_om_key
            ON om.ord_no = ntss_db5_om_key.ord_no
        LEFT JOIN mst_medicine ntss_db5_mst_m
            ON CAST(ntss_db5_om_key.keys AS INTEGER) = ntss_db5_mst_m.medicine_cd
    WHERE
        ntss_db5_mst_m.facility_cd = @facilityCd
        AND om.is_del = ''0''
)
SELECT
    '''' AS hosppatid                             --患者ID
    , ntss_db5_om.pat_id AS patid
    , ntss_db5_os.treat_date AS dialysisdate    --透析日
    , ntss_db5_om.ord_no AS dialysisno          --透析番号
    , CASE
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''1''
            THEN ''002''                          --治療時間
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''2''
            THEN ''003''                          --VA
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''3''
            THEN ''005''                          --目標体重
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''4''
            THEN ''007''                          --除水量制限
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''5''
            THEN ''008''                          --ダイアライザ
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''6''
            THEN ''009''                          --吸着カラム
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''7''
            THEN ''039''                          --1次膜
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''8''
            THEN ''040''                          --2次膜
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''9''
            THEN ''999''                          --穿刺針(A針)
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''10''
            THEN ''998''                          --穿刺針(V針)
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''11''
            THEN ''997''                          --穿刺針(SN)
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''12''
            THEN ''029''                          --シングルニードル使用
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''13''
            THEN ''996''                          --血液回路
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''14''
            THEN ''010''                          --血流量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''15''
            THEN ''018''                          --透析液
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''16''
            THEN ''019''                          --透析液流量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''17''
            THEN ''020''                          --透析液量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''18''
            THEN ''021''                          --透析液温度
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''19''
            THEN ''022''                          --補液
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''20''
            THEN ''023''                          --補液量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''21''
            THEN ''024''                          --補液選択
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''22''
            THEN ''030''                          --補液使用数
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''23''
            THEN ''025''                          --補液温度
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''24''
            THEN ''038''                          --補液速度
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''25''
            THEN ''011''                          --抗凝固剤
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''26''
            THEN ''012''                          --抗凝固剤ワンショット量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''27''
            THEN ''013''                          --抗凝固剤持続速度
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''28''
            THEN ''014''                          --抗凝固剤持続総量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''29''
            THEN ''015''                          --IP使用選択
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''30''
            THEN ''031''                          --IPスタート
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''31''
            THEN ''016''                          --IPワンショット量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''32''
            THEN ''017''                          --IP速度
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''33''
            THEN ''037''                          --IP速度最大値
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''34''
            THEN ''032''                          --自動ワンショット
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''35''
            THEN ''033''                          --IP電源自動切り
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''36''
            THEN ''034''                          --IP電源自動切り時間
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''37''
            THEN ''035''                          --IP電源OKモニタ切り
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''38''
            THEN ''036''                          --IP電源OKモニタ切り時間
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''39''
            THEN ''004''                          --DW
        END AS ctlno                            --透析条件項目コード
    , to_char(ntss_db5_om.up_date, ''YYYY-MM-DD hh24:mi:ss'') AS updates --更新日時
    , CASE
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''1''
            THEN ''透析時間''                     --治療時間
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''2''
            THEN ''VA''                           --VA
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''3''
            THEN ''目標体重''                     --目標体重
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''4''
            THEN ''除水量制限''                   --除水量制限
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''5''
            THEN ''ダイアライザ''                 --ダイアライザ
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''6''
            THEN ''吸着カラム''                   --吸着カラム
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''7''
            THEN ''1次膜''                        --1次膜
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''8''
            THEN ''2次膜''                        --2次膜
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''9''
            THEN ''穿刺針(A針)''                  --穿刺針(A針)
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''10''
            THEN ''穿刺針(V針)''                  --穿刺針(V針)
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''11''
            THEN ''穿刺針(SN)''                   --穿刺針(SN)
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''12''
            THEN ''シングルニードル使用''         --シングルニードル使用
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''13''
            THEN ''血液回路''                     --血液回路
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''14''
            THEN ''血流量''                       --血流量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''15''
            THEN ''透析液''                       --透析液
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''16''
            THEN ''透析液流量''                   --透析液流量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''17''
            THEN ''透析液量''                     --透析液量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''18''
            THEN ''透析液温度''                   --透析液温度
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''19''
            THEN ''補液''                         --補液
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''20''
            THEN ''補液量''                       --補液量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''21''
            THEN ''補液選択''                     --補液選択
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''22''
            THEN ''補液使用数''                   --補液使用数
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''23''
            THEN ''補液温度''                     --補液温度
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''24''
            THEN ''補液速度''                     --補液速度
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''25''
            THEN ''抗凝固剤''                     --抗凝固剤
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''26''
            THEN ''抗凝固剤ワンショット量''       --抗凝固剤ワンショット量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''27''
            THEN ''抗凝固剤持続速度''             --抗凝固剤持続速度
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''28''
            THEN ''抗凝固剤持続総量''             --抗凝固剤持続総量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''29''
            THEN ''IP使用選択''                   --IP使用選択
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''30''
            THEN ''IPスタート''                   --IPスタート
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''31''
            THEN ''IPワンショット量''             --IPワンショット量
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''32''
            THEN ''IP速度''                       --IP速度
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''33''
            THEN ''IP速度最大値''                 --IP速度最大値
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''34''
            THEN ''自動ワンショット''             --自動ワンショット
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''35''
            THEN ''IP電源自動切り''               --IP電源自動切り
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''36''
            THEN ''IP電源自動切り時間''           --IP電源自動切り時間
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''37''
            THEN ''IP電源OKモニタ切り''           --IP電源OKモニタ切り
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''38''
            THEN ''IP電源OKモニタ切り時間''       --IP電源OKモニタ切り時間
        WHEN CAST(ntss_db5_om_key.keys AS CHAR (10)) = ''39''
            THEN ''DW''                           --DW
        END AS dialysisitemname                 --透析条件項目名
    , ntss_db5_om_key.value AS value            --設定値
    , ntss_db5_om_key.value_name_1 AS valuename --設定値
    , ntss_db5_om_key.unit AS unit              --単位
    , SUBSTR(ntss_db5_om_mst_list.in_hospital_cd_1, 0, 20) AS valuecd1 --院内コード1
FROM
    ord_main ntss_db5_om
    LEFT JOIN ord_schedule ntss_db5_os
        ON ntss_db5_om.ord_no = ntss_db5_os.ord_no
        AND ntss_db5_os.facility_cd = @facilityCd
    INNER JOIN ntss_db5_om_key
        ON ntss_db5_om.ord_no = ntss_db5_om_key.ord_no
    LEFT JOIN ntss_db5_om_mst_list
        ON ntss_db5_om_mst_list.ord_no = ntss_db5_om_key.ord_no
        AND ntss_db5_om_mst_list.equipment_cd_keys = CAST(ntss_db5_om_key.keys AS INTEGER)
WHERE
    ntss_db5_om.is_del = ''0''
    AND ntss_db5_om.facility_cd = @facilityCd

        AND (
        CASE
            WHEN @syncMode = ''update''
                THEN (
                (
                    ntss_db5_om.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                )
                OR (
                    ntss_db5_os.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                )
                OR (
                    ntss_db5_om_mst_list.up_date BETWEEN to_timestamp(@fromDate, ''YYYYMMDDHH24MISS'') AND to_timestamp(@toDate, ''YYYYMMDDHH24MISS'')
                )
            ) else ntss_db5_os.treat_date BETWEEN SUBSTR(@fromDate, 0, 9) AND SUBSTR(@toDate, 0, 9) end
    )
    AND ntss_db5_om.pat_id IS NOT NULL;',2,'[]','1','{"applications": [5]}','{"classes": []}','患者病歴情報　@facilityCd @fromDate @toDate使用 {"Mergekey": ["patid"]}','2021/02/26 17:51:54.726','2021/02/26 17:51:54.726',NULL);
