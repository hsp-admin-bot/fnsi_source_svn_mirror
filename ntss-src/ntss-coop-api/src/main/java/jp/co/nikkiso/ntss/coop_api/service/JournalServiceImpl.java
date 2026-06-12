package jp.co.nikkiso.ntss.coop_api.service;

import java.io.ByteArrayInputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileOutputStream;
import java.io.FilenameFilter;
import java.io.IOException;
import java.net.URI;
import java.net.URISyntaxException;
import java.net.URL;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Timestamp;
import java.text.DateFormat;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Base64;
import java.util.Date;
import java.util.HashMap;
import java.util.Iterator;
import java.util.LinkedList;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Set;
import java.util.stream.Collectors;

import jp.co.nikkiso.ntss.api.service.report.ReportService;
import jp.co.nikkiso.ntss.api.service.report.ReportForDistributionListService;
import jp.co.nikkiso.ntss.api.service.report.ReportForMachineReportService;
import jp.co.nikkiso.ntss.api.service.report.ReportForLabelReportService;
import jp.co.nikkiso.ntss.api.service.report.ReportForIntroductionReportService;
import jp.co.nikkiso.ntss.api.service.report.ReportForOnePatientService;
import jp.co.nikkiso.ntss.api.service.report.ReportForTotalService;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import jp.co.nikkiso.ntss.core.dao.MstExamSetDao;
import jp.co.nikkiso.ntss.core.entity.MstExamSet;
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.SelectOptions;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.springframework.aop.framework.AopProxyUtils;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ResourceLoader;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
import org.springframework.http.ResponseEntity;
import org.springframework.http.client.HttpComponentsClientHttpRequestFactory;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;

import tools.jackson.core.type.TypeReference;

import jp.co.nikkiso.ntss.api.constant.ReportConstant;
import jp.co.nikkiso.ntss.api.constant.ReportConstant.ReportDataKey;
import jp.co.nikkiso.ntss.api.service.SysDailyNoService;
import jp.co.nikkiso.ntss.api.service.SysDataSetService;
import jp.co.nikkiso.ntss.api.service.utils.AsposeCellsUtils;
import jp.co.nikkiso.ntss.api.utils.ObjectMapperUtil;
import jp.co.nikkiso.ntss.coop_api.request.CallApiJournalRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalCreateRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalDeliveryRequest;
import jp.co.nikkiso.ntss.coop_api.request.JournalUpdateRequest;
import jp.co.nikkiso.ntss.coop_api.request.MntIfEdgeClientConnectRequest;
import jp.co.nikkiso.ntss.coop_api.response.ErrorMessage;
import jp.co.nikkiso.ntss.coop_api.utils.ClockWrapper;
import jp.co.nikkiso.ntss.coop_api.utils.CoopCdConstant;
import jp.co.nikkiso.ntss.coop_api.utils.DateUtil;
import jp.co.nikkiso.ntss.coop_api.utils.FileUtil;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConstant;
import jp.co.nikkiso.ntss.coop_api.utils.JournalConvertConstants;
import jp.co.nikkiso.ntss.coop_api.utils.JournalLogUtil;
import jp.co.nikkiso.ntss.coop_api.utils.JournalSendSkipConstant;
import jp.co.nikkiso.ntss.coop_api.utils.Key0Constant;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.AnaResult;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.CoopResult;
import jp.co.nikkiso.ntss.coop_api.utils.NtssCoopApiConstants.Crud;
import jp.co.nikkiso.ntss.coop_api.utils.OrdCoopNoConstant;
import jp.co.nikkiso.ntss.coop_api.web.websocket.IfEdgeMntSessionManager;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.MstCoopFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopIniDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentClassDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineClassDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineDao;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.OrdCoopNoDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdPrescriptionDao;
import jp.co.nikkiso.ntss.core.dao.PatCoopDetailDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainDao;
import jp.co.nikkiso.ntss.core.dao.PatExamMainHstDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.PatRadMainDao;
import jp.co.nikkiso.ntss.core.dao.PatRadMainHstDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopNoDao;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility.CommonSetting;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility.CoopOrdCd;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility.ReportType;
import jp.co.nikkiso.ntss.core.entity.MstCoopIni;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayout;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipmentClass;
import jp.co.nikkiso.ntss.core.entity.MstMedicine;
import jp.co.nikkiso.ntss.core.entity.MstMedicineClass;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdCoopNo;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatExamMainForAllOtherInfo;
import jp.co.nikkiso.ntss.core.entity.PatExamMainHst;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.PatRadMain;
import jp.co.nikkiso.ntss.core.entity.PatRadMainHst;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.entity.SysCoopNo;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.SysCoopJournalParam;
import jp.co.nikkiso.ntss.core.entity.json.LayoutExtSetting;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.Getter;
import lombok.NoArgsConstructor;
import lombok.Setter;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
import jp.co.nikkiso.ntss.core.config.DefaultDb;

// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
@Service
public class JournalServiceImpl implements JournalService {
  /**
   * DI
   */
  @Autowired
  SysCoopJournalDao sysCoopJournalDao;

  @Autowired
  MstCoopFacilityDao mstCoopFacilityDao;

  @Autowired
  MstKurDao mstKurDao;

  @Autowired
  MstCoopIniDao mstCoopIniDao;

  @Autowired
  PatMainDao patMainDao;

  @Autowired
  SysCoopNoDao sysCoopNoDao;

  @Autowired
  OrdCoopNoDao ordCoopNoDao;

  @Autowired
  MstTreatmentDao mstTreatmentDao;

  @Autowired
  OrdMainDao ordMainDao;

  @Autowired
  OrdCoopNoService ordCoopNoService;

  @Autowired
  ClockWrapper clockWrapper;

  @Autowired
  SysDailyNoService sysDailyNoService;

  @Autowired
  ReportService reportService;

  // add #12127 透析レポート連携のPDFに一部出力されない項目がある sunsy start
  @Autowired
  private ReportForOnePatientService reportForOnePatientService;

  // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
  @Autowired
  private ReportForDistributionListService reportForDistributionListService;
  // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end

  // add #11117 日常点検記録簿が1ページ1装置で出力される limingzhe start
  @Autowired
  ReportForMachineReportService reportForMachineReportService;
  // add #11117 日常点検記録簿が1ページ1装置で出力される limingzhe end

  // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
  @Autowired
  private ReportForLabelReportService reportForLabelReportService;
  // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end

  @Autowired
  ReportForIntroductionReportService reportForIntroductionReportService;

  // mod #11973 日常点検一覧帳票が正常に出せない limingzhe start
  // @Autowired
  // ReportForMultiTotalService reportForMultiTotalService;
  @Autowired
  ReportForTotalService reportForTotalService;
  // mod #11973 日常点検一覧帳票が正常に出せない limingzhe end
  // add #12127 透析レポート連携のPDFに一部出力されない項目がある sunsy end

  @Autowired
  PatPersonalMainDao patPersonalMainDao;

  // #8102-GX連携で実装されていない機能（処方情報連携） 周 add start
  @Autowired
  OrdPrescriptionDao ordPrescriptionDao;
  // #8102-GX連携で実装されていない機能（処方情報連携） 周 add end

  @Autowired
  LogService logService;

  // add 2021-03-19 外部連携：定時一括送信機能の複数データの対応。 孫 start
  @Autowired
  MstCoopLayoutDao mstCoopLayoutDao;

  @Autowired
  ConvertSendCommonService convertSendCommonService;
  // add 2021-03-19 外部連携：定時一括送信機能の複数データの対応。 孫 end

  // add 2021-03-30 課題No.37:オーダ番号につてい 孫 start
  @Autowired
  PatExamMainDao patExamMainDao;
  @Autowired
  private MstCoopIniService mstCoopIniService;
  @Autowired
  private FileUtil fileUtil;
  @Autowired
  PatRadMainDao patRadMainDao;

  @Autowired
  PatExamMainHstDao patExamMainHstDao;

  @Autowired
  PatRadMainHstDao patRadMainHstDao;
  // TODO:心電図検査オーダは未来の予定実現機能、未実現
  // @Autowired
  // PatPhyMainDao patPhyMainDao;
  // add 2021-03-30 課題No.37:オーダ番号につてい 孫 end

  // add 2021-04-02 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 start
  @Autowired
  private CallApiService callApiService;
  // add 2021-04-02 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 end

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End

  @Autowired
  private SysDataSetService sysDataSetService;
  @Autowired
  private ConvertCommonService convertCommonService;

  @Autowired
  IfEdgeMntSessionManager ifEdgeMntSessionManager;
  /**
   * レポートファイル一時出力フォルダ
   */
  @Value("${ntss.report.createJournalTmp}")
  private String createJournalTmp;

  /**
   * 帳票の拡張子(pdf)
   */
  private final String EXTENSION_PDF = ".pdf";

  // add 2022-10-19 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  /**
   * レポートタイプ(nkk)(pdf+xml+list)
   */
  private final String NKK = "nkk";

  /**
   * レポートタイプ(nec)(pdf+xml)
   */
  private final String NEC = "nec";
  // add 2022-10-19 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  // add 2021-07-09 Transaction対応 孫 start
  /**
   * レポートが有り場合、データを更新する
   */
  /* del by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // private boolean isReportUpdate = false;
  /* del by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
  // add 2021-07-09 Transaction対応 孫 end
  // add 7808 ep_dial連携でのpdfで治療方法にレポートの設定がない場合エラーになる 吉 start
  @Autowired
  MstFacilitySettingDao mstFacilitySettingDao;
  // add 7808 ep_dial連携でのpdfで治療方法にレポートの設定がない場合エラーになる 吉 end
  // add #7721 浄化申込の有無判定がジャーナルから取得するようになっている 王永吉 start
  @Autowired
  PatCoopDetailDao patCoopDetailDao;
  // add #7721 浄化申込の有無判定がジャーナルから取得するようになっている 王永吉 end
  // #8222-rep_dial連携で送信されるPDFの内容が文字化けで読めない 周 add start
  @Autowired
  ResourceLoader resourceLoader;
  @Autowired
  MstMedicineDao mstMedicineDao;
  @Autowired
  MstDialyzerDao mstDialyzerDao;
  @Autowired
  MstEquipmentDao mstEquipmentDao;
  // #8222-rep_dial連携で送信されるPDFの内容が文字化けで読めない 周 add end
  // add #8222-rep_dial連携で送信されるPDFの内容が文字化けで読めない 孟堅　start
  @Autowired
  MstMedicineClassDao mstMedicineClassDao;
  @Autowired
  MstEquipmentClassDao mstEquipmentClassDao;
  // add #8222-rep_dial連携で送信されるPDFの内容が文字化けで読めない　孟堅 　end
  // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
  @Autowired
  private MstExamSetDao mstExamSetDao;
  // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
  @Autowired
  private HealthService healthService;
  // add #9348 治療方法マスタに紐づけられているレポートレイアウトが削除されていると帳票作成に失敗する start
  @Autowired
  private MstReportDao mstReportDao;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;

  // add #9348 治療方法マスタに紐づけられているレポートレイアウトが削除されていると帳票作成に失敗する end
  /**
   * レポート管理用内部クラス
   */
  @Getter
  @Setter
  @NoArgsConstructor
  private class ReportPath {
    /**
     * レポートコード
     */
    private Long reportCd;
    /**
     * レポートのパス
     */
    private String dumpPath;
  }

  @Value("${ntss.coop-api.header-name}")
  private String headerKey;
  @Value("${ntss.coop-api.header-value}")
  private String headerValue;
  /**
   * RestTemplate
   */
  private RestTemplate restTemplate;

  public JournalServiceImpl() {
    HttpComponentsClientHttpRequestFactory clientHttpRequestFactory = new HttpComponentsClientHttpRequestFactory();
    clientHttpRequestFactory.setReadTimeout(0);
    clientHttpRequestFactory.setConnectionRequestTimeout(0);
    restTemplate = new RestTemplate(clientHttpRequestFactory);
  }

  @Override
  public List<SysCoopJournal> listJournalsByOrderNo(SysCoopJournal journal,List<String> coopResultList,String coopOrdNo) {
    SysCoopJournalParam param = new SysCoopJournalParam();
    param.setFacilityCd(journal.getFacilityCd());
    param.setDirection(journal.getDirection());
    param.setOrdNo(journal.getOrdNo());
    param.setPatId(journal.getPatId());
    param.setHospPatId(journal.getHospPatId());
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion()) ? "" : journal.getCoopVersion();
    param.setCoopVersion(coopVersion);
    param.setCoopResult(coopResultList);
    param.setCoopCd(journal.getCoopCd());
    param.setCoopOrdNo(coopOrdNo);
    param.setRegDate(journal.getRegDate());
    return sysCoopJournalDao.selectJournals(param);
    // mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    return sysCoopJournalDao.selectByOrdNoPatIdDirection(journal.getOrdNo(), journal.getPatId(), journal.getDirection(), journal.getCoopCd(), journal.getFacilityCd(),coopResultList, coopOrdNo);
//    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion())?"":journal.getCoopVersion();
//    return sysCoopJournalDao.selectByOrdNoPatIdDirection(journal.getOrdNo(), journal.getPatId(), journal.getDirection(),
//      journal.getCoopCd(), coopVersion, journal.getFacilityCd(),coopResultList, coopOrdNo);
    // mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  }

  @Override
  public List<SysCoopJournal> listJournalsRepDialByOrderNo(SysCoopJournal journal, List<String> coopResultList, String coopCd) {
    SysCoopJournalParam param = new SysCoopJournalParam();
    param.setFacilityCd(journal.getFacilityCd());
    param.setDirection(journal.getDirection());
    param.setOrdNo(journal.getOrdNo());
    param.setPatId(journal.getPatId());
    param.setHospPatId(journal.getHospPatId());
    param.setCoopCd(coopCd);
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion()) ? "" : journal.getCoopVersion();
    param.setCoopVersion(coopVersion);
    param.setCoopResult(coopResultList);
    param.setRegDate(journal.getRegDate());
    return sysCoopJournalDao.selectJournals(param);
    // mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    return sysCoopJournalDao.selectByOrdNoPatIdDirectionCoopCd(journal.getOrdNo(), journal.getPatId(), journal.getDirection(), coopCd, journal.getFacilityCd(),coopResultList);
//    return sysCoopJournalDao.selectByOrdNoPatIdDirectionCoopCd(coopVersion, journal.getOrdNo(), journal.getPatId(),
    // journal.getDirection(), coopCd, journal.getFacilityCd(),coopResultList);
    // mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  }

  @Override
  public List<SysCoopJournal> listJournalsUnprocess(SysCoopJournal journal) {
    SysCoopJournalParam param = new SysCoopJournalParam();
    param.setFacilityCd(journal.getFacilityCd());
    param.setDirection(journal.getDirection());
    param.setOrdNo(journal.getOrdNo());
    param.setPatId(journal.getPatId());
    param.setCoopCd(journal.getCoopCd());
    param.setHospPatId(journal.getHospPatId());
    // #6993-profile連携で受信した生存の有無登録 周 20230204 add start
    if (CoopCdConstant.EXAM_ORD.equals(journal.getCoopCd())
        && Key0Constant.NKK.equals(journal.getKey0())
        && JournalConvertConstants.DIRECTION_SEND.equals(journal.getDirection())) {
      String coopVersion = StringUtils.isEmpty(journal.getCoopVersion()) ? "" : journal.getCoopVersion();
      param.setCoopVersion(coopVersion);
      return sysCoopJournalDao.selectExamOrdJournalsToSkip(param);
    } else {
      // #6993-profile連携で受信した生存の有無登録 周 20230204 add end
      param.setAnaResult(Arrays.asList(AnaResult.UNPROCESS.getResult(), AnaResult.PROCESSING.getResult()));
      param.setCoopResult(Arrays.asList(CoopResult.UNPROCESS.getResult()));
      String coopVersion = StringUtils.isEmpty(journal.getCoopVersion()) ? "" : journal.getCoopVersion();
      param.setCoopVersion(coopVersion);
      param.setRegDate(journal.getRegDate());
      return sysCoopJournalDao.selectJournalsLargeEqualRegDate(param);
      // #6993-profile連携で受信した生存の有無登録 周 20230204 add start
    }
    // #6993-profile連携で受信した生存の有無登録 周 20230204 add end
  }

  @Override
  /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId --start */
  public List<SysCoopJournal> listJournalsUnDelivery(SysCoopJournal sysCoopJournal, String crud, List<String> toSkipAnaResult) {
    String facilityCd = sysCoopJournal.getFacilityCd();
    Long ordNo = sysCoopJournal.getOrdNo();
    Long patId = sysCoopJournal.getPatId();
    String hospPatId = sysCoopJournal.getHospPatId();
    String coopCd = sysCoopJournal.getCoopCd();
    return sysCoopJournalDao.selectByCoopResult(CoopResult.UNPROCESS.getResult(), JournalConvertConstants.DIRECTION_SEND, facilityCd, ordNo, patId, hospPatId, crud, toSkipAnaResult, coopCd);
  }

  /* modify by chamaojia 2023-02-01 [7050] インタフェースパラメータの追加ordNo、patId --end */
  // mod #7627 #7239 2023-03-14 卓 start
  @Override
  public List<SysCoopJournal> filterToSetSkipJournalList(SysCoopJournal crudDeleteJournal, OrdCoopNo ordCoopNo,List<String> coopResultList) {
    // 同じOrdNoのjournalを検索
    // List<String> coopResultList = Arrays.asList(
    // CoopResult.UNPROCESS.getResult()
    // ,CoopResult.RETRY.getResult()
    // ,CoopResult.INTERNAL_ERROR_BY_NTSS.getResult()
    // ,CoopResult.INTERNAL_ERROR_BY_CARTE.getResult());

    List<SysCoopJournal> skipJournalList = null;
    if (CoopCdConstant.REP_DIAL.equals(crudDeleteJournal.getCoopCd())) {
      skipJournalList = this.listJournalsRepDialByOrderNo(crudDeleteJournal, coopResultList, CoopCdConstant.REP_DIAL);
    } else {
      skipJournalList = this.listJournalsByOrderNo(crudDeleteJournal, coopResultList, ordCoopNo.getCoopOrdNo());
    }
    if (CollectionUtils.isEmpty(skipJournalList)) {
      return new ArrayList<>();
    }

    // REP_DIAL filter
    Boolean repDialToSetSkip = true;
    if (CoopCdConstant.REP_DIAL.equals(crudDeleteJournal.getCoopCd())) {
      List<SysCoopJournal> createJournalList = skipJournalList.stream().
        filter(creJ -> (Crud.CREATE.isSameResult(creJ.getCrud()) && CoopCdConstant.REP_DIAL.equals(creJ.getCoopCd())))
          .collect(Collectors.toList());

      List<SysCoopJournal> deleteJournalList = skipJournalList.stream().
        filter(delJ -> (Crud.DELETE.isSameResult(delJ.getCrud()) && CoopCdConstant.REP_DIAL.equals(delJ.getCoopCd())))
          .collect(Collectors.toList());

      for (SysCoopJournal creJ : createJournalList) {
        long coopCdIndexExitCount = deleteJournalList.stream().filter(delJ -> (delJ.getCoopCdIndex().equals(creJ.getCoopCdIndex())))
            .count();

        if (coopCdIndexExitCount == 0l) {
          repDialToSetSkip = false;
          break;
        }
      }
    }
    if (!repDialToSetSkip) {
      return new ArrayList<>();
    }

    long deleteCount = skipJournalList.stream().filter(journal -> journal.getCtlNo().equals(crudDeleteJournal.getCtlNo())).count();
    if (deleteCount <= 0) {
      skipJournalList.add(crudDeleteJournal);
    }

    return skipJournalList;
  }

