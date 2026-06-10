package jp.co.nikkiso.ntss.admin_web.service.introductionLetterCreation;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.ShrPatInfo;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.Map;

public interface PatIntroductionLetterService {

	/**
	 * 患者情報を更新
	 *
	 * @param patId
	 * @param pat
	 * @return
	 * @throws Exception
	 */
	int updatePatientInfo(Long patId, PatPersonalMain pat) throws Exception;

	/**
	 * 紹介状の印刷
	 *
	 * @param introductionLetterHtml
	 * @param reportName
	 * @param mstReport
	 * @param patId
	 * @throws Exception
	 */
	void printReport(String introductionLetterHtml, String reportName, MstReport mstReport, Long patId)
			throws Exception;

  /* add by gaojuncheng  2023-02-01 [CodeOptimization]  start */
  // mod 9795 紹介状画面の画面表示を帳票のプログラムに準拠させる　吉 start
//  Map<String, Object> getIntroLetterTemplate(MstReport mstReport, Long patId, Long reportCd, NtssUser ntssUser);
  // mod 11488 紹介状登録内容保存時に帳票の版も記憶する　1.1A  吉 start
  // Map<String, Object> getIntroLetterTemplate(MstReport mstReport, Long patId, Long reportCd, NtssUser ntssUser) throws Exception;
  // mod #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao start
  // Map<String, Object> getIntroLetterTemplate(MstReport mstReport, Long patId, Long reportCd, NtssUser ntssUser,String ctlNo,String isUpdate) throws Exception;
  Map<String, Object> getIntroLetterTemplate(MstReport mstReport, Long patId, Long reportCd, NtssUser ntssUser,String ctlNo,String isUpdate, String reportStartDate) throws Exception;
  // mod #12196 紹介状作成時に参照される各データが常に最新値になるのはNG zhao end
  // mod 11488 紹介状登録内容保存時に帳票の版も記憶する　1.1A  吉 end
  // mod 9795 紹介状画面の画面表示を帳票のプログラムに準拠させる　吉 end

  ResponseEntity<?> printReport(Map<String, Object> payload, NtssUser ntssUser, String mappingUrl);

  ResponseEntity<?> syncPatientInformation(Map<String, Object> payload, String mappingUrl) throws Exception;
  /* add by gaojuncheng  2023-02-01 [CodeOptimization]  end */
  // add #12462 患者情報共有 zhao start
  List<ShrPatInfo> getShrPatInfoForPatId(Long patId, String facilityCd);
  // add #12462 患者情報共有 zhao end
}
