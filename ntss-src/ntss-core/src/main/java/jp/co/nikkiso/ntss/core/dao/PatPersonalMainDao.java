package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PatInsuranceConditionsSharing;
import jp.co.nikkiso.ntss.core.entity.TreatDatePatIdList;
import jp.co.nikkiso.ntss.core.entity.custom.PatientInfoSharing;
import org.seasar.doma.Dao;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;

import jp.co.nikkiso.ntss.core.config.ConfigAutowireablePersonalDb;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PatPersonalMainDetailedConditions;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.NumberOfPat;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.ItemFacilityCalendar;
import jp.co.nikkiso.ntss.core.entity.custom.PatNameId;


@ConfigAutowireablePersonalDb
@Dao
public interface PatPersonalMainDao {
  @Insert(sqlFile = true)
  int insert(PatPersonalMain pat);

  @Insert(sqlFile = true)
  int insertWithSeq(PatPersonalMain pat);

  /**
   * pat_idを指定して患者取得
   * @param patIdList 患者IDリスト
   * @return 患者リスト
   */
  @Select
  List<PatPersonalMain> selectByIdList(List<Long> patIdList);

  // add 20210827  トグルボタン表示 -- 鄭 start
  /**
   * pat_idを指定して患者取得
   * @param patIdList 患者IDリスト
   * @return 患者リスト
   */
  @Select
  List<PatPersonalMain> selectByPatIdList(List<Long> patIdList);
  // add 20210827  トグルボタン表示 -- 鄭 start

  /**
   * pat_idを指定して患者取得
   * @param patIdList 患者IDリスト
   * @param facilityCd 処理対象施設の施設コード
   * @return 患者リスト
   */
  @Select
  List<PatPersonalMain> selectByIdListFacilityCd(List<Long> patIdList, String facilityCd);

  // add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc start
  /**
   * pat_idを指定して患者取得
   *
   * @param patIdList  患者IDリスト
   * @param facilityCd 処理対象施設の施設コード
   * @return 患者リスト
   */
  @Select
  List<PatPersonalMain> selectByIdListFacilityCdIncludeDel(List<Long> patIdList, String facilityCd);
  // add #10659 削除済み含むの接頭文字対応 ztc 20241021 ztc end

  // add 10389 患者リストのソートが遅い gjn start
  @Select
  List<PatPersonalMain> selectByIdListFacilityCdToPatGroup(List<Long> patIdList, String facilityCd);
  // add 10389 患者リストのソートが遅い gjn end

  @Select
  List<PatPersonalMain> selectByIdListFacilityCdToTreatmentStatus(List<Long> patIdList, String facilityCd);

  /**
   * add 10061 by kangjie
   * @param patIdList
   * @param facilityCd
   * @return
   */
  @Select
  List<PatPersonalMain> getPatPersonalMainDtoList(List<Long> patIdList, String facilityCd);

  /**
   * 院内表示用患者ID重複患者件数取得
   * @param facilityCd 抽出データ（処理対象施設の施設コード）
   * @param hospPatId 抽出データ（処理対象患者の院内表示用の患者ID）
   * @param selfPatId 抽出データ（処理対象患者の患者ID）
   * @return 抽出条件を満たした患者の患者数
   */
  @Select
  Long selectByHospPatId(String facilityCd, String hospPatId, Long selfPatId);

  /**
   * 施設コードと院内表示用患者IDから患者ID取得
   * @param facilityCd 抽出データ（処理対象施設の施設コード）
   * @param hospPatId 抽出データ（処理対象患者の院内表示用の患者ID）
   * @return 患者ID
   */
  @Select
  Long selectPatIdByHospPatId(String facilityCd, String hospPatId);

  /**
   * hosp_pat_id重複チェック
   * @param facilityCd 抽出データ（処理対象施設の施設コード）
   * @param patLastName 抽出データ（処理対象患者の患者氏名(漢字姓)
   * @param patFirstName 抽出データ（処理対象患者の患者氏名(漢字名)
   * @param patLastNameKana 抽出データ（処理対象患者の患者氏名(カタカナ姓)
   * @param patFirstNameKana 抽出データ（処理対象患者の患者氏名(カタカナ名)
   * @param patLastNameAlpha 抽出データ（処理対象患者の患者氏名(英字姓)
   * @param patFirstNameAlpha 抽出データ（処理対象患者の患者氏名(英字名)
   * @param selfPatId 抽出データ（処理対象患者の患者ID）
   * @return 抽出条件を満たした患者の患者数
   */
  @Select
  List<PatPersonalMain> selectByPatName(
    String facilityCd,
    String patLastName,
    String patFirstName,
    String patLastNameKana,
    String patFirstNameKana,
    String patLastNameAlpha,
    String patFirstNameAlpha,
    Long selfPatId);