  // mod #7627 #7239 2023-03-14 卓 end
  // del 2021-07-09 Transaction対応 孫 start
  // @Transactional
  // del 2021-07-09 Transaction対応 孫 end
  @Override
  public List<SysCoopJournal> insert(JournalCreateRequest request) {
    MstCoopFacility mstCoopFacility = mstCoopFacilityDao.select(request.getFacilityCd());
    if (mstCoopFacility == null) {
      throw new NotExistException("施設連携設定が存在しません");
    }
    CommonSetting commonSetting = mstCoopFacility.getCommonSetting();
    if (commonSetting == null) {
      throw new NotExistException("施設連携設定内の各機能共通設定が存在しません");
    }
    List<CoopOrdCd> coopOrdCds = commonSetting.getCoopOrdCds();
    if (coopOrdCds == null) {
      throw new NotExistException("オーダー種別設定が存在しません");
    }

    // del #10336 DBが高負荷になる（外部連携由来）2 start
    // // add 2020-11-04 FNSI-改修 外部連携706 徐 start
    // // 古いジャーナルの削除処理
    // // 不要なジャナル保持日
    // Integer journalKeepDays = commonSetting.getJournalKeepDays();
    // if (journalKeepDays != null && 0 != journalKeepDays.intValue()) {
    // delOldJournal(request.getFacilityCd(), journalKeepDays);
    // }
    // // add 2020-11-04 FNSI-改修 外部連携706 徐 end
    // del #10336 DBが高負荷になる（外部連携由来）2 end

    // add 2021-07-09 Transaction対応 孫 start
    // Step1:ジャーナル作成
    /* del by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
    // isReportUpdate = false;
    /* del by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
    // mod #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 start
    // #7304 mod 異なる連携の機能を組み合わせて使用する方法 荘 2024-07-19 start
    // Long acceptNo = sysDailyNoService.getAcceptNo(request.getFacilityCd(), request.getCoopCd(), request.getBaseDate());
    Long acceptNo = sysDailyNoService.getAcceptNo(request.getFacilityCd(), request.getCoopCd(), request.getBaseDate(), request.getCoopVersion());
    // #7304 mod 異なる連携の機能を組み合わせて使用する方法 荘 2024-07-19 end
    request.setAcceptNo(acceptNo);
    // mod #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 end
    List<SysCoopJournal> journals = insertStep(request, commonSetting);

    // del 2022-11-08 bug #7113 rep_dial連携の処理タイミングがずれる 孫 start
    // // Step2:PDF場合、ジャーナル更新
    // // レポートが有り場合、データを更新する
    // if (isReportUpdate) {
    // // sys_coop_journalのDumpの更新
//      List<SysCoopJournal> updateJournals = updateSysCoopJournalListForDump(request, journals);
    // journals.clear();
    // journals.addAll(updateJournals);
    // }
    // del 2022-11-08 bug #7113 rep_dial連携の処理タイミングがずれる 孫 end
    return journals;
  }

  /**
   * Step1:ジャーナル作成
   *
   * @param request       - {@link JournalCreateRequest}
   * @param commonSetting - {@link CommonSetting}
   * @return {@link SysCoopJournal}
   */
  @Transactional
  public List<SysCoopJournal> insertStep(JournalCreateRequest request, CommonSetting commonSetting) {
    List<CoopOrdCd> coopOrdCds = commonSetting.getCoopOrdCds();
    // add 2021-07-09 Transaction対応 孫 end

    boolean isCreateIndex = false;
    boolean isCoopTarget = false;
    boolean isGetNo = false;
    boolean isReport = false;

    // add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    List<Map<String, String>> reportTypeDef = new ArrayList<>();
    String coopVersionReq = StringUtils.isEmpty(request.getCoopVersion()) ? "" : request.getCoopVersion();
    // add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    // 電文種別の設定を取得
    for (CoopOrdCd coopOrdCd : coopOrdCds) {
      // mod 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
      // if (request.getCoopCd().equals(coopOrdCd.getOrdCd())) {
      List<String> opeCds = coopOrdCd.getOpeCds();
      // mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      if (opeCds != null && opeCds.size() != 0 && opeCds.contains(request.getOpeCd())) {
      String coopVersionDef = StringUtils.isEmpty(coopOrdCd.getCoopVersion()) ? "" : coopOrdCd.getCoopVersion();
      if (opeCds != null && opeCds.size() != 0 && opeCds.contains(request.getOpeCd())
          && coopVersionDef.equals(coopVersionReq)) {
        if (coopOrdCd.getReportType() != null) {
          reportTypeDef = coopOrdCd.getReportType();
        }
        // mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        // mod 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end
        isCreateIndex = (coopOrdCd.isCreateIndex() && JournalConvertConstants.DIRECTION_SEND.equals(request.getDirection()));
        isCoopTarget = true;
        isGetNo = coopOrdCd.isGetNo();
        isReport = coopOrdCd.isReport();
        break;
      }
    }

    if (!isCoopTarget) {
      throw new NotExistException("連携対象の電文種別ではありません。");
    }

    // 送受信の向きが送信(S)の場合
    if (JournalConvertConstants.DIRECTION_SEND.equals(request.getDirection())) {
      // request.hosp_pat_idが設定されていない場合、request.pat_idをもとに取得
      if (StringUtils.isEmpty(request.getHospPatId()) && request.getPatId() != null) {
        // 患者基本情報の取得
        PatPersonalMain ppm = getPatPersonalMain(request.getFacilityCd(), request.getPatId());
        request.setHospPatId(ppm.getHosp_pat_id());
      }
    }

    List<SysCoopJournal> journals = new ArrayList<>();
    // request.coop_cd_indexが設定されていない、かつレポート対象である場合
    if (StringUtils.isEmpty(request.getCoopCdIndex()) && isReport) {

      // mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
      // if (commonSetting.getReportType() == null) {
      // String error = "レポート設定の定義が設定されていません。";
      // outputErrorLog(request.getFacilityCd(), error);
      // throw new NtssException(error);
      // }

      // レポートの場合、レポート設定が無しの場合
      if (reportTypeDef == null || (reportTypeDef != null && reportTypeDef.size() == 0)) {
        String error = String.format("操作番号=%s、電文種別=%s、連携版番号=%s。レポート設定の定義が設定されていません。",
            request.getOpeCd(), request.getCoopCd(), request.getCoopVersion());
        // add 2023-02-17 bug #8361 SSI連携の連携設定にGX連携・NKKK連携で追加された設定が横展開されていない 孫 start
        outputErrorLog(request.getFacilityCd(), error);
        throw new NtssException(error);
        // add 2023-02-17 bug #8361 SSI連携の連携設定にGX連携・NKKK連携で追加された設定が横展開されていない 孫 end
        // del 2023-02-17 bug #8361 SSI連携の連携設定にGX連携・NKKK連携で追加された設定が横展開されていない 孫 start
        // // デフォルトト設定が有りか
        // reportTypeDef = commonSetting.getReportType();
//        if (reportTypeDef == null || (reportTypeDef != null && reportTypeDef.size() == 0)) {
//          error = String.format("操作番号=%s、電文種別=%s、連携版番号=%s。レポート設定の定義が設定されていません。デフォルトトレポート設定の定義が設定されていません。",
        // request.getOpeCd(), request.getCoopCd(), request.getCoopVersion());
        // outputErrorLog(request.getFacilityCd(), error);
        // throw new NtssException(error);
        // }
        // del 2023-02-17 bug #8361 SSI連携の連携設定にGX連携・NKKK連携で追加された設定が横展開されていない 孫 end
      }
      // mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

      // report_typeから作成定義を取得する
      String type = null;
      // mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      Iterator<Map<String, String>> iterator = commonSetting.getReportType().iterator();
      Iterator<Map<String, String>> iterator = reportTypeDef.iterator();
      // mod 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      JournalCreateRequest jcr = new JournalCreateRequest();
      while (iterator.hasNext()) {
        List<SysCoopJournal> insertjournal = new ArrayList<>();
        Map<String, String> reportTypeMap = iterator.next();
        ReportPath dump = null;
        boolean isInsert = true;
        // add 2021-04-21 外部連携:レポートが有り場合、データ作成の変更 孫 start
        boolean isUpdate = true;
        // add 2021-04-21 外部連携:レポートが有り場合、データ作成の変更 孫 end
        // report_typeを電文種別で取得
        if (reportTypeMap.containsKey(request.getCoopCd())) {
          type = reportTypeMap.get(request.getCoopCd());
          // リクエストを複製
          BeanUtils.copyProperties(request, jcr);

          ReportType reportType = ReportType.getReportType(type);
          switch (reportType) {
            case TAR:
              // coop_cd_indexにtarを設定
              jcr.setCoopCdIndex(ReportType.TAR.getType());
              // del 2021-04-21 外部連携:レポートが有り場合、データ作成の変更 孫 start
              // // レポートを作成
              // dump = createReport(jcr);
              // del 2021-04-21 外部連携:レポートが有り場合、データ作成の変更 孫 end
              break;
            case XML:
              // coop_cd_indexにxmlを設定
              jcr.setCoopCdIndex(ReportType.XML.getType());
              // add 2021-04-21 外部連携:レポートが有り場合、データ作成の変更 孫 start
              isUpdate = false;
              // add 2021-04-21 外部連携:レポートが有り場合、データ作成の変更 孫 end
              break;
            case PDF:
              // coop_cd_indexにpdfを設定
              jcr.setCoopCdIndex(ReportType.PDF.getType());
              // del 2021-04-21 外部連携:レポートが有り場合、データ作成の変更 孫 start
              // // レポートを作成
              // dump = createReport(jcr);
              // del 2021-04-21 外部連携:レポートが有り場合、データ作成の変更 孫 end
              break;
            case XML_PDF:
              // add 2022-10-19 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
            case NKK_REP:
              // add 2022-10-19 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
              // xmlとpdfの３レコードを作成
              insertjournal = insertSysCoopJournalXmlPdf(jcr, isGetNo, isCreateIndex, reportType);
              journals.addAll(insertjournal);
              isInsert = false;
              break;
            case PDF_XML:
              // add 2022-10-19 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
            case NEC_REP:
              // add 2022-10-19 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
              // xmlとpdfの２レコードを作成
              insertjournal = insertSysCoopJournalXmlPdf(jcr, isGetNo, isCreateIndex, reportType);
              journals.addAll(insertjournal);
              isInsert = false;
              break;
            // add 2022-10-19 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
            case YOBI1:
            case YOBI2:
            case YOBI3:
            case YOBI4:
            case YOBI5:
            case YOBI6:
            case YOBI7:
            case YOBI8:
            case YOBI9:
              // coop_cd_indexにyobi1～yobi9を設定
              jcr.setCoopCdIndex(type);
              break;
            // add 2022-10-19 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
            default:
              break;
          }
        }
        // 既に登録されている場合はここで登録しない
        if (isInsert) {
          // sys_coop_journalの登録
          insertjournal = insertSysCoopJournalList(jcr, dump, isGetNo, isCreateIndex);
          journals.addAll(insertjournal);
        }
        // mod 2021-07-09 Transaction対応 孫 start
        // // add 2021-04-21 外部連携:レポートが有り場合、データ作成の変更 孫 start
        // // レポートが有り場合、データを更新する
        // if (isUpdate) {
        // // sys_coop_journalのDumpの更新
//          List<SysCoopJournal> updateJournals = updateSysCoopJournalListForDump(jcr, journals);
        // journals.clear();
        // journals.addAll(updateJournals);
        // }
        // // add 2021-04-21 外部連携:レポートが有り場合、データ作成の変更 孫 end
        /* del by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
        // if (isUpdate) {
        //   isReportUpdate = true;
        // }
        /* del by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
        // mod 2021-07-09 Transaction対応 孫 end
      }
      // add 2021-03-30 課題No.37:オーダ番号につてい 孫 start
    } else if (JournalConvertConstants.DIRECTION_SEND.equals(request.getDirection())
        && ("exam_ord".equals(request.getCoopCd())
            // TODO:心電図検査オーダは未来の予定実現機能、未実現
            || "phy_ord".equals(request.getCoopCd())
            || "rad_ord".equals(request.getCoopCd()))
        && (request.getOrdNo() == null || request.getOrdNo() == 0L)) {
      // 検査オーダ(exam_ord),放射線検査オーダ(rad_ord),心電図検査オーダ(phy_ord)の送信処理、
      // オーダ番号が無し場合、検査結果より、レコードデータを作成する

      // ①(ord_no ：exam_main_cd、rad_result_cd)オーダ番号を取得する
      // オーダ番号
      Long ordNoOld = null;
      String message = "";
      // add #7154 exam_ord連携のord_noが正しくsys_coop_journalに登録されない 20220818 zhaoqi start
      String regOrderClass = request.getRegOrderClass();
      // add #7154 exam_ord連携のord_noが正しくsys_coop_journalに登録されない 20220818 zhaoqi end
      // 日時(YYYY-MM-DD)
      String baseDataFormat = DateUtil.convertDateToStringFormat(request.getBaseDate());
      //add 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 start
      // mod 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない zhaoqi 20221226 start
      List<PatExamMainForAllOtherInfo> ordNoList = new LinkedList<>();
      // mod 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない zhaoqi 20221226 end
      //add 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 end
      if ("exam_ord".equals(request.getCoopCd())) {
        //add 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 start
        if ("0".equals(regOrderClass)) {
          if ("D".equals(request.getCrud())) {
            //mod 8393 exam_ord連携 検査依頼一覧画面でその他区分の検査をオーダすると登録検査依頼数以上の連携イベント数が登録される zhaoqi 20230221 start
            // mod 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない zhaoqi 20221226 start
            List<PatExamMainForAllOtherInfo> patExamMainHstList = patExamMainHstDao.selectForALlOtherInfo(request.getPatId(), request.getFacilityCd(), request.getBaseDate());
            // mod 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない zhaoqi 20221226 end
            //mod 8393 exam_ord連携 検査依頼一覧画面でその他区分の検査をオーダすると登録検査依頼数以上の連携イベント数が登録される zhaoqi 20230221 end
            if (patExamMainHstList != null && patExamMainHstList.size() > 0) {
              // システムで管理する一意な検査結果ID
              for (int i = 0; i < patExamMainHstList.size(); i++) {
                ordNoList.add(patExamMainHstList.get(i));
              }
            }
          } else {
            request.setCrud("C");
            //mod 8393 exam_ord連携 検査依頼一覧画面でその他区分の検査をオーダすると登録検査依頼数以上の連携イベント数が登録される zhaoqi 20230221 start
            // mod 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない zhaoqi 20221226 start
            List<PatExamMainForAllOtherInfo> patExamMainList = patExamMainDao.selectForALlOtherInfo(request.getPatId(), request.getFacilityCd(), request.getBaseDate());
            // mod 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない zhaoqi 20221226 end
            //mod 8393 exam_ord連携 検査依頼一覧画面でその他区分の検査をオーダすると登録検査依頼数以上の連携イベント数が登録される zhaoqi 20230221 end

            if (patExamMainList != null && patExamMainList.size() > 0) {
              // システムで管理する一意な検査結果ID
              for (int i = 0; i < patExamMainList.size(); i++) {
                ordNoList.add(patExamMainList.get(i));
              }
            }
          }
        } else {
          //add 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 end
          // 検査オーダ(exam_ord)
          if ("D".equals(request.getCrud())) {
            // add #7154 exam_ord連携のord_noが正しくsys_coop_journalに登録されない 20220818 zhaoqi start
            PatExamMainHst patExamMainHst = patExamMainHstDao.selectByPatIdAndRegRadDateAndFacilityCdForNew(
                request.getPatId(), baseDataFormat, request.getFacilityCd(), regOrderClass);
            // add #7154 exam_ord連携のord_noが正しくsys_coop_journalに登録されない 20220818 zhaoqi end
            if (patExamMainHst != null) {
              // システムで管理する一意な検査結果ID
              ordNoOld = patExamMainHst.getExamMainCd();
            }
          } else {
            // add #7154 exam_ord連携のord_noが正しくsys_coop_journalに登録されない 20220818 start
            PatExamMain patExamMain = patExamMainDao.selectByPatIdAndRegRadDateAndFacilityCdForNew(
                request.getPatId(), baseDataFormat, request.getFacilityCd(), regOrderClass);
            // add #7154 exam_ord連携のord_noが正しくsys_coop_journalに登録されない 20220818 end
            if (patExamMain != null) {
              // システムで管理する一意な検査結果ID
              ordNoOld = patExamMain.getExamMainCd();
            }
          }
          //add 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 start
        }
        //add 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 end
        message = "対象ジャーナルの送信用データが存在しません。[検査オーダ(exam_ord)]";
      } else if ("phy_ord".equals(request.getCoopCd())) {
        //add 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 start
        if ("0".equals(regOrderClass)) {
          if ("D".equals(request.getCrud())) {
            //mod 8393 exam_ord連携 検査依頼一覧画面でその他区分の検査をオーダすると登録検査依頼数以上の連携イベント数が登録される zhaoqi 20230221 start
            // mod 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない zhaoqi 20221226 start
            List<PatExamMainForAllOtherInfo> patExamMainHstList = patExamMainHstDao.selectForALlOtherInfophy(request.getPatId(), request.getFacilityCd(), request.getBaseDate());
            // mod 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない zhaoqi 20221226 end
            //mod 8393 exam_ord連携 検査依頼一覧画面でその他区分の検査をオーダすると登録検査依頼数以上の連携イベント数が登録される zhaoqi 20230221 end
            if (patExamMainHstList != null && patExamMainHstList.size() > 0) {
              // システムで管理する一意な検査結果ID
              for (int i = 0; i < patExamMainHstList.size(); i++) {
                ordNoList.add(patExamMainHstList.get(i));
              }
            }
          } else {
            request.setCrud("C");
            //mod 8393 exam_ord連携 検査依頼一覧画面でその他区分の検査をオーダすると登録検査依頼数以上の連携イベント数が登録される zhaoqi 20230221 start
            // mod 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない zhaoqi 20221226 start
            List<PatExamMainForAllOtherInfo> patExamMainList = patExamMainDao.selectForALlOtherInfophy(request.getPatId(), request.getFacilityCd(), request.getBaseDate());
            // mod 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない zhaoqi 20221226 end
            //mod 8393 exam_ord連携 検査依頼一覧画面でその他区分の検査をオーダすると登録検査依頼数以上の連携イベント数が登録される zhaoqi 20230221 end
            if (patExamMainList != null && patExamMainList.size() > 0) {
              // システムで管理する一意な検査結果ID
              for (int i = 0; i < patExamMainList.size(); i++) {
                ordNoList.add(patExamMainList.get(i));
              }
            }
          }
        } else {
          //add 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 end
          // 検査オーダ(exam_ord)
          if ("D".equals(request.getCrud())) {
            // add #7154 exam_ord連携のord_noが正しくsys_coop_journalに登録されない 20220818 zhaoqi start
            PatExamMainHst patExamMainHst = patExamMainHstDao.selectByPatIdAndRegRadDateAndFacilityCdForNewphy(
                request.getPatId(), baseDataFormat, request.getFacilityCd(), regOrderClass);
            // add #7154 exam_ord連携のord_noが正しくsys_coop_journalに登録されない 20220818 zhaoqi end
            if (patExamMainHst != null) {
              // システムで管理する一意な検査結果ID
              ordNoOld = patExamMainHst.getExamMainCd();
            }
          } else {
            // add #7154 exam_ord連携のord_noが正しくsys_coop_journalに登録されない 20220818 start
            PatExamMain patExamMain = patExamMainDao.selectByPatIdAndRegRadDateAndFacilityCdForNewphy(
                request.getPatId(), baseDataFormat, request.getFacilityCd(), regOrderClass);
            // add #7154 exam_ord連携のord_noが正しくsys_coop_journalに登録されない 20220818 end
            if (patExamMain != null) {
              // システムで管理する一意な検査結果ID
              ordNoOld = patExamMain.getExamMainCd();
            }
          }
          //add 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 start
        }
        //add 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 end
        message = "対象ジャーナルの送信用データが存在しません。[検査オーダ(phy_ord)]";
      } else if ("rad_ord".equals(request.getCoopCd())) {
        // 放射線検査オーダ(rad_ord)
        if ("D".equals(request.getCrud())) {
          PatRadMainHst patRadMainHst = patRadMainHstDao.selectByPatIdAndRegRadDateAndFacilityCdForNew(
              request.getPatId(), baseDataFormat, request.getFacilityCd());
          if (patRadMainHst != null) {
            // システムで管理する一意な検査結果ID
            ordNoOld = patRadMainHst.getRadResultCd();
          }
        } else {
          PatRadMain patRadMain = patRadMainDao.selectByPatIdAndRegRadDateAndFacilityCdForNew(
              request.getPatId(), baseDataFormat, request.getFacilityCd());
          if (patRadMain != null) {
            // システムで管理する一意な検査結果ID
            ordNoOld = patRadMain.getRadResultCd();
          }
        }
        message = "対象ジャーナルの送信用データが存在しません。[放射線検査オーダ(rad_ord)]";
      }
      // オーダ番号が無し場合
      //add 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 start
      if (("exam_ord".equals(request.getCoopCd()) || "phy_ord".equals(request.getCoopCd())) && "0".equals(regOrderClass)) {
        if (ordNoList == null) {
          request.setAnaResult(AnaResult.INTERNAL_ERROR.getResult());
          request.setMessage(message);
        }
      } else {
        //add 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 end
        if (ordNoOld == null) {
          request.setAnaResult(AnaResult.INTERNAL_ERROR.getResult());
          request.setMessage(message);
        } else {
          // ②オーダ番号Listより、sys_coop_journalを登録する
          // ord_noを設定する
          request.setOrdNo(ordNoOld);
        }
        //add 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 start
      }
      //add 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 end


      // ③sys_coop_journalの登録
      //add 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 start
      if (("exam_ord".equals(request.getCoopCd()) || "phy_ord".equals(request.getCoopCd())) && "0".equals(regOrderClass)) {
        if (ordNoList != null && ordNoList.size() > 0) {
          for (int n = 0; n < ordNoList.size(); n++) {
            // add 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない zhaoqi 20221226 start
            Long ordNo = ordNoList.get(n).getOrdNo();
            String baseDate = ordNoList.get(n).getBaseDate();
            request.setOrdNo(ordNo);
            request.setBaseDate(baseDate);
            // add 8208 検査依頼一覧で検査予定を作成した際のjournal登録が正しく行われない zhaoqi 20221226 end
            journals = insertSysCoopJournalList(request, null, isGetNo, isCreateIndex);
          }
        } else {
          journals = insertSysCoopJournalList(request, null, isGetNo, isCreateIndex);
        }
      } else {
        journals = insertSysCoopJournalList(request, null, isGetNo, isCreateIndex);
      }
      //add 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 end
      //del 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 start
      // journals = insertSysCoopJournalList(request, null, isGetNo, isCreateIndex);
      //del 7322 7154 7036 そのたは個別オーダ番号が使用されること（開始時刻が同じになるとは限らないため別オーダ） zhaoqi 20221021 end
      // add 2021-03-30 課題No.37:オーダ番号につてい 孫 end
      // add 2021-03-19 外部連携：定時一括送信機能の複数データの対応。 孫 start
    } else if (JournalConvertConstants.DIRECTION_SEND.equals(request.getDirection())
        && JournalConvertConstants.COOP_CD_INDEX_SEND_TIME.equals(request.getCoopCdIndex())) {
      // 外部連携の定時一括送信場合、複数レコードを作成

      // ①ジャーナルから変換したいレイアウトを取得する
      // mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 start
      //// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
////      MstCoopLayout layout = mstCoopLayoutDao.select(request.getFacilityCd(), request.getCoopCd(),
      //// request.getCoopCdIndex(), JournalConvertConstants.DIRECTION_SEND,
      //// convertSendCommonService.getCoopCdSub(request.getCrud()));
//      MstCoopLayout layout = mstCoopLayoutDao.select(request.getFacilityCd(), request.getCoopCd(),
//        request.getCoopCdIndex(), coopVersionReq, JournalConvertConstants.DIRECTION_SEND,
      // convertSendCommonService.getCoopCdSub(request.getCrud()));
      //// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      //
      // // レイアウトがない場合はジャーナルをエラー
      // if (layout == null) throw new NtssException("対象ジャーナルの送信用変換レイアウトが存在しません。 "
      // + "facility_cd:[" + request.getFacilityCd() + "], "
      // + "coop_cd:[" + request.getCoopCd() + "], "
      //// add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
      // + "coop_version:[" + coopVersionReq + "], "
      //// add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      // + "coop_cd_index:[" + request.getCoopCdIndex() + "], "
//        + "coop_cd_sub:[" + convertSendCommonService.getCoopCdSub(request.getCrud()) + "]");
      MstCoopLayout layout = convertCommonService.getMstCoopLayoutBySub(request.getFacilityCd(),
          JournalConvertConstants.DIRECTION_SEND, request.getCoopCd(), request.getCoopCdIndex(),
          coopVersionReq, convertSendCommonService.getCoopCdSub(request.getCrud()));
      // mod 2023-03-20 bug #8422 有効なレイアウトが複数存在したときのメッセージ不備 孫 end

      // 事前処理用項目がありか
      boolean preSqlInfoItemExists = false;
      String sqlCode = "";
      // 拡張設定がなかったり、datasetのプロパティがない場合は空で返却する
      // (拡張設定はdataset情報以外も入る可能性があるので、datasetのキーがあるかをあらかじめ確認する必要がある)
      LayoutExtSetting layoutExtSetting = layout.getCoopExtSetting();
      // add 2021-09-14 #5897:CSI連携ができないの対応 孫 start
      // 拡張設定が無しの場合
      if (layoutExtSetting == null || layoutExtSetting.size() == 0) {
        // coop_cd_indexを再設定する
        request.setCoopCdIndex("");
        // ④sys_coop_journalの登録
        journals = insertSysCoopJournalList(request, null, isGetNo, isCreateIndex);
      } else {
        // 拡張設定が有りの場合
        // add 2021-09-14 #5897:CSI連携ができないの対応 孫 end
        if (layoutExtSetting != null && layoutExtSetting.containsKey("dataset")) {
          for (Map.Entry<String, Object> keyValue : layoutExtSetting.entrySet()) {
            // dataset情報がありか
            if ("dataset".equals(keyValue.getKey())) {
              List<Map<String, Object>> dataSetList = cast(keyValue.getValue());
              for (Map<String, Object> dataSetMap : dataSetList) {
                if (dataSetMap.containsKey(ReportConstant.PreSqlInfoItem)) {
                  // 事前処理用項目があり
                  preSqlInfoItemExists = true;

                  sqlCode = String.valueOf(dataSetMap.get("sqlCode"));
                  break;
                }
              }
              break;
            }
          }
        }

        // 事前処理用項目が無し場合
        if (!preSqlInfoItemExists) {
          throw new NtssException("対象ジャーナルの送信用変換レイアウトの[" + ReportConstant.PreSqlInfoItem + "]存在しません。"
              + "facility_cd:[" + request.getFacilityCd() + "], "
              + "coop_cd:[" + request.getCoopCd() + "], "
              // add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
              + "coop_version:[" + coopVersionReq + "], "
              // add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
              + "coop_cd_index:[" + request.getCoopCdIndex() + "], "
              + "coop_cd_sub:[" + convertSendCommonService.getCoopCdSub(request.getCrud()) + "]");
        }

        // 事前処理用項目がありの場合
        // ②data-setを利用した出力がある場合に限り、あらかじめdata-setをリクエストしておく
        SysCoopJournal journal = new SysCoopJournal();
        journal.setFacilityCd(request.getFacilityCd());
        journal.setOrdNo(request.getOrdNo());
        journal.setHospPatId(request.getHospPatId());
        journal.setPatId(request.getPatId());
        /* upd by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
        List<MstCoopIni> coopIniList = convertCommonService.getMstCoopIniByFacilityCd(request.getFacilityCd());
        MstCoopIni coopIni = CollectionUtils.isEmpty(coopIniList) ? null : coopIniList.get(0);

        Map<String, List<Map<String, Object>>> dataSetResultMap
          = convertSendCommonService.createRequestAndRequestByDataSetApi(journal, layout.getCoopExtSetting(), null, coopIni);
        /* upd by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
        if (dataSetResultMap == null || dataSetResultMap.isEmpty() || !dataSetResultMap.containsKey(sqlCode)) {
          throw new NtssException("sqlCode[" + sqlCode + "]より対象ジャーナルの送信用データが存在しません。"
              + "facility_cd:[" + request.getFacilityCd() + "], "
              + "coop_cd:[" + request.getCoopCd() + "], "
              // add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
              + "coop_version:[" + coopVersionReq + "], "
              // add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
              + "coop_cd_index:[" + request.getCoopCdIndex() + "], "
              + "coop_cd_sub:[" + convertSendCommonService.getCoopCdSub(request.getCrud()) + "]");
        }

        // ③data-setで取得したデータより、sys_coop_journalを登録する
        // coop_cd_indexを再設定する
        request.setCoopCdIndex("");

        List<Map<String, Object>> resultMap = dataSetResultMap.get(sqlCode);
        int ordnoCnt = 0;
        int hosppatidCnt = 0;
        int patidCnt = 0;
        for (int i = 0; i < resultMap.size(); i++) {
          Map<String, Object> tmpDataMap = resultMap.get(i);
          Set<String> keySet = tmpDataMap.keySet();
          for (String key : keySet) {
            String compKey = key.toLowerCase().replace("_", "").replace("@", "");

            if ("ordno".equals(compKey)) {
              // ord_noを再設定する
              request.setOrdNo((Long) tmpDataMap.get(key));
              ordnoCnt++;
            } else if ("hosppatid".equals(compKey)) {
              // hosp_pat_idを再設定する
              request.setHospPatId((String) tmpDataMap.get(key));
              hosppatidCnt++;
            } else if ("patid".equals(compKey)) {
              // pat_idを再設定する
              request.setPatId((Long) tmpDataMap.get(key));
              patidCnt++;
            }
          }

          if (ordnoCnt != hosppatidCnt || ordnoCnt != patidCnt) {
            throw new NtssException("sqlCode[" + sqlCode + "]の項目名[ord_no,hosp_pat_id,pat_id]はSNAKE_LOWER_CASEの変換。");
          }

          // add FNSI7446-profile連携 (定時一括送信)が複数回行われる 周 start
          if ("031001".equals(request.getOpeCd())) {
            boolean isSamePat = false;
            for (SysCoopJournal jnl : journals) {
              if (jnl.getPatId().equals(request.getPatId())) {
                isSamePat = true;
                break;
              }
            }
            if (isSamePat) {
              continue;
            }
          }
          // add FNSI7446-profile連携 (定時一括送信)が複数回行われる 周 end

          // ④sys_coop_journalの登録
          List<SysCoopJournal> journalsTime = new ArrayList<>();
          journalsTime = insertSysCoopJournalList(request, null, isGetNo, isCreateIndex);
          if (journalsTime.size() > 0) {
            journals.addAll(journalsTime);
          }
        }

        if ((ordnoCnt == 0 || hosppatidCnt == 0 || patidCnt == 0)) {
          return journals;
        }
        // add 2021-03-19 外部連携：定時一括送信機能の複数データの対応。 孫 end
        // add 2021-09-14 #5897:CSI連携ができないの対応 孫 start
      }
      // add 2021-09-14 #5897:CSI連携ができないの対応 孫 end
      //del #10553 連携イベント発生部分不正【最優先】 ⑩処方の追加、変更、削除、処方一覧＞一括交付、処方一覧＞一括コピーにて連携イベントを発生させること。 zrx start
      // // #8102-GX連携で実装されていない機能（処方情報連携） 周 add start
      // } else if (Key0Constant.GX.equals(request.getKey0())
      // && JournalConvertConstants.DIRECTION_SEND.equals(request.getDirection())
      // && CoopCdConstant.PRE_ORD.equals(request.getCoopCd())) {
//      MstCoopLayout layout = mstCoopLayoutDao.select(request.getFacilityCd(), request.getCoopCd(),
//        request.getCoopCdIndex(), coopVersionReq, JournalConvertConstants.DIRECTION_SEND,
      // convertSendCommonService.getCoopCdSub(request.getCrud()));
      // // レイアウトがない場合はジャーナルをエラー
      // if (layout == null) {
      // throw new NtssException("対象ジャーナルの送信用変換レイアウトが存在しません。 "
      // + "facility_cd:[" + request.getFacilityCd() + "], "
      // + "coop_cd:[" + request.getCoopCd() + "], "
      // + "coop_version:[" + coopVersionReq + "], "
      // + "coop_cd_index:[" + request.getCoopCdIndex() + "], "
//          + "coop_cd_sub:[" + convertSendCommonService.getCoopCdSub(request.getCrud()) + "]");
      // }
      //
      // List<Long> patIdList = new ArrayList<>();
      // List<String> facilityCdList = new ArrayList<>();
      // facilityCdList.add(request.getFacilityCd());
      //
//      if (null != request.getPatId() && !StringUtils.isEmpty(request.getBaseDate())) {
      // patIdList.add(request.getPatId());
      //
//        List<SysCoopJournal> tempJournals = createJournalsForOnePat(request.getPatId(), request.getBaseDate(),
      // layout, isGetNo, isCreateIndex, request);
      // journals.addAll(tempJournals);
      // } else {
//        MstCoopIniInfo mstCoopIniInfo = mstCoopIniDao.selectCoopIniInfo(request.getFacilityCd(),
      // request.getKey0(), "FJI_PRESCRIPT", "SEARCH_TERM");
      // if(null == mstCoopIniInfo) {
      // throw new NtssException("検索日数の連携設定が不正。");
      // }
      // int searchTerm;
      // try{
      // searchTerm = Integer.parseInt(mstCoopIniInfo.getVal());
      // if(searchTerm <= 0) {
      // throw new NtssException("検索日数の値が不正。 [" + searchTerm + "]");
      // }
      // } catch (Exception ex) {
      // throw new NtssException("検索日数の値が不正。 " + ex.getMessage());
      // }
      //
//        List <PatPersonalMain> patPersonalMainList = patPersonalMainDao.selectAll(facilityCdList);
      // if (CollectionUtils.isEmpty(patPersonalMainList)) {
      // return journals;
      // }
      //
      // for(PatPersonalMain ppmItem : patPersonalMainList) {
//          if (!"1".equals(ppmItem.getIs_die()) && !patIdList.contains(ppmItem.getPat_id())) {
      // patIdList.add(ppmItem.getPat_id());
      // }
      // }
      //
      // List <Long> preOrdPatIdList = new ArrayList<>();
      //
//        List<PatMain> patMainList = patMainDao.selectByIdListFacilityCd(patIdList, request.getFacilityCd());
      // if (CollectionUtils.isEmpty(patMainList)) {
      // return journals;
      // }
      // patMainList = patMainList.stream().filter(e ->
      // !PatInfoConstant.InOutVisitHistoryInfo.DEATH.equals(e.getIn_out_current_state())
//            && !PatInfoConstant.InOutVisitHistoryInfo.MOVING_OUT.equals(e.getIn_out_current_state())
//            && !PatInfoConstant.InOutVisitHistoryInfo.WITHDRAWAL.equals(e.getIn_out_current_state())
//            && !PatInfoConstant.InOutVisitHistoryInfo.IMPLANTATION.equals(e.getIn_out_current_state()))
      // .collect(Collectors.toList());
      //
      // if (CollectionUtils.isEmpty(patMainList)) {
      // return journals;
      // }
      // patMainList.forEach(e -> preOrdPatIdList.add(e.getPat_id()));
      //
//        List<OrdPrescription> filterOPList = ordPrescriptionDao.selectCoopedPrescriptions(request.getFacilityCd());
      //
      // SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
      // for(int dayDiff = 1; dayDiff <= searchTerm; dayDiff++) {
      // Calendar nowDate = Calendar.getInstance();
      // nowDate.add(Calendar.DAY_OF_YEAR, -dayDiff);
      // Date dt = nowDate.getTime();
      // String baseDate = sdf.format(dt);
      //
      // if (!CollectionUtils.isEmpty(filterOPList)) {
      // JournalCreateRequest onePatRequest = new JournalCreateRequest();
      // for(Long patId : preOrdPatIdList) {
      // BeanUtils.copyProperties(request, onePatRequest);
      //
      // for(OrdPrescription ordPre: filterOPList) {
//                if(ordPre.getIssueDate().equals(baseDate) && ordPre.getPatId().equals(patId)) {
      // onePatRequest.setAnaResult(AnaResult.SKIP.getResult());
      // onePatRequest.setCoopResult(CoopResult.SKIP.getResult());
      // onePatRequest.setMessage("既に連携ずみのため");
      // break;
      // }
      // }
      //
      // // 事前処理用項目がありか
//              List<SysCoopJournal> tempJournals = createJournalsForOnePat(patId, baseDate, layout, isGetNo,
      // isCreateIndex, onePatRequest);
      // journals.addAll(tempJournals);
      // }
      // } else {
      // for(Long patId : preOrdPatIdList) {
      // // 事前処理用項目がありか
//              List<SysCoopJournal> tempJournals = createJournalsForOnePat(patId, baseDate, layout, isGetNo,
      // isCreateIndex, request);
      // journals.addAll(tempJournals);
      // }
      // }
      // }
      // }
      // // #8102-GX連携で実装されていない機能（処方情報連携） 周 add end
      //del #10553 連携イベント発生部分不正【最優先】 ⑩処方の追加、変更、削除、処方一覧＞一括交付、処方一覧＞一括コピーにて連携イベントを発生させること。 zrx end
    } else {
      // sys_coop_journalの登録
      journals = insertSysCoopJournalList(request, null, isGetNo, isCreateIndex);
    }

    return journals;
  }

  // #8102-GX連携で実装されていない機能（処方情報連携） 周 add start
  private List<SysCoopJournal> createJournalsForOnePat(Long patId, String baseDate, MstCoopLayout layout,
      boolean isGetNo, boolean isCreateIndex, JournalCreateRequest request) {
    List<SysCoopJournal> journals = new ArrayList<>();
    String sqlCode = "";
    // 拡張設定がなかったり、datasetのプロパティがない場合は空で返却する
    // (拡張設定はdataset情報以外も入る可能性があるので、datasetのキーがあるかをあらかじめ確認する必要がある)
    LayoutExtSetting layoutExtSetting = new LayoutExtSetting(layout.getCoopExtSetting().getValue());

    // 拡張設定が無しの場合
    if (layoutExtSetting.size() == 0) {
      // coop_cd_indexを再設定する
      request.setCoopCdIndex("");
      // ④sys_coop_journalの登録
      List<SysCoopJournal> tempJournals = insertSysCoopJournalList(request, null, isGetNo, isCreateIndex);
      if (tempJournals.size() > 0) {
        journals.addAll(tempJournals);
      }
    } else {
      String coopVersionReq = StringUtils.isEmpty(request.getCoopVersion()) ? "" : request.getCoopVersion();
      // 拡張設定が有りの場合
      if (layoutExtSetting.containsKey("dataset")) {
        for (Map.Entry<String, Object> keyValue : layoutExtSetting.entrySet()) {
          // dataset情報がありか
          if ("dataset".equals(keyValue.getKey())) {
            List<Map<String, Object>> dataSetList = cast(keyValue.getValue());
            for (Map<String, Object> dataSetMap : dataSetList) {
              sqlCode = String.valueOf(dataSetMap.get("sqlCode"));
              break;
            }
            break;
          }
        }
      }

      // 事前処理用項目がありの場合
      // ②data-setを利用した出力がある場合に限り、あらかじめdata-setをリクエストしておく
      SysCoopJournal journal = new SysCoopJournal();
      journal.setFacilityCd(request.getFacilityCd());
      journal.setOrdNo(request.getOrdNo());
      journal.setHospPatId(request.getHospPatId());
      request.setPatId(patId);
      journal.setPatId(patId);
      request.setBaseDate(baseDate);
      // mod #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi start 名前間違い変量を削除する
      journal.setBaseDate(baseDate);
      // mod #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi end 名前間違い変量を削除する
      /* upd by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
      List<MstCoopIni> coopIniList = convertCommonService.getMstCoopIniByFacilityCd(request.getFacilityCd());
      MstCoopIni coopIni = CollectionUtils.isEmpty(coopIniList) ? null : coopIniList.get(0);

      Map<String, List<Map<String, Object>>> dataSetResultMap
        = convertSendCommonService.createRequestAndRequestByDataSetApi(journal, layoutExtSetting, null, coopIni);
      /* upd by chamaojia 2026-04-24 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */
      if (dataSetResultMap == null || dataSetResultMap.isEmpty() || !dataSetResultMap.containsKey(sqlCode)) {
        throw new NtssException("sqlCode[" + sqlCode + "]より対象ジャーナルの送信用データが存在しません。"
            + "facility_cd:[" + request.getFacilityCd() + "], "
            + "coop_cd:[" + request.getCoopCd() + "], "
            + "coop_version:[" + coopVersionReq + "], "
            + "coop_cd_index:[" + request.getCoopCdIndex() + "], "
            + "coop_cd_sub:[" + convertSendCommonService.getCoopCdSub(request.getCrud()) + "]");
      }

      // ③data-setで取得したデータより、sys_coop_journalを登録する
      // coop_cd_indexを再設定する
      request.setCoopCdIndex("");

      List<Map<String, Object>> resultMap = dataSetResultMap.get(sqlCode);
      int hosppatidCnt = 0;
      for (int i = 0; i < resultMap.size(); i++) {
        Map<String, Object> tmpDataMap = resultMap.get(i);
        Set<String> keySet = tmpDataMap.keySet();
        for (String key : keySet) {
          String compKey = key.toLowerCase().replace("_", "").replace("@", "");

          if ("hosppatid".equals(compKey)) {
            // hosp_pat_idを再設定する
            request.setHospPatId((String) tmpDataMap.get(key));
            hosppatidCnt++;
          }
        }

        // ④sys_coop_journalの登録
        List<SysCoopJournal> tempJournals = insertSysCoopJournalList(request, null, isGetNo, isCreateIndex);
        if (tempJournals.size() > 0) {
          journals.addAll(tempJournals);
        }
      }

      if (hosppatidCnt == 0) {
        throw new NtssException("sqlCode[" + sqlCode + "]より対象ジャーナルの送信用データが存在しません。"
            + "facility_cd:[" + request.getFacilityCd() + "], "
            + "coop_cd:[" + request.getCoopCd() + "], "
            // add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
            + "coop_version:[" + coopVersionReq + "], "
            // add 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
            + "coop_cd_index:[" + request.getCoopCdIndex() + "], "
            + "coop_cd_sub:[" + convertSendCommonService.getCoopCdSub(request.getCrud()) + "]");
      }
      // add 2021-03-19 外部連携：定時一括送信機能の複数データの対応。 孫 end
      // add 2021-09-14 #5897:CSI連携ができないの対応 孫 start
    }

    return journals;
  }
  // #8102-GX連携で実装されていない機能（処方情報連携） 周 add end

  // add 2021-03-23 外部連携：定時一括送信機能の複数データの対応。 孫 start

  /**
   * 未検査キャスト用メソッド
   *
   * @param target - キャスト対象
   * @return T
   */
  @SuppressWarnings("unchecked")
  private <T> T cast(Object target) {
    T castTarget = (T) target;
    return castTarget;
  }
  // add 2021-03-23 外部連携：定時一括送信機能の複数データの対応。 孫 end

  // add 2020-11-04 FNSI-改修 外部連携706 徐 start

  // del #10336 DBが高負荷になる（外部連携由来）2 start
  // /**
  // * 古いジャーナルの削除処理
  // *
  // * @param facilityCd - 施設コード
  // * @param journalKeepDays - 不要なジャナル保持日
  // */
  // @Transactional
  // public void delOldJournal(String facilityCd, Integer journalKeepDays) {
  // Calendar calendar = Calendar.getInstance();
  // calendar.setTime(new Date());
  // calendar.set(Calendar.HOUR_OF_DAY, 0);
  // calendar.set(Calendar.MINUTE, 0);
  // calendar.set(Calendar.SECOND, 0);
  // calendar.set(Calendar.MILLISECOND, 0);
  // calendar.set(Calendar.DATE, calendar.get(Calendar.DATE) - journalKeepDays);
  //
  // // 不要なジャナル保持限界日
  // Timestamp lastDate = new Timestamp(calendar.getTime().getTime());
  // sysCoopJournalDao.deleteSysCoopJournal(lastDate, facilityCd);
  //
  // }
  // // add 2020-11-04 FNSI-改修 外部連携706 徐 end
  // del #10336 DBが高負荷になる（外部連携由来）2 end

  @Transactional
  @Override
  public SysCoopJournal update(JournalUpdateRequest request) {
    SysCoopJournal journal = sysCoopJournalDao.selectByPK(request.getCtlNo());

    if (journal == null) throw new NotExistException("更新対象となるジャーナルデータが存在しません。");

    if (request.getDumpPath() != null) {
      journal.setDumpPath(request.getDumpPath());
    }
    // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 start
    if (request.getOrdNo() != null) {
      journal.setOrdNo(request.getOrdNo());
    }
    if (request.getBaseDate() != null) {
      // mod #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi start 名前間違い変量を削除する
      journal.setBaseDate(request.getBaseDate());
      // mod #10901 #10902 mst_coop_apilinkの動作について 20241004 zhaoqi end 名前間違い変量を削除する
    }
    // add 7712 富士通指摘：患者プロファイルの登録数が大量の患者の連携について 王永吉 end
    // add 2021-04-21 外部連携:レポートが有り場合、データ作成の変更 孫 start
    if (request.getReportCd() != null) {
      journal.setReportCd(request.getReportCd());
    }
    if (request.getMessage() != null) {
      journal.setMessage(request.getMessage());
    }
    // add 2021-04-21 外部連携:レポートが有り場合、データ作成の変更 孫 end

    // リクエスト上の通信もしくは配信ステータスが、開始("1")もしくは終了("9")を指定されたら
    // 開始ステータスであれば開始日時。終了ステータスであれば終了日時を入れる
    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    if (CoopResult.PROCESSING.isSameResult(request.getCoopResult()) && !journal.getCoopResult().equals(request.getCoopResult()))
      journal.setInRegDate(now);
    if (CoopResult.DONE.isSameResult(request.getCoopResult()) && !journal.getCoopResult().equals(request.getCoopResult()))
      journal.setOutRegDate(now);
    if (AnaResult.PROCESSING.isSameResult(request.getAnaResult()) && !journal.getAnaResult().equals(request.getAnaResult()))
      journal.setInAnaDate(now);
    if (AnaResult.DONE.isSameResult(request.getAnaResult()) && !journal.getAnaResult().equals(request.getAnaResult()))
      journal.setOutAnaDate(now);
    // #8551 mod 処理対象となるbackupフォルダの日付が古い 2023-06-05 卓 start
    if (CoopResult.RETRY.isSameResult(request.getCoopResult()))
      journal.setOutRegDate(now);
    // #8551 mod 処理対象となるbackupフォルダの日付が古い 2023-06-05 卓 end

    if (!StringUtils.isEmpty(request.getAnaResult())) {
      journal.setAnaResult(request.getAnaResult());
    }
    if (!StringUtils.isEmpty(request.getCoopResult())) {
      journal.setCoopResult(request.getCoopResult());
    }
    // mod 2021-09-28 #6172:ジャーナルの操作者を上書きしている 孫 start
    // journal.setUserId(request.getUserId());
    // 操作者IDが-1以外の場合、操作者IDを再設定する
    if (request.getUserId() != null && request.getUserId().longValue() != -1) {
      journal.setUserId(request.getUserId());
    }
    // mod 2021-09-28 #6172:ジャーナルの操作者を上書きしている 孫 end
    sysCoopJournalDao.update(journal);

    // #8551 mod 処理対象となるbackupフォルダの日付が古い 2023-06-05 卓 start
    this.deleteDumpFile(journal);
    // #8551 mod 処理対象となるbackupフォルダの日付が古い 2023-06-05 卓 end

    // add 2020-12-17 FNSI-改修 外部連携721(前回処理結果による処理変更) 夏 start
    // mod #7627 #7239 2023-03-14 卓 start
    if ("C".equals(String.valueOf(journal.getCrud()))) {
      if (!CoopResult.DONE.isSameResult(request.getCoopResult())) {
        List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndCoopOrdNo(journal.getFacilityCd(),
            journal.getCoopVersion(),
            journal.getPatId(),
            journal.getHospPatId(),
            journal.getCoopOrdNo());
        if (ordCoopNoList.size() == 0) {
          // coopOrderは存在しません
          JournalLogUtil.eventMessageDebug("coopOrderは存在しません", journal, this.getClass().getName(), SERVICE_NAME.FNSI);
        } else {
          // coopOrderは存在します
          OrdCoopNo ordCoopNo = ordCoopNoList.get(0);
          // D電文を取得
          List<SysCoopJournal> crudDeleteJournal = this.findSameJournalListByCrud(journal, Crud.DELETE.getResult(), true);

          // それぞれD電文とCU電文のみの場合を行い、最適化処理を行う.
          // このうち、Rep _dialの複数の処理、およびind、rst単一の処理
          if (crudDeleteJournal.size() > 0) {
            // **D電文あり
            // 同じOrdNoのjournalを検索
            List<SysCoopJournal> toSetSkipJournalList = this.filterToSetSkipJournalList(crudDeleteJournal.get(0),ordCoopNo,null);
            if (CoopCdConstant.REP_DIAL.equals(journal.getCoopCd())) {
              // rep_dial，送信に成功したC電文があるかどうかを検証する
              if (toSetSkipJournalList.stream().filter(sj -> Crud.CREATE.getResult().equals(sj.getCrud())
                  && CoopResult.DONE.getResult().equals(sj.getCoopResult())).count() == 0) {
                // 同じOrdNoのJournalはスキップに設定されています
                this.updateSkipJournalList(toSetSkipJournalList);
              }
            } else {
              // 非REP_DIALのcoopCd
              // 同じOrdNoのJournalはスキップに設定されています
              this.updateSkipJournalList(toSetSkipJournalList);
            }
          } else {
            // **D電文はなく、C電文とU電文のみ
            if (CoopCdConstant.REP_DIAL.equals(journal.getCoopCd())) {
              List<SysCoopJournal> cuJList = this.findSameJournalListRepDial(journal, Crud.UPDATE.getResult(), CoopCdConstant.REP_DIAL, journal.getCoopCdIndex(), true);
              if (cuJList.size() > 0) {
                SysCoopJournal updateJournal = cuJList.get(0);
                updateJournal.setCrud(Crud.CREATE.getResult());
                this.update(updateJournal);
              }
              List<SysCoopJournal> createRepList = this.listByCrudCoopCd(journal, Crud.CREATE.getResult(), CoopCdConstant.REP_DIAL);
              // rep_dial，送信に成功したC電文があるかどうかを検証する,
              if (0 == createRepList.stream().filter(repJ -> CoopResult.DONE.equals(repJ.getCoopResult())).count()) {
                // ...,なければstatusは0に戻る
                ordCoopNo.setStatus(OrdCoopNoConstant.Status.UNPROCESS.getResult());
                ordCoopNoDao.update(ordCoopNo);
              }
            } else {
              // 非REP_DIALのcoopCd
              // すべてのU電文を見つける
              List<SysCoopJournal> cuJList = this.findSameJournalListByCrud(journal, Crud.UPDATE.getResult(), true);
              if (cuJList.size() > 0) {
                // 最後の電文UがCになる
                SysCoopJournal updateJournal = cuJList.get(0);
                updateJournal.setCrud(Crud.CREATE.getResult());
                this.update(updateJournal);
              }
              // statusは0に戻る
              ordCoopNo.setStatus(OrdCoopNoConstant.Status.UNPROCESS.getResult());
              ordCoopNoDao.update(ordCoopNo);
            }
          }
        }
      }
      // mod #7627 #7239 2023-03-14 卓 end
    }
    // add 2020-12-17 FNSI-改修 外部連携721(前回処理結果による処理変更) 夏 end

    // add 2024-11-25 #11301 CSI連携 rst_dial 酸素吸入の出力が常に新規となる start
    if (!"D".equals(String.valueOf(journal.getCrud()))) {
      if (CoopResult.DONE.isSameResult(request.getCoopResult())) {
        // 連携オーダ番号を記録する
        if (request.getCoopOrdNo() != null) {
          List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndOrdNoAndCoopCd(journal.getFacilityCd(), journal.getPatId(), journal.getHospPatId(), journal.getOrdNo(), journal.getCoopCd(), journal.getCoopVersion());

          if (ordCoopNoList.size() != 0) {
            OrdCoopNo ordCoopNo = ordCoopNoList.get(0);
            ordCoopNo.setCoopOrdNo(request.getCoopOrdNo());
            ordCoopNoDao.update(ordCoopNo);
          }
        }
      }
    }
    // add 2024-11-25 #11301 CSI連携 rst_dial 酸素吸入の出力が常に新規となる end

    // add 2021-04-02 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 start
    // 事後APIキック機能を呼び出し
    if ((!StringUtils.isEmpty(request.getAnaResult())
        && (AnaResult.DONE.getResult().equals(request.getAnaResult())
            || AnaResult.SKIP.getResult().equals(request.getAnaResult())
            || AnaResult.INTERNAL_ERROR.getResult().equals(request.getAnaResult())
            || AnaResult.INTERNAL_ERROR_BY_CARTE.getResult().equals(request.getAnaResult())))
        || (!StringUtils.isEmpty(request.getCoopResult())
            && (CoopResult.DONE.getResult().equals(request.getCoopResult())
                || CoopResult.SKIP.getResult().equals(request.getCoopResult())
                || CoopResult.INTERNAL_ERROR_BY_NTSS.getResult().equals(request.getCoopResult())
                || CoopResult.INTERNAL_ERROR_BY_CARTE.getResult().equals(request.getCoopResult())))) {

      CallApiJournalRequest callApiJournalRequest = new CallApiJournalRequest();
      BeanUtils.copyProperties(journal, callApiJournalRequest);
      // mod 2021-06-09 #5278 API連動処理の判定が正しくない wangchen start
      if (AnaResult.DONE.getResult().equals(request.getAnaResult())) {
        callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.ANA_DONE.getStatus());
      } else if (CoopResult.DONE.getResult().equals(request.getCoopResult())) {
        callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.COOP_DONE.getStatus());
      } else if (AnaResult.SKIP.getResult().equals(request.getAnaResult())) {
        callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.ANA_SKIP.getStatus());
      } else if (CoopResult.SKIP.getResult().equals(request.getCoopResult())) {
        callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.COOP_SKIP.getStatus());
      } else if (AnaResult.INTERNAL_ERROR.getResult().equals(request.getAnaResult())
          || AnaResult.INTERNAL_ERROR_BY_CARTE.getResult().equals(request.getAnaResult())) {
        callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.ANA_ERROR.getStatus());
      } else if (CoopResult.INTERNAL_ERROR_BY_NTSS.getResult().equals(request.getCoopResult())
          || CoopResult.INTERNAL_ERROR_BY_CARTE.getResult().equals(request.getCoopResult())) {
        callApiJournalRequest.setApiTimingIo(NtssCoopApiConstants.ApiTimingIoStatus.COOP_ERROR.getStatus());
      }
      // mod 2021-06-09 #5278 API連動処理の判定が正しくない wangchen end
      callApiJournalRequest.setApiTimingBa(NtssCoopApiConstants.ApiTimingBaStatus.AFTER.getStatus());
      boolean callResult = callApiService.callApiJournal(callApiJournalRequest, journal, null);
      // if (!callResult) {
      // break;
      // }
    }
    // add 2021-04-02 課題No.1:API連動設定:動作条件「処理完了時、処理エラー時、処理スキップ時」を追加 孫 end

    return journal;
  }

  // #8551 mod 処理対象となるbackupフォルダの日付が古い 2023-06-05 卓 start
  public void deleteDumpFile(SysCoopJournal journal) {
    // 配信処理(/journal/delivery)後の後続処理 (処理が正常終了していたら処理対象ファイルを削除する)
    if (CoopResult.DONE.isSameResult(journal.getCoopResult()) && journal.getDumpPath() != null) {

      // 配信ファイル一時保存フォルダを取得
      String deliveryJournalTmp = fileUtil.getDistFolderPath();
      Path deliveryJournalTmpPath = Paths.get(deliveryJournalTmp);
      if (Files.exists(deliveryJournalTmpPath)) {
        String ctlNo = journal.getCtlNo() + "_";
        FilenameFilter filter = new FilenameFilter() {
          public boolean accept(File file, String str) {
            return str.startsWith(ctlNo);
          }
        };
        // ファイルリスト取得
        File filepath = new File(deliveryJournalTmp);
        File[] listFile = filepath.listFiles(filter);
        for (File fl : listFile) {
          // ファイル削除
          fl.delete();
        }
      }
    }
  }
  // #8551 mod 処理対象となるbackupフォルダの日付が古い 2023-06-05 卓 end

  @Transactional
  @Override
  public SysCoopJournal update(SysCoopJournal journal) {
    sysCoopJournalDao.update(journal);

    return journal;
  }

  // mod #7627 #7239 2023-03-14 卓 start
  @Transactional
  @Override
  public void updateSkipJournalList(List<SysCoopJournal> journalList) {
    for (SysCoopJournal skipjournal : journalList) {
      // #8348 mod 2023-02-15 卓 start
      // List<String> needToSetSkipCoopResultList = Arrays.asList(
      // CoopResult.UNPROCESS.getResult()
      // , CoopResult.INTERNAL_ERROR_BY_NTSS.getResult()
      // , CoopResult.INTERNAL_ERROR_BY_CARTE.getResult()
      // , CoopResult.RETRY.getResult());
      // if (needToSetSkipCoopResultList.contains(skipjournal.getCoopResult())) {
      // skipjournal.setCoopResult(CoopResult.SKIP.getResult());
      // }

      // Crud.DELETEは電文を生成しない
      String message = skipjournal.getMessage();
      List<String> needToSetSkipAnaResultList = Arrays.asList(
        AnaResult.DONE.getResult()
        , AnaResult.PROCESSING.getResult()
        , AnaResult.UNPROCESS.getResult()
        , AnaResult.SKIP.getResult());
      if (needToSetSkipAnaResultList.contains(skipjournal.getAnaResult())) {
        if (AnaResult.UNPROCESS.getResult().equals(skipjournal.getAnaResult())) {
          skipjournal.setAnaResult(CoopResult.SKIP.getResult());
          skipjournal.setInAnaDate(new Timestamp(clockWrapper.getClockMillis()));
          skipjournal.setOutAnaDate(new Timestamp(clockWrapper.getClockMillis()));
        } else if (AnaResult.DONE.getResult().equals(skipjournal.getAnaResult())
                  || AnaResult.PROCESSING.getResult().equals(skipjournal.getAnaResult())) {
          skipjournal.setCoopResult(CoopResult.SKIP.getResult());
          skipjournal.setInRegDate(new Timestamp(clockWrapper.getClockMillis()));
          skipjournal.setOutRegDate(new Timestamp(clockWrapper.getClockMillis()));
        }
        // skipjournal.setAnaResult(AnaResult.SKIP.getResult());
        // #8348 mod 2023-02-15 卓 end
        // CRUDタイプに応じてスキップメッセージを設定
        if (Crud.DELETE.isSameResult(skipjournal.getCrud())) {
          message = JournalSendSkipConstant.SKIP_MESSAGE_DELETE_FOR_INCOMPLETE;
        } else {
          message = JournalSendSkipConstant.SKIP_MESSAGE_DELETE_TELEGRAM;
        }
      }
      // ジャーナル更新CoopResult
      Integer integer = this.updateJournalCoopResult(skipjournal, message);

      // rdCoopNo 削除処理
      if (Crud.DELETE.isSameResult(skipjournal.getCrud())) {
        if (CoopCdConstant.REP_DIAL.equals(skipjournal.getCoopCd())) {
          Boolean ordCoopNoDelete = this.checkJournalRep(skipjournal, Crud.CREATE.getResult(), Crud.DELETE.getResult());
          if (ordCoopNoDelete) {
            ordCoopNoService.deleteOrdCoopNoByJournal(skipjournal);
          }
        } else {
          ordCoopNoService.deleteOrdCoopNoByJournal(skipjournal);
        }
      }
    }

  }

  // mod #7627 #7239 2023-03-14 卓 end
  // #7239 2022-11-19 add 処理保留イベントの最適化処理が行われない start
  @Transactional
  @Override
  public Integer updateJournalSkip(SysCoopJournal journal, String skipMessage) {
    SysCoopJournal sysCoopJournal = sysCoopJournalDao.selectByPK(journal.getCtlNo());
    // #8348 mod 2023-02-15 卓 start
    if (AnaResult.UNPROCESS.getResult().equals(journal.getAnaResult())) {
      sysCoopJournal.setAnaResult(CoopResult.SKIP.getResult());
      sysCoopJournal.setInAnaDate(new Timestamp(clockWrapper.getClockMillis()));
      sysCoopJournal.setOutAnaDate(new Timestamp(clockWrapper.getClockMillis()));
    } else if (AnaResult.DONE.getResult().equals(journal.getAnaResult())) {
      sysCoopJournal.setCoopResult(CoopResult.SKIP.getResult());
      sysCoopJournal.setInRegDate(new Timestamp(clockWrapper.getClockMillis()));
      sysCoopJournal.setOutRegDate(new Timestamp(clockWrapper.getClockMillis()));
    }
    // if (!sysCoopJournal.getCoopResult().equals(CoopResult.DONE.getResult())) {
    // sysCoopJournal.setAnaResult(AnaResult.SKIP.getResult());
    // }
    // sysCoopJournal.setCoopResult(CoopResult.SKIP.getResult());
    // #8348 mod 2023-02-15 卓 end
    sysCoopJournal.setMessage(skipMessage);
    Integer updatedCount = sysCoopJournalDao.update(sysCoopJournal);
    if (updatedCount > 0) {
      JournalLogUtil.eventMessageDebug(skipMessage, sysCoopJournal, this.getClass().getName(), SERVICE_NAME.FNSI);
      return 1;
    }
    return 0;
  }

  @Transactional
  @Override
  public Integer updateJournalListSkip(List<SysCoopJournal> journalList, String skipMessage) {
    if (journalList.size() <= 0) {
      return 1;
    }
    for (SysCoopJournal journal : journalList) {
      String ordAnaResult = journal.getAnaResult();
      // #8348 mod 2023-02-15 卓 start
      journal.setUpDate(new Timestamp(clockWrapper.getClockMillis()));
      journal.setMessage(skipMessage);
      if (AnaResult.UNPROCESS.isSameResult(journal.getAnaResult())) {
        journal.setAnaResult(AnaResult.SKIP.getResult());
        journal.setInAnaDate(new Timestamp(clockWrapper.getClockMillis()));
        journal.setOutAnaDate(new Timestamp(clockWrapper.getClockMillis()));
      } else if (AnaResult.DONE.isSameResult(journal.getAnaResult())
                || AnaResult.PROCESSING.isSameResult(journal.getAnaResult())) {
        journal.setCoopResult(CoopResult.SKIP.getResult());
        journal.setInRegDate(new Timestamp(clockWrapper.getClockMillis()));
        journal.setOutRegDate(new Timestamp(clockWrapper.getClockMillis()));
      }
      String message = String.format("ジャーナルスキップ crl_no： %s, old_ana_result：%s", journal.getCtlNo(), ordAnaResult);
      JournalLogUtil.eventMessageDebug(message, journal, this.getClass().getName(), SERVICE_NAME.FNSI);
      // journal.setCoopResult(CoopResult.SKIP.getResult());
      // if (!journal.getCoopResult().equals(CoopResult.DONE.getResult())) {
      // journal.setAnaResult(AnaResult.SKIP.getResult());
      // }
      // #8348 mod 2023-02-15 卓 end
    }
    int[] updatedCount = sysCoopJournalDao.updateJournalListSkip(journalList);

    return 1;
  }

  @Transactional
  @Override
  public Integer updateJournalCoopResult(SysCoopJournal journal, String skipMessage) {
    SysCoopJournal sysCoopJournal = sysCoopJournalDao.selectByPK(journal.getCtlNo());
    // #8348 mod 2023-02-15 卓 start
    sysCoopJournal.setCoopResult(journal.getCoopResult());
    sysCoopJournal.setInRegDate(journal.getInRegDate());
    sysCoopJournal.setOutRegDate(journal.getOutRegDate());

    sysCoopJournal.setAnaResult(journal.getAnaResult());
    sysCoopJournal.setInAnaDate(journal.getInAnaDate());
    sysCoopJournal.setOutAnaDate(journal.getOutAnaDate());
    sysCoopJournal.setMessage(skipMessage);
    // #8348 mod 2023-02-15 卓 end
    Integer updatedCount = sysCoopJournalDao.update(sysCoopJournal);
    if (updatedCount > 0) {
      JournalLogUtil.eventMessageDebug(skipMessage, sysCoopJournal, this.getClass().getName(), SERVICE_NAME.FNSI);

      return 1;
    }
    return 0;
  }

  @Transactional
  @Override
  public Integer updateJournalSkipWithDate(SysCoopJournal journal) {
    Timestamp nowDate = new Timestamp(clockWrapper.getClockMillis());

    SysCoopJournal sysCoopJournal = sysCoopJournalDao.selectByPK(journal.getCtlNo());
    sysCoopJournal.setAnaResult(journal.getAnaResult());
    sysCoopJournal.setOutAnaDate(nowDate);
    sysCoopJournal.setInAnaDate(nowDate);
    // sysCoopJournal.setCoopResult(journal.getCoopResult());
    // sysCoopJournal.setInRegDate(nowDate);
    // sysCoopJournal.setOutRegDate(nowDate);

    sysCoopJournal.setMessage(journal.getMessage());
    Integer updatedCount = sysCoopJournalDao.update(sysCoopJournal);
    if (updatedCount > 0) {
      String message = String.format("変換処理結果 anaResult: %s,coopResult: %s", journal.getAnaResult(),journal.getCoopResult());
      JournalLogUtil.eventMessageDebug(message, sysCoopJournal, this.getClass().getName(), SERVICE_NAME.FNSI);

      return 1;
    }
    return 0;
  }
  // #7239 2022-11-19 add 処理保留イベントの最適化処理が行われない end

  @Transactional
  @Override
  public Integer updateJournalCrud(SysCoopJournal journal) {
    SysCoopJournal sysCoopJournal = sysCoopJournalDao.selectByPK(journal.getCtlNo());
    String oldCurd = sysCoopJournal.getCrud();

    sysCoopJournal.setCrud(journal.getCrud());
    Integer updatedCount = sysCoopJournalDao.update(sysCoopJournal);
    if (updatedCount > 0) {
      String message = String.format("作成更新区分Crud 変換: %s -> %s", oldCurd, journal.getCrud());
      JournalLogUtil.eventMessageDebug(message, sysCoopJournal, this.getClass().getName(), SERVICE_NAME.FNSI);

      return 1;
    }

    return 0;
  }

  /**
   * オーダ番号連携処理を行う
   *
   * @param journal - {@link SysCoopJournal journal}
   */
  // mod 2020-12-09 FNSI-改修 外部連携727 夏 start
  // private void executeCoopOrdNoProc(SysCoopJournal journal) {
  @Transactional
  @Override
  public String executeCoopOrdNoProc(SysCoopJournal journal) {
    // #8102-GX連携で実装されていない機能（処方情報連携） 周 add start
    if (Key0Constant.GX.equals(journal.getKey0()) && CoopCdConstant.PRE_ORD.equals(journal.getCoopCd())) {
      return "";
    }
    // #8102-GX連携で実装されていない機能（処方情報連携） 周 add end
    // mod 2020-12-09 FNSI-改修 外部連携727 夏 end
    // 連携オーダ番号
    String coopOrdNo = journal.getCoopOrdNo();
    // add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    // 電子カルテ種別
    String key0 = StringUtils.isEmpty(journal.getKey0()) ? "" : journal.getKey0();
    // 連携版番号
    String coopVersionCheck = StringUtils.isEmpty(journal.getCoopVersion())?"":String.valueOf(journal.getCoopVersion());
    // add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    boolean existsBySysCoopNo = false;
    // 1. オーダ番号連携対象か否かを判定する
    List<SysCoopNo> sysCoopNoList = sysCoopNoDao.selectByFacilityCd(journal.getFacilityCd());
    Long curSysCoopNoCtlNo = null;
    // coop_ord_cd内に対象電文種別が存在するか確認し、存在しない場合には オーダ番号連携対象外とする
    for (SysCoopNo sysCoopNo : sysCoopNoList) {
      // add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
      // 連携版番号
      String coopVersion = StringUtils.isEmpty(sysCoopNo.getCoopVersion())?"":String.valueOf(sysCoopNo.getCoopVersion());
      // coop_versionに連携版番号が一致しませんの場合、 オーダ番号連携対象外とする
      if (!coopVersionCheck.equals(coopVersion)) {
        continue;
      }
      // add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      try {
        List<Map<String, String>> coopCdMapList = ObjectMapperUtil.readTypeReference(sysCoopNo.getCoopOrdCd(), new TypeReference<List<Map<String, String>>>() {
            });
        for (Map<String, String> coopCdMap : coopCdMapList) {
          if (!journal.getCoopCd().equals(coopCdMap.get("ord_cd"))) {
            continue;
          }
          existsBySysCoopNo = true;
          curSysCoopNoCtlNo = sysCoopNo.getCtlNo();
          break;
        }
      } catch (Exception e) {
        // 対象電文種別判定失敗
        // なにもしない
      }
      if (existsBySysCoopNo) {
        break;
      }
    }
    // 2.オーダ番号連携対象外の場合、本処理を抜ける
    if (!existsBySysCoopNo) {
      return "";
    }

    // 3.携オーダ番号を取得する
    // mod 2021-03-30 課題No.37:オーダ番号につてい 孫 start
    // {
    // //3.0. ジャーナルデータのcrud（作成更新区分）がC（新規）以外の場合
    // boolean isNeedSaiban = true;
    // if (!"C".equals(journal.getCrud())) {
