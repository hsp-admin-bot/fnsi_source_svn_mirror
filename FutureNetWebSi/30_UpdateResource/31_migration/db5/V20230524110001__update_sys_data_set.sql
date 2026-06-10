UPDATE "ntss"."sys_data_set" SET "sql" = 
'select

case when monitor_data->>''1'' is null then ''0'' else monitor_data->>''1'' end as mon1 -- 経過時間
,case when monitor_data->>''2'' is null then ''0'' else monitor_data->>''2'' end as mon2 -- 経過時間（ＥＣＵＭ）
,case when monitor_data->>''3'' is null then ''0'' else monitor_data->>''3'' end as mon3 -- 残り時間（除水完了）
,case when monitor_data->>''4'' is null then ''0'' else monitor_data->>''4'' end as mon4 -- 残り時間（透析完了）
,monitor_data->>''5'' as mon5 -- 除水積算値
,monitor_data->>''6'' as mon6 -- 除水速度
,monitor_data->>''7'' as mon7 -- 血液循環量
,monitor_data->>''8'' as mon8 -- 血流量
,monitor_data->>''9'' as mon9 -- ＩＰ総量
,monitor_data->>''10'' as mon10 -- ＩＰ速度
,monitor_data->>''11'' as mon11 -- 静脈圧
,monitor_data->>''12'' as mon12 -- 透析液圧
,monitor_data->>''13'' as mon13 -- TMP
,monitor_data->>''14'' as mon14 -- ダイアライザ入口圧
,monitor_data->>''15'' as mon15 -- ダイアライザ差圧
,monitor_data->>''16'' as mon16 -- 血液入口～静脈平均圧
,monitor_data->>''17'' as mon17 -- ⊿BV
,monitor_data->>''18'' as mon18 -- バイカーボ濃度
,monitor_data->>''19'' as mon19 -- 透析液濃度
,monitor_data->>''20'' as mon20 -- Ｎａ濃度
,monitor_data->>''21'' as mon21 -- 透析液温度
,monitor_data->>''22'' as mon22 -- 透析液流量
,monitor_data->>''23'' as mon23 -- 漏血量
,monitor_data->>''24'' as mon24 -- 給液圧（上限）
,monitor_data->>''25'' as mon25 -- 給液圧（下限）
,monitor_data->>''26'' as mon26 -- ＵＦＲ
,monitor_data->>''27'' as mon27 -- ＵＦＲ低下率
,monitor_data->>''28'' as mon28 -- 初期ＵＦＲ測定値
,monitor_data->>''29'' as mon29 -- TMP補正値
,monitor_data->>''30'' as mon30 -- 透析運転時間
,monitor_data->>''31'' as mon31 -- 治療モード
,monitor_data->>''32'' as mon32 -- 除水目標値
,monitor_data->>''33'' as mon33 -- 除水速度設定値
,monitor_data->>''34'' as mon34 -- 透析液温度設定値
,monitor_data->>''35'' as mon35 -- 透析液流量設定値
,monitor_data->>''36'' as mon36 -- 血流量設定値
,monitor_data->>''37'' as mon37 -- ＩＰ速度設定
,monitor_data->>''39'' as mon39 -- 静脈圧警報点（上限）
,monitor_data->>''40'' as mon40 -- 静脈圧警報点（下限）
,monitor_data->>''41'' as mon41 -- 透析液圧警報点（上限）
,monitor_data->>''42'' as mon42 -- 透析液圧警報点（下限）
,monitor_data->>''43'' as mon43 -- TMP警報点（上限）
,monitor_data->>''44'' as mon44 -- TMP警報点（下限）
,monitor_data->>''45'' as mon45 -- ダイアライザ入口圧警報点（上限）
,monitor_data->>''46'' as mon46 -- ダイアライザ入口圧警報点（下限）
,monitor_data->>''47'' as mon47 -- ダイアライザ差圧警報点（上限）
,monitor_data->>''48'' as mon48 -- ダイアライザ差圧警報点（下限）
,monitor_data->>''49'' as mon49 -- ⊿ＢＶ低下警報点1
,monitor_data->>''50'' as mon50 -- ⊿ＢＶ低下警報点2
,monitor_data->>''51'' as mon51 -- ⊿BV変化率警報点
,monitor_data->>''54'' as mon54 -- バイカーボ濃度警報点（上限）
,monitor_data->>''55'' as mon55 -- バイカーボ濃度警報点（下限）
,monitor_data->>''56'' as mon56 -- 透析液濃度警報点（上限）
,monitor_data->>''57'' as mon57 -- 透析液濃度警報点（下限）
,monitor_data->>''58'' as mon58 -- Ｎａ濃度警報点（上限）
,monitor_data->>''59'' as mon59 -- Ｎａ濃度警報点（下限）
,monitor_data->>''60'' as mon60 -- 透析液温度警報点（上限）
,monitor_data->>''61'' as mon61 -- 透析液温度警報点（下限）
,monitor_data->>''62'' as mon62 -- 漏血量警報
,monitor_data->>''63'' as mon63 -- 給水圧警報点（上限）
,monitor_data->>''64'' as mon64 -- 給水圧警報点（下限）
,monitor_data->>''65'' as mon65 -- 初期ＵＦＲ警報点（上限）
,monitor_data->>''66'' as mon66 -- 初期ＵＦＲ警報点（下限）
,monitor_data->>''67'' as mon67 -- ＵＦＲ低下率警報
,monitor_data->>''68'' as mon68 -- Kt/V
,monitor_data->>''69'' as mon69 -- 運転中の血流量積算値
,monitor_data->>''70'' as mon70 -- 補液量設定値
,monitor_data->>''71'' as mon71 -- 補液速度
,monitor_data->>''72'' as mon72 -- 補液量現在値
,monitor_data->>''73'' as mon73 -- 補液速度設定値
,monitor_data->>''74'' as mon74 -- 補液温度
,monitor_data->>''75'' as mon75 -- 補液温度設定値
,monitor_data->>''76'' as mon76 -- 濾液速度
,monitor_data->>''77'' as mon77 -- 荷重計
,case when monitor_data->>''78'' is null then ''0'' else monitor_data->>''78'' end as mon78 -- 残り時間（補液完了）
,monitor_data->>''80'' as mon80 -- ⊿ＢＶ変化率
,monitor_data->>''85'' as mon85 -- ⊿BVリファレンスエリア上限
,monitor_data->>''86'' as mon86 -- ⊿BVリファレンスエリア下限
,monitor_data->>''88'' as mon88 -- PRR
,monitor_data->>''89'' as mon89 -- 再循環率測定結果（BVMS連携用）
,monitor_data->>''90'' as mon90 -- 最高血圧
,monitor_data->>''91'' as mon91 -- 最低血圧
,monitor_data->>''92'' as mon92 -- 平均血圧
,monitor_data->>''93'' as mon93 -- 脈拍
,monitor_data->>''94'' as mon94 -- 体温
,monitor_data->>''95'' as mon95 -- ⊿ＢＶ_5分平均値
,monitor_data->>''96'' as mon96 -- ⊿ＢＶ_最大最小を除いた5分平均値
,monitor_data->>''97'' as mon97 -- 推定血流量
,monitor_data->>''98'' as mon98 -- 血流量不足率

