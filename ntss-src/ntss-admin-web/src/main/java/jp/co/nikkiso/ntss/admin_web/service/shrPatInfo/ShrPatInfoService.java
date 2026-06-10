package jp.co.nikkiso.ntss.admin_web.service.shrPatInfo;

import com.fasterxml.jackson.core.JsonProcessingException;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.dto.PatInfo.SearchPat.PatInsuranceConditionsSharing;
import jp.co.nikkiso.ntss.core.entity.PatientInfoSharingDetails;
import jp.co.nikkiso.ntss.core.entity.ShrPatInfo;
import jp.co.nikkiso.ntss.core.entity.custom.PatientInfoSharing;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Map;

public interface ShrPatInfoService {

  /**
   * 患者情報共有一覧を取得する。
   *
   * @param patInsuranceConditionsSharing 保険・条件に基づく共有検索条件
   * @param facilityCd 施設コード
   * @return 患者情報共有の一覧
   */
  List<PatientInfoSharing> patientInformationSharing(
    PatInsuranceConditionsSharing patInsuranceConditionsSharing,
    String facilityCd
  );

  /**
   * 患者情報共有の詳細情報を取得する。
   *
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @return 患者情報共有詳細情報
   */
  PatientInfoSharingDetails sharingDetails(Long patId, String facilityCd);

  /**
   * 共有ファイルをアップロードする。
   *
   * @param file アップロード対象のファイル
   * @param params 追加パラメータ（JSON文字列など）
   * @throws Exception 処理中に例外が発生した場合
   */
  void uploadShrFileAttachment(MultipartFile file, String params) throws Exception;

  /**
   * 共有ファイルをダウンロードする。
   *
   * @param filepath ファイルパス
   * @param facilityCd 施設コード
   * @return ダウンロード対象ファイルのパスまたは情報
   * @throws Exception 処理中に例外が発生した場合
   */
  String downloadShrFileAttachment(String filepath, String facilityCd) throws Exception;

  /**
   * 患者共有情報を新規登録する。
   *
   * @param shrPatInfo 患者共有情報エンティティ
   * @param ntssUser 操作ユーザ情報
   * @param files 添付ファイル一覧
   * @throws Exception 処理中に例外が発生した場合
   */
  void saveShrPatInfo(ShrPatInfo shrPatInfo, NtssUser ntssUser, MultipartFile[] files) throws Exception;

  /**
   * 患者共有情報を更新する。
   *
   * @param shrPatInfo 患者共有情報エンティティ
   * @param ntssUser 操作ユーザ情報
   * @param files 添付ファイル一覧
   * @throws Exception 処理中に例外が発生した場合
   */
  void updateShrPatInfo(ShrPatInfo shrPatInfo, NtssUser ntssUser, MultipartFile[] files) throws Exception;

  /**
   * 指定施設の患者共有詳細一覧をダウンロード用に取得する。
   *
   * @param facilityCd 施設コード
   * @return 患者共有情報一覧
   * @throws JsonProcessingException JSON処理時に例外が発生した場合
   */
  List<PatientInfoSharing> patientDetailsDown(String facilityCd) throws JsonProcessingException;

  /**
   * ダウンロード対象の施設コード一覧を取得する。
   *
   * @return 施設コードの一覧
   */
  Map<String, Object> facilityCdDown(String facilityCd);

  /**
   * 患者情報共有を削除する。
   *
   * @param shrPatInfoId 患者共有情報ID
   */
  void deleteShrPatInfo(Long shrPatInfoId);

  /**
   * 対応施設情報を取得する。
   *
   * @param facilityCd 施設コード
   * @return キー：種別、値：施設コード一覧のMap
   * @throws JsonProcessingException JSON処理時に例外が発生した場合
   */
  Map<String, List<String>> correspondingFacilities(String facilityCd) throws JsonProcessingException;

  /**
   * 共有イベントの添付ファイルを削除する。
   *
   * @param fileInfo 削除対象ファイル情報一覧
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @throws Exception 処理中に例外が発生した場合
   */
  void deleteEventFileAttachment(List<Map<String, String>> fileInfo, long patId, String facilityCd) throws Exception;

  // add #12462 患者情報共有->患者経過総合ビューア fang start
  /**
   * @param patId 患者ID
   * @param facilityCd 施設コード
   * @return ShrPatInfo 共有情報
   */
  List<ShrPatInfo> selectShrPatInfoByPatId(Long patId,String facilityCd);
  // add #12462 患者情報共有->患者経過総合ビューア fang end
}
