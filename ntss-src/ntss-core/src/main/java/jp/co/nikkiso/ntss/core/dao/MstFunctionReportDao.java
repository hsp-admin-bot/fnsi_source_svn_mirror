package jp.co.nikkiso.ntss.core.dao;

import java.util.List;

import org.seasar.doma.Dao;
import org.seasar.doma.Select;
import org.seasar.doma.Update;
import org.seasar.doma.Insert;
import org.seasar.doma.boot.ConfigAutowireable;

import jp.co.nikkiso.ntss.core.entity.MstFunctionReport;

/**
 * 機能帳票マスタのDaoインタフェース.
 */
@ConfigAutowireable
@Dao
public interface MstFunctionReportDao {

  /**
   * 機能と帳票名で新規機能帳票マスタを登録
   * @param functionCd 機能cコード
   * @param facilityCd 施設コード
   * @param reportName 帳票名
   * @return 更新件数
   */
  @Insert(sqlFile = true)
  int insertByFunctionCdAndReportName(String functionCd, String reportName, String facilityCd);

  /**
   * 機能コード、施設コードをもとに機能帳票マスタを取得します.
   *
   * @param functionCd 機能コード
   * @param facilityCd 施設コード
   * @return 機能帳票マスタのリスト
   */
  @Select
  // mod FNSI-#522、IES364 選択された機能により、対象の帳票を表示する。 夏 start
  //List<MstFunctionReport> selectByFunctionCdAndFacilityCd(String functionCd, String facilityCd);
  List<MstFunctionReport> selectByFunctionCdAndFacilityCd(String functionCd, String facilityCd, String printFlag);
  // mod FNSI-#522、IES364 選択された機能により、対象の帳票を表示する。 夏 end
  /**
   * 削除フラグを1に更新する.
   * @param rec 帳票データ
   * @return
   */
  @Update(sqlFile = true)
  int updateIsDel(MstFunctionReport rec);
  //add 6410 デグレ：機能帳票から「治療経過表」が消えている 吉 start
  @Select
  // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
  //List<MstFunctionReport> selectReportFixedByFunctionCdAndFacilityCd(String functionCd, String facilityCd);
  List<MstFunctionReport> selectReportFixedByFunctionCdAndFacilityCd(String functionCd, String facilityCd, String printFlag, List<String> facilitySettingNos);
  // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
  //add 6410 デグレ：機能帳票から「治療経過表」が消えている 吉 end

  // add #12419 各画面の機能帳票リストが機能帳票マスタの表示順になっていない limingzhe start
  @Select
  List<MstFunctionReport> selectAllForFixedAndNormal(String functionCd, String facilityCd, String printFlag, List<String> facilitySettingNos, String is_disp, String is_del);
  // add #12419 各画面の機能帳票リストが機能帳票マスタの表示順になっていない limingzhe end

  // add #12589 どこかで使用している帳票も削除出来てしまう sunsy start
  /**
   * 機能帳票マスタと関連するすべての帳票を取得
   * @param facilityCd
   * @return 帳票コード
   */
  @Select
  List<Integer> selectReportCdsByFacilityCd(String facilityCd);
  // add #12589 どこかで使用している帳票も削除出来てしまう sunsy end
}