,monitor_data->>''38'' as mon38 -- Kt/V測定値
,monitor_data->>''79'' as mon79 -- URR
,monitor_data->>''100'' as mon100 -- ⊿BV(BVplus)
,monitor_data->>''101'' as mon101 -- Ht
,monitor_data->>''102'' as mon102 -- LDQb

,monitor_data->>''Z11'' as monZ1sigma -- 治療モード(Σ)
,monitor_data->>''Z21'' as monZ2sigma -- 工程状態(Σ)
,monitor_data->>''Z31'' as monZ3sigma -- 除水速度(Σ)
,monitor_data->>''Z41'' as monZ4sigma -- 血液流量(Σ)
,monitor_data->>''Z51'' as monZ5sigma -- シリンジ流量(Σ)
,monitor_data->>''Z61'' as monZ6sigma -- ろ過流量(Σ)
,monitor_data->>''Z71'' as monZ7sigma -- 透析液/ドレン流量(Σ)
,monitor_data->>''Z81'' as monZ8sigma -- 補液流量(Σ)
,monitor_data->>''Z91'' as monZ9sigma -- 透析液加温器温度(Σ)
,monitor_data->>''Z101'' as monZ10sigma -- 補液加温器温度(Σ)
,monitor_data->>''Z111'' as monZ11sigma -- 現在 除水量(Σ)
,monitor_data->>''Z121'' as monZ12sigma -- 現在 血液循環量(Σ)
,monitor_data->>''Z131'' as monZ13sigma -- 現在 ろ過量(Σ)
,monitor_data->>''Z141'' as monZ14sigma -- 現在 透析液/ドレン量(Σ)
,monitor_data->>''Z151'' as monZ15sigma -- 現在 補液量(Σ)
,monitor_data->>''Z161'' as monZ16sigma -- 治療時間(Σ)
,monitor_data->>''Z171'' as monZ17sigma -- シリンジ積算量(Σ)
,monitor_data->>''Z181'' as monZ18sigma -- 目標 除水量(Σ)
,monitor_data->>''Z191'' as monZ19sigma -- 目標 血液循環量(Σ)
,monitor_data->>''Z201'' as monZ20sigma -- 目標 ろ過量(Σ)
,monitor_data->>''Z211'' as monZ21sigma -- 目標 透析液/ドレン量(Σ)
,monitor_data->>''Z221'' as monZ22sigma -- 目標 補液量(Σ)
,monitor_data->>''Z231'' as monZ23sigma -- 目標 治療時間(Σ)
,monitor_data->>''Z241'' as monZ24sigma -- 脱血圧(Σ)
,monitor_data->>''Z251'' as monZ25sigma -- 入口圧(Σ)
,monitor_data->>''Z261'' as monZ26sigma -- 静脈圧(Σ)
,monitor_data->>''Z271'' as monZ27sigma -- ろ過圧(Σ)
,monitor_data->>''Z281'' as monZ28sigma -- 排気圧/2次膜圧(Σ)
,monitor_data->>''Z291'' as monZ29sigma -- TMP/TMP1(Σ)
,monitor_data->>''Z301'' as monZ30sigma -- TMP2(Σ)
,monitor_data->>''Z311'' as monZ31sigma -- 差圧(Σ)
,monitor_data->>''Z321'' as monZ32sigma -- 気泡検知警報(Σ)
,monitor_data->>''Z331'' as monZ33sigma -- 漏血警報(Σ)
,monitor_data->>''Z341'' as monZ34sigma -- 加温器警報(Σ)
,monitor_data->>''Z351'' as monZ35sigma -- 脱血圧警報(Σ)
,monitor_data->>''Z361'' as monZ36sigma -- 入口圧警報(Σ)
,monitor_data->>''Z371'' as monZ37sigma -- 静脈圧警報(Σ)
,monitor_data->>''Z381'' as monZ38sigma -- ろ過圧警報(Σ)
,monitor_data->>''Z391'' as monZ39sigma -- 排気圧/2次膜圧警報(Σ)
,monitor_data->>''Z401'' as monZ40sigma -- TMP警報(Σ)
,monitor_data->>''Z411'' as monZ41sigma -- TMP2警報(Σ)
,monitor_data->>''Z421'' as monZ42sigma -- 差圧警報(Σ)
,monitor_data->>''Z431'' as monZ43sigma -- その他警報(Σ)

