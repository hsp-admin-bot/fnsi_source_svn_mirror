with base as (
    select
        ord_no,
        pat_id,
        --//add #10412->#10439 次患者情報1の自動プライミング開始時刻の送信データ不正 朴 start
        ind_treat_start_time
        --//add #10412->#10439 次患者情報1の自動プライミング開始時刻の送信データ不正 朴 end
    from
        ord_main
    where
        ord_no = /*ordNo*/0
)
select
    to_json(dev) as dev,
    to_json(pat) as pat
from
    (
        select
            *
        from
            (
                select
                    ind_device_set_info#>'{ufr,dev,A,290}' as "A290", --ＵＦＲプログラム電源ＳＷ
                    ind_device_set_info#>'{ufr,dev,A,311}' as "A311", --ＵＦＲプログラム最終位置
                    ind_device_set_info#>'{ufr,dev,A,312}' as "A312", --ＵＦＲプログラムコース
                    ind_device_set_info#>'{ufr,dev,A,291}' as "A291", --治療モード１
                    ind_device_set_info#>'{ufr,dev,A,292}' as "A292", --治療モード２
                    ind_device_set_info#>'{ufr,dev,A,293}' as "A293", --治療モード３
                    ind_device_set_info#>'{ufr,dev,A,294}' as "A294", --治療モード４
                    ind_device_set_info#>'{ufr,dev,A,295}' as "A295", --治療モード５
                    ind_device_set_info#>'{ufr,dev,A,296}' as "A296", --治療モード６
                    ind_device_set_info#>'{ufr,dev,A,297}' as "A297", --治療モード７
                    ind_device_set_info#>'{ufr,dev,A,298}' as "A298", --治療モード８
                    ind_device_set_info#>'{ufr,dev,A,299}' as "A299", --治療モード９
                    ind_device_set_info#>'{ufr,dev,A,300}' as "A300", --治療モード１０
                    ind_device_set_info#>'{ufr,dev,B,0}' as "B000", --UFRプログラム工程1の指数
                    ind_device_set_info#>'{ufr,dev,B,1}' as "B001", --UFRプログラム工程2の指数
                    ind_device_set_info#>'{ufr,dev,B,2}' as "B002", --UFRプログラム工程3の指数
                    ind_device_set_info#>'{ufr,dev,B,3}' as "B003", --UFRプログラム工程4の指数
                    ind_device_set_info#>'{ufr,dev,B,4}' as "B004", --UFRプログラム工程5の指数
                    ind_device_set_info#>'{ufr,dev,B,5}' as "B005", --UFRプログラム工程6の指数
                    ind_device_set_info#>'{ufr,dev,B,6}' as "B006", --UFRプログラム工程7の指数
                    ind_device_set_info#>'{ufr,dev,B,7}' as "B007", --UFRプログラム工程8の指数
                    ind_device_set_info#>'{ufr,dev,B,8}' as "B008", --UFRプログラム工程9の指数
                    ind_device_set_info#>'{ufr,dev,B,9}' as "B009", --UFRプログラム工程10の指数
                    ind_device_set_info#>'{ufr,dev,A,301}' as "A301", --ＵＦＲプログラム指数１
                    ind_device_set_info#>'{ufr,dev,A,302}' as "A302", --ＵＦＲプログラム指数２
                    ind_device_set_info#>'{ufr,dev,A,303}' as "A303", --ＵＦＲプログラム指数３
                    ind_device_set_info#>'{ufr,dev,A,304}' as "A304", --ＵＦＲプログラム指数４
                    ind_device_set_info#>'{ufr,dev,A,305}' as "A305", --ＵＦＲプログラム指数５
                    ind_device_set_info#>'{ufr,dev,A,306}' as "A306", --ＵＦＲプログラム指数６
                    ind_device_set_info#>'{ufr,dev,A,307}' as "A307", --ＵＦＲプログラム指数７
                    ind_device_set_info#>'{ufr,dev,A,308}' as "A308", --ＵＦＲプログラム指数８
                    ind_device_set_info#>'{ufr,dev,A,309}' as "A309", --ＵＦＲプログラム指数９
                    ind_device_set_info#>'{ufr,dev,A,310}' as "A310", --ＵＦＲプログラム指数１０
                    ind_device_set_info#>'{ufr,dev,A,313}' as "A313", --ＵＦＲプログラム開始数値
                    ind_device_set_info#>'{ufr,dev,A,314}' as "A314", --ＵＦＲプログラム終了数値
                    ind_device_set_info#>'{na,dev,A,315}' as "A315", --Ｎａ注入プログラム電源ＳＷ
                    ind_device_set_info#>'{na,dev,A,326}' as "A326", --Ｎａ注入プログラム切替時間
                    ind_device_set_info#>'{na,dev,A,328}' as "A328", --Ｎａ注入プログラムコース
                    ind_device_set_info#>'{na,dev,A,327}' as "A327", --Ｎａ注入プログラム　ＵＦＲプロとの連動選択
                    ind_device_set_info#>'{na,dev,A,316}' as "A316", --Ｎａ注入プログラム設定１
                    ind_device_set_info#>'{na,dev,A,317}' as "A317", --Ｎａ注入プログラム設定２
                    ind_device_set_info#>'{na,dev,A,318}' as "A318", --Ｎａ注入プログラム設定３
                    ind_device_set_info#>'{na,dev,A,319}' as "A319", --Ｎａ注入プログラム設定４
                    ind_device_set_info#>'{na,dev,A,320}' as "A320", --Ｎａ注入プログラム設定５
                    ind_device_set_info#>'{na,dev,A,321}' as "A321", --Ｎａ注入プログラム設定６
                    ind_device_set_info#>'{na,dev,A,322}' as "A322", --Ｎａ注入プログラム設定７
                    ind_device_set_info#>'{na,dev,A,323}' as "A323", --Ｎａ注入プログラム設定８
                    ind_device_set_info#>'{na,dev,A,324}' as "A324", --Ｎａ注入プログラム設定９
                    ind_device_set_info#>'{na,dev,A,325}' as "A325", --Ｎａ注入プログラム設定１０
                    ind_device_set_info#>'{na,dev,A,329}' as "A329", --Ｎａ注入プログラム開始数値
                    ind_device_set_info#>'{na,dev,A,330}' as "A330", --Ｎａ注入プログラム終了数値
                    ind_device_set_info#>'{na,dev,A,184}' as "A184", --Ｎａ注入濃度操作範囲上限
                    ind_device_set_info#>'{dc,dev,A,340}' as "A340", --濃度プログラム電源ＳＷ
                    ind_device_set_info#>'{dc,dev,A,368}' as "A368", --濃度プログラム　ＵＦＲプロとの連動選択
                    ind_device_set_info#>'{dc,dev,A,367}' as "A367", --濃度プログラム切替時間
                    ind_device_set_info#>'{dc,dev,A,361}' as "A361", --透析液濃度プログラムステップ切替無し　コース
                    ind_device_set_info#>'{dc,dev,B,20}' as "B020", --A液濃度プログラム工程1のA液濃度
                    ind_device_set_info#>'{dc,dev,B,21}' as "B021", --A液濃度プログラム工程2のA液濃度
                    ind_device_set_info#>'{dc,dev,B,22}' as "B022", --A液濃度プログラム工程3のA液濃度
                    ind_device_set_info#>'{dc,dev,B,23}' as "B023", --A液濃度プログラム工程4のA液濃度
                    ind_device_set_info#>'{dc,dev,B,24}' as "B024", --A液濃度プログラム工程5のA液濃度
                    ind_device_set_info#>'{dc,dev,B,25}' as "B025", --A液濃度プログラム工程6のA液濃度
                    ind_device_set_info#>'{dc,dev,B,26}' as "B026", --A液濃度プログラム工程7のA液濃度
                    ind_device_set_info#>'{dc,dev,B,27}' as "B027", --A液濃度プログラム工程8のA液濃度
                    ind_device_set_info#>'{dc,dev,B,28}' as "B028", --A液濃度プログラム工程9のA液濃度
                    ind_device_set_info#>'{dc,dev,B,29}' as "B029", --A液濃度プログラム工程10のA液濃度
                    ind_device_set_info#>'{dc,dev,A,341}' as "A341", --透析液濃度プログラム設定１
                    ind_device_set_info#>'{dc,dev,A,342}' as "A342", --透析液濃度プログラム設定２
                    ind_device_set_info#>'{dc,dev,A,343}' as "A343", --透析液濃度プログラム設定３
                    ind_device_set_info#>'{dc,dev,A,344}' as "A344", --透析液濃度プログラム設定４
                    ind_device_set_info#>'{dc,dev,A,345}' as "A345", --透析液濃度プログラム設定５
                    ind_device_set_info#>'{dc,dev,A,346}' as "A346", --透析液濃度プログラム設定６
                    ind_device_set_info#>'{dc,dev,A,347}' as "A347", --透析液濃度プログラム設定７
                    ind_device_set_info#>'{dc,dev,A,348}' as "A348", --透析液濃度プログラム設定８
                    ind_device_set_info#>'{dc,dev,A,349}' as "A349", --透析液濃度プログラム設定９
                    ind_device_set_info#>'{dc,dev,A,350}' as "A350", --透析液濃度プログラム設定１０
                    ind_device_set_info#>'{dc,dev,A,362}' as "A362", --透析液濃度プログラム開始数値
                    ind_device_set_info#>'{dc,dev,A,363}' as "A363", --透析液濃度プログラム終了数値
                    ind_device_set_info#>'{dc,dev,A,364}' as "A364", --Ｂ液濃度プログラムステップ切替無し　コース
                    ind_device_set_info#>'{dc,dev,B,10}' as "B010", --B液濃度プログラム工程1のB液濃度
                    ind_device_set_info#>'{dc,dev,B,11}' as "B011", --B液濃度プログラム工程2のB液濃度
                    ind_device_set_info#>'{dc,dev,B,12}' as "B012", --B液濃度プログラム工程3のB液濃度
                    ind_device_set_info#>'{dc,dev,B,13}' as "B013", --B液濃度プログラム工程4のB液濃度
                    ind_device_set_info#>'{dc,dev,B,14}' as "B014", --B液濃度プログラム工程5のB液濃度
                    ind_device_set_info#>'{dc,dev,B,15}' as "B015", --B液濃度プログラム工程6のB液濃度
                    ind_device_set_info#>'{dc,dev,B,16}' as "B016", --B液濃度プログラム工程7のB液濃度
                    ind_device_set_info#>'{dc,dev,B,17}' as "B017", --B液濃度プログラム工程8のB液濃度
                    ind_device_set_info#>'{dc,dev,B,18}' as "B018", --B液濃度プログラム工程9のB液濃度
                    ind_device_set_info#>'{dc,dev,B,19}' as "B019", --B液濃度プログラム工程10のB液濃度
                    ind_device_set_info#>'{dc,dev,A,351}' as "A351", --Ｂ液濃度プログラム設定１
                    ind_device_set_info#>'{dc,dev,A,352}' as "A352", --Ｂ液濃度プログラム設定２
                    ind_device_set_info#>'{dc,dev,A,353}' as "A353", --Ｂ液濃度プログラム設定３
                    ind_device_set_info#>'{dc,dev,A,354}' as "A354", --Ｂ液濃度プログラム設定４
                    ind_device_set_info#>'{dc,dev,A,355}' as "A355", --Ｂ液濃度プログラム設定５
                    ind_device_set_info#>'{dc,dev,A,356}' as "A356", --Ｂ液濃度プログラム設定６
                    ind_device_set_info#>'{dc,dev,A,357}' as "A357", --Ｂ液濃度プログラム設定７
                    ind_device_set_info#>'{dc,dev,A,358}' as "A358", --Ｂ液濃度プログラム設定８
                    ind_device_set_info#>'{dc,dev,A,359}' as "A359", --Ｂ液濃度プログラム設定９
                    ind_device_set_info#>'{dc,dev,A,360}' as "A360", --Ｂ液濃度プログラム設定１０
                    ind_device_set_info#>'{dc,dev,A,365}' as "A365", --Ｂ液濃度プログラム開始数値
                    ind_device_set_info#>'{dc,dev,A,366}' as "A366", --Ｂ液濃度プログラム終了数値
                    ind_device_set_info#>'{qbqd,dev,A,430}' as "A430", --QBプログラム電源
                    ind_device_set_info#>'{qbqd,dev,A,429}' as "A429", --QB、QDプログラム最大ステップ数
                    ind_device_set_info#>'{qbqd,dev,A,400}' as "A400", --QBプログラム血流量1
                    ind_device_set_info#>'{qbqd,dev,A,401}' as "A401", --QBプログラム血流量2
                    ind_device_set_info#>'{qbqd,dev,A,402}' as "A402", --QBプログラム血流量3
                    ind_device_set_info#>'{qbqd,dev,A,403}' as "A403", --QBプログラム血流量4
                    ind_device_set_info#>'{qbqd,dev,A,404}' as "A404", --QBプログラム血流量5
                    ind_device_set_info#>'{qbqd,dev,A,405}' as "A405", --QBプログラム血流量6
                    ind_device_set_info#>'{qbqd,dev,A,406}' as "A406", --QBプログラム血流量7
                    ind_device_set_info#>'{qbqd,dev,A,407}' as "A407", --QBプログラム血流量8
                    ind_device_set_info#>'{qbqd,dev,A,408}' as "A408", --QBプログラム血流量9
                    ind_device_set_info#>'{qbqd,dev,A,409}' as "A409", --QBプログラム血流量10
                    ind_device_set_info#>'{qbqd,dev,A,431}' as "A431", --QDプログラム電源
                    ind_device_set_info#>'{qbqd,dev,A,410}' as "A410", --QDプログラム透析液流量1
                    ind_device_set_info#>'{qbqd,dev,A,411}' as "A411", --QDプログラム透析液流量2
                    ind_device_set_info#>'{qbqd,dev,A,412}' as "A412", --QDプログラム透析液流量3
                    ind_device_set_info#>'{qbqd,dev,A,413}' as "A413", --QDプログラム透析液流量4
                    ind_device_set_info#>'{qbqd,dev,A,414}' as "A414", --QDプログラム透析液流量5
                    ind_device_set_info#>'{qbqd,dev,A,415}' as "A415", --QDプログラム透析液流量6
                    ind_device_set_info#>'{qbqd,dev,A,416}' as "A416", --QDプログラム透析液流量7
                    ind_device_set_info#>'{qbqd,dev,A,417}' as "A417", --QDプログラム透析液流量8
                    ind_device_set_info#>'{qbqd,dev,A,418}' as "A418", --QDプログラム透析液流量9
                    ind_device_set_info#>'{qbqd,dev,A,419}' as "A419", --QDプログラム透析液流量10
                    ind_device_set_info#>'{qbqd,dev,A,420}' as "A420", --QB、QDプログラム切替時間1
                    ind_device_set_info#>'{qbqd,dev,A,421}' as "A421", --QB、QDプログラム切替時間2
                    ind_device_set_info#>'{qbqd,dev,A,422}' as "A422", --QB、QDプログラム切替時間3
                    ind_device_set_info#>'{qbqd,dev,A,423}' as "A423", --QB、QDプログラム切替時間4
                    ind_device_set_info#>'{qbqd,dev,A,424}' as "A424", --QB、QDプログラム切替時間5
                    ind_device_set_info#>'{qbqd,dev,A,425}' as "A425", --QB、QDプログラム切替時間6
                    ind_device_set_info#>'{qbqd,dev,A,426}' as "A426", --QB、QDプログラム切替時間7
                    ind_device_set_info#>'{qbqd,dev,A,427}' as "A427", --QB、QDプログラム切替時間8
                    ind_device_set_info#>'{qbqd,dev,A,428}' as "A428", --QB、QDプログラム切替時間9
                    ind_device_set_info#>'{ihdf,dev,A,201}' as "A201", --I-HDF 補液速度
                    ind_device_set_info#>'{ihdf,dev,A,203}' as "A203", --I-HDF 補液開始時間
                    ind_device_set_info#>'{ihdf,dev,A,200}' as "A200", --I-HDF 補液量設定
                    ind_device_set_info#>'{ihdf,dev,A,204}' as "A204", --I-HDF 除水再開時間
                    ind_device_set_info#>'{ihdf,dev,A,202}' as "A202", --I-HDF 補液周期
                    ind_device_set_info#>'{ihdf,dev,A,205}' as "A205", --I-HDF 総補液量上限
                    ind_device_set_info#>'{ihdf,dev,A,432}' as "A432", --I-HDFプログラム使用選択
                    ind_device_set_info#>'{ihdf,dev,A,433}' as "A433", --予定補液回数
                    ind_device_set_info#>'{ihdf,dev,A,434}' as "A434", --補液バランス制限
                    ind_device_set_info#>'{ihdf,dev,A,435}' as "A435", --補液量01
                    ind_device_set_info#>'{ihdf,dev,A,436}' as "A436", --補液量02
                    ind_device_set_info#>'{ihdf,dev,A,437}' as "A437", --補液量03
                    ind_device_set_info#>'{ihdf,dev,A,438}' as "A438", --補液量04
                    ind_device_set_info#>'{ihdf,dev,A,439}' as "A439", --補液量05
                    ind_device_set_info#>'{ihdf,dev,A,440}' as "A440", --補液量06
                    ind_device_set_info#>'{ihdf,dev,A,441}' as "A441", --補液量07
                    ind_device_set_info#>'{ihdf,dev,A,442}' as "A442", --補液量08
                    ind_device_set_info#>'{ihdf,dev,A,443}' as "A443", --補液量09
                    ind_device_set_info#>'{ihdf,dev,A,444}' as "A444", --補液量10
                    ind_device_set_info#>'{ihdf,dev,A,445}' as "A445", --補液量11
                    ind_device_set_info#>'{ihdf,dev,A,446}' as "A446", --補液量12
                    ind_device_set_info#>'{ihdf,dev,A,447}' as "A447", --補液量13
                    ind_device_set_info#>'{ihdf,dev,A,448}' as "A448", --補液量14
                    ind_device_set_info#>'{ihdf,dev,A,449}' as "A449", --補液量15
                    ind_device_set_info#>'{ihdf,dev,A,450}' as "A450", --補液量16
                    ind_device_set_info#>'{ihdf,dev,A,451}' as "A451", --回収量01
                    ind_device_set_info#>'{ihdf,dev,A,452}' as "A452", --回収量02
                    ind_device_set_info#>'{ihdf,dev,A,453}' as "A453", --回収量03
                    ind_device_set_info#>'{ihdf,dev,A,454}' as "A454", --回収量04
                    ind_device_set_info#>'{ihdf,dev,A,455}' as "A455", --回収量05
                    ind_device_set_info#>'{ihdf,dev,A,456}' as "A456", --回収量06
                    ind_device_set_info#>'{ihdf,dev,A,457}' as "A457", --回収量07
                    ind_device_set_info#>'{ihdf,dev,A,458}' as "A458", --回収量08
                    ind_device_set_info#>'{ihdf,dev,A,459}' as "A459", --回収量09
                    ind_device_set_info#>'{ihdf,dev,A,460}' as "A460", --回収量10
                    ind_device_set_info#>'{ihdf,dev,A,461}' as "A461", --回収量11
                    ind_device_set_info#>'{ihdf,dev,A,462}' as "A462", --回収量12
                    ind_device_set_info#>'{ihdf,dev,A,463}' as "A463", --回収量13
                    ind_device_set_info#>'{ihdf,dev,A,464}' as "A464", --回収量14
                    ind_device_set_info#>'{ihdf,dev,A,465}' as "A465", --回収量15
                    ind_device_set_info#>'{ihdf,dev,A,466}' as "A466", --回収量16
                    ind_device_set_info#>'{bvufc,dev,A,196}' as "A196", --BV-UFC使用選択
                    ind_device_set_info#>'{bvufc,dev,A,197}' as "A197", --UFC期間除水速度上限
                    ind_device_set_info#>'{bvufc,dev,A,198}' as "A198", --UFC期間除水速度下限
                    ind_device_set_info#>'{bvufc,dev,A,199}' as "A199", --開始期間 時間
                    ind_device_set_info#>'{bvufc,dev,A,206}' as "A206", --開始期間 除水速度倍率
                    ind_device_set_info#>'{bvufc,dev,A,207}' as "A207", --固定倍率除水期間 時間
                    ind_device_set_info#>'{bvufc,dev,A,208}' as "A208", --固定倍率除水期間 除水速度倍率
                    ind_device_set_info#>'{bvufc,dev,A,209}' as "A209", --固定倍率除水終了条件　最高血圧
                    ind_device_set_info#>'{bvufc,dev,A,210}' as "A210", --固定倍率除水終了条件　脈拍
                    ind_device_set_info#>'{bvufc,dev,A,248}' as "A248", --固定倍率除水終了条件　ΔBV
                    ind_device_set_info#>'{bvufc,dev,A,249}' as "A249", --終了前期間 時間
                    ind_device_set_info#>'{bvufc,dev,A,271}' as "A271", --開始時ΔBV基準値
                    ind_device_set_info#>'{bvufc,dev,A,272}' as "A272", --ΔBV基準線　指数1
                    ind_device_set_info#>'{bvufc,dev,A,273}' as "A273", --ΔBV基準線　指数2
                    ind_device_set_info#>'{bvufc,dev,A,274}' as "A274", --ΔBV基準線　指数3
                    ind_device_set_info#>'{bvufc,dev,A,275}' as "A275", --終了時ΔBV基準値
                    ind_device_set_info#>'{dia,dev,A,282}' as "A282", --透析量プログラム使用選択
                    ind_device_set_info#>'{dia,dev,A,288}' as "A288", --目標Kt/V
                    ind_device_set_info#>'{dia,dev,A,ord_no}' as "ord_no", --検査日
                    rst_weight_info#>'{weight_before}' as "A040", --透析前体重
                    rst_off_water_info as "A042", --補正値の合計
                    ind_cond_info#>'{4,value}' as "A043" --除水量制限
                from
                    ord_main ord,
                    base
                where
                    ord.ord_no = base.ord_no
            ) ord_dev,
            (
                select
                    device_set_info#>'{ope,dev,A,179}' as "A179", --血流量操作範囲上限
                    device_set_info#>'{ope,dev,A,181}' as "A181", --除水速度操作範囲上限
                    device_set_info#>'{ope,dev,A,38}' as "A038", --クリップ式気泡検出器切りＳＷ
                    device_set_info#>'{ope,dev,A,21}' as "A021", --除水計算選択
                    device_set_info#>'{ope,dev,A,22}' as "A022", --除水計算優先項目選択
                    device_set_info#>'{ope,dev,A,39}' as "A039", --除水開始遅延時間
                    device_set_info#>'{ope,dev,A,182}' as "A182", --透析液温度操作範囲上限
                    device_set_info#>'{ope,dev,A,183}' as "A183", --透析液温度操作範囲下限
                    device_set_info#>'{ope,dev,A,268}' as "A268", --透析液流量　設定方法
                    device_set_info#>'{ope,dev,A,269}' as "A269", --透析液流量　比率設定
                    device_set_info#>'{ope,dev,A,24}' as "A024", --シングルニードル切替圧上限
                    device_set_info#>'{ope,dev,A,25}' as "A025", --シングルニードル切替圧下限
                    device_set_info#>'{ope,dev,A,241}' as "A241", --ＴＭＰゼロ補正の選択
                    device_set_info#>'{ope,dev,A,168}' as "A168", --ＴＭＰゼロ補正警報上限HD
                    device_set_info#>'{ope,dev,A,169}' as "A169", --ＴＭＰゼロ補正警報下限HD
                    device_set_info#>'{ope,dev,A,171}' as "A171", --ＴＭＰゼロ補正警報上限ECUM
                    device_set_info#>'{ope,dev,A,172}' as "A172", --ＴＭＰゼロ補正警報下限ECUM
                    device_set_info#>'{ope,dev,A,174}' as "A174", --ＴＭＰゼロ補正警報上限HDF
                    device_set_info#>'{ope,dev,A,175}' as "A175", --ＴＭＰゼロ補正警報下限HDF
                    device_set_info#>'{ope,dev,A,177}' as "A177", --ＴＭＰゼロ補正警報上限HF
                    device_set_info#>'{ope,dev,A,178}' as "A178", --ＴＭＰゼロ補正警報下限HF
                    device_set_info#>'{ope,dev,B,37}' as "B037", --ＴＭＰゼロ補正警報上限（HD+補液）
                    device_set_info#>'{ope,dev,B,38}' as "B038", --ＴＭＰゼロ補正警報下限（HD+補液）
                    device_set_info#>'{ope,dev,A,391}' as "A391", --ＴＭＰゼロ補正警報上限OHDF
                    device_set_info#>'{ope,dev,A,392}' as "A392", --ＴＭＰゼロ補正警報下限OHDF
                    device_set_info#>'{ope,dev,A,394}' as "A394", --ＴＭＰゼロ補正警報上限OHF
                    device_set_info#>'{ope,dev,A,395}' as "A395", --ＴＭＰゼロ補正警報下限OHF
                    device_set_info#>'{ope,dev,A,383}' as "A383", --補液量設定値制限（OHDF・OHF用）
                    device_set_info#>'{ope,dev,A,389}' as "A389", --OHDF/OHF補液計算優先項目選択
                    device_set_info#>'{ope,dev,A,379}' as "A379", --前補液　OHDF/OHF　補液速度比率
                    device_set_info#>'{ope,dev,B,39}' as "B039", --後補液　OHDF/OHF　補液速度比率
                    device_set_info#>'{ope,dev,A,398}' as "A398", --補液開始遅延時間
                    device_set_info#>'{ope,dev,A,369}' as "A369", --DP=Qd+Qs(補液速度加算)
                    device_set_info#>'{ope,dev,A,90}' as "A090", --前補液　濾過率
                    device_set_info#>'{ope,dev,B,40}' as "B040", --後補液　濾過率
                    device_set_info#>'{ope,dev,A,91}' as "A091", --ヘマトクリット（Ht）
                    device_set_info#>'{ope,dev,C,91}' as "C091", --検査日時(ヘマトクリット（Ht）)
                    device_set_info#>'{ope,dev,A,92}' as "A092", --総タンパク(TP)
                    device_set_info#>'{ope,dev,C,92}' as "C092", --検査日時(総タンパク(TP))
                    device_set_info#>'{ope,dev,A,336}' as "A336", --補液速度
                    device_set_info#>'{ope,dev,A,337}' as "A337", --補液量
                    device_set_info#>'{ope,dev,A,185}' as "A185", --補液速度操作範囲上限（HDF）
                    device_set_info#>'{ope,dev,A,186}' as "A186", --補液速度操作範囲上限（HF）
                    device_set_info#>'{ope,dev,B,30}' as "B030", --前補液 補液速度操作範囲上限（HD+補液）
                    device_set_info#>'{ope,dev,A,396}' as "A396", --補液速度操作範囲上限（OHDF）
                    device_set_info#>'{ope,dev,A,397}' as "A397", --補液速度操作範囲上限（OHF）
                    device_set_info#>'{ope,dev,B,31}' as "B031", --後補液　補液速度操作範囲上限（HDF）
                    device_set_info#>'{ope,dev,B,32}' as "B032", --後補液　補液速度操作範囲上限（HF）
                    device_set_info#>'{ope,dev,B,33}' as "B033", --後補液　補液速度操作範囲上限（HD+補液）
                    device_set_info#>'{ope,dev,B,34}' as "B034", --後補液　補液速度操作範囲上限（OHDF）
                    device_set_info#>'{ope,dev,B,35}' as "B035", --後補液　補液速度操作範囲上限（OHF）
                    device_set_info#>'{ope,dev,A,384}' as "A384", --AFBF　補液比率使用選択
                    device_set_info#>'{ope,dev,A,385}' as "A385", --AFBF　補液比率
                    device_set_info#>'{ope,dev,A,386}' as "A386", --補液速度設定範囲上限（AFBF）
                    device_set_info#>'{ope,dev,A,387}' as "A387", --補液速度設定範囲下限（AFBF）
                    device_set_info#>'{ope,dev,A,472}' as "A472", --TMP閾値 速度低下
                    device_set_info#>'{ope,dev,A,473}' as "A473", --TMP閾値 速度復帰
                    device_set_info#>'{ope,dev,A,474}' as "A474", --補液量 速度低下
                    device_set_info#>'{ope,dev,A,475}' as "A475", --補液量 速度復帰
                    device_set_info#>'{bp,dev,A,211}' as "A211", --最高血圧上限
                    device_set_info#>'{bp,dev,A,212}' as "A212", --最高血圧下限
                    device_set_info#>'{bp,dev,A,213}' as "A213", --最低血圧上限
                    device_set_info#>'{bp,dev,A,214}' as "A214", --最低血圧下限
                    device_set_info#>'{bp,dev,A,215}' as "A215", --平均血圧上限
                    device_set_info#>'{bp,dev,A,216}' as "A216", --平均血圧下限
                    device_set_info#>'{bp,dev,A,217}' as "A217", --脈拍数上限
                    device_set_info#>'{bp,dev,A,218}' as "A218", --脈拍数下限
                    device_set_info#>'{bp,dev,A,227}' as "A227", --最高血圧上限警報　BP　速度
                    device_set_info#>'{bp,dev,A,219}' as "A219", --最高血圧上限警報　BP　動作選択
                    device_set_info#>'{bp,dev,A,228}' as "A228", --最高血圧下限警報　BP　速度
                    device_set_info#>'{bp,dev,A,220}' as "A220", --最高血圧下限警報　BP　動作選択
                    device_set_info#>'{bp,dev,A,229}' as "A229", --最高血圧上限警報　除水　速度
                    device_set_info#>'{bp,dev,A,221}' as "A221", --最高血圧上限警報　除水　動作選択
                    device_set_info#>'{bp,dev,A,230}' as "A230", --最高血圧下限警報　除水　速度
                    device_set_info#>'{bp,dev,A,222}' as "A222", --最高血圧下限警報　除水　動作選択
                    device_set_info#>'{bp,dev,A,231}' as "A231", --最高血圧上限警報　Na注入　速度
                    device_set_info#>'{bp,dev,A,223}' as "A223", --最高血圧上限警報　Na注入　動作選択
                    device_set_info#>'{bp,dev,A,232}' as "A232", --最高血圧下限警報　Na注入　速度
                    device_set_info#>'{bp,dev,A,224}' as "A224", --最高血圧下限警報　Na注入　動作選択
                    device_set_info#>'{bp,dev,A,233}' as "A233", --最高血圧上限警報　補液　速度
                    device_set_info#>'{bp,dev,A,225}' as "A225", --最高血圧上限警報　補液　動作選択
                    device_set_info#>'{bp,dev,A,234}' as "A234", --最高血圧下限警報　補液　速度
                    device_set_info#>'{bp,dev,A,226}' as "A226", --最高血圧下限警報　補液　動作選択
                    device_set_info#>'{bp,dev,A,191}' as "A191", --血圧ｶﾌ選択
                    device_set_info#>'{bp,dev,A,190}' as "A190", --血圧自動測定間隔
                    device_set_info#>'{bp,dev,A,192}' as "A192", --昇圧値
                    device_set_info#>'{bp,dev,A,193}' as "A193", --昇圧方法選択
                    device_set_info#>'{bp,dev,A,195}' as "A195", --血圧測定方法選択
                    device_set_info#>'{bp,dev,A,239}' as "A239", --高速測定選択
                    device_set_info#>'{bp,dev,A,194}' as "A194", --血圧連続測定動作選択
                    device_set_info#>'{bp,dev,A,235}' as "A235", --警報連動測定開始時刻
                    device_set_info#>'{bp,dev,A,236}' as "A236", --治療条件連動測定時刻
                    device_set_info#>'{bp,dev,A,237}' as "A237", --血圧測定自動停止(警報発生)
                    device_set_info#>'{bp,dev,A,238}' as "A238", --血圧測定自動停止(条件変更)
                    device_set_info#>'{war,dev,A,240}' as "A240", --ＴＭＰ監視モード
                    device_set_info#>'{war,dev,A,100}' as "A100", --静脈圧自動設定警報幅上限HD/ECUM
                    device_set_info#>'{war,dev,A,101}' as "A101", --静脈圧自動設定警報幅下限HD/ECUM
                    device_set_info#>'{war,dev,A,102}' as "A102", --静脈圧自動設定警報限界上限
                    device_set_info#>'{war,dev,A,103}' as "A103", --静脈圧自動設定警報限界下限
                    device_set_info#>'{war,dev,A,104}' as "A104", --静脈圧固定警報上限
                    device_set_info#>'{war,dev,A,105}' as "A105", --静脈圧固定警報下限
                    device_set_info#>'{war,dev,A,152}' as "A152", --ダイアライザー入口圧自動設定警報幅上限HD/ECUM
                    device_set_info#>'{war,dev,A,153}' as "A153", --ダイアライザー入口圧自動設定警報幅下限HD/ECUM
                    device_set_info#>'{war,dev,A,154}' as "A154", --ダイアライザー入口圧自動設定警報限界上限
                    device_set_info#>'{war,dev,A,155}' as "A155", --ダイアライザー入口圧自動設定警報限界下限
                    device_set_info#>'{war,dev,A,156}' as "A156", --ダイアライザー入口圧固定警報上限
                    device_set_info#>'{war,dev,A,157}' as "A157", --ダイアライザー入口圧固定警報下限
                    device_set_info#>'{war,dev,A,112}' as "A112", --液圧自動設定警報幅上限HD/ECUM
                    device_set_info#>'{war,dev,A,113}' as "A113", --液圧自動設定警報幅下限HD/ECUM
                    device_set_info#>'{war,dev,A,114}' as "A114", --液圧自動設定警報限界上限
                    device_set_info#>'{war,dev,A,115}' as "A115", --液圧自動設定警報限界下限
                    device_set_info#>'{war,dev,A,116}' as "A116", --液圧固定警報上限
                    device_set_info#>'{war,dev,A,117}' as "A117", --液圧固定警報下限
                    device_set_info#>'{war,dev,A,128}' as "A128", --ＴＭＰ自動設定警報幅上限HD/ECUM
                    device_set_info#>'{war,dev,A,129}' as "A129", --ＴＭＰ自動設定警報幅下限HD/ECUM
                    device_set_info#>'{war,dev,A,130}' as "A130", --ＴＭＰ自動設定警報限界上限
                    device_set_info#>'{war,dev,A,131}' as "A131", --ＴＭＰ自動設定警報限界下限
                    device_set_info#>'{war,dev,A,132}' as "A132", --ＴＭＰ固定警報上限
                    device_set_info#>'{war,dev,A,133}' as "A133", --ＴＭＰ固定警報下限
                    device_set_info#>'{war,dev,A,126}' as "A126", --ＴＭＰ自動追従警報幅上限HD/ECUM
                    device_set_info#>'{war,dev,A,127}' as "A127", --ＴＭＰ自動追従警報幅下限HD/ECUM
                    device_set_info#>'{war,dev,A,146}' as "A146", --ダイアライザー差圧自動設定警報幅上限HD/ECUM
                    device_set_info#>'{war,dev,A,147}' as "A147", --ダイアライザー差圧自動設定警報幅下限HD/ECUM
                    device_set_info#>'{war,dev,A,148}' as "A148", --ダイアライザー差圧固定警報上限
                    device_set_info#>'{war,dev,A,149}' as "A149", --ダイアライザー差圧固定警報下限
                    device_set_info#>'{war,dev,A,106}' as "A106", --静脈圧自動設定警報幅上限HDF/HF
                    device_set_info#>'{war,dev,A,107}' as "A107", --静脈圧自動設定警報幅下限HDF/HF
                    device_set_info#>'{war,dev,A,158}' as "A158", --ダイアライザー入口圧自動設定警報幅上限HDF/HF
                    device_set_info#>'{war,dev,A,159}' as "A159", --ダイアライザー入口圧自動設定警報幅下限HDF/HF
                    device_set_info#>'{war,dev,A,118}' as "A118", --液圧自動設定警報幅上限HDF/HF
                    device_set_info#>'{war,dev,A,119}' as "A119", --液圧自動設定警報幅下限HDF/HF
                    device_set_info#>'{war,dev,A,136}' as "A136", --ＴＭＰ自動設定警報幅上限HDF/HF
                    device_set_info#>'{war,dev,A,137}' as "A137", --ＴＭＰ自動設定警報幅下限HDF/HF
                    device_set_info#>'{war,dev,A,134}' as "A134", --ＴＭＰ自動追従警報幅上限HDF/HF
                    device_set_info#>'{war,dev,A,135}' as "A135", --ＴＭＰ自動追従警報幅下限HDF/HF
                    device_set_info#>'{war,dev,A,150}' as "A150", --ダイアライザー差圧自動設定警報幅上限HDF/HF
                    device_set_info#>'{war,dev,A,151}' as "A151", --ダイアライザー差圧自動設定警報幅下限HDF/HF
                    device_set_info#>'{war,dev,A,110}' as "A110", --静脈圧固定警報上限ＳＮ
                    device_set_info#>'{war,dev,A,111}' as "A111", --静脈圧固定警報下限ＳＮ
                    device_set_info#>'{war,dev,A,162}' as "A162", --ダイアライザー入口圧固定警報上限ＳＮ
                    device_set_info#>'{war,dev,A,163}' as "A163", --ダイアライザー入口圧固定警報下限ＳＮ
                    device_set_info#>'{war,dev,A,120}' as "A120", --液圧自動設定警報幅上限ＳＮ
                    device_set_info#>'{war,dev,A,121}' as "A121", --液圧自動設定警報幅下限ＳＮ
                    device_set_info#>'{war,dev,A,122}' as "A122", --液圧自動設定警報限界上限ＳＮ
                    device_set_info#>'{war,dev,A,123}' as "A123", --液圧自動設定警報限界下限ＳＮ
                    device_set_info#>'{war,dev,A,124}' as "A124", --液圧固定警報上限ＳＮ
                    device_set_info#>'{war,dev,A,125}' as "A125", --液圧固定警報下限ＳＮ
                    device_set_info#>'{war,dev,A,140}' as "A140", --ＴＭＰ自動設定警報幅上限ＳＮ
                    device_set_info#>'{war,dev,A,141}' as "A141", --ＴＭＰ自動設定警報幅下限ＳＮ
                    device_set_info#>'{war,dev,A,142}' as "A142", --ＴＭＰ自動設定警報限界上限ＳＮ
                    device_set_info#>'{war,dev,A,143}' as "A143", --ＴＭＰ自動設定警報限界下限ＳＮ
                    device_set_info#>'{war,dev,A,144}' as "A144", --ＴＭＰ固定警報上限ＳＮ
                    device_set_info#>'{war,dev,A,145}' as "A145", --ＴＭＰ固定警報下限ＳＮ
                    device_set_info#>'{war,dev,A,138}' as "A138", --ＴＭＰ自動追従警報幅上限ＳＮ
                    device_set_info#>'{war,dev,A,139}' as "A139", --ＴＭＰ自動追従警報幅下限ＳＮ
                    device_set_info#>'{war,dev,A,108}' as "A108", --静脈圧固定警報上限透析準備
                    device_set_info#>'{war,dev,A,109}' as "A109", --静脈圧固定警報下限透析準備
                    device_set_info#>'{war,dev,A,160}' as "A160", --ダイアライザー入口圧固定警報上限透析準備
                    device_set_info#>'{war,dev,A,161}' as "A161", --ダイアライザー入口圧固定警報下限透析準備
                    device_set_info#>'{war,dev,A,254}' as "A254", --Ｎａ濃度自動設定警報幅上限
                    device_set_info#>'{war,dev,A,255}' as "A255", --Ｎａ濃度自動設定警報幅下限
                    device_set_info#>'{war,dev,A,256}' as "A256", --Ｎａ濃度固定警報上限
                    device_set_info#>'{war,dev,A,257}' as "A257", --Ｎａ濃度固定警報下限
                    device_set_info#>'{war,dev,A,242}' as "A242", --静脈圧自動設定警報監視有無
                    device_set_info#>'{war,dev,A,243}' as "A243", --ダイアライザー血液入口圧自動設定警報監視有無
                    device_set_info#>'{war,dev,A,244}' as "A244", --透析液圧自動設定警報監視有無
                    device_set_info#>'{war,dev,A,245}' as "A245", --ＴＭＰ自動設定警報監視有無
                    device_set_info#>'{war,dev,A,246}' as "A246", --差圧自動設定警報監視有無
                    device_set_info#>'{war,dev,A,247}' as "A247", --Ｎａ濃度自動設定警報監視有無
                    device_set_info#>'{bv,dev,A,267}' as "A267", --ブラッドボリューム計使用の選択
                    device_set_info#>'{bv,dev,A,260}' as "A260", --ΔＢＶ低下警報点１
                    device_set_info#>'{bv,dev,A,261}' as "A261", --ΔＢＶ低下警報点２
                    device_set_info#>'{bv,dev,A,262}' as "A262", --ΔBV変化率警報点
                    device_set_info#>'{bv,dev,A,277}' as "A277", --ΔＢＶ除水低下速度
                    device_set_info#>'{bv,dev,A,278}' as "A278", --ΔＢＶ除水低下遅延時間
                    --// #11124 2025.08.26 add 酸素飽和度対応 TDC高村 start
                    device_set_info#>'{bv,dev,A,476}' as "A476", --ΔSO2低下報知点
                    --// #11124 2025.08.26 add 酸素飽和度対応 TDC高村 end
                    device_set_info#>'{bv,dev,A,258}' as "A258", --アクセス再循環測定使用選択
                    device_set_info#>'{bv,dev,A,259}' as "A259", --自動測定1
                    device_set_info#>'{bv,dev,A,263}' as "A263", --自動測定2
                    device_set_info#>'{bv,dev,A,264}' as "A264", --自動測定3
                    device_set_info#>'{bv,dev,A,265}' as "A265", --自動測定4
                    device_set_info#>'{bv,dev,A,266}' as "A266", --自動測定5
                    device_set_info#>'{bv,dev,A,281}' as "A281", --再循環率報知
                    device_set_info#>'{pri,dev,A,370}' as "A370", --自動回収　使用液量
                    device_set_info#>'{pri,dev,A,371}' as "A371", --自動回収　流速
                    device_set_info#>'{pri,dev,A,372}' as "A372", --自動回収　血液判別器による終了選択
                    device_set_info#>'{dfas,dev,A,339}' as "A339", --脱血方法選択
                    device_set_info#>'{dfas,dev,A,333}' as "A333", --脱血速度
                    device_set_info#>'{dfas,dev,A,331}' as "A331", --同時脱血　脱血量
                    device_set_info#>'{dfas,dev,A,334}' as "A334", --片側脱血(除水なし) 脱血量
                    device_set_info#>'{dfas,dev,A,338}' as "A338", --片側脱血（除水あり）　脱血量
                    device_set_info#>'{dfas,dev,A,332}' as "A332", --片側脱血への切替え透析液圧
                    device_set_info#>'{dfas,dev,B,36}' as "B036", --治療開始時血流量使用有無
                    device_set_info#>'{dfas,dev,A,373}' as "A373", --静脈側返血速度
                    device_set_info#>'{dfas,dev,A,374}' as "A374", --静脈側最大返血量
                    device_set_info#>'{dfas,dev,A,377}' as "A377", --静脈側返血　血液判別器使用選択
                    device_set_info#>'{dfas,dev,A,270}' as "A270", --D-FAS 返血 動脈側返血使用選択
                    device_set_info#>'{dfas,dev,A,376}' as "A376", --動脈側最大返血量
                    device_set_info#>'{dfas,dev,A,378}' as "A378", --動脈側返血　血液判別器使用選択
                    device_set_info#>'{ecum,dev,A,16}' as "A016", --ＥＣＵＭ選択
                    device_set_info#>'{ecum,dev,A,17}' as "A017", --ＥＣＵＭ量
                    device_set_info#>'{ecum,dev,A,18}' as "A018", --ＥＣＵＭ時間
                    device_set_info#>'{ecum,dev,A,19}' as "A019", --ＥＣＵＭ時間カウント選択
                    device_set_info#>'{cpro,dev,A,252}' as "A252", --Ｂ液濃度プログラム自動設定警報幅上限
                    device_set_info#>'{cpro,dev,A,253}' as "A253", --Ｂ液濃度プログラム自動設定警報幅下限
                    device_set_info#>'{cpro,dev,A,250}' as "A250", --透析液濃度プログラム自動設定警報幅上限
                    device_set_info#>'{cpro,dev,A,251}' as "A251", --透析液濃度プログラム自動設定警報幅下限
                    device_set_info#>'{iap,dev,A,468}' as "A468", --VA確認報知基準値(静的静脈圧)
                    device_set_info#>'{iap,dev,A,469}' as "A469", --VA確認報知基準値(アクセス内圧力比率)
                    device_set_info#>'{iap,dev,A,470}' as "A470", --静的静脈圧記録 自動実施選択
                    device_set_info#>'{iap,dev,A,471}' as "A471" --血圧測定 自動実施選択
                from
                    pat_main pat,
                    base
                where
                    pat.pat_id = base.pat_id
            ) pat_dev
    ) dev,
    (
        select
						device_set_info#>'{pri,pat,A,228}' as "A000-228", --プライミング補助液交換量
						device_set_info#>'{pri,pat,A,230}' as "A001-230", --プライミング補助間欠動作停止時間
						device_set_info#>'{pri,pat,A,229}' as "A002-229", --プライミング補助間欠動作動作時間
						device_set_info#>'{pri,pat,A,223}' as "A003-223", --プライミング補助気泡抜き液量
						device_set_info#>'{pri,pat,A,227}' as "A004-227", --プライミング補助気泡抜き間欠動作選択
						device_set_info#>'{pri,pat,A,224}' as "A005-224", --プライミング補助気泡抜き流速
						device_set_info#>'{pri,pat,A,221}' as "A006-221", --プライミング補助静脈充填液量
						device_set_info#>'{pri,pat,A,226}' as "A007-226", --プライミング補助静脈充填後継続の有無
						device_set_info#>'{pri,pat,A,222}' as "A008-222", --プライミング補助静脈充填流速
						device_set_info#>'{pri,pat,A,219}' as "A009-219", --プライミング補助動脈充填液量
						device_set_info#>'{pri,pat,A,225}' as "A010-225", --プライミング補助動脈充填後継続の有無
						device_set_info#>'{pri,pat,A,220}' as "A011-220", --プライミング補助動脈充填流速
						--//mod #10412->#10439 次患者情報1の自動プライミング開始時刻の送信データ不正 朴 start
						--device_set_info#>'{pri,pat,A,231}' as "A012-231", --自動プライミング開始時刻
						(CAST(SUBSTRING(base.ind_treat_start_time, 1, 2) AS INT) * 60 + CAST(SUBSTRING(base.ind_treat_start_time, 3, 2) AS INT) - CAST((pat.device_set_info#>'{pri,pat,A,231}') AS INT)) as "A012-231", --自動プライミング開始時刻(開始予定時刻－設定時間)
						--//mod #10412->#10439 次患者情報1の自動プライミング開始時刻の送信データ不正 朴 end
						device_set_info#>'{pri,pat,A,237}' as "A013-237", --自動プライミング循環時間
						device_set_info#>'{pri,pat,A,236}' as "A014-236", --自動プライミング循環流速
						device_set_info#>'{pri,pat,A,238}' as "A015-238", --自動プライミング総量
						device_set_info#>'{pri,pat,A,233}' as "A016-233", --自動プライミング送液液量
						device_set_info#>'{pri,pat,A,234}' as "A017-234", --自動プライミング送液流速1回目
						device_set_info#>'{pri,pat,A,235}' as "A018-235", --自動プライミング送液流速2回目以降
						device_set_info#>'{pri,pat,A,232}' as "A019-232", --自動プライミング落差時間
            device_set_info#>'{pri,pat,B,51}' as "B051-051", --後補液　ダイアライザー気泡抜き時間
            device_set_info#>'{pri,pat,B,32}' as "B032-032", --動脈チャンバ液面作成時間
            device_set_info#>'{pri,pat,B,52}' as "B052-052", --後補液　動脈チャンバ液面作成時間
            device_set_info#>'{pri,pat,B,33}' as "B033-033", --循環洗浄時間
            device_set_info#>'{pri,pat,B,53}' as "B053-053", --後補液　循環洗浄時間
            device_set_info#>'{dfas,pat,B,1}' as "B001-001", --IPラインプライミング使用選択
            device_set_info#>'{dfas,pat,B,5}' as "B005-005", --プライミング時のBP速度
            device_set_info#>'{dfas,pat,B,7}' as "B007-007", --送液最大時間
            device_set_info#>'{dfas,pat,B,8}' as "B008-008", --回路洗浄送液量
            device_set_info#>'{dfas,pat,B,9}' as "B009-009", --気泡抜き実行回数
            device_set_info#>'{dfas,pat,B,10}' as "B010-010", --気泡抜き圧力上限
            device_set_info#>'{dfas,pat,B,59}' as "B059-059", --積層 プライミング時のBP速度
            device_set_info#>'{dfas,pat,B,54}' as "B054-054", --積層 送液最大時間
            device_set_info#>'{dfas,pat,B,55}' as "B055-055", --積層 回路内洗浄送液量
            device_set_info#>'{dfas,pat,B,56}' as "B056-056", --積層 気泡抜き動作実行回数
            device_set_info#>'{dfas,pat,B,57}' as "B057-057", --積層 気泡抜き圧力上限
            device_set_info#>'{dfas,pat,B,58}' as "B058-058" --積層 除水ポンプ速度
        from
            pat_main pat,
            base
        where
            pat.pat_id = base.pat_id
    ) pat