//      List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndOrdNoAndCoopCd(journal.getPatId(), journal.getOrdNo(), journal.getCoopCd());
    // if (!ordCoopNoList.isEmpty()) {
    // // D(中止)の場合、以降で同じ番号が使われないように論理削除する
    // if("D".equals(journal.getCrud())) {
    // Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    //
    // // DB更新ログ出力ロジック wangzuo Start
    // String tableNameOrd = "ord_coop_no";
    // // SQL検索条件
    // StringBuffer wheresOrd = new StringBuffer("");
    // wheresOrd.append(" WHERE\n");
    // wheresOrd.append(" pat_id = " + journal.getPatId() + "\n");
    // wheresOrd.append(" AND\n");
    // wheresOrd.append(" ord_no = " + journal.getOrdNo() + "\n");
    // wheresOrd.append(" AND\n");
    // wheresOrd.append(" coop_cd = '" + journal.getCoopCd() + "'\n");
    //
    // // logCommon設定
//          DataUpdateLogCommonNew logCommonOrd = getLogCommon(ordCoopNoDao, tableNameOrd, wheresOrd, getEventLogMessage());
    // // ログ出力カラム情報及び更新前データ情報取得
    // boolean setResultOrd = logCommonOrd.setInfo();
    // // DB更新ログ出力ロジック wangzuo End
    //