,monitor_data->>''Z12'' as monZ1km -- 測定値 TMP(KM)
,monitor_data->>''Z22'' as monZ2km -- 測定値 入口圧(KM)
,monitor_data->>''Z32'' as monZ3km -- 測定値 返血圧(KM)
,monitor_data->>''Z42'' as monZ4km -- 測定値 2次膜圧（吸着圧）(KM)
,monitor_data->>''Z52'' as monZ5km -- 圧力上限警報設定値 TMP(KM)
,monitor_data->>''Z62'' as monZ6km -- 圧力上限警報設定値 入口圧(KM)
,monitor_data->>''Z72'' as monZ7km -- 圧力上限警報設定値 返血圧(KM)
,monitor_data->>''Z82'' as monZ8km -- 圧力上限警報設定値 2次膜圧（吸着圧）(KM)
,monitor_data->>''Z92'' as monZ9km -- 流量情報 BP瞬時流量(KM)
,monitor_data->>''Z102'' as monZ10km -- 流量情報 PP瞬時流量(KM)
,monitor_data->>''Z112'' as monZ11km -- 流量情報 DP瞬時流量(KM)
,monitor_data->>''Z122'' as monZ12km -- 流量情報 BP積算流量(KM)
,monitor_data->>''Z132'' as monZ13km -- 流量情報 PP積算流量(KM)
,monitor_data->>''Z142'' as monZ14km -- 流量情報 DP積算流量(KM)
,monitor_data->>''Z152'' as monZ15km -- 流量情報 除水積算流量(KM)
,monitor_data->>''Z162'' as monZ16km -- 流量情報 血漿処理目標値(KM)
,monitor_data->>''Z172'' as monZ17km -- その他情報 加温器温度(KM)
,monitor_data->>''Z182'' as monZ18km -- その他情報 バランス(KM)
,monitor_data->>''Z192'' as monZ19km -- その他情報 経過時間(KM)
,monitor_data->>''Z202'' as monZ20km -- その他情報 アラーム番号(KM)
,monitor_data->>''Z212'' as monZ21km -- その他情報 自己診断番号(KM)
,monitor_data->>''Z222'' as monZ22km -- その他情報 モード(KM)
,monitor_data->>''Z232'' as monZ23km -- その他情報 工程情報(KM)

