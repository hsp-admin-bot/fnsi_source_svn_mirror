DELETE FROM "ntss"."sys_data_set" where sql_cd in (106);
INSERT INTO "ntss"."sys_data_set" ("sql_cd", "sql", "db_class", "detail", "can_repeat", "use_application", "report_class", "memo", "reg_date", "up_date", "pre_sql_info") VALUES (106, 'select b.* from (select
CASE WHEN (monitor_data->>''1'') IS NULL THEN ''0'' ELSE  (monitor_data->>''1'') END  as mon1 -- 経過時間
,monitor_data->>''2'' as mon2 -- 経過時間（ＥＣＵＭ）
,monitor_data->>''3'' as mon3 -- 残り時間（除水完了）
,monitor_data->>''4'' as mon4 -- 残り時間（透析完了）
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
,monitor_data->>''78'' as mon78 -- 残り時間（補液完了）
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
from
  mni_monitor
where
  ord_no = @ordNo and data_type = 1 and is_del = ''0'' and ((monitor_data->>''1'')::INTEGER = 0 OR (monitor_data->>''1'') IS NULL) ORDER BY occur_date::timestamp  asc) b
UNION ALL 
SELECT A.* FROM (select
monitor_data->>''1'' as mon1 -- 経過時間
,monitor_data->>''2'' as mon2 -- 経過時間（ＥＣＵＭ）
,monitor_data->>''3'' as mon3 -- 残り時間（除水完了）
,monitor_data->>''4'' as mon4 -- 残り時間（透析完了）
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
,monitor_data->>''78'' as mon78 -- 残り時間（補液完了）
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
from
  mni_monitor
where
  ord_no = @ordNo and data_type = 1 and is_del = ''0'' and (monitor_data->>''1'')::INTEGER > 0
	ORDER BY monitor_data->>''1'' asc,occur_date::timestamp asc) A


	', 2, '[{"preview": "00：11", "can_calc": "0", "data_code": "mon1", "data_name": "経過時間", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "mon1", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00：12", "can_calc": "0", "data_code": "mon2", "data_name": "経過時間（ＥＣＵＭ）", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "mon2", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00：13", "can_calc": "0", "data_code": "mon3", "data_name": "残り時間（除水完了）", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "mon3", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00：14", "can_calc": "0", "data_code": "mon4", "data_name": "残り時間（透析完了）", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "mon4", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.21", "can_calc": "0", "data_code": "mon5", "data_name": "除水積算値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon5", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.18", "can_calc": "0", "data_code": "mon6", "data_name": "除水速度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon6", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8.58", "can_calc": "0", "data_code": "mon7", "data_name": "血液循環量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon7", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "0", "data_code": "mon8", "data_name": "血流量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon8", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "4.4", "can_calc": "0", "data_code": "mon9", "data_name": "ＩＰ総量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon9", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.2", "can_calc": "0", "data_code": "mon10", "data_name": "ＩＰ速度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon10", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "138", "can_calc": "0", "data_code": "mon11", "data_name": "静脈圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon11", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "144", "can_calc": "0", "data_code": "mon12", "data_name": "透析液圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon12", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-7", "can_calc": "0", "data_code": "mon13", "data_name": "TMP", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon13", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-830", "can_calc": "0", "data_code": "mon14", "data_name": "ダイアライザ入口圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon14", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-925", "can_calc": "0", "data_code": "mon15", "data_name": "ダイアライザ差圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon15", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-367", "can_calc": "0", "data_code": "mon16", "data_name": "血液入口～静脈平均圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon16", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon17", "data_name": "⊿BV", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon17", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "0", "data_code": "mon18", "data_name": "バイカーボ濃度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon18", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "13.8", "can_calc": "0", "data_code": "mon19", "data_name": "透析液濃度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon19", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon20", "data_name": "Ｎａ濃度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon20", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.2", "can_calc": "0", "data_code": "mon21", "data_name": "透析液温度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon21", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "mon22", "data_name": "透析液流量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon22", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon23", "data_name": "漏血量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon23", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "38", "can_calc": "0", "data_code": "mon24", "data_name": "給液圧（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon24", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "22", "can_calc": "0", "data_code": "mon25", "data_name": "給液圧（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon25", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-72.13", "can_calc": "0", "data_code": "mon26", "data_name": "ＵＦＲ", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon26", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon27", "data_name": "ＵＦＲ低下率", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon27", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "0", "data_code": "mon28", "data_name": "初期ＵＦＲ測定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon28", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon29", "data_name": "TMP補正値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon29", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon30", "data_name": "透析運転時間", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon30", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "HD", "can_calc": "0", "data_code": "mon31", "data_name": "治療モード", "data_type": "string", "conv_table": [{"code": "-1", "disp": "不明", "item": "不明"}, {"code": "0", "disp": "HD", "item": "HD"}, {"code": "1", "disp": "ECUM", "item": "ECUM"}, {"code": "2", "disp": "HDF", "item": "HDF"}, {"code": "3", "disp": "HF", "item": "HF"}, {"code": "4", "disp": "HD+補液", "item": "HD+補液"}, {"code": "5", "disp": "ECUM+補液", "item": "ECUM+補液"}, {"code": "6", "disp": "AFBF", "item": "AFBF"}, {"code": "7", "disp": "OHDF", "item": "OHDF"}, {"code": "8", "disp": "OHF", "item": "OHF"}, {"code": "9", "disp": "特殊浄化", "item": "特殊浄化"}, {"code": "10", "disp": "I-HDF", "item": "I-HDF"}], "data_class": "モニタ", "field_name": "mon31", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.85", "can_calc": "0", "data_code": "mon32", "data_name": "除水目標値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon32", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "0", "data_code": "mon33", "data_name": "除水速度設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon33", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.5", "can_calc": "0", "data_code": "mon34", "data_name": "透析液温度設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon34", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "500", "can_calc": "0", "data_code": "mon35", "data_name": "透析液流量設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon35", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "220", "can_calc": "0", "data_code": "mon36", "data_name": "血流量設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon36", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.2", "can_calc": "0", "data_code": "mon37", "data_name": "ＩＰ速度設定", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon37", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "0", "data_code": "mon39", "data_name": "静脈圧警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon39", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "0", "data_code": "mon40", "data_name": "静脈圧警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon40", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "0", "data_code": "mon41", "data_name": "透析液圧警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon41", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "0", "data_code": "mon42", "data_name": "透析液圧警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon42", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "0", "data_code": "mon43", "data_name": "TMP警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon43", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "0", "data_code": "mon44", "data_name": "TMP警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon44", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50", "can_calc": "0", "data_code": "mon45", "data_name": "ダイアライザ入口圧警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon45", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-50", "can_calc": "0", "data_code": "mon46", "data_name": "ダイアライザ入口圧警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon46", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "20", "can_calc": "0", "data_code": "mon47", "data_name": "ダイアライザ差圧警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon47", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20", "can_calc": "0", "data_code": "mon48", "data_name": "ダイアライザ差圧警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon48", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-20.0", "can_calc": "0", "data_code": "mon49", "data_name": "⊿ＢＶ低下警報点1", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon49", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-40.0", "can_calc": "0", "data_code": "mon50", "data_name": "⊿ＢＶ低下警報点2", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon50", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-10.0", "can_calc": "0", "data_code": "mon51", "data_name": "⊿BV変化率警報点", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon51", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "0", "data_code": "mon54", "data_name": "バイカーボ濃度警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon54", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "0", "data_code": "mon55", "data_name": "バイカーボ濃度警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon55", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon56", "data_name": "透析液濃度警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon56", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon57", "data_name": "透析液濃度警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon57", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon58", "data_name": "Ｎａ濃度警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon58", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon59", "data_name": "Ｎａ濃度警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon59", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "40.0", "can_calc": "0", "data_code": "mon60", "data_name": "透析液温度警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon60", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "33.0", "can_calc": "0", "data_code": "mon61", "data_name": "透析液温度警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon61", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon62", "data_name": "漏血量警報", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon62", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "45", "can_calc": "0", "data_code": "mon63", "data_name": "給水圧警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon63", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8", "can_calc": "0", "data_code": "mon64", "data_name": "給水圧警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon64", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-40.00", "can_calc": "0", "data_code": "mon65", "data_name": "初期ＵＦＲ警報点（上限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon65", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-100.00", "can_calc": "0", "data_code": "mon66", "data_name": "初期ＵＦＲ警報点（下限）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon66", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "29", "can_calc": "0", "data_code": "mon67", "data_name": "ＵＦＲ低下率警報", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon67", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.1", "can_calc": "0", "data_code": "mon68", "data_name": "Kt/V", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon68", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8.58", "can_calc": "0", "data_code": "mon69", "data_name": "運転中の血流量積算値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon69", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "8", "can_calc": "0", "data_code": "mon70", "data_name": "補液量設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon70", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "0", "data_code": "mon71", "data_name": "補液速度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon71", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.4", "can_calc": "0", "data_code": "mon72", "data_name": "補液量現在値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon72", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2.0", "can_calc": "0", "data_code": "mon73", "data_name": "補液速度設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon73", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.4", "can_calc": "0", "data_code": "mon74", "data_name": "補液温度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon74", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.4", "can_calc": "0", "data_code": "mon75", "data_name": "補液温度設定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon75", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.00", "can_calc": "0", "data_code": "mon76", "data_name": "濾液速度", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon76", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "6.62", "can_calc": "0", "data_code": "mon77", "data_name": "荷重計", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon77", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "00：15", "can_calc": "0", "data_code": "mon78", "data_name": "残り時間（補液完了）", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "mon78", "disp_format": "hh:mm", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "-5.0", "can_calc": "0", "data_code": "mon80", "data_name": "⊿ＢＶ変化率", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon80", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon85", "data_name": "⊿BVリファレンスエリア上限", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon85", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon86", "data_name": "⊿BVリファレンスエリア下限", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon86", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon88", "data_name": "PRR", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon88", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0", "can_calc": "0", "data_code": "mon89", "data_name": "再循環率測定結果（BVMS連携用）", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon89", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "132", "can_calc": "0", "data_code": "mon90", "data_name": "最高血圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "88", "can_calc": "0", "data_code": "mon91", "data_name": "最低血圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon91", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "102", "can_calc": "0", "data_code": "mon92", "data_name": "平均血圧", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon92", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "66", "can_calc": "0", "data_code": "mon93", "data_name": "脈拍", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon93", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "36.6", "can_calc": "0", "data_code": "mon94", "data_name": "体温", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon94", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon95", "data_name": "⊿ＢＶ_5分平均値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon95", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "0.0", "can_calc": "0", "data_code": "mon96", "data_name": "⊿ＢＶ_最大最小を除いた5分平均値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon96", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "1.51", "can_calc": "0", "data_code": "mon38", "data_name": "Kt/V測定値", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon38", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "35.5", "can_calc": "0", "data_code": "mon79", "data_name": "URR", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon79", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "300", "can_calc": "0", "data_code": "mon97", "data_name": "推定血流量", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon97", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "50.1", "can_calc": "0", "data_code": "mon98", "data_name": "血流量不足率", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon98", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "SCUF", "can_calc": "0", "data_code": "monz1sigma", "data_name": "治療モード(Σ)", "data_type": "string", "conv_table": [{"code": "00", "disp": "SCUF", "item": "SCUF"}, {"code": "01", "disp": "CHF 前希釈", "item": "CHF 前希釈"}, {"code": "02", "disp": "CHF 後希釈", "item": "CHF 後希釈"}, {"code": "03", "disp": "CHD", "item": "CHD"}, {"code": "04", "disp": "CHDF 前希釈", "item": "CHDF 前希釈"}, {"code": "05", "disp": "CHDF 後希釈", "item": "CHDF 後希釈"}, {"code": "06", "disp": "PE", "item": "PE"}, {"code": "07", "disp": "PA プラソーバ", "item": "PA プラソーバ"}, {"code": "08", "disp": "PA イムソーバ", "item": "PA イムソーバ"}, {"code": "09", "disp": "DFPP 補液無し", "item": "DFPP 補液無し"}, {"code": "10", "disp": "DFPP 補液有り", "item": "DFPP 補液有り"}, {"code": "11", "disp": "HA", "item": "HA"}, {"code": "12", "disp": "LCAP", "item": "LCAP"}, {"code": "13", "disp": "(腹水)", "item": "(腹水)"}], "data_class": "モニタ", "field_name": "monz1sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "治療", "can_calc": "0", "data_code": "monz2sigma", "data_name": "工程状態(Σ)", "data_type": "string", "conv_table": [{"code": "1", "disp": "治療", "item": "治療"}, {"code": "2", "disp": "治療停止", "item": "治療停止"}, {"code": "3", "disp": "回収", "item": "回収"}, {"code": "4", "disp": "回収 廃棄", "item": "回収 廃棄"}, {"code": "5", "disp": "準備", "item": "準備"}, {"code": "6", "disp": "点検", "item": "点検"}, {"code": "7", "disp": "その他", "item": "その他"}], "data_class": "モニタ", "field_name": "monz2sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz3sigma", "data_name": "除水速度(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz3sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz4sigma", "data_name": "血液流量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz4sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz5sigma", "data_name": "シリンジ流量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz5sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz6sigma", "data_name": "ろ過流量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz6sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz7sigma", "data_name": "透析液/ドレン流量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz7sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz8sigma", "data_name": "補液流量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz8sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz9sigma", "data_name": "透析液加温器温度(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz9sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz10sigma", "data_name": "補液加温器温度(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz10sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz11sigma", "data_name": "現在 除水量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz11sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz12sigma", "data_name": "現在 血液循環量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz12sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz13sigma", "data_name": "現在 ろ過量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz13sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz14sigma", "data_name": "現在 透析液/ドレン量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz14sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz15sigma", "data_name": "現在 補液量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz15sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz16sigma", "data_name": "治療時間(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz16sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz17sigma", "data_name": "シリンジ積算量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz17sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz18sigma", "data_name": "目標 除水量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz18sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz19sigma", "data_name": "目標 血液循環量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz19sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz20sigma", "data_name": "目標 ろ過量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz20sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz21sigma", "data_name": "目標 透析液/ドレン量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz21sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz22sigma", "data_name": "目標 補液量(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz22sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz23sigma", "data_name": "目標 治療時間(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz23sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz24sigma", "data_name": "脱血圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz24sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz25sigma", "data_name": "入口圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz25sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz26sigma", "data_name": "静脈圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz26sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz27sigma", "data_name": "ろ過圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz27sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz28sigma", "data_name": "排気圧/2次膜圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz28sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz29sigma", "data_name": "TMP/TMP1(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz29sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz30sigma", "data_name": "TMP2(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz30sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz31sigma", "data_name": "差圧(Σ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz31sigma", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz32sigma", "data_name": "気泡検知警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz32sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz33sigma", "data_name": "漏血警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz33sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz34sigma", "data_name": "加温器警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz34sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz35sigma", "data_name": "脱血圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz35sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz36sigma", "data_name": "入口圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz36sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz37sigma", "data_name": "静脈圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz37sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz38sigma", "data_name": "ろ過圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz38sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz39sigma", "data_name": "排気圧/2次膜圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz39sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz40sigma", "data_name": "TMP警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz40sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz41sigma", "data_name": "TMP2警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz41sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz42sigma", "data_name": "差圧警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz42sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz43sigma", "data_name": "その他警報(Σ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz43sigma", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz1km", "data_name": "測定値 TMP(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz1km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz2km", "data_name": "測定値 入口圧(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz2km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz3km", "data_name": "測定値 返血圧(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz3km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz4km", "data_name": "測定値 2次膜圧（吸着圧）(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz4km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz5km", "data_name": "圧力上限警報設定値 TMP(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz5km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz6km", "data_name": "圧力上限警報設定値 入口圧(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz6km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz7km", "data_name": "圧力上限警報設定値 返血圧(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz7km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz8km", "data_name": "圧力上限警報設定値 2次膜圧（吸着圧）(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz8km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz9km", "data_name": "流量情報 BP瞬時流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz9km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz10km", "data_name": "流量情報 PP瞬時流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz10km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz11km", "data_name": "流量情報 DP瞬時流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz11km", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz12km", "data_name": "流量情報 BP積算流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz12km", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz13km", "data_name": "流量情報 PP積算流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz13km", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz14km", "data_name": "流量情報 DP積算流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz14km", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz15km", "data_name": "流量情報 除水積算流量(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz15km", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz16km", "data_name": "流量情報 血漿処理目標値(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz16km", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz17km", "data_name": "その他情報 加温器温度(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz17km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz18km", "data_name": "その他情報 バランス(KM)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz18km", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz19km", "data_name": "その他情報 経過時間(KM)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz19km", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz20km", "data_name": "その他情報 アラーム番号(KM)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz20km", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz21km", "data_name": "その他情報 自己診断番号(KM)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz21km", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "情報なし", "can_calc": "0", "data_code": "monz22km", "data_name": "その他情報 モード(KM)", "data_type": "string", "conv_table": [{"code": "0", "disp": "情報なし", "item": "情報なし"}, {"code": "1", "disp": "CHDF", "item": "CHDF"}, {"code": "2", "disp": "CHD", "item": "CHD"}, {"code": "3", "disp": "CHF", "item": "CHF"}, {"code": "4", "disp": "PE", "item": "PE"}, {"code": "5", "disp": "PP", "item": "PP"}, {"code": "6", "disp": "DF", "item": "DF"}, {"code": "7", "disp": "手動", "item": "手動"}], "data_class": "モニタ", "field_name": "monz22km", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "情報なし", "can_calc": "0", "data_code": "monz23km", "data_name": "その他情報 工程情報(KM)", "data_type": "string", "conv_table": [{"code": "0", "disp": "情報なし", "item": "情報なし"}, {"code": "1", "disp": "洗浄工程", "item": "洗浄工程"}, {"code": "2", "disp": "臨床工程", "item": "臨床工程"}, {"code": "3", "disp": "回収工程", "item": "回収工程"}, {"code": "4", "disp": "手動工程", "item": "手動工程"}], "data_class": "モニタ", "field_name": "monz23km", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz1iq", "data_name": "治療経過時間(iQ)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz1iq", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz2iq", "data_name": "除水速度(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz2iq", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz3iq", "data_name": "ろ過ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz3iq", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz4iq", "data_name": "補液ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz4iq", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz5iq", "data_name": "透析ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz5iq", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz6iq", "data_name": "血液ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz6iq", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz7iq", "data_name": "シリンジポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz7iq", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz8iq", "data_name": "除水量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz8iq", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz9iq", "data_name": "ろ過量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz9iq", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz10iq", "data_name": "補液量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz10iq", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz11iq", "data_name": "透析液量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz11iq", "disp_format": "0.000", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz12iq", "data_name": "血液循環量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz12iq", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz13iq", "data_name": "シリンジポンプ積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz13iq", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz14iq", "data_name": "採血圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz14iq", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz15iq", "data_name": "動脈圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz15iq", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz16iq", "data_name": "静脈圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz16iq", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz17iq", "data_name": "ろ過圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz17iq", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz18iq", "data_name": "TMP(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz18iq", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz19iq", "data_name": "分離ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz19iq", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz20iq", "data_name": "返漿ポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz20iq", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz21iq", "data_name": "ドレンポンプ流量(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz21iq", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz22iq", "data_name": "分離量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz22iq", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz23iq", "data_name": "返漿量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz23iq", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz24iq", "data_name": "ドレン量積算値(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz24iq", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz25iq", "data_name": "血漿圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz25iq", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz26iq", "data_name": "血漿入口圧(iQ)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz26iq", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz1km90", "data_name": "測定値 TMP圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz1km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz2km90", "data_name": "測定値 入口圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz2km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz3km90", "data_name": "測定値 返血圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz3km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz4km90", "data_name": "測定値 ろ過圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz4km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz5km90", "data_name": "測定値 浄化器圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz5km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz6km90", "data_name": "設定値 TMP圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz6km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz7km90", "data_name": "設定値 入口圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz7km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz8km90", "data_name": "設定値 返血圧・上限(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz8km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz9km90", "data_name": "設定値 返血圧・下限(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz9km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz10km90", "data_name": "設定値 浄化器圧(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz10km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz11km90", "data_name": "設定値 除水設定値(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz11km90", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz12km90", "data_name": "流量情報 血液ﾎﾟﾝﾌﾟ指令流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz12km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz13km90", "data_name": "流量情報 透析液ﾎﾟﾝﾌﾟ指令流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz13km90", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz14km90", "data_name": "流量情報 補充液ﾎﾟﾝﾌﾟ指令流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz14km90", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz15km90", "data_name": "流量情報 ろ液ﾎﾟﾝﾌﾟ指令流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz15km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz16km90", "data_name": "流量情報 血液ﾎﾟﾝﾌﾟ積算流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz16km90", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz17km90", "data_name": "流量情報 透析液ﾎﾟﾝﾌﾟ積算流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz17km90", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz18km90", "data_name": "流量情報 補充液ﾎﾟﾝﾌﾟ積算流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz18km90", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz19km90", "data_name": "流量情報 除水積算流量(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz19km90", "disp_format": "0.00", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz20km90", "data_name": "その他情報 加温器温度(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz20km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz21km90", "data_name": "その他情報 除水差分/重量値(KM90)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "monz21km90", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz22km90", "data_name": "その他情報 初期診断情報(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz22km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz23km90", "data_name": "その他情報 ｱﾗｰﾑ情報1(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz23km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz24km90", "data_name": "その他情報 ｱﾗｰﾑ情報2(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz24km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz25km90", "data_name": "その他情報 ｱﾗｰﾑ情報3(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz25km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz26km90", "data_name": "その他情報 ｱﾗｰﾑ情報4(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz26km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz27km90", "data_name": "その他情報 ｱﾗｰﾑ情報5(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz27km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz28km90", "data_name": "その他情報 ｱﾗｰﾑ情報6(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz28km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz29km90", "data_name": "その他情報 ｱﾗｰﾑ情報7(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz29km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz30km90", "data_name": "その他情報 ｱﾗｰﾑ情報8(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz30km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz31km90", "data_name": "その他情報 ｱﾗｰﾑ情報9(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz31km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz32km90", "data_name": "その他情報 ｱﾗｰﾑ情報10(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz32km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz33km90", "data_name": "その他情報 注意情報(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz33km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz34km90", "data_name": "経過時間(KM9000)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz34km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz35km90", "data_name": "その他情報 用途(KM90)", "data_type": "string", "conv_table": [{"code": "1", "disp": "CRRT", "item": "CRRT"}, {"code": "2", "disp": "ECUM", "item": "ECUM"}, {"code": "3", "disp": "DF", "item": "DF"}, {"code": "4", "disp": "DFT", "item": "DFT"}, {"code": "5", "disp": "PP", "item": "PP"}, {"code": "6", "disp": "PE", "item": "PE"}, {"code": "7", "disp": "DHP", "item": "DHP"}, {"code": "8", "disp": "ASCT", "item": "ASCT"}, {"code": "9", "disp": "TEST", "item": "TEST"}], "data_class": "モニタ", "field_name": "monz35km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz36km90", "data_name": "その他情報 工程(KM90)", "data_type": "string", "conv_table": [{"code": "1", "disp": "装着", "item": "装着"}, {"code": "2", "disp": "確認", "item": "確認"}, {"code": "3", "disp": "洗浄", "item": "洗浄"}, {"code": "4", "disp": "臨床", "item": "臨床"}, {"code": "5", "disp": "回収", "item": "回収"}], "data_class": "モニタ", "field_name": "monz36km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "monz37km90", "data_name": "その他情報 動作日、時間(KM90)", "data_type": "string", "conv_table": [], "data_class": "モニタ", "field_name": "monz37km90", "disp_format": "", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "mon100", "data_name": "⊿BV(BVplus)", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon100", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "mon101", "data_name": "Ht", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon101", "disp_format": "0.0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "", "can_calc": "0", "data_code": "mon102", "data_name": "LDQb", "data_type": "decimal", "conv_table": [], "data_class": "モニタ", "field_name": "mon102", "disp_format": "0", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}, {"preview": "2020/03/25", "can_calc": "0", "data_code": "occur_date", "data_name": "発生日時", "data_type": "DateTime", "conv_table": [], "data_class": "モニタ", "field_name": "occur_date", "disp_format": "yyyy/mm/dd", "data_category": "実績", "facility_table": "", "facility_filter_type": "0"}]', '1', '{"applications": [1]}', '{"classes": [1, 2, 3, 9, 10, 11]}', '実績：モニタ @ordNo 使用', '2020-03-31 23:59:59', CURRENT_TIMESTAMP, NULL);
