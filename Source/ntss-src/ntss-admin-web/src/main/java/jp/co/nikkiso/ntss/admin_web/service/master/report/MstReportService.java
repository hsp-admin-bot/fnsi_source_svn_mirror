package jp.co.nikkiso.ntss.admin_web.service.master.report;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstReport;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;

/**
 * 帳票マスタのインタフェース.
 *
 */
public interface MstReportService {

  /**
   * mst_reportの全レコードを読み込む.
   * @return mst_reportの全レコード
   */
  List<MstReport> selectAll(String facilityCd);
  //add 6502 6498 5984 定期・日常が分離されていない 吉 start
  List<MstReport> selectByFlag(String facilityCd,String vorcFlag);
  //add 6502 6498 5984 定期・日常が分離されていない 吉 end
  // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
  List<MstReport> selectAllForFixedAndNormal(String facilityCd, String is_disp, String is_del);
  // add #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
  /**
   * 1レコード追加する.
   * @param record エンティティ
   * @return
   */
  int insert(MstReport record, NtssUser ntssUser);

  /**
   * 1レコード削除する.
   * @param record エンティティ
   * @return
   */
  int delete(MstReport record);

  /**
   * 帳票名を更新する.
   * @param record エンティティ
   * @return
   */
  int updateReportName(MstReport record);

  /**
   * 3ファイルのパスを更新する.
   * @param record エンティティ
   * @return
   */
  int updateReportPath(MstReport record);

  /**
   * 表示非表示フラグを更新する.
   * @param record エンティティ
   * @return
   */
  int updateIsDisp(MstReport record);

  /**
   * 帳票マスタを読み込む.
   * @param reportCd レポートコード
   * @return mst_reportエンティティ
   */
  MstReport getMstReport(Long reportCd);

  /**
   * 帳票名, 表示非表示フラグ, 削除フラグを更新する.
   * @param request mst_reportレコード
   * @param facilityCd 施設コード
   * @param isReportChanged 帳票が変更されたフラグ
   */
  void updateListData(List<MstReport> request, final String facilityCd, Boolean isReportChanged, NtssUser ntssUser);

  // add #12589 どこかで使用している帳票も削除出来てしまう sunsy start
  /**
   * 削除しようとする帳票が以下の箇所に配置しているかを確認
   * @param request mst_reportレコード
   * @param facilityCd 施設コード
   */
  String checkIsCanDelete(List<MstReport> request, final String facilityCd);
  // add #12589 どこかで使用している帳票も削除出来てしまう sunsy end
  /**
   * 削除フラグを1に更新する.
   * @param reportCd レポートコード
   * @param facilityCd 施設コード
   */
  void updateIsDel(long reportCd, String facilityCd);

  //add 6502  装置帳票：定期・日常が分離されていない  吉 start
  MstReport checkRepeat(MstReport record, String facilityCd);
  //add 6502  装置帳票：定期・日常が分離されていない  吉 end

  /**
   * 帳票の選択された履歴の変更
   * @param reportCd レポートコード
   * @param selectedHst 選択された履歴
   */
  String updateSelectedHst(Long reportCd, String selectedHst);
}
