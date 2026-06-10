package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Delete;
import org.seasar.doma.Insert;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstComsvSetting;;

/**
 * 通信サーバー設定のDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstComsvSettingDao {

  /**
   * 全件取得SQL（resourceあり）
   * @return
   */
  @Select
  List<MstComsvSetting> selectAll();

  /**
   * 主キーから取得する（resourceあり）
   * @param facilityCd 主キー
   * @param deviceEdgeNo　主キー
   * @return
   */
  @Select
  MstComsvSetting selectByCd(String facilityCd, Integer deviceEdgeNo);

  //add redmine bug#6392 劉 start
  /**
   * 仮想端末ログ内容ら取得
   * @param facilityCd 主キー
   * @param deviceEdgeNo　主キー
   * @return
   */
  @Select
  boolean selectIsLogTypeOnByCd(String facilityCd, Integer deviceEdgeNo);
  //9871 addデバイスエッジが並び順の通りに表示しない zhao start
  @Select
  List<MstComsvSetting>  selectByOrderItem(String facilityCd);
  //9871 addデバイスエッジが並び順の通りに表示しない zhao end

  @Select
  List<MstComsvSetting> selectByBedCds(String facilityCd, List<Integer> bedCdList);
  //add redmine bug#6392 劉 end

  // #12625 2026.05.10 add 利用者削除時の仮想端末スタッフ一覧連動 TDC高村 start
  /**
   * 施設コードで装置通信・仮想端末マスタを全件・全列取得
   * @param facilityCd 施設コード
   * @return 該当施設の論理削除されていない装置通信・仮想端末マスタ一覧
   */
  @Select
  List<MstComsvSetting> selectByFacilityCd(String facilityCd);
  // #12625 2026.05.10 add 利用者削除時の仮想端末スタッフ一覧連動 TDC高村 end

  /**
   * 自動生成されるINSERT
   * @param param
   * @return
   */
  @Insert
  int insert(MstComsvSetting param);

  /**
   * 自動生成されるDELETE
   * @param param
   * @return
   */
  @Delete
  int delete(MstComsvSetting param);

  /**
   * 自動生成されるUPDATE
   * @param param
   * @return
   */
  @Update
  int update(MstComsvSetting param);

  //add #10412 次患者更新関連全体見直し対応 朴 start
  @Select
  List<MstComsvSetting>  selectAllByFacilityCdAndCodeList(String facilityCd, List<Integer> codeList);
  //add #10412 次患者更新関連全体見直し対応 朴 end

  //add #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される start
  @Update(sqlFile = true)
  int updateDisp(String facilityCd, Integer deviceEdgeNo);
  //add #12298 装置通信・仮想端末マスタにてマスタ同期失敗のメッセージに削除済みDEが表示される end

  // #12625 2026.05.10 add 利用者削除時の仮想端末スタッフ一覧連動 TDC高村 start
  /**
   * 仮想端末スタッフ一覧（lcd_staff_list）と更新日時のみを更新
   */
  @Update(sqlFile = true)
  int updateLcdStaffList(Long comsvCd, String lcdStaffList);
  // #12625 2026.05.10 add 利用者削除時の仮想端末スタッフ一覧連動 TDC高村 end
}