,monitor_data->>''Z13'' as monZ1iq -- 治療経過時間(iQ)
,monitor_data->>''Z23'' as monZ2iq -- 除水速度(iQ)
,monitor_data->>''Z33'' as monZ3iq -- ろ過ポンプ流量(iQ)
,monitor_data->>''Z43'' as monZ4iq -- 補液ポンプ流量(iQ)
,monitor_data->>''Z53'' as monZ5iq -- 透析ポンプ流量(iQ)
,monitor_data->>''Z63'' as monZ6iq -- 血液ポンプ流量(iQ)
,monitor_data->>''Z73'' as monZ7iq -- シリンジポンプ流量(iQ)
,monitor_data->>''Z83'' as monZ8iq -- 除水量積算値(iQ)
,monitor_data->>''Z93'' as monZ9iq -- ろ過量積算値(iQ)
,monitor_data->>''Z103'' as monZ10iq -- 補液量積算値(iQ)
,monitor_data->>''Z113'' as monZ11iq -- 透析液量積算値(iQ)
,monitor_data->>''Z123'' as monZ12iq -- 血液循環量(iQ)
,monitor_data->>''Z133'' as monZ13iq -- シリンジポンプ積算値(iQ)
,monitor_data->>''Z143'' as monZ14iq -- 採血圧(iQ)
,monitor_data->>''Z153'' as monZ15iq -- 動脈圧(iQ)
,monitor_data->>''Z163'' as monZ16iq -- 静脈圧(iQ)
,monitor_data->>''Z173'' as monZ17iq -- ろ過圧(iQ)
,monitor_data->>''Z183'' as monZ18iq -- TMP(iQ)
,monitor_data->>''Z193'' as monZ19iq -- 分離ポンプ流量(iQ)
,monitor_data->>''Z203'' as monZ20iq -- 返漿ポンプ流量(iQ)
,monitor_data->>''Z213'' as monZ21iq -- ドレンポンプ流量(iQ)
,monitor_data->>''Z223'' as monZ22iq -- 分離量積算値(iQ)
,monitor_data->>''Z233'' as monZ23iq -- 返漿量積算値(iQ)
,monitor_data->>''Z243'' as monZ24iq -- ドレン量積算値(iQ)
,monitor_data->>''Z253'' as monZ25iq -- 血漿圧(iQ)
,monitor_data->>''Z263'' as monZ26iq -- 血漿入口圧(iQ)