  // #9509 検索条件のフリーワードの検索範囲について 2023-08-30 卓 start
  /**
   *  ファジィクエリと 姓.名 が一致するPatPersonalMain
   */
  @Select
  List<PatPersonalMain> selectByPatFirstLastName(String facilityCd, String patName);
  // #9509 検索条件のフリーワードの検索範囲について 2023-08-30 卓 end

  @Update(sqlFile = true)
  int updateById(long pat_id, PatPersonalMain pat);

  /**
   * 患者ID1件取得
   * @param patId 患者ID
   * @return 抽出条件を満たした患者
   */
  @Select
  PatPersonalMain selectById(Long patId);

  @Select
  long selectNextSeqPatId();
  /**
   * 詳細検索
   */
  @Select
  List<Long> selectByDetailedSearchCondition(PatPersonalMainDetailedConditions conditions, List<String> facilityCdList);

  @Update(sqlFile = true)
  int updateInOutClassById(long pat_id, Integer in_out_class, PatPersonalMain pat);

  @Select
  List<PatPersonalMain> selectAll(List<String> facilityCdList);

  // 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add start
  @Select
  List<PatPersonalMain> selectAllExamRstPat(List<String> facilityCdList);
  // 9729-検査再計算ツール画面について 20231115仕様変更 zhoubin add end

  @Update(sqlFile = true)
  int updateIsDelById(long patId);

  /**
   * 施設コードと院内表示用患者IDから患者情報取得
   * @param facilityCd 抽出データ（処理対象施設の施設コード）
   * @param hospPatId 抽出データ（処理対象患者の院内表示用の患者ID）
   * @return 患者情報
   */
  @Select
  PatPersonalMain selectPatInfoByHospPatId(String facilityCd, String hospPatId);

  /**
   * 紹介状上に入力した患者情報がDBに更新
   *
   * @param pat_id
   * @param pat
   * @return
   */
  @Update(sqlFile = true, excludeNull = true)
  int updateByIdFromIntroductionLetter(long pat_id, PatPersonalMain pat);

  /**
   * 患者IDから患者名を取得
   * @param pat_id
   * @return
   */
  @Select
  List<PatNameId> selectPatNameById(List<Long> patIdList);

  @Update(excludeNull = true)
  int update(PatPersonalMain entity);

  /**
   * 入外区分を更新
   *
   * @param patIdList 更新対象患者IDリスト
   * @param inOutClass 入外区分
   * @return 更新件数
   */
  @Update(sqlFile = true)
  int updateInOutClass(List<Long> patIdList, Integer inOutClass);

  /**
   * 入外区分で患者情報を取得
   * @param facilityCd  施設コード
   * @param inOutClass  入外区分
   */
  @Select
  ItemFacilityCalendar selectPatInfoByInOutClass(String facilityCd, int inOutClass);

// add 障害票一覧_施設カレンダー 修正 chen start
  /**
   * 入外区分で患者情報を取得
   * @param facilityCd  施設コード
   * @param inOutClass  入外区分
   */
  @Select
  List<String> selectPatInfoByInOutClassList(String facilityCd, int inOutClass);
// add 障害票一覧_施設カレンダー 修正 chen end

  /**
   * 死んだ患者を数える
   * @param startDate 開始日
   * @param endDate 終了日
   * @param facilityCd  施設コード
   */
  @Select
  List<NumberOfPat> countDiePat(String startDate, String endDate, String facilityCd);

  /**
   * 死亡日別の患者IDを選択
   * @param date 日付
   * @param facilityCd  施設コード
   */
  @Select
  List<PatPersonalMain> selectPatIdsByDieDate(String date, String facilityCd);

  @Select
  PatPersonalMain selectByIdForWriteCard(Long patId);

  /**
   * 開示した元施設のデータをコピーして、自施設の患者のデータに埋め込む
   */
  @Update(sqlFile = true)
  int updateByOtherPatId(Long patIdSrc, Long patIdDst);

  /** 施設毎患者リスト取得用
   * @param facilityCdList 施設コードリスト
   * @param simpleSearchConditions 簡易検索対象条件
   * @return 患者リスト
   */
  @Select
  List<PatPersonalMain> selectAllAndSetting(List<String> facilityCdList, int simpleSearchConditions);

  /**
   * 患者IDを指定して患者取得
   * @param patIdList 患者IDリスト
   * @param facilityCd 施設コード
   * @param simpleSearchConditions 簡易検索対象条件
   * @return 患者リスト
   */
  @Select
  List<PatPersonalMain> selectByIdListFacilityCdAndSetting(List<Long> patIdList, String facilityCd, int simpleSearchConditions);