//          int updateCountOrd = ordCoopNoDao.updateIsDelIsDisp(journal.getPatId(), journal.getOrdNo(), journal.getCoopCd(), now);
    //
    // // DB更新ログ出力ロジック wangzuo Start
    // // 更新後データ取得、差分あれば、log出力
    // if (setResultOrd && updateCountOrd > 0) {
    // logCommonOrd.updateLog();
    // }
    // // DB更新ログ出力ロジック wangzuo End
    //
    // }
    // // add 2020-12-17 FNSI-改修 外部連携721(前回処理結果による処理変更) 夏 start
    // else{
    // for (OrdCoopNo ordCoopNo : ordCoopNoList) {
    // if(ordCoopNo.getFacilityCd().equals(journal.getFacilityCd()) &&
    // ordCoopNo.getCoopOrdNo().equals(coopOrdNo) &&
    // "0".equals(ordCoopNo.getStatus())){
    // journal.setCrud("C");
    // }
    // }
    // }
    // // add 2020-12-17 FNSI-改修 外部連携721(前回処理結果による処理変更) 夏 end
    //
    // journal.setCoopOrdNo(ordCoopNoList.get(0).getCoopOrdNo());
    // return;
    // }
    // }
    // Long updateByCurCoopOrdNo = null;
    // while (isNeedSaiban) {
    // //新規 or 更新でありながら該当データがない場合
    // //3.1. 連携オーダ番号を採番する
    // //3.1.1. 1の処理で取得したctl_noをキーにしてsys_coop_noを取得する(forupdate)
    // SysCoopNo curSysCoopNo = sysCoopNoDao.selectByCtlNo(curSysCoopNoCtlNo);
    // //3.1.2. 現在の連携オーダ番号シーケンスを+1する
    // if (updateByCurCoopOrdNo == null) {
    // updateByCurCoopOrdNo = curSysCoopNo.getCurCoopOrdNo() + 1;
    // } else {
    // updateByCurCoopOrdNo ++;
    // }
    //
    // //3.1.3. 上記結果が最大値を超えた場合には最小値に設定する
    // if (updateByCurCoopOrdNo > curSysCoopNo.getRangeMax()) {
    // updateByCurCoopOrdNo = curSysCoopNo.getRangeMin();
    // }
    // //3.1.4. 連携オーダ番号、パディング文字、位置、前置文字、後置文字等を用いて連携オーダ番号（文字列）を作成する
    // StringBuilder coopOrdNoSb = new StringBuilder();
    // //前置文字
    // coopOrdNoSb.append(curSysCoopNo.getPrefixChar());
    // //パティングした文字
//      coopOrdNoSb.append(padding(String.valueOf(updateByCurCoopOrdNo), curSysCoopNo.getNoOfDigit(), curSysCoopNo.getPaddingChar(), curSysCoopNo.getPaddingPos()));
    // //後置文字
    // coopOrdNoSb.append(curSysCoopNo.getSuffixChar());
    //
    // coopOrdNo = coopOrdNoSb.toString();
    // //3.1.5. 以下のsqlを発行し、結果が0件でない場合には3.1.2に戻り処理を繰り返す
//      List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndCoopOrdNo(journal.getPatId(), coopOrdNo);
    // if (ordCoopNoList.isEmpty()) {
    // isNeedSaiban = false;
    // Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    //
    // // DB更新ログ出力ロジック wangzuo Start
    // String tableNameSys = "sys_coop_no";
    // // SQL検索条件
    // StringBuffer wheresSys = new StringBuffer("");
    // wheresSys.append(" WHERE\n");
    // wheresSys.append(" ctl_no = " + curSysCoopNoCtlNo + "\n");
    //
    // // logCommon設定
//        DataUpdateLogCommonNew logCommonSys = getLogCommon(sysCoopNoDao, tableNameSys, wheresSys, getEventLogMessage());
    // // ログ出力カラム情報及び更新前データ情報取得
    // boolean setResultSys = logCommonSys.setInfo();
    // // DB更新ログ出力ロジック wangzuo End
    //
    // //3.1.6. sys_coop_noをupdateする(対象カラム: cur_coop_ord_no )
//        int updateCountSys = sysCoopNoDao.updateCurCoopOrdNo(updateByCurCoopOrdNo, curSysCoopNoCtlNo, now);
    //
    // // DB更新ログ出力ロジック wangzuo Start
    // // 更新後データ取得、差分あれば、log出力
    // if (setResultSys && updateCountSys > 0) {
    // logCommonSys.updateLog();
    // }
    // // DB更新ログ出力ロジック wangzuo End
    //
    // // DB更新ログ出力ロジック wangzuo Start
    // String tableNameOrd = "ord_coop_no";
    // // SQL検索条件
    // StringBuffer wheresOrd = new StringBuffer("");
    // wheresOrd.append(" WHERE\n");
    // wheresOrd.append(" pat_id = " + journal.getPatId() + "\n");
    // wheresOrd.append(" AND\n");
    // wheresOrd.append(" ord_no = " + journal.getOrdNo() + "\n");
    // wheresOrd.append(" AND\n");
    // wheresOrd.append(" coop_cd = '" + journal.getCoopCd() + "'\n");
    //
    // // logCommon設定
//        DataUpdateLogCommonNew logCommonOrd = getLogCommon(ordCoopNoDao, tableNameOrd, wheresOrd, getEventLogMessage());
    // // ログ出力カラム情報及び更新前データ情報取得
    // boolean setResultOrd = logCommonOrd.setInfo();
    // // DB更新ログ出力ロジック wangzuo End
    //
    // //3.1.7. ord_coop_noをupdateする(pat_id, ord_no, coop_cdをキー)
    // //update deleteflg 1 viewFlg 0
//        int updateCountOrd = ordCoopNoDao.updateIsDelIsDisp(journal.getPatId(), journal.getOrdNo(), journal.getCoopCd(), now);
    //
    // // DB更新ログ出力ロジック wangzuo Start
    // // 更新後データ取得、差分あれば、log出力
    // if (setResultOrd && updateCountOrd > 0) {
    // logCommonOrd.updateLog();
    // }
    // // DB更新ログ出力ロジック wangzuo End
    //
    // OrdCoopNo ordCoopNo = new OrdCoopNo();
    // ordCoopNo.setCtlNo(ordCoopNoDao.selectNextSeqCtlNo());
    // ordCoopNo.setFacilityCd(journal.getFacilityCd());
    // ordCoopNo.setPatId(journal.getPatId());
    // ordCoopNo.setOrdNo(journal.getOrdNo());
    // ordCoopNo.setCoopCd(journal.getCoopCd());
    // ordCoopNo.setCoopOrdNo(coopOrdNo);
    // ordCoopNo.setUserId(journal.getUserId());
    // ordCoopNo.setRegDate(now);
    // ordCoopNo.setUpDate(now);
    // //3.1.8. ord_coop_noをinsertする
    // ordCoopNoDao.insert(ordCoopNo);
    // }
    // // add 2020-12-17 FNSI-改修 外部連携721(前回処理結果による処理変更) 夏 start
    // else{
    // for (OrdCoopNo ordCoopNo : ordCoopNoList) {
    // if(ordCoopNo.getFacilityCd().equals(journal.getFacilityCd()) &&
    // ordCoopNo.getOrdNo().equals(journal.getOrdNo()) &&
    // ordCoopNo.getCoopCd().equals(journal.getCoopCd()) &&
    // "1".equals(ordCoopNo.getStatus())){
    // isNeedSaiban = false;
    // journal.setCrud("U");
    // }
    // }
    // }
    // // add 2020-12-17 FNSI-改修 外部連携721(前回処理結果による処理変更) 夏 end
    // }
    // journal.setCoopOrdNo(coopOrdNo);
    // }
    // 削除したソース

    // 画面パラメータ[患者番号,オーダ番号,連携種別(pat_id,ord_no,coop_cd)] で、連携オーダ番号(ord_coop_no)を取得する

    // #7790 初版確定前の治療実績削除で不要なイベントが登録される 王永吉　start
