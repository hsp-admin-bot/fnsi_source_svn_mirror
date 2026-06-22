package jp.co.nikkiso.ntss.admin_web.service;

import java.util.List;

import jp.co.nikkiso.ntss.core.entity.MstCompTreatment;
import jp.co.nikkiso.ntss.core.entity.MstComplaint;

/**
 * マスタ編集（愁訴処置マスタ）向けServiceインターフェース.
 * <p>愁訴マスタおよび処置マスタを取得/更新します.</p>
 */
public interface ComplaintService {
  /**
   * 対象施設の愁訴マスタ（削除済み除く）を全て取得します.
   * @param facilityCd 施設コード
   * @return 愁訴マスタのリスト
   */
  List<MstComplaint> getAllMstComplaints(String facilityCd);

  /**
   * 対象施設の愁訴マスタを更新します.
   * @param facilityCd 施設コード
   * @param list 更新する愁訴マスタのリスト
   */
  int[] updateMstComplaints(String facilityCd, List<MstComplaint> list);

  /**
   * 対象施設の処置マスタ（削除済み除く）を全て取得します.
   * @param facilityCd 施設コード
   * @return 処置マスタのリスト
   */
  List<MstCompTreatment> getAllMstCompTreatments(String facilityCd);

  /**
   * 対象施設の処置マスタを更新します.
   * @param facilityCd 施設コード
   * @param list 更新する愁訴マスタのリスト
   */
  int[] updateMstCompTreatments(String facilityCd, List<MstCompTreatment> list);
}