  // add FNSI-共有された患者情報作成を見直し 江 start
  @Select
  PatPersonalMain selectContactInfoById(long pat_id);
  @Select
  Long selectOtherContactPatId(String facilityCd,String hosp_pat_id);
  // add FNSI-共有された患者情報作成を見直し 江 end

  //add FNSI-患者情報の連絡先の施設内患者の選択による登録変更同期を追加 江 start
  @Select
  /**
   * 患者IDを指定して患者取得
   * @param facilityCd 施設コード
   * @return 患者リスト
   */
  List<PatPersonalMain> selectPatListByFacility(String facilityCd);
  //add FNSI-患者情報の連絡先の施設内患者の選択による登録変更同期を追加 江 end

//  add  FNSI 外来/入院患者治療予定件数の不正 5886修正 shan start
  @Select
  List<TreatDatePatIdList> selectPatInfoByInOutClassNew(String facilityCd, int inOutClass, List<String> patIdList);
//  add  FNSI 外来/入院患者治療予定件数の不正 5886修正 shan　end

  //add 患者検索設定後処理不正 修正 20230601 ztc start
  @Select
  List<PatPersonalMain> selectByFacilityCdList(List<String> facilityCdList);

  @Select
  List<PatPersonalMain> selectByPatIdListAndFacilityCd(List<Long> patIdList, String facilityCd);
  //add 患者検索設定後処理不正 修正 20230601 ztc end
// add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou start
  @Select
  List<String> selectByName (String keyWord, List<String> facilityCds, boolean searchFlag);
// add 9227 ログ参照にて検索条件でフリーワードに「3」で「終わる」を指定すると条件と合わない検索結果となる。 zhou end

  //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 start
  @Select
  List<PatPersonalMain> selectSomePatColumnsListByFacility(String facilityCd);
  //add #9799 クールマスタ変更に伴うスケジュール処理が不正 zhaoqi 20231122 end

  // add #9323 帳票「並び替え」機能のオーバーホール　高 start
  @Select
  String getInOutClassByPatPersonalMain(String facilityCd, String patId);
  // add #9323 帳票「並び替え」機能のオーバーホール　高 end

  //add #10203 profile連携で同姓同名のチェックが行われない 20240110 zhaoqi start
  @Select
  List<Long> getAllDataForIsSameIsZero(String facilityCd);
  //add #10203 profile連携で同姓同名のチェックが行われない 20240110 zhaoqi end

  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 zhaoqi start
  @Select
  List<PatPersonalMain> selectAllByTransCd(String facilityCd, List<Integer> transportCdList);

  @Select
  List<PatPersonalMain> selectAllBySeverityCd(String facilityCd, List<Integer> severityCdList);

  @Select
  List<PatPersonalMain> selectAllByDieCd(String facilityCd, List<Integer> dieCdList);

  @Select
  List<PatPersonalMain> selectAllByPrimaryDiseaseCd(String facilityCd, List<Integer> PrimaryDiseaseCdList);
  //add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 zhaoqi 20240228 zhaoqi end

  @Select
  /* update by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --start */
  List<PatPersonalMain> selectPatByFacilityCd(List<String> facilityCdList, List<Long> patIds);
  /* update by chamaojia 2026-02-05 [11893] キャッシュ軽減対応 --end */

  //add #10601 スケジュール表動作不正 start
  @Select
  List<PatPersonalMain> selectPatPersonalMainForHospPatIdListByPatIdList(String facilityCd, List<Long> patIdList);
  //add #10601 スケジュール表動作不正 end}

  // add #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 start
  @Select
  List<PatPersonalMain> selectAllByDieCdOrPrimaryDiseaseCd(String facilityCd, List<Integer> diseaseCdList);
  // add #10245 マスタ変更時点で患者情報履歴テーブルの追加や更新をしていないため正しいデータを出力できない ztc 20240712 end

  @Select
  List<PatPersonalMain> selectPatListByFacilityAndOtherPatId(String facilityCd, String patId);

  /**
   * 拠点コードから患者名を取得
   * @param facilityCd
   * @return
   */
  @Select
  List<PatPersonalMain> selectPatNameByFacilityCd(String facilityCd);

  // add #12462 患者情報共有->患者検索 start
  @Select
  List<PatientInfoSharing> selectPatientInformationSharing(PatInsuranceConditionsSharing patInsuranceConditionsSharing);
  // add #12462 患者情報共有->患者検索  end
}

