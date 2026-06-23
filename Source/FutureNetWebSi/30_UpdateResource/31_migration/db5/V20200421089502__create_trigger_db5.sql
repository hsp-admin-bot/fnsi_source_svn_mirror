DROP TRIGGER IF EXISTS tg_sync_mst_facility ON mst_facility ;
CREATE OR REPLACE FUNCTION sync_mst_facility()
RETURNS trigger AS $BODY$
DECLARE
BEGIN
  IF (TG_OP = 'INSERT') THEN
    INSERT INTO mst_take_medicine( facility_cd, list_class, list_name, list_details, is_disp, is_del, reg_date, up_date)
    VALUES ( NEW.facility_cd, '01', '調剤指示リスト', '粉砕,脱カプセル,経管', '1', '0', now(), now());
    INSERT INTO mst_take_medicine( facility_cd, list_class, list_name, list_details, is_disp, is_del, reg_date, up_date)
    VALUES ( NEW.facility_cd, '10', '内服用法リスト', '１日１回起床時,１日１回朝食前,１日１回朝食直前,１日１回朝食直後,１日１回朝食後,１日１回朝食２時間後,１日１回昼食前,１日１回昼食直前,１日１回昼食直後,１日１回昼食後,１日１回昼食２時間後,１日１回夕食前,１日１回夕食直前,１日１回夕食直後,１日１回夕食後,１日１回夕食２時間後,１日１回就寝前,１日１回空腹時,１日２回朝食前と就寝前,１日２回朝食後と就寝前,１日２回朝昼食前,１日２回朝昼食直前,１日２回朝昼食後,１日２回朝夕食前,１日２回朝夕食直前,１日２回朝夕食直後,１日２回朝夕食後,１日２回朝夕食事２時間後,１日２回昼夕食前,１日２回昼夕食直前,１日２回昼食前と就寝前,１日２回昼夕食後,１日２回昼食後と就寝前,１日２回夕食前と就寝前,１日２回夕食後と就寝前,１日３回朝昼夕食前,１日３回朝昼夕食直前,１日３回朝昼夕食直後,１日３回朝昼夕食後,１日３回朝昼夕食後２時間,１日３回朝昼食前と就寝前,１日３回朝昼食後と就寝前,１日３回朝夕食前と就寝前,１日３回朝夕食後と就寝前,１日３回昼夕食前と就寝前,１日３回昼夕食後と就寝前,１日４回朝昼夕食前と就寝前,１日４回朝昼夕食後と就寝前,１日５回朝昼夕食後、１５時、就寝前,１日２回１２時間毎,１日３回８時間毎,１日４回６時間毎,１日６回４時間毎,１日８回３時間毎,１日１回Ｎ１時,１日２回Ｎ１時、Ｎ２時,１日３回Ｎ１時、Ｎ２時、Ｎ３時,１日４回Ｎ１時、Ｎ２時、Ｎ３時、Ｎ４時,１日５回Ｎ１時、Ｎ２時、Ｎ３時、Ｎ４時、Ｎ５時,１日６回Ｎ１時、Ｎ２時、Ｎ３時、Ｎ４時、Ｎ５時、Ｎ６時,１日８回Ｎ１時、Ｎ２時、Ｎ３時、Ｎ４時、Ｎ５時、Ｎ６時、Ｎ７時、Ｎ８時,１日1回哺乳時,１日2回哺乳時,１日3回哺乳時,１日4回哺乳時,１日5回哺乳時,１日6回哺乳時,１日8回哺乳時,１日10回哺乳時,１日12回哺乳時,１日１回空腹時', '1', '0', now(), now());
    INSERT INTO mst_take_medicine( facility_cd, list_class, list_name, list_details, is_disp, is_del, reg_date, up_date)
    VALUES ( NEW.facility_cd, '11', '内服用法詳細リスト', '経口,舌下,バッカル（歯茎と頬の間に挟む）,口腔内塗布', '1', '0', now(), now());
    INSERT INTO mst_take_medicine( facility_cd, list_class, list_name, list_details, is_disp, is_del, reg_date, up_date)
    VALUES ( NEW.facility_cd, '20', '外用用法リスト', '１日１回起床時,１日１回朝,１日１回昼,１日１回夕,１日１回就寝時,１日２回朝夕,１日２回朝と就寝前,１日２回午前と午後,１日３回朝昼夕,１日４回朝昼夕と就寝前,１日１回,１日２回,１日３回,１日４回,１日６回,１日３回程度,１日４回程度,１日６回程度,１日１～２回,１日１～数回,１日２～３回,１日３～４回,１日４～５回,２～３時間毎,４～６時間毎', '1', '0', now(), now());
    INSERT INTO mst_take_medicine( facility_cd, list_class, list_name, list_details, is_disp, is_del, reg_date, up_date)
    VALUES ( NEW.facility_cd, '21', '外用用法詳細リスト', '貼付,塗布,湿布,撒布,噴霧,消毒,点耳,点眼,点鼻,うがい,吸入,トローチ,膀胱洗浄,鼻腔内洗浄,浣腸,肛門挿入,肛門注入,膣内挿入,膀胱注入', '1', '0', now(), now());
    INSERT INTO mst_take_medicine( facility_cd, list_class, list_name, list_details, is_disp, is_del, reg_date, up_date)
    VALUES ( NEW.facility_cd, '22', '部位リスト', '全身,頭皮,頭部,頭頂部,後頭部,ひたい,顔,まゆ,まゆのまわり,まぶた,眼,目のまわり,頬,鼻,鼻のまわり,鼻の下,鼻腔内,耳,耳たぶ,耳のうしろ,耳のまわり,耳の中,口,口のまわり,口唇,口腔内,口腔内ほほの内側,口腔内上あご部,上歯茎部,下歯茎部,舌,舌の裏側,喉の奥,扁桃腺部,下あご,首,うなじ,肩,上肢,腕,上腕,前腕,ひじ,手,手の甲,手のひら,手の指,手の指の間,手の爪,手足,体幹部,背中,上背部,脇の下,全胸部,乳房,乳房まわり,乳首,上腹部,下腹部,へそ,へそのまわり,臀部,陰のう,陰部,股間部,肛門部,肛門周囲,下肢,ふともも,ふともも後ろ,ふとももとすね,膝,膝のうら,すね,ふくらはぎ,くるぶし,かかと,足,足の裏,足の甲,足のゆび,足のゆびの間,足の爪,かゆい所,カサカサした所,じくじくした所,ひどい所,褥瘡部,発赤部,発疹部,ストマ部,カテ挿入部,患部', '1', '0', now(), now());
    INSERT INTO mst_take_medicine( facility_cd, list_class, list_name, list_details, is_disp, is_del, reg_date, up_date)
    VALUES ( NEW.facility_cd, '23', '左右リスト', '右,左,両', '1', '0', now(), now());
    INSERT INTO mst_take_medicine( facility_cd, list_class, list_name, list_details, is_disp, is_del, reg_date, up_date)
    VALUES ( NEW.facility_cd, '30', '内服頓服用法リスト', '疼痛時,頭痛時,歯痛時,胸痛時,腹痛時,腰痛時,関節痛時,喘鳴時,喘息発作時,喉がゴロゴロする時,しゃっくり時,咳込時,血圧上昇時○○mHg以上,血糖値○○mg/dL以上,便秘時,お腹がゴロゴロする時,下痢時,嘔吐時,吐き気時,空腹時,出血時,乏尿時○○mＬ/時間未満,多尿時,むくみ時,不眠時,不安時,不穏時,いらいら時,けいれん時,めまい時,疲労時,発熱時(○○度以上),悪寒時,かゆい時,発疹時,発作時,症状ある時,検査前,検査時,検査後,手術前,手術中,手術後,処置前,処置時,処置後,起床時,入浴前,食事前,食事後,就寝前,外出時,哺乳時,必要時,適宜', '1', '0', now(), now());
    INSERT INTO mst_take_medicine( facility_cd, list_class, list_name, list_details, is_disp, is_del, reg_date, up_date)
    VALUES ( NEW.facility_cd, '40', '外用頓服用法リスト', '疼痛時,頭痛時,歯痛時,胸痛時,腹痛時,腰痛時,関節痛時,喘鳴時,喘息発作時,喉がゴロゴロする時,しゃっくり時,咳込時,血圧上昇時○○mHg以上,血糖値○○mg/dL以上,便秘時,お腹がゴロゴロする時,下痢時,排便時,嘔吐時,口腔乾燥時,吐き気時,空腹時,出血時,乏尿時○○mＬ/時間未満,多尿時,むくみ時,不眠時,不安時,不穏時,いらいら時,けいれん時,めまい時,疲労時,発熱時(○○度以上),悪寒時,かゆい時,発疹時,発作時,症状ある時,検査前,検査時,検査後,手術前,手術中,手術後,処置前,処置時,処置後,起床時,入浴前,食事前,食事後,就寝前,外出時,哺乳時,必要時,適宜', '1', '0', now(), now());
    INSERT INTO mst_take_medicine( facility_cd, list_class, list_name, list_details, is_disp, is_del, reg_date, up_date)
    VALUES ( NEW.facility_cd, '99', '用語リスト', '一包化,１日Ｎ回まで、Ｎ時間あける,Ｎ時間あける', '1', '0', now(), now());
  END IF ;

  RETURN NULL ;

EXCEPTION
  WHEN OTHERS THEN
    RAISE NOTICE '例外が発生しました。' ;
    RETURN NULL ;
END ;
$BODY$  LANGUAGE plpgsql VOLATILE COST 10 ;
CREATE TRIGGER tg_sync_mst_facility AFTER INSERT ON mst_facility FOR EACH ROW EXECUTE PROCEDURE sync_mst_facility() ;
