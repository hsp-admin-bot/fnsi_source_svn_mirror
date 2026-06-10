package jp.co.nikkiso.ntss.device_edge.util.MedicalCareInfo;

/**
 *  共通診療情報処理サービス.
 */
public interface MedicalCareInfoService {

  public MedicalCareInfo createMedicalCareInfo(String mediCareInfoJsonString);

  public String findWardName(MedicalCareInfo mediCareInfo);

  public String findMainCourseName(MedicalCareInfo mediCareInfo);

  public String findDialysisCourseName(MedicalCareInfo mediCareInfo);

}