//    List<MstCoopIni> iniName = mstCoopIniDao.selectByFacilityCd(journal.getFacilityCd());
    // // 電文施設名が存在する場合
    // if (iniName != null && iniName.size() > 0) {
    // // 電文施設名はと"日機装"同じの場合
    // if ("日機装".equals(iniName.get(0).getCoopIniMemo())) {
    // if ("S".equals(journal.getDirection()) && "D".equals(journal.getCrud()) &&
//          ("rst_dial".equals(journal.getCoopCd()) || ("rep_dial".equals(journal.getCoopCd()) && ("pdf".equals(journal.getCoopCdIndex()) || "xml".equals(journal.getCoopCdIndex()) || "listxml".equals(journal.getCoopCdIndex()))))) {
    // // 治療情報のord_noの取得
    // Long ordNo = journal.getOrdNo();
    // // 版番号と治療状況の取得
    // List<OrdMain> ordS = ordMainDao.selectRstByOrdNo(ordNo);
    // // 治療情報が存在する場合
    // if (ordS != null && ordS.size() > 0) {
    // // 版番号が0の状態。または、透析ステータスが6じゃない状態。治療実績削除でイベントが登録されない。
//            if (!CoreConstant.rstDialysisState.AFTER_PAST_RECORD.equals(ordS.get(0).getRstDialysisState()) || ordS.get(0).getRstEdition() == 0) {
    // return "";
    // }
    // } else {
    // // 治療情報が存在しない場合、治療実績削除でイベントが登録されない。
    // return "";
    // }
    // }
    // }
    // } else {
    // // 電文施設名が存在しない場合、治療実績削除でイベントが登録されない。
    // return "";
    // }
    // #7790 初版確定前の治療実績削除で不要なイベントが登録される 王永吉　end

    // mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    // // mod 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 start
////    List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndOrdNoAndCoopCd(journal.getPatId(), journal.getOrdNo(), journal.getCoopCd());
//    List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndOrdNoAndCoopCd(journal.getFacilityCd(), journal.getPatId(), journal.getHospPatId(), journal.getOrdNo(), journal.getCoopCd());
    // // mod 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 end
    List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndOrdNoAndCoopCd(journal.getFacilityCd(),
        journal.getPatId(), journal.getHospPatId(), journal.getOrdNo(), journal.getCoopCd(), coopVersionCheck);
    // mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    if (!ordCoopNoList.isEmpty()) {
      // 連携オーダ番号(ord_coop_no)を取得する場合、連携オーダ番号を設定する
      coopOrdNo = ordCoopNoList.get(0).getCoopOrdNo();
    } else {
      // 連携オーダ番号(ord_coop_no)を取得しませんの場合

      // data,indexがセットになった電文であるか否かを設定したの場合、電文付帯情報がindexです。
      // indexの場合、関連したdataの連携オーダ番号を取得しませんの場合、
      // 送信しない。ジャーナルの通信ステータスは内部エラー。
      if ("index".equals(journal.getCoopCdIndex())) {
        // mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//        String error = String.format("電文付帯情報がindexの場合、関連した連携オーダ番号が無し。pat_id:[%s],ord_no:[%s],coop_cd:[%s]",
        // journal.getPatId(), journal.getOrdNo(), journal.getCoopCd());
        String error = String.format("電文付帯情報がindexの場合、関連した連携オーダ番号が無し。pat_id:[%s],ord_no:[%s],coop_cd:[%s],coop_version:[%s]",
            journal.getPatId(), journal.getOrdNo(), journal.getCoopCd(), coopVersionCheck);
        // mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        outputErrorLog(journal.getFacilityCd(), error);

        return error;
        // throw new NtssException(error);
      }

      // ジャーナルデータのcrud（作成更新区分）がD（削除）以外の場合、連携オーダ番号を採番する
      if (!"index".equals(journal.getCoopCdIndex())) {
        // #7068 mod 2022-11-14 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 start
        // && !"D".equals(journal.getCrud())) {
        // try {
        // // 連携オーダ番号を採番する
        // coopOrdNo = getNewCoopOrdNo(curSysCoopNoCtlNo, journal);
        try {
          coopOrdNo = ordCoopNoService.createOrdCoopNo(curSysCoopNoCtlNo, journal);
          // #7068 mod 2022-11-14 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 start
        } catch (Exception ex) {

          return ex.getMessage();
        }
      }
    }

    // 連携オーダ番号を設定する
    journal.setCoopOrdNo(coopOrdNo);
    convertCommonService.updateCoopOrdNo(journal);

    // #7301 2022-12-12 mod ind_dial連携・rst_dial連携・rep_dial連携のオーダ番号 start
    // ジャーナルデータのcrud（作成更新区分）のチェックを行う。
    if (Crud.CREATE.isSameResult(journal.getCrud())) {
      // ①送信する電文のcrudがC（新規）の時
      // 1.存在かつ実施済→crudはUにする（更新）
      // 2.存在かつ未実施→crudはCのまま。送信完了後実施済
      // 3.存在しない→crudはCのまま。送信完了後実施済

      // 連携オーダ番号(ord_coop_no)が存在、かつ、ステータスが実施済(status = 1：処理済)
      // かつ、電文種別!=[profile]の場合、crudはUにする。
      if (!ordCoopNoList.isEmpty() && OrdCoopNoConstant.Status.DONE.isSameResult(ordCoopNoList.get(0).getStatus())
          && !CoopCdConstant.PROFILE.equals(journal.getCoopCd())) {
        journal.setCrud(Crud.UPDATE.getResult());
      }
      // mod 2023-02-06 7781 start
      List<SysCoopJournal> crudCreateJournalList = this.findSameJournalList(journal, Crud.CREATE.getResult(), false);
      // if (journal.getCoopCd().equals(CoopCdConstant.REP_DIAL)) {
//        crudCreateJournalList = this.listByCrudCoopCdCoopCdIndex(journal, Crud.CREATE.getResult(), CoopCdConstant.REP_DIAL, journal.getCoopCdIndex());
      // } else {
//        crudCreateJournalList = this.listCoopResultUnprocessSkipError(journal, Crud.CREATE.getResult());
      // }
      // mod 2023-02-06 7781 end
      crudCreateJournalList=crudCreateJournalList.stream().filter(creJ->(!creJ.getCtlNo().equals(journal.getCtlNo()))).collect(Collectors.toList());
      if (crudCreateJournalList != null && crudCreateJournalList.size() > 0) {
        SysCoopJournal crudCreJournal = crudCreateJournalList.get(crudCreateJournalList.size() - 1);
        this.updateJournalSkip(crudCreJournal, JournalSendSkipConstant.SKIP_MESSAGE_LATEST_TELEGRAM);

      }

    } else if (Crud.UPDATE.isSameResult(journal.getCrud())) {
      // ②送信する電文のcrudがU（更新）の時
      // 1.存在かつ実施済→crudはUのまま
      // 2.存在かつ未実施→crudはCにする。送信完了後実施済
      // 3.存在しない→crudはCにする。送信完了後実施済

      // 連携オーダ番号(ord_coop_no)が存在しない、
      // または、[存在、かつ、ステータスが未処理(status = 0：未処理)]の場合、crudはCにする。
      if (ordCoopNoList.isEmpty()) {
        journal.setCrud(Crud.CREATE.getResult());
      } else {
        // String ordCoopStatus = ordCoopNoList.get(0).getStatus();
        OrdCoopNo ordCoopNo = ordCoopNoList.get(0);

        // CoopOrdNo未送信処理
        if (OrdCoopNoConstant.Status.UNPROCESS.isSameResult(ordCoopNo.getStatus())) {
          journal.setCrud(Crud.CREATE.getResult());

          // 以前のjournalはskipに設定されていました
          // mod 2023-02-06 7781 start
          List<SysCoopJournal> crudCreateJournalList = this.findSameJournalList(journal, Crud.CREATE.getResult(),false);
          // if (journal.getCoopCd().equals(CoopCdConstant.REP_DIAL)) {
          //            crudCreateJournalList = this.listByCrudCoopCdCoopCdIndex(journal, Crud.CREATE.getResult(), CoopCdConstant.REP_DIAL, journal.getCoopCdIndex());
          // } else {
          //            crudCreateJournalList = this.listCoopResultUnprocessSkipError(journal, Crud.CREATE.getResult());
          // }
          // mod 2023-02-06 7781 end

          if (crudCreateJournalList != null && crudCreateJournalList.size() > 0) {
            SysCoopJournal crudCreJournal = crudCreateJournalList.get(0);
            this.updateJournalSkip(crudCreJournal, JournalSendSkipConstant.SKIP_MESSAGE_LATEST_TELEGRAM);
          }
        } else {
          // mod 2023-02-06 7781 start
          List<SysCoopJournal> crudUpdateJournalList = this.findSameJournalList(journal, Crud.UPDATE.getResult(),false);
          // List<SysCoopJournal> crudUpdateJournalList = null;
          // if (journal.getCoopCd().equals(CoopCdConstant.REP_DIAL)) {
          //            crudUpdateJournalList = this.listByCrudCoopCdCoopCdIndex(journal, Crud.UPDATE.getResult(), CoopCdConstant.REP_DIAL, journal.getCoopCdIndex());
          // } else {
          //            crudUpdateJournalList = this.listCoopResultUnprocessSkipError(journal, Crud.UPDATE.getResult());
          // }
          // mod 2023-02-06 7781 end
          crudUpdateJournalList = crudUpdateJournalList.stream().filter(creJ -> (!creJ.getCtlNo().equals(journal.getCtlNo()))).collect(Collectors.toList());
          if (crudUpdateJournalList != null && crudUpdateJournalList.size() > 0) {
            SysCoopJournal crudCreJournal = crudUpdateJournalList.get(0);
            this.updateJournalSkip(crudCreJournal, JournalSendSkipConstant.SKIP_MESSAGE_LATEST_TELEGRAM);
          }
        }

        // mod FNSI-7528 劉全航 start
        // CoopOrdNo送信処理
        if (OrdCoopNoConstant.Status.DONE.isSameResult(ordCoopNo.getStatus())) {
          // mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//          boolean condition = this.getTreatmentRecordCondition(journal.getOrdNo(), journal.getFacilityCd());
          boolean condition = this.getTreatmentRecordCondition(journal.getOrdNo(), journal.getFacilityCd(), key0);
          // mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          if (condition && CoopCdConstant.RST_DIAL.equals(journal.getCoopCd())) {
            journal.setCrud(Crud.CREATE.getResult());
          }
        }
      }
      // mod FNSI-7528 劉全航 end
      // mod FNSI-7528 劉全航 start
    } else if (Crud.DELETE.isSameResult(journal.getCrud())) {
      // mod FNSI-7528 劉全航 end
      // ③送信する電文のcrudがD（削除）の時
      // 1.存在かつ実施済→crudはDのまま。送信完了後is_del=1
      // 2.存在かつ未実施→送信しない。ジャーナルの通信ステータスは内部エラー。完了後is_del=1
      // 3.存在しない→送信しない。ジャーナルの通信ステータスは内部エラー。

      // ord_coop_noが存の場合、is_del=1を設定する
      // #7068 mod 2022-11-14 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 start
      // ord_coop_noが存在しないの場合、
      // 送信しない。ジャーナルの通信ステータスは内部エラー。

      if (!ordCoopNoList.isEmpty()) {
        // ord_coop_noが存在、かつ、ステータスが未処理「status = 0：未処理」の場合、

        // Add 【デグレ】削除電文の連携オーダ番号が取得できない CoopResult !=0 の場合 2022-07-26 #7781 xmj start

        // 送信しない。ジャーナルの通信ステータスは内部エラー。
        String ordCoopStatus = ordCoopNoList.get(0).getStatus();
        if (OrdCoopNoConstant.Status.UNPROCESS.isSameResult(ordCoopStatus) && !CoopResult.SKIP.isSameResult(journal.getCoopResult())) {
          // mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//          String error = String.format("ジャーナルデータの作成更新区分が削除の場合、連携オーダ番号のステータスが未処理です。pat_id:[%s],ord_no:[%s],coop_cd:[%s]",
          // journal.getPatId(), journal.getOrdNo(), journal.getCoopCd());
          String error = String.format("ジャーナルデータの作成更新区分が削除の場合、連携オーダ番号のステータスが未処理です。pat_id:[%s],ord_no:[%s],coop_cd:[%s],coop_version:[%s]",
              journal.getPatId(), journal.getOrdNo(), journal.getCoopCd(), coopVersionCheck);
          // mod 2023-01-29 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          outputErrorLog(journal.getFacilityCd(), error);

          return error;
          // throw new NtssException(error);
        }

        // createに対応するdeleteがすべて作成された場合、coopOrdNoを削除
        if (CoopCdConstant.REP_DIAL.equals(journal.getCoopCd())) {
          Boolean ordCoopNoDelete = this.checkJournalRep(journal, Crud.CREATE.getResult(), Crud.DELETE.getResult());
//          List<SysCoopJournal> createRepList=this.listByCrudCoopCd(journal,Crud.CREATE.getResult(),CoopCdConstant.REP_DIAL);
//          List<SysCoopJournal> deleteRepList=this.listByCrudCoopCd(journal,Crud.DELETE.getResult(),CoopCdConstant.REP_DIAL);
          // for (SysCoopJournal creJ : createRepList) {
//            if (deleteRepList.stream().filter(delJ -> (null != delJ.getCoopOrdNo() && delJ.getCoopCdIndex().equals(creJ.getCoopCdIndex()))).count() == 0l) {
          // ordCoopNoDelete = false;
          // break;
          // }
          // }
          if (ordCoopNoDelete) {
            ordCoopNoService.deleteOrdCoopNoByJournal(journal);
          }

        } else {
          // OrdCoopNo 削除処理
          ordCoopNoService.deleteOrdCoopNoByJournal(journal);
        }
      }
    }

    this.updateJournalCrud(journal);

    // #7301 2022-12-12 mod ind_dial連携・rst_dial連携・rep_dial連携のオーダ番号 end
    // #7068 mod 2022-11-14 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 end

    // #7068 rm 2022-11-14 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 start
    // // DB更新ログ出力ロジック wangzuo Start
    // String tableNameOrd = "ord_coop_no";
    // // SQL検索条件
    // StringBuffer wheresOrd = new StringBuffer("");
    // wheresOrd.append(" WHERE\n");
    // wheresOrd.append(" pat_id = " + journal.getPatId() + "\n");
    // wheresOrd.append(" AND\n");
    // wheresOrd.append(" ord_no = " + journal.getOrdNo() + "\n");
    // wheresOrd.append(" AND\n");
    // wheresOrd.append(" coop_cd = '" + journal.getCoopCd() + "'\n");
    //
    // // logCommon設定
//        DataUpdateLogCommonNew logCommonOrd = getLogCommon(ordCoopNoDao, tableNameOrd, wheresOrd, getEventLogMessage());
    // // ログ出力カラム情報及び更新前データ情報取得
    // boolean setResultOrd = logCommonOrd.setInfo();
    // // DB更新ログ出力ロジック wangzuo End
    //
    // // mod 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 start
////        int updateCountOrd = ordCoopNoDao.updateIsDelIsDisp(journal.getPatId(), journal.getOrdNo(), journal.getCoopCd(), now);
//        int updateCountOrd = ordCoopNoDao.updateIsDelIsDisp(journal.getPatId(), journal.getHospPatId(), journal.getOrdNo(), journal.getCoopCd(), now);
    // // mod 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 end
    //
    // // DB更新ログ出力ロジック wangzuo Start
    // // 更新後データ取得、差分あれば、log出力
    // if (setResultOrd && updateCountOrd > 0) {
    // logCommonOrd.updateLog();
    // }
    // // DB更新ログ出力ロジック wangzuo End
    // }
    // }
    // // ord_coop_noが存在しないの場合、
    // // 送信しない。ジャーナルの通信ステータスは内部エラー。
    // if (ordCoopNoList.isEmpty()) {
//        String error = String.format("ジャーナルデータの作成更新区分が削除の場合、連携オーダ番号が無し。pat_id:[%s],ord_no:[%s],coop_cd:[%s]",
    // journal.getPatId(), journal.getOrdNo(), journal.getCoopCd());
    // outputErrorLog(journal.getFacilityCd(), error);
    // return error;
    //// throw new NtssException(error);
    // }
    //
    // // ord_coop_noが存在、かつ、ステータスが未処理「status = 0：未処理」の場合、
    // // Add 【デグレ】削除電文の連携オーダ番号が取得できない CoopResult !=0 の場合 2022-07-26 #7781 xmj start
    // // 送信しない。ジャーナルの通信ステータスは内部エラー。
