
package jp.co.nikkiso.ntss.admin_web.service.prescription;

import java.util.List;

import javax.validation.Valid;

import jp.co.nikkiso.ntss.admin_web.request.prescription.MedicineSelectionRequest;
import jp.co.nikkiso.ntss.admin_web.request.prescription.OrdPrescriptionDTO;
import jp.co.nikkiso.ntss.admin_web.request.prescription.OrdPrescriptionRequest;
import jp.co.nikkiso.ntss.admin_web.request.prescription.PrescriptionListRequest;
import jp.co.nikkiso.ntss.core.entity.MedicineSelection;
import jp.co.nikkiso.ntss.core.entity.MstTakeMedicine;
import jp.co.nikkiso.ntss.core.entity.OrdPersonalPrescription;
import jp.co.nikkiso.ntss.core.entity.OrdPrescription;
import jp.co.nikkiso.ntss.core.entity.custom.PrescriptionCount;
import jp.co.nikkiso.ntss.core.entity.custom.PrescriptionList;

public interface PrescriptionService {

    /**
     * 薬剤選択で検索.
     *
     * @param request
     *            処方薬剤選択条件
     * @return 薬剤選択
     *
     */
    public List<MedicineSelection> searchMedicineSelection(MedicineSelectionRequest request);

    /**
     * 処方歴検索.
     *
     * @param request
     *            処方情報択条件
     * @return 処方歴
     */
    public List<OrdPrescription> searchOrdPrescription(OrdPrescriptionRequest request);

    /**
     * 処方の詳細を取得する。
     *
     * @param ordPrescriptionNo
     *            処方オーダー番号
     *
     * @return 処方の詳細
     */
    public OrdPrescription selectOrdPrescriptionDetails(Long ordPrescriptionNo);

    /**
     * 処方箋情報コードで個人処方箋詳細を取得
     *
     * @param ordPrescriptionNo
     *            処方オーダー番号
     *
     * @return 個人処方箋の詳細
     */
    public OrdPersonalPrescription selectOrdPersonalPrescriptionDetails(Long ordPrescriptionNo);

    /**
     * 用法・用語マスタ取得する.
     *
     * @param listClass リスト種別
     * @param facilityCd 施設コード
     * @return 処方
     */
    public List<MstTakeMedicine> getTakeMedicine(String listClass, String facilityCd);

    /**
     * 保存.
     *
     * @param input
     */
    public OrdPrescriptionDTO save(@Valid OrdPrescriptionDTO input);

    /**
     * 削除.
     *
     * @param ordPrescriptionNo
     *            処方オーダー番号
     * @return
     */
    public List<OrdPrescription> delete(Long ordPrescriptionNo);

    // add FNSI-改修内容 イベント一覧の日付直下に、施設名を表示する dou start
    /**
     * 施設名を取得
     *
     * @param facilityCd
     *            施設コード
     * @return 施設名
     *
     */
    String getFacilityNameByCd(String facilityCd);

    /**
     * 処方歴検索.
     *
     * @param facilityCdList 処方情報択条件
     * @param treatDate 指定日
     * @param prescriptionTypeList 院内・院外
     * @return 処方歴
     */
    //mod #12462 患者共有情報 by zrx start
//    List<PrescriptionList> getPrescriptionList(List<Long> patIdList, String issueDate, List<String> prescriptionTypeList);
    List<PrescriptionList> getPrescriptionList(List<Long> patIdList, String issueDate, List<String> prescriptionTypeList, Integer patientShareMode,String facilityCd);
    //mod #12462 患者共有情報 by zrx end
  // mod #9738 患者経過総合ビューアで検査依頼、一般撮影検査依頼、招待状、処方、患者イベントのデータが正常に表示されない zy start
//    List<PrescriptionCount> getPrescriptionCount(String patId, String facilityCd);
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --start */
  // List<PrescriptionCount> getPrescriptionCount(String patId, String facilityCd,String startDate,String endDate);
  List<PrescriptionCount> getPrescriptionCount(String patId, String facilityCd,String startDate,String endDate, Integer patShareMode);
  /* upd by chamaojia 2026-03-16 [12462] 患者情報共有->患者経過総合ビューア --end */
  // mod #9738 患者経過総合ビューアで検査依頼、一般撮影検査依頼、招待状、処方、患者イベントのデータが正常に表示されない zy end

    /**
     * 処方対象件数取得_一括交付済み変更_日付変更時
     *
     * @param patIdList 患者IDリスト
     * @param issueDate 交付日
     * @return 一括交付済み変更モーダル
     */
    int getPatPrescriptionCount(List<Long> patIdList, String issueDate, String facilityCd);

    /**
     * 処方対象リスト取得_一括交付済み変更_確定ボタン押下時
     *
     * @param patIdList 患者IDリスト
     * @param issueDate 交付日
     * @return 一括交付済み変更モーダル
     */
    List<PrescriptionList> getOrdPrescriptionNoList(List<Long> patIdList, String issueDate, String facilityCd);

    /**
     * 交付状態を更新.
     *
     * @param bodyData 処方一覧のリクエスト
     */
    List<OrdPrescription> updateIssueState(PrescriptionListRequest bodyData);

    /**
     * 一括オーダー処方.
     *
     * @param bodyData 処方一覧のリクエスト
     * @return 処方歴
     */
    List<OrdPrescription> copyPrescription(PrescriptionListRequest bodyData);
}