,monitor_data->>''Z14'' as monZ1km90 -- 測定値 TMP圧(KM90)
,monitor_data->>''Z24'' as monZ2km90 -- 測定値 入口圧(KM90)
,monitor_data->>''Z34'' as monZ3km90 -- 測定値 返血圧(KM90)
,monitor_data->>''Z44'' as monZ4km90 -- 測定値 ろ過圧(KM90)
,monitor_data->>''Z54'' as monZ5km90 -- 測定値 浄化器圧(KM90)
,monitor_data->>''Z64'' as monZ6km90 -- 設定値 TMP圧(KM90)
,monitor_data->>''Z74'' as monZ7km90 -- 設定値 入口圧(KM90)
,monitor_data->>''Z84'' as monZ8km90 -- 設定値 返血圧・上限(KM90)
,monitor_data->>''Z94'' as monZ9km90 -- 設定値 返血圧・下限(KM90)
,monitor_data->>''Z104'' as monZ10km90 -- 設定値 浄化器圧(KM90)
,monitor_data->>''Z114'' as monZ11km90 -- 設定値 除水設定値(KM90)
,monitor_data->>''Z124'' as monZ12km90 -- 流量情報 血液ﾎﾟﾝﾌﾟ指令流量(KM90)
,monitor_data->>''Z134'' as monZ13km90 -- 流量情報 透析液ﾎﾟﾝﾌﾟ指令流量(KM90)
,monitor_data->>''Z144'' as monZ14km90 -- 流量情報 補充液ﾎﾟﾝﾌﾟ指令流量(KM90)
,monitor_data->>''Z154'' as monZ15km90 -- 流量情報 ろ液ﾎﾟﾝﾌﾟ指令流量(KM90)
,monitor_data->>''Z164'' as monZ16km90 -- 流量情報 血液ﾎﾟﾝﾌﾟ積算流量(KM90)
,monitor_data->>''Z174'' as monZ17km90 -- 流量情報 透析液ﾎﾟﾝﾌﾟ積算流量(KM90)
,monitor_data->>''Z184'' as monZ18km90 -- 流量情報 補充液ﾎﾟﾝﾌﾟ積算流量(KM90)
,monitor_data->>''Z194'' as monZ19km90 -- 流量情報 除水積算流量(KM90)
,monitor_data->>''Z204'' as monZ20km90 -- その他情報 加温器温度(KM90)
,monitor_data->>''Z214'' as monZ21km90 -- その他情報 除水差分/重量値(KM90)
,monitor_data->>''Z224'' as monZ22km90 -- その他情報 初期診断情報(KM90)
,monitor_data->>''Z234'' as monZ23km90 -- その他情報 ｱﾗｰﾑ情報1(KM90)
,monitor_data->>''Z244'' as monZ24km90 -- その他情報 ｱﾗｰﾑ情報2(KM90)
,monitor_data->>''Z254'' as monZ25km90 -- その他情報 ｱﾗｰﾑ情報3(KM90)
,monitor_data->>''Z264'' as monZ26km90 -- その他情報 ｱﾗｰﾑ情報4(KM90)
,monitor_data->>''Z274'' as monZ27km90 -- その他情報 ｱﾗｰﾑ情報5(KM90)
,monitor_data->>''Z284'' as monZ28km90 -- その他情報 ｱﾗｰﾑ情報6(KM90)
,monitor_data->>''Z294'' as monZ29km90 -- その他情報 ｱﾗｰﾑ情報7(KM90)
,monitor_data->>''Z304'' as monZ30km90 -- その他情報 ｱﾗｰﾑ情報8(KM90)
,monitor_data->>''Z314'' as monZ31km90 -- その他情報 ｱﾗｰﾑ情報9(KM90)
,monitor_data->>''Z324'' as monZ32km90 -- その他情報 ｱﾗｰﾑ情報10(KM90)
,monitor_data->>''Z334'' as monZ33km90 -- その他情報 注意情報(KM90)
,monitor_data->>''Z344'' as monZ34km90 -- 経過時間(KM90)
,monitor_data->>''Z354'' as monZ35km90 -- その他情報 用途(KM90)
,monitor_data->>''Z364'' as monZ36km90 -- その他情報 工程(KM90)
,monitor_data->>''Z374'' as monZ37km90 -- その他情報 動作日、時間(KM90)
,to_date(occur_date || '''', ''YYYYMMDD'') as occur_date -- 発生日時
,occur_date as origin_occur_date -- 発生日時(ソート用)
from
  mni_monitor
where
  ord_no = @ordNo and data_type = 1 and is_del = ''0''
order by origin_occur_date;', "up_date" = CURRENT_TIMESTAMP WHERE "sql_cd" = 106;


UPDATE "ntss"."sys_data_set" SET "sql" = 
'WITH prescription_data AS (
 SELECT
        CASE WHEN ( o ->> ''Rp'' ) = '''' THEN NULL
             ELSE ( o ->> ''Rp'' ) END AS rp,--RP番号
        ( o ->> ''unchg'' ) AS unchg,--unchg
        ( o ->> ''type'' ) AS TYPE,--type
        ( o ->> ''F1'' ) AS f1,--F1
        ( o ->> ''F2'' ) AS f2,--F2
        ( o ->> ''F3'' ) AS f3,--F3
        ( o ->> ''F4'' ) AS f4,--F4
        ( o ->> ''F5'' ) AS f5,--量
        ( o ->> ''F6'' ) AS f6,--単位
        ( o ->> ''R'' ) AS r,--薬剤名称
        to_date( op.issue_date, ''YYYYMMDD'' ) issue_date,--交付日
        to_date( op.expiration_date, ''YYYYMMDD'' ) expiration_date,--使用期限
        op.issue_state AS issue_state,--交付状態
        op.ord_prescription_no AS ord_prescription_no --処方オーダー番号
    FROM
        ord_prescription AS op,
        jsonb_array_elements ( prescription_detail ) AS o 
    WHERE
        op.pat_id = @patId 
     AND op.is_del = ''0'' 
     AND o ->> ''type'' <> ''0'' 
     AND op.ord_prescription_no = @ordPrescriptionNo 
    ORDER BY rp ASC NULLS LAST, TYPE ASC
)
SELECT
  CASE WHEN rp = LAG(rp) OVER(ORDER BY rp) THEN NULL
       ELSE rp END as rp,
  unchg,
  TYPE,
  f1,
  f2,
  f3,
  f4,
  f5,
  f6,
  r,
  issue_date,
  expiration_date,
  issue_state,
  ord_prescription_no
FROM prescription_data;', "detail" = (
  select jsonb_agg (
    case when tmp.de->>'data_name' = '交付日' then tmp.de || json_build_object('data_class', '処方箋情報')::jsonb
         when tmp.de->>'data_name' = '使用期限' then tmp.de || json_build_object('data_class', '処方箋情報')::jsonb
         else tmp.de
    end 
  )
  from (
    select jsonb_array_elements(detail) as de from sys_data_set where sql_cd = 138
  ) tmp
), "up_date" = CURRENT_TIMESTAMP WHERE "sql_cd" = 138;
