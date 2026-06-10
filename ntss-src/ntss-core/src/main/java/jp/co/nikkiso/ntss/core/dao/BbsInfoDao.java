package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import org.seasar.doma.jdbc.SelectOptions;

import jp.co.nikkiso.ntss.core.entity.BbsInfo;
import jp.co.nikkiso.ntss.core.entity.BbsInfoLimit;
import jp.co.nikkiso.ntss.core.entity.custom.dataFacilityCalendar.NumberOfBbsInfo;

@ConfigAutowireable
@Dao
public interface BbsInfoDao {
  /**
   * 掲示板登録情報取得
   */
  @Select
  List<BbsInfo> selectAll(SelectOptions options);

  /**
   * 掲示板登録情報取得(施設指定)
   */
  @Select
  List<BbsInfo> selectByFacilityCd(SelectOptions options, String facility_cd);

  /**
   * 掲示板登録情報取得(掲示板番号指定)
   */
  @Select
  BbsInfo selectById(long bbs_ctl_no);

  /**
   * 掲示板登録情報登録
   */
  @Insert(sqlFile = true)
  int insert(BbsInfo bbs);

  /**
   * bbs_info.bbs_ctl_noの次のシーケンス
   */
  @Select
  long selectNextSeqBbsCtlNo();

  /**
   * 掲示板登録情報更新
   */
  @Update(sqlFile = true)
  int updateByBbsCtlNo(long bbs_ctl_no, BbsInfo bbs);

  /**
   * 掲示板登録情報一覧更新
   */
  @Update(sqlFile = true)
  int updateOnlyStaff(BbsInfo bbs,String curLoginFacilityCd);

  /**
   * 掲示板登録情報削除
   */
  @Delete(sqlFile = true)
  int deleteById(long bbs_ctl_no);

  /**
   * 検索(患者ID)
   */
  @Select
  List<Long> selectBySearchCondition(String facility_cd, String dialysisDate, Long kur, List<Long> roomBedGroup);

  /**
   * 検索(掲示板番号)
   */
  @Select
// mod FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
//  List<BbsInfo> selectByIdList(
  List<BbsInfoLimit> selectByIdList(
// mod FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
      String facility_cd,
      List<Long> bbsCtlNoList,
      List<String> func_cd_list,
      List<Long> kind_no_list,
      String notice_start_date,
      String notice_end_date,
      String dialysis_date,
      Long kur_cd,
      List<Long> room_bed_group_cd,
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start
      Long limitFrom,
      Long limitTo,
      String userId,
      String sortColumn,
      String sortKind,
      String targetUserId,
      List<Long> bbsCtlNoListFreeWord,
      String text
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
  );
// mod FNSI-改修内容 検索欄の治療日、クール、ベッドの条件を指定された時、検索されたデータがない dou start
  /**
   * 検索対象患者list
   */
  @Select
  List<BbsInfo> selectPatInfo(
      String facility_cd,
      List<String> func_cd_list,
      List<Long> kind_no_list,
      String notice_start_date,
      String notice_end_date
  );
  @Select
  List<BbsInfo> selectPatInfoForCalendar(
    String facility_cd,
    String notice_start_date,
    String notice_end_date,
    String text
  );
// mod FNSI-改修内容 検索欄の治療日、クール、ベッドの条件を指定された時、検索されたデータがない dou end
  @Select
  List<BbsInfo> selectByIdListForCalendar(
      String facility_cd,
      List<Long> bbsCtlNoList,
      String notice_start_date,
      String notice_end_date,
      String dialysis_date,
      Long kur_cd,
      List<Long> room_bed_group_cd,
      String text,
      Boolean isDispBbsAll
  );

  /**
   * 掲示板ファイル情報登録
   */
  @Update(sqlFile = true)
  int updateOnlyFileInfo(long bbs_ctl_no, String file_info);

  @Update(sqlFile = true)
  int updateOnlyFile(long bbs_ctl_no, String file_info);

  /* modify by chamaojia 2023-11-07 [9717] クエリー条件がコレクションに変わり、範囲クエリー  --start */
  /**
   * 掲示板の種類を数える
   * @param startDate 開始日
   * @param endDate 終了日
   * @param facilityCd 施設コード
   * @param kindNoList 種別番号集合
   */
  @Select
  List<NumberOfBbsInfo> countBbsKindByFacCalDate(String startDate, String endDate, String facilityCd, List<Long> kindNoList);
  /* modify by chamaojia 2023-11-07 [9717] クエリー条件がコレクションに変わり、範囲クエリー  --end */

  /**
   * 掲示板登録情報更新
   */
  @Update(sqlFile = true)
  int updateFileInfoByBbsCtlNo(Long bbs_ctl_no, BbsInfo bbs);

  /**
   * 種別と日付が一致する項目を取得する
   * @param facilityCd 施設コード
   * @param kindNo 種別番号
   * @param targetDate 対象yyyyMMdd
   * @return
   */
  @Select
  List<BbsInfo> selectByKindAndDate(String facilityCd, Long kindNo, String targetDate);
  /* add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 start */
  /**
   * 検索(掲示板番号)
   */
  @Select
  Long selectByIdListCount(
    String facility_cd,
    List<Long> bbsCtlNoList,
    List<String> func_cd_list,
    List<Long> kind_no_list,
    String notice_start_date,
    String notice_end_date,
    String dialysis_date,
    Long kur_cd,
    List<Long> room_bed_group_cd,
    String userId,
    String targetUserId,
    List<Long> bbsCtlNoListFreeWord,
    String text
  );
// add FNSI-No.554 掲示期間を広げると、検索件数が多い場合にフリーズする 追加読み込み型にする。 陳 end
// add #9273 施設設定マスタのNo105の設定どおり動かない。  start
@Update(sqlFile = true)
int updateDateByCd(Long bbsCtlNo, int dataNumber);
  // add #9273 施設設定マスタのNo105の設定どおり動かない。  end

  // add #11716 曜日パターン変更の不正 関 start
  @Update(sqlFile = true)
  int updateIsDispToZeroByList(String facilityCd, List<Long> bbsCtlNos);
  // add #11716 曜日パターン変更の不正 関 end
}