//      if (!ordCoopNoList.isEmpty() && "0".equals(ordCoopNoList.get(0).getStatus()) && !"0".equals(journal.getCoopResult())) {
//        String error = String.format("ジャーナルデータの作成更新区分が削除の場合、連携オーダ番号のステータスが未処理です。pat_id:[%s],ord_no:[%s],coop_cd:[%s]",
    // journal.getPatId(), journal.getOrdNo(), journal.getCoopCd());
    // outputErrorLog(journal.getFacilityCd(), error);
    // return error;
    //// throw new NtssException(error);
    // }
    // }
    // Add 【デグレ】削除電文の連携オーダ番号が取得できない CoopResult !=0 の場合 2022-07-26 #7781 xmj end
    // #7068 rm 2022-11-14 患者経過総合ビューアで曜日パターン変更すると変更前の削除イベント・変更後の新規イベントが正しく作成されない   卓 end
    return "";
    // mod 2021-03-30 課題No.37:オーダ番号につてい 孫 end
  }

  @Override
  public Boolean checkJournalRep(SysCoopJournal journal, String crud1, String crud2) {
    Boolean ordCoopNoDelete = true;
    if (CoopCdConstant.REP_DIAL.equals(journal.getCoopCd())) {
      List<SysCoopJournal> createRepList = this.listByCrudCoopCd(journal, crud1, CoopCdConstant.REP_DIAL);
      List<SysCoopJournal> crud2List = this.listByCrudCoopCd(journal, crud2, CoopCdConstant.REP_DIAL);
      for (SysCoopJournal creJ : createRepList) {
        if (crud2List.stream().filter(delJ -> (null != delJ.getCoopOrdNo() && delJ.getCoopCdIndex().equals(creJ.getCoopCdIndex()))).count() == 0l) {
          ordCoopNoDelete = false;
          break;
        }
      }
    }
    return ordCoopNoDelete;
  }

  /**
   * 作成更新区分と電文種別で検索
   *
   * @param journal {@link SysCoopJournal}
   * @param crud    {@link Crud}
   * @param coopCd  {@link CoopCdConstant}
   */
  private List<SysCoopJournal> listByCrudCoopCd(SysCoopJournal journal, String crud, String coopCd) {
    // mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    return sysCoopJournalDao.selectByCrudCoopCd(crud, coopCd, journal.getOrdNo(), journal.getPatId(), journal.getDirection(), journal.getFacilityCd());
//    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion())?"":String.valueOf(journal.getCoopVersion());
//    return sysCoopJournalDao.selectByCrudCoopCd( crud, coopCd, coopVersion, journal.getOrdNo(), journal.getPatId(),
    // journal.getDirection(), journal.getFacilityCd());
    SysCoopJournalParam param = new SysCoopJournalParam();
    param.setFacilityCd(journal.getFacilityCd());
    param.setDirection(journal.getDirection());
    param.setOrdNo(journal.getOrdNo());
    param.setPatId(journal.getPatId());
    param.setHospPatId(journal.getHospPatId());
    param.setCoopVersion(StringUtils.isEmpty(journal.getCoopVersion()) ? "" : String.valueOf(journal.getCoopVersion()));
    param.setCrud(crud);
    param.setCoopCd(coopCd);
    param.setCoopOrdNo(journal.getCoopOrdNo());
    param.setRegDate(journal.getRegDate());
    return sysCoopJournalDao.selectJournals(param);
    // mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  }

  /**
   * 当該ジャーナル対象により、最適化する必要があるジャーナル対象を検索する。
   * RepDial
   *
   * @param journal     {@link SysCoopJournal}
   * @param crud        {@link Crud}
   * @param coopCd      {@link CoopCdConstant}
   * @param coopCdIndex IBM向け_電文付帯情報
   * @param last        フィルタリングregDateが現在のJournalのregDateより小さい
   */
  public List<SysCoopJournal> findSameJournalListRepDial(SysCoopJournal journal, String crud, String coopCd, String coopCdIndex,Boolean last) {
    // mod 2023-4-14#8348 #7237 卓 start
//    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion()) ? "" : String.valueOf(journal.getCoopVersion());
    // Timestamp regDate=last?null:journal.getRegDate();
    // return sysCoopJournalDao.selectByCrudCoopCdCoopCdIndex(
    // crud
    // , coopCd
    // , coopCdIndex
    // , journal.getOrdNo()
    // , coopVersion
    // , journal.getPatId()
    // , journal.getDirection()
    // , journal.getFacilityCd()
    // , Arrays.asList(CoopResult.DONE.getResult(),CoopResult.UNPROCESS.getResult())
    // , CoopResult.UNPROCESS.getResult()
    // , regDate
    // );
    SysCoopJournalParam param = new SysCoopJournalParam();
    param.setCrud(crud);
    param.setCoopCd(coopCd);
    param.setCoopCdIndex(coopCdIndex);
    param.setOrdNo(journal.getOrdNo());
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion()) ? "" : journal.getCoopVersion();
    param.setCoopVersion(coopVersion);
    param.setPatId(journal.getPatId());
    param.setHospPatId(journal.getHospPatId());
    param.setDirection(journal.getDirection());
    param.setFacilityCd(journal.getFacilityCd());
    param.setAnaResult(Arrays.asList(AnaResult.DONE.getResult(), AnaResult.UNPROCESS.getResult()));
    param.setCoopResult(Arrays.asList(CoopResult.UNPROCESS.getResult()));
    Timestamp regDate = last ? null : journal.getRegDate();
    param.setRegDate(regDate);
    return sysCoopJournalDao.selectJournals(param);
    // mod 2023-4-14#8348 #7237 卓 end
  }

  /**
   * 当該ジャーナル対象により、最適化する必要があるジャーナル対象を検索する。
   *
   * @param journal {@link SysCoopJournal}
   * @param crud    {@link Crud}
   * @param last    フィルタリングregDateが現在のJournalのregDateより小さい
   */
  public List<SysCoopJournal> findSameJournalListByCrud(SysCoopJournal journal, String crud, Boolean last) {
    // mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    SysCoopJournalParam param = new SysCoopJournalParam();
    param.setFacilityCd(journal.getFacilityCd());
    param.setDirection(journal.getDirection());
    param.setOrdNo(journal.getOrdNo());
    param.setPatId(journal.getPatId());
    param.setHospPatId(journal.getHospPatId());
    param.setCoopCd(journal.getCoopCd());
    param.setCrud(crud);
    param.setCoopOrdNo(journal.getCoopOrdNo());
    param.setAnaResult(Arrays.asList(AnaResult.DONE.getResult(), AnaResult.PROCESSING.getResult(), AnaResult.UNPROCESS.getResult()));
    param.setCoopResult(NtssCoopApiConstants.coopResultSkipList);
    if (!last) {
      param.setRegDate(journal.getRegDate());
    }
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion()) ? "" : journal.getCoopVersion();
    param.setCoopVersion(coopVersion);

    return sysCoopJournalDao.selectJournals(param);

    // mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  }
  // add 2021-03-30 課題No.37:オーダ番号につてい 孫 start

  // Mod 2023-06-06 #8584 Thach start
  /**
   * 種別が「ini_dial」「profile」のレコードが存在するのチェック
   *
   * @param journal - {@link SysCoopJournal}
   * @return 処理結果
   */
  @Transactional
  @Override
  public String checkCoopExisted(SysCoopJournal journal) {
    if (journal == null) {
      return "";
    }
    // ジャーナルの情報を取得する
    String facilityCd = journal.getFacilityCd();
    String direction = journal.getDirection();
    Long patId = journal.getPatId();
    String hospPatId = journal.getHospPatId();
    String coopCd = journal.getCoopCd();
    Long ordNo = journal.getOrdNo();
    Long ctlNo = journal.getCtlNo();
    String checkCoopCd = "";
    String checkCoopName = "";
    String key0 = StringUtils.isEmpty(journal.getKey0()) ? "" : journal.getKey0();
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion()) ? "" : journal.getCoopVersion();

    // MstCoopIniを取得する
    List<MstCoopIni> values = mstCoopIniDao.selectByFacilityCd(facilityCd);
    MstCoopIni value = null;
    String res = null;

    if (null != values && values.size() > 0) {
      value = values.get(0);
      String data = value.getCoopIniInfo();
      JSONArray ay = new JSONArray(data);
      for (int i = 0; i < ay.length(); i++) {
        String key0Ini = "";
        if (ay.getJSONObject(i).has("key0")) {
          key0Ini = StringUtils.isEmpty(ay.getJSONObject(i).get("key0"))?"":String.valueOf(ay.getJSONObject(i).get("key0"));
        }
        if (key0.equals(key0Ini) &&
            ay.getJSONObject(i).get("key1").equals("PAT_SCOPE") && ay.getJSONObject(i).get("key2").equals(coopCd)) {
          res = ay.getJSONObject(i).get("value").toString();
        }
      }

      if (null != res) {
        if (res.equals("0")) {
          return "";
        } else if (res.equals("1")) {
          checkCoopCd = "profile";
          checkCoopName = "患者プロファイル";
          List<SysCoopJournal> chekJournal = sysCoopJournalDao.selectForNotCoopCheck(facilityCd, coopVersion,
              direction, patId, hospPatId, checkCoopCd);
          if (chekJournal == null || chekJournal.size() == 0) {
            return "[" + checkCoopName + "]データが無し。この患者[" + hospPatId + "]は連携したことがない。";
          }
        } else if (res.equals("2")) {
          Map<String, Object> dataKey = new HashMap<>();
          dataKey.put("facilityCd", facilityCd);
          dataKey.put("ordNo", ordNo);
          dataKey.put("patId", patId);
          dataKey.put("ctlNo", ctlNo);
          dataKey.put("key0", key0);
          dataKey.put("coopVersion", coopVersion);
          List<Map<String, Object>> reportInfo;
          reportInfo = sysDataSetService.getDataListContainsError(-30l, dataKey, null);
          if (reportInfo == null || reportInfo.size() == 0) {
            return "[" + checkCoopName + "]データが無し。この患者[" + hospPatId + "]は連携したことがない。";
          }
        }
      }
    }
    return "";
  }
  // Mod 2023-06-06 #8584 Thach end

  // add 2022-11-02 bug #8028 応答待ちのジャーナルがあると、送信処理が実施されない 孫 start
  @Transactional
  @Override
  public int updateWaitingStatus(String facilityCd) {
    return sysCoopJournalDao.updateWaitingStatus(facilityCd);
  }
  // add 2022-11-02 bug #8028 応答待ちのジャーナルがあると、送信処理が実施されない 孫 end

  /* modify by zhangruixue 2023-01-30 [Transaction,CodeOptimization] --start */
  @Transactional
  @Override
  public ErrorMessage updateWaiting(String facilityCd, JournalDeliveryRequest request) {
    ErrorMessage result = null;
    EventLogMessage eventLogMessage = new EventLogMessage();
    try {
      int updCnt = this.updateWaitingStatus(facilityCd);
      result = new ErrorMessage(HttpStatus.OK, String.format("UPDATE CNT[%s].", updCnt));
    } catch (Exception e) {
      ErrorMessage error = new ErrorMessage(HttpStatus.INTERNAL_SERVER_ERROR, "応答待ちのジャーナル更新APIにて例外が発生しました。");

      eventLogMessage.setFacilityCd(request.getFacilityCd());
      eventLogMessage.setInvokeClass(this.getClass().getName());
      eventLogMessage.setLogMessage(error.getMessage() + "Message:" + e.getMessage());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(eventLogMessage.getLogMessage());
    }

    // エッジヘルスモニタ更新処理の呼び出し
    try {
      healthService.update(request);
    } catch (Exception e) {
      eventLogMessage.setFacilityCd(request.getFacilityCd());
      eventLogMessage.setInvokeClass(this.getClass().getName());
      eventLogMessage.setLogMessage("応答待ちのエッジヘルスモニタ更新処理の呼び出しでエラーが発生しました。Message:" + e.getMessage());
      logService.log(LogLevel.WARN, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(eventLogMessage.getLogMessage());
    }
    return result;
  }
  /* modify by zhangruixue 2023-01-30 [Transaction,CodeOptimization] --end */

  /**
   * 連携オーダ番号を採番する
   *
   * @param curSysCoopNoCtlNo - 連携オーダ番号の管理番号
   * @param journal           - {@link SysCoopJournal journal}
   * @return 連携オーダ番号
   */
  private String getNewCoopOrdNo(Long curSysCoopNoCtlNo, SysCoopJournal journal) {
    String coopOrdNo = "";
    String coopOrdNoCheck = "";
    Long updateByCurCoopOrdNo = null;
    boolean isNeedSaiban = true;

    // add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    // 連携版番号
    String coopVersion = StringUtils.isEmpty(journal.getCoopVersion()) ? "" : journal.getCoopVersion();
    // add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    // 3.1.1. 1の処理で取得したctl_noをキーにしてsys_coop_noを取得する(forupdate)
    SysCoopNo curSysCoopNo = sysCoopNoDao.selectByCtlNo(curSysCoopNoCtlNo);

    while (isNeedSaiban) {
      // 3.1.2. 現在の連携オーダ番号シーケンスを+1する
      if (updateByCurCoopOrdNo == null) {
        updateByCurCoopOrdNo = curSysCoopNo.getCurCoopOrdNo() + 1;
      } else {
        updateByCurCoopOrdNo++;
      }

      // 3.1.3. 上記結果が最大値を超えた場合には最小値に設定する
      if (updateByCurCoopOrdNo > curSysCoopNo.getRangeMax()) {
        updateByCurCoopOrdNo = curSysCoopNo.getRangeMin();
      }
      // 3.1.4. 連携オーダ番号、パディング文字、位置、前置文字、後置文字等を用いて連携オーダ番号（文字列）を作成する
      StringBuilder coopOrdNoSb = new StringBuilder();
      // 前置文字
      // #4042対応 2021/04/08 start
      if (curSysCoopNo.getPrefixChar() != null) {
        coopOrdNoSb.append(curSysCoopNo.getPrefixChar());
      }
      // パティングした文字
      coopOrdNoSb.append(padding(String.valueOf(updateByCurCoopOrdNo), curSysCoopNo.getNoOfDigit(), curSysCoopNo.getPaddingChar(), curSysCoopNo.getPaddingPos()));
      // 後置文字
      if (curSysCoopNo.getSuffixChar() != null) {
        coopOrdNoSb.append(curSysCoopNo.getSuffixChar());
      }
      // #4042対応 2021/04/08 end

      coopOrdNo = coopOrdNoSb.toString();

      // 資源の枯渇を判断する
      if (coopOrdNo.equals(coopOrdNoCheck)) {
        String error = String.format("連携オーダ番号を採番する時、使用できる番号がなくなりました。pat_id:[%s]",
            journal.getPatId());
        outputErrorLog(journal.getFacilityCd(), error);
        throw new NtssException(error);
      }
      // 最初の番号を保存します。
      if (StringUtils.isEmpty(coopOrdNoCheck)) {
        coopOrdNoCheck = coopOrdNo;
      }

      // 3.1.5. 以下のsqlを発行し、結果が0件でない場合には3.1.2に戻り処理を繰り返す
      // mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
      // // mod 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 start
////      List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndCoopOrdNo(journal.getPatId(), coopOrdNo);
//      List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndCoopOrdNo(journal.getFacilityCd(), journal.getPatId(), journal.getHospPatId(), coopOrdNo);
      // // mod 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 end
      List<OrdCoopNo> ordCoopNoList = ordCoopNoDao.selectByPatIdAndCoopOrdNo(journal.getFacilityCd(), coopVersion,
          journal.getPatId(), journal.getHospPatId(), coopOrdNo);
      // mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      if (ordCoopNoList.isEmpty()) {
        isNeedSaiban = false;
        Timestamp now = new Timestamp(clockWrapper.getClockMillis());

        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260401 del yangxuewang start
//        // DB更新ログ出力ロジック wangzuo Start
//        String tableNameSys = "sys_coop_no";
//        // SQL検索条件
//        StringBuffer wheresSys = new StringBuffer("");
//        wheresSys.append(" WHERE\n");
//        wheresSys.append(" ctl_no = " + curSysCoopNoCtlNo + "\n");
//
//        // logCommon設定
//        DataUpdateLogCommonNew logCommonSys = getLogCommon(tableNameSys, wheresSys, getEventLogMessage());
//        // ログ出力カラム情報及び更新前データ情報取得
//        boolean setResultSys = logCommonSys.setInfo();
//        // DB更新ログ出力ロジック wangzuo End
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260401 del yangxuewang end

        // 3.1.6. sys_coop_noをupdateする(対象カラム: cur_coop_ord_no )
        int updateCountSys = sysCoopNoDao.updateCurCoopOrdNo(updateByCurCoopOrdNo, curSysCoopNoCtlNo, now);

        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260401 del yangxuewang start
//        // DB更新ログ出力ロジック wangzuo Start
//        // 更新後データ取得、差分あれば、log出力
//        if (setResultSys && updateCountSys > 0) {
//          logCommonSys.updateLog();
//        }
//        // DB更新ログ出力ロジック wangzuo End
//
//        // DB更新ログ出力ロジック wangzuo Start
//        String tableNameOrd = "ord_coop_no";
//        // SQL検索条件
//        StringBuffer wheresOrd = new StringBuffer("");
//        wheresOrd.append(" WHERE\n");
//        wheresOrd.append(" pat_id = " + journal.getPatId() + "\n");
//        wheresOrd.append(" AND\n");
//        wheresOrd.append(" ord_no = " + journal.getOrdNo() + "\n");
//        wheresOrd.append(" AND\n");
//        wheresOrd.append(" coop_cd = '" + journal.getCoopCd() + "'\n");
//        /* add by chamaojia 2023-05-16 [8637] クエリー条件を追加してインデックス効率を向上 --start */
//        wheresOrd.append(" AND\n");
//        wheresOrd.append(" facility_cd = '" + journal.getFacilityCd() + "'\n");
//        /* add by chamaojia 2023-05-16 [8637] クエリー条件を追加してインデックス効率を向上 --end */
//        wheresOrd.append(" AND\n");
//        wheresOrd.append(" (is_del = '0' OR is_disp = '1')" + "\n");
//        wheresOrd.append(" AND\n");
//        wheresOrd.append(" coop_ord_no = '" + coopOrdNo + "'\n");
//
//        // logCommon設定
//        DataUpdateLogCommonNew logCommonOrd = getLogCommon(tableNameOrd, wheresOrd, getEventLogMessage());
//        // ログ出力カラム情報及び更新前データ情報取得
//        boolean setResultOrd = logCommonOrd.setInfo();
//        // DB更新ログ出力ロジック wangzuo End
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260401 del yangxuewang end

        // 3.1.7. ord_coop_noをupdateする(pat_id, ord_no, coop_cdをキー)
        // update deleteflg 1 viewFlg 0
        // mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
        // // mod 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 start
////        int updateCountOrd = ordCoopNoDao.updateIsDelIsDisp(journal.getPatId(), journal.getOrdNo(), journal.getCoopCd(), now);
//        int updateCountOrd = ordCoopNoDao.updateIsDelIsDisp(journal.getPatId(), journal.getHospPatId(), journal.getOrdNo(), journal.getCoopCd(), now);
        // // mod 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 end
        /* modify by chamaojia 2023-05-16 [8637] クエリー条件を追加してインデックス効率を向上 --start */
        int updateCountOrd = ordCoopNoDao.updateIsDelIsDisp(journal.getPatId(), journal.getHospPatId(),
          journal.getOrdNo(), journal.getCoopCd(), coopVersion, now
                , journal.getFacilityCd(), coopOrdNo);
        /* modify by chamaojia 2023-05-16 [8637] クエリー条件を追加してインデックス効率を向上 --end */
        // mod 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260401 del yangxuewang start
//        // DB更新ログ出力ロジック wangzuo Start
//        // 更新後データ取得、差分あれば、log出力
//        if (setResultOrd && updateCountOrd > 0) {
//          logCommonOrd.updateLog();
//        }
//        // DB更新ログ出力ロジック wangzuo End
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260401 del yangxuewang end

        OrdCoopNo ordCoopNo = new OrdCoopNo();
        ordCoopNo.setCtlNo(ordCoopNoDao.selectNextSeqCtlNo());
        ordCoopNo.setFacilityCd(journal.getFacilityCd());
        ordCoopNo.setPatId(journal.getPatId());
        // add 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 start
        ordCoopNo.setHospPatId(journal.getHospPatId());
        // add 2021-04-13 連携オーダ番号の患者番号（連携用）を追加 孫 end
        ordCoopNo.setOrdNo(journal.getOrdNo());
        ordCoopNo.setCoopCd(journal.getCoopCd());
        ordCoopNo.setCoopOrdNo(coopOrdNo);
        ordCoopNo.setUserId(journal.getUserId());
        ordCoopNo.setRegDate(now);
        ordCoopNo.setUpDate(now);
        // add 2021-09-30 #6549:連携オーダ番号管理テーブルにてステータスがnullのデータが発生している 孫 start
        ordCoopNo.setStatus("0");
        // add 2021-09-30 #6549:連携オーダ番号管理テーブルにてステータスがnullのデータが発生している 孫 end
        // add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
        ordCoopNo.setCoopVersion(coopVersion);
        // add 2022-12-14 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        // 3.1.8. ord_coop_noをinsertする
        ordCoopNoDao.insert(ordCoopNo);
      }
    }
    return coopOrdNo;
  }
  // add 2021-03-30 課題No.37:オーダ番号につてい 孫 end

  /**
   * Padding対応
   *
   * @param target     - Padding対象
   * @param itemLength - Paddingする桁数
   * @param format     パディング文字
   * @param position   パディングする位置(left : 左、right : 右)
   * @return Paddingされた文字列
   */
  private String padding(String target, long itemLength, String format, String position) {
    long formatedLength = itemLength - target.getBytes().length;
    // add 2022-01-28 #7060:profile連携のイベントでエラーが発生する 孫 start
    if (formatedLength <= 0) {
      return target;
    }
    // add 2022-01-28 #7060:profile連携のイベントでエラーが発生する 孫 end
    // 半角スペース×桁数で文字列用意
    String paddingByDefaultFormat = "%".concat(String.valueOf(formatedLength)).concat("s");
    String paddingByDefault = String.format(paddingByDefaultFormat, " ");

    // パディング文字なし：０パディング、パディング文字がある場合にはパディング文字でパディングする
    String paddingOnly = StringUtils.isEmpty(format) ? paddingByDefault.replace(" ", "0") : paddingByDefault.replace(" ", format);
    return position.equals("left") ? paddingOnly.concat(target) : target.concat(paddingOnly);
  }

  // mod 2022-11-08 bug #7113 rep_dial連携の処理タイミングがずれる 孫 start
  // // add 2021-04-21 外部連携:レポートが有り場合、データ作成の変更 孫 start
  // /**
  // * sys_coop_journalへ登録
  // *
  // * @param request {@link JournalCreateRequest} リクエスト
  // * @param journals 外部連携用ジャーナルのリスト
  // * @return 登録結果のリスト
  // */
  // @Transactional
