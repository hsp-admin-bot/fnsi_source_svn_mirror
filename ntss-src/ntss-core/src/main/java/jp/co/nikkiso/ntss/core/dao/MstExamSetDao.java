package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;
import jp.co.nikkiso.ntss.core.entity.MstExamSet;
import org.seasar.doma.jdbc.SelectOptions;


@ConfigAutowireable
@Dao
public interface MstExamSetDao {

  /**
   * 検査セットマスタ：対象施設の検査セット取得用(削除済みも含む)
   * 施設コード：必須
   * @param facilityCd 施設コード
   * @param requestFlg セット使用区分 依頼専用
   * @param recodeFlg セット使用区分 結果専用
   * @return 検査セット情報
   */
  @Select
  List<MstExamSet> selectExamSetList(String facilityCd, Boolean requestFlg, Boolean recodeFlg);

  /**
   * 検査セットマスタ：対象施設の検査セット取得用(未削除のみ取得)
   * 施設コード：必須
   * @param facilityCd 施設コード
   * @return 検査セット情報
   */
  @Select
  List<MstExamSet> selectValidExamSetList(String facilityCd);

  /**
   * 検査セットマスタ：検査セットコード指定取得
   * 検査セットコード：必須
   * @param examSetCd 検査セットコード
   * @return 検査セットマスタ(0～1件)
   */
  @Select
  MstExamSet selectExamSetByCd(Long examSetCd);

  // add FutreNetWeb+SI課題管理No4770対応 趙 start
  @Select
  List<MstExamSet> selectAll(SelectOptions options, MstExamSet params);
  // add FutreNetWeb+SI課題管理No4770対応 趙 end
  @Select
  List<MstExamSet> selectExamsetByPhyOrdClass(String facilityCd);

  //add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao start
  @Update(sqlFile = true)
  int updateExamItemInfoByItemCd(String facilityCd, String examItemInfo);
  //add 10618検査セットマスタ、検査項目マスタ、一般撮影検査依頼マスタ編集時に関連データを補正する zhao end

  //add 10553 連携イベント発生部分不正【最優先】zhao start
  @Select
  List<MstExamSet> selectExamSetByExamItemCd(String facilityCd, String examItemCd);
  //add 10553 連携イベント発生部分不正【最優先】zhao end

  /**
   * 検査セットマスタ：対象施設の検査セット取得用(削除済みも含む)
   * 施設コード：必須
   * @param facilityCd 施設コード
   * @return 検査セット情報
   */
  @Select
  List<MstExamSet> selectAllExamSetListByFacility(String facilityCd);
}