//  public List<SysCoopJournal> updateSysCoopJournalListForDump(JournalCreateRequest request, List<SysCoopJournal> journals) {
  //
  // // mod 2022-10-19 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  //// // ファイル出力対象ジャーナルのシーケンスNoを取得
  //// String journalCtlNo = "";
  //// for (SysCoopJournal journal : journals) {
  //// // CoopCdIndexがpdfかtar以外の場合、スキップする
  //// if (!ReportType.PDF.getType().equals(journal.getCoopCdIndex())
  //// && !ReportType.TAR.getType().equals(journal.getCoopCdIndex())) {
  //// continue;
  //// }
  //// journalCtlNo = String.valueOf(journal.getCtlNo());
  //// }
  ////
  //// List<SysCoopJournal> journalsUpdated = new ArrayList<>();
  //// // 帳票作成
  //// ReportPath report = null;
  //// String message = null;
  //// try {
  //// report = createReport(request, journalCtlNo);
  //// } catch (Exception ex) {
  //// message = ex.getMessage();
  //// }
  ////
  //// for (SysCoopJournal journal : journals) {
  //// // pdfとtar以外の場合、更新しません。
  //// if (!ReportType.PDF.getType().equals(journal.getCoopCdIndex())
  //// && !ReportType.TAR.getType().equals(journal.getCoopCdIndex())) {
  //// journalsUpdated.add(journal);
  //// continue;
  //// }
  ////
  //// // レポート作成に失敗の場合
  //// if (report == null) {
  //// journal.setAnaResult(AnaResult.INTERNAL_ERROR.getResult());
  //// journal.setMessage(message);
  //// } else {
  //// // レポート作成の場合
  //// journal.setReportCd(report.getReportCd());
  //// journal.setDumpPath(report.getDumpPath());
  //// }
  ////
  //// // リクエストを複製
  //// JournalUpdateRequest updateRequest = new JournalUpdateRequest();
  //// BeanUtils.copyProperties(journal, updateRequest);
  ////
  ////// add 2021-10-09 #6188：レポート連携PDFファイルの出力に失敗する 孫 start
  //// // [dump is undefined in response]問題を修正する
  //// updateRequest.setCoopResult(String.valueOf(NtssCoopApiConstants.CoopResult.UNPROCESS.getResult()));
  ////// add 2021-10-09 #6188：レポート連携PDFファイルの出力に失敗する 孫 end
  //// SysCoopJournal journalNew = update(updateRequest);
  //// journalsUpdated.add(journalNew);
  //// }
  //
  // List<SysCoopJournal> journalsUpdated = new ArrayList<>();
  //
  // // ファイル出力対象ジャーナルのシーケンスNoを取得
  // for (SysCoopJournal journal : journals) {
  // // CoopCdIndexがpdf,nkkpdf,necpdfとtar以外の場合、スキップする
  // if (!ReportType.PDF.getType().equals(journal.getCoopCdIndex())
  // && !(NKK + ReportType.PDF.getType()).equals(journal.getCoopCdIndex())
  // && !(NEC + ReportType.PDF.getType()).equals(journal.getCoopCdIndex())
  // && !ReportType.TAR.getType().equals(journal.getCoopCdIndex())) {
  // journalsUpdated.add(journal);
  // continue;
  // }
  // String journalCtlNo = String.valueOf(journal.getCtlNo());
  //
  // // 帳票作成
  // ReportPath report = null;
  // String message = null;
  // try {
  // report = createReport(request, journalCtlNo);
  // } catch (Exception e) {
  // message = "帳票生成に失敗しました。" + e.getMessage();
  // StackTraceElement[] list = null;
  // String errAdd = "";
  // if (e.getCause() != null && e.getCause().getStackTrace() != null
  // && e.getCause().getStackTrace().length > 0) {
  // list = e.getCause().getStackTrace();
  // for (StackTraceElement err : list) {
  // if (err != null && err.toString().startsWith("jp.co.")) {
  // errAdd = errAdd + "\r\n" + err.toString();
  // }
  // }
  // }
  // if (StringUtils.isEmpty(errAdd)) {
  // list = e.getStackTrace();
  // for (StackTraceElement err : list) {
  // if (err != null && err.toString().startsWith("jp.co.")) {
  // errAdd = errAdd + "\r\n" + err.toString();
  // }
  // }
  // }
  // message = message + errAdd;
  // outputErrorLog(journal.getFacilityCd(), message);
  // }
  //
  // // レポート作成に失敗の場合
  // if (report == null) {
  // journal.setAnaResult(AnaResult.INTERNAL_ERROR.getResult());
  // journal.setMessage(message);
  // } else {
  // // レポート作成の場合
  // journal.setReportCd(report.getReportCd());
  // journal.setDumpPath(report.getDumpPath());
  // }
  //
  // // リクエストを複製
  // JournalUpdateRequest updateRequest = new JournalUpdateRequest();
  // BeanUtils.copyProperties(journal, updateRequest);
  //
  // updateRequest.setCoopResult(String.valueOf(NtssCoopApiConstants.CoopResult.UNPROCESS.getResult()));
  // SysCoopJournal journalNew = update(updateRequest);
  // journalsUpdated.add(journalNew);
  // }
  // // add 2022-10-19 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  //
  // return journalsUpdated;
  // }
  // // add 2021-04-21 外部連携:レポートが有り場合、データ作成の変更 孫 end

  /**
   * 帳票作成待ちデータの場合、帳票データを作成する
   *
   * @param journal 外部連携用ジャーナル
   * @return {@link SysCoopJournal}
   */
  public SysCoopJournal createJournalReportDump(SysCoopJournal journal) {
    // ファイル出力対象ジャーナルのシーケンスNoを取得
    String journalCtlNo = String.valueOf(journal.getCtlNo());

    // 帳票作成
    ReportPath report = null;
    String message = null;
    try {
      // リクエストを複製
      JournalCreateRequest request = new JournalCreateRequest();
      BeanUtils.copyProperties(journal, request);

      // #8222-rep_dial連携で送信されるPDFの内容が文字化けで読めない 周 mod start
      // report = createReport(request, journalCtlNo);
      report = createReport(request, journalCtlNo, journal);
      // #8222-rep_dial連携で送信されるPDFの内容が文字化けで読めない 周 mod end
    } catch (Exception e) {
      message = String.format("%s %s", StringUtils.isEmpty(e.getMessage()) ? "帳票生成に失敗しました。" : e.getMessage(), getAddExceptionError(e));
      outputErrorLog(journal.getFacilityCd(), message);
      throw new NtssException(message);
    }

    // レポート作成の場合
    journal.setReportCd(report.getReportCd());
    journal.setDumpPath(report.getDumpPath());

    return journal;
  }

  private String getAddExceptionError(Exception e) {
    StackTraceElement[] list = null;
    String errAdd = "";
    if (e.getCause() != null && e.getCause().getStackTrace() != null
        && e.getCause().getStackTrace().length > 0) {
      list = e.getCause().getStackTrace();
      for (StackTraceElement err : list) {
        if (err != null && err.toString().startsWith("jp.co.")) {
          errAdd = errAdd + "\r\n" + err.toString();
        }
      }
    }
    if (StringUtils.isEmpty(errAdd)) {
      list = e.getStackTrace();
      for (StackTraceElement err : list) {
        if (err != null && err.toString().startsWith("jp.co.")) {
          errAdd = errAdd + "\r\n" + err.toString();
        }
      }
    }
    return errAdd;
  }
  // mod 2022-11-08 bug #7113 rep_dial連携の処理タイミングがずれる 孫 end

  /**
   * sys_coop_journalへ登録
   *
   * @param request     {@link JournalCreateRequest} リクエスト
   * @param report      {@link ReportPath} レポートコードと電文パス
   * @param isGetNo     ジャーナル作成時受付番号の採番可否
   * @param isCoopOrdNo オーダ番号連携処理の実行可否
   * @return 登録結果
   */
  private SysCoopJournal insertSysCoopJournal(JournalCreateRequest request, ReportPath report, boolean isGetNo, boolean isCoopOrdNo) {

    // add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    // 電子カルテ種別
    String key0 = StringUtils.isEmpty(request.getKey0()) ? "" : request.getKey0();
    // 連携版番号
    String coopVersion = StringUtils.isEmpty(request.getCoopVersion()) ? "" : request.getCoopVersion();
    // add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    Long ordNo = request.getOrdNo() == null ? 0L : request.getOrdNo();
    Long patId = request.getPatId() == null ? 0L : request.getPatId();
    // mod 2020-12-09 FNSI-改修 外部連携727 夏 start
    //String coopOrdNo = StringUtils.isEmpty(request.getCoopOrdNo()) ? "0" : request.getCoopOrdNo();
    String coopOrdNo = null;
    if (JournalConvertConstants.DIRECTION_RECEIVE.equals(request.getDirection())) {
      coopOrdNo = StringUtils.isEmpty(request.getCoopOrdNo()) ? "0" : request.getCoopOrdNo();
    }
    // mod 2020-12-09 FNSI-改修 外部連携727 夏 end
    String hospPatId = StringUtils.isEmpty(request.getHospPatId()) ? "0" : request.getHospPatId();
    // mod 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
//    String opeId = StringUtils.isEmpty(request.getOpeId()) ? "0" : request.getOpeId();
    String opeCd = StringUtils.isEmpty(request.getOpeCd()) ? "0" : request.getOpeCd();
    // mod 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end

    SysCoopJournal journal = new SysCoopJournal();
    journal.setFacilityCd(request.getFacilityCd());
    journal.setCtlNo(sysCoopJournalDao.selectNextSeqCtlNo());
    journal.setCoopCd(request.getCoopCd());
    journal.setCoopCdIndex(request.getCoopCdIndex());
    journal.setCrud(request.getCrud());
    journal.setDirection(request.getDirection());
    journal.setOrdNo(ordNo);
    journal.setCoopOrdNo(coopOrdNo);
    journal.setHospPatId(hospPatId);
    journal.setPatId(patId);
    journal.setAnaResult(request.getAnaResult());
    // mod 2021-10-09 #6188：レポート連携PDFファイルの出力に失敗する 孫 start
    // journal.setCoopResult(request.getCoopResult());
    if (ReportType.PDF.getType().equals(journal.getCoopCdIndex())
        // add 2022-10-19 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
        || (NKK + ReportType.PDF.getType()).equals(journal.getCoopCdIndex())
        || (NEC + ReportType.PDF.getType()).equals(journal.getCoopCdIndex())
        // add 2022-10-19 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        || ReportType.TAR.getType().equals(journal.getCoopCdIndex())) {
      // mod 2022-11-08 bug #7113 rep_dial連携の処理タイミングがずれる 孫 start
      // journal.setCoopResult(String.valueOf(NtssCoopApiConstants.CoopResult.PROCESSING.getResult()));
      journal.setCoopResult(request.getCoopResult());
      // mod 2022-11-08 bug #7113 rep_dial連携の処理タイミングがずれる 孫 end
    } else {
      journal.setCoopResult(request.getCoopResult());
    }
    // mod 2021-10-09 #6188：レポート連携PDFファイルの出力に失敗する 孫 end
    if (report != null) {
      journal.setReportCd(report.getReportCd());
      journal.setDumpPath(report.getDumpPath());
    }
    if (request.getMessage64() != null) {
      journal.setDump(Base64.getDecoder().decode(request.getMessage64().getBytes()));
    }
    journal.setUserId(request.getUserId());

    // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 start
    // 操作番号
    journal.setOpeCd(opeCd);
    // add 2020-12-25 No.716：IFエッジ、変換処理ステータス、配信処理ステータスはエラーの場合、通知処理を行う。 孫 end

    // 基準日を設定する。
    // mod 2020-10-13 FNSI-改修 外部連携276 夏 start
    //String strBaseDate =DateUtil.convertDateStr(DateUtil.convertDateToStringFormat(request.getBaseDate()));

    //journal.setBaseDate(strBaseDate == null ? null : Timestamp.valueOf(strBaseDate));
    journal.setBaseDate(request.getBaseDate());
    // mod 2020-10-13 FNSI-改修 外部連携276 夏 end
    if (!StringUtils.isEmpty(request.getMessage())) {
      journal.setMessage(request.getMessage());
    }
    // add 2021-06-17 #5261:TSHPlusにおけるデータのジャーナル反映について 孫 end
    // リクエスト上の通信もしくは配信ステータスが、開始("1")もしくは終了("9")を指定されたら
    // 開始ステータスであれば開始日時。終了ステータスであれば終了日時を入れる
    Timestamp now = new Timestamp(clockWrapper.getClockMillis());
    if (CoopResult.PROCESSING.isSameResult(request.getCoopResult())) {
      journal.setInRegDate(now);
    } else if (CoopResult.DONE.isSameResult(request.getCoopResult())) {
      journal.setOutRegDate(now);
    }

    // add 2021-06-17 #5261:TSHPlusにおけるデータのジャーナル反映について 孫 start
    // 向き（送受信）が受信、かつ、IFEdge(userId==null,-1)、CoopResultがnull以外の場合、受信データのCoopResultを利用する
    if (JournalConvertConstants.DIRECTION_RECEIVE.equals(request.getDirection())
        && (request.getUserId() != null && request.getUserId().longValue() == -1)) {
      journal.setInRegDate(now);
      journal.setOutRegDate(now);
    }
    // add 2021-06-17 #5261:TSHPlusにおけるデータのジャーナル反映について 孫 end

    if (AnaResult.PROCESSING.isSameResult(request.getAnaResult())) {
      journal.setInAnaDate(now);
    } else if (AnaResult.DONE.isSameResult(request.getAnaResult())) {
      journal.setOutAnaDate(now);
    }

    // add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    journal.setKey0(key0);
    journal.setCoopVersion(coopVersion);
    // add 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    // del 2020-12-09 FNSI-改修 外部連携727 夏 start
    // if (isCoopOrdNo) {
    // //オーダ番号連携処理を行う
    // executeCoopOrdNoProc(journal);
    // }
    // del 2020-12-09 FNSI-改修 外部連携727 夏 end

    // 受付番号採番可否が可の場合、受付番号を採番してaccept_noに設定する。
    if (isGetNo) {
      // mod #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 start
//      Long acceptNo = sysDailyNoService.numberingReception(request.getFacilityCd(), request.getCoopCd(), request.getBaseDate());
      journal.setAcceptNo(request.getAcceptNo());
      // mod #10311 DBが高負荷になる（外部連携由来） zhaoqi 20240220 end
    }
    // #8348 profile連携の定時処理で作成されたjournalが処理されない 2023-02-11 卓 ---start
    if (journal.getBaseDate() != null) {
      try {
        DateFormat dateFormat = new SimpleDateFormat("yyyyMMdd");
        dateFormat.parse(journal.getBaseDate());

      } catch (ParseException e) {
        journal.setBaseDate(JournalConstant.BASEDATE_DEFAULT);
        journal.setMessage(JournalConstant.BASEDATE_ERROR_MESSAGE);
        journal.setAnaResult(AnaResult.INTERNAL_ERROR.getResult());
        journal.setInAnaDate(new Timestamp(clockWrapper.getClockMillis()));
        journal.setOutAnaDate(new Timestamp(clockWrapper.getClockMillis()));
        EventLogMessage eventLogMessageBaseDate = new EventLogMessage();
        eventLogMessageBaseDate.setLogMessage(JournalConstant.BASEDATE_ERROR_MESSAGE);
        logService.log(LogLevel.INFO, eventLogMessageBaseDate, null, SERVICE_NAME.FNSI, null);
      }
    }
    // #8348 profile連携の定時処理で作成されたjournalが処理されない 2023-02-11 卓 ---end
    sysCoopJournalDao.insert(journal);

    return journal;
  }

  /**
   * sys_coop_journalへ登録
   *
   * @param request       {@link JournalCreateRequest} リクエスト
   * @param report{{@link ReportPath}} レポートコードと電文パス レポートコードと電文パス
   * @param isGetNo       ジャーナル作成時受付番号の採番可否
   * @param isCreateIndex data,indexがセットになった電文か否か
   * @return 登録結果のリスト
   */
  private List<SysCoopJournal> insertSysCoopJournalList(JournalCreateRequest request, ReportPath report
    , boolean isGetNo, boolean isCreateIndex) {

    List<SysCoopJournal> journals = new ArrayList<>();
    SysCoopJournal journal = insertSysCoopJournal(request, report, isGetNo, true);
    journals.add(journal);

    if (isCreateIndex) {
      JournalCreateRequest jcr = new JournalCreateRequest();
      BeanUtils.copyProperties(request, jcr);

      // インデックスのsys_coop_journalを追加
      jcr.setCoopCdIndex("index");
      SysCoopJournal indexJournal = insertSysCoopJournal(jcr, report, isGetNo, false);
      journals.add(indexJournal);
    }
    return journals;
  }

  /**
   * レポート共有機能向けsys_coop_journal登録
   *
   * @param request       {@link JournalCreateRequest} リクエスト
   * @param isGetNo       ジャーナル作成時受付番号の採番可否
   * @param isCreateIndex data,indexがセットになった電文か否か
   * @param reportType    {@link ReportType} レポートタイプ
   * @return 登録結果
   */
  private List<SysCoopJournal> insertSysCoopJournalXmlPdf(JournalCreateRequest request, boolean isGetNo,
      boolean isCreateIndex, ReportType reportType) {

    List<SysCoopJournal> journals = new ArrayList<>();
    JournalCreateRequest jcr = new JournalCreateRequest();
    // リクエストを複製
    BeanUtils.copyProperties(request, jcr);
    if (reportType.equals(ReportType.NKK_REP)) {
      jcr.setCoopCdIndex(NKK + ReportType.XML.getType());
    } else if (reportType.equals(ReportType.NEC_REP)) {
      jcr.setCoopCdIndex(NEC + ReportType.XML.getType());
    } else {
      jcr.setCoopCdIndex(ReportType.XML.getType());
    }
    List<SysCoopJournal> list = insertSysCoopJournalList(jcr, null, isGetNo, isCreateIndex);
    journals.addAll(list);
    if (ReportType.XML_PDF.equals(reportType) || ReportType.NKK_REP.equals(reportType)) {
      if (reportType.equals(ReportType.NKK_REP)) {
        jcr.setCoopCdIndex(NKK + "list" + ReportType.XML.getType());
      } else {
        jcr.setCoopCdIndex("list" + ReportType.XML.getType());
      }
      list = insertSysCoopJournalList(jcr, null, isGetNo, isCreateIndex);
      journals.addAll(list);
    }
    ReportPath report = null;
    if (reportType.equals(ReportType.NKK_REP)) {
      jcr.setCoopCdIndex(NKK + ReportType.PDF.getType());
    } else if (reportType.equals(ReportType.NEC_REP)) {
      jcr.setCoopCdIndex(NEC + ReportType.PDF.getType());
    } else {
      jcr.setCoopCdIndex(ReportType.PDF.getType());
    }
    list = insertSysCoopJournalList(jcr, report, isGetNo, isCreateIndex);
    journals.addAll(list);

    return journals;
  }

  /**
   * レポート作成
   *
   * @param request      {@link JournalCreateRequest} リクエスト
   * @param journalCtlNo ジャーナルのシーケンスNo (ファイル名重複対策に、作成ファイル名の先頭に追加する)
   * @return 作成したPDFファイルのパス
   */
  // #8222-rep_dial連携で送信されるPDFの内容が文字化けで読めない 周 mod start
  //private ReportPath createReport(JournalCreateRequest request, String journalCtlNo) {
  private ReportPath createReport(JournalCreateRequest request, String journalCtlNo, SysCoopJournal journal) {
    // #8222-rep_dial連携で送信されるPDFの内容が文字化けで読めない 周 mod end

    // オーダ番号からテンプレートのレポートIDを取得
    Long reportCd = getTemplateReportCd(request.getFacilityCd(), request.getOrdNo());

    // 帳票作成するためのデータ抽出キーを作成
    Map<String, Object> dataKey = createDataKey(request);

    // 帳票情報(HTML)の取得
    // #8222-rep_dial連携で送信されるPDFの内容が文字化けで読めない 周 mod start
    // String html = reportService.getReportHtml(reportCd, dataKey, null, null);
    // if (StringUtils.isEmpty(html)) {
    // String error = String.format("帳票情報の作成に失敗しました。report_id:[%s]", reportCd);
    // outputErrorLog(request.getFacilityCd(), error);
    // throw new NtssException(error);
    // }

    // ファイル名作成
    // String pdfName = getReportName(request);
    //
    // // html→PDFに変換して保存
//    reportService.convertHtmlToPdfOutputTmp(html, createJournalTmp, journalCtlNo + "_" + pdfName);

    // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
//    MstMedicine mstMedicine = new MstMedicine();
//    mstMedicine.setFacilityCd(request.getFacilityCd());
    // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
    // del #8222-rep_dial連携で送信されるPDFの内容が文字化けで読めない 孟堅　start
    // マスタ取得処理
    // SelectOptions selectOptions = SelectOptions.get();
    //List<MstMedicine> mstMedicineList = mstMedicineDao.selectAll(selectOptions, mstMedicine);

    // MstDialyzer mstDialyzer = new MstDialyzer();
    // mstDialyzer.setFacilityCd(request.getFacilityCd());
    // マスタ取得処理
    //List<MstDialyzer> mstDialyzerList = mstDialyzerDao.selectAll(selectOptions, mstDialyzer);

    // MstEquipment mstEquipment = new MstEquipment();
    // mstEquipment.setFacilityCd(request.getFacilityCd());
    // マスタ取得処理
    //List<MstEquipment> mstEquipmentList = mstEquipmentDao.selectAll(selectOptions, mstEquipment);
    // del #8222-rep_dial連携で送信されるPDFの内容が文字化けで読めない　孟堅 　end
    // mod #8222-rep_dial連携で送信されるPDFの内容が文字化けで読めない　孟堅 　start
    // dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,mstMedicineList);
    // dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,mstDialyzerList);
    // dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,mstEquipmentList);
    // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
//    Map<String, List> searchList = searchMap(request.getFacilityCd());
//    dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS, searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
//    dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS, searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
//    dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
    // del #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
    // mod #8222-rep_dial連携で送信されるPDFの内容が文字化けで読めない　孟堅 　end

    Long ordNo = Long.parseLong(dataKey.get(ReportDataKey.ORD_NO).toString());
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, ordMain.getRstMachineNo());
    // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
    dataKey.putAll(searchReportSettingForDataKey(String.valueOf(dataKey.getOrDefault(ReportConstant.ReportDataKey.FACILITY_CD, "")), reportCd, dataKey));
    // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end

    journal.setReportCd(reportCd);
    Map<String, String> fileNames = convertSendCommonService.getFileNames(journal);

    String pdfName = fileNames.get(ConvertSendCommonServiceImpl.FileNames.PDF_NAME.getKey());
    if (org.apache.commons.lang3.StringUtils.isEmpty(pdfName)) {
      String error = "ファイル名が取得できませんでした。";
      outputErrorLog(journal.getFacilityCd(), error);
      throw new NtssException(error);
    }
    // del 9316 施設設定マスタ125番の削除について　吉 start
    // boolean isUseAsposeCells = true;
//    FacilitySettingInfo settingValue = mstFacilitySettingDao.getBySettingNoAndCd(request.getFacilityCd(),CoreConstant.FacilitySettingNo.PREVIEW_MODE);
    // if(settingValue != null && settingValue.getValue().equals("1")){
    // isUseAsposeCells = false;
    // }
    // if(isUseAsposeCells){
      // del 9316 施設設定マスタ125番の削除について　吉 end
    try {
      String fileName = journalCtlNo + "_" + pdfName;
      if (!fileName.matches(".+\\.pdf$")) {
        fileName += fileName + ".pdf";
      }
      Path pdfPath = Paths.get(createJournalTmp, fileName);
      if (!Files.exists(pdfPath)) {
        Files.createDirectories(pdfPath.getParent());
        File file = new File(pdfPath.toString());
        file.createNewFile();
      }
      // mod #12127 透析レポート連携のPDFに一部出力されない項目がある sunsy start
      // byte[] excelResult = reportService.getReportExcelFile(reportCd, dataKey);
      byte[] excelResult = new byte[0];
      MstReport mstReport = mstReportDao.selectByCd(reportCd);
      if (mstReport.getReportClass().equals(ReportConstant.ReportClass.DIALYSIS_REPORT)) {
          // add #12299 【因島】NKK連携 rep_dial pdfのana_resuletがタイムアウトによりE1でエラーとなりPDFの送信ができないことがある 吉 start
        dataKey.put("channel", "journal");
          // add #12299 【因島】NKK連携 rep_dial pdfのana_resuletがタイムアウトによりE1でエラーとなりPDFの送信ができないことがある 吉 end
        excelResult = reportService.getReportExcelFileForDialysisReport(reportCd, dataKey);
      } else if (mstReport.getReportClass().equals(ReportConstant.ReportClass.ONE_PATIENT_REPORT)) {
        Map<String, Object> searchInfo = new HashMap<>();
        excelResult = reportForOnePatientService.getReportExcelFileForOnePatient(reportCd, dataKey, searchInfo);
      } else if (mstReport.getReportClass().equals(ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT)) {
        excelResult = reportService.getReportExcelFileForMultiPatient(reportCd, dataKey);
      } else if (mstReport.getReportClass().equals(ReportConstant.ReportClass.PREPARATION_LIST_REPORT)) {
        excelResult = reportService.getReportExcelFileForPreparationList(reportCd, dataKey);
      } else if (mstReport.getReportClass().equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT)) {
        // mod #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
        //excelResult = reportService.getReportExcelFileForDistributionListBed(reportCd, dataKey);
        excelResult = reportForDistributionListService.getReportExcelFileForDistributionListBed(reportCd, dataKey);
        // mod #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end
      } else if (mstReport.getReportClass().equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_GOODS_REPORT)) {
        // mod #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
        //excelResult = reportService.getReportExcelFileForDistributionListGoods(reportCd, dataKey);
        excelResult = reportForDistributionListService.getReportExcelFileForDistributionListGoods(reportCd, dataKey);
        // mod #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end
      }
      // add #11117 日常点検記録簿が1ページ1装置で出力される limingzhe start
      else if (mstReport.getReportClass().equals(ReportConstant.ReportClass.MACHINE_REPORT)) {
        excelResult = reportForMachineReportService.getReportExcelFileForMachineReport(reportCd, dataKey);
      }
      // add #11117 日常点検記録簿が1ページ1装置で出力される limingzhe end
      else if (mstReport.getReportClass().equals(ReportConstant.ReportClass.LABEL_REPORT)) {
        // mod #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
        //excelResult = reportService.getReportExcelFileForLabelReport(reportCd, dataKey);
        excelResult = reportForLabelReportService.getReportExcelFileForLabelReport(reportCd, dataKey);
        // mod #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end
      } else if (mstReport.getReportClass().equals(ReportConstant.ReportClass.INTRODUCTION_REPORT)) {
          // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
          if(mstReport.getReportType() == 1){
            excelResult = reportForTotalService.getReportExcelFileForIntroductionReport(reportCd, dataKey);
          }
          else{
          // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
        excelResult = reportForIntroductionReportService.getReportExcelFileForIntroductionReport(reportCd, dataKey);
          // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
          }
          // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
      } else if (mstReport.getReportClass().equals(ReportConstant.ReportClass.ONE_TOTAL_REPORT)) {
        // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
        // excelResult = reportService.getReportExcelFileForOneTotal(reportCd, dataKey);
        excelResult = reportForTotalService.getReportExcelFileForOneTotal(reportCd, dataKey);
        // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end
      } else if (mstReport.getReportClass().equals(ReportConstant.ReportClass.MULTI_TOTAL_REPORT)) {
        // mod #11973 日常点検一覧帳票が正常に出せない limingzhe start
          //excelResult = reportForMultiTotalService.getReportExcelFileForMultiTotal(reportCd, dataKey);
        excelResult = reportForTotalService.getReportExcelFileForMultiTotal(reportCd, dataKey);
        // mod #11973 日常点検一覧帳票が正常に出せない limingzhe end
      }
      // mod #12127 透析レポート連携のPDFに一部出力されない項目がある sunsy end
      if (!(excelResult == null || excelResult.length == 0)) {
        ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelResult);
        FileOutputStream fileOutputStream = new FileOutputStream(pdfPath + "");
        ByteArrayOutputStream byteArrayOutputStream = new ByteArrayOutputStream();
        try {
          URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
          AsposeCellsUtils.excelToPdf(byteArrayInputStream, byteArrayOutputStream, url);
          byteArrayOutputStream.writeTo(fileOutputStream);
        } catch (Exception e) {
          throw new NtssException("PDFに書き込みの処理が失敗. " + e.getMessage());
        } finally {
          fileOutputStream.close();
          byteArrayOutputStream.close();
        }
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (request != null && request.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(request.getFacilityCd());
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
        logService.log(LogLevel.ERROR, eventLogMessage, LoggingConstant.FUNCTION_CODE.FUNC_REPORT_MENU,SERVICE_NAME.FNSI, null);
        // #8751 PDF生成時エラーが発生する場合、処理が異常終了してしまう 20230529 孟堅　start
      throw new NtssException(e.getMessage());
        // #8751 PDF生成時エラーが発生する場合、処理が異常終了してしまう 20230529 孟堅　　end
    }
      // del 9316 施設設定マスタ125番の削除について　吉 start
    // }else {
    // String html = reportService.getReportHtml(reportCd, dataKey, null, null);
    // if (StringUtils.isEmpty(html)) {
    // String error = String.format("帳票情報の作成に失敗しました。report_id:[%s]", reportCd);
    // outputErrorLog(request.getFacilityCd(), error);
    // throw new NtssException(error);
    // }
    //
    // // html→PDFに変換して保存
//      reportService.convertHtmlToPdfOutputTmp(html, createJournalTmp, journalCtlNo + "_" + pdfName);
    // }
    // del 9316 施設設定マスタ125番の削除について　吉 end
    // #8222-rep_dial連携で送信されるPDFの内容が文字化けで読めない 周 mod end

    // 作成したレポートコードを保持
    ReportPath rp = new ReportPath();
    rp.setReportCd(reportCd);
    rp.setDumpPath(pdfName);

    // 作成したファイルパスを返却
    return rp;
  }

  /**
   * 患者基本情報の取得
   *
   * @param facilityCd 施設コード
   * @param patId      患者ID
   * @return PatPersonalMain
   */
  private PatPersonalMain getPatPersonalMain(String facilityCd, Long patId) {
    // 患者基本情報の取得
    PatPersonalMain ppm = patPersonalMainDao.selectById(patId);
    if (ppm == null) {
      String error = String.format("患者基本情報の取得に失敗しました。pat_id:[%s]", patId);
      outputErrorLog(facilityCd, error);
      throw new NtssException(error);
    }
    return ppm;
  }

  /**
   * PDFのファイル名
   *
   * @param request {@link JournalCreateRequest} リクエスト
   * @return ファイル名 [施設コード + YYYYMMDDHHmmssSSS.pdf]
   */
  private String getReportName(JournalCreateRequest request) {

    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmssSSS");
    return request.getFacilityCd()
        + sdf.format(new Timestamp(clockWrapper.getClockMillis()))
        + EXTENSION_PDF;
  }

  /**
   * データ抽出キーの取得
   *
   * @param request {@link JournalCreateRequest} リクエスト
   * @return データ抽出キーのマップ
   */
  private Map<String, Object> createDataKey(JournalCreateRequest request) {

    Map<String, Object> dataKey = new HashMap<>();
    // オーダ番号
    dataKey.put(ReportDataKey.ORD_NO, request.getOrdNo());
    // 患者ID
    dataKey.put(ReportDataKey.PAT_ID, request.getPatId());

    // リクエストに基準日が設定されている場合
    // mod #8222-rep_dial連携で送信されるPDFの内容が文字化けで読めない 孟堅　start
    // String date = DateUtil.convertDateToStringFormat(request.getBaseDate());
    String date = request.getBaseDate();
    // mod #8222-rep_dial連携で送信されるPDFの内容が文字化けで読めない 孟堅　end
    try {

      if (!StringUtils.isEmpty(date)) {
        // 日付
      // mod #8222-rep_dial連携で送信されるPDFの内容が文字化けで読めない 孟堅　start
        // dataKey.put(ReportDataKey.DATE, date);
        SimpleDateFormat formater = new SimpleDateFormat("yyyyMMdd");
        formater.setLenient(false);
        Date dat = formater.parse(date);
        dataKey.put(ReportDataKey.DATE, new SimpleDateFormat("yyyy/MM/dd").format(dat));
      // mod #8222-rep_dial連携で送信されるPDFの内容が文字化けで読めない 孟堅　end
        // 日付FROM
        dataKey.put(ReportDataKey.DATE_FROM, date);
        // 日付TO
        dataKey.put(ReportDataKey.DATE_TO, date);
      }
    } catch (ParseException e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (request != null && request.getFacilityCd() != null) {
        eventLogMessage.setFacilityCd(request.getFacilityCd());
      }
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260403 add yangxuewang end
    }

    // add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    // 「2022-11-30 -- Aspose.cells plug-in integration」より、施設コードを追加する
    // 施設コード
    dataKey.put(ReportDataKey.FACILITY_CD, request.getFacilityCd());
    // add 2022-12-07 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

    outputDebugLog(request.getFacilityCd(), String.format("dataKey:[%s]", dataKey));

    return dataKey;
  }

  /**
   * レポートコードの取得
   *
   * @param ordNo オーダ番号
   * @return 帳票ID(mst_treatment.report_id)
   */
  private Long getTemplateReportCd(String facilityCd, Long ordNo) {
    MstTreatment treatment = mstTreatmentDao.selectByOrdNo(ordNo);
    if (treatment == null) {
      String error = "治療情報に紐づく治療方法の取得に失敗しました。";
      outputErrorLog(facilityCd, error);
      throw new NtssException(error);
    }
    // add #9348 治療方法マスタに紐づけられているレポートレイアウトが削除されていると帳票作成に失敗する start
    boolean reportNoExistFlg = false;
    if (treatment.getReportId() != null) {
      MstReport report = mstReportDao.selectReportByReportCd(Long.valueOf(treatment.getReportId()));
      if (null == report) {
        reportNoExistFlg = true;
      }
    }
    // add #9348 治療方法マスタに紐づけられているレポートレイアウトが削除されていると帳票作成に失敗する end
    // mod #9348 治療方法マスタに紐づけられているレポートレイアウトが削除されていると帳票作成に失敗する start
    // if (treatment.getReportId() == null) {
    if (treatment.getReportId() == null || reportNoExistFlg) {
      // mod #9348 治療方法マスタに紐づけられているレポートレイアウトが削除されていると帳票作成に失敗する end
      // mod 7808 ep_dial連携でのpdfで治療方法にレポートの設定がない場合エラーになる 吉 start
      // String error ="治療方法マスタの治療経過表IDが設定されていません。";
      // outputErrorLog(facilityCd, error);
      // throw new NtssException(error);
      List<FacilitySettingInfo> list = mstFacilitySettingDao.selectFacilitySetting(facilityCd, "3004");
      if (null != list && list.size() > 0) {
        // add #9348 治療方法マスタに紐づけられているレポートレイアウトが削除されていると帳票作成に失敗する start
        MstReport report = mstReportDao.selectReportByReportCd(Long.valueOf(list.get(0).getValue()));
        if (report == null) {
          String error = "テンプレートが設定されていません。";
          outputErrorLog(facilityCd, error);
          throw new NtssException(error);
        }
        // add #9348 治療方法マスタに紐づけられているレポートレイアウトが削除されていると帳票作成に失敗する end
        return Long.valueOf(list.get(0).getValue());
      } else {
        String error = "治療方法マスタの治療経過表IDが設定されていません。";
        outputErrorLog(facilityCd, error);
        throw new NtssException(error);
      }
      // mod 7808 ep_dial連携でのpdfで治療方法にレポートの設定がない場合エラーになる 吉 end
    }
    // Longへ変換
    return Long.valueOf(treatment.getReportId());
  }

  // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
  private static String getDataKind(Integer dateType){
    switch (dateType){
      case 0: return "dialysis_date";
      case 1: return "exam_date";
      case 2: return "issue_date";
      case 3: return "letter_issue_date";
      case 4: return "all_date";
    }
    return "dialysis_date";
  }

  private static String getDataKindPrint(Integer dateType){
    switch (dateType){
      case 0: return "治療日";
      case 1: return "検査日";
      case 2: return "処方日";
      case 3: return "紹介日";
      case 4: return "すべて";
    }
    return "治療日";
  }

  private Map<String,Object> searchReportSettingForDataKey(String facilityCd, Long reportCd, Map<String, Object> dataKey){
    Map<String, Object> map = new HashMap<>();
    if(reportCd == null || reportCd < 0 || StringUtils.isEmpty(facilityCd)) return map;

    MstReport reportSettingResult = mstReportDao.selectReportSettingByReportCd(facilityCd, reportCd);
    String jsonString = reportSettingResult == null || reportSettingResult.getReportSetting() == null ? "" : String.valueOf(reportSettingResult.getReportSetting());

    if (!"".equals(jsonString)) {
      JSONObject jsonObject = new JSONObject(jsonString);

      // 並び替え
      if (jsonObject.has("sortList")) {
        JSONArray sortList = jsonObject.getJSONArray("sortList");
        List<Map<String, String>> sortConditions = new ArrayList<>();
        for (int i = 0; i < sortList.length(); i++) {
          JSONObject sortItem = sortList.getJSONObject(sortList.length() - (i+1));
          Map<String, String> sortConditionsMap = new HashMap<>();
          String key = sortItem.isNull("key") ? null : sortItem.getString("key");
          int sort = sortItem.getInt("sort");
          if (key != null) {
            sortConditionsMap.put(key, sort == 0 ? "asc" : "desc");
            sortConditions.add(sortConditionsMap);
          }
          map.put(ReportConstant.ReportDataKey.SORT_CONDITION_COLUMN+(sortList.length() - (i+1) +1), key);
          map.put(ReportConstant.ReportDataKey.SORT_CONDITION_ORDER+(sortList.length() - (i+1) +1), String.valueOf(sort));
        }
        map.put(ReportConstant.ReportDataKey.SORT_CONDITIONS, sortConditions);
      }

      // データ抽出条件
      if (jsonObject.has("dataCond")) {
        JSONObject dataCondJsonObject = (JSONObject)jsonObject.get("dataCond");

        // 基準日
        if (dataCondJsonObject.has("dateType")) {
          map.put(ReportConstant.ReportDataKey.dateKind, getDataKind(dataCondJsonObject.getInt("dateType")));
          map.put(ReportConstant.ReportDataKey.dateKindPrint, getDataKindPrint(dataCondJsonObject.getInt("dateType")));
        }

        // 0: 期間指定、1: 1日指定、2: 検査日数指定
        if (dataCondJsonObject.has("periodType")) {
          if(dataCondJsonObject.getInt("periodType") == 2){
            map.put("inspectionDate", dataKey.get(ReportConstant.ReportDataKey.DATE_FROM));
            map.put("inspectionDirection", dataCondJsonObject.getInt("beforeAfter") == 0 ? "前" : "後");
            map.put("inspectionDays", dataCondJsonObject.getInt("numDay"));
          }
        }

        // 検査区分
        if (dataCondJsonObject.has("regOrderClass")) {
          JSONArray regOrderClass = dataCondJsonObject.getJSONArray("regOrderClass");
          List<String> list = new ArrayList<>();
          for (int i = 0; i < regOrderClass.length(); i++) {
            list.add(regOrderClass.getString(i));
          }
          map.put(ReportConstant.ReportDataKey.EXAM_CLASSS,list);
        }

        // 処方区分
        if (dataCondJsonObject.has("prescriptionClass")) {
          JSONArray regOrderClass = dataCondJsonObject.getJSONArray("prescriptionClass");
          List<String> list = new ArrayList<>();
          for (int i = 0; i < regOrderClass.length(); i++) {
            list.add(regOrderClass.getString(i));
          }
          map.put(ReportConstant.ReportDataKey.PRESCRIPTION_CLASSS,list);
        }

        // 紹介区分
        if (dataCondJsonObject.has("letterCategory")) {
          JSONArray regOrderClass = dataCondJsonObject.getJSONArray("letterCategory");
          List<String> list = new ArrayList<>();
          for (int i = 0; i < regOrderClass.length(); i++) {
            list.add(regOrderClass.getString(i));
          }
          map.put(ReportConstant.ReportDataKey.LETTER_CLASSS,list);
        }
      }

      // 医療材料分類
      if (jsonObject.has("equipment")) {
        JSONArray jsonArray = jsonObject.getJSONObject("equipment").getJSONArray("checkedList");
        List<String> list = new ArrayList<>();
        for (int i = 0; i < jsonArray.length(); i++) {
          list.add(jsonArray.getString(i));
        }
        map.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, list);
        // ダイアライザマスタ
        List<String> dialyzerCds = new ArrayList<>();
        if(CollectionUtils.isEmpty(list) ? false : list.contains("0") || list.contains("all")) {
          dialyzerCds.add("all");
        }
        else {
          dialyzerCds.add("0");
        }
        map.put(ReportConstant.ReportDataKey.DIALYZER_IDS, dialyzerCds);
      }

      // 薬剤分類
      if (jsonObject.has("medicine")) {
        JSONArray jsonArray = jsonObject.getJSONObject("medicine").getJSONArray("checkedList");
        List<String> list = new ArrayList<>();
        for (int i = 0; i < jsonArray.length(); i++) {
          list.add(jsonArray.getString(i));
        }
        map.put(ReportConstant.ReportDataKey.MEDICINE_IDS, list);
      }

      // 検査セット
      if (jsonObject.has("examSet")) {
        JSONArray jsonArray = jsonObject.getJSONObject("examSet").getJSONArray("checkedList");
        List<String> list = new ArrayList<>();
        for (int i = 0; i < jsonArray.length(); i++) {
          list.add(jsonArray.getString(i));
        }
        map.put(ReportConstant.ReportDataKey.EXAMSET_IDS, list);
      }

      // 採血管
      if (jsonObject.has("inspect")) {
        List<Integer> inspectionlist =new ArrayList<>();
        inspectionlist.add(jsonObject.getInt("inspect"));
        map.put(ReportConstant.ReportDataKey.INSPECT_IDS, inspectionlist);
      }
    }

    // 並び替え
    if(!map.containsKey(ReportConstant.ReportDataKey.SORT_CONDITIONS)){
      for(int i = 0; i < 3; i++){
        map.put(ReportConstant.ReportDataKey.SORT_CONDITION_COLUMN+(i+1), null);
        map.put(ReportConstant.ReportDataKey.SORT_CONDITION_ORDER+(i+1), "0");
      }
      map.put(ReportConstant.ReportDataKey.SORT_CONDITIONS, new ArrayList<>());
    }

    // データ抽出条件の「基準日」
    if(!map.containsKey(ReportConstant.ReportDataKey.dateKind)){
      map.put(ReportConstant.ReportDataKey.dateKind, getDataKind(-1));
      map.put(ReportConstant.ReportDataKey.dateKindPrint, getDataKindPrint(-1));
    }

    // データ抽出条件の「検査区分」
    if(!map.containsKey(ReportConstant.ReportDataKey.EXAM_CLASSS)){
      map.put(ReportConstant.ReportDataKey.EXAM_CLASSS, new ArrayList<String>(Arrays.asList("1", "2", "0")));
    }

    // データ抽出条件の「処方区分」
    if(!map.containsKey(ReportConstant.ReportDataKey.PRESCRIPTION_CLASSS)){
      map.put(ReportConstant.ReportDataKey.PRESCRIPTION_CLASSS, new ArrayList<String>(Arrays.asList("1", "2")));
    }

    // データ抽出条件の「紹介区分」
    if(!map.containsKey(ReportConstant.ReportDataKey.LETTER_CLASSS)){
      map.put(ReportConstant.ReportDataKey.LETTER_CLASSS, new ArrayList<String>(Arrays.asList("0", "1")));
    }

    // ダイアライザマスタ
    if(!map.containsKey(ReportConstant.ReportDataKey.DIALYZER_IDS)
      || (map.containsKey(ReportConstant.ReportDataKey.DIALYZER_IDS) && map.get(ReportConstant.ReportDataKey.DIALYZER_IDS).toString().contains("all"))
    ) {
      List<Integer> list =new ArrayList<>();
      List<MstDialyzer> dialyzerList = mstDialyzerDao.selectByFacillityCd(facilityCd);
      if(null != dialyzerList && dialyzerList.size()>0){
        for(MstDialyzer dl : dialyzerList){
          list.add(dl.getDialyzerCd());
        }
      }
      map.put(ReportConstant.ReportDataKey.DIALYZER_IDS, list);
    }
    else {
      List<String> Strlist = (List<String>)map.get(ReportConstant.ReportDataKey.DIALYZER_IDS);
      List<Integer> list =new ArrayList<>();
      for(String str : Strlist) {
        list.add(Integer.parseInt(str));
      }
    }

    // 医療材料分類
    if(!map.containsKey(ReportConstant.ReportDataKey.EQUIPMENT_IDS)
      || (map.containsKey(ReportConstant.ReportDataKey.EQUIPMENT_IDS) && map.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS).toString().contains("all"))
    ) {
      List<Integer>list =new ArrayList<>();
      MstEquipmentClass params = new MstEquipmentClass();
      params.setFacilityCd(facilityCd);
      List<MstEquipmentClass> mstEquipmentClassList = mstEquipmentClassDao.selectAll(SelectOptions.get(), params);
      if(null != mstEquipmentClassList && mstEquipmentClassList.size()>0){
        list.add(-1);
        for(MstEquipmentClass mec : mstEquipmentClassList){
          list.add(mec.getClassCd());
        }
      }
      map.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, list);
    }
    else {
      List<String> Strlist = (List<String>)map.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS);
      List<Integer> list =new ArrayList<>();
      for(String str : Strlist) {
        list.add(Integer.parseInt(str));
      }
    }

    // 薬剤分類
    if(!map.containsKey(ReportConstant.ReportDataKey.MEDICINE_IDS)
      || (map.containsKey(ReportConstant.ReportDataKey.MEDICINE_IDS) && map.get(ReportConstant.ReportDataKey.MEDICINE_IDS).toString().contains("all"))
    ) {
      List<Integer>list =new ArrayList<>();
      MstMedicineClass medicineClass = new MstMedicineClass();
      medicineClass.setFacilityCd(facilityCd);
      List<MstMedicineClass> mstMedicineClassList = mstMedicineClassDao.selectAll(SelectOptions.get(), medicineClass);
      if(null != mstMedicineClassList && mstMedicineClassList.size()>0){
        list.add(-1);
        for(MstMedicineClass mdc : mstMedicineClassList){
          list.add(mdc.getClassCd());
        }
      }
      map.put(ReportConstant.ReportDataKey.MEDICINE_IDS, list);
    }
    else {
      List<String> Strlist = (List<String>)map.get(ReportConstant.ReportDataKey.MEDICINE_IDS);
      List<Integer> list =new ArrayList<>();
      for(String str : Strlist) {
        list.add(Integer.parseInt(str));
      }
    }

    // 検査セット
    if(!map.containsKey(ReportConstant.ReportDataKey.EXAMSET_IDS)
      || (map.containsKey(ReportConstant.ReportDataKey.EXAMSET_IDS) && map.get(ReportConstant.ReportDataKey.EXAMSET_IDS).toString().contains("all"))
    ) {
      List<Long>list =new ArrayList<>();
      MstExamSet examSet = new MstExamSet();
      examSet.setFacilityCd(facilityCd);
      List<MstExamSet> mstExamSetList = mstExamSetDao.selectAll(SelectOptions.get(),examSet);
      if(null != mstExamSetList && mstExamSetList.size()>0){
        for(MstExamSet mes : mstExamSetList){
          list.add(mes.getExamSetCd());
        }
      }
      map.put(ReportConstant.ReportDataKey.EXAMSET_IDS, list);
    }
    else {
      List<String> Strlist = (List<String>)map.get(ReportConstant.ReportDataKey.EXAMSET_IDS);
      List<Integer> list =new ArrayList<>();
      for(String str : Strlist) {
        list.add(Integer.parseInt(str));
      }
    }

    // 採血管
    List<Integer> inspectionlist =new ArrayList<>();
    inspectionlist.add(0);//常に出さないように暫定的の対応
    map.put(ReportConstant.ReportDataKey.INSPECT_IDS, inspectionlist);

    return map;
  }
  // add #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end

  /**
   * ログ出力
   *
   * @param level      {@link LogLevel} ログレベル
   * @param facilityCd 施設コード
   * @param message    ログメッセージ
   */
  private void outputLog(LogLevel level, String facilityCd, String message) {
    EventLogMessage elm = new EventLogMessage();
    elm.setFacilityCd(facilityCd);
    elm.setLogMessage(message);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    elm.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(level, elm, null, SERVICE_NAME.FNSI, null);
  }

  /**
   * エラーログ出力
   *
   * @param facilityCd 施設コード
   * @param message    ログメッセージ
   */
  private void outputErrorLog(String facilityCd, String message) {
    outputLog(LogLevel.ERROR, facilityCd, message);
  }

  /**
   * デバッグログ出力
   *
   * @param facilityCd 施設コード
   * @param message    ログメッセージ
   */
  private void outputDebugLog(String facilityCd, String message) {
    outputLog(LogLevel.DEBUG, facilityCd, message);
  }

  // DB更新ログ出力ロジック wangzuo Start

  /**
   * ログ情報設定
   *
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();

    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + SERVICE_NAME.FNSI);
    return eventLogMessage;
  }

  /**
   * ログ出力共通クラス設定、取得
   *
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(defaultDbConfig);
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }
  // DB更新ログ出力ロジック wangzuo End

  // add FNSI-7528 劉全航 start
  // mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
  // private boolean getTreatmentRecordCondition(Long ordNo, String facilityCd) {
  private boolean getTreatmentRecordCondition(Long ordNo, String facilityCd, String key0) {
    // mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    OrdMain ordMain = ordMainDao.selectByOrdNo(ordNo);
    // add bug #7435 修正 chen start
    if (ordMain == null) {
      return false;
    }
    // add bug #7435 修正 chen end
    Integer rstEdition = ordMain.getRstEdition();
    List<MstCoopIni> mstCoopInis = mstCoopIniDao.selectByFacilityCd(facilityCd);
    MstCoopIni mstCoopIni = mstCoopInis.get(0);
    String coopIniInfo = mstCoopIni.getCoopIniInfo();
    JSONArray iniJsonArray = new JSONArray(coopIniInfo);
    String settingValue = null;
    for (int i = 0; i < iniJsonArray.length(); i++) {
      JSONObject jsonObject = iniJsonArray.getJSONObject(i);
      // mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//      if (jsonObject.get("key1").equals("DIALYSISSEND") && jsonObject.get("key2").equals("MODIFY_SEND_CLASS")) {
      String key0Ini = "";
      if (jsonObject.has("key0")) {
        key0Ini = StringUtils.isEmpty(jsonObject.get("key0")) ? "" : String.valueOf(jsonObject.get("key0"));
      }
      if (key0.equals(key0Ini) &&
          jsonObject.get("key1").equals("DIALYSISSEND") && jsonObject.get("key2").equals("MODIFY_SEND_CLASS")) {
        // mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        String value = jsonObject.get("value").toString();
        String default_v = jsonObject.get("default_v").toString();
        settingValue = value.equals("") ? default_v : value;
        break;
      }
    }
    return rstEdition > 1 && Objects.equals(settingValue, "1");
  }
  // add FNSI-7528 劉全航 end

  //add #8255 ini_dial連携で正常応答を行っているにもかかわらずバックアップデータがNGフォルダに格納される 20230204 孫健 start
  @Override
  public List<SysCoopJournal> listJournalsUnDeliveryAsSkip(String facilityCd, Long ordNo, Long patId) {
    return sysCoopJournalDao.selectUnDeliveryAsSkip(facilityCd, ordNo, patId);
  }

  /**
   * 当該ジャーナル対象により、最適化する必要があるジャーナル対象を検索する。
   *
   * @param sysCoopJournal {@link SysCoopJournal}
   * @param crud           {@link Crud}
   * @param last           フィルタリングregDateが現在のJournalのregDateより小さい
   */
  @Override
  public List<SysCoopJournal> findSameJournalList(SysCoopJournal sysCoopJournal, String crud, Boolean last) {
    List<SysCoopJournal> cuJList = null;
    if (CoopCdConstant.REP_DIAL.equals(sysCoopJournal.getCoopCd())) {
      cuJList = this.findSameJournalListRepDial(sysCoopJournal, crud, CoopCdConstant.REP_DIAL, sysCoopJournal.getCoopCdIndex(), last);
    } else {
      cuJList = this.findSameJournalListByCrud(sysCoopJournal, crud, last);
    }
    return cuJList;
  }
  // add #8255 ini_dial連携で正常応答を行っているにもかかわらずバックアップデータがNGフォルダに格納される 20230204 孫健 end

  // #6993-profile連携で受信した生存の有無登録 周 20230204 add start
  @Transactional
  @Override
  public int upExamOrdJournalToSkip(JournalCreateRequest request) {

    SysCoopJournalParam scjParam = new SysCoopJournalParam();
    BeanUtils.copyProperties(request, scjParam);
    // #9336 処理保留イベントの最適化処理が正常に行われない 2023-08-09 卓 start
    if (NtssCoopApiConstants.ApiTimingBaStatus.BEFORE.getStatus().equals(request.getBaStatus())) {
      sysCoopJournalDao.updateExamOrdJournalToSkip(scjParam);
    }
    if (Crud.UPDATE.getResult().equals(request.getCrud())) {
      sysCoopJournalDao.updateExamOrdJournalToSkipCrudCU(scjParam);

    }
    return 1;
    // #9336 処理保留イベントの最適化処理が正常に行われない 2023-08-09 卓 end
  }
  // #6993-profile連携で受信した生存の有無登録 周 20230204 add end

  @Transactional
  @Override
  public void upReportDialJournalToSkip(JournalCreateRequest request) {
    SysCoopJournalParam scjParam = new SysCoopJournalParam();
    BeanUtils.copyProperties(request, scjParam);
    sysCoopJournalDao.updateReportDialJournalToSkip(scjParam);
  }

  @Transactional
  @Override
  public void ordDialBedReplace(JournalUpdateRequest request) {
    SysCoopJournal journal = sysCoopJournalDao.selectByPK(request.getCtlNo());
    String facilityCd = journal.getFacilityCd();

    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setFacilityCd(facilityCd);
    eventLogMessage.setInvokeClass(this.getClass().getName());

    // ord_main.ind_bed_cdに登録されているか確認
    OrdMain ord = ordMainDao.selectByOrdNo(journal.getOrdNo());
    // ind_bed_cdが登録されている場合は処理しない
    if (null != ord.getIndBedCd() && ord.getIndBedCd() != 0) {
      return;
    }

    // ベッドコードが連携されていて、ind_bed_cdが登録されていない場合はベッドの入れ替えを考慮し、再度ベッド設定用のjournal作成
    URI uri;
    StringBuilder builder = new StringBuilder("http://localhost:8080/ntss-coop-api/journal/create");
    try {
      uri = new URI(builder.toString());
    } catch (URISyntaxException use) {
      eventLogMessage.setLogMessage("オーダ受け連携ベッド入れ替え用URLの生成に失敗しました。url:[" + builder + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(eventLogMessage.getLogMessage());
    }
    // ヘッダ作成
    HttpHeaders headers = new HttpHeaders();
    headers.setContentType(MediaType.APPLICATION_JSON);
    headers.set(headerKey, headerValue);
    JournalCreateRequest journalCreateRequest = getString(request.getOpeCd(), journal);
    try {
      RequestEntity<?> req = new RequestEntity<>(journalCreateRequest, headers, HttpMethod.POST, uri);
	  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
      long start = System.currentTimeMillis();
      ResponseEntity<?> response = restTemplate.exchange(req, String.class);
      long cost = System.currentTimeMillis() - start;
      Map<String, Object> map = new HashMap<>();
      map.put("logType", "RESTTEMPLATE-LOG");
      map.put("className", "jp.co.nikkiso.ntss.coop_api.service.JournalServiceImpl");
      map.put("methodName", "ordDialBedReplace");
      map.put("method", req.getMethod());
      map.put("url", req.getUrl());
      map.put("headers", req.getHeaders().toSingleValueMap());
      map.put("requestParameter", req.getBody());
      map.put("status",response.getStatusCode());
      map.put("cost", cost);
      map.put("result",response.getBody());
      EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
      restTemplateEventLogMessage.setLogMessage(toJson(map));
      logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
      eventLogMessage.setLogMessage("オーダ受け連携ベッド入れ替え用連携API呼び出し結果:" + response);
	  // #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      logService.log(LogLevel.INFO, eventLogMessage, null, SERVICE_NAME.FNSI, null);
    } catch (Exception ex) {
      eventLogMessage.setLogMessage("オーダ受け連携ベッド入れ替え用連携APIの呼び出しに失敗しました。"
          + " api_uri:[" + builder + "]"
          + " api_method:[" + HttpMethod.POST + "]"
          + " api_body:[" + journalCreateRequest + "]"
          + " Message:[" + ex.getMessage() + "]");
      logService.log(LogLevel.ERROR, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NtssException(eventLogMessage.getLogMessage());
    }
  }

  /**
   * @param opeCd
   * @param journal
   * @return
   */
  private JournalCreateRequest getString(String opeCd, SysCoopJournal journal) {
    JournalCreateRequest apiJson = new JournalCreateRequest();
    apiJson.setCrud(CoopCdConstant.CRUD_CREATE);
    apiJson.setOpeCd(opeCd);
    apiJson.setPatId(journal.getPatId());
    apiJson.setCoopCd(journal.getCoopCd());
    apiJson.setUserId(journal.getUserId());
    apiJson.setFacilityCd(journal.getFacilityCd());
    apiJson.setHospPatId(journal.getHospPatId());
    apiJson.setOrdNo(journal.getOrdNo());
    apiJson.setBaseDate(journal.getBaseDate());
    apiJson.setCoopVersion(journal.getCoopVersion());

    apiJson.setMessage64(Base64.getEncoder().encodeToString(journal.getDump()));
    return apiJson;
  }

  @Override
  public Boolean wsClientSend(MntIfEdgeClientConnectRequest request) throws IOException {
    Boolean result = ifEdgeMntSessionManager.wsClientSend(request);

    return result;
  }

}
