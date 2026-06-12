package jp.co.nikkiso.ntss.admin_web.service.reportMenu;

import tools.jackson.core.JacksonException;
import tools.jackson.databind.JsonNode;
import tools.jackson.databind.ObjectMapper;
import com.google.common.base.Objects;
import com.mongodb.client.AggregateIterable;
import com.mongodb.client.FindIterable;
import com.mongodb.client.model.Accumulators;
import com.mongodb.client.model.Aggregates;
import com.mongodb.client.model.Sorts;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.ReportMenu;
import jp.co.nikkiso.ntss.admin_web.service.MstInfoService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.print.PrinterService;
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.api.constant.ReportConstant;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlParam;
import jp.co.nikkiso.ntss.api.domain.report.ReportXmlTmplRepeat;
import jp.co.nikkiso.ntss.api.service.SysDataSetService;
import jp.co.nikkiso.ntss.api.service.onPremise.OnPremiseService;
import jp.co.nikkiso.ntss.api.service.report.ReportForIntroductionReportService;
import jp.co.nikkiso.ntss.api.service.report.ReportForDistributionListService;
import jp.co.nikkiso.ntss.api.service.report.ReportForMachineReportService;
import jp.co.nikkiso.ntss.api.service.report.ReportForLabelReportService;
import jp.co.nikkiso.ntss.api.service.report.ReportForOnePatientService;
import jp.co.nikkiso.ntss.api.service.report.ReportForTotalService;
import jp.co.nikkiso.ntss.api.service.report.ReportS3Service;
import jp.co.nikkiso.ntss.api.service.report.ReportService;
import jp.co.nikkiso.ntss.api.service.report.ReportServiceImpl;
import jp.co.nikkiso.ntss.api.service.report.ReportWithAsposeApiService;
import jp.co.nikkiso.ntss.api.service.utils.AsposeCellsUtils;
import jp.co.nikkiso.ntss.api.service.utils.ReportUtils;
import jp.co.nikkiso.ntss.api.service.utils.ReportZipFile;
import jp.co.nikkiso.ntss.api.service.utils.TmpFileService;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.FUNCTION_CODE;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant.SERVICE_NAME;
import jp.co.nikkiso.ntss.core.dao.BaseEntityDao;
import jp.co.nikkiso.ntss.core.dao.DevMenteMainDao;
import jp.co.nikkiso.ntss.core.dao.MniMonitorDao;
import jp.co.nikkiso.ntss.core.dao.MstBedDao;
import jp.co.nikkiso.ntss.core.dao.MstDialyzerDao;
import jp.co.nikkiso.ntss.core.dao.MstEquipmentClassDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstKurDao;
import jp.co.nikkiso.ntss.core.dao.MstMachineDao;
import jp.co.nikkiso.ntss.core.dao.MstMedicineClassDao;
import jp.co.nikkiso.ntss.core.dao.MstReportDao;
import jp.co.nikkiso.ntss.core.dao.MstRoomBedGroupDao;
import jp.co.nikkiso.ntss.core.dao.MstTreatmentDao;
import jp.co.nikkiso.ntss.core.dao.OrdMainDao;
import jp.co.nikkiso.ntss.core.dao.OrdPrescriptionDao;
import jp.co.nikkiso.ntss.core.dao.PatEventDao;
import jp.co.nikkiso.ntss.core.dao.PatGroupDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.ReportMenuDao;
import jp.co.nikkiso.ntss.core.dao.ReportMenuSortDao;
import jp.co.nikkiso.ntss.core.entity.DevMenteMainDto;
import jp.co.nikkiso.ntss.core.entity.EntityDao;
import jp.co.nikkiso.ntss.core.entity.MstBed;
import jp.co.nikkiso.ntss.core.entity.MstDialyzer;
import jp.co.nikkiso.ntss.core.entity.MstEquipmentClass;
import jp.co.nikkiso.ntss.core.entity.MstFacilitySetting;
import jp.co.nikkiso.ntss.core.entity.MstKur;
import jp.co.nikkiso.ntss.core.entity.MstMachineReportList;
import jp.co.nikkiso.ntss.core.entity.MstMedicineClass;
import jp.co.nikkiso.ntss.core.entity.MstReport;
import jp.co.nikkiso.ntss.core.entity.MstTreatment;
import jp.co.nikkiso.ntss.core.entity.OrdMain;
import jp.co.nikkiso.ntss.core.entity.OrdPrescription;
import jp.co.nikkiso.ntss.core.entity.PatEvent;
import jp.co.nikkiso.ntss.core.entity.PatExamMain;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.custom.CusMachineInfoPeriodic;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.entity.custom.MniMonitorRemainingTime;
import jp.co.nikkiso.ntss.core.entity.custom.ReportMenuSortContainer;
import jp.co.nikkiso.ntss.core.exception.NotExistException;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import lombok.extern.slf4j.Slf4j;
import org.apache.commons.lang3.StringUtils;
import org.apache.commons.lang3.math.NumberUtils;
import org.apache.poi.ss.usermodel.Workbook;
import org.apache.poi.ss.usermodel.WorkbookFactory;
import org.bson.Document;
import org.bson.conversions.Bson;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.SelectOptions;
import org.seasar.doma.jdbc.builder.SelectBuilder;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ResourceLoader;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.io.BufferedInputStream;
import java.io.ByteArrayInputStream;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.nio.file.Files;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.sql.Timestamp;
import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.Calendar;
import java.util.Collections;
import java.util.Comparator;
import java.util.Date;
import java.util.GregorianCalendar;
import java.util.HashMap;
import java.util.HashSet;
import java.util.LinkedHashMap;
import java.util.LinkedHashSet;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import java.util.Set;
import java.util.function.Function;
import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.Collectors;
import java.util.zip.ZipEntry;
import java.util.zip.ZipOutputStream;

import static com.mongodb.client.model.Filters.and;
import static com.mongodb.client.model.Filters.eq;
import static com.mongodb.client.model.Filters.in;
import static com.mongodb.client.model.Filters.lt;
import static com.mongodb.client.model.Sorts.descending;
import static java.util.stream.Collectors.toList;
import jp.co.nikkiso.ntss.core.config.DefaultDb;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

//add #9058【IES起票】状況マップ画面にて単患者帳票機能帳票印刷後線とプレビューが不一致 liuc start
//add #9058【IES起票】状況マップ画面にて単患者帳票機能帳票印刷後線とプレビューが不一致 liuc end

/**
 *
 * 帳票出力の実装インタフェース
 *
 */
@Service
@Slf4j
public class ReportMenuServiceImpl implements ReportMenuService {
  //add #9058【IES起票】状況マップ画面にて単患者帳票機能帳票印刷後線とプレビューが不一致 liuc start
  @Autowired
  ResourceLoader resourceLoader;
  //add #9058【IES起票】状況マップ画面にて単患者帳票機能帳票印刷後線とプレビューが不一致 liuc end

	@Value("${ntss.report.printTmpDir}")
	private String printTmpDir;

	@Value("${ntss.report.createTmpDir}")
	private String createTmpDir;

	@Autowired
	private ReportMenuDao reportMenuDao;

	@Autowired
	private ReportMenuSortDao reportMenuSortDao;

	@Autowired
	private ReportService reportService;

  // add #12206 【デグレード】帳票画面で透析予測でのソートが機能しない 高 start
  @Autowired
  private ReportServiceImpl reportServiceImpl;
  // add #12206 【デグレード】帳票画面で透析予測でのソートが機能しない 高 end

	@Autowired
	private TmpFileService tmpFileService;
  /*add FNSI-改修内容装置帳票の対応 任 start*/
  @Autowired
  private MstReportDao mstReportDao;
  /*add FNSI-改修内容装置帳票の対応 任 end*/

  // add 10546 複数集計出力時にサーバが高負荷になる gjn start
  @Autowired
  MstDialyzerDao mstDialyzerDao;
  // add 10546 複数集計出力時にサーバが高負荷になる gjn end
  // add #12324 紹介状の出力時にpat_eventを参照する zhao start
  /**
   * 患者イベントのDaoインタフェース.
   */
  @Autowired
  private PatEventDao patEventDao;
  // add #12324 紹介状の出力時にpat_eventを参照する zhao end
  @Autowired
  private SysDataSetService sysDataSetService;
  // add #6377 「テンプレート繰り返しが正しく動いていない」 鄧シン start
  /**
   * 帳票ファイル取得のServiceインタフェース.
   */
  @Autowired
  private ReportS3Service reportS3Service;
  // add #6377 「テンプレート繰り返しが正しく動いていない」 鄧シン end

	@Autowired
	private PatPersonalMainDao patPersonalMainDao;

	@Autowired
	private PrinterService printerService;

	@Autowired
  private OnPremiseService onPremiseService;

	@Autowired
	private MstInfoService mstInfoService;

	@Autowired
	private LogService logService;

  //add IES因島）sql性能試験 後で削除 liuc start
  @Autowired
  private jp.co.nikkiso.ntss.api.service.LogService testLogService;
  //add IES因島）sql性能試験 後で削除 liuc end

  // add #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
  @Autowired
  private ReportForOnePatientService reportForOnePatientService;
  // add #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end

  // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
  @Autowired
  private ReportForDistributionListService reportForDistributionListService;

  @Autowired
  private ReportForLabelReportService reportForLabelReportService;
  // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end

  // add #11117 日常点検記録簿が1ページ1装置で出力される limingzhe start
  @Autowired
  ReportForMachineReportService reportForMachineReportService;
  // add #11117 日常点検記録簿が1ページ1装置で出力される limingzhe end

  // add #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe start
  @Autowired
  ReportForIntroductionReportService reportForIntroductionReportService;
  // add #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe end

  // mod #11973 日常点検一覧帳票が正常に出せない limingzhe start
  // add 10546 複数集計出力時にサーバが高負荷になる gjn start
//  @Autowired
//  ReportForMultiTotalService reportForMultiTotalService;
  // add 10546 複数集計出力時にサーバが高負荷になる gjn end
  @Autowired
  ReportForTotalService reportForTotalService;
  // mod #11973 日常点検一覧帳票が正常に出せない limingzhe end

  /*add FNSI-改修内容装置帳票の対応 任 start*/
	@Autowired
  private DevMenteMainDao devMenteMainDao;
  /*add FNSI-改修内容装置帳票の対応 任 end*/
  //add 帳票用のパラメーター設定処理  吉 start
  @Autowired
  private OrdPrescriptionDao ordPrescriptionDao;
  //add 帳票用のパラメーター設定処理  吉 end
  // add FNSI-印刷失敗時の通知を追加 江 start
  @Autowired
  WebApiCallCommonUtil webApiCallCommonUtil;
  // add FNSI-印刷失敗時の通知を追加 江 end
  //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 start
  @Autowired
  MstTreatmentDao mstTreatmentDao;
  //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 end
  //add 5565 並び替えを実施してもその情報が保持されない 吉 start
  @Autowired
  MstFacilitySettingDao mstFacilitySettingDao;
  //add 5565 並び替えを実施してもその情報が保持されない 吉 end

  // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
  @Autowired
  MstEquipmentClassDao mstEquipmentClassDao;
  @Autowired
  MstMedicineClassDao mstMedicineClassDao;
  // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end

  // add #10633 【たくしん会】帳票のフォント問題 吉 start
  @Autowired
  private ReportWithAsposeApiService reportWithAsposeApiService;
  // add #10633 【たくしん会】帳票のフォント問題 吉 end

  @Autowired
  PatGroupDao patGroupDao;
  @Autowired
  MstBedDao mstBedDao;
  @Autowired
  MstKurDao mstKurDao;
  @Autowired
  MstRoomBedGroupDao mstRoomBedGroupDao;
  @Autowired
  MniMonitorDao mniMonitorDao;
  //add #9323 donghao start
  @Autowired
  OrdMainDao rdMainDao;
  //add #9323 donghao end
  // add #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
  @Autowired
  MstMachineDao mstMachineDao;
  // add #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
  // add #10504 一日複数回指示ある患者の治療経過表出力で空帳票が出力される 王永吉 start
  // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang start
//  private boolean optionCdFlag = false;
  private final ThreadLocal<Boolean> optionCdFlag = ThreadLocal.withInitial(() -> false);
  // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang end
  // add #10504 一日複数回指示ある患者の治療経過表出力で空帳票が出力される 王永吉 end
	private String currentSortId = "";
	private List<Long> currentPatIds = new ArrayList<>();
	private List<Long> tmpIds = new ArrayList<>();
	private String[] sortConditions = {
			ReportMenu.PATIENT_ID,
			ReportMenu.PATIENT_COOL,
			ReportMenu.PATIENT_NAME,
			ReportMenu.PATIENT_BED,
			ReportMenu.READING,
			ReportMenu.PATIENT_GROUP_NAME,
			ReportMenu.BED_GROUP_NAME,
			ReportMenu.BED_NAME,
			ReportMenu.ENTRANCE_EXIT_CLASSIFICATION,
			ReportMenu.SEX,
			ReportMenu.BLOOD_TYPE,
			ReportMenu.MEDICINE_EQUIPMENT_CODE,
			ReportMenu.MEDICINE_EQUIPMENT_CLASS,
			ReportMenu.MEDICINE_EQUIPMENT_NAME,
			// add #5562 並び替えを行っても帳票画面のリストに反映されない 歴 start
			ReportMenu.INFECTIOUS_ISEASE_PATIENTS,
			// add #5562 並び替えを行っても帳票画面のリストに反映されない 歴 end
      /*add 2020-12-09 FNSI-添加内容 各帳票の並び順調整。 吉 start*/
      ReportMenu.DIALYSIS_DAY,
      ReportMenu.DIALYSIS_ROOM_GROUP,
      ReportMenu.ROOM_BED_GROUP,
    /*add 2020-12-09 FNSI-添加内容 各帳票の並び順調整。 吉 end*/
    /*add FNSI-改修内容装置帳票の対応 任 start*/
      ReportMenu.MACHINE_NAME,
      ReportMenu.MACHINE_NO,
      ReportMenu.MACHINE_SERIAL,
      ReportMenu.MACHINE_TYPE,
    /*add FNSI-改修内容装置帳票の対応 任 end*/
    // add #9323 donghao start
    ReportMenu.EQUIPMENT_MEDICINE_CODE,
    // add #9323 donghao end
    // add #12032 配布リスト（物品）の並び順に「データ分類」がない 高　start
    ReportMenu.EQUIPMENT_MEDICINE_DATA_GROUP
    // add #12032 配布リスト（物品）の並び順に「データ分類」がない 高　end
		};

	private String checkSortId(Map<String, String> item) {
		String sortId = "";
		for (String value : this.sortConditions) {
			if (item.get(value) != null ) {
				sortId = value;
				return sortId;
			}
		}
		return sortId;
	}

	/**
	 *
	 * {@inheritDoc}
	 */
	@Override
	public List<OrdMain> getOrdNoListSorted(ReportMenuSortContainer reportMenu) {
		Boolean isDialyzer = false;
// del 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
//		if(reportMenu.getEquipmentCdList() != null) {
//			if(reportMenu.getEquipmentCdList().contains(0)) {
//				isDialyzer = true;
//				for (int index = 0; index < reportMenu.getEquipmentCdList().size(); index++) {
//					if(reportMenu.getEquipmentCdList().get(index).equals(0)){
//						reportMenu.getEquipmentCdList().remove(index);
//					}
//				}
//			}
//		}
// del 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
		String facilityCd = reportMenu.getFacilityCd();
		List<String> regOrderClassList = reportMenu.getRegOrderClassList();
// del 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
//		List<Integer> medicineCdList = reportMenu.getMedicineCdList();
//		List<Integer> equipmentCdList = reportMenu.getEquipmentCdList();
//
//		if (medicineCdList == null) {
//			medicineCdList = new ArrayList<>();
//		}
//		if (equipmentCdList == null) {
//			equipmentCdList = new ArrayList<>();
//		}
// del 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
		if (regOrderClassList == null) {
			regOrderClassList = new ArrayList<>();
		}

		List<OrdMain> results = new ArrayList<>();
		List<OrdMain> newResults = new ArrayList<>();
		List<Long> patIds = reportMenu.getPatIds();
		List<Map<String, String>> sortConditions = reportMenu.getSortCondition();
    // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
    List<Map<String, Object>> ordNosFilterByDate = reportMenuDao.selectByPatIdsAndData(
      patIds,
      facilityCd,
      regOrderClassList,
      reportMenu.getSpecifyDate(),
      reportMenu.getFromDate(),
      reportMenu.getToDate()
    );
    // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end
		for (int index = 0; index < patIds.size(); index++) {
		  //mod #9058【IES起票】状況マップ画面にて単患者帳票機能帳票印刷後線とプレビューが不一致 liuc start
			//修正タイプ変換エラー
      //Long patId = patIds.get(index);
      Long patId = 0L;
      if(patIds.get(index) != null) {
        patId = Long.valueOf(String.valueOf(patIds.get(index)));
      }
      //mod #9058【IES起票】状況マップ画面にて単患者帳票機能帳票印刷後線とプレビューが不一致 liuc end
			List<Long> ordNos = new ArrayList<>();

      // mod #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
//			List<Long> ordNoFilterByDate = getOrdNoListByDate(patId, facilityCd, regOrderClassList,
//					reportMenu.getFromDate(), reportMenu.getToDate(), reportMenu.getSpecifyDate());
      final Long patIdf = patId;
      List<Long> ordNoFilterByDate = ordNosFilterByDate.stream()
        .filter(r -> patIdf.equals(Long.parseLong(String.valueOf(r.get("pat_id")))))
        .map(r -> Long.parseLong(String.valueOf(r.get("ord_no"))))
        .distinct()
        .collect(toList());
      // mod #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end
// del 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
//			List<Long> ordNoFilterByMedicine = new ArrayList<>();
//			if (medicineCdList.size() > 0) {
//				ordNoFilterByMedicine = getOrdNoListByMedicines(medicineCdList, ordNoFilterByDate);
//			}
//
//			List<Long> ordNoFilterByEquipment = new ArrayList<>();
//			if (equipmentCdList.size() > 0) {
//				ordNoFilterByEquipment = getOrdNoListByEquipments(equipmentCdList, ordNoFilterByDate);
//			}
//
//			List<Long> ordNoFilterByDialyzer = new ArrayList<>();
//			if (isDialyzer) {
//				List<Integer> listDia = new ArrayList<>();
//				for(MstDialyzer item : mstInfoService.findMstDialyzerAllByFacillityCd(reportMenu.getFacilityCd())) {
//					listDia.add(item.getDialyzerCd());
//				}
//				ordNoFilterByDialyzer = getOrdNoListByDialyzer(listDia, ordNoFilterByDate);
//			}
//
//			if (medicineCdList.size() > 0 && equipmentCdList.size() > 0 && isDialyzer) {
//				for (int i = 0; i < ordNoFilterByDate.size(); i++) {
//					Long ordNo = ordNoFilterByDate.get(i);
//					if (ordNoFilterByMedicine.contains(ordNo) || ordNoFilterByEquipment.contains(ordNo) || ordNoFilterByDialyzer.contains(ordNo)) {
//						ordNos.add(ordNo);
//					}
//				}
//			} else if (medicineCdList.size() > 0 && equipmentCdList.size() > 0 && !isDialyzer) {
//				for (int i = 0; i < ordNoFilterByDate.size(); i++) {
//					Long ordNo = ordNoFilterByDate.get(i);
//					if (ordNoFilterByMedicine.contains(ordNo) || ordNoFilterByEquipment.contains(ordNo)) {
//						ordNos.add(ordNo);
//					}
//				}
//			} else if (medicineCdList.size() > 0 && equipmentCdList.size() == 0 && isDialyzer) {
//				for (int i = 0; i < ordNoFilterByDate.size(); i++) {
//					Long ordNo = ordNoFilterByDate.get(i);
//					if (ordNoFilterByMedicine.contains(ordNo) || ordNoFilterByDialyzer.contains(ordNo)) {
//						ordNos.add(ordNo);
//					}
//				}
//			} else if (medicineCdList.size() == 0 && equipmentCdList.size() > 0 && isDialyzer) {
//				for (int i = 0; i < ordNoFilterByDate.size(); i++) {
//					Long ordNo = ordNoFilterByDate.get(i);
//					if (ordNoFilterByEquipment.contains(ordNo) || ordNoFilterByDialyzer.contains(ordNo)) {
//						ordNos.add(ordNo);
//					}
//				}
//			}
//			else if (isDialyzer) {
//				for (int i = 0; i < ordNoFilterByDate.size(); i++) {
//					Long ordNo = ordNoFilterByDate.get(i);
//					if (ordNoFilterByDialyzer.contains(ordNo)) {
//						ordNos.add(ordNo);
//					}
//				}
//			} else if (medicineCdList.size() > 0) {
//				for (int i = 0; i < ordNoFilterByDate.size(); i++) {
//					Long ordNo = ordNoFilterByDate.get(i);
//					if (ordNoFilterByMedicine.contains(ordNo)) {
//						ordNos.add(ordNo);
//					}
//				}
//			} else if (equipmentCdList.size() > 0) {
//				for (int i = 0; i < ordNoFilterByDate.size(); i++) {
//					Long ordNo = ordNoFilterByDate.get(i);
//					if (ordNoFilterByEquipment.contains(ordNo)) {
//						ordNos.add(ordNo);
//					}
//				}
//			} else {
// del 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
				for (int i = 0; i < ordNoFilterByDate.size(); i++) {
					Long ordNo = ordNoFilterByDate.get(i);
					ordNos.add(ordNo);
				}
// del 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
//			}
// del 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
      // add 2020-09-21 FNSI-仕様追加 出力データなしの場合に帳票も表示する 夏 start
			if(ordNos.size() == 0){
        OrdMain ordMain = new OrdMain();
        ordMain.setPatId(patId);
        ordMain.setOrdNo(0l);
        results.add(ordMain);
      }else{
      // add 2020-09-21 FNSI-仕様追加 出力データなしの場合に帳票も表示する 夏 end
        for (int i = 0; i < ordNos.size(); i++) {
          OrdMain ordMain = new OrdMain();
          ordMain.setPatId(patId);
          ordMain.setOrdNo(ordNos.get(i));
          results.add(ordMain);
        }
			}
		}
// del 9323 帳票「並び替え」機能のオーバーホール　吉 start
//		if (sortConditions.size() > 0) {
//      /*add FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start*/
//      Comparator<EntityDao> value1 = null;
//      Comparator<EntityDao> value2 = null;
//      Comparator<EntityDao> value3 = null;
//      List<EntityDao> list = new ArrayList<>();
//      /*add FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end*/
//			for (int index = 0; index < sortConditions.size(); index++) {
//				Map<String, String> item = sortConditions.get(index);
//				int key = sortConditions.indexOf(item);
//				String sortId = "";
//				String sortIdValue = "";
//				switch (key) {
//				case 0:
//					sortId = checkSortId(item);
//					if (!sortId.equals("")) {
//						this.currentSortId = sortId;
//						sortIdValue = item.get(sortId);
//					} else {
//						this.currentSortId = "";
//					}
//					break;
//				case 1:
//					sortId = checkSortId(item);
//					if (!sortId.equals("")) {
//						this.currentSortId = sortId;
//						sortIdValue = item.get(sortId);
//					} else {
//						this.currentSortId = "";
//					}
//					break;
//				case 2:
//					sortId = checkSortId(item);
//					if (!sortId.equals("")) {
//						this.currentSortId = sortId;
//						sortIdValue = item.get(sortId);
//					} else {
//						this.currentSortId = "";
//					}
//					break;
//				default:
//					this.currentSortId = "";
//					break;
//				}
//				if (!this.currentSortId.equals("")) {
//					if (this.currentPatIds != null) {
//						this.currentPatIds = patIds;
//					}
//          /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start*/
//          /*this.currentPatIds = sortPatientIds(sortId, sortIdValue, patIds, facilityCd);
//
//        }
//      }*/
//          List<EntityDao> listTemp = sortPatientIds(sortId, sortIdValue, patIds, facilityCd);
//          for(int i = 0;i < listTemp.size();i++){
//            boolean b = false;
//            EntityDao entityDao = listTemp.get(i);
//            int indexList = 0;
//            for(EntityDao entityDao1 : list){
//              if(entityDao1.getPat_id().equals(entityDao.getPat_id())){
//                if(index == 0){
//                  if(entityDao1.getValue3()==null||"".equals(entityDao1.getValue3())){
//                    entityDao1.setValue3(entityDao.getPat_name());
//                    // add FNSI-No.25　帳票の追加順位  吉 start
//                    if(sortId == ReportMenu.DIALYSIS_ROOM_GROUP || sortId ==ReportMenu.ROOM_BED_GROUP  && null != entityDao.getPat_name()){
//                      entityDao.setValue4(Integer.valueOf(entityDao.getPat_name()));
//                    }
//                    // add FNSI-No.25　帳票の追加順位  吉 end
//                    list.set(indexList,entityDao1);
//                  }
//                }else if(index ==1){
//                  if(entityDao1.getValue2()==null||"".equals(entityDao1.getValue2())){
//                    // add FNSI-No.25　帳票の追加順位  吉 start
//                    if(sortId == ReportMenu.DIALYSIS_ROOM_GROUP || sortId ==ReportMenu.ROOM_BED_GROUP  && null != entityDao.getPat_name()){
//                      entityDao.setValue4(Integer.valueOf(entityDao.getPat_name()));
//                    }
//                    // add FNSI-No.25　帳票の追加順位  吉 end
//                    entityDao1.setValue2(entityDao.getPat_name());
//                    list.set(indexList,entityDao1);
//                  }
//                }else{
//                  if(entityDao1.getValue1()==null||"".equals(entityDao1.getValue1())){
//                    // add FNSI-No.25　帳票の追加順位  吉 start
//                    if(sortId == ReportMenu.DIALYSIS_ROOM_GROUP || sortId ==ReportMenu.ROOM_BED_GROUP  && null != entityDao.getPat_name()){
//                      entityDao.setValue4(Integer.valueOf(entityDao.getPat_name()));
//                    }
//                    // add FNSI-No.25　帳票の追加順位  吉 end
//                    entityDao1.setValue1(entityDao.getPat_name());
//                    list.set(indexList,entityDao1);
//                  }
//                }
//                b = true;
//                break;
//              }
//              indexList++;
//            }
//            if(!b){
//              if(index == 0){
//                entityDao.setValue3(entityDao.getPat_name());
//                // add FNSI-No.25　帳票の追加順位  吉 start
//                if((sortId == ReportMenu.DIALYSIS_ROOM_GROUP || sortId ==ReportMenu.ROOM_BED_GROUP) && null != entityDao.getPat_name()){
//                  entityDao.setValue4(Integer.valueOf(entityDao.getPat_name()));
//                }
//                // add FNSI-No.25　帳票の追加順位  吉 end
//              }else if(index == 1){
//                entityDao.setValue2(entityDao.getPat_name());
//                // add FNSI-No.25　帳票の追加順位  吉 start
//                if((sortId == ReportMenu.DIALYSIS_ROOM_GROUP || sortId ==ReportMenu.ROOM_BED_GROUP) && null != entityDao.getPat_name()){
//                  entityDao.setValue4(Integer.valueOf(entityDao.getPat_name()));
//                }
//                // add FNSI-No.25　帳票の追加順位  吉 end
//              }else{
//                entityDao.setValue1(entityDao.getPat_name());
//                // add FNSI-No.25　帳票の追加順位  吉 start
//                if((sortId == ReportMenu.DIALYSIS_ROOM_GROUP || sortId ==ReportMenu.ROOM_BED_GROUP) && null != entityDao.getPat_name()){
//                  entityDao.setValue4(Integer.valueOf(entityDao.getPat_name()));
//                }
//                // add FNSI-No.25　帳票の追加順位  吉 end
//              }
//              list.add(entityDao);
//            }
//          }
//          if(index == 0){
//            if("asc".equals(sortIdValue)){
//              // mod FNSI-No.25　帳票の追加順位  吉 start
////              value3 = Comparator.comparing(EntityDao::getValue3,Comparator.nullsLast(String::compareTo));
//              if(sortId == ReportMenu.DIALYSIS_ROOM_GROUP || sortId ==ReportMenu.ROOM_BED_GROUP){
//                value3 = Comparator.comparing(EntityDao::getValue4,Comparator.nullsLast(Comparator.naturalOrder()));
//              }else{
//                value3 = Comparator.comparing(EntityDao::getValue3,Comparator.nullsLast(String::compareTo));
//              }
//              // mod FNSI-No.25　帳票の追加順位  吉 end
//            }else{
//              // mod FNSI-No.25　帳票の追加順位  吉 start
////              value3 = Comparator.comparing(EntityDao::getValue3,Comparator.nullsLast(String::compareTo)).reversed();
//              if(sortId == ReportMenu.DIALYSIS_ROOM_GROUP || sortId ==ReportMenu.ROOM_BED_GROUP){
//                value3 = Comparator.comparing(EntityDao::getValue4,Comparator.nullsFirst(Comparator.naturalOrder())).reversed();
//              }else{
//                value3 = Comparator.comparing(EntityDao::getValue3,Comparator.nullsLast(String::compareTo)).reversed();
//              }
//              // mod FNSI-No.25　帳票の追加順位  吉 end
//            }
//          }else if(index == 1){
//            // mod FNSI-No.25　帳票の追加順位  吉 start
////            if("asc".equals(sortIdValue)){
////              value2 = Comparator.comparing(EntityDao::getValue2,Comparator.nullsLast(String::compareTo));
////            }else{
////              value2 = Comparator.comparing(EntityDao::getValue2,Comparator.nullsLast(String::compareTo)).reversed();
////            }
//            if("asc".equals(sortIdValue)){
//              if(sortId == ReportMenu.DIALYSIS_ROOM_GROUP || sortId ==ReportMenu.ROOM_BED_GROUP){
//                value2 = Comparator.comparing(EntityDao::getValue4,Comparator.nullsLast(Comparator.naturalOrder()));
//              }else{
//                value2 = Comparator.comparing(EntityDao::getValue2,Comparator.nullsLast(String::compareTo));
//              }
//            }else{
//              if(sortId == ReportMenu.DIALYSIS_ROOM_GROUP || sortId ==ReportMenu.ROOM_BED_GROUP){
//                value2 = Comparator.comparing(EntityDao::getValue4,Comparator.nullsFirst(Comparator.naturalOrder())).reversed();
//              }else{
//                value2 = Comparator.comparing(EntityDao::getValue2,Comparator.nullsLast(String::compareTo)).reversed();
//              }
//            }
//            // mod FNSI-No.25　帳票の追加順位  吉 end
//          }else{
//            // mod FNSI-No.25　帳票の追加順位  吉 start
////            if("asc".equals(sortIdValue)){
////              value1 = Comparator.comparing(EntityDao::getValue1,Comparator.nullsLast(String::compareTo));
////            }else{
////              value1 = Comparator.comparing(EntityDao::getValue1,Comparator.nullsLast(String::compareTo)).reversed();
////            }
//            if("asc".equals(sortIdValue)){
//              if(sortId == ReportMenu.DIALYSIS_ROOM_GROUP || sortId ==ReportMenu.ROOM_BED_GROUP){
//                value1 = Comparator.comparing(EntityDao::getValue4,Comparator.nullsLast(Comparator.naturalOrder()));
//              }else{
//                value1 = Comparator.comparing(EntityDao::getValue1,Comparator.nullsLast(String::compareTo));
//              }
//            }else{
//              if(sortId == ReportMenu.DIALYSIS_ROOM_GROUP || sortId ==ReportMenu.ROOM_BED_GROUP){
//                value1 = Comparator.comparing(EntityDao::getValue4,Comparator.nullsFirst(Comparator.naturalOrder())).reversed();
//              }else{
//                value1 = Comparator.comparing(EntityDao::getValue1,Comparator.nullsLast(String::compareTo)).reversed();
//              }
//            }
//            // mod FNSI-No.25　帳票の追加順位  吉 end
//          }
//        }
//			}
//			if(value1 == null){
//			  if(value2 == null){
//          list.sort(value3);
//        }else if(value3 == null){
//			    list.sort(value2);
//        }else{
//          list.sort(value2.thenComparing(value3));
//        }
//      }else{
//			  if(value2 == null && value3 == null){
//          list.sort(value1);
//        }else if(value2 == null){
//          list.sort(value1.thenComparing(value3));
//        }else if(value3 == null){
//          list.sort(value1.thenComparing(value2));
//        }else{
//          list.sort(value1.thenComparing(value2).thenComparing(value3));
//        }
//      }
//      List<Long> longList = new ArrayList<>();
//      for(EntityDao entityDao : list){
//        longList.add(entityDao.getPat_id());
//      }
//      this.currentPatIds = longList;
//      /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end*/
//		}
//		//add 帳票出力時に並び替え設定を入力しても設定した並び替え順に出力されない  吉 start
//    else{
//      currentPatIds=new ArrayList<>();
//    }
//    //add 帳票出力時に並び替え設定を入力しても設定した並び替え順に出力されない  吉 end
//		// Re-sort if currentPatIds duplicate values
////		if (this.currentPatIds.size() > 0 && this.currentPatIds.size() != patIds.size()) {
////			for (Long id : this.currentPatIds) {
////				int index = this.tmpIds.indexOf(id);
////				if (index < 0){
////					this.tmpIds.add(id);
////				}
////			}
////			this.currentPatIds = tmpIds;
////		}
//
//		if (results.size() > 0 && this.currentPatIds.size() > 0) {
//			for (Long id : this.currentPatIds) {
//				for (OrdMain itemOrd : results) {
//					if (itemOrd.getPatId().equals(id) ) {
//						newResults.add(itemOrd);
//					}
//				}
//			}
//			results = newResults;
//		}
    // del 9323 帳票「並び替え」機能のオーバーホール　吉 end
		return results;
	}

	/**
	 *
	 * {@inheritDoc}
	 */
	@Override
	public List<Map<Long, List<String>>> getHtmlReport(ReportMenuSortContainer reportMenu, String userName) throws Exception {
		List<Map<Long, List<String>>> htmlReportList = new ArrayList<>();
    /*add FNSI-改修内容装置帳票の対応 任 start*/
		if(reportMenu.getReportClass().equals(ReportConstant.ReportClass.MACHINE_REPORT)){
      // add #6426 「定期点検の帳票がシステムエラーとなる。」について、修正する。 start
      //del 6502 6498 5984 定期・日常が分離されていない 吉 start
//      MstReport mstReport = getMstReport(reportMenu.getReportCd());
//      Workbook wb = getReportWorkbook(mstReport, getReportZip(mstReport));
//      Sheet baseSt = wb.getSheet("設定");
//      String reportTyppe = baseSt.getRow(50).getCell(0).toString().split(",")[0];
        //del 6502 6498 5984 定期・日常が分離されていない 吉 start
      if (reportMenu.getReportCd()>0) {
        Map<String, Object> dataKey = new HashMap<>();
        List<String> reportHtml = new ArrayList<>();
        List<Map<String, Object>> machines = new ArrayList<>();
        Map<String, Object> machine = new HashMap<>();

        for(int i = 0; i < reportMenu.getMachines().size(); i++) {
          machine = new HashMap<>();
          // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
          Map<String,List> searchList =this.searchMap(reportMenu.getFacilityCd());
          dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
          dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
          dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
          // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
          machine.put(ReportConstant.ReportDataKey.DATE_FROM, reportMenu.getFromDate() != null ? reportMenu.getFromDate() : reportMenu.getSpecifyDate());
          machine.put(ReportConstant.ReportDataKey.DATE_TO, reportMenu.getToDate() != null ? reportMenu.getToDate() : reportMenu.getSpecifyDate());
          machine.put(ReportConstant.ReportDataKey.DATE, reportMenu.getSpecifyDate());
          machine.put(ReportConstant.ReportDataKey.MACHINE_NO,reportMenu.getMachines().get(i).getMachineNo());
          machines.add(machine);
        }
        dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, reportMenu.getFromDate() != null ? reportMenu.getFromDate() : reportMenu.getSpecifyDate());
        dataKey.put(ReportConstant.ReportDataKey.DATE_TO, reportMenu.getToDate() != null ? reportMenu.getToDate() : reportMenu.getSpecifyDate());
        dataKey.put(ReportConstant.ReportDataKey.DATE, reportMenu.getSpecifyDate());

        dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, machines);
        String html = reportService.getReportHtml(reportMenu.getReportCd(), dataKey, null, null);
        reportHtml.add(html);
        if (reportHtml.size() > 0) {
          Map<Long, List<String>> reportMap = new HashMap<>();
          reportMap.put(Long.parseLong(0+""), reportHtml);
          htmlReportList.add(reportMap);
        }
      } else {
      // add #6426 「定期点検の帳票がシステムエラーとなる。」について、修正する。 end
        for(int i = 0;i<reportMenu.getMachines().size();i++){
          String date = "";
          Map<String, Object> dataKey = new HashMap<>();
          List<String> reportHtml = new ArrayList<>();
          if(reportMenu.getSpecifyDate() != null){
            date = reportMenu.getSpecifyDate();
            dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, date);
            dataKey.put(ReportConstant.ReportDataKey.DATE_TO, date);
            //add 6502 6498 5984 定期・日常が分離されていない 吉 start
            dataKey.put(ReportConstant.ReportDataKey.DATE, date);
            //add 6502 6498 5984 定期・日常が分離されていない 吉 end
            // add UT帳票No.127 特殊帳票「交換部品記録簿」PDFとExcel出力の対応 夏 start
            //mod 6502 6498 5984 定期・日常が分離されていない 吉 start
//if(reportMenu.getReportCd() == null){
            if(reportMenu.getReportCd() < 0){
              //mod 6502 6498 5984 定期・日常が分離されていない 吉 end
              //mod 6502 装置帳票：定期・日常が分離されていない 吉 start
//List<Long> reportCdList = getReportCdList(reportMenu,i,date);
              // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
              //List<Long> reportCdList = getReportCdList(reportMenu,i,date,reportMenu.getReportCd() == -5 ? "2" : "1");
              List<Long> reportCdList = new ArrayList<>();
              if(reportMenu.getReportCd() == CoreConstant.FixedReportCd.DAILY_INSPECT_RECORD_BOOK){
                reportCdList = getReportCdList(reportMenu, i, date, "1");
              }
              else if(reportMenu.getReportCd() == CoreConstant.FixedReportCd.PERIODIC_INSPECT_RECORD_BOOK){
                reportCdList = getReportCdList(reportMenu, i, date, "2");
              }
              // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe start
              else if(reportMenu.getReportCd() == CoreConstant.FixedReportCd.WATER_SURVEY_RECORD_BOOK){
                reportCdList = getReportCdList(reportMenu, i, date, "3");
              }
              // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe end
              // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
              //mod 6502 装置帳票：定期・日常が分離されていない 吉 end
              dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, reportMenu.getMachines().get(i).getMachineNo());
              if(reportCdList.size()>0){
                for(int k =0 ;k<reportCdList.size();k++){
                  String html = reportService.getReportHtml(reportCdList.get(k), dataKey, null, null);
                  reportHtml.add(html);
                }
              }
            }else{
              dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, reportMenu.getMachines().get(i).getMachineNo());
              String html = reportService.getReportHtml(reportMenu.getReportCd(), dataKey, null, null);
              reportHtml.add(html);
            }
            // add UT帳票No.127 特殊帳票「交換部品記録簿」PDFとExcel出力の対応 夏 end
          }else{
            String fromDate = reportMenu.getFromDate();
            String toDate = reportMenu.getToDate();
            dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate);
            dataKey.put(ReportConstant.ReportDataKey.DATE_TO, toDate);
            SimpleDateFormat sdf=new SimpleDateFormat("yyyyMMdd");
            Calendar cal = Calendar.getInstance();
            cal.setTime(sdf.parse(fromDate));
            long time1 = cal.getTimeInMillis();
            cal.setTime(sdf.parse(toDate));
            long time2 = cal.getTimeInMillis();
            long between_days=(time2-time1)/(1000*3600*24);
            // mod UT帳票No.127 特殊帳票「交換部品記録簿」PDFとExcel出力の対応 夏 start
//          for(int j = 0;j<between_days ;j++){
//            Calendar calendar = new GregorianCalendar();
//            calendar.setTime(sdf.parse(reportMenu.getFromDate()));
//            calendar.add(calendar.DATE,j);
//            date=sdf.format(calendar.getTime());
//          }
            Calendar calendar = new GregorianCalendar();
            calendar.setTime(sdf.parse(reportMenu.getFromDate()));
            List<String> strHtmlTemp = new ArrayList<>();
            boolean htmlFlg = false;
            for (int j = 0; j <= between_days; j++) {
              date = sdf.format(calendar.getTime());
              dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD,reportMenu.getFacilityCd());
              dataKey.put(ReportConstant.ReportDataKey.DATE,date);
              if(reportMenu.getReportCd() == null){
                //mod 6502 装置帳票：定期・日常が分離されていない 吉 start
//                List<Long> reportCdList = getReportCdList(reportMenu,i,date);
                // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
                //List<Long> reportCdList = getReportCdList(reportMenu,i,date,reportMenu.getReportCd() == -5 ? "2" : "1");
                List<Long> reportCdList = new ArrayList<>();
                if(reportMenu.getReportCd() == CoreConstant.FixedReportCd.DAILY_INSPECT_RECORD_BOOK){
                  reportCdList = getReportCdList(reportMenu, i, date, "1");
                }
                else if(reportMenu.getReportCd() == CoreConstant.FixedReportCd.PERIODIC_INSPECT_RECORD_BOOK){
                  reportCdList = getReportCdList(reportMenu, i, date, "2");
                }
                // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe start
                else if(reportMenu.getReportCd() == CoreConstant.FixedReportCd.WATER_SURVEY_RECORD_BOOK){
                  reportCdList = getReportCdList(reportMenu, i, date, "3");
                }
                // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe end
                // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
                //mod 6502 装置帳票：定期・日常が分離されていない 吉 end
                dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, reportMenu.getMachines().get(i).getMachineNo());
                if(reportCdList.size()>0){
                  for(int k =0 ;k<reportCdList.size();k++){
                    htmlFlg = true;
                    for (String dataList : strHtmlTemp) {
                      if (dataList.equals(reportService.getReportHtml(reportCdList.get(k), dataKey, null, null))) {
                        htmlFlg = false;
                        break;
                      }
                    }
                    if(htmlFlg == true){
                      String html = reportService.getReportHtml(reportCdList.get(k), dataKey, null, null);
                      reportHtml.add(html);
                      strHtmlTemp.add(reportService.getReportHtml(reportCdList.get(k), dataKey, null, null));
                    }
                  }
                }
              }else{
                dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, reportMenu.getMachines().get(i).getMachineNo());
                String html = reportService.getReportHtml(reportMenu.getReportCd(), dataKey, null, null);
                reportHtml.add(html);
              }
              calendar.add(calendar.DATE, 1);
            }
          }
//        if(reportMenu.getReportCd() == null){
//          List<Long> reportCdList = getReportCdList(reportMenu,i,date);
//          dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, reportMenu.getMachines().get(i).getMachineNo());
//          if(reportCdList.size()>0){
//            for(int k =0 ;k<reportCdList.size();k++){
//              String html = reportService.getReportHtml(reportCdList.get(k), dataKey, null, null);
//              reportHtml.add(html);
//            }
//          }
//        }else{
//          dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, reportMenu.getMachines().get(i).getMachineNo());
//          String html = reportService.getReportHtml(reportMenu.getReportCd(), dataKey, null, null);
//          reportHtml.add(html);
//        }
          // mod UT帳票No.127 特殊帳票「交換部品記録簿」PDFとExcel出力の対応 夏 end
          if (reportHtml.size() > 0) {
            Map<Long, List<String>> reportMap = new HashMap<>();
            reportMap.put(Long.parseLong(i+""), reportHtml);
            htmlReportList.add(reportMap);
          }
        }
      // add #6426 「定期点検の帳票がシステムエラーとなる。」について、修正する。 start
      }
      // add #6426 「定期点検の帳票がシステムエラーとなる。」について、修正する。 end
      // mod  #5714 紹介状が正しく出力できない  2021-11-23 孟堅  start
    }else if(reportMenu.getReportClass().equals(ReportConstant.ReportClass.INTRODUCTION_REPORT)){
      /*add FNSI-改修内容装置帳票の対応 任 end*/
      Long reportCd = reportMenu.getReportCd();
      HashMap<Long, List<Long>> patOrdNo = getOrdNoList(reportMenu);
      for (Long key : patOrdNo.keySet()) {
        List<String> reportHtml = new ArrayList<>();
        List<Long> values = patOrdNo.get(key);
          Map<String, Object> dataKey = new HashMap<>();
          dataKey.put("ordNo", values.get(0));
          dataKey.put("patId", key.toString());
          dataKey.put("login", userName);
          //add 帳票用のパラメーター設定処理  吉 start
          if(null == reportMenu.getFromDate() || null ==reportMenu.getToDate()){
            dataKey.put(ReportConstant.ReportDataKey.DATE_FROM,dateStr2dispDateStr(reportMenu.getSpecifyDate()));
            dataKey.put(ReportConstant.ReportDataKey.DATE_TO,dateStr2dispDateStr(reportMenu.getSpecifyDate()));
            dataKey.put(ReportConstant.ReportDataKey.DATE,reportMenu.getSpecifyDate());
          }else{
            dataKey.put(ReportConstant.ReportDataKey.DATE,reportMenu.getFromDate());
            dataKey.put(ReportConstant.ReportDataKey.DATE_FROM,dateStr2dispDateStr(reportMenu.getFromDate()));
            dataKey.put(ReportConstant.ReportDataKey.DATE_TO,dateStr2dispDateStr(reportMenu.getToDate()));
          }
          dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD,reportMenu.getFacilityCd());
          List<Long> prescriptionList = ordPrescriptionDao.getPrescriptionListByPatId(key,reportMenu.getFacilityCd());
          if(null != prescriptionList && prescriptionList.size()>0){
            dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS,prescriptionList);
          }else{
            dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS,0);
          }
          //add 帳票用のパラメーター設定処理  吉 end
          // add UT障害票一覧_帳票No.88 フィルタデータ出力不良 夏 start
          dataKey.put(ReportConstant.ReportDataKey.DATE, null != reportMenu.getSpecifyDate() ? dateStr2dispDateStr(reportMenu.getSpecifyDate()) : null);
          // add UT障害票一覧_帳票No.88 フィルタデータ出力不良 夏 end
          //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
          dataKey.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
          // mod #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 start
          //dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getTreatDate());
          dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate());
          // mod #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 end
          dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
          dataKey.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
          dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
        // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
        // 薬剤分類の設定
          List<Integer> medicineCdList =
            reportMenu.getMedicineCdList() == null || reportMenu.getMedicineCdList().isEmpty()
              ? Collections.singletonList(0)
              :  reportMenu.getMedicineCdList();
          dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS, medicineCdList);

          // ダイアライザの設定
          List<Integer> dialyzerCdList =
            reportMenu.isDialyzer()
              ? getDialyzerCdList(reportMenu.getFacilityCd())
              : Collections.singletonList(0);
          dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS, dialyzerCdList);

          // 医療材料区分の設定
          List<Integer> equipmentCdList =
            reportMenu.getEquipmentCdList() == null || reportMenu.getEquipmentCdList().isEmpty()
              ? Collections.singletonList(0)
              : reportMenu.getEquipmentCdList();
          dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, equipmentCdList);
        // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
          // add 項目別(印刷情報一覧)の項目が実装されない  吉 end
          //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 start
//          if(reportCd == -3 || reportCd == -2){
//            reportCd = getTemplateReportCd(reportMenu.getFacilityCd(),values.get(index),reportCd);
//          }
          //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 end
          String html = reportService.getReportHtml(reportCd, dataKey, null, Long.parseLong(key.toString()));
          reportHtml.add(html);
        if (reportHtml.size() > 0) {
          Map<Long, List<String>> reportMap = new HashMap<>();
          reportMap.put(key, reportHtml);
          htmlReportList.add(reportMap);
        }
      }
      /*add FNSI-改修内容装置帳票の対応 任 start*/
		 // mod #5714 紹介状が正しく出力できない  2021-11-23 孟堅 end
    }
		else{
      /*add FNSI-改修内容装置帳票の対応 任 end*/
      // mod #6426 2022-01-12 定期点検の帳票がシステムエラーとなる。 孟堅 start
      //Long reportCd = reportMenu.getReportCd();
      // mod #6426 2022-01-12 定期点検の帳票がシステムエラーとなる。 孟堅 end
      HashMap<Long, List<Long>> patOrdNo = getOrdNoList(reportMenu);
      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
      Map<String,List> searchList =this.searchMap(reportMenu.getFacilityCd());
      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
      for (Long key : patOrdNo.keySet()) {
        List<String> reportHtml = new ArrayList<>();
        List<Long> values = patOrdNo.get(key);
        for (int index = 0; index < values.size(); index++) {
          Map<String, Object> dataKey = new HashMap<>();
          // add #6426 2022-01-12 定期点検の帳票がシステムエラーとなる。 孟堅 start
           Long reportCd = reportMenu.getReportCd();
          // add #6426 2022-01-12 定期点検の帳票がシステムエラーとなる。 孟堅 end
          // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
          // if (reportMenu.getReportClass().equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT)){
          //  dataKey = createDistributionListDataKey(reportMenu,new ArrayList<Long>(){{add(key);}});
          // }
          if (reportMenu.getReportClass().equals(ReportConstant.ReportClass.DIALYSIS_REPORT) ||
            reportMenu.getReportClass().equals(ReportConstant.ReportClass.ONE_PATIENT_REPORT) ){
            dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
            dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
            dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
          }else{
            dataKey = createDistributionListDataKey(reportMenu,new ArrayList<Long>(){{add(key);}});

          }
          // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
          dataKey.put("ordNo", values.get(index));
          dataKey.put("patId", key.toString());
          dataKey.put("login", userName);
          //add 帳票用のパラメーター設定処理  吉 start
          if(null == reportMenu.getFromDate() || null ==reportMenu.getToDate()){
            dataKey.put(ReportConstant.ReportDataKey.DATE_FROM,dateStr2dispDateStr(reportMenu.getSpecifyDate()));
            dataKey.put(ReportConstant.ReportDataKey.DATE_TO,dateStr2dispDateStr(reportMenu.getSpecifyDate()));
            dataKey.put(ReportConstant.ReportDataKey.DATE,reportMenu.getSpecifyDate());
          }else{
            dataKey.put(ReportConstant.ReportDataKey.DATE,reportMenu.getFromDate());
            dataKey.put(ReportConstant.ReportDataKey.DATE_FROM,dateStr2dispDateStr(reportMenu.getFromDate()));
            dataKey.put(ReportConstant.ReportDataKey.DATE_TO,dateStr2dispDateStr(reportMenu.getToDate()));
          }
          dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD,reportMenu.getFacilityCd());
          //add 帳票用のパラメーター設定処理  吉 end
          // add UT障害票一覧_帳票No.88 フィルタデータ出力不良 夏 start
          dataKey.put(ReportConstant.ReportDataKey.DATE, null != reportMenu.getSpecifyDate() ? dateStr2dispDateStr(reportMenu.getSpecifyDate()) : null);
          // add UT障害票一覧_帳票No.88 フィルタデータ出力不良 夏 end
          //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
          dataKey.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
          // mod #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 start
          //dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getTreatDate());
          dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate());
          // mod #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 end
          dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
          dataKey.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
          dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
          // add 項目別(印刷情報一覧)の項目が実装されない  吉 end
                    //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 start
          // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
          //if(reportCd == -3 || reportCd == -2)
          if(reportCd == CoreConstant.FixedReportCd.DIALYSIS_REPORT
            || reportCd == CoreConstant.FixedReportCd.DIALYSIS_REPORT_HANDWRITTEN
          )
          // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
          {
            reportCd = getTemplateReportCd(reportMenu.getFacilityCd(),values.get(index),reportCd);
          }
          //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 end
          //add  #6346 処方の項目が足りない 吉 start
          List<Long> prescriptionList = ordPrescriptionDao.getPrescriptionListByPatId(key,reportMenu.getFacilityCd());
          if(null != prescriptionList && prescriptionList.size() >0 && reportMenu.getReportClass().equals(ReportConstant.ReportClass.ONE_PATIENT_REPORT)
          && reportMenu.getReportType().equals("2")){
            if(null == reportMenu.getFromDate() || null ==reportMenu.getToDate()){
              dataKey.put(ReportConstant.ReportDataKey.DATE_FROM,dateStr2dispDateStr(reportMenu.getSpecifyDate()));
              dataKey.put(ReportConstant.ReportDataKey.DATE_TO,dateStr2dispDateStr(reportMenu.getSpecifyDate()));
              dataKey.put(ReportConstant.ReportDataKey.DATE,reportMenu.getSpecifyDate());
            }else{
              dataKey.put(ReportConstant.ReportDataKey.DATE,reportMenu.getFromDate());
              dataKey.put(ReportConstant.ReportDataKey.DATE_FROM,dateStr2dispDateStr(reportMenu.getFromDate()));
              dataKey.put(ReportConstant.ReportDataKey.DATE_TO,dateStr2dispDateStr(reportMenu.getToDate()));
            }
            for (int p = 0; p < prescriptionList.size(); p++){
              Map<String, Object> tmplPrescriptionParam = new HashMap<>();
              List<Map<String, Object>> tmplPrescriptionParams = new ArrayList<>();
              dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO,prescriptionList.get(p));
              tmplPrescriptionParam.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO, prescriptionList.get(p));
              tmplPrescriptionParam.put(ReportConstant.ReportDataKey.PAT_ID, key);
              tmplPrescriptionParam.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
              tmplPrescriptionParam.put(ReportConstant.ReportDataKey.DATE_FROM, reportMenu.getFromDate());
              tmplPrescriptionParam.put(ReportConstant.ReportDataKey.DATE_TO, reportMenu.getToDate());
              tmplPrescriptionParams.add(tmplPrescriptionParam);
              dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, tmplPrescriptionParams);
              String html = reportService.getReportHtml(reportCd, dataKey, null, Long.parseLong(key.toString()));
              reportHtml.add(html);
            }
          }else{
            //add  #6346 処方の項目が足りない 吉 end
            dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO,0);
            String html = reportService.getReportHtml(reportCd, dataKey, null, Long.parseLong(key.toString()));
            reportHtml.add(html);
            //add  #6346 処方の項目が足りない 吉 start
          }
          //add  #6346 処方の項目が足りない 吉 end
        }
        if (reportHtml.size() > 0) {
          Map<Long, List<String>> reportMap = new HashMap<>();
          reportMap.put(key, reportHtml);
          htmlReportList.add(reportMap);
        }
      }
      /*add FNSI-改修内容装置帳票の対応 任 start*/
    }

    /*add FNSI-改修内容装置帳票の対応 任 end*/
		return htmlReportList;
	}


  /**
   * 帳票生成時パラメータ.
   *
   */
  final class ReportParam {

    /**
     * オーダー番号.
     */
    Long ordNo;

    /**
     * 日付
     */
    String date;

    /**
     * 日付範囲 開始.
     */
    String dateFrom;

    /**
     * 日付範囲 終了.
     */
    String dateTo;

    /**
     * 患者ID
     */
    Long patId;

  }

  /**
   *
   * {@inheritDoc}
   */
  @Override
  public String getHtmlReportSorted(ReportMenuSortContainer reportMenu, Long userId, String userName) throws Exception {
    //add IES因島）sql性能試験 後で削除 liuc start
    Date beginTime = new Date();
    //add IES因島）sql性能試験 後で削除 liuc end

    Integer reportClass = reportMenu.getReportClass();
    String htmlResult = "";
    Long reportCd = reportMenu.getReportCd();
    List<OrdMain> patOrdNo = getOrdNoListSorted(reportMenu);
    // add #7927 帳票に患者情報が出力されない場合がある 王永吉 start
    List<OrdMain> patOrdNoDoOnePats = getOrdNoListSorted(reportMenu);
    if(null != patOrdNoDoOnePats && patOrdNoDoOnePats.size()>0 && !reportClass.equals(ReportConstant.ReportClass.LABEL_REPORT)){
      for(int i=patOrdNoDoOnePats.size();i>0 ;i--){
        if(patOrdNoDoOnePats.get(i-1).getOrdNo() != 0){
          patOrdNoDoOnePats.remove(i-1);
        }
      }
    }
    // add #7927 帳票に患者情報が出力されない場合がある 王永吉 end
    // add 6589 治癒経過表：プレビューでシステムエラー 吉 start
    // mod 5981 ラベルが検査に対応していない 吉 start
    //if(null != patOrdNo && patOrdNo.size()>0){
    if(null != patOrdNo && patOrdNo.size()>0 && !reportClass.equals(ReportConstant.ReportClass.LABEL_REPORT)){
      // mod 5981 ラベルが検査に対応していない 吉 end
      for(int i=patOrdNo.size();i>0 ;i--){
        if(patOrdNo.get(i-1).getOrdNo() == 0){
          patOrdNo.remove(i-1);
        }
      }
    }
    //add 6589 治癒経過表：プレビューでシステムエラー 吉 end
    // add 特殊二次元帳票「紹介状」帳票レイアウトの対応 start
    // 帳票マスタを取得する
    //mod 4748 5269 5402 6502治療方法ごとの治療経過表での出力ができない  吉 start
//    MstReport mstReport = reportService.getMstReport(reportCd);
    MstReport mstReport = new MstReport();
    // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
    //if(reportCd != -3L && reportCd != -2L && reportCd != -4L && reportCd != -5L)
    if(!reportServiceImpl.isFixedReport(reportCd))
    // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
    {
       mstReport = reportService.getMstReport(reportCd);
    }
    //mod 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 end
    // add 特殊二次元帳票「紹介状」帳票レイアウトの対応 end

    if (reportClass.equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT)) {
      // 配布リスト(ベッド)
      /*mod FNSI-改修内容 各帳票の並び順調整。 吉 start*/
      /*Map<String, Object> dataKey = createDistributionListDataKey(reportMenu);*/
      List<Long> patIds=new ArrayList<Long>();
      if(null != patOrdNo){
        for(int i=0;i<patOrdNo.size();i++){
          if(!patIds.contains(patOrdNo.get(i).getPatId())){
            patIds.add(patOrdNo.get(i).getPatId());
          }
        }
      }
      Map<String, Object> dataKey = createDistributionListDataKey(reportMenu,patIds);
      /*mod FNSI-改修内容 各帳票の並び順調整。 吉 end*/
      dataKey.put("login", userName);
      //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
      dataKey.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
      // mod #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 start
      //dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getTreatDate());
      dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate());
      // mod #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 end
      dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
      dataKey.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
      dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
      // add 項目別(印刷情報一覧)の項目が実装されない  吉 end
      // add #8182 帳票出力時にasposeを経由しないで出力される帳票がある 鄭爽 start
      dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
      // add #8182 帳票出力時にasposeを経由しないで出力される帳票がある 鄭爽 end
      htmlResult = reportService.getReportHtml(reportCd, dataKey, null, userId);

      // add FNSI-523 2次元帳票対応 夏 start
      // add 特殊二次元帳票「紹介状」帳票レイアウトの対応 start
      // add #6070 帳票メニューで複数患者を選択してプレビューすると表示されるのは先頭の1患者のみ 孟堅 start
    }  else if (reportClass == ReportConstant.ReportClass.ONE_TOTAL_REPORT
      || (reportClass == ReportConstant.ReportClass.INTRODUCTION_REPORT && null != mstReport.getReportType() && mstReport.getReportType() == 1)) {
      // add 特殊二次元帳票「紹介状」帳票レイアウトの対応 end
      // 単一集計 複数集計

      List<Long> patIds = reportMenu.getPatIds();
      LocalDate nowDate = LocalDate.now();
      String nowYYYYMMDD = nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));

      List<ReportParam> params = new ArrayList<>();

      Long patId;

      if (reportMenu.getIsDialysisDate()) {
        // 透析日基準

        // 患者IDリストで渡された患者の期間内での最新の確定透析実績を取得する
        // 透析実績が取得できない場合は、期間内で今日以降の直近予定を取得する
        // 透析実績、透析予定ともに存在しない場合は、期間終了日の患者情報のみを取得する

        for (int index = 0; index < patIds.size(); index++) {
          patId = patIds.get(index);
          ReportParam reportParam = new ReportParam();
          String dateString;

          List<OrdMain> ordList;

          if(reportClass == ReportConstant.ReportClass.ONE_TOTAL_REPORT) {
            // 最新の確定実績を取得する
            ordList = reportMenuDao.selectResultByTreatDate(patId, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
            // add #6035 2021-12-27 紹介状で曜日単位の投与マトリクスが表示できない 孟堅 start
          }else if(reportClass == ReportConstant.ReportClass.INTRODUCTION_REPORT && mstReport.getReportType() == 1){
            ordList = reportMenuDao.selectByTreatDate(patId, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
          }
            // add #6035 2021-12-27 紹介状で曜日単位の投与マトリクスが表示できない 孟堅 end
          else{
            ordList = reportMenuDao.selectByTreatDate(patId, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
          }
           //　add　#6035 2021-12-27 紹介状で曜日単位の投与マトリクスが表示できない 孟堅 start
          if(reportClass == ReportConstant.ReportClass.INTRODUCTION_REPORT && mstReport.getReportType() == 1){
            if(ordList.size() > 0)
            {
              // 最新の確定実績 治療日降順でソートしているので、1レコード目が最新
              for(int i = 0; i < ordList.size(); i++) {
                reportParam = new ReportParam();
                OrdMain ordMain = ordList.get(i);
                reportParam.ordNo = ordMain.getOrdNo();
                final String treatDate = dateStr2dispDateStr(ordMain.getTreatDate());
                dateString = treatDate;
                //add ２次元帳票週間薬剤集計表対応   吉 end
                dateString = dateString.replace("/","");
                //add ２次元帳票週間薬剤集計表対応   吉 end
                reportParam.patId = patId;
                reportParam.date = dateString;
                if(reportMenu.getFromDate() == null){
                  reportParam.dateFrom = dateString;
                }else {
                  reportParam.dateFrom = reportMenu.getFromDate();
                }
                if(reportMenu.getToDate() == null){
                  reportParam.dateTo = dateString;
                }else {
                  reportParam.dateTo = reportMenu.getToDate();
                }
                params.add(reportParam);
              }
            }
          }else{
            // #6035 2021-12-27 紹介状で曜日単位の投与マトリクスが表示できない 孟堅 end
            if(ordList.size() > 0)
            {
              // 最新の確定実績 治療日降順でソートしているので、1レコード目が最新
              for(int i = 0; i < ordList.size(); i++) {
                reportParam = new ReportParam();
                OrdMain ordMain = ordList.get(i);
                reportParam.ordNo = ordMain.getOrdNo();
                final String treatDate = dateStr2dispDateStr(ordMain.getTreatDate());
                dateString = treatDate;
                //add ２次元帳票週間薬剤集計表対応   吉 end
                dateString = dateString.replace("/","");
                //add ２次元帳票週間薬剤集計表対応   吉 end
                reportParam.patId = patId;
                reportParam.date = dateString;
                if(reportMenu.getFromDate() == null){
                  reportParam.dateFrom = dateString;
                }else {
                  reportParam.dateFrom = reportMenu.getFromDate();
                }
                if(reportMenu.getToDate() == null){
                  reportParam.dateTo = dateString;
                }else {
                  reportParam.dateTo = reportMenu.getToDate();
                }
                params.add(reportParam);
              }
            } else {
              // 治療予定を取得する. ここに到達するということは、指定期間内に確定実績はない

              // この患者の直近1件の治療予定を取得
              OrdMain near = reportMenuDao.selectNearOrdPlan(patId, nowYYYYMMDD);
              if (near != null) {

                // ord_mainから取得

                // 治療予定
                reportParam.ordNo = near.getOrdNo();
                final String treatDate = dateStr2dispDateStr(near.getTreatDate());
                dateString = treatDate;

              } else {

                // 透析実績、透析予定ともに存在しない場合は、期間終了日の患者情報のみを取得する

                final String toDate;
                if (reportMenu.getSpecifyDate() == null) {
                  // 範囲指定
                  // 期間終了日
                  toDate = reportMenu.getToDate();

                } else {
                  // 1日指定
                  // 特定日付
                  toDate = reportMenu.getSpecifyDate();

                }
                dateString = toDate;

              }
              reportParam.patId = patId;
              //add ２次元帳票週間薬剤集計表対応   吉 end
              dateString = dateString.replace("/","");
              //add ２次元帳票週間薬剤集計表対応   吉 end
              reportParam.date = dateString;
              if(reportMenu.getFromDate() == null){
                reportParam.dateFrom = dateString;
              }else {
                reportParam.dateFrom = reportMenu.getFromDate();
              }
              if(reportMenu.getToDate() == null){
                reportParam.dateTo = dateString;
              }else {
                reportParam.dateTo = reportMenu.getToDate();
              }
              params.add(reportParam);
            }
          }
        }
      } else if (reportMenu.getRegOrderClassList().size() > 0) {
        for (int index = 0; index < patIds.size(); index++){
          patId = patIds.get(index);
          ReportParam reportParam = new ReportParam();
          reportParam.patId = patId;
          // 検査結果
          List<PatExamMain> examMainList =  new ArrayList<>();
          // 検索区分
          List<String> regOrderClassList = reportMenu.getRegOrderClassList();
          // 日付がどのように選択されているか確認して、検査結果リストを取得する
          String fromDate;
          String toDate;
          if (reportMenu.getSpecifyDate() == null) {
            // 期間指定
            fromDate = reportMenu.getFromDate();
            toDate = reportMenu.getToDate();
            LocalDateTime localDateFrom = LocalDate.parse(reportMenu.getFromDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
            LocalDateTime localDateTo = LocalDate.parse(reportMenu.getToDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
            localDateTo = localDateTo.plusDays(1L).minusNanos(1000);
            examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateFrom), Timestamp.valueOf(localDateTo), regOrderClassList);
          } else {
            // 1日指定
            fromDate = reportMenu.getSpecifyDate();
            toDate = reportMenu.getSpecifyDate();
            LocalDateTime localDateTarget = LocalDate.parse(reportMenu.getSpecifyDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
            LocalDateTime localDateTo = localDateTarget.plusDays(1L).minusNanos(1000);
            examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateTarget), Timestamp.valueOf(localDateTo), regOrderClassList);
          }

          boolean isNotExistExamResult = true;
          for (PatExamMain exam : examMainList) {
            // 検査日リスト
            // 期間内での最新の検査結果の検査日を取得する

            if (Objects.equal(exam.getExamStatus(), "1")) {
              // 検査結果
              // 検査日時が最新であるか判定する処理を実装する
              isNotExistExamResult = false;
              String uuuuMMdd = exam.getResultExamDate().toLocalDateTime().toLocalDate().format(DateTimeFormatter.ofPattern("uuuuMMdd"));
              reportParam.date = dateStr2dispDateStr(uuuuMMdd);
              reportParam.dateFrom = dateStr2dispDateStr(fromDate);
              reportParam.dateTo = dateStr2dispDateStr(toDate);

            } else if(isNotExistExamResult) {
              // 検査予定
              String uuuuMMdd = exam.getRegExamDate().toLocalDateTime().toLocalDate().format(DateTimeFormatter.ofPattern("uuuuMMdd"));
              reportParam.date = dateStr2dispDateStr(uuuuMMdd);
              reportParam.dateFrom = dateStr2dispDateStr(fromDate);
              reportParam.dateTo = dateStr2dispDateStr(toDate);
            }

          }

          // 透析実績と紐づける
          List<OrdMain> ordList = reportMenuDao.selectByTreatDate(patId, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
          List<OrdMain> ords = ordList.stream().filter(
            o -> Objects.equal(o.getTreatDate(), reportParam.date == null ? null : reportParam.date.replace("/", ""))).collect(Collectors.toList());
          if (ords.size() > 0) {
            reportParam.ordNo = ords.get(ords.size() - 1).getOrdNo();
          }

          params.add(reportParam);

        }

      }
      Map<String, Object> dataKey = new HashMap<>();
      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
      if (reportMenu.getMedicineCdList() != null && reportMenu.getMedicineCdList().size() > 0) {
        dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS, reportMenu.getMedicineCdList());
      } else {
        dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS, Collections.singletonList(0));
      }
      List<Integer> listDia = new ArrayList<>();
      if (reportMenu.isDialyzer()) {
        for (MstDialyzer item : mstInfoService.findMstDialyzerAllByFacillityCd(reportMenu.getFacilityCd())) {
          listDia.add(item.getDialyzerCd());
        }
        dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS, listDia);
        reportMenu.getEquipmentCdList().add(0);
      } else {
        dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS, Collections.singletonList(0));
      }
      List<Integer> equipmentCdList = new ArrayList<>();
      if (reportMenu.getEquipmentCdList() != null && reportMenu.getEquipmentCdList().size() > 0) {
        equipmentCdList = reportMenu.getEquipmentCdList();
        dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, equipmentCdList);
      } else {
        dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, Collections.singletonList(0));
      }
      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
      dataKey.put(ReportConstant.ReportDataKey.DATE, nowYYYYMMDD);
      List<Long> listPat = new ArrayList<>();
      for (int i = 0; i < patIds.size(); i++) {
        List<Map<String, Object>> tmplParams = new ArrayList<Map<String, Object>>();
          // add #6035  2021-12-27 紹介状で曜日単位の投与マトリクスが表示できない 孟堅 start
        // del 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
        // if(reportClass == ReportConstant.ReportClass.INTRODUCTION_REPORT && mstReport.getReportType() == 1){
        // del 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
          for(int param = 0; param < params.size() ; param++){
            if(params.get(param).patId.equals(patIds.get(i))){
              Map<String, Object> tmplParam = new HashMap<>();
              // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
              tmplParam.put(ReportConstant.ReportDataKey.DIALYZER_IDS,dataKey.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
              tmplParam.put(ReportConstant.ReportDataKey.MEDICINE_IDS,dataKey.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
              tmplParam.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,dataKey.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
              // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
              tmplParam.put(ReportConstant.ReportDataKey.ORD_NO,params.get(param).ordNo);
              tmplParam.put(ReportConstant.ReportDataKey.PAT_ID, params.get(param).patId);
              tmplParam.put(ReportConstant.ReportDataKey.PAT_IDS, listPat);
              //mod 項目別(印刷情報一覧)の項目が実装されない  吉 start
              if(null != reportMenu.getSpecifyDate()){
                String treatDateFormatted = params.get(param).dateFrom.substring(0,4) + "-" +  params.get(param).dateFrom.substring(4,6) + "-" +  params.get(param).dateFrom.substring(6);
                String[] result = getStartAndEndDayByDate(treatDateFormatted);
                tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, result[0].replace("-",""));
                tmplParam.put(ReportConstant.ReportDataKey.DATE_TO, result[1].replace("-",""));
              }else{
                tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, params.get(param).dateFrom);
                tmplParam.put(ReportConstant.ReportDataKey.DATE_TO, params.get(param).dateTo);
              }
              tmplParam.put(ReportConstant.ReportDataKey.DATE, params.get(param).date.replace("/",""));
              // del #7641 自動印刷で値が入らない項目がある 王永吉 start
              // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
              // tmplParam.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getTreatDate());
              // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
              // del #7641 自動印刷で値が入らない項目がある 王永吉 end
              //mod 項目別(印刷情報一覧)の項目が実装されない  吉 start
              tmplParam.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
              tmplParams.add(tmplParam);
            }
          }
        // del 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 start
//        }else{
//          // add #6035 2021-12-27 紹介状で曜日単位の投与マトリクスが表示できない  孟堅 end
//          ReportParam param =params.get(i);
//          Map<String, Object> tmplParam = new HashMap<>();
//          // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
//          tmplParam.put(ReportConstant.ReportDataKey.DIALYZER_IDS,dataKey.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
//          tmplParam.put(ReportConstant.ReportDataKey.MEDICINE_IDS,dataKey.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
//          tmplParam.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,dataKey.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
//          // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
//          tmplParam.put(ReportConstant.ReportDataKey.ORD_NO, param.ordNo);
//          tmplParam.put(ReportConstant.ReportDataKey.PAT_ID, param.patId);
//          tmplParam.put(ReportConstant.ReportDataKey.PAT_IDS, listPat);
//          //mod 項目別(印刷情報一覧)の項目が実装されない  吉 start
//          if(null != reportMenu.getSpecifyDate()){
//            String treatDateFormatted = param.dateFrom.substring(0,4) + "-" +  param.dateFrom.substring(4,6) + "-" +  param.dateFrom.substring(6);
//            String[] result = getStartAndEndDayByDate(treatDateFormatted);
//            tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, result[0].replace("-",""));
//            tmplParam.put(ReportConstant.ReportDataKey.DATE_TO, result[1].replace("-",""));
//          }else{
//            tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, param.dateFrom);
//            tmplParam.put(ReportConstant.ReportDataKey.DATE_TO, param.dateTo);
//          }
//          tmplParam.put(ReportConstant.ReportDataKey.DATE, param.date.replace("/",""));
//          // del #7641 自動印刷で値が入らない項目がある 王永吉 start
//          // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
//          // tmplParam.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getTreatDate());
//          // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
//          // del #7641 自動印刷で値が入らない項目がある 王永吉 end
//          //mod 項目別(印刷情報一覧)の項目が実装されない  吉 start
//          tmplParam.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
//          tmplParams.add(tmplParam);
//        }
        // del 7486 紹介状画面で印刷ボタンを押下しても印刷できない 吉 end
        dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, tmplParams);
        dataKey.put("login", userName);
        //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
        dataKey.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
        // mod #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 start
        //dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getTreatDate());
        dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate());
        // mod #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 end
        dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
        dataKey.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
        dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
        //add ２次元帳票週間薬剤集計表対応   吉 start
        // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//        String kind ="医療材料";
//        if(null != reportMenu.getEquipmentCdList() && reportMenu.getEquipmentCdList().size() == 0 && null !=  reportMenu.getMedicineCdList() && reportMenu.getMedicineCdList().size()>0){
//          kind="";
//        }
//        if(null !=  reportMenu.getMedicineCdList() && reportMenu.getMedicineCdList().size()>0){
//          if("" == kind){
//            kind="薬剤";
//          }else{
//            kind=kind+"·薬剤";
//          }
//        }
//        dataKey.put(ReportConstant.ReportDataKey.kind,kind);
//        SimpleDateFormat sdf =new SimpleDateFormat("yyyy年MM月dd日");
//        if(null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate()){
//          String day=reportMenu.getSpecifyDate().substring(6,8);
//          String date = reportMenu.getSpecifyDate();
//          Calendar calendar =Calendar.getInstance();
//          calendar.setFirstDayOfWeek(Calendar.MONDAY);
//          calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
//          int week = calendar.get(Calendar.WEEK_OF_MONTH);
//          dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
//          String treatDateFormatted = date.substring(0,4) + "-" + date.substring(4,6) + "-" + date.substring(6);
//          String[] result = getStartAndEndDayByDate(treatDateFormatted);
//          String start = result[0].substring(0,4) + "年" + result[0].substring(5,7) + "月" + result[0].substring(8)+ "日";
//          String end = result[1].substring(5,7) + "月" + result[1].substring(8)+ "日";
//          dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
//
//        }else{
//          String day=reportMenu.getFromDate().substring(6,8);
//          String fromDate = reportMenu.getFromDate().substring(0,4) + "-" + reportMenu.getFromDate().substring(4,6) + "-" + reportMenu.getFromDate().substring(6);
//          Calendar calendar =Calendar.getInstance();
//          calendar.setFirstDayOfWeek(Calendar.MONDAY);
//          calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
//          int week = calendar.get(Calendar.WEEK_OF_MONTH);
//          dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
//          String start = reportMenu.getFromDate().substring(0,4) + "年" + reportMenu.getFromDate().substring(4,6) + "月" + reportMenu.getFromDate().substring(6)+ "日";
//          String end =  reportMenu.getToDate().substring(4,6) + "月" + reportMenu.getToDate().substring(6)+ "日";
//          dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
//        }
          // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
        htmlResult += reportService.getReportHtml(reportCd, dataKey, null, userId);
        // del #12445 【因島】帳票に出力されない画像がある 差戻1 sunsy start
//        // add #12245 【因島】帳票に出力されない画像がある  吉 start
//        String uuid = UUID.randomUUID().toString();
//        String clipPrefix = "CLIP-" + uuid + "-" + i + "-";
//        htmlResult = htmlResult.replaceAll("id=\"CLIP(.*?)\"", "id=\"" + clipPrefix + "$1\"");
//        htmlResult = htmlResult.replaceAll("url\\(#CLIP(.*?)\\)", "url(#" + clipPrefix + "$1)");
//        // add #12245 【因島】帳票に出力されない画像がある  吉 end
        // del #12445 【因島】帳票に出力されない画像がある 差戻1 sunsy end
      }
      // add #6070 帳票メニューで複数患者を選択してプレビューすると表示されるのは先頭の1患者のみ 孟堅 end
    } else if (reportClass == ReportConstant.ReportClass.MULTI_TOTAL_REPORT
      || (reportClass == ReportConstant.ReportClass.INTRODUCTION_REPORT && null != mstReport.getReportType() && mstReport.getReportType() == 1)) {
      // add 特殊二次元帳票「紹介状」帳票レイアウトの対応 end
      // 単一集計 複数集計
      // del Aspose.cells関連問題8の対応 夏 start
//      List<Long> patIds = reportMenu.getPatIds();
//      LocalDate nowDate = LocalDate.now();
//      String nowYYYYMMDD = nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));
//
//      List<ReportParam> params = new ArrayList<>();
//
//      Long patId;
//
//      if (reportMenu.getIsDialysisDate()) {
//        // 透析日基準
//
//        // 患者IDリストで渡された患者の期間内での最新の確定透析実績を取得する
//        // 透析実績が取得できない場合は、期間内で今日以降の直近予定を取得する
//        // 透析実績、透析予定ともに存在しない場合は、期間終了日の患者情報のみを取得する
//
//        for (int index = 0; index < patIds.size(); index++)
//        {
//          patId = patIds.get(index);
//          ReportParam reportParam = new ReportParam();
//          String dateString;
//
//          List<OrdMain> ordList;
//
//          if(reportClass == ReportConstant.ReportClass.ONE_TOTAL_REPORT) {
//            // 最新の確定実績を取得する
//            ordList = reportMenuDao.selectResultByTreatDate(patId, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
//          }else{
//            ordList = reportMenuDao.selectByTreatDate(patId, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
//          }
//          if(ordList.size() > 0)
//          {
//            // 最新の確定実績 治療日降順でソートしているので、1レコード目が最新
//            for(int i = 0; i < ordList.size(); i++) {
//              reportParam = new ReportParam();
//              OrdMain ordMain = ordList.get(i);
//              reportParam.ordNo = ordMain.getOrdNo();
//              final String treatDate = dateStr2dispDateStr(ordMain.getTreatDate());
//              dateString = treatDate;
//              //add ２次元帳票週間薬剤集計表対応   吉 end
//              dateString = dateString.replace("/","");
//              //add ２次元帳票週間薬剤集計表対応   吉 end
//              reportParam.patId = patId;
//              reportParam.date = dateString;
//              if(reportMenu.getFromDate() == null){
//                reportParam.dateFrom = dateString;
//              }else {
//                reportParam.dateFrom = reportMenu.getFromDate();
//              }
//              if(reportMenu.getToDate() == null){
//                reportParam.dateTo = dateString;
//              }else {
//                reportParam.dateTo = reportMenu.getToDate();
//              }
//              params.add(reportParam);
//            }
//          } else {
//            // 治療予定を取得する. ここに到達するということは、指定期間内に確定実績はない
//
//            // この患者の直近1件の治療予定を取得
//            OrdMain near = reportMenuDao.selectNearOrdPlan(patId, nowYYYYMMDD);
//            if (near != null) {
//
//              // ord_mainから取得
//
//              // 治療予定
//              reportParam.ordNo = near.getOrdNo();
//              final String treatDate = dateStr2dispDateStr(near.getTreatDate());
//              dateString = treatDate;
//
//            } else {
//
//              // 透析実績、透析予定ともに存在しない場合は、期間終了日の患者情報のみを取得する
//
//              final String toDate;
//              if (reportMenu.getSpecifyDate() == null) {
//                // 範囲指定
//                // 期間終了日
//                toDate = reportMenu.getToDate();
//
//              } else {
//                // 1日指定
//                // 特定日付
//                toDate = reportMenu.getSpecifyDate();
//
//              }
//              dateString = toDate;
//
//            }
//            reportParam.patId = patId;
//            //add ２次元帳票週間薬剤集計表対応   吉 end
//            dateString = dateString.replace("/","");
//            //add ２次元帳票週間薬剤集計表対応   吉 end
//            reportParam.date = dateString;
//            if(reportMenu.getFromDate() == null){
//              reportParam.dateFrom = dateString;
//            }else {
//              reportParam.dateFrom = reportMenu.getFromDate();
//            }
//            if(reportMenu.getToDate() == null){
//              reportParam.dateTo = dateString;
//            }else {
//              reportParam.dateTo = reportMenu.getToDate();
//            }
//            params.add(reportParam);
//          }
//
////          // 1患者のパラメータ
////          reportParam.patId = patId;
////          reportParam.date = dateString;
////          reportParam.dateFrom = reportMenu.getFromDate();
////          reportParam.dateTo = reportMenu.getToDate();
////          params.add(reportParam);
//
//        }
//
//      } else if (reportMenu.getRegOrderClassList().size() > 0) {
//        // 検査日基準
//        // 検査区分(チェックボックス)が指定されていなかったら検査対象を取得できないので、検索処理を行わない
//
//        // 患者IDリストで渡された患者の期間内での最新の検査結果の検査日を取得する。
//        // 検査結果が存在しない場合は、期間内の今日以降の直近検査予定の検査日を取得する。
//        // 検査結果または検査結果を取得する際のフィルタとして、帳票画面の検査区分、およびExcelパラメータの各検査コード、検査区分を使用する。
//        // 検査結果、検査予定共に無い場合は、患者情報のみ。
//
//        for (int index = 0; index < patIds.size(); index++)
//        {
//
//          patId = patIds.get(index);
//
//          ReportParam reportParam = new ReportParam();
//          reportParam.patId = patId;
//
//          // 検査結果
//          List<PatExamMain> examMainList =  new ArrayList<>();
//
//          // 検索区分
//          List<String> regOrderClassList = reportMenu.getRegOrderClassList();
//
//          // 日付がどのように選択されているか確認して、検査結果リストを取得する
//          String fromDate;
//          String toDate;
//          if (reportMenu.getSpecifyDate() == null) {
//            // 期間指定
//            fromDate = reportMenu.getFromDate();
//            toDate = reportMenu.getToDate();
//            LocalDateTime localDateFrom = LocalDate.parse(reportMenu.getFromDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
//            LocalDateTime localDateTo = LocalDate.parse(reportMenu.getToDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
//            localDateTo = localDateTo.plusDays(1L).minusNanos(1000);
//            examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateFrom), Timestamp.valueOf(localDateTo), regOrderClassList);
//          } else {
//            // 1日指定
//            fromDate = reportMenu.getSpecifyDate();
//            toDate = reportMenu.getSpecifyDate();
//            LocalDateTime localDateTarget = LocalDate.parse(reportMenu.getSpecifyDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
//            LocalDateTime localDateTo = localDateTarget.plusDays(1L).minusNanos(1000);
//            examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateTarget), Timestamp.valueOf(localDateTo), regOrderClassList);
//          }
//
//          boolean isNotExistExamResult = true;
//          for (PatExamMain exam : examMainList) {
//            // 検査日リスト
//            // 期間内での最新の検査結果の検査日を取得する
//
//            if (Objects.equal(exam.getExamStatus(), "1")) {
//              // 検査結果
//              // 検査日時が最新であるか判定する処理を実装する
//              isNotExistExamResult = false;
//              String uuuuMMdd = exam.getResultExamDate().toLocalDateTime().toLocalDate().format(DateTimeFormatter.ofPattern("uuuuMMdd"));
//              reportParam.date = dateStr2dispDateStr(uuuuMMdd);
//              reportParam.dateFrom = dateStr2dispDateStr(fromDate);
//              reportParam.dateTo = dateStr2dispDateStr(toDate);
//
//            } else if(isNotExistExamResult) {
//              // 検査予定
//              String uuuuMMdd = exam.getRegExamDate().toLocalDateTime().toLocalDate().format(DateTimeFormatter.ofPattern("uuuuMMdd"));
//              reportParam.date = dateStr2dispDateStr(uuuuMMdd);
//              reportParam.dateFrom = dateStr2dispDateStr(fromDate);
//              reportParam.dateTo = dateStr2dispDateStr(toDate);
//            }
//
//          }
//
//          // 透析実績と紐づける
//          List<OrdMain> ordList = reportMenuDao.selectByTreatDate(patId, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
//          List<OrdMain> ords = ordList.stream().filter(
//            // mod 2020-11-10 初回(IES)528 フィルタ動作対応 夏 start
//            //o -> Objects.equal(o.getTreatDate(), reportParam.date)).collect(Collectors.toList());
//            o -> Objects.equal(o.getTreatDate(), reportParam.date == null ? null : reportParam.date.replace("/", ""))).collect(Collectors.toList());
//          // mod 2020-11-10 初回(IES)528 フィルタ動作対応 夏 end
//          if (ords.size() > 0) {
//            // 検査日と同じ日に透析実績がある場合、透析番号を紐づける
//            reportParam.ordNo = ords.get(ords.size() - 1).getOrdNo();
//          }
//
//          params.add(reportParam);
//
//        }
//
//      }
//
//      // テンプレート外領域のパラメータを生成する処理を実装する
//      // 以下の構造のMapを生成する
//      // キー: ordNo テンプレート外 オーダー番号
//      // キー: patId テンプレート外 患者ID
//      // キー: tmplParams テンプレート内パラメーター ordNo + patIdのList<Map<String, Object>>
//      Map<String, Object> dataKey = new HashMap<>();
//      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
//      if (reportMenu.getMedicineCdList() != null && reportMenu.getMedicineCdList().size() > 0) {
//        dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS, reportMenu.getMedicineCdList());
//      } else {
//        dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS, Collections.singletonList(0));
//      }
//      List<Integer> listDia = new ArrayList<>();
//      if (reportMenu.isDialyzer()) {
//        for (MstDialyzer item : mstInfoService.findMstDialyzerAllByFacillityCd(reportMenu.getFacilityCd())) {
//          listDia.add(item.getDialyzerCd());
//        }
//        dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS, listDia);
//        reportMenu.getEquipmentCdList().add(0);
//      } else {
//        dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS, Collections.singletonList(0));
//      }
//      List<Integer> equipmentCdList = new ArrayList<>();
//      if (reportMenu.getEquipmentCdList() != null && reportMenu.getEquipmentCdList().size() > 0) {
//        equipmentCdList = reportMenu.getEquipmentCdList();
//        dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, equipmentCdList);
//      } else {
//        dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, Collections.singletonList(0));
//      }
//      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
//      // テンプレート外パラメータとして本日日付
//      dataKey.put(ReportConstant.ReportDataKey.DATE, nowYYYYMMDD);
//      List<Long> listPat = new ArrayList<>();
//      for (int i = 0; i < patIds.size(); i++) {
//        listPat.add(patIds.get(i));
//      }
//      // テンプレート内 領域のパラメータを生成する処理を実装する
//      List<Map<String, Object>> tmplParams = new ArrayList<Map<String, Object>>();
//      for (ReportParam param : params) {
//        Map<String, Object> tmplParam = new HashMap<>();
//        // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
//        tmplParam.put(ReportConstant.ReportDataKey.DIALYZER_IDS,dataKey.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
//        tmplParam.put(ReportConstant.ReportDataKey.MEDICINE_IDS,dataKey.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
//        tmplParam.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,dataKey.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
//        // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
//        tmplParam.put(ReportConstant.ReportDataKey.ORD_NO, param.ordNo);
//        tmplParam.put(ReportConstant.ReportDataKey.PAT_ID, param.patId);
//        tmplParam.put(ReportConstant.ReportDataKey.PAT_IDS, listPat);
//        //mod 項目別(印刷情報一覧)の項目が実装されない  吉 start
//        if(null != reportMenu.getSpecifyDate()){
//          String treatDateFormatted = param.dateFrom.substring(0,4) + "-" +  param.dateFrom.substring(4,6) + "-" +  param.dateFrom.substring(6);
//          String[] result = getStartAndEndDayByDate(treatDateFormatted);
//          if (null != reportMenu.getReportType() && reportMenu.getReportType() == "2"){
//            tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, result[0].replace("-",""));
//            tmplParam.put(ReportConstant.ReportDataKey.DATE_TO, result[1].replace("-",""));
//          }else{
//            tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, treatDateFormatted.replace("-",""));
//            tmplParam.put(ReportConstant.ReportDataKey.DATE_TO,treatDateFormatted.replace("-",""));
//          }
//        }else{
//          tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, param.dateFrom);
//          tmplParam.put(ReportConstant.ReportDataKey.DATE_TO, param.dateTo);
//        }
//        tmplParam.put(ReportConstant.ReportDataKey.DATE, param.date.replace("/",""));
//        // del #7641 自動印刷で値が入らない項目がある 王永吉 start
//        // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
//        // tmplParam.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getTreatDate());
//        // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
//        // del #7641 自動印刷で値が入らない項目がある 王永吉 emd
//        //mod 項目別(印刷情報一覧)の項目が実装されない  吉 start
//        tmplParam.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
//        tmplParams.add(tmplParam);
//      }
//      dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, tmplParams);
//      dataKey.put("login", userName);
//      //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
//      dataKey.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
//      // mod #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 start
//      //dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getTreatDate());
//      dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate());
//      // mod #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 end
//      dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
//      dataKey.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
//      dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
//      //add ２次元帳票週間薬剤集計表対応   吉 start
//      String kind ="医療材料";
//      if(null != reportMenu.getEquipmentCdList() && reportMenu.getEquipmentCdList().size() == 0 && null !=  reportMenu.getMedicineCdList() && reportMenu.getMedicineCdList().size()>0){
//        kind="";
//      }
//      if(null !=  reportMenu.getMedicineCdList() && reportMenu.getMedicineCdList().size()>0){
//        if("" == kind){
//          kind="薬剤";
//        }else{
//          kind=kind+"·薬剤";
//        }
//      }
//      dataKey.put(ReportConstant.ReportDataKey.kind,kind);
//      SimpleDateFormat sdf =new SimpleDateFormat("yyyy年MM月dd日");
//      if(null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate()){
//        String day=reportMenu.getSpecifyDate().substring(6,8);
//        String date = reportMenu.getSpecifyDate();
//        Calendar calendar =Calendar.getInstance();
//        calendar.setFirstDayOfWeek(Calendar.MONDAY);
//        calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
//        int week = calendar.get(Calendar.WEEK_OF_MONTH);
//        dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
//        String treatDateFormatted = date.substring(0,4) + "-" + date.substring(4,6) + "-" + date.substring(6);
//        String[] result = getStartAndEndDayByDate(treatDateFormatted);
//        String start = result[0].substring(0,4) + "年" + result[0].substring(5,7) + "月" + result[0].substring(8)+ "日";
//        String end = result[1].substring(5,7) + "月" + result[1].substring(8)+ "日";
//        dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
//
//      }else{
//        String day=reportMenu.getFromDate().substring(6,8);
//        String fromDate = reportMenu.getFromDate().substring(0,4) + "-" + reportMenu.getFromDate().substring(4,6) + "-" + reportMenu.getFromDate().substring(6);
//        Calendar calendar =Calendar.getInstance();
//        calendar.setFirstDayOfWeek(Calendar.MONDAY);
//        calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
//        int week = calendar.get(Calendar.WEEK_OF_MONTH);
//        dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
//        String start = reportMenu.getFromDate().substring(0,4) + "年" + reportMenu.getFromDate().substring(4,6) + "月" + reportMenu.getFromDate().substring(6)+ "日";
//        String end =  reportMenu.getToDate().substring(4,6) + "月" + reportMenu.getToDate().substring(6)+ "日";
//        dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
//      }
//      //add ２次元帳票週間薬剤集計表対応   吉 end
//      // add 項目別(印刷情報一覧)の項目が実装されない  吉 end
      // del Aspose.cells関連問題8の対応 夏 end
      // mod Aspose.cells関連問題8の対応 夏 start
//      htmlResult = reportService.getReportHtml(reportCd, dataKey, null, userId);
      Map<String, Object> dataKey = setMultiTotalDataKey(reportMenu,userId,userName);
      // add 7845 帳票（複数集計）：情報が出力されない && 6691 複数集計：対象項目の不足 liuc start
      //regOrderClassList(透析前、透析後、その他)の条件を追加します。
      dataKey.put("regOrderClassList",reportMenu.getRegOrderClassList());
      // add 7845 帳票（複数集計）：情報が出力されない && 6691 複数集計：対象項目の不足 liuc end
      htmlResult = reportService.getReportHtml(reportCd, dataKey, null, userId);
      // mod Aspose.cells関連問題8の対応 夏 start
      // add FNSI-523 2次元帳票対応 夏 end
      // mod 2020-11-10 初回(IES)528 フィルタ動作対応 夏 start
//    } else if (reportClass >= ReportConstant.ReportClass.PREPARATION_LIST_REPORT) {
//      // 準備リスト または 配布リスト(物品) または 装置帳票 または ラベル または 紹介状
      /*add FNSI-改修内容装置帳票の対応 任 start*/
    } else if(reportClass.equals(ReportConstant.ReportClass.MACHINE_REPORT)){
      Map<String, Object> dataKey = new HashMap<>();
      // add #5562 並び替えを行っても帳票画面のリストに反映されない 歴 start
      // 装置帳票のソート
      List<Map<String, String>> sortConditions = reportMenu.getSortCondition();
      if (sortConditions.size() > 0) {
        List<Long> machineNoList = new ArrayList<>();
        for (int i = 0; i < reportMenu.getMachines().size(); i++) {
          if (reportMenu.getMachines().get(i).getMachineNo() != null) {
            machineNoList.add(reportMenu.getMachines().get(i).getMachineNo());
          }
        }

        String sortId = "";
        String sortIdValue = "";
        if (sortConditions.size() == 3) {
          sortId = checkSortId(sortConditions.get(2));
          if (!sortId.equals("")) {
            sortIdValue = sortConditions.get(2).get(sortId);
          } else {
            sortIdValue = "";
          }
        } else if (sortConditions.size() == 2) {
          sortId = checkSortId(sortConditions.get(1));
          if (!sortId.equals("")) {
            sortIdValue = sortConditions.get(1).get(sortId);
          } else {
            sortIdValue = "";
          }
        } else {
          sortId = checkSortId(sortConditions.get(0));
          if (!sortId.equals("")) {
            sortIdValue = sortConditions.get(0).get(sortId);
          } else {
            sortIdValue = "";
          }
        }

        List<Long> machineNoListTemp = reportMenuDao.selectSortByMachineInfo(machineNoList, sortId, sortIdValue, reportMenu.getFacilityCd());
        //add 6502 定期・日常が分離されていない 吉 start
        List<CusMachineInfoPeriodic> machineNoListTemps = reportMenuDao.selectAllByMachineInfo(machineNoList, sortId, sortIdValue, reportMenu.getFacilityCd());
        List<DevMenteMainDto> machineNoLists = new ArrayList<>();
        if(null != machineNoListTemp && machineNoListTemp.size()>0){
          for(CusMachineInfoPeriodic cmi : machineNoListTemps){
            DevMenteMainDto dto = new DevMenteMainDto();
            dto.setMachineNo(cmi.getMachineNo());
            dto.setMachineName(cmi.getMachineName());
            dto.setMachineSerial(cmi.getMachineSerial());
            dto.setMachineType(cmi.getMachineType());
            dto.setMachineTypeCd(cmi.getMachineTypeCd());
            machineNoLists.add(dto);
          }
        }
        reportMenu.setMachines(machineNoLists);
        //add 6502 定期・日常が分離されていない 吉 end
        if (machineNoListTemp != null && machineNoListTemp.size() > 0) {
          // mod #7233 デフォルト帳票について 日本指摘対応 商 start
          // if ("0".equals(reportMenu.getReportType())) {
          // mod #7233 デフォルト帳票について 日本指摘対応 姜 start
          // if ("0".equals(reportMenu.getReportType()) && reportCd > 0) {
          if ("0".equals(reportMenu.getReportType())) {
          // mod #7233 デフォルト帳票について 日本指摘対応 姜 end
            // mod #7233 デフォルト帳票について 日本指摘対応 商 end
            for (int i = 0; i< machineNoListTemp.size(); i++) {
              String date = "";
              if (reportMenu.getSpecifyDate() != null) {
                date = reportMenu.getSpecifyDate();
                // add Aspose.cells関連バッグ対応 吉 start
                dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD,reportMenu.getFacilityCd());
                // add Aspose.cells関連バッグ対応 吉 end
                dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, date);
                dataKey.put(ReportConstant.ReportDataKey.DATE_TO, date);
                dataKey.put(ReportConstant.ReportDataKey.DATE, date);
                if (reportMenu.getReportCd() != null) {
                  List<Long> reportCdList = new ArrayList<>();
                  // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
                  // if (reportCd == -4L)
                  if (reportCd == CoreConstant.FixedReportCd.DAILY_INSPECT_RECORD_BOOK)
                  // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
                  {
                    reportCdList = getReportCdList(reportMenu, i, date,"1");
                  }
                  // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
                  // if (reportCd == -5L)
                  if (reportCd == CoreConstant.FixedReportCd.PERIODIC_INSPECT_RECORD_BOOK)
                  // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
                  {
                    reportCdList = getReportCdList(reportMenu, i ,date,"2");
                  }
                  // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe start
                  else if(reportMenu.getReportCd() == CoreConstant.FixedReportCd.WATER_SURVEY_RECORD_BOOK){
                    reportCdList = getReportCdList(reportMenu, i, date, "3");
                  }
                  // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe end
                  dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, machineNoListTemp.get(i));

                  if (reportCdList.size() > 0) {
                    for (int k = 0; k < reportCdList.size(); k++){
                      htmlResult += reportService.getReportHtml(reportCdList.get(k), dataKey, null, userId);
                    }
                  }
                }else{
                  htmlResult="";
                }
              }else{
                String fromDate = reportMenu.getFromDate();
                String toDate = reportMenu.getToDate();
                dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate);
                dataKey.put(ReportConstant.ReportDataKey.DATE_TO, toDate);
                SimpleDateFormat sdf=new SimpleDateFormat("yyyyMMdd");
                Calendar cal = Calendar.getInstance();
                cal.setTime(sdf.parse(fromDate));
                long time1 = cal.getTimeInMillis();
                cal.setTime(sdf.parse(toDate));
                long time2 = cal.getTimeInMillis();
                long between_days=(time2-time1)/(1000*3600*24);
                Calendar calendar = new GregorianCalendar();
                calendar.setTime(sdf.parse(reportMenu.getFromDate()));
                List<String> strHtmlTemp = new ArrayList<>();
                boolean htmlFlg = false;
                for (int j = 0; j <= between_days; j++) {
                  date = sdf.format(calendar.getTime());
                  dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
                  dataKey.put(ReportConstant.ReportDataKey.DATE, date);
                  if (reportMenu.getReportCd() != null) {
                    List<Long> reportCdList = new ArrayList<>();
                    // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
                    // if (reportCd == -4L)
                    if (reportCd == CoreConstant.FixedReportCd.DAILY_INSPECT_RECORD_BOOK)
                    // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
                    {
                      reportCdList = getReportCdList(reportMenu, i, date,"1");
                    }
                    // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
                    // if (reportCd == -5L)
                    if (reportCd == CoreConstant.FixedReportCd.PERIODIC_INSPECT_RECORD_BOOK)
                    // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
                    {
                      reportCdList = getReportCdList(reportMenu, i, date,"2");
                    }
                    // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe start
                    else if(reportMenu.getReportCd() == CoreConstant.FixedReportCd.WATER_SURVEY_RECORD_BOOK){
                      reportCdList = getReportCdList(reportMenu, i, date, "3");
                    }
                    // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe end
                    dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, machineNoListTemp.get(i));

                    if (reportCdList.size() > 0) {
                      for (int k =0 ; k < reportCdList.size(); k++) {
                        htmlFlg = true;
                        for (String dataList : strHtmlTemp) {
                          if (dataList.equals(reportService.getReportHtml(reportCdList.get(k), dataKey, null, userId))) {
                            htmlFlg = false;
                            break;
                          }
                        }
                        if (htmlFlg == true) {
                          htmlResult += reportService.getReportHtml(reportCdList.get(k), dataKey, null, userId);
                          strHtmlTemp.add(reportService.getReportHtml(reportCdList.get(k), dataKey, null, userId));
                        }
                      }
                    }
                  }else{
                    htmlResult += "";
                  }
                  calendar.add(calendar.DATE, 1);
                }
              }
            }
            // mod #7233 デフォルト帳票について 日本指摘対応 商 start
            // } else if ("1".equals(reportMenu.getReportType())) {
          // mod #7233 デフォルト帳票について 日本指摘対応 姜 start
          // } else if ("1".equals(reportMenu.getReportType()) || reportCd > 0) {
          } else if ("1".equals(reportMenu.getReportType())) {
          // mod #7233 デフォルト帳票について 日本指摘対応 姜 end
            // mod #7233 デフォルト帳票について 日本指摘対応 商 end
            Map<String, Object> machine = new HashMap<>();
            List<Map<String, Object>> machines = new ArrayList<>();
            // add #7233 デフォルト帳票について 日本指摘対応 商 start
            List<Long> machineNos = new ArrayList<>();
            // add #7233 デフォルト帳票について 日本指摘対応 商 end
            for (int i = 0; i < machineNoListTemp.size(); i++) {
              machine = new HashMap<>();
              machine.put(ReportConstant.ReportDataKey.DATE_FROM, reportMenu.getFromDate() != null ? reportMenu.getFromDate() : reportMenu.getSpecifyDate());
              machine.put(ReportConstant.ReportDataKey.DATE_TO, reportMenu.getToDate() != null ? reportMenu.getToDate() : reportMenu.getSpecifyDate());
              machine.put(ReportConstant.ReportDataKey.DATE, reportMenu.getSpecifyDate());
              machine.put(ReportConstant.ReportDataKey.MACHINE_NO, machineNoListTemp.get(i));
              // add #7233 デフォルト帳票について 日本指摘対応 商 start
              machineNos.add(reportMenu.getMachines().get(i).getMachineNo());
              // add #7233 デフォルト帳票について 日本指摘対応 商 end
              machines.add(machine);
            }
            dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, reportMenu.getFromDate() != null ? reportMenu.getFromDate() : reportMenu.getSpecifyDate());
            dataKey.put(ReportConstant.ReportDataKey.DATE_TO, reportMenu.getToDate() != null ? reportMenu.getToDate() : reportMenu.getSpecifyDate());
            dataKey.put(ReportConstant.ReportDataKey.DATE, reportMenu.getSpecifyDate());

            dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, machines);
            // add #7233 デフォルト帳票について 日本指摘対応 商 start
            dataKey.put("machineNos", machineNos);
            // add #7233 デフォルト帳票について 日本指摘対応 商 end
            htmlResult = reportService.getReportHtml(reportMenu.getReportCd(), dataKey, null, userId);
          }
        }
      } else {
        // add #5562 並び替えを行っても帳票画面のリストに反映されない 歴 end
        // add #6377 「テンプレート繰り返しが正しく動いていない」 鄧シン start
        //mod 6502 装置帳票：定期・日常が分離されていない 吉 start
//      mstReport = getMstReport(reportCd);
//      Workbook wb = getReportWorkbook(mstReport, getReportZip(mstReport));
//      Sheet baseSt = wb.getSheet("設定");
//      String reportTyppe = baseSt.getRow(50).getCell(0).toString().split(",")[0];
//      if ("0".equals(reportTyppe)) {
        // mod #7233 デフォルト帳票について 日本指摘対応 商 start
        // if ("0".equals(reportMenu.getReportType())) {
        if ("0".equals(reportMenu.getReportType()) && reportCd < 0) {
          // mod #7233 デフォルト帳票について 日本指摘対応 商 end
          //mod 6502 装置帳票：定期・日常が分離されていない 吉 end

          for(int i = 0;i<reportMenu.getMachines().size();i++){
            String date = "";
            // add Aspose.cells関連バッグ対応 吉 start
            dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD,reportMenu.getFacilityCd());
            // add Aspose.cells関連バッグ対応 吉 end
            if (reportMenu.getSpecifyDate() != null) {
              date = reportMenu.getSpecifyDate();
              dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, date);
              dataKey.put(ReportConstant.ReportDataKey.DATE_TO, date);
              dataKey.put(ReportConstant.ReportDataKey.DATE, date);
              //mod 6502 装置帳票：定期・日常が分離されていない 吉 start
//            if(reportMenu.getReportCd() == null){
//              List<Long> reportCdList = getReportCdList(reportMenu,i,date);
//              dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, reportMenu.getMachines().get(i).getMachineNo());
//              if(reportCdList.size()>0){
//                for(int k =0 ;k<reportCdList.size();k++){
//                  htmlResult += reportService.getReportHtml(reportCdList.get(k), dataKey, null, userId);
//                }
//              }
//            }else{
//              dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, reportMenu.getMachines().get(i).getMachineNo());
//              htmlResult += reportService.getReportHtml(reportMenu.getReportCd(), dataKey, null, userId);
//            }
              if (reportMenu.getReportCd() != null) {
                List<Long> reportCdList = new ArrayList<>();
                // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
                // if (reportCd == -4L)
                if (reportCd == CoreConstant.FixedReportCd.DAILY_INSPECT_RECORD_BOOK)
                // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
                {
                  reportCdList = getReportCdList(reportMenu, i, date, "1");
                }
                // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
                // if (reportCd == -5L)
                if (reportCd == CoreConstant.FixedReportCd.PERIODIC_INSPECT_RECORD_BOOK)
                // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
                {
                  reportCdList = getReportCdList(reportMenu, i, date, "2");
                }
                // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe start
                else if(reportMenu.getReportCd() == CoreConstant.FixedReportCd.WATER_SURVEY_RECORD_BOOK){
                  reportCdList = getReportCdList(reportMenu, i, date, "3");
                }
                // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe end

                dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, reportMenu.getMachines().get(i).getMachineNo());
                if (reportCdList.size() > 0) {
                  for (int k = 0; k < reportCdList.size(); k++) {
                    htmlResult += reportService.getReportHtml(reportCdList.get(k), dataKey, null, userId);
                  }
                }

              } else {
                htmlResult = "";
              }
              //mod 6502 装置帳票：定期・日常が分離されていない 吉 end
            } else {
              String fromDate = reportMenu.getFromDate();
              String toDate = reportMenu.getToDate();
              dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate);
              dataKey.put(ReportConstant.ReportDataKey.DATE_TO, toDate);
              SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
              Calendar cal = Calendar.getInstance();
              cal.setTime(sdf.parse(fromDate));
              long time1 = cal.getTimeInMillis();
              cal.setTime(sdf.parse(toDate));
              long time2 = cal.getTimeInMillis();
              long between_days = (time2 - time1) / (1000 * 3600 * 24);
              Calendar calendar = new GregorianCalendar();
              calendar.setTime(sdf.parse(reportMenu.getFromDate()));
              List<String> strHtmlTemp = new ArrayList<>();
              boolean htmlFlg = false;
              // add 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 start
              dataKey.put("login", userName);
              // add 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 end
              for (int j = 0; j <= between_days; j++) {
                date = sdf.format(calendar.getTime());
                dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
                dataKey.put(ReportConstant.ReportDataKey.DATE, date);
                //mod 6502 装置帳票：定期・日常が分離されていない 吉 start
//              if(reportMenu.getReportCd() == null){
//                List<Long> reportCdList = getReportCdList(reportMenu,i,date);
//                dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, reportMenu.getMachines().get(i).getMachineNo());
//                if(reportCdList.size()>0){
//                  for(int k =0 ;k<reportCdList.size();k++){
//                    htmlFlg = true;
//                    for (String dataList : strHtmlTemp) {
//                      if (dataList.equals(reportService.getReportHtml(reportCdList.get(k), dataKey, null, userId))) {
//                        htmlFlg = false;
//                        break;
//                      }
//                    }
//                    if(htmlFlg == true){
//                      htmlResult += reportService.getReportHtml(reportCdList.get(k), dataKey, null, userId);
//                      strHtmlTemp.add(reportService.getReportHtml(reportCdList.get(k), dataKey, null, userId));
//                    }
//                  }
//                }
//              }else{
//                dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, reportMenu.getMachines().get(i).getMachineNo());
//                htmlResult += reportService.getReportHtml(reportMenu.getReportCd(), dataKey, null, userId);
//              }
                if (reportMenu.getReportCd() != null) {
                  List<Long> reportCdList = new ArrayList<>();
                  // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
                  // if (reportCd == -4L)
                  if (reportCd == CoreConstant.FixedReportCd.DAILY_INSPECT_RECORD_BOOK)
                  // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
                  {
                    reportCdList = getReportCdList(reportMenu, i, date, "1");
                  }
                  // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
                  // if (reportCd == -5L)
                  if (reportCd == CoreConstant.FixedReportCd.PERIODIC_INSPECT_RECORD_BOOK)
                  // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
                  {
                    reportCdList = getReportCdList(reportMenu, i, date, "2");
                  }
                  // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe start
                  else if(reportMenu.getReportCd() == CoreConstant.FixedReportCd.WATER_SURVEY_RECORD_BOOK){
                    reportCdList = getReportCdList(reportMenu, i, date, "3");
                  }
                  // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe end
                  dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, reportMenu.getMachines().get(i).getMachineNo());

                  if (reportCdList.size() > 0) {
                    for (int k = 0; k < reportCdList.size(); k++) {
                      htmlFlg = true;
                      for (String dataList : strHtmlTemp) {
                        if (dataList.equals(reportService.getReportHtml(reportCdList.get(k), dataKey, null, userId))) {
                          htmlFlg = false;
                          break;
                        }
                      }
                      if (htmlFlg == true) {
                        htmlResult += reportService.getReportHtml(reportCdList.get(k), dataKey, null, userId);
                        strHtmlTemp.add(reportService.getReportHtml(reportCdList.get(k), dataKey, null, userId));
                      }
                    }
                  }
                } else {
                  htmlResult += "";
                }
                //mod 6502 装置帳票：定期・日常が分離されていない 吉 end
                calendar.add(calendar.DATE, 1);
              }
            }
          }
          //mod 6502 装置帳票：定期・日常が分離されていない 吉 start
//      } else if ("1".equals(reportTyppe)) {
          // mod #7233 デフォルト帳票について 日本指摘対応 商 start
          // } else if ("1".equals(reportMenu.getReportType())) {
        } else if ("1".equals(reportMenu.getReportType()) || reportCd > 0) {
          // mod #7233 デフォルト帳票について 日本指摘対応 商 end
          mstReport = getMstReport(reportCd);
          //mod 6502 装置帳票：定期・日常が分離されていない 吉 end
          String date = "";
          Map<String, Object> machine = new HashMap<>();
          List<Map<String, Object>> machines = new ArrayList<>();

          // mod #6426 「テンプレート内の繰り返しが正しく動かない」について、修正する。 鄧シン start
          //　for(int i = 0; i < reportMenu.getMachines().size(); i++) {
          //　  machine = new HashMap<>();
          //　  date = reportMenu.getSpecifyDate();
          //　  machine.put(ReportConstant.ReportDataKey.DATE_FROM, date);
          //　  machine.put(ReportConstant.ReportDataKey.DATE_TO, date);
          //　  machine.put(ReportConstant.ReportDataKey.DATE,date);
          //　  machine.put(ReportConstant.ReportDataKey.MACHINE_NO,reportMenu.getMachines().get(i).getMachineNo());
          //　  machines.add(machine);
          //　}
          //　dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, date);
          //　dataKey.put(ReportConstant.ReportDataKey.DATE_TO, date);
          //　dataKey.put(ReportConstant.ReportDataKey.DATE,date);
          //
          //　dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, machines);
          //　htmlResult = reportService.getReportHtml(reportMenu.getReportCd(), dataKey, null, userId);
          // add #7233 デフォルト帳票について 日本指摘対応 商 start
          List<Long> machineNos = new ArrayList<>();
          // add #7233 デフォルト帳票について 日本指摘対応 商 end
          for (int i = 0; i < reportMenu.getMachines().size(); i++) {
            machine = new HashMap<>();
            machine.put(ReportConstant.ReportDataKey.DATE_FROM, reportMenu.getFromDate() != null ? reportMenu.getFromDate() : reportMenu.getSpecifyDate());
            machine.put(ReportConstant.ReportDataKey.DATE_TO, reportMenu.getToDate() != null ? reportMenu.getToDate() : reportMenu.getSpecifyDate());
            machine.put(ReportConstant.ReportDataKey.DATE, reportMenu.getSpecifyDate());
            machine.put(ReportConstant.ReportDataKey.MACHINE_NO, reportMenu.getMachines().get(i).getMachineNo());
            // add Aspose.cells関連バッグ対応 吉 start
            machine.put(ReportConstant.ReportDataKey.FACILITY_CD,reportMenu.getFacilityCd());
            // add Aspose.cells関連バッグ対応 吉 end
            // add #7233 デフォルト帳票について 日本指摘対応 商 start
            machineNos.add(reportMenu.getMachines().get(i).getMachineNo());
            // add #7233 デフォルト帳票について 日本指摘対応 商 end
            machines.add(machine);
          }
          dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, reportMenu.getFromDate() != null ? reportMenu.getFromDate() : reportMenu.getSpecifyDate());
          dataKey.put(ReportConstant.ReportDataKey.DATE_TO, reportMenu.getToDate() != null ? reportMenu.getToDate() : reportMenu.getSpecifyDate());
          dataKey.put(ReportConstant.ReportDataKey.DATE, reportMenu.getSpecifyDate());
          // add Aspose.cells関連バッグ対応 吉 start
          dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD,reportMenu.getFacilityCd());
          // add Aspose.cells関連バッグ対応 吉 end
          dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, machines);
          // add #7233 デフォルト帳票について 日本指摘対応 商 start
          dataKey.put("machineNos", machineNos);
          // add #7233 デフォルト帳票について 日本指摘対応 商 end
          // add 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 start
          dataKey.put("login", userName);
          // add 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 end
          htmlResult = reportService.getReportHtml(reportMenu.getReportCd(), dataKey, null, userId);
          // mod #6426 「テンプレート内の繰り返しが正しく動かない」について、修正する。 鄧シン end
        }
        // add #6377 「テンプレート繰り返しが正しく動いていない」 鄧シン end
      // add #5562 並び替えを行っても帳票画面のリストに反映されない 歴 start
      }
      // add #5562 並び替えを行っても帳票画面のリストに反映されない 歴 end
      // del #6377 「テンプレート繰り返しが正しく動いていない」 鄧シン start
//      for(int i = 0;i<reportMenu.getMachines().size();i++){
//        String date = "";
//        if(reportMenu.getSpecifyDate() != null){
//          date = reportMenu.getSpecifyDate();
//          dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, date);
//          dataKey.put(ReportConstant.ReportDataKey.DATE_TO, date);
//          // add UT帳票No.114 期間指定とき、定期日常点検・交換部品記録簿出力不正の対応 夏 start
//          dataKey.put(ReportConstant.ReportDataKey.DATE,date);
//          if(reportMenu.getReportCd() == null){
//            List<Long> reportCdList = getReportCdList(reportMenu,i,date);
//            dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, reportMenu.getMachines().get(i).getMachineNo());
//            if(reportCdList.size()>0){
//              for(int k =0 ;k<reportCdList.size();k++){
//                htmlResult += reportService.getReportHtml(reportCdList.get(k), dataKey, null, userId);
//              }
//            }
//          }else{
//            dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, reportMenu.getMachines().get(i).getMachineNo());
//            htmlResult += reportService.getReportHtml(reportMenu.getReportCd(), dataKey, null, userId);
//          }
//          // add UT帳票No.114 期間指定とき、定期日常点検・交換部品記録簿出力不正の対応 夏 end
//        }else{
//          String fromDate = reportMenu.getFromDate();
//          String toDate = reportMenu.getToDate();
//          dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate);
//          dataKey.put(ReportConstant.ReportDataKey.DATE_TO, toDate);
//          SimpleDateFormat sdf=new SimpleDateFormat("yyyyMMdd");
//          Calendar cal = Calendar.getInstance();
//          cal.setTime(sdf.parse(fromDate));
//          long time1 = cal.getTimeInMillis();
//          cal.setTime(sdf.parse(toDate));
//          long time2 = cal.getTimeInMillis();
//          long between_days=(time2-time1)/(1000*3600*24);
//          // mod UT帳票No.114 期間指定とき、定期日常点検・交換部品記録簿出力不正の対応 夏 start
//          Calendar calendar = new GregorianCalendar();
//          calendar.setTime(sdf.parse(reportMenu.getFromDate()));
//          // add UT帳票No.125 特殊帳票「交換部品記録簿」レイアウト出力の対応 夏 start
//          List<String> strHtmlTemp = new ArrayList<>();
//          boolean htmlFlg = false;
//          // add UT帳票No.125 特殊帳票「交換部品記録簿」レイアウト出力の対応 夏 end
//          // add UT帳票No.113 期間指定とき、システムエラー発生の対応 夏 start
////        for (int j = 0; j < between_days; j++) {
//          for (int j = 0; j <= between_days; j++) {
//            // add UT帳票No.113 期間指定とき、システムエラー発生の対応 夏 end
//            date = sdf.format(calendar.getTime());
//            dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD,reportMenu.getFacilityCd());
//            dataKey.put(ReportConstant.ReportDataKey.DATE,date);
//            if(reportMenu.getReportCd() == null){
//              List<Long> reportCdList = getReportCdList(reportMenu,i,date);
//              dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, reportMenu.getMachines().get(i).getMachineNo());
//              if(reportCdList.size()>0){
//                for(int k =0 ;k<reportCdList.size();k++){
//                  // mod UT帳票No.125 特殊帳票「交換部品記録簿」レイアウト出力の対応 夏 start
//                  htmlFlg = true;
//                  for (String dataList : strHtmlTemp) {
//                    if (dataList.equals(reportService.getReportHtml(reportCdList.get(k), dataKey, null, userId))) {
//                      htmlFlg = false;
//                      break;
//                    }
//                  }
//                  if(htmlFlg == true){
//                    htmlResult += reportService.getReportHtml(reportCdList.get(k), dataKey, null, userId);
//                    strHtmlTemp.add(reportService.getReportHtml(reportCdList.get(k), dataKey, null, userId));
//                  }
//                  // mod UT帳票No.125 特殊帳票「交換部品記録簿」レイアウト出力の対応 夏 end
//                }
//              }
//            }else{
//              dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, reportMenu.getMachines().get(i).getMachineNo());
//              htmlResult += reportService.getReportHtml(reportMenu.getReportCd(), dataKey, null, userId);
//            }
//            calendar.add(calendar.DATE, 1);
//          }
//          // mod UT帳票No.114 期間指定とき、定期日常点検・交換部品記録簿出力不正の対応 夏 end
//        }
//      }
      // add #6377 「テンプレート繰り返しが正しく動いていない」 鄧シン end
      /*add FNSI-改修内容装置帳票の対応 任 end*/
    } else if (reportClass >= ReportConstant.ReportClass.PREPARATION_LIST_REPORT
      && reportClass != ReportConstant.ReportClass.INTRODUCTION_REPORT) {
      // 準備リスト または 配布リスト(物品) または 装置帳票 または ラベル
    // mod 2020-11-10 初回(IES)528 フィルタ動作対応 夏 end
      List<Long> listPat = new ArrayList<>();
      List<Long> listOrd = new ArrayList<>();
      List<Integer> listDia = new ArrayList<>();
      for (int i = 0; i < patOrdNo.size(); i++) {
        // mod #7880 帳票：ラベルが正しく表示されない 商 start
        //listPat.add(patOrdNo.get(i).getPatId());
        // mod #7958 PDFとEXCELのファイル出力の内容が異なる 内部指摘対応 商 start
        //if (!listPat.contains(patOrdNo.get(i).getPatId())) {
          //listPat.add(patOrdNo.get(i).getPatId());
        //}
        if (reportClass == ReportConstant.ReportClass.LABEL_REPORT) {
          if (!listPat.contains(patOrdNo.get(i).getPatId())) {
            listPat.add(patOrdNo.get(i).getPatId());
          }
        } else {
          listPat.add(patOrdNo.get(i).getPatId());
        }
        // mod #7958 PDFとEXCELのファイル出力の内容が異なる 内部指摘対応 商 end
        // mod #7880 帳票：ラベルが正しく表示されない 商 end
        listOrd.add(patOrdNo.get(i).getOrdNo());
      }
      // add #7880 帳票：ラベルが正しく表示されない 内部指摘対応 商 start
      Collections.sort(listPat);
      // add #7880 帳票：ラベルが正しく表示されない 内部指摘対応 商 end
      if (listPat.size() == 0 || listOrd.size() == 0) {
        //add 5981 薬剤の下に検査の区分を作成し、〇採血管　（〇はチェックボックス）を追加する。 吉 start
        if(reportClass == ReportConstant.ReportClass.LABEL_REPORT && !reportMenu.getIsDialysisDate()){
          listPat = reportMenu.getPatIds();
        }else{
        //add 5981 薬剤の下に検査の区分を作成し、〇採血管　（〇はチェックボックス）を追加する。 吉 end
          return null;
        }

      }
      Map<String, Object> dataKey = new HashMap<>();

      dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD,reportMenu.getFacilityCd());

      dataKey.put(ReportConstant.ReportDataKey.PAT_IDS, listPat);
      dataKey.put(ReportConstant.ReportDataKey.ORD_NOS, listOrd);

      if (reportMenu.getMedicineCdList() != null && reportMenu.getMedicineCdList().size() > 0) {
        dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS, reportMenu.getMedicineCdList());
      } else {
        // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
        // dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS, 0);
        dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS, Collections.singletonList(0));
        // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
      }

      if (reportMenu.isDialyzer()) {
        //ダイアライザの表示
        for (MstDialyzer item : mstInfoService.findMstDialyzerAllByFacillityCd(reportMenu.getFacilityCd())) {
          listDia.add(item.getDialyzerCd());
        }
        dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS, listDia);
        reportMenu.getEquipmentCdList().add(0);
      } else {
        // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
        // dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS, .0);
        dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS, Collections.singletonList(0));
        // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
      }

      // mod #7880 帳票：ラベルが正しく表示されない 日本指摘対応 商 start
      //if (reportMenu.getEquipmentCdList().size() > 0) {
      //  dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, reportMenu.getEquipmentCdList());
      //} else {
      //  dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, 0);
      //}
      List<Integer> equipmentCdList = new ArrayList<>();
      if (reportMenu.getEquipmentCdList() != null && reportMenu.getEquipmentCdList().size() > 0) {
        equipmentCdList = reportMenu.getEquipmentCdList();
        // del 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
        // equipmentCdList.add(-1);
        // del 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
        dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, equipmentCdList);
      } else {
        // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
        // dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, 0);
        dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, Collections.singletonList(0));
        // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
      }
      // mod #7880 帳票：ラベルが正しく表示されない 日本指摘対応 商 end
      dataKey.put("login", userName);
      if (reportClass.equals(ReportConstant.ReportClass.LABEL_REPORT))
      {
        // add Aspose.cells関連問題4の対応 姜 start
        // 帳票種別がラベルならば
        MstReport report = getMstReport(reportMenu.getReportCd());
        // S3から帳票定義XML、帳票デザインHTMLが格納されたZipファイルを取得する
        ReportZipFile reportZipFile = getReportZip(report);
        // SqlCodeをもとに帳票に出力する情報を取得する
        String reportXml = getReportXml(report, reportZipFile);
        // 帳票定義xmlをリストに変換
        List<ReportXmlParam> params = ReportUtils.getParamElements(reportXml);
        final ReportXmlTmplRepeat reportXmlTmplRepeat = params.get(0).getReportXmlTmplRepeat();
        if (reportXmlTmplRepeat.getRepeatMax() < reportMenu.getStPos()) {
          reportMenu.setStPos(1);
        }
        // add Aspose.cells関連問題4の対応 姜 end
        // TODO UIで指定された印刷開始位置をセットする
        dataKey.put(ReportConstant.ReportDataKey.PRINTING_START_TMPL_NO, reportMenu.getStPos());
      }
      //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
      dataKey.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
      dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate());
      dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
      dataKey.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
      dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
      // add #7880 帳票：ラベルが正しく表示されない 姜 start
      dataKey.put(ReportConstant.ReportDataKey.SORT_CONDITIONS, reportMenu.getSortCondition());
      // add #7880 帳票：ラベルが正しく表示されない 姜 end
      // add 項目別(印刷情報一覧)の項目が実装されない  吉 end
      //add IES因島）sql性能試験 後で削除 liuc start
      dataKey.put("sqlTestSign", reportMenu.getSqlTestTimeStr());
      //add IES因島）sql性能試験 後で削除 liuc end
      htmlResult = reportService.getReportHtml(reportCd, dataKey, null, userId);

    }
    // add #6346 処方の項目が足りない 王永吉 start
    else if (reportClass.equals(ReportConstant.ReportClass.ONE_PATIENT_REPORT)
      && (null != mstReport.getReportType() && mstReport.getReportType() == 2)) {
      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
      Map<String,List> searchList =this.searchMap(reportMenu.getFacilityCd());
      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
      // 処方帳票
      List<String> regOrderClassList = reportMenu.getRegOrderClassList();
      List<Long> patIds=new ArrayList<Long>();
      if(null != patOrdNo){
        for(int i=0;i<patOrdNo.size();i++){
          patIds.add(patOrdNo.get(i).getPatId());
        }
      }
      LocalDate nowDate = LocalDate.now();
      String nowYYYYMMDD = nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));
      List<Long> patIdsIn=new ArrayList<>();

      for (int index = 0; index < patOrdNo.size(); index++) {
        // 選択された患者の数だけ帳票を生成する
        Long patId = patIds.get(index);
        // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
        Long ordNo = patOrdNo.get(index).getOrdNo();
        // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
        boolean inOrOut = false;
        // 重複患者番号を削除する
        if (patOrdNo.size() > 1) {
          if (patIdsIn.size() >= 1){
            for (int pa = 0; pa < patIdsIn.size(); pa++){
              if (patIdsIn.get(pa) == patId){
                inOrOut = true;
                break;
              }
            }
            if (inOrOut) {
              continue;
            }
          }
          patIdsIn.add(patId);
        }

        List<ReportParam> params = new ArrayList<>();
        List<Long> examMainCds = new ArrayList<>();
        if (reportMenu.getIsDialysisDate()) {
          // 透析日基準
          // 指定日、または期間内の透析日をターゲットに治療情報を取得します。
          List<OrdMain> ordList = reportMenuDao.selectByTreatDate(patId, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
          if (reportMenu.getSpecifyDate() == null) {
            // 範囲指定ならば
            for (OrdMain ord: ordList) {
              ReportParam reportParam = new ReportParam();
              reportParam.ordNo = ord.getOrdNo();
              reportParam.date = dateStr2dispDateStr(ord.getTreatDate());
              reportParam.dateFrom = dateStr2dispDateStr(reportMenu.getFromDate());
              reportParam.dateTo = dateStr2dispDateStr(reportMenu.getToDate());
              params.add(reportParam);
            }
          } else {
            // 指定日ならば
            for (OrdMain ord: ordList) {
              String treatDate = dateStr2dispDateStr(ord.getTreatDate());
              ReportParam reportParam = new ReportParam();
              reportParam.ordNo = ord.getOrdNo();
              reportParam.date = treatDate;
              reportParam.dateFrom = treatDate;
              reportParam.dateTo = treatDate;
              params.add(reportParam);
            }
          }
        } else {
          // 検査日基準
          List<PatExamMain> examMainList =  new ArrayList<>();
          if (reportMenu.getRegOrderClassList().size() > 0) {
            // 検査区分が指定されていなかったら検査対象を取得できないので、検索処理を行わない
            List<OrdMain> ordList = reportMenuDao.selectByTreatDate(patId, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
            // 日付がどのように選択されているか確認して、検査結果リストを取得する
            String fromDate = reportMenu.getFromDate();
            String toDate = reportMenu.getToDate();
            if (reportMenu.getSpecifyDate() == null) {
              // 期間指定
              LocalDateTime localDateFrom = LocalDate.parse(reportMenu.getFromDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
              LocalDateTime localDateTo = LocalDate.parse(reportMenu.getToDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
              localDateTo = localDateTo.plusDays(1L).minusNanos(1000);
              examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateFrom), Timestamp.valueOf(localDateTo), regOrderClassList);
            } else {
              // 1日指定
              fromDate = reportMenu.getSpecifyDate();
              toDate = reportMenu.getSpecifyDate();
              LocalDateTime localDateTarget = LocalDate.parse(reportMenu.getSpecifyDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
              LocalDateTime localDateTo = localDateTarget.plusDays(1L).minusNanos(1000);
              examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateTarget), Timestamp.valueOf(localDateTo), regOrderClassList);
            }
            for (PatExamMain exam : examMainList) {
              examMainCds.add(exam.getExamMainCd());
              if (Objects.equal(exam.getExamStatus(), "1")) {
                // 検査実績
                // 検査と同日の透析実績リストを取得する
                String uuuuMMdd = exam.getResultExamDate().toLocalDateTime().toLocalDate().format(DateTimeFormatter.ofPattern("uuuuMMdd"));
                List<OrdMain> ords = ordList.stream().filter(
                  o -> Objects.equal(o.getTreatDate(), uuuuMMdd)).collect(Collectors.toList());
                if (ords.size() > 0) {
                  // 検査日と同じ日に透析実績がある
                  for (OrdMain ord : ords) {
                    ReportParam reportParam = new ReportParam();
                    reportParam.ordNo = ord.getOrdNo();
                    reportParam.date = dateStr2dispDateStr(uuuuMMdd);
                    reportParam.dateFrom = dateStr2dispDateStr(fromDate);
                    reportParam.dateTo = dateStr2dispDateStr(toDate);
                    params.add(reportParam);
                  }
                } else {
                  // 実績なし
                  // 検査日と同じ日に透析実績はない
                  ReportParam reportParam = new ReportParam();
                  reportParam.ordNo = null;
                  reportParam.date = dateStr2dispDateStr(uuuuMMdd);
                  reportParam.dateFrom = dateStr2dispDateStr(fromDate);
                  reportParam.dateTo = dateStr2dispDateStr(toDate);
                  params.add(reportParam);
                }
              } else {
                // 検査予定
                LocalDate regExamDate = exam.getRegExamDate().toLocalDateTime().toLocalDate();
                if (nowDate.isAfter(regExamDate)) {
                  // 今日が予定日よりも後にあるものはは実績のない過去の検査予定
                  continue;
                } else {
                  // 本日以降の検査予定
                  // 検査予定
                  String uuuuMMdd = regExamDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));
                  List<OrdMain> ords = ordList.stream().filter(
                    o -> Objects.equal(o.getTreatDate(), uuuuMMdd)).collect(Collectors.toList());
                  if (ords.size() > 0) {
                    for (OrdMain ord : ords) {
                      ReportParam reportParam = new ReportParam();
                      reportParam.ordNo = ord.getOrdNo();
                      reportParam.date = dateStr2dispDateStr(uuuuMMdd);
                      reportParam.dateFrom = dateStr2dispDateStr(fromDate);
                      reportParam.dateTo = dateStr2dispDateStr(toDate);
                      params.add(reportParam);
                    }
                  } else {
                    // 実績なし
                    ReportParam reportParam = new ReportParam();
                    reportParam.ordNo = null;
                    reportParam.date = dateStr2dispDateStr(uuuuMMdd);
                    reportParam.dateFrom = dateStr2dispDateStr(fromDate);
                    reportParam.dateTo = dateStr2dispDateStr(toDate);
                    params.add(reportParam);
                  }
                }
              }
            }
          }
        }

        // テンプレート外用オーダー番号
        Long outTemplateOrdNo = null;
        // 以下の構造のMapを生成する
        // キー: ordNo テンプレート外 オーダー番号
        // キー: patId テンプレート外 患者ID
        // キー: tmplParams テンプレート内パラメーター ordPrescriptionNo + patId + facilityCdのList<Map<String, Object>>
        Map<String, Object> dataKey = new HashMap<>();
        // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
        dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
        dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
        dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
        // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
        // テンプレート外パラメータとしてオーダー番号と患者ID
        dataKey.put(ReportConstant.ReportDataKey.PAT_ID, patId);
        // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
        // dataKey.put(ReportConstant.ReportDataKey.ORD_NO, outTemplateOrdNo);
        dataKey.put(ReportConstant.ReportDataKey.ORD_NO, ordNo);
        // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
        dataKey.put(ReportConstant.ReportDataKey.DATE, nowYYYYMMDD);
        // テンプレート内パラメータ
        String fromDate ="";
        String toData = "";
        String data ="";
        if(null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate()){
          fromDate=dateStr2dispDateStr(reportMenu.getSpecifyDate());
          toData=dateStr2dispDateStr(reportMenu.getSpecifyDate());
          data = dateStr2dispDateStr(reportMenu.getSpecifyDate());
        }else{
          fromDate=dateStr2dispDateStr(reportMenu.getFromDate());
          toData=dateStr2dispDateStr(reportMenu.getToDate());
          data = dateStr2dispDateStr(reportMenu.getFromDate());
        }
        dataKey.put(ReportConstant.ReportDataKey.DATE_TO, toData);
        dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate);
        dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
        dataKey.put("login", userName);
        dataKey.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
        // mod #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 start
        //dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getTreatDate());
        dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate());
        // mod #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 end
        dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
        dataKey.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
        dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
        dataKey.put("examMainCds",examMainCds);

        //条件に合った処方箋を取得します
        // mod #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240613 sunsy start
//        List<OrdPrescription> ordPrescriptionList = ordPrescriptionDao.selectResultByPatId(patId, fromDate.replace("/",""), toData.replace("/",""));
        // mod #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
//        List<OrdPrescription> ordPrescriptionList = ordPrescriptionDao.selectResultByPatId(patId, fromDate.replace("/",""));
        // 処方箋区分
        List<String> prescriptionClassList = reportMenu.getPrescriptionClassList();
        List<OrdPrescription> ordPrescriptionList = ordPrescriptionDao.selectResultByPatId(patId, fromDate.replace("/",""),prescriptionClassList);
        // mod #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end
        // mod #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240613 sunsy end
        if(null != ordPrescriptionList && ordPrescriptionList.size() >0){
          for (int p = 0; p < ordPrescriptionList.size(); p++){
            Map<String, Object> tmplPrescriptionParam = new HashMap<>();
            List<Map<String, Object>> tmplPrescriptionParams = new ArrayList<>();
            dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO,ordPrescriptionList.get(p).getOrdPrescriptionNo());
            tmplPrescriptionParam.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO, ordPrescriptionList.get(p).getOrdPrescriptionNo());
            tmplPrescriptionParam.put(ReportConstant.ReportDataKey.PAT_ID, ordPrescriptionList.get(p).getPatId());
            tmplPrescriptionParam.put(ReportConstant.ReportDataKey.FACILITY_CD, ordPrescriptionList.get(p).getFacilityCd());
            tmplPrescriptionParam.put(ReportConstant.ReportDataKey.DATE_FROM, ordPrescriptionList.get(p).getIssueDate());
            tmplPrescriptionParam.put(ReportConstant.ReportDataKey.DATE_TO, ordPrescriptionList.get(p).getExpirationDate());
            // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
            tmplPrescriptionParam.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
            tmplPrescriptionParam.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
            tmplPrescriptionParam.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
            // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
            // del #7641 自動印刷で値が入らない項目がある 王永吉 start
            // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
            // tmplPrescriptionParam.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getTreatDate());
            // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
            // del #7641 自動印刷で値が入らない項目がある 王永吉 end
            tmplPrescriptionParams.add(tmplPrescriptionParam);
            dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, tmplPrescriptionParams);

            htmlResult += reportService.getReportHtml(reportCd, dataKey, null, userId);

            // del #12445 【因島】帳票に出力されない画像がある 差戻1 sunsy start
//            // add #12245 【因島】帳票に出力されない画像がある  吉 start
//            String uuid = UUID.randomUUID().toString();
//            String clipPrefix = "CLIP-" + uuid + "-" + index + "-";
//            htmlResult = htmlResult.replaceAll("id=\"CLIP(.*?)\"", "id=\"" + clipPrefix + "$1\"");
//            htmlResult = htmlResult.replaceAll("url\\(#CLIP(.*?)\\)", "url(#" + clipPrefix + "$1)");
//            // add #12245 【因島】帳票に出力されない画像がある  吉 end
            // del #12445 【因島】帳票に出力されない画像がある 差戻1 sunsy end
          }
        }else{
          dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO,0);
          htmlResult += reportService.getReportHtml(reportCd, dataKey, null, userId);

          // del #12445 【因島】帳票に出力されない画像がある 差戻1 sunsy start
//          // add #12245 【因島】帳票に出力されない画像がある  吉 start
//          String uuid = UUID.randomUUID().toString();
//          String clipPrefix = "CLIP-" + uuid + "-" + index + "-";
//          htmlResult = htmlResult.replaceAll("id=\"CLIP(.*?)\"", "id=\"" + clipPrefix + "$1\"");
//          htmlResult = htmlResult.replaceAll("url\\(#CLIP(.*?)\\)", "url(#" + clipPrefix + "$1)");
//          // add #12245 【因島】帳票に出力されない画像がある  吉 end
          // del #12445 【因島】帳票に出力されない画像がある 差戻1 sunsy end
        }
      }
    }
    // add #6346 処方の項目が足りない 王永吉 end
    else if (reportClass.equals(ReportConstant.ReportClass.ONE_PATIENT_REPORT)) {
      // 単患者帳票
      List<String> regOrderClassList = reportMenu.getRegOrderClassList();
      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
      Map<String,List> searchList =this.searchMap(reportMenu.getFacilityCd());
      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
      /*mod FNSI-改修内容 各帳票の並び順調整。 吉 start*/
      //    List<Long> patIds = reportMenu.getPatIds();
      List<Long> patIds=new ArrayList<Long>();
      if(null != patOrdNo){
        for(int i=0;i<patOrdNo.size();i++){
          patIds.add(patOrdNo.get(i).getPatId());
        }
      }
      /*mod FNSI-改修内容 各帳票の並び順調整。 吉 end*/

      LocalDate nowDate = LocalDate.now();
      String nowYYYYMMDD = nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));
      // add #7943 帳票レイアウトデザイナーが正しく動作しない 日本指摘対応 商 start
      String oldhtmlResult = "";
      // add #7943 帳票レイアウトデザイナーが正しく動作しない 日本指摘対応 商 end

      for (int index = 0; index < patOrdNo.size(); index++) {
        // 選択された患者の数だけ帳票を生成する

        Long patId = patIds.get(index);

        List<ReportParam> params = new ArrayList<>();
        List<Long> examMainCds = new ArrayList<>();
        if (reportMenu.getIsDialysisDate()) {
          // 透析日基準
          // 指定日、または期間内の透析日をターゲットに治療情報を取得します。

          List<OrdMain> ordList = reportMenuDao.selectByTreatDate(patId, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
          if (reportMenu.getSpecifyDate() == null) {
            // 範囲指定ならば
            for (OrdMain ord: ordList) {
              ReportParam reportParam = new ReportParam();
              reportParam.ordNo = ord.getOrdNo();
              reportParam.date = dateStr2dispDateStr(ord.getTreatDate());
              reportParam.dateFrom = dateStr2dispDateStr(reportMenu.getFromDate());
              reportParam.dateTo = dateStr2dispDateStr(reportMenu.getToDate());
              params.add(reportParam);
            }
          } else {
            // 指定日ならば
            for (OrdMain ord: ordList) {
              String treatDate = dateStr2dispDateStr(ord.getTreatDate());
              ReportParam reportParam = new ReportParam();
              reportParam.ordNo = ord.getOrdNo();
              reportParam.date = treatDate;
              reportParam.dateFrom = treatDate;
              reportParam.dateTo = treatDate;
              params.add(reportParam);
            }
          }

        } else {
          // 検査日基準

          List<PatExamMain> examMainList =  new ArrayList<>();

          if (reportMenu.getRegOrderClassList().size() > 0) {
            // 検査区分が指定されていなかったら検査対象を取得できないので、検索処理を行わない

            List<OrdMain> ordList = reportMenuDao.selectByTreatDate(patId, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
            // 日付がどのように選択されているか確認して、検査結果リストを取得する
            String fromDate = reportMenu.getFromDate();
            String toDate = reportMenu.getToDate();
            if (reportMenu.getSpecifyDate() == null) {
              // 期間指定
              LocalDateTime localDateFrom = LocalDate.parse(reportMenu.getFromDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
              LocalDateTime localDateTo = LocalDate.parse(reportMenu.getToDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
              localDateTo = localDateTo.plusDays(1L).minusNanos(1000);
              examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateFrom), Timestamp.valueOf(localDateTo), regOrderClassList);
            } else {
              // 1日指定
              fromDate = reportMenu.getSpecifyDate();
              toDate = reportMenu.getSpecifyDate();
              LocalDateTime localDateTarget = LocalDate.parse(reportMenu.getSpecifyDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
              LocalDateTime localDateTo = localDateTarget.plusDays(1L).minusNanos(1000);
              examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateTarget), Timestamp.valueOf(localDateTo), regOrderClassList);
            }

            for (PatExamMain exam : examMainList) {
              examMainCds.add(exam.getExamMainCd());
              if (Objects.equal(exam.getExamStatus(), "1")) {
                // 検査実績

                // 検査と同日の透析実績リストを取得する
                String uuuuMMdd = exam.getResultExamDate().toLocalDateTime().toLocalDate().format(DateTimeFormatter.ofPattern("uuuuMMdd"));
                List<OrdMain> ords = ordList.stream().filter(
                    o -> Objects.equal(o.getTreatDate(), uuuuMMdd)).collect(Collectors.toList());

                if (ords.size() > 0) {
                  // 検査日と同じ日に透析実績がある
                  for (OrdMain ord : ords) {
                    ReportParam reportParam = new ReportParam();
                    reportParam.ordNo = ord.getOrdNo();
                    reportParam.date = dateStr2dispDateStr(uuuuMMdd);
                    reportParam.dateFrom = dateStr2dispDateStr(fromDate);
                    reportParam.dateTo = dateStr2dispDateStr(toDate);
                    params.add(reportParam);
                  }
                } else {
                  // 実績なし
                  // 検査日と同じ日に透析実績はない
                  ReportParam reportParam = new ReportParam();
                  reportParam.ordNo = null;
                  reportParam.date = dateStr2dispDateStr(uuuuMMdd);
                  reportParam.dateFrom = dateStr2dispDateStr(fromDate);
                  reportParam.dateTo = dateStr2dispDateStr(toDate);
                  params.add(reportParam);
                }
              } else {
                // 検査予定
                LocalDate regExamDate = exam.getRegExamDate().toLocalDateTime().toLocalDate();
                if (nowDate.isAfter(regExamDate)) {
                  // 今日が予定日よりも後にあるものはは実績のない過去の検査予定
                  continue;
                } else {
                  // 本日以降の検査予定
                  // 検査予定
                  String uuuuMMdd = regExamDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));
                  List<OrdMain> ords = ordList.stream().filter(
                      o -> Objects.equal(o.getTreatDate(), uuuuMMdd)).collect(Collectors.toList());

                  if (ords.size() > 0) {
                    for (OrdMain ord : ords) {
                      ReportParam reportParam = new ReportParam();
                      reportParam.ordNo = ord.getOrdNo();
                      reportParam.date = dateStr2dispDateStr(uuuuMMdd);
                      reportParam.dateFrom = dateStr2dispDateStr(fromDate);
                      reportParam.dateTo = dateStr2dispDateStr(toDate);
                      params.add(reportParam);
                    }
                  } else {
                    // 実績なし
                    ReportParam reportParam = new ReportParam();
                    reportParam.ordNo = null;
                    reportParam.date = dateStr2dispDateStr(uuuuMMdd);
                    reportParam.dateFrom = dateStr2dispDateStr(fromDate);
                    reportParam.dateTo = dateStr2dispDateStr(toDate);
                    params.add(reportParam);
                  }
                }
              }
            }
          }
        }

        // 以下の構造のMapを生成する
        // キー: ordNo テンプレート外 オーダー番号
        // キー: patId テンプレート外 患者ID
        // キー: tmplParams テンプレート内パラメーター ordNo + patIdのList<Map<String, Object>>
        Map<String, Object> dataKey = new HashMap<>();
        // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
        dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
        dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
        dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
        // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
        // テンプレート外パラメータとしてオーダー番号と患者ID
        dataKey.put(ReportConstant.ReportDataKey.PAT_ID, patId);
        dataKey.put(ReportConstant.ReportDataKey.ORD_NO, patOrdNo.get(index).getOrdNo());

        // テンプレート内パラメータ
        List<Map<String, Object>> tmplParams = new ArrayList<Map<String, Object>>();
        //mod 帳票用のパラqメーター設定処理  吉 start
//        for (ReportParam param : params) {
//          Map<String, Object> tmplParam = new HashMap<>();
//          tmplParam.put(ReportConstant.ReportDataKey.ORD_NO, param.ordNo);
//          tmplParam.put(ReportConstant.ReportDataKey.PAT_ID, patId);
//          tmplParam.put(ReportConstant.ReportDataKey.DATE, param.date);
//          tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, param.dateFrom);
//          tmplParams.add(tmplParam);
//        }
//        dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, tmplParams);
        String fromDate ="";
        String toData = "";
        String data ="";
        if(null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate()){
          fromDate=dateStr2dispDateStr(reportMenu.getSpecifyDate());
          toData=dateStr2dispDateStr(reportMenu.getSpecifyDate());
          data = dateStr2dispDateStr(reportMenu.getSpecifyDate());
        }else{
          fromDate=dateStr2dispDateStr(reportMenu.getFromDate());
          toData=dateStr2dispDateStr(reportMenu.getToDate());
          data = dateStr2dispDateStr(reportMenu.getFromDate());
        }
        dataKey.put(ReportConstant.ReportDataKey.DATE, data);
        Map<String, Object> tmplParam = new HashMap<>();
        tmplParam.put(ReportConstant.ReportDataKey.ORD_NO, patOrdNo.get(index).getOrdNo());
        tmplParam.put(ReportConstant.ReportDataKey.PAT_ID, patId);
        tmplParam.put(ReportConstant.ReportDataKey.DATE, data);
        tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate);
        tmplParam.put(ReportConstant.ReportDataKey.DATE_TO,toData);
        // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
        tmplParam.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
        tmplParam.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
        tmplParam.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
        // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
        // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 start
        tmplParam.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
        // add #7840 帳票（単患者）：薬剤にフィルター機能がない 王永吉 end
        // del #7641 自動印刷で値が入らない項目がある 王永吉 start
        // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
        // tmplParam.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getTreatDate());
        // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
        // del #7641 自動印刷で値が入らない項目がある 王永吉 end
        tmplParams.add(tmplParam);
        dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, tmplParams);

        dataKey.put(ReportConstant.ReportDataKey.DATE_TO, toData);
        dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate);
        dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());

        List<Long> prescriptionList = ordPrescriptionDao.getPrescriptionListByPatId(patId,reportMenu.getFacilityCd());
        if(null != prescriptionList && prescriptionList.size()>0){
          dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS,prescriptionList);
          // add #6346 処方の項目が足りない 王永吉 start
          dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO,prescriptionList);
          // add #6346 処方の項目が足りない 王永吉 end
        }else{
          dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS,0);
          // add #6346 処方の項目が足りない 王永吉 start
          dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO,0);
          // add #6346 処方の項目が足りない 王永吉 end
        }
        //mod 帳票用のパラメーター設定処理  吉 end
        dataKey.put("login", userName);
        //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
        dataKey.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
        // mod #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 start
        //dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getTreatDate());
        dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate());
        // mod #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 end
        dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
        dataKey.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
        dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
        dataKey.put("examMainCds",examMainCds);
        // add 項目別(印刷情報一覧)の項目が実装されない  吉 end
        // mod #7943 帳票レイアウトデザイナーが正しく動作しない 日本指摘対応 商 start
        //htmlResult += reportService.getReportHtml(reportCd, dataKey, null, userId);
        htmlResult = reportService.getReportHtml(reportCd, dataKey, null, userId);

        // del #12445 【因島】帳票に出力されない画像がある 差戻1 sunsy start
//        // add #12245 【因島】帳票に出力されない画像がある  吉 start
//        String uuid = UUID.randomUUID().toString();
//        String clipPrefix = "CLIP-" + uuid + "-" + index + "-";
//        htmlResult = htmlResult.replaceAll("id=\"CLIP(.*?)\"", "id=\"" + clipPrefix + "$1\"");
//        htmlResult = htmlResult.replaceAll("url\\(#CLIP(.*?)\\)", "url(#" + clipPrefix + "$1)");
//        // add #12245 【因島】帳票に出力されない画像がある  吉 end
        // del #12445 【因島】帳票に出力されない画像がある 差戻1 sunsy end

        if("".equals(oldhtmlResult)){
          oldhtmlResult = htmlResult;
        }else {
          if (!htmlResult.equals(oldhtmlResult)) {
            // mod 新しいプラグイ改ページ 吉 start
            // htmlResult += reportService.getReportHtml(reportCd, dataKey, null, userId);
            htmlResult = oldhtmlResult + htmlResult;
            // mod 新しいプラグイ改ページ 吉 end
          }
          oldhtmlResult = htmlResult;
        }
        // mod #7943 帳票レイアウトデザイナーが正しく動作しない 日本指摘対応 商 end
      }
      // add #7927 帳票に患者情報が出力されない場合がある 王永吉 start
      if (null != patOrdNoDoOnePats && patOrdNoDoOnePats.size() > 0){
        List<Long> patIdOnePats=new ArrayList<Long>();
        for(int i = 0; i < patOrdNoDoOnePats.size(); i++){
          patIdOnePats.add(patOrdNoDoOnePats.get(i).getPatId());
        }
        for (int index = 0; index < patOrdNoDoOnePats.size(); index++){
          // 選択された患者の数だけ帳票を生成する

          Long patId = patIdOnePats.get(index);
          List<ReportParam> params = new ArrayList<>();
          List<Long> examMainCds = new ArrayList<>();
          if (reportMenu.getIsDialysisDate()) {
            // 透析日基準
            // 指定日、または期間内の透析日をターゲットに治療情報を取得します。
            List<OrdMain> ordList = reportMenuDao.selectByTreatDate(patId, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
            if (reportMenu.getSpecifyDate() == null) {
              // 範囲指定ならば
              for (OrdMain ord: ordList) {
                ReportParam reportParam = new ReportParam();
                reportParam.ordNo = ord.getOrdNo();
                reportParam.date = dateStr2dispDateStr(ord.getTreatDate());
                reportParam.dateFrom = dateStr2dispDateStr(reportMenu.getFromDate());
                reportParam.dateTo = dateStr2dispDateStr(reportMenu.getToDate());
                params.add(reportParam);
              }
            } else {
              // 指定日ならば
              for (OrdMain ord: ordList) {
                String treatDate = dateStr2dispDateStr(ord.getTreatDate());
                ReportParam reportParam = new ReportParam();
                reportParam.ordNo = ord.getOrdNo();
                reportParam.date = treatDate;
                reportParam.dateFrom = treatDate;
                reportParam.dateTo = treatDate;
                params.add(reportParam);
              }
            }
          } else {
            // 検査日基準
            List<PatExamMain> examMainList =  new ArrayList<>();
            if (reportMenu.getRegOrderClassList().size() > 0) {
              // 検査区分が指定されていなかったら検査対象を取得できないので、検索処理を行わない
              List<OrdMain> ordList = reportMenuDao.selectByTreatDate(patId, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
              // 日付がどのように選択されているか確認して、検査結果リストを取得する
              String fromDate = reportMenu.getFromDate();
              String toDate = reportMenu.getToDate();
              if (reportMenu.getSpecifyDate() == null) {
                // 期間指定
                LocalDateTime localDateFrom = LocalDate.parse(reportMenu.getFromDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
                LocalDateTime localDateTo = LocalDate.parse(reportMenu.getToDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
                localDateTo = localDateTo.plusDays(1L).minusNanos(1000);
                examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateFrom), Timestamp.valueOf(localDateTo), regOrderClassList);
              } else {
                // 1日指定
                fromDate = reportMenu.getSpecifyDate();
                toDate = reportMenu.getSpecifyDate();
                LocalDateTime localDateTarget = LocalDate.parse(reportMenu.getSpecifyDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
                LocalDateTime localDateTo = localDateTarget.plusDays(1L).minusNanos(1000);
                examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateTarget), Timestamp.valueOf(localDateTo), regOrderClassList);
              }

              for (PatExamMain exam : examMainList) {
                examMainCds.add(exam.getExamMainCd());
                if (Objects.equal(exam.getExamStatus(), "1")) {
                  // 検査実績
                  // 検査と同日の透析実績リストを取得する
                  String uuuuMMdd = exam.getResultExamDate().toLocalDateTime().toLocalDate().format(DateTimeFormatter.ofPattern("uuuuMMdd"));
                  List<OrdMain> ords = ordList.stream().filter(
                    o -> Objects.equal(o.getTreatDate(), uuuuMMdd)).collect(Collectors.toList());
                  if (ords.size() > 0) {
                    // 検査日と同じ日に透析実績がある
                    for (OrdMain ord : ords) {
                      ReportParam reportParam = new ReportParam();
                      reportParam.ordNo = ord.getOrdNo();
                      reportParam.date = dateStr2dispDateStr(uuuuMMdd);
                      reportParam.dateFrom = dateStr2dispDateStr(fromDate);
                      reportParam.dateTo = dateStr2dispDateStr(toDate);
                      params.add(reportParam);
                    }
                  } else {
                    // 実績なし
                    // 検査日と同じ日に透析実績はない
                    ReportParam reportParam = new ReportParam();
                    reportParam.ordNo = null;
                    reportParam.date = dateStr2dispDateStr(uuuuMMdd);
                    reportParam.dateFrom = dateStr2dispDateStr(fromDate);
                    reportParam.dateTo = dateStr2dispDateStr(toDate);
                    params.add(reportParam);
                  }
                } else {
                  // 検査予定
                  LocalDate regExamDate = exam.getRegExamDate().toLocalDateTime().toLocalDate();
                  if (nowDate.isAfter(regExamDate)) {
                    // 今日が予定日よりも後にあるものはは実績のない過去の検査予定
                    continue;
                  } else {
                    // 本日以降の検査予定
                    // 検査予定
                    String uuuuMMdd = regExamDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));
                    List<OrdMain> ords = ordList.stream().filter(
                      o -> Objects.equal(o.getTreatDate(), uuuuMMdd)).collect(Collectors.toList());
                    if (ords.size() > 0) {
                      for (OrdMain ord : ords) {
                        ReportParam reportParam = new ReportParam();
                        reportParam.ordNo = ord.getOrdNo();
                        reportParam.date = dateStr2dispDateStr(uuuuMMdd);
                        reportParam.dateFrom = dateStr2dispDateStr(fromDate);
                        reportParam.dateTo = dateStr2dispDateStr(toDate);
                        params.add(reportParam);
                      }
                    } else {
                      // 実績なし
                      ReportParam reportParam = new ReportParam();
                      reportParam.ordNo = null;
                      reportParam.date = dateStr2dispDateStr(uuuuMMdd);
                      reportParam.dateFrom = dateStr2dispDateStr(fromDate);
                      reportParam.dateTo = dateStr2dispDateStr(toDate);
                      params.add(reportParam);
                    }
                  }
                }
              }
            }
          }
          // テンプレート外用オーダー番号
          Long outTemplateOrdNo = null;
          // この患者の直近1件の治療予定を取得
          OrdMain near = reportMenuDao.selectNearOrdPlan(patId, nowYYYYMMDD);
          if (near != null) {
            outTemplateOrdNo = near.getOrdNo();
          } else {
            List<ReportParam> tmpParams = params.stream().filter(o -> o.ordNo != null).collect(Collectors.toList());
            if (tmpParams.size() > 0) {
              outTemplateOrdNo = tmpParams.get(tmpParams.size() - 1).ordNo;
            }
          }
          // 以下の構造のMapを生成する
          // キー: ordNo テンプレート外 オーダー番号
          // キー: patId テンプレート外 患者ID
          // キー: tmplParams テンプレート内パラメーター ordNo + patIdのList<Map<String, Object>>
          Map<String, Object> dataKey = new HashMap<>();
          dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
          dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
          dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
          // テンプレート外パラメータとしてオーダー番号と患者ID
          dataKey.put(ReportConstant.ReportDataKey.PAT_ID, patId);
          dataKey.put(ReportConstant.ReportDataKey.ORD_NO, outTemplateOrdNo);
          dataKey.put(ReportConstant.ReportDataKey.DATE, nowYYYYMMDD);
          // テンプレート内パラメータ
          List<Map<String, Object>> tmplParams = new ArrayList<Map<String, Object>>();
          String fromDate ="";
          String toData = "";
          String data ="";
          if(null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate()){
            fromDate=dateStr2dispDateStr(reportMenu.getSpecifyDate());
            toData=dateStr2dispDateStr(reportMenu.getSpecifyDate());
            data = dateStr2dispDateStr(reportMenu.getSpecifyDate());
          }else{
            fromDate=dateStr2dispDateStr(reportMenu.getFromDate());
            toData=dateStr2dispDateStr(reportMenu.getToDate());
            data = dateStr2dispDateStr(reportMenu.getFromDate());
          }
          Map<String, Object> tmplParam = new HashMap<>();
          tmplParam.put(ReportConstant.ReportDataKey.ORD_NO, patOrdNoDoOnePats.get(index).getOrdNo());
          tmplParam.put(ReportConstant.ReportDataKey.PAT_ID, patId);
          tmplParam.put(ReportConstant.ReportDataKey.DATE, data);
          tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate);
          tmplParam.put(ReportConstant.ReportDataKey.DATE_TO,toData);
          tmplParam.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
          tmplParam.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
          tmplParam.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
          tmplParam.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
          tmplParams.add(tmplParam);

          dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, tmplParams);
          dataKey.put(ReportConstant.ReportDataKey.DATE_TO, toData);
          dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate);
          dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());

          List<Long> prescriptionList = ordPrescriptionDao.getPrescriptionListByPatId(patId,reportMenu.getFacilityCd());
          if(null != prescriptionList && prescriptionList.size()>0){
            dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS,prescriptionList);
            dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO,prescriptionList);
          }else{
            dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS,0);
            dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NO,0);
          }
          dataKey.put("login", userName);
          dataKey.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
          dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate());
          dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
          dataKey.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
          dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
          dataKey.put("examMainCds",examMainCds);
          htmlResult += reportService.getReportHtml(reportCd, dataKey, null, userId);
        }
      }
      // add #7927 帳票に患者情報が出力されない場合がある 王永吉 end
    } else if (reportClass.equals(ReportConstant.ReportClass.MULTIPLE_PATIENT_REPORT)) {
      // 複数患者帳票
      /*mod FNSI-改修内容 各帳票の並び順調整。 吉 start*/
//      List<Long> patIds = reportMenu.getPatIds();
      List<Long> patIds=new ArrayList<Long>();
      if(null != patOrdNo){
        for(int i=0;i<patOrdNo.size();i++){
          patIds.add(patOrdNo.get(i).getPatId());
        }
      }
      /*mod FNSI-改修内容 各帳票の並び順調整。 吉 end*/
      // add #7958 PDFとEXCELのファイル出力の内容が異なる 内部指摘対応 鄭爽 start
      Collections.sort(patIds);
      // add #7958 PDFとEXCELのファイル出力の内容が異なる 内部指摘対応 鄭爽 end
      LocalDate nowDate = LocalDate.now();
      String nowYYYYMMDD = nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));

      List<ReportParam> params = new ArrayList<>();

      Long patId;

      if (reportMenu.getIsDialysisDate()) {
        // 透析日基準

        // 患者IDリストで渡された患者の期間内での透析データを取得
        // 透析データが期間内に存在しない場合は、期間終了日の患者情報のみを取得する
        List<OrdMain> ordList =  reportMenuDao.selectResultByTreatDateAndPatIds(patIds, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());

        for (int index = 0; index < patIds.size(); index++)
        {
          patId = patIds.get(index);
          ReportParam reportParam = new ReportParam();
          String dateString = null;

          OrdMain ordMain = null;
          for (OrdMain ord : ordList) {
            if (patId.equals(ord.getPatId())) {
              // 最新の治療データを取得 ( 治療日降順でソートしているので、1レコード目が最新 )
              ordMain = ord;
              // 同じ患者IDでの治療情報重複を防ぐため、取得したら配列から要素を削除
              ordList.remove(ordList.indexOf(ord));
              break;
            }
          }
          if (ordMain != null) {
            reportParam.ordNo = ordMain.getOrdNo();
            dateString = dateStr2dispDateStr(ordMain.getTreatDate());
          } else {
            // 該当する治療データが存在しない場合は、期間終了日の患者情報のみを取得する
            if (reportMenu.getSpecifyDate() == null) {
              // 範囲指定
              // 期間終了日
              dateString = reportMenu.getToDate();
            } else {
              // 1日指定
              // 特定日付
              dateString = reportMenu.getSpecifyDate();
            }
          }

          // 1患者のパラメータ
          reportParam.patId = patId;
          reportParam.date = dateString;
          reportParam.dateFrom = reportMenu.getFromDate();
          reportParam.dateTo = reportMenu.getToDate();
          params.add(reportParam);

        }
        // mod #12341 複数患者帳票を処方日でファイル保存するとシステムエラー 高　start
//      } else if (reportMenu.getRegOrderClassList().size() > 0) {
      } else if (reportMenu.getRegOrderClassList() != null && reportMenu.getRegOrderClassList().size() > 0) {
        // mod #12341 複数患者帳票を処方日でファイル保存するとシステムエラー 高　end
        // 検査日基準
        // 検査区分(チェックボックス)が指定されていなかったら検査対象を取得できないので、検索処理を行わない

        // 患者IDリストで渡された患者の期間内での最新の検査結果の検査日を取得する。
        // 検査結果が存在しない場合は、期間内の今日以降の直近検査予定の検査日を取得する。
        // 検査結果または検査結果を取得する際のフィルタとして、帳票画面の検査区分、およびExcelパラメータの各検査コード、検査区分を使用する。
        // 検査結果、検査予定共に無い場合は、患者情報のみ。

        for (int index = 0; index < patIds.size(); index++)
        {

          patId = patIds.get(index);

          ReportParam reportParam = new ReportParam();
          reportParam.patId = patId;

          // 検査結果
          List<PatExamMain> examMainList =  new ArrayList<>();

          // 検索区分
          List<String> regOrderClassList = reportMenu.getRegOrderClassList();

          // 日付がどのように選択されているか確認して、検査結果リストを取得する
          String fromDate;
          String toDate;
          if (reportMenu.getSpecifyDate() == null) {
            // 期間指定
            fromDate = reportMenu.getFromDate();
            toDate = reportMenu.getToDate();
            LocalDateTime localDateFrom = LocalDate.parse(reportMenu.getFromDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
            LocalDateTime localDateTo = LocalDate.parse(reportMenu.getToDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
            localDateTo = localDateTo.plusDays(1L).minusNanos(1000);
            examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateFrom), Timestamp.valueOf(localDateTo), regOrderClassList);
          } else {
            // 1日指定
            fromDate = reportMenu.getSpecifyDate();
            toDate = reportMenu.getSpecifyDate();
            LocalDateTime localDateTarget = LocalDate.parse(reportMenu.getSpecifyDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
            LocalDateTime localDateTo = localDateTarget.plusDays(1L).minusNanos(1000);
            examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateTarget), Timestamp.valueOf(localDateTo), regOrderClassList);
          }

          boolean isNotExistExamResult = true;
          for (PatExamMain exam : examMainList) {
            // 検査日リスト
            // 期間内での最新の検査結果の検査日を取得する

            if (Objects.equal(exam.getExamStatus(), "1")) {
              // 検査結果
              // 検査日時が最新であるか判定する処理を実装する
              isNotExistExamResult = false;
              String uuuuMMdd = exam.getResultExamDate().toLocalDateTime().toLocalDate().format(DateTimeFormatter.ofPattern("uuuuMMdd"));
              reportParam.date = dateStr2dispDateStr(uuuuMMdd);
              reportParam.dateFrom = dateStr2dispDateStr(fromDate);
              reportParam.dateTo = dateStr2dispDateStr(toDate);

            } else if(isNotExistExamResult) {
              // 検査予定
              String uuuuMMdd = exam.getRegExamDate().toLocalDateTime().toLocalDate().format(DateTimeFormatter.ofPattern("uuuuMMdd"));
              reportParam.date = dateStr2dispDateStr(uuuuMMdd);
              reportParam.dateFrom = dateStr2dispDateStr(fromDate);
              reportParam.dateTo = dateStr2dispDateStr(toDate);
            }

          }

          // 透析実績と紐づける
          List<OrdMain> ordList = reportMenuDao.selectByTreatDate(patId, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
          List<OrdMain> ords = ordList.stream().filter(
              // mod 2020-11-10 初回(IES)528 フィルタ動作対応 夏 start
            //o -> Objects.equal(o.getTreatDate(), reportParam.date)).collect(Collectors.toList());
              o -> Objects.equal(o.getTreatDate(), reportParam.date == null ? null : reportParam.date.replace("/", ""))).collect(Collectors.toList());
              // mod 2020-11-10 初回(IES)528 フィルタ動作対応 夏 end
          if (ords.size() > 0) {
            // 検査日と同じ日に透析実績がある場合、透析番号を紐づける
            reportParam.ordNo = ords.get(ords.size() - 1).getOrdNo();
          }

          params.add(reportParam);

        }

      }

      // add #12341 複数患者帳票を処方日でファイル保存するとシステムエラー 高　start
      else if (reportMenu.getPrescriptionClassList() != null && reportMenu.getPrescriptionClassList().size() > 0) {
        for (int index = 0; index < patIds.size(); index++)
        {
          patId = patIds.get(index);

          ReportParam reportParam = new ReportParam();
          reportParam.patId = patId;

          // 処方結果
          List<OrdPrescription> ordPrescriptionList =  new ArrayList<>();

          // 処方区分
          List<String> prescriptionClassList = reportMenu.getPrescriptionClassList();

          // 日付がどのように選択されているか確認して、処方結果リストを取得する
          String fromDate;
          String toDate;
          if (reportMenu.getSpecifyDate() == null) {
            // 期間指定
            fromDate = reportMenu.getFromDate();
            toDate = reportMenu.getToDate();
            LocalDateTime localDateFrom = LocalDate.parse(reportMenu.getFromDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
            LocalDateTime localDateTo = LocalDate.parse(reportMenu.getToDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
            localDateTo = localDateTo.plusDays(1L).minusNanos(1000);
            ordPrescriptionList = ordPrescriptionDao.selectPrescriptionResultByPatId(patId,
              String.valueOf(localDateFrom).replace("/", "").replace("-","").substring(0,8),
              String.valueOf(localDateTo).replace("/", "").replace("-","").substring(0,8));
          } else {
            // 1日指定
            fromDate = reportMenu.getSpecifyDate();
            toDate = reportMenu.getSpecifyDate();
            LocalDateTime localDateTarget = LocalDate.parse(reportMenu.getSpecifyDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
            LocalDateTime localDateTo = localDateTarget.plusDays(1L).minusNanos(1000);
            ordPrescriptionList = ordPrescriptionDao.selectPrescriptionResultByPatId(patId,
              String.valueOf(localDateTarget).replace("/", "").replace("-","").substring(0,8),
              String.valueOf(localDateTo).replace("/", "").replace("-","").substring(0,8));
          }
          ordPrescriptionList = ordPrescriptionList.stream()
            .filter(p -> prescriptionClassList.contains(p.getPrescriptionType()))
            .collect(Collectors.toList());

          for (OrdPrescription pres : ordPrescriptionList) {
            // 処方日リスト
            // 期間内での最新の処方結果の処方日を取得する
            String uuuuMMdd = pres.getIssueDate();
            reportParam.date = dateStr2dispDateStr(uuuuMMdd);
            reportParam.dateFrom = dateStr2dispDateStr(fromDate);
            reportParam.dateTo = dateStr2dispDateStr(toDate);
          }

          // 透析実績と紐づける
          List<OrdMain> ordList = reportMenuDao.selectByTreatDate(patId, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
          List<OrdMain> ords = ordList.stream().filter(
            o -> Objects.equal(o.getTreatDate(), reportParam.date == null ? null : reportParam.date.replace("/", ""))).collect(Collectors.toList());
          if (ords.size() > 0) {
            // 処方日と同じ日に透析実績がある場合、透析番号を紐づける
            reportParam.ordNo = ords.get(ords.size() - 1).getOrdNo();
          }
          params.add(reportParam);
        }
      }
      // add #12341 複数患者帳票を処方日でファイル保存するとシステムエラー 高　end

      // テンプレート外領域のパラメータを生成する処理を実装する
      // 以下の構造のMapを生成する
      // キー: ordNo テンプレート外 オーダー番号
      // キー: patId テンプレート外 患者ID
      // キー: tmplParams テンプレート内パラメーター ordNo + patIdのList<Map<String, Object>>
      Map<String, Object> dataKey = new HashMap<>();
      // add 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 start
      dataKey.put("login", userName);
      // add 8542 紹介状（集計あり。因島様にて使用）にて出力できない項目がある 吉 end
      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
      Map<String, Object> dataKey1 = createDistributionListDataKey(reportMenu,patIds);
      dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,dataKey1.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
      dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,dataKey1.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
      dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,dataKey1.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
      // テンプレート外パラメータとして本日日付
      dataKey.put(ReportConstant.ReportDataKey.DATE, nowYYYYMMDD);

      // テンプレート内 領域のパラメータを生成する処理を実装する
      List<Map<String, Object>> tmplParams = new ArrayList<Map<String, Object>>();
      for (ReportParam param : params) {
        Map<String, Object> tmplParam = new HashMap<>();
        tmplParam.put(ReportConstant.ReportDataKey.ORD_NO, param.ordNo);
        tmplParam.put(ReportConstant.ReportDataKey.PAT_ID, param.patId);
        //mod 帳票用のパラメーター設定処理  吉 start
//        tmplParam.put(ReportConstant.ReportDataKey.DATE, param.date);
//        tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, param.dateFrom);
//        tmplParam.put(ReportConstant.ReportDataKey.DATE_TO, param.dateTo);
        if(null == reportMenu.getFromDate() ||null ==  reportMenu.getToDate()){
          param.dateFrom = reportMenu.getSpecifyDate();
          param.dateTo = reportMenu.getSpecifyDate();
          param.date = reportMenu.getSpecifyDate();
        }
        tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, dateStr2dispDateStr(param.dateFrom));
        tmplParam.put(ReportConstant.ReportDataKey.DATE_TO, dateStr2dispDateStr(param.dateTo));
        // del #7641 自動印刷で値が入らない項目がある 王永吉 start
        // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 start
        // tmplParam.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getTreatDate());
        // add 6886 帳票の患者情報が過去日付時点の内容で表示できない 王永吉 end
        // del #7641 自動印刷で値が入らない項目がある 王永吉 end
        tmplParam.put(ReportConstant.ReportDataKey.DATE, null != param.date ?dateStr2dispDateStr(param.date) : null);
        tmplParam.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
        // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
        tmplParam.put(ReportConstant.ReportDataKey.MEDICINE_IDS,dataKey.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
        tmplParam.put(ReportConstant.ReportDataKey.DIALYZER_IDS,dataKey.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
        tmplParam.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,dataKey.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
        // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
        //mod 帳票用のパラメーター設定処理  吉 end
        tmplParams.add(tmplParam);
      }
      dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, tmplParams);
      dataKey.put("login", userName);
      //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
      dataKey.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
      // mod #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 start
      //dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getTreatDate());
      dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate());
      // mod #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 end
      dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
      dataKey.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
      dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
      // add 項目別(印刷情報一覧)の項目が実装されない  吉 end
      htmlResult = reportService.getReportHtml(reportCd, dataKey, null, userId);

    }
    //add 紹介状の帳票データがordNoで抽出されてしまう 吉 start
    else if(reportClass.equals(ReportConstant.ReportClass.INTRODUCTION_REPORT)){
      List<Long> patIds=new ArrayList<Long>();
      if(null != patOrdNo){
        for(int i=0;i<patOrdNo.size();i++){
          if(null != patIds && !patIds.contains(patOrdNo.get(i).getPatId())){
            patIds.add(patOrdNo.get(i).getPatId());
          }
        }
      }
      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
      Map<String, Object> dataKey1 = createDistributionListDataKey(reportMenu,patIds);
      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
      // add #5714 紹介状が正しく出力できない 鄭爽 start
      List<Long> ordNos = new ArrayList<>();
      for (int i = 0; i < patOrdNo.size(); i++) {
        ordNos.add(patOrdNo.get(i).getOrdNo());
      }
      // add #5714 紹介状が正しく出力できない 鄭爽 end
      for (int i = 0; i < patIds.size(); i++) {
        Map<String, Object> dataKey = new HashMap<>();
        // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
        dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,dataKey1.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
        dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,dataKey1.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
        dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,dataKey1.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
        // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
        dataKey.put(ReportConstant.ReportDataKey.ORD_NO, patOrdNo.get(i).getOrdNo());
        dataKey.put(ReportConstant.ReportDataKey.PAT_ID, patIds.get(i));
        dataKey.put("login", userName);
        if (null == reportMenu.getFromDate() || null == reportMenu.getToDate()) {
          reportMenu.setFromDate(reportMenu.getSpecifyDate());
          reportMenu.setToDate(reportMenu.getSpecifyDate());
        }
        dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, dateStr2dispDateStr(reportMenu.getFromDate()));
        dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
        dataKey.put(ReportConstant.ReportDataKey.DATE_TO, dateStr2dispDateStr(reportMenu.getToDate()));
        dataKey.put(ReportConstant.ReportDataKey.DATE, null != reportMenu.getSpecifyDate() ? dateStr2dispDateStr(reportMenu.getSpecifyDate()) : null);
        //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
        dataKey.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
        // mod #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 start
        //dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getTreatDate());
        dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate());
        // mod #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 end
        dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
        dataKey.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
        dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
        // add #5714 紹介状が正しく出力できない 鄭爽 start
        // mod #8310 検査結果表示のフィルタ・表示が正しく動作していない 鄭爽 start
        // dataKey.put("ordNos",ordNos);
        dataKey.put("ordRstNos", ordNos);
        // mod #8310 検査結果表示のフィルタ・表示が正しく動作していない 鄭爽 end
        // add #5714 紹介状が正しく出力できない 鄭爽 end
        // add 項目別(印刷情報一覧)の項目が実装されない  吉 end

        //add IES因島）sql性能試験 後で削除 liuc start
        dataKey.put("sqlTestSign", reportMenu.getSqlTestTimeStr());
        //add IES因島）sql性能試験 後で削除 liuc end
        htmlResult += reportService.getReportHtml(reportCd, dataKey, null, userId);
        // del #12445 【因島】帳票に出力されない画像がある 差戻1 sunsy start
//        // add #12245 【因島】帳票に出力されない画像がある  吉 start
//        String uuid = UUID.randomUUID().toString();
//        String clipPrefix = "CLIP-" + uuid + "-" + i + "-";
//        htmlResult = htmlResult.replaceAll("id=\"CLIP(.*?)\"", "id=\"" + clipPrefix + "$1\"");
//        htmlResult = htmlResult.replaceAll("url\\(#CLIP(.*?)\\)", "url(#" + clipPrefix + "$1)");
//        // add #12245 【因島】帳票に出力されない画像がある  吉 end
        // del #12445 【因島】帳票に出力されない画像がある 差戻1 sunsy end
      }
    }
    //add 紹介状の帳票データがordNoで抽出されてしまう  吉 end
    else {
      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
      Map<String,List> searchList =this.searchMap(reportMenu.getFacilityCd());
      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
      for (int i = 0; i < patOrdNo.size(); i++) {
        Map<String, Object> dataKey = new HashMap<>();
        // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
        dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
        dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
        dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
        // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
        dataKey.put(ReportConstant.ReportDataKey.ORD_NO, patOrdNo.get(i).getOrdNo());
        dataKey.put(ReportConstant.ReportDataKey.PAT_ID, patOrdNo.get(i).getPatId());
        dataKey.put("login", userName);
        // add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 start
        //mod 帳票用のパラメーター設定処理  吉 start
//        dataKey = createDataKey(reportMenu,dataKey,patOrdNo.get(i).getPatId());
        if(null == reportMenu.getFromDate() ||null ==  reportMenu.getToDate()){
          reportMenu.setFromDate(reportMenu.getSpecifyDate());
          reportMenu.setToDate(reportMenu.getSpecifyDate());
        }
        dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, dateStr2dispDateStr(reportMenu.getFromDate()));
        dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
        dataKey.put(ReportConstant.ReportDataKey.DATE_TO, dateStr2dispDateStr(reportMenu.getToDate()));
        dataKey.put(ReportConstant.ReportDataKey.DATE, null != reportMenu.getSpecifyDate() ?dateStr2dispDateStr(reportMenu.getSpecifyDate()) : null);
        //mod 帳票用のパラメーター設定処理  吉 end
        // add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 end
        //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
        dataKey.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
        // mod #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 start
        //dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getTreatDate());
        dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate());
        // mod #7949 「帳票種別：ラベル　sqlcode=16とsqlcode=17の項目を1つの帳票に設定すると、保存できない」 商 end
        dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
        dataKey.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
        dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
        // add #7672 【デグレ】透析装置に表示される治療記録画像が縦長になる 王永吉 start
        dataKey.put("fromGlag",reportMenu.isReportFromFlag());
        // add #7672 【デグレ】透析装置に表示される治療記録画像が縦長になる 王永吉 end
        // add 項目別(印刷情報一覧)の項目が実装されない  吉 end
        //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 start
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        //if(reportCd == -3 || reportCd == -2)
        if(reportCd == CoreConstant.FixedReportCd.DIALYSIS_REPORT
          || reportCd == CoreConstant.FixedReportCd.DIALYSIS_REPORT_HANDWRITTEN
        )
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
        {
          reportCd = getTemplateReportCd(reportMenu.getFacilityCd(),patOrdNo.get(i).getOrdNo(),reportCd);
        }
        //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 end

        //add IES因島）sql性能試験 後で削除 liuc start
        dataKey.put("sqlTestSign", reportMenu.getSqlTestTimeStr());
        //add IES因島）sql性能試験 後で削除 liuc end

        htmlResult += reportService.getReportHtml(reportCd, dataKey, null, userId);
        // del #12445 【因島】帳票に出力されない画像がある 差戻1 sunsy start
//        // add #12245 【因島】帳票に出力されない画像がある  吉 start
//        String uuid = UUID.randomUUID().toString();
//        String clipPrefix = "CLIP-" + uuid + "-" + i + "-";
//        htmlResult = htmlResult.replaceAll("id=\"CLIP(.*?)\"", "id=\"" + clipPrefix + "$1\"");
//        htmlResult = htmlResult.replaceAll("url\\(#CLIP(.*?)\\)", "url(#" + clipPrefix + "$1)");
//        // add #12245 【因島】帳票に出力されない画像がある  吉 end
        // del #12445 【因島】帳票に出力されない画像がある 差戻1 sunsy end
      }
    }
//    /*mod FNSI-改修内容紹介状印刷で次の患者の場合、改ページで表示していない 任 start*/
//    if(htmlResult!=null){
//      String htmlString[] = htmlResult.split("<tbody>");
//      if(htmlString.length>2){
//        htmlResult = htmlString[0] + "<tbody>";
//        for(int i = 1 ;i < htmlString.length;i++){
//          if(i<htmlString.length-1){
//            htmlResult += htmlString[i] + "<div style=\"page-break-after: always;\"></div><tbody>";
//          }else{
//            htmlResult += htmlString[i];
//          }
//        }
//      }
//    }
//    /*mod FNSI-改修内容紹介状印刷で次の患者の場合、改ページで表示していない 任 start*/
      //add 6470 治療経過表：縦型配置が反映されない 吉 start
    if(htmlResult!=null){
      if(htmlResult.contains("layout-flow:vertical-ideographic;")){
        htmlResult=htmlResult.replaceAll("layout-flow:vertical-ideographic;","writing-mode: vertical-rl;");
      }
    }
    //add 6470 治療経過表：縦型配置が反映されない 吉 end
    //add IES因島）sql性能試験 後で削除 liuc start
    Date endTime = new Date();
    String sqlTestSign = reportMenu.getSqlTestTimeStr();
    EventLogMessage LogMessage = new EventLogMessage();
    LogMessage.setLogMessage(sqlTestSign + "ReportMenuServiceImpl::getExcelReportSorted 実行時間:" + (endTime.getTime() - beginTime.getTime()) + "ms");
    testLogService.log(LogLevel.WARN, LogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
    //add IES因島）sql性能試験 後で削除 liuc end
    return htmlResult;
  }
  // add #6377 「テンプレート繰り返しが正しく動いていない」 鄧シン start
  /**
   * 帳票デザインExcelを取得します.
   *
   * @param mstReport 帳票マスタEntity
   * @param reportZipFile 帳票Zipファイル
   * @return 帳票デザインExcel(POI Workbook)
   */
  private Workbook getReportWorkbook(MstReport mstReport, ReportZipFile reportZipFile) {
    // エクセルファイルを取得
    byte[] excelData = reportZipFile.getFile(mstReport.getReportPath().getXlsxFilename());
    if (java.util.Objects.isNull(excelData)) {
      throw new NotExistException("帳票デザインExcelファイルを取得できません。");
    }
    try (InputStream is = new ByteArrayInputStream(excelData)) {
      return WorkbookFactory.create(is);
    } catch (IOException e) {
      throw new NtssException("帳票デザインExcelファイルを取得できません。");
    }
  }

  /**
   * 帳票Zipファイルを取得します.
   *
   * @param mstReport 帳票マスタEntity
   * @return 帳票Zipファイル
   */
  private ReportZipFile getReportZip(MstReport mstReport) {
    return new ReportZipFile(
      reportS3Service.getReportFile(
        mstReport.getReportPath().getBucket(),
        mstReport.getReportPath().getReportZip(),
        mstReport.getUpDate()));
  }
  public MstReport getMstReport(Long reportCd) {
    try {
      return mstReportDao.selectByCd(reportCd);
    } catch (EmptyResultDataAccessException e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage("There is no MstReport.");
      logService.log(LogLevel.DEBUG, eventLogMessage, null, SERVICE_NAME.FNSI, null);
      throw new NotExistException("存在しない帳票マスタのレポートコードを指定されています。");
    }
  }
  // add #6377 「テンプレート繰り返しが正しく動いていない」 鄧シン end

  //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 start
  private Long getTemplateReportCd(String facilityCd, Long ordNo ,Long reportCd) {

    MstTreatment treatment;
    // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
    //if (reportCd == -2L)
    if(reportCd == CoreConstant.FixedReportCd.DIALYSIS_REPORT_HANDWRITTEN)
    // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
    {
      // 治療経過表(手書き) の場合、予定を含むため、予定を含めて判定を行う
      treatment = mstTreatmentDao.selectIndByOrdNo(ordNo);
    } else {
      treatment = mstTreatmentDao.selectByOrdNo(ordNo);
    }
    if (treatment == null) {
      String error ="治療情報に紐づく治療方法の取得に失敗しました。";
      outputErrorLog(facilityCd, error);
      throw new NtssException(error);
    }
    // mod #8870 帳票画面にてデータ無しのエラーメッセージが規範的ではない 王 start
//    if (treatment.getReportId() == null || treatment.getReportId() == 0) {
//      // 施設設定マスタ No3004 帳票未指定時のデフォルト帳票の設定を確認
//      FacilitySettingInfo info = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, "3004");
//      Long rtnValue = 0L;
//      if (null != info) {
//        String value = info.getValue();
//        if (NumberUtils.isCreatable(value)) {
//          rtnValue = Long.parseLong(value);
//        }
//      }
//      if (rtnValue.equals(0L)) {
//        String error ="治療方法マスタの治療経過表IDが設定されていません、また施設設定マスタNo117 帳票未指定時のデフォルト帳票の設定もされておりません。";
//        outputErrorLog(facilityCd, error);
//        throw new NtssException(error);
//      }
//      return rtnValue;
//    }
    boolean flag = false;
    if (
      // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
      //reportCd == -3L
      reportCd == CoreConstant.FixedReportCd.DIALYSIS_REPORT
      // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
        && (treatment.getReportId() == null || treatment.getReportId() == 0)) {
      flag = true;
    }
    if (
      // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
      //reportCd == -2L
      reportCd == CoreConstant.FixedReportCd.DIALYSIS_REPORT_HANDWRITTEN
      // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
        && (treatment.getReportIdHw() == null || treatment.getReportIdHw() == 0)) {
      flag = true;
    }
    if (flag) {
      // 施設設定マスタ No3004 帳票未指定時のデフォルト帳票の設定を確認
      FacilitySettingInfo info = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, "3004");
      Long rtnValue = 0L;
      if (null != info) {
        String value = info.getValue();
        if (NumberUtils.isCreatable(value)) {
          rtnValue = Long.parseLong(value);
        }
      }
      if (rtnValue.equals(0L)) {
        String error ="治療方法マスタの治療経過表IDが設定されていません、また施設設定マスタNo117 帳票未指定時のデフォルト帳票の設定もされておりません。";
        outputErrorLog(facilityCd, error);
        throw new NtssException(error);
      }
      return rtnValue;
    }
    // mod #8870 帳票画面にてデータ無しのエラーメッセージが規範的ではない 王 end
    // Longへ変換
    // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
    // if(reportCd == -3L)
    if(reportCd == CoreConstant.FixedReportCd.DIALYSIS_REPORT)
    // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
    {
      return Long.valueOf(treatment.getReportId());
    }else{
      return Long.valueOf(treatment.getReportIdHw());
    }

  }

  private void outputErrorLog(String facilityCd, String message) {
    outputLog(LogLevel.ERROR, facilityCd, message);
  }
  private void outputLog(LogLevel level, String facilityCd, String message) {
    EventLogMessage elm = new EventLogMessage();
    elm.setFacilityCd(facilityCd);
    elm.setLogMessage(message);
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 start
    elm.setInvokeClass(this.getClass().getName());
    // add 2020-12-08 No.718：各APIのログ出力→共通ログ 孫 end
    logService.log(level, elm, null, SERVICE_NAME.FNSI, null);
  }
  //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 end

  // add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 start
  private Map<String, Object> createDataKey(ReportMenuSortContainer reportMenu, Map<String, Object> dataKey, Long patId) {
    if (!reportMenu.getIsDialysisDate()) {
      // 検査日基準
      List<ReportParam> params = new ArrayList<>();
      List<String> regOrderClassList = reportMenu.getRegOrderClassList();
      List<PatExamMain> examMainList = new ArrayList<>();
      LocalDate nowDate = LocalDate.now();
      String nowYYYYMMDD = nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));
      if (reportMenu.getRegOrderClassList().size() > 0) {
        // 検査区分が指定されていなかったら検査対象を取得できないので、検索処理を行わない

        List<OrdMain> ordList = reportMenuDao.selectByTreatDate(patId, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
        // 日付がどのように選択されているか確認して、検査結果リストを取得する
        String fromDate = reportMenu.getFromDate();
        String toDate = reportMenu.getToDate();
        if (reportMenu.getSpecifyDate() == null) {
          // 期間指定
          LocalDateTime localDateFrom = LocalDate.parse(reportMenu.getFromDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
          LocalDateTime localDateTo = LocalDate.parse(reportMenu.getToDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
          localDateTo = localDateTo.plusDays(1L).minusNanos(1000);
          examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateFrom), Timestamp.valueOf(localDateTo), regOrderClassList);
        } else {
          // 1日指定
          fromDate = reportMenu.getSpecifyDate();
          toDate = reportMenu.getSpecifyDate();
          LocalDateTime localDateTarget = LocalDate.parse(reportMenu.getSpecifyDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
          LocalDateTime localDateTo = localDateTarget.plusDays(1L).minusNanos(1000);
          examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateTarget), Timestamp.valueOf(localDateTo), regOrderClassList);
        }

        for (PatExamMain exam : examMainList) {
          if (Objects.equal(exam.getExamStatus(), "1")) {
            // 検査実績

            // 検査と同日の透析実績リストを取得する
            String uuuuMMdd = exam.getResultExamDate().toLocalDateTime().toLocalDate().format(DateTimeFormatter.ofPattern("uuuuMMdd"));
            List<OrdMain> ords = ordList.stream().filter(
              o -> Objects.equal(o.getTreatDate(), uuuuMMdd)).collect(Collectors.toList());

            if (ords.size() > 0) {
              // 検査日と同じ日に透析実績がある
              for (OrdMain ord : ords) {
                ReportParam reportParam = new ReportParam();
                reportParam.ordNo = ord.getOrdNo();
                reportParam.date = dateStr2dispDateStr(uuuuMMdd);
                reportParam.dateFrom = dateStr2dispDateStr(fromDate);
                reportParam.dateTo = dateStr2dispDateStr(toDate);
                params.add(reportParam);
              }
            } else {
              // 実績なし
              // 検査日と同じ日に透析実績はない
              ReportParam reportParam = new ReportParam();
              reportParam.ordNo = null;
              reportParam.date = dateStr2dispDateStr(uuuuMMdd);
              ;
              reportParam.dateFrom = dateStr2dispDateStr(fromDate);
              reportParam.dateTo = dateStr2dispDateStr(toDate);
              params.add(reportParam);
            }
          } else {
            // 検査予定
            LocalDate regExamDate = exam.getRegExamDate().toLocalDateTime().toLocalDate();
            if (nowDate.isAfter(regExamDate)) {
              // 今日が予定日よりも後にあるものはは実績のない過去の検査予定
              continue;
            } else {
              // 本日以降の検査予定
              // 検査予定
              String uuuuMMdd = regExamDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));
              List<OrdMain> ords = ordList.stream().filter(
                o -> Objects.equal(o.getTreatDate(), uuuuMMdd)).collect(Collectors.toList());

              if (ords.size() > 0) {
                for (OrdMain ord : ords) {
                  ReportParam reportParam = new ReportParam();
                  reportParam.ordNo = ord.getOrdNo();
                  reportParam.date = dateStr2dispDateStr(uuuuMMdd);
                  ;
                  reportParam.dateFrom = dateStr2dispDateStr(fromDate);
                  reportParam.dateTo = dateStr2dispDateStr(toDate);
                  params.add(reportParam);
                }
              } else {
                // 実績なし
                ReportParam reportParam = new ReportParam();
                reportParam.ordNo = null;
                reportParam.date = dateStr2dispDateStr(uuuuMMdd);
                ;
                reportParam.dateFrom = dateStr2dispDateStr(fromDate);
                reportParam.dateTo = dateStr2dispDateStr(toDate);
                params.add(reportParam);
              }
            }
          }
        }
      }
      // テンプレート外用オーダー番号
      Long outTemplateOrdNo = null;

      // この患者の直近1件の治療予定を取得
      OrdMain near = reportMenuDao.selectNearOrdPlan(patId, nowYYYYMMDD);
      if (near != null) {
        outTemplateOrdNo = near.getOrdNo();
      } else {
        List<ReportParam> tmpParams = params.stream().filter(o -> o.ordNo != null).collect(Collectors.toList());
        if (tmpParams.size() > 0) {
          outTemplateOrdNo = tmpParams.get(tmpParams.size() - 1).ordNo;
        }
      }
      dataKey.put(ReportConstant.ReportDataKey.ORD_NO, outTemplateOrdNo);
      // テンプレート内パラメータ
      List<Map<String, Object>> tmplParams = new ArrayList<Map<String, Object>>();
      for (ReportParam param : params) {
        Map<String, Object> tmplParam = new HashMap<>();
        tmplParam.put(ReportConstant.ReportDataKey.ORD_NO, param.ordNo);
        tmplParam.put(ReportConstant.ReportDataKey.PAT_ID, patId);
        tmplParam.put(ReportConstant.ReportDataKey.DATE, param.date);
        tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, param.dateFrom);
        tmplParam.put(ReportConstant.ReportDataKey.DATE_TO, param.dateTo);
        tmplParams.add(tmplParam);
      }
      dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, tmplParams);
    }
    return dataKey;
  }
  // add 2020-11-10 初回(IES)528 フィルタ動作対応 夏 end

  /**
   * 配布リスト用のデータキーを作成する.
   *
   * 配布リスト用のデータキーは下記の通りである.
   *  date : 画面で入力された日付(配布リストの場合、期間指定の入力は想定しない.)
   *  ordNos : オーダ番号のリスト
   *  medIds : 薬剤分類のリスト
   *  diaIds : ダイアライザコードのリスト
   *  eqIds :  医療材料分類のリスト
   *  tmplParams : 1テンプレート内に出力する情報を収集する為のデータキー
   *    {
   *      ordNos : オーダ番号 ※1つ目のテンプレートに出力する為のデータキー
   *      medIds : 薬剤分類のリスト
   *      diaIds : ダイアライザコードのリスト
   *      eqIds :  医療材料分類のリスト
   *    } , {
   *      ordNos : オーダ番号　※2つ目のテンプレートに出力する為のデータキー
   *      medIds : 薬剤分類のリスト
   *      diaIds : ダイアライザコードのリスト
   *      eqIds :  医療材料分類のリスト
   *    }
   *
   * @param condition 帳票メニューで指定された条件
   * @return 配布リスト用のデータキー
   */
  /*mod FNSI-改修内容 各帳票の並び順調整。 吉 start*/
  /*private Map<String, Object> createDistributionListDataKey(ReportMenuSortContainer condition) {*/
  private Map<String, Object> createDistributionListDataKey(ReportMenuSortContainer condition,List<Long> patIds) {
    /*mod FNSI-改修内容 各帳票の並び順調整。 吉 end*/
    Map<String, Object> dataKey = new HashMap<>();
    // 画面で選択された患者リスト
    /*del FNSI-改修内容 各帳票の並び順調整。 吉 start*/
//    List<Long> patIds = condition.getPatIds();
    /*del FNSI-改修内容 各帳票の並び順調整。 吉 end*/
    // テンプレート外のデータキー
    dataKey.put(ReportConstant.ReportDataKey.DATE, condition.getSpecifyDate());

    // 薬剤分類の設定
    List<Integer> medicineCdList =
      condition.getMedicineCdList() == null || condition.getMedicineCdList().isEmpty()
        ? Collections.singletonList(0)
        :  condition.getMedicineCdList();
    dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS, medicineCdList);

    // ダイアライザの設定
    List<Integer> dialyzerCdList =
        condition.isDialyzer()
          ? getDialyzerCdList(condition.getFacilityCd())
          : Collections.singletonList(0);
    dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS, dialyzerCdList);

    // 医療材料区分の設定
    List<Integer> equipmentCdList =
      condition.getEquipmentCdList() == null || condition.getEquipmentCdList().isEmpty()
        ? Collections.singletonList(0)
        : condition.getEquipmentCdList();
    dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, equipmentCdList);

    // 1テンプレートに出力するデータキーを登録するリスト
    List<Map<String, Object>> dataKeyInTemplateList = new ArrayList<>();
    // オーダ番号を格納するリスト
    List<Long> ordNoList = new ArrayList<>();
    patIds.stream().forEach(patId -> {
      // 患者IDと日付のord_mainを取得
      List<OrdMain> ordMainList =
        reportMenuDao.selectByTreatDate(patId, condition.getSpecifyDate(), null, null);
      //add 項目別(印刷情報一覧)の項目が実装されない  吉 start
      List<Long> newOrdNoList = new ArrayList<>();
      if(null != ordMainList && ordMainList.size()>1){
        ordMainList.stream().forEach(ordMain -> {
          newOrdNoList.add(ordMain.getOrdNo());
        });
      }
      //add 項目別(印刷情報一覧)の項目が実装されない  吉 end
      // 1テンプレートを取得するデータキー
      ordMainList.stream().forEach(ordMain -> {
        Map<String, Object> dataKeyInTemplate = new HashMap<>();
        // オーダ番号
        //mod 項目別(印刷情報一覧)の項目が実装されない  吉 start
//        dataKeyInTemplate.put(ReportConstant.ReportDataKey.ORD_NOS, Arrays.asList(ordMain.getOrdNo()));
        if(condition.getReportClass().equals(ReportConstant.ReportClass.DISTRIBUTION_LIST_BED_REPORT) && newOrdNoList.size()>0){
          dataKeyInTemplate.put(ReportConstant.ReportDataKey.ORD_NOS, newOrdNoList);
        }else{
          dataKeyInTemplate.put(ReportConstant.ReportDataKey.ORD_NOS, Arrays.asList(ordMain.getOrdNo()));
        }
        //mod 項目別(印刷情報一覧)の項目が実装されない  吉 end

        // テンプレート外用のオーダ番号リストに追加
        ordNoList.add(ordMain.getOrdNo());
        // 薬剤分類
        dataKeyInTemplate.put(ReportConstant.ReportDataKey.MEDICINE_IDS, medicineCdList);
        // ダイアライザ
        dataKeyInTemplate.put(ReportConstant.ReportDataKey.DIALYZER_IDS, dialyzerCdList);
        // 医療材料分類
        dataKeyInTemplate.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, equipmentCdList);
        // テンプレート内のデータキーをリストに追加
        dataKeyInTemplateList.add(dataKeyInTemplate);
      });
    });
    // テンプレート外のデータキーにオーダ番号リストを追加
    dataKey.put(ReportConstant.ReportDataKey.ORD_NOS, ordNoList);
    // テンプレート用のデータキーを追加
    dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, dataKeyInTemplateList);
    return dataKey;
  }

  /**
   * 施設に該当するダイアライザコードのリストを取得する.
   *
   * @see MstInfoService#findMstDialyzerAllByFacillityCd(String)
   * @param facilityCd 施設コード
   * @return 施設コードに該当するダイアライザコードのリスト
   */
  private List<Integer> getDialyzerCdList(String facilityCd) {
    try {
      List<MstDialyzer> mstDialyzerList = mstInfoService.findMstDialyzerAllByFacillityCd(facilityCd);
      List<Integer> dialyzerCdList = mstDialyzerList.stream()
          .map(mstDialyzer -> {
            return mstDialyzer.getDialyzerCd();
          })
          .collect(Collectors.toList());
      return dialyzerCdList;
    } catch (Exception ex) {
	  EventLogMessage eventLogMessage = new EventLogMessage();
	  eventLogMessage.setLogMessage("帳票：ダイアライザマスタの検索に失敗しました。" + ex.getCause());
	  eventLogMessage.setSqlIdentification("(facility_cd = " + facilityCd + ")");
	  logService.log(LogLevel.ERROR, eventLogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI,
	            "MstInfoService/findMstDialyzerAllByFacillityCd");
      return Collections.EMPTY_LIST;
    }
  }

  /**
   * yyyyMMdd -> yyyy/MM/dd
   * @param yyyymmdd
   * @return
   */
  private String dateStr2dispDateStr(String yyyymmdd) {
    String year = yyyymmdd.substring(0,4);
    String month = yyyymmdd.substring(4,6);
    String day = yyyymmdd.substring(6);
    String treatDateFormatted = year + "/" + month + "/" + day;
    return treatDateFormatted;
  }


  // add Aspose.cells関連問題8の対応 夏 start
	private Map<String, Object> setMultiTotalDataKey(ReportMenuSortContainer reportMenu, Long userId, String userName) throws ParseException {
    // 複数集計
    Integer reportClass = reportMenu.getReportClass();
    List<Long> patIds = reportMenu.getPatIds();
    LocalDate nowDate = LocalDate.now();
    String nowYYYYMMDD = nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));

    List<ReportParam> params = new ArrayList<>();

    Long patId;

    // mod Aspose.cells関連問題8の二回目対応 夏 start
//    if (ReportConstant.ReportClass.MULTI_TOTAL_REPORT.equals(reportClass) && !"".equals(reportMenu.getReportType())) {
    if (ReportConstant.ReportClass.MULTI_TOTAL_REPORT.equals(reportClass)) {
      // mod Aspose.cells関連問題8の二回目対応 夏 end
      if (null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate()) {
        // mod Aspose.cells関連問題8の二回目対応 夏 start
//        if (!"1".equals(reportMenu.getReportType())) {
// del #10547 複数集計で出力される値・内容が正しくない limingzhe start
//        if (!StringUtils.isEmpty(reportMenu.getReportType()) && !"1".equals(reportMenu.getReportType())) {
//          // mod Aspose.cells関連問題8の二回目対応 夏 end
//          String day = reportMenu.getSpecifyDate().substring(6, 8);
//          String date = reportMenu.getSpecifyDate();
//          Calendar calendar = Calendar.getInstance();
//          calendar.setFirstDayOfWeek(Calendar.MONDAY);
//          calendar.set(Calendar.DAY_OF_MONTH, Integer.valueOf(day));
//          String treatDateFormatted = date.substring(0, 4) + "-" + date.substring(4, 6) + "-" + date.substring(6);
//          String[] result = getStartAndEndDayByDate(treatDateFormatted);
//          reportMenu.setFromDate(result[0].replace("-", ""));
//          reportMenu.setToDate(result[1].replace("-", ""));
//        }else{
// del #10547 複数集計で出力される値・内容が正しくない limingzhe end
          reportMenu.setFromDate(reportMenu.getSpecifyDate());
          reportMenu.setToDate(reportMenu.getSpecifyDate());
// del #10547 複数集計で出力される値・内容が正しくない limingzhe start
//        }
// del #10547 複数集計で出力される値・内容が正しくない limingzhe end
      }
    }

    if(ReportConstant.ReportClass.MULTI_TOTAL_REPORT.equals(reportClass) && !"3".equals(reportMenu.getReportType())) {
      if (reportMenu.getIsDialysisDate()) {
        // 透析日基準

        // 患者IDリストで渡された患者の期間内での最新の確定透析実績を取得する
        // 透析実績が取得できない場合は、期間内で今日以降の直近予定を取得する
        // 透析実績、透析予定ともに存在しない場合は、期間終了日の患者情報のみを取得する

        for (int index = 0; index < patIds.size(); index++) {
          patId = patIds.get(index);
          ReportParam reportParam = new ReportParam();
          String dateString;

          List<OrdMain> ordList;

          if (reportClass == ReportConstant.ReportClass.ONE_TOTAL_REPORT) {
            // 最新の確定実績を取得する
            ordList = reportMenuDao.selectResultByTreatDate(patId, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
          } else {
            ordList = reportMenuDao.selectByTreatDate(patId, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
          }
          if (ordList.size() > 0) {
            // 最新の確定実績 治療日降順でソートしているので、1レコード目が最新
            for (int i = 0; i < ordList.size(); i++) {
              reportParam = new ReportParam();
              OrdMain ordMain = ordList.get(i);
              reportParam.ordNo = ordMain.getOrdNo();
              final String treatDate = dateStr2dispDateStr(ordMain.getTreatDate());
              dateString = treatDate;
              dateString = dateString.replace("/", "");
              reportParam.patId = patId;
              reportParam.date = dateString;
              if (reportMenu.getFromDate() == null) {
                reportParam.dateFrom = dateString;
              } else {
                reportParam.dateFrom = reportMenu.getFromDate();
              }
              if (reportMenu.getToDate() == null) {
                reportParam.dateTo = dateString;
              } else {
                reportParam.dateTo = reportMenu.getToDate();
              }
              params.add(reportParam);
            }
          } else {
            // 治療予定を取得する. ここに到達するということは、指定期間内に確定実績はない

            // この患者の直近1件の治療予定を取得
            OrdMain near = reportMenuDao.selectNearOrdPlan(patId, nowYYYYMMDD);
            if (near != null) {

              // ord_mainから取得

              // 治療予定
              reportParam.ordNo = near.getOrdNo();
              final String treatDate = dateStr2dispDateStr(near.getTreatDate());
              dateString = treatDate;

            } else {

              // 透析実績、透析予定ともに存在しない場合は、期間終了日の患者情報のみを取得する

              final String toDate;
              if (reportMenu.getSpecifyDate() == null) {
                // 範囲指定
                // 期間終了日
                toDate = reportMenu.getToDate();

              } else {
                // 1日指定
                // 特定日付
                toDate = reportMenu.getSpecifyDate();

              }
              dateString = toDate;

            }
            reportParam.patId = patId;
            dateString = dateString.replace("/", "");
            reportParam.date = dateString;
            if (reportMenu.getFromDate() == null) {
              reportParam.dateFrom = dateString;
            } else {
              reportParam.dateFrom = reportMenu.getFromDate();
            }
            if (reportMenu.getToDate() == null) {
              reportParam.dateTo = dateString;
            } else {
              reportParam.dateTo = reportMenu.getToDate();
            }
            params.add(reportParam);
          }
        }

      } else if (reportMenu.getRegOrderClassList().size() > 0) {
        // 検査日基準
        // 検査区分(チェックボックス)が指定されていなかったら検査対象を取得できないので、検索処理を行わない

        // 患者IDリストで渡された患者の期間内での最新の検査結果の検査日を取得する。
        // 検査結果が存在しない場合は、期間内の今日以降の直近検査予定の検査日を取得する。
        // 検査結果または検査結果を取得する際のフィルタとして、帳票画面の検査区分、およびExcelパラメータの各検査コード、検査区分を使用する。
        // 検査結果、検査予定共に無い場合は、患者情報のみ。

        for (int index = 0; index < patIds.size(); index++) {

          patId = patIds.get(index);

          ReportParam reportParam = new ReportParam();
          reportParam.patId = patId;

          // 検査結果
          List<PatExamMain> examMainList = new ArrayList<>();

          // 検索区分
          List<String> regOrderClassList = reportMenu.getRegOrderClassList();

          // 日付がどのように選択されているか確認して、検査結果リストを取得する
          String fromDate;
          String toDate;
          if (reportMenu.getSpecifyDate() == null) {
            // 期間指定
            fromDate = reportMenu.getFromDate();
            toDate = reportMenu.getToDate();
            LocalDateTime localDateFrom = LocalDate.parse(reportMenu.getFromDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
            LocalDateTime localDateTo = LocalDate.parse(reportMenu.getToDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
            localDateTo = localDateTo.plusDays(1L).minusNanos(1000);
            examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateFrom), Timestamp.valueOf(localDateTo), regOrderClassList);
          } else {
            // 1日指定
            fromDate = reportMenu.getSpecifyDate();
            toDate = reportMenu.getSpecifyDate();
            LocalDateTime localDateTarget = LocalDate.parse(reportMenu.getSpecifyDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
            LocalDateTime localDateTo = localDateTarget.plusDays(1L).minusNanos(1000);
            examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateTarget), Timestamp.valueOf(localDateTo), regOrderClassList);
          }

          boolean isNotExistExamResult = true;
          for (PatExamMain exam : examMainList) {
            // 検査日リスト
            // 期間内での最新の検査結果の検査日を取得する

            if (Objects.equal(exam.getExamStatus(), "1")) {
              // 検査結果
              // 検査日時が最新であるか判定する処理を実装する
              isNotExistExamResult = false;
              String uuuuMMdd = exam.getResultExamDate().toLocalDateTime().toLocalDate().format(DateTimeFormatter.ofPattern("uuuuMMdd"));
              reportParam.date = dateStr2dispDateStr(uuuuMMdd);
              // del 7845 帳票（複数集計）：情報が出力されない && 6691 複数集計：対象項目の不足 liuc start
//              reportParam.dateFrom = dateStr2dispDateStr(fromDate);
//              reportParam.dateTo = dateStr2dispDateStr(toDate);
              // del 7845 帳票（複数集計）：情報が出力されない && 6691 複数集計：対象項目の不足 liuc end

            } else if (isNotExistExamResult) {
              // 検査予定
              String uuuuMMdd = exam.getRegExamDate().toLocalDateTime().toLocalDate().format(DateTimeFormatter.ofPattern("uuuuMMdd"));
              reportParam.date = dateStr2dispDateStr(uuuuMMdd);
              // del 7845 帳票（複数集計）：情報が出力されない && 6691 複数集計：対象項目の不足 liuc start
//              reportParam.dateFrom = dateStr2dispDateStr(fromDate);
//              reportParam.dateTo = dateStr2dispDateStr(toDate);
              // del 7845 帳票（複数集計）：情報が出力されない && 6691 複数集計：対象項目の不足 liuc end
            }

          }
          // mod 7845 帳票（複数集計）：情報が出力されない && 6691 複数集計：対象項目の不足 liuc start
          // 共通付値を抽出します。dateにデフォルト値を設定します。そうしないと、date空ポインタ異常が発生します。
          reportParam.dateFrom = dateStr2dispDateStr(fromDate);
          reportParam.dateTo = dateStr2dispDateStr(toDate);
          if(null == reportParam.date) {
            reportParam.date = dateStr2dispDateStr(fromDate);
          }
          // mod 7845 帳票（複数集計）：情報が出力されない && 6691 複数集計：対象項目の不足 liuc end

          // 透析実績と紐づける
          List<OrdMain> ordList = reportMenuDao.selectByTreatDate(patId, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
          List<OrdMain> ords = ordList.stream().filter
            (o -> Objects.equal(o.getTreatDate(), reportParam.date == null ? null : reportParam.date.replace("/", ""))).collect(Collectors.toList());
          if (ords.size() > 0) {
            // 検査日と同じ日に透析実績がある場合、透析番号を紐づける
            reportParam.ordNo = ords.get(ords.size() - 1).getOrdNo();
          }

          params.add(reportParam);

        }

      }
    }else{
      ReportParam reportParam = new ReportParam();
      if(null != reportMenu.getSpecifyDate()) {
        reportParam.date = reportMenu.getSpecifyDate();
      }else{
        reportParam.date = dateStr2dispDateStr(nowYYYYMMDD);
      }
      reportParam.dateFrom = reportMenu.getFromDate();
      reportParam.dateTo = reportMenu.getToDate();
      params.add(reportParam);
    }

    // テンプレート外領域のパラメータを生成する処理を実装する
    // 以下の構造のMapを生成する
    // キー: ordNo テンプレート外 オーダー番号
    // キー: patId テンプレート外 患者ID
    // キー: tmplParams テンプレート内パラメーター ordNo + patIdのList<Map<String, Object>>
    Map<String, Object> dataKey = new HashMap<>();
    if (reportMenu.getMedicineCdList() != null && reportMenu.getMedicineCdList().size() > 0) {
      dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS, reportMenu.getMedicineCdList());
    } else {
      dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS, Collections.singletonList(0));
    }
    List<Integer> listDia = new ArrayList<>();
    if (reportMenu.isDialyzer()) {
      for (MstDialyzer item : mstInfoService.findMstDialyzerAllByFacillityCd(reportMenu.getFacilityCd())) {
        listDia.add(item.getDialyzerCd());
      }
      dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS, listDia);
      reportMenu.getEquipmentCdList().add(0);
    } else {
      dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS, Collections.singletonList(0));
    }
    List<Integer> equipmentCdList = new ArrayList<>();
    if (reportMenu.getEquipmentCdList() != null && reportMenu.getEquipmentCdList().size() > 0) {
      equipmentCdList = reportMenu.getEquipmentCdList();
      dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, equipmentCdList);
    } else {
      dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, Collections.singletonList(0));
    }
    // テンプレート外パラメータとして本日日付
    dataKey.put(ReportConstant.ReportDataKey.DATE, nowYYYYMMDD);
    List<Long> listPat = new ArrayList<>();
    for (int i = 0; i < patIds.size(); i++) {
      listPat.add(patIds.get(i));
    }
    List<Long> listMachineNo = new ArrayList<>();
    for (int i = 0; i < reportMenu.getMachines().size(); i++) {
      listMachineNo.add(reportMenu.getMachines().get(i).getMachineNo());
    }
    // add Aspose.cells関連問題8の二回目対応 夏 start
    List<Long> listOrdNo = new ArrayList<>();
    for (int i = 0; i < params.size(); i++) {
      listOrdNo.add(params.get(i).ordNo);
    }
    // add Aspose.cells関連問題8の二回目対応 夏 end

    // add #6691 複数集計：対象項目の不足対応 夏 start
    dataKey.put(ReportConstant.ReportDataKey.ORD_NOS, listOrdNo);
    // add #6691 複数集計：対象項目の不足対応 夏 end

    // テンプレート内 領域のパラメータを生成する処理を実装する
    List<Map<String, Object>> tmplParams = new ArrayList<Map<String, Object>>();
    for (ReportParam param : params) {
      Map<String, Object> tmplParam = new HashMap<>();
      tmplParam.put(ReportConstant.ReportDataKey.DIALYZER_IDS,dataKey.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
      tmplParam.put(ReportConstant.ReportDataKey.MEDICINE_IDS,dataKey.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
      tmplParam.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,dataKey.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
      tmplParam.put(ReportConstant.ReportDataKey.ORD_NO, param.ordNo);
      tmplParam.put(ReportConstant.ReportDataKey.PAT_ID, param.patId);
      tmplParam.put(ReportConstant.ReportDataKey.PAT_IDS, listPat);
      if(null != reportMenu.getSpecifyDate()){
        // mod 7845 帳票（複数集計）：情報が出力されない && 6691 複数集計：対象項目の不足 liuc start
        //日付フォーマットカットのバグを修正します。
//        String treatDateFormatted = param.dateFrom.substring(0,4) + "-" +  param.dateFrom.substring(4,6) + "-" +  param.dateFrom.substring(6);
        String tempDateFrom = param.dateFrom;
        String treatDateFormatted;
        if(tempDateFrom.contains("/")) {
          treatDateFormatted = param.dateFrom.replace("/", "-");
        }else {
          treatDateFormatted = param.dateFrom.substring(0,4) + "-" +  param.dateFrom.substring(4,6) + "-" +  param.dateFrom.substring(6);
        }
        // mod 7845 帳票（複数集計）：情報が出力されない && 6691 複数集計：対象項目の不足 liuc end
        String[] result = getStartAndEndDayByDate(treatDateFormatted);
        if (null != reportMenu.getReportType() && !"1".equals(reportMenu.getReportType())){
          tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, result[0].replace("-",""));
          tmplParam.put(ReportConstant.ReportDataKey.DATE_TO, result[1].replace("-",""));
        }else{
          tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, treatDateFormatted.replace("-",""));
          tmplParam.put(ReportConstant.ReportDataKey.DATE_TO,treatDateFormatted.replace("-",""));
        }
      }else{
        tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, param.dateFrom);
        tmplParam.put(ReportConstant.ReportDataKey.DATE_TO, param.dateTo);
      }
      tmplParam.put(ReportConstant.ReportDataKey.DATE, param.date.replace("/",""));
      tmplParam.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
	  // mod #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
      //tmplParam.put(ReportConstant.ReportDataKey.MACHINE_NO, listMachineNo);
      tmplParam.put(ReportConstant.ReportDataKey.MACHINE_NOS, listMachineNo);
      // mod #9558 機能帳票で正しく変数が引き渡されていない limingzhe end
      // add Aspose.cells関連問題8の二回目対応 夏 start
      tmplParam.put(ReportConstant.ReportDataKey.ORD_NOS, listOrdNo);
      // add Aspose.cells関連問題8の二回目対応 夏 end
      tmplParams.add(tmplParam);
    }
    dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, tmplParams);
    dataKey.put("login", userName);
    dataKey.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
    dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate());
    dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
    dataKey.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
    dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
    // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//    String kind ="医療材料";
//    if(null != reportMenu.getEquipmentCdList() && reportMenu.getEquipmentCdList().size() == 0 && null !=  reportMenu.getMedicineCdList() && reportMenu.getMedicineCdList().size()>0){
//      kind="";
//    }
//    if(null !=  reportMenu.getMedicineCdList() && reportMenu.getMedicineCdList().size()>0){
//      if("" == kind){
//        kind="薬剤";
//      }else{
//        kind=kind+"·薬剤";
//      }
//    }
//    dataKey.put(ReportConstant.ReportDataKey.kind,kind);
//    SimpleDateFormat sdf =new SimpleDateFormat("yyyy年MM月dd日");
//    if(null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate()){
//      String day=reportMenu.getSpecifyDate().substring(6,8);
//      String date = reportMenu.getSpecifyDate();
//      Calendar calendar =Calendar.getInstance();
//      calendar.setFirstDayOfWeek(Calendar.MONDAY);
//      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
//      int week = calendar.get(Calendar.WEEK_OF_MONTH);
//      dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
//      String treatDateFormatted = date.substring(0,4) + "-" + date.substring(4,6) + "-" + date.substring(6);
//      String[] result = getStartAndEndDayByDate(treatDateFormatted);
//      String start = result[0].substring(0,4) + "年" + result[0].substring(5,7) + "月" + result[0].substring(8)+ "日";
//      String end = result[1].substring(5,7) + "月" + result[1].substring(8)+ "日";
//      dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
//
//    }else{
//      String day=reportMenu.getFromDate().substring(6,8);
//      String fromDate = reportMenu.getFromDate().substring(0,4) + "-" + reportMenu.getFromDate().substring(4,6) + "-" + reportMenu.getFromDate().substring(6);
//      Calendar calendar =Calendar.getInstance();
//      calendar.setFirstDayOfWeek(Calendar.MONDAY);
//      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
//      int week = calendar.get(Calendar.WEEK_OF_MONTH);
//      dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
//      String start = reportMenu.getFromDate().substring(0,4) + "年" + reportMenu.getFromDate().substring(4,6) + "月" + reportMenu.getFromDate().substring(6)+ "日";
//      String end =  reportMenu.getToDate().substring(4,6) + "月" + reportMenu.getToDate().substring(6)+ "日";
//      dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
//    }
    // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
    return dataKey;
  }
  // add Aspose.cells関連問題8の対応 夏 end

    // mod #11642 スケジュール表帳票がデータ抽出条件「指定日」で「一週間出力」になるのはNG limingzhe start
//  // add 10546 複数集計出力時にサーバが高負荷になる gjn start
//  private Map<String, Object> setMultiTotalDataKey(ReportMenuSortContainer reportMenu, String userName) throws ParseException {
//    // 複数集計
//    MstReport mstReport = getMstReport(reportMenu.getReportCd());
//    ReportZipFile reportZipFile = getReportZip(mstReport);
//    String reportXml = getReportXml(mstReport, reportZipFile);
//    List<ReportXmlParam> xmlparams = ReportUtils.getParamElements(reportXml);
//    boolean isHaveTotalFlag = false;
//    if(null != xmlparams && null != xmlparams.get(0) && null != xmlparams.get(0).getReportXmlTmplRepeat() && !"".equals(xmlparams.get(0).getReportXmlTmplRepeat().getId())){
//      isHaveTotalFlag = true;
//    }
//    List<Long> patIds = reportMenu.getPatIds();
//    LocalDate nowDate = LocalDate.now();
//    String nowYYYYMMDD = nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));
//    List<ReportParam> params = new ArrayList<>();
//    Long patId;
//    if (null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate() ) {
//      // mod 10375 患者イベント(テキストエリア)の出力が不正 吉 start
////reportMenu.setFromDate(reportMenu.getSpecifyDate());
////      reportMenu.setToDate(reportMenu.getSpecifyDate());
//      if(isHaveTotalFlag){
//        if(!reportMenu.getSpecifyDate().contains("-")){
//          SimpleDateFormat inputFormat = new SimpleDateFormat("yyyyMMdd");
//          SimpleDateFormat outputFormat = new SimpleDateFormat("yyyy-MM-dd");
//          try {
//            Date date = inputFormat.parse(reportMenu.getSpecifyDate());
//            String formattedDate = outputFormat.format(date);
//            String[] result = getStartAndEndDayByDate(formattedDate);
//            reportMenu.setFromDate(result[0].replace("-",""));
//            reportMenu.setToDate(result[1].replace("-",""));
//            // add 11010 スケジュール表出力時の処理が不足している gjn start
//            // 1日指定SpecifyDateがnullではなく、かつセットカウント内である場合、1日指定を所在週の期間指定に変換し、SpecifyDateをnullにする
//            reportMenu.setSpecifyDate(null);
//            // add 11010 スケジュール表出力時の処理が不足している gjn end
//          } catch (ParseException e) {
//            e.printStackTrace();
//          }
//        }else{
//          String[] result = getStartAndEndDayByDate(reportMenu.getSpecifyDate());
//          reportMenu.setFromDate(result[0].replace("-",""));
//          reportMenu.setToDate(result[1].replace("-",""));
//        }
//      }else{
//        reportMenu.setFromDate(reportMenu.getSpecifyDate());
//        reportMenu.setToDate(reportMenu.getSpecifyDate());
//      }
//      // mod 10375 10375 患者イベント(テキストエリア)の出力が不正 吉 end
//
//    }
//    Map<String, Object> dataKey = new HashMap<>();
//    // reportType [1:スケジュール表, 2:週間薬剤集計表, 3:水質調査一覧]
//    if(!"3".equals(reportMenu.getReportType())) {
//      if (reportMenu.getIsDialysisDate()) {
//        // 透析日基準
//        // 患者IDリストで渡された患者の期間内での最新の確定透析実績を取得する
//        // 透析実績が取得できない場合は、期間内で今日以降の直近予定を取得する
//        // 透析実績、透析予定ともに存在しない場合は、期間終了日の患者情報のみを取得する
//        // mod 10546 複数集計出力時にサーバが高負荷になる gjn sratr
//        //add 10998 「週間.医材」の出力内容修正 杜 start
//        if("曜日".equals(xmlparams.get(0).getReportXmlTotalTable().getUnitDate())){
//          reportMenu.setSpecifyDate(null);
//        }
//        //add 10998 「週間.医材」の出力内容修正 杜 end
//        String dateString;
//        // mod 10546 複数集計出力時にサーバが高負荷になる gjn start
//        List<OrdMain> ordList = reportMenuDao.selectByTreatDateAndPatIdsfacilityCd(patIds, reportMenu.getFacilityCd(),
//          reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
//        // mod 10546 複数集計出力時にサーバが高負荷になる gjn end
//        // 最新の確定実績 治療日降順でソートしているので、1レコード目が最新
//        for (int i = 0; i < ordList.size(); i++) {
//          ReportParam reportParam = new ReportParam();
//          OrdMain ordMain = ordList.get(i);
//          reportParam.ordNo = ordMain.getOrdNo();
//          final String treatDate = dateStr2dispDateStr(ordMain.getTreatDate());
//          dateString = treatDate;
//          dateString = dateString.replace("/", "");
//          reportParam.patId = ordMain.getPatId();
//          reportParam.date = dateString;
//          if (reportMenu.getFromDate() == null) {
//            reportParam.dateFrom = dateString;
//          } else {
//            reportParam.dateFrom = reportMenu.getFromDate();
//          }
//          if (reportMenu.getToDate() == null) {
//            reportParam.dateTo = dateString;
//          } else {
//            reportParam.dateTo = reportMenu.getToDate();
//          }
//          params.add(reportParam);
//          // mod 10546 複数集計出力時にサーバが高負荷になる gjn end
//        }
//      } else if (reportMenu.getRegOrderClassList().size() > 0) {
//        // 検査日基準
//        // 検査区分(チェックボックス)が指定されていなかったら検査対象を取得できないので、検索処理を行わない
//        // 患者IDリストで渡された患者の期間内での最新の検査結果の検査日を取得する。
//        // 検査結果が存在しない場合は、期間内の今日以降の直近検査予定の検査日を取得する。
//        // 検査結果または検査結果を取得する際のフィルタとして、帳票画面の検査区分、およびExcelパラメータの各検査コード、検査区分を使用する。
//        // 検査結果、検査予定共に無い場合は、患者情報のみ。
//        for (int index = 0; index < patIds.size(); index++) {
//          patId = patIds.get(index);
//          ReportParam reportParam = new ReportParam();
//          reportParam.patId = patId;
//          // 検査結果
//          List<PatExamMain> examMainList = new ArrayList<>();
//          // 検索区分
//          List<String> regOrderClassList = reportMenu.getRegOrderClassList();
//          // 日付がどのように選択されているか確認して、検査結果リストを取得する
//          String fromDate;
//          String toDate;
//          if (reportMenu.getSpecifyDate() == null) {
//            // 期間指定
//            fromDate = reportMenu.getFromDate();
//            toDate = reportMenu.getToDate();
//            LocalDateTime localDateFrom = LocalDate.parse(reportMenu.getFromDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
//            LocalDateTime localDateTo = LocalDate.parse(reportMenu.getToDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
//            localDateTo = localDateTo.plusDays(1L).minusNanos(1000);
//            examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateFrom), Timestamp.valueOf(localDateTo), regOrderClassList);
//          } else {
//            // 1日指定
//            fromDate = reportMenu.getSpecifyDate();
//            toDate = reportMenu.getSpecifyDate();
//            LocalDateTime localDateTarget = LocalDate.parse(reportMenu.getSpecifyDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
//            LocalDateTime localDateTo = localDateTarget.plusDays(1L).minusNanos(1000);
//            examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateTarget), Timestamp.valueOf(localDateTo), regOrderClassList);
//          }
//          boolean isNotExistExamResult = true;
//          for (PatExamMain exam : examMainList) {
//            // 検査日リスト
//            // 期間内での最新の検査結果の検査日を取得する
//            if (Objects.equal(exam.getExamStatus(), "1")) {
//              // 検査結果
//              // 検査日時が最新であるか判定する処理を実装する
//              isNotExistExamResult = false;
//              String uuuuMMdd = exam.getResultExamDate().toLocalDateTime().toLocalDate().format(DateTimeFormatter.ofPattern("uuuuMMdd"));
//              reportParam.date = dateStr2dispDateStr(uuuuMMdd);
//            } else if (isNotExistExamResult) {
//              // 検査予定
//              String uuuuMMdd = exam.getRegExamDate().toLocalDateTime().toLocalDate().format(DateTimeFormatter.ofPattern("uuuuMMdd"));
//              reportParam.date = dateStr2dispDateStr(uuuuMMdd);
//            }
//          }
//          // 共通付値を抽出します。dateにデフォルト値を設定します。そうしないと、date空ポインタ異常が発生します。
//          reportParam.dateFrom = dateStr2dispDateStr(fromDate);
//          reportParam.dateTo = dateStr2dispDateStr(toDate);
//          if(null == reportParam.date) {
//            reportParam.date = dateStr2dispDateStr(fromDate);
//          }
//          // 透析実績と紐づける
//          List<OrdMain> ordList = reportMenuDao.selectByTreatDate(patId, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
//          List<OrdMain> ords = ordList.stream().filter
//            (o -> Objects.equal(o.getTreatDate(), reportParam.date == null ? null : reportParam.date.replace("/", ""))).collect(Collectors.toList());
//          if (ords.size() > 0) {
//            // 検査日と同じ日に透析実績がある場合、透析番号を紐づける
//            reportParam.ordNo = ords.get(ords.size() - 1).getOrdNo();
//          }
//          params.add(reportParam);
//        }
//      }
//    } else {
//      ReportParam reportParam = new ReportParam();
//      if(null != reportMenu.getSpecifyDate()) {
//        reportParam.date = reportMenu.getSpecifyDate();
//      }else{
//        reportParam.date = dateStr2dispDateStr(nowYYYYMMDD);
//      }
//      reportParam.dateFrom = reportMenu.getFromDate();
//      reportParam.dateTo = reportMenu.getToDate();
//      params.add(reportParam);
//    }
//    // テンプレート外領域のパラメータを生成する処理を実装する
//    // 以下の構造のMapを生成する
//    // キー: ordNo テンプレート外 オーダー番号
//    // キー: patId テンプレート外 患者ID
//    // キー: tmplParams テンプレート内パラメーター ordNo + patIdのList<Map<String, Object>>
//
//    // 3:水質調査一覧 才会需要Dialyzer
//    if (reportMenu.isDialyzer()) {
//      dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS, mstDialyzerDao.selectDialyzerCdByFacillityCd(reportMenu.getFacilityCd()));
//      reportMenu.getEquipmentCdList().add(0);
//    } else {
//      dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS, Collections.singletonList(0));
//    }
//    if (reportMenu.getMedicineCdList() != null && reportMenu.getMedicineCdList().size() > 0) {
//      dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS, reportMenu.getMedicineCdList());
//    } else {
//      dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS, Collections.singletonList(0));
//    }
//    List<Integer> equipmentCdList = new ArrayList<>();
//    if (reportMenu.getEquipmentCdList() != null && reportMenu.getEquipmentCdList().size() > 0) {
//      equipmentCdList = reportMenu.getEquipmentCdList();
//      dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, equipmentCdList);
//    } else {
//      dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, Collections.singletonList(0));
//    }
//    // テンプレート外パラメータとして本日日付
//    dataKey.put(ReportConstant.ReportDataKey.DATE, nowYYYYMMDD);
//
//    List<Long> listMachineNo = new ArrayList<>();
//    for (int i = 0; i < reportMenu.getMachines().size(); i++) {
//      listMachineNo.add(reportMenu.getMachines().get(i).getMachineNo());
//    }
//    List<Long> listOrdNo = new ArrayList<>();
//    for (int i = 0; i < params.size(); i++) {
//      listOrdNo.add(params.get(i).ordNo);
//    }
//    dataKey.put(ReportConstant.ReportDataKey.ORD_NOS, listOrdNo);
//    // add 11010 スケジュール表出力時の処理が不足している gjn start
//    dataKey.put(ReportConstant.ReportDataKey.kurCdLists, reportMenu.getKurList());
//    dataKey.put(ReportConstant.ReportDataKey.bedCdLists, reportMenu.getBedCdList());
//    // add 11010 スケジュール表出力時の処理が不足している gjn end
//
//    // テンプレート内 領域のパラメータを生成する処理を実装する
//    List<Map<String, Object>> tmplParams = new ArrayList<Map<String, Object>>();
//    // mod 10546 複数集計出力時にサーバが高負荷になる gjn start
//    ReportParam param = params.get(0);
//    //for (ReportParam param : params) {
//      Map<String, Object> tmplParam = new HashMap<>();
//      tmplParam.put(ReportConstant.ReportDataKey.DIALYZER_IDS,dataKey.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
//      tmplParam.put(ReportConstant.ReportDataKey.MEDICINE_IDS,dataKey.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
//      tmplParam.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,dataKey.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
//      tmplParam.put(ReportConstant.ReportDataKey.ORD_NO, param.ordNo);
//      tmplParam.put(ReportConstant.ReportDataKey.PAT_ID, param.patId);
//      tmplParam.put(ReportConstant.ReportDataKey.PAT_IDS, patIds);
//      if(null != reportMenu.getSpecifyDate()){
//        //日付フォーマットカットのバグを修正します。
//        String tempDateFrom = param.dateFrom;
//        String treatDateFormatted;
//        if(tempDateFrom.contains("/")) {
//          treatDateFormatted = param.dateFrom.replace("/", "-");
//        }else {
//          treatDateFormatted = param.dateFrom.substring(0,4) + "-" +  param.dateFrom.substring(4,6) + "-" +  param.dateFrom.substring(6);
//        }
//        // mod 10375 患者イベント(テキストエリア)の出力が不正 吉 start
////        String[] result = getStartAndEndDayByDate(treatDateFormatted);
////        if (null != reportMenu.getReportType() && !"1".equals(reportMenu.getReportType()) ){
//        if (null != reportMenu.getReportType() && !"1".equals(reportMenu.getReportType()) && isHaveTotalFlag){
//          String[] result = getStartAndEndDayByDate(treatDateFormatted);
//          // mod 10375 患者イベント(テキストエリア)の出力が不正 吉 end
//          tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, result[0].replace("-",""));
//          tmplParam.put(ReportConstant.ReportDataKey.DATE_TO, result[1].replace("-",""));
//        }else{
//          tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, treatDateFormatted.replace("-",""));
//          tmplParam.put(ReportConstant.ReportDataKey.DATE_TO,treatDateFormatted.replace("-",""));
//        }
//      }else{
//        tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, param.dateFrom);
//        tmplParam.put(ReportConstant.ReportDataKey.DATE_TO, param.dateTo);
//      }
//      tmplParam.put(ReportConstant.ReportDataKey.DATE, param.date.replace("/",""));
//      tmplParam.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
//      // mod #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
//      //tmplParam.put(ReportConstant.ReportDataKey.MACHINE_NO, listMachineNo);
//      tmplParam.put(ReportConstant.ReportDataKey.MACHINE_NOS, listMachineNo);
//      // mod #9558 機能帳票で正しく変数が引き渡されていない limingzhe end
//      tmplParam.put(ReportConstant.ReportDataKey.ORD_NOS, listOrdNo);
//      // add #11009 カテゴリ「印刷情報」の優先対応 高 start
//      tmplParam.put(ReportConstant.ReportDataKey.kurCdList, reportMenu.getKurCdList());
//      tmplParam.put(ReportConstant.ReportDataKey.weeks, dataKey.get(ReportConstant.ReportDataKey.weeks));
//      // add #11009 カテゴリ「印刷情報」の優先対応 高 end
//      tmplParams.add(tmplParam);
//    //}
//    // mod 10546 複数集計出力時にサーバが高負荷になる gjn end
//    dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, tmplParams);
//    dataKey.put("login", userName);
//    dataKey.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
//    dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate());
//    dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
//    dataKey.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
//    dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
//    String kind ="医療材料";
//    if(null != reportMenu.getEquipmentCdList() && reportMenu.getEquipmentCdList().size() == 0 && null !=  reportMenu.getMedicineCdList() && reportMenu.getMedicineCdList().size()>0){
//      kind="";
//    }
//    if(null !=  reportMenu.getMedicineCdList() && reportMenu.getMedicineCdList().size()>0){
//      if("" == kind){
//        kind="薬剤";
//      }else{
//        kind=kind+"·薬剤";
//      }
//    }
//    dataKey.put(ReportConstant.ReportDataKey.kind,kind);
//    SimpleDateFormat sdf =new SimpleDateFormat("yyyy年MM月dd日");
//    // del #11009 カテゴリ「印刷情報」の優先対応 高 start
////    if(null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate()){
////      String day=reportMenu.getSpecifyDate().substring(6,8);
////      String date = reportMenu.getSpecifyDate();
////      Calendar calendar =Calendar.getInstance();
////      calendar.setFirstDayOfWeek(Calendar.MONDAY);
////      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
////      int week = calendar.get(Calendar.WEEK_OF_MONTH);
////      dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
////      String treatDateFormatted = date.substring(0,4) + "-" + date.substring(4,6) + "-" + date.substring(6);
////      String[] result = getStartAndEndDayByDate(treatDateFormatted);
////      String start = result[0].substring(0,4) + "年" + result[0].substring(5,7) + "月" + result[0].substring(8)+ "日";
////      String end = result[1].substring(5,7) + "月" + result[1].substring(8)+ "日";
////      dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
////    }else{
////      String day=reportMenu.getFromDate().substring(6,8);
////      //String fromDate = reportMenu.getFromDate().substring(0,4) + "-" + reportMenu.getFromDate().substring(4,6) + "-" + reportMenu.getFromDate().substring(6);
////      Calendar calendar =Calendar.getInstance();
////      calendar.setFirstDayOfWeek(Calendar.MONDAY);
////      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
////      int week = calendar.get(Calendar.WEEK_OF_MONTH);
////      dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
////      String start = reportMenu.getFromDate().substring(0,4) + "年" + reportMenu.getFromDate().substring(4,6) + "月" + reportMenu.getFromDate().substring(6)+ "日";
////      String end =  reportMenu.getToDate().substring(4,6) + "月" + reportMenu.getToDate().substring(6)+ "日";
////      dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
////    }
//    // del #11009 カテゴリ「印刷情報」の優先対応 高 end
//    // add #11003 日付型データ項目で書式設定が反映しない場合がある limingzhe start
//    dataKey.put(ReportConstant.ReportDataKey.MACHINE_NOS, listMachineNo);
//    // add #11003 日付型データ項目で書式設定が反映しない場合がある limingzhe end
//    return dataKey;
//  }
//  // add 10546 複数集計出力時にサーバが高負荷になる gjn end
  private Map<String, Object> setMultiTotalDataKey(ReportMenuSortContainer reportMenu, String userName) throws ParseException {
    // reportType [1:スケジュール表, 2:週間薬剤集計表, 3:水質調査一覧]
    Integer reportType = Integer.parseInt(reportMenu.getReportType());

    Map<String, Object> dataKey = new HashMap<>();
    // テンプレート外領域のパラメータを生成する処理を実装する
    // ダイアライザーが含まれるか
    if (reportMenu.isDialyzer()) {
      List<Integer> listDia = new ArrayList<>();
      for(MstDialyzer item : mstInfoService.findMstDialyzerAllByFacillityCd(reportMenu.getFacilityCd())) {
        listDia.add(item.getDialyzerCd());
      }
      dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS, listDia);
    } else {
      dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS, Collections.singletonList(0));
    }
    if (reportMenu.getMedicineCdList() != null && reportMenu.getMedicineCdList().size() > 0) {
      dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS, reportMenu.getMedicineCdList());
    } else {
      dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS, Collections.singletonList(0));
    }
    if (reportMenu.getEquipmentCdList() != null && reportMenu.getEquipmentCdList().size() > 0) {
      dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, reportMenu.getEquipmentCdList());
    } else {
      dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, Collections.singletonList(0));
    }
    // mod #11973 日常点検一覧帳票が正常に出せない limingzhe start
    // dataKey.put(ReportConstant.ReportDataKey.kurCdLists, reportMenu.getKurList());
    // dataKey.put(ReportConstant.ReportDataKey.bedCdLists, reportMenu.getBedCdList());
    List<Long> listKurCd = new ArrayList<>();
    if(reportMenu.getKurList() != null && reportMenu.getKurList().size() > 0){
      listKurCd.addAll(reportMenu.getKurList());
    }
    else{
      List<MstKur> kurAll = mstKurDao.selectByFacilityCd(SelectOptions.get(), reportMenu.getFacilityCd(), "0");
      for (int i = 0; i < kurAll.size(); i++) {
        listKurCd.add(Long.parseLong(String.valueOf(kurAll.get(i).getKurCd())));
      }
    }
    List<Long> listBedCd = new ArrayList<>();
    if(reportMenu.getBedCdList() != null && reportMenu.getBedCdList().size() > 0){
      listBedCd.addAll(reportMenu.getBedCdList());
    }
    else{
      List<MstBed> bedAll = mstBedDao.selectByFacilityCdMachineNo(reportMenu.getFacilityCd());
      for (int i = 0; i < bedAll.size(); i++) {
        listBedCd.add(bedAll.get(i).getBedCd());
      }
    }
    dataKey.put(ReportConstant.ReportDataKey.KUR_CDS, listKurCd);
    dataKey.put(ReportConstant.ReportDataKey.BED_CDS, listBedCd);
    // mod #11973 日常点検一覧帳票が正常に出せない limingzhe end
    dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
    dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
    List<Long> listMachineNo = new ArrayList<>();
    for (int i = 0; i < reportMenu.getMachines().size(); i++) {
      listMachineNo.add(reportMenu.getMachines().get(i).getMachineNo());
    }
    // add #11744 水質検査帳票で、装置に紐づかない検査個所が出力できない sunsy start
    if (null != listMachineNo && listMachineNo.size() > 0) {
      listMachineNo.add(-1L);
    }
    // add #11744 水質検査帳票で、装置に紐づかない検査個所が出力できない sunsy end
    dataKey.put(ReportConstant.ReportDataKey.MACHINE_NOS, listMachineNo);
    // del #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
//    MstReport mstReport = getMstReport(reportMenu.getReportCd());
//    ReportZipFile reportZipFile = getReportZip(mstReport);
//    String reportXml = getReportXml(mstReport, reportZipFile);
//    List<ReportXmlParam> xmlparams = ReportUtils.getParamElements(reportXml);
//    boolean isHaveTotalFlag = false;
//    if(null != xmlparams && null != xmlparams.get(0) && null != xmlparams.get(0).getReportXmlTmplRepeat() && !"".equals(xmlparams.get(0).getReportXmlTmplRepeat().getId())){
//      isHaveTotalFlag = true;
//    }
    // del #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end

    // データ抽出条件を「指定日」
    if (null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate() ) {
      String specifyDate = reportMenu.getSpecifyDate().replace("/", "").replace("-", "");
      // del #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
//      if(reportType == 2 && isHaveTotalFlag){
//        SimpleDateFormat inputFormat = new SimpleDateFormat("yyyyMMdd");
//        SimpleDateFormat outputFormat = new SimpleDateFormat("yyyy-MM-dd");
//        try {
//          Date date = inputFormat.parse(specifyDate);
//          String formattedDate = outputFormat.format(date);
//          String[] result = getStartAndEndDayByDate(formattedDate);
//          dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, result[0].replace("-",""));
//          dataKey.put(ReportConstant.ReportDataKey.DATE_TO, result[1].replace("-",""));
//        } catch (ParseException e) {
//          e.printStackTrace();
//        }
//      }else{
      // del #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end
        dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, specifyDate);
        dataKey.put(ReportConstant.ReportDataKey.DATE_TO, specifyDate);
      // del #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
//      }
      // del #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end
      dataKey.put("specifyDate", specifyDate);
      dataKey.put(ReportConstant.ReportDataKey.DATE, specifyDate);
    } else {
      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, reportMenu.getFromDate().replace("/", "").replace("-", ""));
      dataKey.put(ReportConstant.ReportDataKey.DATE_TO, reportMenu.getToDate().replace("/", "").replace("-", ""));
      dataKey.put("specifyDate", reportMenu.getSpecifyDate());
      dataKey.put(ReportConstant.ReportDataKey.DATE, reportMenu.getFromDate().replace("/", "").replace("-", ""));
    }

    List<ReportParam> params = new ArrayList<>();
    List<Long> patIds = reportMenu.getPatIds();
    Long patId;
    // mod #11973 日常点検一覧帳票が正常に出せない limingzhe start
    // if(reportType != 3)
    Integer selectedType = 1; // 1:対象患者 2:対象装置
    if(reportType == 3) selectedType = 2;
    else if(reportType == 4) selectedType = 2;
    // add #11985 定期点検一覧帳票が正常に出せない limingzhe start
    else if(reportType == 5) selectedType = 2;
    // add #11985 定期点検一覧帳票が正常に出せない limingzhe end
    if(selectedType == 1)
    // mod #11973 日常点検一覧帳票が正常に出せない limingzhe end
    {
      // del #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
//      if (reportMenu.getDateKind().equals("dialysis_date")){ // 基準日が透析日の場合
      // del #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
        List<OrdMain> ordList = reportMenuDao.selectByTreatDateAndPatIdsfacilityCd(
          patIds,
          reportMenu.getFacilityCd(),
          null,
          dataKey.get(ReportConstant.ReportDataKey.DATE_FROM).toString(),
          dataKey.get(ReportConstant.ReportDataKey.DATE_TO).toString()
        );
        String dateString;
        for (int i = 0; i < ordList.size(); i++) {
          ReportParam reportParam = new ReportParam();
          OrdMain ordMain = ordList.get(i);
          reportParam.ordNo = ordMain.getOrdNo();
          final String treatDate = dateStr2dispDateStr(ordMain.getTreatDate());
          dateString = treatDate;
          dateString = dateString.replace("/", "");
          reportParam.patId = ordMain.getPatId();
          reportParam.date = dateString;
          reportParam.dateFrom = dataKey.get(ReportConstant.ReportDataKey.DATE_FROM).toString();
          reportParam.dateTo = dataKey.get(ReportConstant.ReportDataKey.DATE_TO).toString();
          params.add(reportParam);
        }
      // del #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
//      } else if (reportMenu.getDateKind().equals("exam_date")){  // 基準日が検査日の場合
//        // 検査区分(チェックボックス)が指定されていなかったら検査対象を取得できないので、検索処理を行わない
//        // 患者IDリストで渡された患者の期間内での最新の検査結果の検査日を取得する。
//        // 検査結果が存在しない場合は、期間内の今日以降の直近検査予定の検査日を取得する。
//        // 検査結果または検査結果を取得する際のフィルタとして、帳票画面の検査区分、およびExcelパラメータの各検査コード、検査区分を使用する。
//        // 検査結果、検査予定共に無い場合は、患者情報のみ。
//        for (int index = 0; index < patIds.size(); index++) {
//          patId = patIds.get(index);
//          ReportParam reportParam = new ReportParam();
//          reportParam.patId = patId;
//          // 検査結果
//          List<PatExamMain> examMainList = new ArrayList<>();
//          // 検索区分
//          List<String> regOrderClassList = reportMenu.getRegOrderClassList();
//          // 日付がどのように選択されているか確認して、検査結果リストを取得する
//          String fromDate = dataKey.get(ReportConstant.ReportDataKey.DATE_FROM).toString();
//          String toDate = dataKey.get(ReportConstant.ReportDataKey.DATE_TO).toString();
//          LocalDateTime localDateFrom = LocalDate.parse(fromDate, DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
//          LocalDateTime localDateTo = LocalDate.parse(toDate, DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
//          localDateTo = localDateTo.plusDays(1L).minusNanos(1000);
//          examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateFrom), Timestamp.valueOf(localDateTo), regOrderClassList);
//          boolean isNotExistExamResult = true;
//          for (PatExamMain exam : examMainList) {
//            // 検査日リスト
//            // 期間内での最新の検査結果の検査日を取得する
//            if (Objects.equal(exam.getExamStatus(), "1")) {
//              // 検査結果
//              // 検査日時が最新であるか判定する処理を実装する
//              isNotExistExamResult = false;
//              String uuuuMMdd = exam.getResultExamDate().toLocalDateTime().toLocalDate().format(DateTimeFormatter.ofPattern("uuuuMMdd"));
//              reportParam.date = uuuuMMdd;
//            } else if (isNotExistExamResult) {
//              // 検査予定
//              String uuuuMMdd = exam.getRegExamDate().toLocalDateTime().toLocalDate().format(DateTimeFormatter.ofPattern("uuuuMMdd"));
//              reportParam.date = uuuuMMdd;
//            }
//          }
//          // 共通付値を抽出します。dateにデフォルト値を設定します。そうしないと、date空ポインタ異常が発生します。
//          reportParam.dateFrom = fromDate;
//          reportParam.dateTo = toDate;
//          if(null == reportParam.date) {
//            reportParam.date = fromDate;
//          }
//          // 透析実績と紐づける
//          List<OrdMain> ordList = reportMenuDao.selectByTreatDate(patId, null, fromDate, toDate);
//          List<OrdMain> ords = ordList.stream().filter
//            (o -> Objects.equal(o.getTreatDate(), reportParam.date == null ? null : reportParam.date.replace("/", ""))).collect(Collectors.toList());
//          if (ords.size() > 0) {
//            // 検査日と同じ日に透析実績がある場合、透析番号を紐づける
//            reportParam.ordNo = ords.get(ords.size() - 1).getOrdNo();
//          }
//          params.add(reportParam);
//        }
//      }
      // del #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
    } else {
      ReportParam reportParam = new ReportParam();
      reportParam.date = dataKey.get(ReportConstant.ReportDataKey.DATE).toString();
      reportParam.dateFrom = dataKey.get(ReportConstant.ReportDataKey.DATE_FROM).toString();
      reportParam.dateTo = dataKey.get(ReportConstant.ReportDataKey.DATE_TO).toString();
      params.add(reportParam);
    }
    List<Long> listOrdNo = new ArrayList<>();
    for (int i = 0; i < params.size(); i++) {
      // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe start
      if(params.get(i).ordNo == null) continue;
      // add #12311 複数集計で患者毎の汎用的な集計を作成できない limingzhe end
      listOrdNo.add(params.get(i).ordNo);
    }
    dataKey.put(ReportConstant.ReportDataKey.ORD_NOS, listOrdNo);

    // del #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
//    // テンプレート内 領域のパラメータを生成する処理を実装する
//    // 以下の構造のMapを生成する
//    // キー: tmplParams テンプレート内パラメーター
//    List<Map<String, Object>> tmplParams = new ArrayList<Map<String, Object>>();
//    ReportParam param = params.get(0);
//    Map<String, Object> tmplParam = new HashMap<>();
//    tmplParam.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
//    tmplParam.put(ReportConstant.ReportDataKey.DIALYZER_IDS,dataKey.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
//    tmplParam.put(ReportConstant.ReportDataKey.MEDICINE_IDS,dataKey.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
//    tmplParam.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,dataKey.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
//    // mod #11973 日常点検一覧帳票が正常に出せない limingzhe start
//    //tmplParam.put(ReportConstant.ReportDataKey.kurCdList, reportMenu.getKurCdList());
//    tmplParam.put(ReportConstant.ReportDataKey.KUR_CDS, listKurCd);
//    tmplParam.put(ReportConstant.ReportDataKey.BED_CDS, listBedCd);
//    // mod #11973 日常点検一覧帳票が正常に出せない limingzhe end
//    tmplParam.put(ReportConstant.ReportDataKey.ORD_NO, param.ordNo);
//    tmplParam.put(ReportConstant.ReportDataKey.ORD_NOS, listOrdNo);
//    tmplParam.put(ReportConstant.ReportDataKey.PAT_ID, param.patId);
//    tmplParam.put(ReportConstant.ReportDataKey.PAT_IDS, patIds);
//    tmplParam.put(ReportConstant.ReportDataKey.MACHINE_NOS, listMachineNo);
//    tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, param.dateFrom);
//    tmplParam.put(ReportConstant.ReportDataKey.DATE_TO, param.dateTo);
//    tmplParam.put(ReportConstant.ReportDataKey.DATE, param.date);
//    // del #11973 日常点検一覧帳票が正常に出せない limingzhe start
////    tmplParam.put(ReportConstant.ReportDataKey.weeks, reportMenu.getWeeks());
//    // del #11973 日常点検一覧帳票が正常に出せない limingzhe end
//    tmplParams.add(tmplParam);
//    dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, tmplParams);
    // del #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end
    return dataKey;
  }
  // mod #11642 スケジュール表帳票がデータ抽出条件「指定日」で「一週間出力」になるのはNG limingzhe end

  /**
	 * 治療日で治療情報の取得
	 *
	 * @param patId
	 * @param facilityCd
	 * @param regOrderClassList
	 * @param fromDate
	 * @param toDate
	 * @param specifyDate
	 * @return
	 */
	private List<Long> getOrdNoListByDate(Long patId, String facilityCd, List<String> regOrderClassList,
			String fromDate, String toDate, String specifyDate) {
		if (specifyDate != null) {
			return reportMenuDao.selectByDate(patId, facilityCd, regOrderClassList, specifyDate);
		} else {
			return reportMenuDao.selectByDateFromTo(patId, facilityCd, regOrderClassList, fromDate, toDate);
		}
	}

	/**
	 *
	 * {@inheritDoc}
	 */
	@Override
	public byte[] convertHtmlToPdf(String html) throws Exception {
		Path htmlPath = null;
		Path pdfPath = null;
		if (html.equals("")) {
			return null;
		}
		try {
			// HTMLデータを一時ファイルに保存
		    htmlPath = tmpFileService.createTmpDirectoryAndFile(createTmpDir, "nkk-report", ".html");
			Files.write(htmlPath, html.getBytes(StandardCharsets.UTF_8));

			// 生成するPDFの一時ファイルを生成
			pdfPath = tmpFileService.createTmpDirectoryAndFile(createTmpDir, "nkk-report", ".pdf");

			String[] command = { "wkhtmltopdf", htmlPath.toString(), pdfPath.toString() };

			Runtime rt = Runtime.getRuntime();
			int runCmd = rt.exec(command).waitFor();
			if (runCmd == 0) {
				byte[] data = Files.readAllBytes(Paths.get(pdfPath.toString()));
				return data;
			} else {
				return null;
			}
		} finally {
			// 一時ファイルを削除
			Optional.ofNullable(htmlPath).ifPresent(path -> path.toFile().delete());
			Optional.ofNullable(pdfPath).ifPresent(path -> path.toFile().delete());
		}
	}

	/**
	 *
	 * {@inheritDoc}
	 */
	@Override
  /*mod FNSI-改修内容装置帳票の対応 任 start*/
  /*public byte[] zipFile(List<Map<Long, List<byte[]>>> patFile, String reportName, Integer option) {*/
	public byte[] zipFile(List<Map<Long, List<byte[]>>> patFile, String reportName, Integer option,Integer reportClass) {
    /*mod FNSI-改修内容装置帳票の対応 任 end*/
    Path zipPath = null;
    byte[] zipFileBytes = null;
    ZipOutputStream zos = null;
    try {
      zipPath = tmpFileService.createTmpDirectoryAndFile(createTmpDir, "nkk-report-zip", ".zip");
      FileOutputStream fos = new FileOutputStream(zipPath.toString());
      zos = new ZipOutputStream(fos);
      /*add FNSI-改修内容装置帳票の対応 任 start*/
      Map<String,String> map1 = new HashMap<String,String>();
      /*add FNSI-改修内容装置帳票の対応 任 end*/
      for (int i = 0; i < patFile.size(); i++) {
        for (Long key : patFile.get(i).keySet()) {
          List<byte[]> bytesList = patFile.get(i).get(key);
          for (int j = 0; j < bytesList.size(); j++) {
            byte[] data = bytesList.get(j);
            if (data.length > 0) {
              /*mod FNSI-改修内容装置帳票の対応 任 start*/
              /*ByteArrayInputStream fis = new ByteArrayInputStream(data);
              String fileName = getFileNameByPatId(key, reportName);*/
              String fileName = "";
              ByteArrayInputStream fis = new ByteArrayInputStream(data);
              if(reportClass.equals(ReportConstant.ReportClass.MACHINE_REPORT)){
                LocalDate localDate = LocalDate.now();
                int month = localDate.getMonthValue();
                int dayOfMonth = localDate.getDayOfMonth();
                int year = localDate.getYear();
                String dateString = String.valueOf(year) + String.valueOf(month) + String.valueOf(dayOfMonth);
                if(patFile.size()>1){
                  fileName = "[" + reportName + "]_[" + dateString + "](" + (i + 1) + ").pdf";
                }else{
                  fileName = "[" + reportName + "]_[" + dateString + "].pdf";
                }

              }else{
                fileName = getFileNameByPatId(key, reportName);
              }
              /*mod FNSI-改修内容装置帳票の対応 任 end*/
              if (bytesList.size() > 1) {
                if (option == 1) {
                  // mod #10616 選択患者分の帳票が出力されない 王永吉 start
                  //fileName = fileName.replace(".pdf", "(" + (j + 1) + ").pdf");
                  fileName = fileName.replace(".pdf", ".pdf");
                  // mod #10616 選択患者分の帳票が出力されない 王永吉 end
                } else {
                  // mod #10616 選択患者分の帳票が出力されない 王永吉 start
                  //fileName = fileName.replace(".pdf", "(" + (j + 1) + ").xlsx");
                  fileName = fileName.replace(".pdf", ".xlsx");
                  // mod #10616 選択患者分の帳票が出力されない 王永吉 end
                }
              } else {
                if (option == 2) {
                  fileName = fileName.replace(".pdf", ".xlsx");
                }
              }
              /*add FNSI-改修内容装置帳票の対応 任 start*/
              if(map1!=null&&map1.containsKey(fileName)){
                String fileNameOld =  map1.get(fileName);
                if(fileNameOld.indexOf(")")>0){
                  int num = Integer.parseInt(fileNameOld.split("\\(")[1].split("\\)")[0]);
                  fileName = fileNameOld.replaceAll("\\(" + num + "\\)","(" + num+1 + ")");
                }else{
                  fileName = fileNameOld.replaceAll("]\\.","](1).");
                }
                map1.put(fileName,fileName);
              }
              map1.put(fileName,fileName);
              /*add FNSI-改修内容装置帳票の対応 任 end*/
              int length;
              byte[] buffer = new byte[data.length];
              // ファイル名に使用できない文字を置換
              fileName = fileName.replaceAll("[\\\\/:\\*\\?<>\\|]", "_");
              zos.putNextEntry(new ZipEntry(fileName));
              BufferedInputStream bufferedInputStream = new BufferedInputStream(fis);
              while ((length = bufferedInputStream.read(buffer)) > 0) {
                zos.write(buffer, 0, length);
              }
              zos.closeEntry();
              fis.close();
            }
          }
        }
      }
      //add ダウンロードしたファイルを開けない  吉 start
      zos.close();
      fos.close();
      //add ダウンロードしたファイルを開けない  吉 end
      zipFileBytes = Files.readAllBytes(Paths.get(zipPath.toString()));
      return zipFileBytes;
    } catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      return null;
    } finally {
      //del ダウンロードしたファイルを開けない  吉 start
//      if (zos != null) {
//        try {
//
//          zos.close();
//        } catch (Exception e) {
//        }
//      }
      //del ダウンロードしたファイルを開けない  吉 end
      Optional.ofNullable(zipPath).ifPresent(path -> path.toFile().delete());
    }
	}

	/**
	 *
	 * {@inheritDoc}
	 */
	@Override
	public byte[] zipFileMultiPat(byte[] patPdf, byte[] patExcel, String reportName) {
		Path zipPath = null;
		byte[] zipFileBytes = null;
		ZipOutputStream zos = null;
		try {
		    zipPath = tmpFileService.createTmpDirectoryAndFile(createTmpDir, "nkk-report-zip", ".zip");
			FileOutputStream fos = new FileOutputStream(zipPath.toString());
			zos = new ZipOutputStream(fos);

			// pdf
			ByteArrayInputStream fis = new ByteArrayInputStream(patPdf);
			String fileName = reportName + ".pdf";

			int length;
			byte[] buffer = new byte[patPdf.length];
			zos.putNextEntry(new ZipEntry(fileName));
			while ((length = fis.read(buffer)) > 0) {
				zos.write(buffer, 0, length);
			}
			zos.closeEntry();
			fis.close();

			// excel
			fis = new ByteArrayInputStream(patExcel);
			fileName = reportName + ".xlsx";

			buffer = new byte[patExcel.length];
			zos.putNextEntry(new ZipEntry(fileName));
			while ((length = fis.read(buffer)) > 0) {
				zos.write(buffer, 0, length);
			}
			zos.closeEntry();
			fis.close();

			zipFileBytes = Files.readAllBytes(Paths.get(zipPath.toString()));
			return zipFileBytes;
		} catch (Exception e) {
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
      EventLogMessage eventLogMessage = new EventLogMessage();
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
			return null;
		} finally {
		    if (zos != null) {
              try {
                zos.close();
              } catch (Exception e) {
              }
		    }
			Optional.ofNullable(zipPath).ifPresent(path -> path.toFile().delete());
		}
	}

	/**
	 *
	 * {@inheritDoc}
	 */
	@Override
	public String getFileNameByPatId(Long patId, String reportName) {
		String fileName = "";
    // del 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 start
//		LocalDate localDate = LocalDate.now();
//		int month = localDate.getMonthValue();
//		int dayOfMonth = localDate.getDayOfMonth();
//		int year = localDate.getYear();
    // del 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 end
    //mod 帳票印刷の命名規則が変更されました 吉 start
    // del 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 start
////    String dateString = String.valueOf(year) + String.valueOf(month) + String.valueOf(dayOfMonth);
//    String time = String.valueOf(new Date().getTime());
//    String dateString = String.valueOf(year) + String.valueOf(month) + String.valueOf(dayOfMonth)+time;
    // del 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 end
    //mod 帳票印刷の命名規則が変更されました 吉 end
    // add 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 start
    Date date = new Date();
    // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
//    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmssSSS");
    // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end
    String dateString = sdf.format(date);
    // add 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 end
		PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);
		String lastName = patPersonalMain.getPat_last_name();
		String firstName = patPersonalMain.getPat_first_name();
    /*mod FNSI-改修内容圧縮ファイル名が不正 任 start*/
    /*String name = firstName + lastName;*/
		String name = lastName + firstName;
    /*mod FNSI-改修内容圧縮ファイル名が不正 任 start*/
		fileName = "[" + reportName + "]_[" + name + "]_[" + dateString + "].pdf";
		return fileName;
	}

	/**
	 * 患者IDの再度ソート
	 *
	 * @param key
	 * @param value
	 * @param ids
	 * @return ids
	 */
  /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 start*/
  /*public List<Long> sortPatientIds(String key, String value, List<Long> ids, String facilityCd) {
    List<Long> idList = new ArrayList<>();*/
	public List<EntityDao> sortPatientIds(String key, String value, List<Long> ids, String facilityCd) {
		List<EntityDao> idList = new ArrayList<>();
    /*mod FNSI-改修内容表示順が全部効かなくて、最後の表示順だけ効いてしまう。 任 end*/
		switch (key) {

		case ReportMenu.PATIENT_ID:
			idList = reportMenuSortDao.selectByPatId(ids, value, facilityCd);
			break;

		case ReportMenu.PATIENT_NAME:
			idList = reportMenuSortDao.selectSortByFullname(ids, value, facilityCd);
			break;

		case ReportMenu.PATIENT_BED:
			idList = reportMenuDao.selectSortByBed(ids, value, facilityCd);
			break;

		case ReportMenu.PATIENT_COOL:
			idList = reportMenuDao.selectSortByCool(ids, value, facilityCd);
			break;

		case ReportMenu.READING:
			idList = reportMenuSortDao.selectSortByKanaFullname(ids, value, facilityCd);
			break;

		case ReportMenu.PATIENT_GROUP_NAME:
			idList = reportMenuDao.selectSortByGroupName(ids, value);
			break;

		case ReportMenu.BED_GROUP_NAME:
			idList = reportMenuDao.selectSortByBedGroupName(ids, value, facilityCd);
			break;

		case ReportMenu.BED_NAME:
			idList = reportMenuDao.selectSortByBedName(ids, value, facilityCd);
			break;

		case ReportMenu.ENTRANCE_EXIT_CLASSIFICATION:
			idList = reportMenuDao.selectSortByInOutClass(ids, value, facilityCd);
			break;

		case ReportMenu.SEX:
			idList = reportMenuSortDao.selectSortBySex(ids, value, facilityCd);
			break;

		case ReportMenu.INFECTIOUS_ISEASE_PATIENTS:
			idList = reportMenuDao.selectSortByInfect(ids, value, facilityCd);
			break;

		case ReportMenu.BLOOD_TYPE:
			idList = reportMenuSortDao.selectSortByPatBloodType(ids, value, facilityCd);
			break;

		case ReportMenu.MEDICINE_EQUIPMENT_CODE:
			idList = reportMenuDao.selectSortByEquipMedicineCode(ids, value, facilityCd);
			break;

		case ReportMenu.MEDICINE_EQUIPMENT_CLASS:
			idList = reportMenuDao.selectSortByEquipMedicineClass(ids, value, facilityCd);
			break;

		case ReportMenu.MEDICINE_EQUIPMENT_NAME:
			idList = reportMenuDao.selectSortByEquipmentMedicine(ids, value, facilityCd);
			break;
		/*add 2020-12-09 FNSI-添加内容 各帳票の並び順調整。 吉 start*/
    case ReportMenu.DIALYSIS_DAY:
      idList = reportMenuDao.selectSortByDialysisDay(ids, value, facilityCd);
      break;

    case ReportMenu.DIALYSIS_ROOM_GROUP:
      idList = reportMenuDao.selectSortByDialysisRoomGroup(ids, value, facilityCd,"2");
      break;

    case ReportMenu.ROOM_BED_GROUP:
      idList = reportMenuDao.selectSortByDialysisRoomGroup(ids, value, facilityCd,"1");
      break;
    /*add 2020-12-09 FNSI-添加内容 各帳票の並び順調整。 吉 end*/

		default:
			break;
		}
		return idList;
	}

	/**
	 *
	 * {@inheritDoc}
	 */
	@Override
	public HashMap<Long, List<Long>> getOrdNoList(ReportMenuSortContainer reportMenu) {
		String facilityCd = reportMenu.getFacilityCd();
		List<String> regOrderClassList = reportMenu.getRegOrderClassList();

		if (regOrderClassList == null) {
			regOrderClassList = new ArrayList<>();
		}

		HashMap<Long, List<Long>> results = new HashMap<>();

		List<Long> patIds = reportMenu.getPatIds();
		for (int index = 0; index < patIds.size(); index++) {
			Long patId = patIds.get(index);
			List<Long> ordNos = new ArrayList<>();

			List<Long> ordNoFilterByDate = getOrdNoListByDate(patId, facilityCd, regOrderClassList,
					reportMenu.getFromDate(), reportMenu.getToDate(), reportMenu.getSpecifyDate());

			for (int i = 0; i < ordNoFilterByDate.size(); i++) {
				Long ordNo = ordNoFilterByDate.get(i);
				ordNos.add(ordNo);
			}
      // add 2020-09-21 FNSI-仕様追加 出力データなしの場合に帳票も表示する 夏 start
      if(ordNos.size() == 0){
        ordNos.add(0l);
        results.put(patId, ordNos);
      }else {
      // add 2020-09-21 FNSI-仕様追加 出力データなしの場合に帳票も表示する 夏 end
        results.put(patId, ordNos);
      }
		}
		return results;
	}

	/**
	 *
	 * {@inheritDoc}
	 */
	@Override
	public void printReport(List<Map<Long, List<String>>> patHtmls, String reportName, Long printerCd)
			throws Exception {
		for (int i = 0; i < patHtmls.size(); i++) {
			for (Long key : patHtmls.get(i).keySet()) {
				List<String> htmls = patHtmls.get(i).get(key);
				for (int j = 0; j < htmls.size(); j++) {
					Path htmlPath = null;
					Path pdfPath = null;
					try {
						String html = htmls.get(j);
						// HTMLデータを一時ファイルに保存
						htmlPath = tmpFileService.createTmpDirectoryAndFile(createTmpDir, "nkk-report", ".html");
						Files.write(htmlPath, html.getBytes(StandardCharsets.UTF_8));

						// 生成するPDFの一時ファイルを生成
						pdfPath = tmpFileService.createTmpDirectoryAndFile(createTmpDir, "nkk-report", ".pdf");
						String[] command = { "wkhtmltopdf", htmlPath.toString(), pdfPath.toString() };

						Runtime rt = Runtime.getRuntime();
						int runCmd = rt.exec(command).waitFor();
						if (runCmd == 0) {
							String fileName = getFileNameByPatId(key, reportName);
							if (htmls.size() > 0) {
								fileName = fileName.replace(".pdf", "(" + (j + 1) + ").pdf");
								String destFilePath = "pdf/" + fileName;
								// 印刷用ファイルはローカルに保存する
								onPremiseService.putFile(printTmpDir, destFilePath, pdfPath);

								printerService.sendPrintRequest(printerCd, destFilePath);
							}
						} else {
							return;
						}
					} finally {
						// 一時ファイルを削除
						Optional.ofNullable(htmlPath).ifPresent(path -> path.toFile().delete());
						Optional.ofNullable(pdfPath).ifPresent(path -> path.toFile().delete());
					}
				}
			}
		}
	}

    /* add by shiyinwang 2022-11-30 -- Aspose.cells plug-in integration --start */
    //add #9616 帳票印刷失敗通知がされない 李 start
    @Override
    public void printPdfReport(List<Map<Long, List<byte[]>>> patPdfFiles, String reportName, Long printerCd)
      throws Exception {
      printPdfReport(patPdfFiles, reportName, printerCd, "");
    }
  //add #9616 帳票印刷失敗通知がされない 李 end

  @Override
  //add #9616 帳票印刷失敗通知がされない 李 start
  //public void printPdfReport(List<Map<Long, List<byte[]>>> patPdfFiles, String reportName, Long printerCd)
  public void printPdfReport(List<Map<Long, List<byte[]>>> patPdfFiles, String reportName, Long printerCd, String reportType)
  //add #9616 帳票印刷失敗通知がされない 李 end
    throws Exception {
      //Map<patId,patName>
      Map<Long,String> patNameMap = new HashMap<>();
    for (int i = 0; i < patPdfFiles.size(); i++) {
      for (Long patId : patPdfFiles.get(i).keySet()) {
        if(!patNameMap.containsKey(patId)){
          PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);
          String lastName = patPersonalMain.getPat_last_name();
          String firstName = patPersonalMain.getPat_first_name();
          String patName = lastName + firstName;
          patNameMap.put(patId,patName);
        }
      }
    }

    LocalDate localDate = LocalDate.now();

    for (int i = 0; i < patPdfFiles.size(); i++) {
      for (Long key : patPdfFiles.get(i).keySet()) {
        List<byte[]> pdfFiles = patPdfFiles.get(i).get(key);
        for (int j = 0; j < pdfFiles.size(); j++) {
          Path pdfPath = null;
          try {
            byte[] pdfFileBytes = pdfFiles.get(j);
            // 生成するPDFの一時ファイルを生成
            pdfPath = tmpFileService.createTmpDirectoryAndFile(createTmpDir, "nkk-report", ".pdf");
            // mod #10616 選択患者分の帳票が出力されない 王永吉 start
            //String fileName = getFileNameByPatName(localDate,patNameMap.get(key),reportName);
            String fileName = getFileNameToPrintByPatName(patNameMap.get(key),reportName);
            // mod #10616 選択患者分の帳票が出力されない 王永吉 end
            if (pdfFileBytes.length > 0) {
              // del #10616 選択患者分の帳票が出力されない 王永吉 start
              //fileName = fileName.replace(".pdf", "(" + (j + 1) + ").pdf");
              // del #10616 選択患者分の帳票が出力されない 王永吉 end
              String destFilePath = "pdf/" + fileName;
              // 印刷用ファイルはローカルに保存する
              onPremiseService.writeBytesToFile(printTmpDir + "/" + destFilePath,pdfFileBytes);
              //mod #9616 帳票印刷失敗通知がされない 李 start
//              printerService.sendPrintRequest(printerCd, destFilePath);
              printerService.sendPrintRequest(printerCd, destFilePath, reportName, reportType);
              //mod #9616 帳票印刷失敗通知がされない 李 end
            }
          } finally {
            // 一時ファイルを削除
            Optional.ofNullable(pdfPath).ifPresent(path -> path.toFile().delete());
            Optional.ofNullable(pdfPath).ifPresent(path -> path.toFile().delete());
          }
        }
      }
    }
  }
  // add #10616 選択患者分の帳票が出力されない 王永吉 start
  private String getFileNameToPrintByPatName(String patName, String reportName) {
    String fileName = "";
    Date date = new Date();
    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmssSSS");
    String dateString = sdf.format(date);
    fileName = "[" + reportName + "]_[" + patName + "]_[" + dateString + "].pdf";
    return fileName;
  }
  // add #10616 選択患者分の帳票が出力されない 王永吉 end
  //add #9616 帳票印刷失敗通知がされない 李 start
  @Override
  public void IntroductionLetterPrintPdfReport(Map<String, byte[]> patPdfFiles, String reportName, Long printerCd, String facilityCd)
  // mod 9608 紹介状印刷時に同時に出力される透析レポートについて　吉 end
    throws Exception {
    IntroductionLetterPrintPdfReport(patPdfFiles, reportName, printerCd, facilityCd, "");
  }
  //add #9616 帳票印刷失敗通知がされない 李 end

  //add  Aspose.cells plug-in integration  吉 start
  @Override
  // mod 9608 紹介状印刷時に同時に出力される透析レポートについて　吉 start
  // public void IntroductionLetterPrintPdfReport(Map<String, byte[]>patPdfFiles, String reportName, Long printerCd)
  //mod #9616 帳票印刷失敗通知がされない 李 start
  //public void IntroductionLetterPrintPdfReport(Map<String, byte[]>patPdfFiles, String reportName, Long printerCd, String facilityCd)
  public void IntroductionLetterPrintPdfReport(Map<String, byte[]> patPdfFiles, String reportName, Long printerCd, String facilityCd, String reportType)
  //mod #9616 帳票印刷失敗通知がされない 李 end
  // mod 9608 紹介状印刷時に同時に出力される透析レポートについて　吉 end
    throws Exception {
    // mod 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 start
    // del 9094 紹介状画面にて印刷を押下時、設定の中の印刷回数と不一致すべき 姜 start
//    LocalDate localDate = LocalDate.now();
//    Date date = new Date();
//    SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
//    String localDate = sdf.format(date);
    // del 9094 紹介状画面にて印刷を押下時、設定の中の印刷回数と不一致すべき 姜 end
    // mod 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 end
    for (Map.Entry<String,byte[]> entry : patPdfFiles.entrySet()) {
      Path pdfPath = null;
      try {
        byte[] pdfFileBytes = entry.getValue();
        // 生成するPDFの一時ファイルを生成
        pdfPath = tmpFileService.createTmpDirectoryAndFile(createTmpDir, "nkk-report", ".pdf");
        // mod 9094 紹介状画面にて印刷を押下時、設定の中の印刷回数と不一致すべき 姜 start
        // String fileName = reportName;
        String fileName = entry.getKey();
        // mod 9094 紹介状画面にて印刷を押下時、設定の中の印刷回数と不一致すべき 姜 end
        if (pdfFileBytes.length > 0) {
          // add 9094 紹介状画面にて印刷を押下時、設定の中の印刷回数と不一致すべき 姜 start
          if (fileName.indexOf("Dialysis") > -1) {
            fileName = "Dialysis";
          }
          Date date = new Date();
          // mod #9608 紹介状印刷時に同時に出力される透析レポートについて jiang start
          // SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
          SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmssSSS");
          // mod #9608 紹介状印刷時に同時に出力される透析レポートについて jiang end
          String localDate = sdf.format(date);
          // add 9094 紹介状画面にて印刷を押下時、設定の中の印刷回数と不一致すべき 姜 end

          // mod 9094 紹介状画面にて印刷を押下時、設定の中の印刷回数と不一致すべき 姜 start
          // fileName = "["+entry.getKey()+"]_["+localDate+"]"+").pdf";
          // mod 9608 紹介状印刷時に同時に出力される透析レポートについて　吉 start
          // fileName = "["+fileName+"]_["+localDate+"]"+").pdf";
          fileName = "["+fileName+"]_[" + facilityCd +"]_["+localDate+"]"+").pdf";
          // mod 9608 紹介状印刷時に同時に出力される透析レポートについて　吉 end
          // mod 9094 紹介状画面にて印刷を押下時、設定の中の印刷回数と不一致すべき 姜 end
          String destFilePath = "pdf/" + fileName;
          // 印刷用ファイルはローカルに保存する
          onPremiseService.writeBytesToFile(printTmpDir + "/" + destFilePath,pdfFileBytes);
          //mod #9616 帳票印刷失敗通知がされない 李 start
//              printerService.sendPrintRequest(printerCd, destFilePath);
          printerService.sendPrintRequest(printerCd, destFilePath, reportName, reportType);
          //mod #9616 帳票印刷失敗通知がされない 李 end
        }
      } finally {
        // 一時ファイルを削除
        Optional.ofNullable(pdfPath).ifPresent(path -> path.toFile().delete());
        Optional.ofNullable(pdfPath).ifPresent(path -> path.toFile().delete());
      }
    }
  }

  //mod #9616 帳票印刷失敗通知がされない 李 start
  @Override
  public void printPdfReportForMultiplePatient(List<Map<Long, List<byte[]>>> patPdfFiles, String reportName, Long printerCd) throws Exception {
    printPdfReportForMultiplePatient(patPdfFiles, reportName, printerCd, "");
  }
  //mod #9616 帳票印刷失敗通知がされない 李 end

  @Override
  //add #9616 帳票印刷失敗通知がされない 李 start
  //public void printPdfReportForMultiplePatient(List<Map<Long, List<byte[]>>> patPdfFiles, String reportName, Long printerCd) throws Exception {
  public void printPdfReportForMultiplePatient(List<Map<Long, List<byte[]>>> patPdfFiles, String reportName, Long printerCd, String reportType) throws Exception {
    //add #9616 帳票印刷失敗通知がされない 李 end
  LocalDate localDate = LocalDate.now();

  for (int i = 0; i < patPdfFiles.size(); i++) {
    for (Long key : patPdfFiles.get(i).keySet()) {
      List<byte[]> pdfFiles = patPdfFiles.get(i).get(key);
      for (int j = 0; j < pdfFiles.size(); j++) {
        Path pdfPath = null;
        try {
          byte[] pdfFileBytes = pdfFiles.get(j);
          // 生成するPDFの一時ファイルを生成
          pdfPath = tmpFileService.createTmpDirectoryAndFile(createTmpDir, "nkk-report", ".pdf");
          String fileName = getFileName(localDate,reportName);
          if (pdfFileBytes.length > 0) {
              // del #10616 選択患者分の帳票が出力されない 王永吉 start
              //fileName = fileName.replace(".pdf", "(" + (j + 1) + ").pdf");
              // del #10616 選択患者分の帳票が出力されない 王永吉 end
              String destFilePath = "pdf/" + fileName;
              // 印刷用ファイルはローカルに保存する
              onPremiseService.writeBytesToFile(printTmpDir + "/" + destFilePath,pdfFileBytes);
              //mod #9616 帳票印刷失敗通知がされない 李 start
//              printerService.sendPrintRequest(printerCd, destFilePath);
            printerService.sendPrintRequest(printerCd, destFilePath, reportName, reportType);
            //mod #9616 帳票印刷失敗通知がされない 李 end
          }
        } finally {
          // 一時ファイルを削除
          Optional.ofNullable(pdfPath).ifPresent(path -> path.toFile().delete());
          Optional.ofNullable(pdfPath).ifPresent(path -> path.toFile().delete());
        }
      }
    }
  }
}
  //add  Aspose.cells plug-in integration  吉 end

  // add 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
  @Override
  public void printPdfReportForReferralLetter(List<Map<Long, List<byte[]>>> patPdfFiles, String reportName, Long printerCd, String reportType) throws Exception {
    LocalDate localDate = LocalDate.now();

    for (int i = 0; i < patPdfFiles.size(); i++) {
      for (Long key : patPdfFiles.get(i).keySet()) {
        List<byte[]> pdfFiles = patPdfFiles.get(i).get(key);
        for (int j = 0; j < pdfFiles.size(); j++) {
          Path pdfPath = null;
          try {
            byte[] pdfFileBytes = pdfFiles.get(j);
            pdfPath = tmpFileService.createTmpDirectoryAndFile(createTmpDir, "nkk-report", ".pdf");
            String fileName = getFileName(localDate,reportName);
            if (pdfFileBytes.length > 0) {
              Date date = new Date();
              SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmssSSS");
              String destFilePath = "pdf/" + fileName;
              onPremiseService.writeBytesToFile(printTmpDir + "/" + destFilePath,pdfFileBytes);
              printerService.sendPrintRequest(printerCd, destFilePath, reportName, reportType);
            }
          } finally {
            // 一時ファイルを削除
            Optional.ofNullable(pdfPath).ifPresent(path -> path.toFile().delete());
            Optional.ofNullable(pdfPath).ifPresent(path -> path.toFile().delete());
          }
        }
      }
    }
  }
  // add 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end

    private String getFileNameByPatName(LocalDate localDate,String patName, String reportName) {
        String fileName = "";
        // mod 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 start
//        int month = localDate.getMonthValue();
//        int dayOfMonth = localDate.getDayOfMonth();
//        int year = localDate.getYear();
//        String time = String.valueOf(new Date().getTime());
//        String dateString = String.valueOf(year) + String.valueOf(month) + String.valueOf(dayOfMonth)+time;
        Date date = new Date();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
        String dateString = sdf.format(date);
        // mod 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 end
        fileName = "[" + reportName + "]_[" + patName + "]_[" + dateString + "].pdf";
        return fileName;
    }
    /* add by shiyinwang 2022-11-30 -- Aspose.cells plug-in integration --start */

    private String getFileName(LocalDate localDate, String reportName) {
      String fileName = "";
      Date date = new Date();
      // mod #10616 選択患者分の帳票が出力されない 王永吉 start
      //SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
      SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmssSSS");
      // mod #10616 選択患者分の帳票が出力されない 王永吉 end
      String dateString = sdf.format(date);
      fileName = "[" + reportName + "]_[" +  dateString + "].pdf";
      return fileName;
  }
	/**
	 *
	 * {@inheritDoc}
	 */
	@Override
  //mod 帳票印刷の命名規則が変更されました 吉 start
//	public void printReportMultiPat(String html, Long printerCd) throws Exception {
  public void printReportMultiPat(String html, Long printerCd,String reportName) throws Exception {
    //mod 帳票印刷の命名規則が変更されました 吉 end
		Path htmlPath = null;
		Path pdfPath = null;
		try {
			// HTMLデータを一時ファイルに保存
		    htmlPath = tmpFileService.createTmpDirectoryAndFile(createTmpDir, "nkk-report", ".html");
			Files.write(htmlPath, html.getBytes(StandardCharsets.UTF_8));

			// 生成するPDFの一時ファイルを生成
			pdfPath = tmpFileService.createTmpDirectoryAndFile(createTmpDir, "nkk-report", ".pdf");
			String[] command = { "wkhtmltopdf", htmlPath.toString(), pdfPath.toString() };

			Runtime rt = Runtime.getRuntime();
			int runCmd = rt.exec(command).waitFor();
			if (runCmd == 0) {
        // del 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 start
//				LocalDate localDate = LocalDate.now();
//				int month = localDate.getMonthValue();
//				int dayOfMonth = localDate.getDayOfMonth();
//				int year = localDate.getYear();
        // del 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 end
        //mod 帳票印刷の命名規則が変更されました 吉 start
//        String dateString = String.valueOf(year) + String.valueOf(month) + String.valueOf(dayOfMonth);
        // del 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 start
//        String time = String.valueOf(new Date().getTime());
//        String dateString = String.valueOf(year) + String.valueOf(month) + String.valueOf(dayOfMonth)+time;
        // del 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 end
        //mod 帳票印刷の命名規則が変更されました 吉 end
        // add 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 start
        Date date = new Date();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMddHHmmss");
        String dateString = sdf.format(date);
        // add 5776 ファイル出力した時のファイル名にある処理日時のフォーマットが正しくない 姜 end
        //mod 帳票印刷の命名規則が変更されました 吉 start
//				String fileName = "帳票_[" + dateString + "].pdf";
        String fileName = "[" + reportName + "]"+"_[" + dateString + "].pdf";
        //mod 帳票印刷の命名規則が変更されました 吉 end
				String destFilePath = "pdf/" + fileName;

				// 印刷用ファイルはローカルに保存する
                onPremiseService.putFile(printTmpDir, destFilePath, pdfPath);

				printerService.sendPrintRequest(printerCd, destFilePath);
			} else {
				return;
			}
		} finally {
			// 一時ファイルを削除
			Optional.ofNullable(htmlPath).ifPresent(path -> path.toFile().delete());
			Optional.ofNullable(pdfPath).ifPresent(path -> path.toFile().delete());
		}
	}

  /*add FNSI-改修内容装置帳票の対応 任 start*/
	@Override
  public Long getReportCd(ReportMenuSortContainer reportMenu) throws Exception {
    List<Long> reportCdList = new ArrayList<>();
    for(int i = 0;i<reportMenu.getMachines().size();i++) {
      String date = "";
      if (reportMenu.getSpecifyDate() != null) {
        date = reportMenu.getSpecifyDate();
      } else {
        String fromDate = reportMenu.getFromDate();
        String toDate = reportMenu.getToDate();
        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
        Calendar cal = Calendar.getInstance();
        cal.setTime(sdf.parse(fromDate));
        long time1 = cal.getTimeInMillis();
        cal.setTime(sdf.parse(toDate));
        long time2 = cal.getTimeInMillis();
        long between_days = (time2 - time1) / (1000 * 3600 * 24);
        for (int j = 0; j < between_days; j++) {
          Calendar calendar = new GregorianCalendar();
          calendar.setTime(sdf.parse(reportMenu.getFromDate()));
          calendar.add(calendar.DATE, j);
          date = sdf.format(calendar.getTime());
        }
      }
      if (reportMenu.getReportCd() == null) {
        reportCdList = getReportCdList(reportMenu, i, date,null);
       // add #6426 2022-01-12 定期点検の帳票がシステムエラーとなる。 孟堅　start
      }else  if (
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        // reportMenu.getReportCd() == -4L
        reportMenu.getReportCd() == CoreConstant.FixedReportCd.DAILY_INSPECT_RECORD_BOOK
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      ) {
        reportCdList = getReportCdList(reportMenu, i, date,"1");
      }else if (
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        // reportMenu.getReportCd() == -5L
        reportMenu.getReportCd() == CoreConstant.FixedReportCd.PERIODIC_INSPECT_RECORD_BOOK
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      ) {
        reportCdList = getReportCdList(reportMenu, i ,date,"2");
      }
      // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe start
      else if(reportMenu.getReportCd() == CoreConstant.FixedReportCd.WATER_SURVEY_RECORD_BOOK){
        reportCdList = getReportCdList(reportMenu, i, date, "3");
      }
      // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe end
      else  if (
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        //reportMenu.getReportCd() == -2L || reportMenu.getReportCd() == -3L
        reportMenu.getReportCd() ==CoreConstant.FixedReportCd.DIALYSIS_REPORT
          || reportMenu.getReportCd() == CoreConstant.FixedReportCd.DIALYSIS_REPORT_HANDWRITTEN
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      ) {
        List<OrdMain> getOrdIdList = getOrdIdList(reportMenu);
        if(getOrdIdList != null && getOrdIdList.size() > 0){
          for (int ordNo = 0 ; ordNo < getOrdIdList.size(); ordNo++){
            reportCdList.add(getTemplateReportCd(reportMenu.getFacilityCd(),getOrdIdList.get(ordNo).getOrdNo(),reportMenu.getReportCd()));
          }
        };
      }
      //　add #6426 2022-01-12 定期点検の帳票がシステムエラーとなる。 孟堅 end
      if(reportCdList.size()>0){
        break;
      }
    }
    // add #6426 2022-01-12 定期点検の帳票がシステムエラーとなる。#　孟堅 start
    if(reportCdList.size() > 0){
      // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
      // if (reportMenu.getReportCd() == -4L || reportMenu.getReportCd() == -5L || reportMenu.getReportCd() == -2l || reportMenu.getReportCd() ==-3l)
      if(reportServiceImpl.isFixedReport(reportMenu.getReportCd()))
      // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      {
        List<Long> devicePrintCdList = new ArrayList<>();
        reportCdList.stream().forEach(el -> {
          long printCd = mstReportDao.selectPrintCd(el);
          devicePrintCdList.add(printCd);
        });
        if (devicePrintCdList.size() > 0) {
         long printCd = devicePrintCdList.get(0);
         for (int i = 0; i < devicePrintCdList.size() ; i++){
           if (devicePrintCdList.get(i) != printCd){
                return  null;
           }
         }
          return printCd;
        }else{
          return null;
        }
      }else{
        // add #6426 2022-01-12 定期点検の帳票がシステムエラーとなる。　孟堅 end
        return mstReportDao.selectPrintCd(reportCdList.get(0));
      }
    }else{
      return null;
    }
  }
  // add #6426 2022-01-12 定期点検の帳票がシステムエラーとなる。　孟堅　start
  public List<OrdMain> getOrdIdList(ReportMenuSortContainer reportMenu){
    List<OrdMain> patOrdNo = getOrdNoListSorted(reportMenu);
    if(null != patOrdNo && patOrdNo.size()>0){
      for(int i=patOrdNo.size();i>0 ;i--){
        if(patOrdNo.get(i-1).getOrdNo() == 0){
          patOrdNo.remove(i-1);
        }
      }
    }
    return patOrdNo;
  }
  //　add  #6426 2022-01-12 定期点検の帳票がシステムエラーとなる。　孟堅 end
  //mod 6502 装置帳票：定期・日常が分離されていない 吉 start
//  private List<Long> getReportCdList(ReportMenuSortContainer reportMenu,int i,String date){
  private List<Long> getReportCdList(ReportMenuSortContainer reportMenu,int i,String date,String flag){
    //mod 6502 装置帳票：定期・日常が分離されていない 吉 end
    List<Map<String, String>> sortConditions = reportMenu.getSortCondition();
    String firstName = null;
    String firstOrd = "asc";
    String secondName = null;
    String secondOrd = "asc";
    String thirdName = null;
    String thirdOrd = "asc";
    for (int index = sortConditions.size()-1; index >= 0; index--) {
      Map<String, String> item = sortConditions.get(index);
      int key = sortConditions.indexOf(item);
      String sortId = "";
      if(index == sortConditions.size()-1){
        sortId = checkSortId(item);
        if (!sortId.equals("")) {
          firstName = sortId;
          firstOrd = item.get(sortId);
        } else {
          firstName = null;
        }
      }else if(index == sortConditions.size()-2){
        sortId = checkSortId(item);
        if (!sortId.equals("")) {
          secondName = sortId;
          secondOrd = item.get(sortId);
        } else {
          secondName = null;
        }
      }else{
        sortId = checkSortId(item);
        if (!sortId.equals("")) {
          thirdName = sortId;
          thirdOrd = item.get(sortId);
        } else {
          thirdName = null;
        }
      }
    }
    //mod 6502 装置帳票：定期・日常が分離されていない 吉 start
//    List<Long> reportCdList = devMenteMainDao.selectLayoutCd(reportMenu.getMachines().get(i).getMachineNo(),date,firstName,firstOrd,secondName,secondOrd,thirdName,thirdOrd);
//    return reportCdList;
    if(null == flag){
      List<Long> reportCdList = devMenteMainDao.selectLayoutCd(reportMenu.getMachines().get(i).getMachineNo(),date,firstName,firstOrd,secondName,secondOrd,thirdName,thirdOrd);
      return reportCdList;
    }else{
      List<Long> reportCdList = new ArrayList<>();
      if(flag == "1"){
        reportCdList = devMenteMainDao.selectReportCdByMainteClass(Long.valueOf(reportMenu.getMachines().get(i).getMachineNo().toString()),date,reportMenu.getFacilityCd(),"1");
      }else{
        reportCdList = devMenteMainDao.selectReportCdByMainteClass2(Long.valueOf(reportMenu.getMachines().get(i).getMachineNo().toString()),date,reportMenu.getFacilityCd(),"2");
      }
      return reportCdList;
    }
    //mod 6502 装置帳票：定期・日常が分離されていない 吉 end
  }
  /*add FNSI-改修内容装置帳票の対応 任 end*/

  // add FNSI-印刷失敗時の通知を追加 江 start
  @Override
  public void registerNotification(String facilityCd, String reportType, String reportName) throws Exception {
    SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
    JSONObject replaceData = new JSONObject();
    replaceData.put("REPORTTYPE", reportType);
    replaceData.put("REPORTNAME", reportName);
    replaceData.put("UP_DATE", sdf.format(new Date()));
    webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.PRINT_FAIL, facilityCd, replaceData);
  }
  // add FNSI-印刷失敗時の通知を追加 江 end

  //add ２次元帳票週間薬剤集計表対応   吉 start
  @Override
  public String[] getStartAndEndDayByDate(String yyyyMMdd) throws ParseException {
    String[] dateZone = new String[3];
    Calendar cal = getCalendarByDateStr(yyyyMMdd);
    int year = Integer.parseInt(yyyyMMdd.substring(0, 4));
    Function<Integer, String> add0 = (i -> i < 10 ? "0" + i : String.valueOf(i));//补0
    dateZone[0] = cal.get(Calendar.YEAR) + "-" + add0.apply(cal.get(Calendar.MONTH) + 1) + "-" + add0.apply(cal.get(Calendar.DAY_OF_MONTH));
    if (cal.get(Calendar.YEAR) < year) dateZone[0] = year + "-01-01";
    cal.add(Calendar.DATE, 6);
    dateZone[1] = cal.get(Calendar.YEAR) + "-" + add0.apply(cal.get(Calendar.MONTH) + 1) + "-" + add0.apply(cal.get(Calendar.DAY_OF_MONTH));
    if (cal.get(Calendar.YEAR) > year) dateZone[1] = year + "-12-31";
    dateZone[2] = String.valueOf(cal.get(Calendar.WEEK_OF_YEAR));
    return dateZone;
  }
  private static Calendar getCalendarByDateStr(String yyyyMMdd) throws ParseException {
    SimpleDateFormat sm = new SimpleDateFormat("yyyy-MM-dd");
    Date d = sm.parse(yyyyMMdd);
    Calendar cal = Calendar.getInstance();
    cal.setTime(d);
    int dayWeek = cal.get(Calendar.DAY_OF_WEEK);
    if (1 == dayWeek) cal.add(Calendar.DAY_OF_MONTH, -1);
    cal.setFirstDayOfWeek(Calendar.MONDAY);
    int day = cal.get(Calendar.DAY_OF_WEEK);
    cal.add(Calendar.DATE, cal.getFirstDayOfWeek()-day);
    return cal;
  }
  //add ２次元帳票週間薬剤集計表対応   吉 end
  //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 start
  @Override
  public List<Long> getPatIdByPayLoad(ReportMenuSortContainer reportMenu) {
    List<Long> patIdList = new ArrayList<>();

    // 開始日,終了日の設定
    String fromDate= "";
    String toDate="";
    if(null != reportMenu.getSpecifyDate()){
      fromDate=reportMenu.getSpecifyDate();
      toDate=reportMenu.getSpecifyDate();
    }else{
      fromDate=reportMenu.getFromDate();
      toDate=reportMenu.getToDate();
    }

    // 日付のフォーマット設定
    SimpleDateFormat treatDateFormat = new SimpleDateFormat("yyyyMMdd");
    SimpleDateFormat fromDateFormat  = new SimpleDateFormat("yyyy/MM/dd 00:00:00");
    SimpleDateFormat toDateFormat    = new SimpleDateFormat("yyyy/MM/dd 23:59:59");

    if(reportMenu.getDateKind().equals("dialysis_date")){ // 基準日が治療日の場合

      String rstDialysisStateFlag = "";
      // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
      // if(reportMenu.getReportCd() == -3)
      if(reportMenu.getReportCd() == CoreConstant.FixedReportCd.DIALYSIS_REPORT)
      // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      { // 治療経過表
        rstDialysisStateFlag = "1"; // 実績を検索するフラグ
      }
      else { // 治療経過表以外
        rstDialysisStateFlag = "2"; // 予定を検索するフラグ
      }
      patIdList = reportMenuDao.selectByDialysisState(
        reportMenu.getFacilityCd(),
        reportMenu.getPatIds(),
        fromDate,
        toDate,
        rstDialysisStateFlag
      );

    }
    // mod #11226 患者情報系historyの取得条件見直し② limingzhe start
    //else { // 基準日が検査日の場合
    else if(reportMenu.getDateKind().equals("exam_date")){  // 基準日が検査日の場合
    // mod #11226 患者情報系historyの取得条件見直し② limingzhe end
      try {
        String examFromDate = fromDateFormat.format(treatDateFormat.parse(fromDate));
        String examToDate = toDateFormat.format(treatDateFormat.parse(toDate));
        // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
        //if (reportMenu.getReportClass() == 2 || reportMenu.getReportClass() == 3 || reportMenu.getReportClass() == 10 || reportMenu.getReportClass() == 11) {
        if (reportMenu.getReportClass() == 2 || reportMenu.getReportClass() == 3 || reportMenu.getReportClass() == 9 || reportMenu.getReportClass() == 10 || reportMenu.getReportClass() == 11) {
        // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
          // 単患者帳票、複数患者帳票、単集計、複数集計
          String examStatusFlag = "2"; // 予定+実績を検索するフラグ
          patIdList = reportMenuDao.selectByExamStatus(
            reportMenu.getFacilityCd(),
            reportMenu.getPatIds(),
            examFromDate,
            examToDate,
            examStatusFlag
          );
        } else if (reportMenu.getReportClass() == 8) {
          // ラベル
          String examStatusFlag = "1"; // 予定を検索するフラグ
          patIdList = reportMenuDao.selectByExamStatus(
            reportMenu.getFacilityCd(),
            reportMenu.getPatIds(),
            examFromDate,
            examToDate,
            examStatusFlag
          );
        } else {
          String rstDialysisStateFlag = "";
          // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
          // if(reportMenu.getReportCd() == -3)
          if(reportMenu.getReportCd() == CoreConstant.FixedReportCd.DIALYSIS_REPORT)
          // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
          { // 治療経過表
            rstDialysisStateFlag = "1"; // 実績を検索するフラグ
          }
          else { // 治療経過表以外
            rstDialysisStateFlag = "2"; // 予定+実績を検索するフラグ
          }
          String examStatusFlag = "";
          if(reportMenu.getReportClass() == 4 || reportMenu.getReportClass() == 5 || reportMenu.getReportClass() == 6){ // 準備リスト、配布リスト2種
            examStatusFlag = "1"; // 予定を検索するフラグ
          }
          else { // 治療経過表以外
            examStatusFlag = "2"; // 予定+実績を検索するフラグ
          }
          patIdList = reportMenuDao.selectByDialysisStateAndExam(
            reportMenu.getFacilityCd(),
            reportMenu.getPatIds(),
            fromDate,
            toDate,
            rstDialysisStateFlag,
            examFromDate,
            examToDate,
            examStatusFlag
          );
        }
      } catch (ParseException e) {
        // TODO 自動生成された catch ブロック
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
        EventLogMessage eventLogMessage = new EventLogMessage();
        eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
        if (reportMenu != null && reportMenu.getFacilityCd() != null) {
          eventLogMessage.setFacilityCd(reportMenu.getFacilityCd());
        }
        logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
      }
    // add #11226 患者情報系historyの取得条件見直し② limingzhe start
    } else if (reportMenu.getDateKind().equals("issue_date")) {  // 基準日が処方日の場合
      // 1:予定・実績・処方未交付・交付済み 2:実績・交付済み 3: 予定・実績関係なし・処方未交付・交付済み
      String issueStatusFlag = "1";
      if(reportMenu.getReportClass() == 1 &&
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        // reportMenu.getReportCd() == -3
        reportMenu.getReportCd() == CoreConstant.FixedReportCd.DIALYSIS_REPORT
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      ) {
        issueStatusFlag = "2";
      } else if(reportMenu.getReportClass() == 2 || reportMenu.getReportClass() == 3
             || reportMenu.getReportClass() == 10 || reportMenu.getReportClass() == 11
             || reportMenu.getReportClass() == 8 || reportMenu.getReportClass() == 9) {
        // 単患者帳票、複数患者帳票、単集計、複数集計、ラベル、紹介状
        issueStatusFlag = "3";
      }
      // mod #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
//      patIdList = reportMenuDao.selectByIssueStatus(
//        reportMenu.getFacilityCd(),
//        reportMenu.getPatIds(),
//        fromDate,
//        toDate,
//        issueStatusFlag
//      );
      List<String> prescriptionClassList = reportMenu.getPrescriptionClassList();
      patIdList = reportMenuDao.selectByIssueStatus(
        reportMenu.getFacilityCd(),
        reportMenu.getPatIds(),
        fromDate,
        toDate,
        issueStatusFlag,
        prescriptionClassList
      );
      // mod #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end
    // add #11226 患者情報系historyの取得条件見直し② limingzhe end
    } else if (reportMenu.getDateKind().equals("letter_issue_date")) {  // 基準日が紹介日の場合

      // "":予定・実績あり関係なし  単患者帳票、複数患者帳票、ラベル、紹介状、単集計、複数集計
      // "1":治療実績ありを検索     治療経過表
      // "2":治療予定ありを検索     治療経過表(手書き)、準備リスト・配布リストベッド・物品
      String rstDialysisStateFlag = "";
      if (reportMenu.getReportClass() == 1 &&
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        // reportMenu.getReportCd() == -3
        reportMenu.getReportCd() == CoreConstant.FixedReportCd.DIALYSIS_REPORT
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      ) {
      	// 治療経過表
        rstDialysisStateFlag = "1";
      } else if (reportMenu.getReportClass() == 1 || reportMenu.getReportClass() == 4
             || reportMenu.getReportClass() == 5 || reportMenu.getReportClass() == 6) {
        rstDialysisStateFlag = "2";
      }

      // 指定日の紹介日の紹介状データをもつ患者ID取得
      List<String> letterCategoryList = reportMenu.getLetterCategoryList();
      patIdList = reportMenuDao.selectByLetterIssueDate(
        reportMenu.getFacilityCd(),
        reportMenu.getPatIds(),
        fromDate,
        toDate,
        rstDialysisStateFlag,
        letterCategoryList
      );

    } else {  // 基準日がすべての場合

      // 単患者帳票、複数患者帳票、ラベル、紹介状、単集計、複数集計 -> 全患者IDを返却
      // "1":治療実績ありを検索     治療経過表
      // "2":治療予定ありを検索     治療経過表(手書き)、準備リスト・配布リストベッド・物品
      String rstDialysisStateFlag = "";
      if (reportMenu.getReportClass() == 1 &&
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        // reportMenu.getReportCd() == -3
        reportMenu.getReportCd() == CoreConstant.FixedReportCd.DIALYSIS_REPORT
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      ) {
        // 治療経過表
        rstDialysisStateFlag = "1";
      } else if (reportMenu.getReportClass() == 1 || reportMenu.getReportClass() == 4
             || reportMenu.getReportClass() == 5 || reportMenu.getReportClass() == 6) {
        rstDialysisStateFlag = "2";
      } else {
        // 全患者IDを返却
        return  reportMenu.getPatIds();
      }

      // 指定日の治療実績or治療予定ありのデータをもつ患者ID取得
      patIdList = reportMenuDao.selectByDialysisState(
        reportMenu.getFacilityCd(),
        reportMenu.getPatIds(),
        fromDate,
        toDate,
        rstDialysisStateFlag
      );

    }
    return patIdList;
  }
  //add 4748 5269 5402治療方法ごとの治療経過表での出力ができない  吉 end
  //add 5565 並び替えを実施してもその情報が保持されない 吉 start
  /* add yuqinlong  2023-02-02 [Transaction]  */
  @Transactional
  @Override
  public int saveSortList(MstReport payload) {
    Long reportCd = payload.getReportCd();
    int resultCount = 0;
    JSONObject jsonObject = new JSONObject(payload.getReportSetting());
    /* 帳票マスタ管理外：治療経過表、治療経過表（手書き）の場合 */
    // mod #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　start
    // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
    // if (reportCd == -2 || reportCd == -3 || reportCd == -4 || reportCd == -5)
    if(reportServiceImpl.isFixedReport(reportCd))
    // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
    {
      // mod #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　end
      MstFacilitySetting mstFacilitySetting = new MstFacilitySetting();
      // 施設設定番号
      // mod #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　start
//      String facilitySettingNo = reportCd == -3 ? "3117" : "3118";
      // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
//      String facilitySettingNo = "";
//      if(reportCd == -3) {
//        facilitySettingNo = "3117";
//      } else if(reportCd == -2) {
//        facilitySettingNo = "3118";
//      } else if(reportCd == -4) {
//        facilitySettingNo = "3119";
//      } else if(reportCd == -5) {
//        facilitySettingNo = "3120";
//      }
      String facilitySettingNo = reportServiceImpl.getFacilitySettingNoForFixedReportSort(reportCd);
      // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      // mod #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　end
      mstFacilitySetting.setFacilitySettingNo(facilitySettingNo);
      // 施設コード
      mstFacilitySetting.setFacilityCd(payload.getFacilityCd());
      // 値
      mstFacilitySetting.setValue(jsonObject.toString());
      // 登録日時
      java.sql.Timestamp sysDate = new java.sql.Timestamp(System.currentTimeMillis());
      mstFacilitySetting.setRegDate(sysDate);
      // 更新日時
      mstFacilitySetting.setUpDate(sysDate);
      // 治療経過表、治療経過表（手書き）の場合、施設設定マスタへ登録 or 更新
      resultCount = mstFacilitySettingDao.update(mstFacilitySetting);
      if(resultCount == 0 ) {
          resultCount = mstFacilitySettingDao.insert(mstFacilitySetting);
      }
      return resultCount;
    /* 帳票マスタ管理外：日常点検記録簿、定期点検（記録簿・交換部品記録簿）の場合、何もせずに正常終了 */
      // del #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　start
//    } else if(reportCd == -4 || reportCd == -5) {
//      return resultCount;
      // del #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　end
    /* 帳票マスタ管理対象の場合、データ抽出条件を更新 */
    } else {
      resultCount = reportMenuDao.updateSortList(payload.getReportCd(), jsonObject.toString());
      return resultCount;
    }
  }

  @Override
  public MstReport getSortList(String facilityCd, Long reportCd) {
    MstReport mr = new MstReport();
    FacilitySettingInfo info= new FacilitySettingInfo();
    // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
//    if(reportCd == -3){
//      info = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, "3117");
//    }else if(reportCd == -2){
//      info = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, "3118");
//    }else if(reportCd == -4){
//      info = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, "3119");
//    }else if(reportCd == -5){
//      info = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, "3120");
//    }
    if(reportServiceImpl.isFixedReport(reportCd)){
      String facilitySettingNo = reportServiceImpl.getFacilitySettingNoForFixedReportSort(reportCd);
      info = mstFacilitySettingDao.getBySettingNoAndCd(facilityCd, facilitySettingNo);
    }
    // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
    else{
      mr =mstReportDao.selectByCd(reportCd);
      return mr;
    }
    // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　start
    if(info != null) {
      JSONObject jsonObject = null;
      try {
        jsonObject = new JSONObject(info.getValue());
        mr.setReportSetting(jsonObject.toString());
      } catch (Exception e) {
        // JSONではない場合、空白を設定する。
        mr.setReportSetting("{}");
      }
    }
    // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　end

    // del #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　start
//    // mod 7963 帳票印刷順の初期設定がされていない 鄭爽 start
//    // String val = info.getValue();
//    String val = "[]";
//    if (null != info) {
//      val = info.getValue();
//    }
//    if ("[]".equals(val)) {
//      if(reportCd == -3){
//        val = "[\"pat_id_asc\",\"dialysis_day_asc\"]";
//      }else if(reportCd == -2){
//        val = "[\"pat_id_asc\"]";
//      }else if(reportCd == -4){
//        val = "[\"machine_type_asc\",\"machine_name_asc\"]";
//      }else if(reportCd == -5){
//        val = "[\"machine_type_asc\",\"machine_name_asc\"]";
//      }
//    }
//    // mod 7963 帳票印刷順の初期設定がされていない 鄭爽 end
//    if(null != val){
//      Map<String,String> softMap = new HashMap<>();
//      softMap.put("dialysis_day",ReportMenu.DIALYSIS_DAY);
//      softMap.put("pat_id",ReportMenu.PATIENT_ID);
//      softMap.put("rst_in_out_class",ReportMenu.ENTRANCE_EXIT_CLASSIFICATION);
//      softMap.put("dialysis_room_group",ReportMenu.DIALYSIS_ROOM_GROUP);
//      softMap.put("room_bed_group",ReportMenu.ROOM_BED_GROUP);
//      softMap.put("bed_name",ReportMenu.BED_NAME);
//      softMap.put("ind_kur_cd",ReportMenu.PATIENT_COOL);
//      softMap.put("machine_name",ReportMenu.MACHINE_NAME);
//      softMap.put("machine_no",ReportMenu.MACHINE_NO);
//      softMap.put("machine_serial",ReportMenu.MACHINE_SERIAL);
//      softMap.put("machine_type",ReportMenu.MACHINE_TYPE);
//      // add 9036 【IES起票】帳票画面_並び替え表示不正　吉 start
//      softMap.put("bed_cd",ReportMenu.BED_CD);
//      // add 9036 【IES起票】帳票画面_並び替え表示不正　吉 end
//      String key1="";
//      String value1="";
//      String key2="";
//      String value2="";
//      String key3="";
//      String value3="";
//
//      String keyVal1 = "";
//      String keyVal2 = "";
//      String keyVal3 = "";
//
//      JSONArray newjsonObj = new JSONArray();
//      Map<String,Object>map = new HashMap<>();
//      String [] arr = val.split(",");
//      if(arr.length==1){
//        Map<String,Object>map1 = new HashMap<>();
//        keyVal1 = arr[0];
//        // mod 7963 帳票印刷順の初期設定がされていない 鄭爽 start
//        // key1 = keyVal1.substring(3,keyVal1.lastIndexOf("_"));
//        key1 = keyVal1.substring(2,keyVal1.lastIndexOf("_"));
//        // mod 7963 帳票印刷順の初期設定がされていない 鄭爽 end
//        value1 = keyVal1.substring(keyVal1.lastIndexOf("_")+1,keyVal1.length()-2);
//        map1.put("key",softMap.get(key1));
//        map1.put("sort",value1);
//        JSONArray jsonArray = new JSONArray();
//        jsonArray.put(map1);
//        map.put("softList",jsonArray);
//        newjsonObj.put(map);
//      }
//      if(arr.length==2){
//        Map<String,Object>map1 = new HashMap<>();
//        keyVal1 = arr[0];
//        key1 = keyVal1.substring(2,keyVal1.lastIndexOf("_"));
//        value1 = keyVal1.substring(keyVal1.lastIndexOf("_")+1,keyVal1.length()-1);
//        map1.put("key",softMap.get(key1));
//        map1.put("sort",value1);
//        JSONArray jsonArray = new JSONArray();
//        jsonArray.put(map1);
//        keyVal2 = arr[1];
//        key2 = keyVal2.substring(1,keyVal2.lastIndexOf("_"));
//        value2 = keyVal2.substring(keyVal2.lastIndexOf("_")+1,keyVal2.length()-2);
//        map1 = new HashMap<>();
//        map1.put("key",softMap.get(key2));
//        map1.put("sort",value2);
//        jsonArray.put(map1);
//        map.put("softList",jsonArray);
//        newjsonObj.put(map);
//      }
//      if(arr.length==3){
//        Map<String,Object>map1 = new HashMap<>();
//        keyVal1 = arr[0];
//        key1 = keyVal1.substring(2,keyVal1.lastIndexOf("_"));
//        value1 = keyVal1.substring(keyVal1.lastIndexOf("_")+1,keyVal1.length()-1);
//        map1.put("key",softMap.get(key1));
//        map1.put("sort",value1);
//        JSONArray jsonArray = new JSONArray();
//        jsonArray.put(map1);
//        keyVal2 = arr[1];
//        key2 = keyVal2.substring(1,keyVal2.lastIndexOf("_"));
//        value2 = keyVal2.substring(keyVal2.lastIndexOf("_")+1,keyVal2.length()-1);
//        map1 = new HashMap<>();
//        map1.put("key",softMap.get(key2));
//        map1.put("sort",value2);
//        jsonArray.put(map1);
//        keyVal3 = arr[2];
//        key3 = keyVal3.substring(1,keyVal3.lastIndexOf("_"));
//        value3 = keyVal3.substring(keyVal3.lastIndexOf("_")+1,keyVal3.length()-2);
//        map1 = new HashMap<>();
//        map1.put("key",softMap.get(key3));
//        map1.put("sort",value3);
//        jsonArray.put(map1);
//        map.put("softList",jsonArray);
//        newjsonObj.put(map);
//      }
//      mr.setReportSetting(newjsonObj.toString());
//      return mr;
//    }
    // del #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　end
    return mr;
  }
  //add 5565 並び替えを実施してもその情報が保持されない 吉 end
  // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
  public Map<String,List> searchMap (String facilityCd){
    Map<String,List>map= new HashMap<>();
    // ダイアライザマスタ
    List<MstDialyzer> dialyzerList = mstInfoService.findMstDialyzerAllByFacillityCd(facilityCd);
    if(null != dialyzerList && dialyzerList.size()>0){
      List<Integer>list =new ArrayList<>();
      for(MstDialyzer dl : dialyzerList){
        list.add(dl.getDialyzerCd());
      }
      map.put(ReportConstant.ReportDataKey.DIALYZER_IDS,list);
    }else{
      map.put(ReportConstant.ReportDataKey.DIALYZER_IDS,new ArrayList());
    }
    // 医療材料分類
    MstEquipmentClass params = new MstEquipmentClass();
    params.setFacilityCd(facilityCd);
    List<MstEquipmentClass> mstEquipmentClassList = mstEquipmentClassDao.selectAll(SelectOptions.get(), params);
    if(null != mstEquipmentClassList && mstEquipmentClassList.size()>0){
      List<Integer>list =new ArrayList<>();
      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
      list.add(-1);
      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
      for(MstEquipmentClass mec : mstEquipmentClassList){
        list.add(mec.getClassCd());
      }
      // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
      // map.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,mstEquipmentClassList);
      map.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,list);
      // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
    }else{
      map.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,new ArrayList());
    }

    // 薬剤分類
    MstMedicineClass medicineClass = new MstMedicineClass();
    medicineClass.setFacilityCd(facilityCd);
    List<MstMedicineClass> mstMedicineClassList = mstMedicineClassDao.selectAll(SelectOptions.get(),medicineClass);
    if(null != mstEquipmentClassList && mstEquipmentClassList.size()>0){
      List<Integer>list =new ArrayList<>();
      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
      list.add(-1);
      // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
      for(MstMedicineClass mdc : mstMedicineClassList){
        list.add(mdc.getClassCd());
      }
      // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start
      // map.put(ReportConstant.ReportDataKey.MEDICINE_IDS,mstMedicineClassList);
      map.put(ReportConstant.ReportDataKey.MEDICINE_IDS,list);
      // mod 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 end
    }else{
      map.put(ReportConstant.ReportDataKey.MEDICINE_IDS,new ArrayList());
    }
    return map;
  }
  // add 7841 帳票（複数患者）：帳票メニューのフィルタ機能が反映していない 吉 start

  /**
   * 帳票定義XMLを取得します.
   *
   * @param mstReport 帳票マスタEntity
   * @param reportZipFile 帳票Zipファイル
   * @return 帳票定義XML
   */
  private String getReportXml(MstReport mstReport, ReportZipFile reportZipFile) {
    // 帳票定義XMLファイルを取得する
    String reportXml = reportZipFile.getFileToString(mstReport.getReportPath().getXmlFilename());
    if (org.springframework.util.StringUtils.isEmpty(reportXml)) {
      List<String> fileList = reportZipFile.getFileToString();
      throw new NtssException("帳票定義XMLファイルを取得できません。"
        + "MstReport:[" + mstReport.getReportPath().getXmlFilename() + "]"
        + " ReportZipFile:[" + fileList.toString() + "]"
      );
    }
    return reportXml;
  }

  /**
   * BaseEntity の Daoインタフェース(並び替え処理用).
   */
  @Autowired
  private BaseEntityDao baseEntityDao;

  @Autowired
  @DefaultDb
  private Config defaultDbConfig;
  // TODO ■■
  /**
   * データセット（mongoDB）のインタフェース (並び替え処理用).
   */
  @Autowired(required = false)
  private MongoTemplate mongoTemplate;

  /**
   *
   * {@inheritDoc}
   */
  @Override
  public List<Map<Long, byte[]>> getReportExcelFilesForOnePatient(ReportMenuSortContainer reportMenu, String userName) throws Exception {

    Long reportCd = reportMenu.getReportCd();
    List<Long> patIdList = reportMenu.getPatIds();
    Map<Long, List<Long>> patIdOrdList = new HashMap<>();
    // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　start
    Map<Long, List<String>> patIdPreDateMap = new HashMap<>();
    // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　end

    // 期間指定、1日指定に応じて、開始日、終了日を格納
    LocalDateTime localDateFrom = null;
    LocalDateTime localDateTo = null;
    if (reportMenu.getSpecifyDate() == null) {
      // 期間指定
      localDateFrom = LocalDate.parse(reportMenu.getFromDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
      localDateTo = LocalDate.parse(reportMenu.getToDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
      localDateTo = localDateTo.plusDays(1L).minusNanos(1000);
    } else {
      // 1日指定
      localDateFrom = LocalDate.parse(reportMenu.getSpecifyDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
      localDateTo = localDateFrom.plusDays(1L).minusNanos(1000);
    }
    //add #9323 donghao start
    List<OrdMain> ordList = new ArrayList<>();
    List<Long> ordNos = new ArrayList<>();
    List<PatExamMain> examMainList = new ArrayList<>();
    Map<String,PatExamMain> newExamMainList = new HashMap<>();
    Map<String, List<String>> treatDateStr = new HashMap<>();
    // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　start
    List<String> patIdPreDateList = new ArrayList<>();
    // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　end
    //add #9323 donghao end
    //【01】透析日指定 / 検査日指定の判定
    if (reportMenu.getIsDialysisDate()) {
      // 透析日指定

      // 指定日、または期間内の透析日をターゲットに治療情報を取得します。
      //mod #9323 donghao start
      //List<OrdMain> ordList = reportMenuDao.selectByTreatDateAndPatIds(patIdList, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
      ordList = reportMenuDao.selectByTreatDateAndPatIds(patIdList, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
      //mod #9323 donghao end
      // 患者ID毎に集計
      for (Long patId : patIdList) {
        // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　start
        patIdPreDateList = new ArrayList<>();
        // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　end
        //mod #9323 donghao start
        //List<Long> ordNos = new ArrayList<>();
        ordNos = new ArrayList<>();
        //mod #9323 donghao end
        for (OrdMain ord : ordList) {
          if (ord.getPatId() != null && ord.getPatId().equals(patId)) {
            ordNos.add(ord.getOrdNo());
            // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　start
            patIdPreDateList.add(ord.getTreatDate());
            // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　end
          }
        }
        patIdOrdList.put(patId, ordNos);
        // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　start
        patIdPreDateMap.put(patId, patIdPreDateList);
        // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　end
      }
    // mod #11226 患者情報系historyの取得条件見直し② limingzhe start
    //} else {
    } else if(reportMenu.getDateKind().equals("exam_date")){
    // mod #11226 患者情報系historyの取得条件見直し② limingzhe end
      // 検査日指定：検査日の存在する日の ordNo をリストに格納します。該当のordNoが存在しない場合は、-1Lを格納します。

      List<String> regOrderClassList = reportMenu.getRegOrderClassList();
      if (regOrderClassList.size() == 0) {
        // 検査区分が全て未チェックの場合は、全選択扱いとする
        regOrderClassList = new ArrayList<String>(Arrays.asList("1", "2", "0"));
      }

      // 期間内の透析日リストを取得
      //mod #9323 donghao start
      //List<OrdMain> ordList = reportMenuDao.selectByTreatDateAndPatIds(patIdList, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
      ordList = reportMenuDao.selectByTreatDateAndPatIds(patIdList, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
      //mod #9323 donghao end

      for (Long patId : patIdList) {
        // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　start
        patIdPreDateList = new ArrayList<>();
        // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　end
        //mod #9323 donghao start
        //List<PatExamMain> examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateFrom), Timestamp.valueOf(localDateTo), regOrderClassList);
        examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateFrom), Timestamp.valueOf(localDateTo), regOrderClassList);
        //mod #9323 donghao end
        //add #9323 donghao start
        if (examMainList.size()>0) {
          newExamMainList.put(patId.toString(),examMainList.get(0));
        }
        //add #9323 donghao end
        for (PatExamMain exam : examMainList) {
          if (Objects.equal(exam.getExamStatus(), "1")) {
            // 検査実績：検査結果の場合は、result_exam_date と比較

            // 検査と同日の透析実績リストを取得する
            String uuuuMMdd = exam.getResultExamDate().toLocalDateTime().toLocalDate().format(DateTimeFormatter.ofPattern("uuuuMMdd"));
            // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//            List<OrdMain> ords = ordList.stream().filter(
//              o -> Objects.equal(o.getTreatDate(), uuuuMMdd)).collect(Collectors.toList());
            List<OrdMain> ords = ordList.stream().filter(
                o -> Objects.equal(o.getTreatDate(), uuuuMMdd) && o.getPatId().equals(patId)).collect(Collectors.toList());
            // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

            if (ords.size() > 0) {
              // 検査日と同じ日に透析予定、または実績が存在する
              for (OrdMain ord : ords) {
                ordNos.add(ord.getOrdNo());
                // del #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
//                // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　start
//                patIdPreDateList.add(ord.getTreatDate());
//                // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　end
                // del #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
              }
            }
            // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
            patIdPreDateList.add(uuuuMMdd);
            // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
          } else {
            // 検査予定：検査依頼の場合は、reg_exam_date と比較

            String uuuuMMdd = exam.getRegExamDate().toLocalDateTime().toLocalDate().format(DateTimeFormatter.ofPattern("uuuuMMdd"));
            // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//            List<OrdMain> ords = ordList.stream().filter(
//              o -> Objects.equal(o.getTreatDate(), uuuuMMdd)).collect(Collectors.toList());
            List<OrdMain> ords = ordList.stream().filter(
                o -> Objects.equal(o.getTreatDate(), uuuuMMdd) && o.getPatId().equals(patId)).collect(Collectors.toList());
            // mod #9323 帳票「並び替え」機能のオーバーホール　高 end
            if (ords.size() > 0) {
              // 検査日と同じ日に透析データがある
              for (OrdMain ord : ords) {
                ordNos.add(ord.getOrdNo());
                // del #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
//                // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　start
//                patIdPreDateList.add(ord.getTreatDate());
//                // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　end
                // del #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
              }
            }
            // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
            patIdPreDateList.add(uuuuMMdd);
            // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
          }
        }
        // 検査データが存在し、検査データと同時の ordNo が存在しない場合は、エラーを避ける為に -1L を入れておく
        if (ordNos.size() == 0) {
          ordNos = new ArrayList<Long>(Arrays.asList(-1L));
        }
        // 重複チェックして格納する
        patIdOrdList.put(patId, new ArrayList<Long>(new LinkedHashSet<>(ordNos)));
        // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　start
        patIdPreDateMap.put(patId, patIdPreDateList);
        // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　end
        // add #9323 帳票「並び替え」機能のオーバーホール　高 start
        ordNos.clear();
        // add #9323 帳票「並び替え」機能のオーバーホール　高 end

      }
    }
    // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　start
    else {

      // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
      List<String> prescriptionClassList = reportMenu.getPrescriptionClassList();
      // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end

      // 期間内の透析日リストを取得
      ordList = reportMenuDao.selectByTreatDateAndPatIds(patIdList, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
      for (Long patId : patIdList) {
        patIdPreDateList = new ArrayList<>();
        ordNos = new ArrayList<>();
        // 処方データを取得する
        // mod #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
//        List<OrdPrescription> prescriptionList = ordPrescriptionDao.selectResultByPatIdAndDateFromTo(patId, reportMenu.getFacilityCd(), localDateFrom.format(DateTimeFormatter.ofPattern("yyyyMMdd"))
//          ,localDateTo.format(DateTimeFormatter.ofPattern("yyyyMMdd")));
        List<OrdPrescription> prescriptionList = ordPrescriptionDao.selectResultByPatIdAndDateFromTo(patId, reportMenu.getFacilityCd(), localDateFrom.format(DateTimeFormatter.ofPattern("yyyyMMdd"))
        ,localDateTo.format(DateTimeFormatter.ofPattern("yyyyMMdd")), prescriptionClassList);
        // mod #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end
        List<OrdMain> prescriptionOrdList = ordList.stream().filter(el -> el.getPatId().toString().equals(patId.toString())).collect(toList());
        if(prescriptionOrdList != null && prescriptionOrdList.size() > 0 && prescriptionList != null && prescriptionList.size() > 0) {
          List<String> issueDateList = prescriptionList.stream().map(el -> el.getIssueDate()).collect(toList());
          //　オーダーの治療日は処方の交付日と同じのオーダーデータがあるかどうか
          List<OrdMain> filterList = prescriptionOrdList.stream().filter(el -> issueDateList.contains(el.getTreatDate())).collect(toList());
          if(filterList != null && filterList.size() > 0) {
            ordNos.addAll(filterList.stream().map(el -> el.getOrdNo()).collect(toList()));
            // del #11646 基準日「処方日」で期間指定したときに透析予定がない日の処方が出力できないことがある 高 start
//            patIdPreDateList.addAll(filterList.stream().map(el -> el.getTreatDate()).collect(toList()));
            // del #11646 基準日「処方日」で期間指定したときに透析予定がない日の処方が出力できないことがある 高 end
          }
        }
        // add #11646 基準日「処方日」で期間指定したときに透析予定がない日の処方が出力できないことがある 高 start
        patIdPreDateList.addAll(prescriptionList.stream().map(el -> el.getIssueDate()).collect(toList()));
        // add #11646 基準日「処方日」で期間指定したときに透析予定がない日の処方が出力できないことがある 高 end
        // エラーを避ける為に -1L を入れておく
        if (ordNos.size() == 0) {
          ordNos = new ArrayList<Long>(Arrays.asList(-1L));
        }
        patIdOrdList.put(patId, ordNos);
        patIdPreDateMap.put(patId, patIdPreDateList);
      }
    }
    // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　end

    //【02】：患者ID を ソート条件にしたがってソートする
    List<Map<String, String>> sortConditions = reportMenu.getSortCondition();
    // add #9323 帳票「並び替え」機能のオーバーホール　高 2024/03/06 start
    List tmpSortKey = new ArrayList();
    List tmpSortDirection = new ArrayList();
    String tmpSortKeyStr = "";
    String tmpSortDirectionStr = "";
    // add #9323 帳票「並び替え」機能のオーバーホール　高 2024/03/06 end
    // sortConditions (帳票画面>並び替え設定) は、優先3番目 → 優先2番目 → 優先1番目の順でデータがくることを想定しています (帳票種別：8：ラベルの並び替えと同様)
    if (sortConditions != null && sortConditions.size() > 0 && patIdList.size() > 0) {

      String patIdStr = "pat_id";
      //add #9323 donghao start
      String ordNoStr = "ord_no";
      //add #9323 donghao end
      // 01：患者IDのリストを、jsonのリストにまとめる
      List<JSONObject> tmpList = new ArrayList<>();//mod #9323 donghao start
      //for (Long patId : patIdList) {
      for (int idx = 0; idx < patIdList.size(); idx++) {
        //mod #9323 donghao end
        JSONObject jsonData = new JSONObject();
        //mod #9323 donghao start
        //jsonData.put(patIdStr, patId);
        jsonData.put(patIdStr, patIdList.get(idx));
        if(null != patIdOrdList.get(patIdList.get(idx)) && patIdOrdList.get(patIdList.get(idx)).size() > 0){
          jsonData.put(ordNoStr, patIdOrdList.get(patIdList.get(idx)).get(0).toString());
        }else{
          jsonData.put(ordNoStr, "");
        }
        //mod #9323 donghao end
        jsonData.put("treat_date", "");
        jsonData.put("hosp_pat_id", "");
        jsonData.put("in_out_class", "");
        jsonData.put("pat_full_name", "");
        jsonData.put("bed_order", "");
        jsonData.put("kur_order", "");
        tmpList.add(jsonData);
      }

      // 02：ソートに必要なデータを「01」で作成したjsonのリストに格納する
      // ※：画面上で並び順を 第1→患者ID(昇順)、第2→患者ID(降順) とした場合、sortConditions は 患者ID(昇順) 1件のみで送られてきます
      // ※：患者ID/入外区分のデータは1度の処理で取得できる為、フラグで2回通らないようにします
      boolean ppmhPassedFlg = false;
      boolean ordPassedFlg = false;
      for (int index = 0; index < sortConditions.size(); index++) {
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//        Map<String, String> item = sortConditions.get(index);
        Map<String, String> item = sortConditions.get(sortConditions.size() - (index+1));
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        if (item.keySet().contains(CoreConstant.ReportMenu.DIALYSIS_DAY)) {
// mod #9323 donghao start
//          // 透析日データを取得 ( 透析日は、開始日～終了日で検索し、開始日に近いほうのデータを使用してソートを行う )
//          Config config = defaultDbConfig;
//          SelectBuilder builder = SelectBuilder.newInstance(config);
//          builder.sql("select pat_id, min(treat_date) as treat_date from ord_main where pat_id in (");
//          for (Long patId : patIdList) {
//            builder.param(Long.class, patId);
//            builder.sql(",");
//          }
//          builder.removeLast();
//          builder.sql(") and treat_date >= '" + localDateFrom.format(DateTimeFormatter.ofPattern("yyyyMMdd")) + "' ");
//          builder.sql("and treat_date <= '" + localDateTo.format(DateTimeFormatter.ofPattern("yyyyMMdd")) + "' group by pat_id");
//          List<Map<String, Object>> results = baseEntityDao.executeSql(builder);
//          // 患者ID毎に透析日を格納
//          for (JSONObject tmpJson : tmpList) {
//            Long patId = tmpJson.getLong(patIdStr);
//            for (Map<String, Object> tmpMap : results) {
//              Long tmpId = Long.valueOf(tmpMap.get(patIdStr).toString());
//              if (tmpId.equals(patId)) {
//                tmpJson.put("treat_date", tmpMap.get("treat_date").toString());
//              }
//            }
//          }
          if (reportMenu.getIsDialysisDate()) {
            // 透析日データを取得 ( 透析日は、開始日～終了日で検索し、開始日に近いほうのデータを使用してソートを行う )
            Config config = defaultDbConfig;
            SelectBuilder builder = SelectBuilder.newInstance(config);
            builder.sql("select pat_id, min(treat_date) as treat_date from ord_main where pat_id in (");
            for (Long patId : patIdList) {
              builder.param(Long.class, patId);
              builder.sql(",");
            }
            builder.removeLast();
            builder.sql(") and treat_date >= '" + localDateFrom.format(DateTimeFormatter.ofPattern("yyyyMMdd")) + "' ");
            builder.sql("and treat_date <= '" + localDateTo.format(DateTimeFormatter.ofPattern("yyyyMMdd")) + "' group by pat_id");
            List<Map<String, Object>> results = baseEntityDao.executeSql(builder);
            // 患者ID毎に透析日を格納
            for (JSONObject tmpJson : tmpList) {
              Long patId = tmpJson.getLong(patIdStr);
              for (Map<String, Object> tmpMap : results) {
                Long tmpId = Long.valueOf(tmpMap.get(patIdStr).toString());
                if (tmpId.equals(patId)) {
                  tmpJson.put("treat_date", tmpMap.get("treat_date").toString());
                }
              }
            }
          } else {

            for (JSONObject tmpJson : tmpList) {
              Long patId = tmpJson.getLong(patIdStr);
              for (String tmpMap : newExamMainList.keySet()) {
                Long tmpId = Long.valueOf(tmpMap);
                if (tmpId.equals(patId)) {
                  if (newExamMainList.get(tmpMap).getResultExamDate() !=null) {
                    tmpJson.put("treat_date", newExamMainList.get(tmpMap).getResultExamDate().toString());
                    continue;
                  } else if (newExamMainList.get(tmpMap).getRegExamDate() != null) {
                    tmpJson.put("treat_date", newExamMainList.get(tmpMap).getRegExamDate().toString());
                    continue;
                  } else {
                    tmpJson.put("treat_date","");
                    continue;
                  }
                }
              }
            }
          }
          // mod #9323 donghao end

        } else if ((item.keySet().contains(CoreConstant.ReportMenu.PATIENT_ID) ||
                    item.keySet().contains(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION) ||
                    item.keySet().contains(CoreConstant.ReportMenu.PATIENT_NAME)) && !ppmhPassedFlg) {
          // 患者ID/入外区分/患者名のデータを取得

          // mongoDB検索条件作成
          String mongFromDate = localDateFrom.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")) + " 23:59:59";
          ArrayList<Bson> arr = new ArrayList<Bson>();
          arr.add(lt("up_date", mongFromDate));
          List<String> searchPatIdlist = new ArrayList<>();
          for (JSONObject tmpJson : tmpList) {
            searchPatIdlist.add(tmpJson.get(patIdStr).toString());
          }
          arr.add(in(patIdStr, searchPatIdlist));
          Bson bson = and(arr);
          // mongoDB検索処理
          FindIterable<Document> resultDocs = mongoTemplate.getCollection("pat_personal_main_history").find(bson).sort(descending("up_date"));
          // 患者ID毎に患者ID/入外区分を格納
          for (JSONObject tmpJson : tmpList) {
            Document doc = resultDocs != null ? resultDocs.filter(eq(patIdStr, tmpJson.get(patIdStr).toString())).first() : new Document();
            // add #9323 donghao start
            String InOutClass = "";
            if(null != tmpJson.get(ordNoStr) && !tmpJson.get(ordNoStr).equals("")){
              InOutClass = rdMainDao.getInOutClass(reportMenu.getFacilityCd(), tmpJson.get(ordNoStr).toString(), tmpJson.get(patIdStr).toString());
            }
            // add #9323 donghao end
            // 患者ID ( ソート用に0埋めして格納 )
              // add #11853 観察記録が記載されている患者で、観察記録(全体)の帳票を表示するとシステムエラーが発生する sunsy start
            if (doc.get("hosp_pat_id") != null)
            // add #11853 観察記録が記載されている患者で、観察記録(全体)の帳票を表示するとシステムエラーが発生する sunsy end
              // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//            tmpJson.put("hosp_pat_id", String.format("%12s", doc.get("hosp_pat_id").toString()).replace(" ", "0"));
            tmpJson.put("hosp_pat_id", doc.get("hosp_pat_id").toString());
            // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
            // 入外区分
            //mod #9323 donghao start
            //tmpJson.put("in_out_class", doc.get("in_out_class"));
            // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//            if (reportMenu.getIsDialysisDate()) {
//              if (null != InOutClass && !InOutClass.equals("")) {
//                tmpJson.put("in_out_class", InOutClass);
//              } else {
//                if (doc.get("in_out_class") != null) {
//                  tmpJson.put("in_out_class", doc.get("in_out_class"));
//                } else {
//                  tmpJson.put("in_out_class", "");
//                }
//              }
//            } else {
//              if (doc.get("in_out_class") != null) {
//                tmpJson.put("in_out_class", doc.get("in_out_class"));
//              } else {
//                tmpJson.put("in_out_class", "");
//              }
//            }
            if (reportMenu.getIsDialysisDate() && !StringUtils.isEmpty(InOutClass)) {
              tmpJson.put("in_out_class", InOutClass);
            } else {
              tmpJson.put("in_out_class", doc.get("in_out_class") != null ? doc.get("in_out_class") : "");
            }
            // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
            //mod #9323 donghao end
            // 患者名
            // add #11853 観察記録が記載されている患者で、観察記録(全体)の帳票を表示するとシステムエラーが発生する sunsy start
            if (doc.get("pat_last_name") != null && doc.get("pat_first_name") != null)
            // add #11853 観察記録が記載されている患者で、観察記録(全体)の帳票を表示するとシステムエラーが発生する sunsy end
              // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
              // カナ優先として半角スペースで連結し、ソート用キーを作成。文字列としてソートするソート用キーーカナ姓(漢字姓)&&カナ名(漢字名)
              if (doc.get("pat_last_name") != null && doc.get("pat_first_name") != null) {
                String lastName = !StringUtils.isEmpty((CharSequence) doc.get("pat_last_name_kana")) ? String.valueOf(doc.get("pat_last_name_kana"))
                  : String.valueOf(doc.get("pat_last_name"));
                String firstName = !StringUtils.isEmpty((CharSequence) doc.get("pat_first_name_kana")) ? String.valueOf(doc.get("pat_first_name_kana"))
                  : String.valueOf(doc.get("pat_first_name"));
                tmpJson.put("pat_full_name", lastName + " " + firstName);
              }
//            tmpJson.put("pat_full_name", doc.get("pat_last_name").toString() + " " + doc.get("pat_first_name").toString());
            // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
          }
          ppmhPassedFlg = true;

        } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_BED) ||
                   item.keySet().contains(CoreConstant.ReportMenu.PATIENT_COOL) && !ordPassedFlg) {
          // マスタデータを取得
          SelectOptions options = SelectOptions.get();
          List<MstBed> mstBedList = mstBedDao.selectByFacilityCd(reportMenu.getFacilityCd(), "1", "0");
          List<MstKur> mstKurList = mstKurDao.selectByFacilityCd(options, reportMenu.getFacilityCd(), "0");
          // 期間内のordMain取得
          //mod #9323 donghao start
          // List<OrdMain> ordList = reportMenuDao.selectByTreatDateAndPatIds(patIdList, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
          ordList = reportMenuDao.selectByTreatDateAndPatIds(patIdList, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
          //mod #9323 donghao end

          for (JSONObject tmpJson : tmpList) {
            Long patId = tmpJson.getLong(patIdStr);
            // ordMainから取得する値
            for (OrdMain ord : ordList) {
              if (patId.equals(ord.getPatId())) {
                // ベッド
                for (Integer bedListIndex = 0; bedListIndex < mstBedList.size(); bedListIndex++ ) {
                  if (ord.getIndBedCd().toString().equals(mstBedList.get(bedListIndex).getBedCd().toString())) {
                    tmpJson.put("bed_order", String.format("%5s", bedListIndex.toString()).replace(" ", "0"));
                  }
                }
                // クール
                for (Integer kurListIndex = 0; kurListIndex < mstKurList.size(); kurListIndex++ ) {
                  if (ord.getIndKurCd().toString().equals(mstKurList.get(kurListIndex).getKurCd().toString())) {
                    tmpJson.put("kur_order", String.format("%3s", kurListIndex.toString()).replace(" ", "0"));
                  }
                }
              }
            }
          }
          ordPassedFlg = true;
        }
      }

      // 03：条件により並び替えを実施する
      // add #9323 帳票「並び替え」機能のオーバーホール　高 start
      // del #9323 帳票「並び替え」機能のオーバーホール　高 2024/03/06 start
//      List tmpSortKey = new ArrayList();
//      List tmpSortDirection = new ArrayList();
      // del #9323 帳票「並び替え」機能のオーバーホール　高 2024/03/06 end
//      // add #9323 帳票「並び替え」機能のオーバーホール　高 end
      // add #9323 帳票「並び替え」機能のオーバーホール　高 2024/03/06 start
      List<Map<String, String>> treatList = new ArrayList();
      // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//      treatList = sortConditions.stream().filter(p->p.containsKey(CoreConstant.ReportMenu.DIALYSIS_DAY)).collect(Collectors.toList());
//      for (int index = 0; index < treatList.size();index++) {
//        Map<String, String> item = treatList.get(treatList.size() - (index+1));
//        if (item.keySet().contains(CoreConstant.ReportMenu.DIALYSIS_DAY)) {
//          // 透析日
//          tmpSortKeyStr = "treat_date";
//          tmpSortDirectionStr = item.get(CoreConstant.ReportMenu.DIALYSIS_DAY).toString();
//
//        }
//      }
//      sortConditions = sortConditions.stream().filter(p->!p.containsKey(CoreConstant.ReportMenu.DIALYSIS_DAY)).collect(Collectors.toList());
      treatList = sortConditions.stream().filter(p->p.containsKey(CoreConstant.ReportMenu.TREATMENT_DATE)).collect(Collectors.toList());
      for (int index = 0; index < treatList.size();index++) {
        Map<String, String> item = treatList.get(treatList.size() - (index+1));
        if (item.keySet().contains(CoreConstant.ReportMenu.TREATMENT_DATE)) {
          // 治療日
          tmpSortKeyStr = "treat_date";
          tmpSortDirectionStr = item.get(CoreConstant.ReportMenu.TREATMENT_DATE).toString();

        }
      }
      sortConditions = sortConditions.stream().filter(p->!p.containsKey(CoreConstant.ReportMenu.TREATMENT_DATE)).collect(Collectors.toList());
      // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
      // add #9323 帳票「並び替え」機能のオーバーホール　高 2024/03/06 end
      for (int index = 0; index < sortConditions.size(); index++) {
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//        Map<String, String> item = sortConditions.get(index);
        Map<String, String> item = sortConditions.get(sortConditions.size() - (index+1));
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 end
        // 並び替えに使用する項目を取得
        // del #9323 帳票「並び替え」機能のオーバーホール　高 start
//        String tmpSortKey = "";
//        String tmpSortDirection = "";
        // del #9323 帳票「並び替え」機能のオーバーホール　高 end

// del #9323 帳票「並び替え」機能のオーバーホール　高 2024/03/06 start
//        if (item.keySet().contains(CoreConstant.ReportMenu.DIALYSIS_DAY)) {
//          // 透析日
//          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
////          tmpSortKey = "treat_date";
////          tmpSortDirection = item.get(CoreConstant.ReportMenu.DIALYSIS_DAY).toString();
//          tmpSortKey.add(index,"treat_date");
//          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.DIALYSIS_DAY).toString());
//          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end
//
//        } else
// del #9323 帳票「並び替え」機能のオーバーホール　高 2024/03/06 end
          if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_ID)) {
          // 患者ID
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey = "hosp_pat_id";
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.PATIENT_ID).toString();
          tmpSortKey.add(index,"hosp_pat_id");
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_ID).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        } else if (item.keySet().contains(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION)) {
          // 入外区分
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey = "in_out_class";
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION).toString();
          tmpSortKey.add(index,"in_out_class");
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_NAME)) {
          // 患者名
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey = "pat_full_name";
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.PATIENT_NAME).toString();
          tmpSortKey.add(index,"pat_full_name");
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_NAME).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_BED)) {
          // ベッド表示順
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey = "bed_order";
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.PATIENT_BED).toString();
          tmpSortKey.add(index,"bed_order");
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_BED).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_COOL)) {
          // クール表示順
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey = "kur_order";
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.PATIENT_COOL).toString();
          tmpSortKey.add(index,"kur_order");
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_COOL).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        }

        // del #9323 帳票「並び替え」機能のオーバーホール　高 start
        // 並び替え
//        if (!tmpSortKey.equals("")) {
//          final String sortKey = tmpSortKey;
//          final String sortDirection = tmpSortDirection;
//          tmpList = tmpList.stream().sorted((patA, patB) -> {
//            if ("asc".equals(sortDirection)) {
//              return patA.get(sortKey).toString().compareTo(patB.get(sortKey).toString());
//            } else {
//              return patA.get(sortKey).toString().compareTo(patB.get(sortKey).toString()) * -1;
//            }
//            if ("asc".equals(sortDirection)) {
//              //add #9323 donghao start
//              if (patA.get(sortKey) != null && patA.get(sortKey)!= "" && !patA.get(sortKey).toString().equals(patB.get(sortKey).toString())) {
//                //add #9323 donghao end
//                return patA.get(sortKey).toString().compareTo(patB.get(sortKey).toString());
//                //add #9323 donghao start
//              } else {
//                return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//              }
//              //add #9323 donghao end
//            } else {
//              //add #9323 donghao start
//              if (patA.get(sortKey) != null && patA.get(sortKey)!= "" && !patA.get(sortKey).toString().equals(patB.get(sortKey).toString())) {
//                //add #9323 donghao end
//                return patA.get(sortKey).toString().compareTo(patB.get(sortKey).toString()) * -1;
//                //add #9323 donghao start
//              } else {
//                return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString()) * -1;
//              }
//              //add #9323 donghao end
//            }
//          }).collect(Collectors.toList());
//
//          // ソート対象のデータが存在しないデータを最下段に寄せる
//          List<JSONObject> list = new ArrayList<>();
//          List<JSONObject> empList = new ArrayList<>();
//          for (JSONObject tmpJson : tmpList) {
//            if (tmpJson.getString(sortKey).equals("")) {
//              empList.add(tmpJson);
//            } else {
//              list.add(tmpJson);
//            }
//          }
//          list.addAll(empList);
//          tmpList = list;
//        }
        // del #9323 帳票「並び替え」機能のオーバーホール　高 end
      }
      // add #9323 帳票「並び替え」機能のオーバーホール　高 start
      List sortKey = tmpSortKey;
      List sortDirection = tmpSortDirection;

      // mod #9323 帳票「並び替え」機能のオーバーホール　高 2024/03/06 start
      if (sortKey.contains("in_out_class") && sortDirection.get(sortKey.indexOf("in_out_class")).equals("asc")) {
        for (int index = 0;index < tmpList.size();index++) {
          if (tmpList.get(index).get("in_out_class").equals("2")) {
            tmpList.get(index).put("in_out_class","999999998");
          }else if (tmpList.get(index).get("in_out_class").equals("3")) {
            tmpList.get(index).put("in_out_class","999999999");
          }
        }
      } else if (sortKey.contains("in_out_class") && sortDirection.get(sortKey.indexOf("in_out_class")).equals("desc")) {
        for (int index = 0;index < tmpList.size();index++) {
          if (tmpList.get(index).get("in_out_class").equals("2")) {
            tmpList.get(index).put("in_out_class","-999999999");
          } else if (tmpList.get(index).get("in_out_class").equals("3")) {
            tmpList.get(index).put("in_out_class","-999999998");
          }
        }
      }
      // mod #9323 帳票「並び替え」機能のオーバーホール　高 2024/03/06 end
      // add #9323 帳票「並び替え」機能のオーバーホール(帳票種別：2：単患者帳票)　高 start
      if (sortKey.contains("bed_order") && sortDirection.get(sortKey.indexOf("bed_order")).equals("asc")) {
        for (int index = 0;index < tmpList.size();index++) {
          if (StringUtils.isEmpty(tmpList.get(index).get("bed_order").toString())) {
            tmpList.get(index).put("bed_order","999999999");
          }
        }
      } else if (sortKey.contains("bed_order") && sortDirection.get(sortKey.indexOf("bed_order")).equals("desc")) {
        for (int index = 0;index < tmpList.size();index++) {
          if (StringUtils.isEmpty(tmpList.get(index).get("bed_order").toString())) {
            tmpList.get(index).put("bed_order","-999999999");
          }
        }
      }
      if (sortKey.contains("kur_order") && sortDirection.get(sortKey.indexOf("kur_order")).equals("asc")) {
        for (int index = 0;index < tmpList.size();index++) {
          if (StringUtils.isEmpty(tmpList.get(index).get("kur_order").toString())) {
            tmpList.get(index).put("kur_order","999999999");
          }
        }
      } else if (sortKey.contains("kur_order") && sortDirection.get(sortKey.indexOf("kur_order")).equals("desc")) {
        for (int index = 0;index < tmpList.size();index++) {
          if (StringUtils.isEmpty(tmpList.get(index).get("kur_order").toString())) {
            tmpList.get(index).put("kur_order","-999999999");
          }
        }
      }
      // add #9323 帳票「並び替え」機能のオーバーホール(帳票種別：2：単患者帳票)　高 end
      // 並び替え
      // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//      tmpList = OnePatientCompare(tmpList,sortKey,sortDirection);
      tmpList = DialysisAndOnePatientReportCompare(tmpList,sortKey,sortDirection);
      // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end

      // mod #9323 帳票「並び替え」機能のオーバーホール　高 2024/03/06 start
      if (sortKey.contains("in_out_class") && sortDirection.get(sortKey.indexOf("in_out_class")).equals("asc")) {
        for (int index = 0;index < tmpList.size();index++) {
          if (tmpList.get(index).get("in_out_class").equals("999999998")) {
            tmpList.get(index).put("in_out_class","2");
          } else if (tmpList.get(index).get("in_out_class").equals("999999999")) {
            tmpList.get(index).put("in_out_class","3");
          }
        }
      } else if (sortKey.contains("in_out_class") && sortDirection.get(sortKey.indexOf("in_out_class")).equals("desc")) {
        for (int index = 0;index < tmpList.size();index++) {
          if (tmpList.get(index).get("in_out_class").equals("-999999999")) {
            tmpList.get(index).put("in_out_class","2");
          } else if (tmpList.get(index).get("in_out_class").equals("-999999998")) {
            tmpList.get(index).put("in_out_class","3");
          }
        }
      }
      // mod #9323 帳票「並び替え」機能のオーバーホール　高 2024/03/06 end
      // add #9323 帳票「並び替え」機能のオーバーホール(帳票種別：2：単患者帳票)　高 start
      if (sortKey.contains("bed_order") && sortDirection.get(sortKey.indexOf("bed_order")).equals("asc")) {
        for (int index = 0;index < tmpList.size();index++) {
          if (tmpList.get(index).get("bed_order").equals("999999999")) {
            tmpList.get(index).put("bed_order","");
          }
        }
      } else if (sortKey.contains("bed_order") && sortDirection.get(sortKey.indexOf("bed_order")).equals("desc")) {
        for (int index = 0;index < tmpList.size();index++) {
          if (tmpList.get(index).get("bed_order").equals("-999999999")) {
            tmpList.get(index).put("bed_order","");
          }
        }
      }
      if (sortKey.contains("kur_order") && sortDirection.get(sortKey.indexOf("kur_order")).equals("asc")) {
        for (int index = 0;index < tmpList.size();index++) {
          if (tmpList.get(index).get("kur_order").equals("999999999")) {
            tmpList.get(index).put("kur_order","");
          }
        }
      } else if (sortKey.contains("kur_order") && sortDirection.get(sortKey.indexOf("kur_order")).equals("desc")) {
        for (int index = 0;index < tmpList.size();index++) {
          if (tmpList.get(index).get("kur_order").equals("-999999999")) {
            tmpList.get(index).put("kur_order","");
          }
        }
      }
      // add #9323 帳票「並び替え」機能のオーバーホール(帳票種別：2：単患者帳票)　高 end

      // ソート対象のデータが存在しないデータを最下段に寄せる
      List<JSONObject> list = new ArrayList<>();
      List<JSONObject> empList = new ArrayList<>();
      for (JSONObject tmpJson : tmpList) {
        for (int index = 0; index < sortKey.size();index++) {
          if (tmpJson.getString(sortKey.get(index).toString()).equals("")) {
            empList.add(tmpJson);
          }
        }
      }
      list.addAll(empList);
      // add #9323 帳票「並び替え」機能のオーバーホール　高 end
      // ソートしたデータを適用
      List<Long> tmpPatIdList = new ArrayList<>();
      for (JSONObject tmpJson : tmpList) {
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 2024/03/06 start
//        tmpPatIdList.add(tmpJson.getLong(patIdStr));
        if (!tmpPatIdList.contains(tmpJson.getLong(patIdStr))) {
          tmpPatIdList.add(tmpJson.getLong(patIdStr));
        }
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 2024/03/06 end
      }
      patIdList = tmpPatIdList;

    }

    //【03】：患者ID の繰り返しにより、帳票データを患者ID毎に取得して、戻り値に格納する
    Map<String,List> searchList = this.searchMap(reportMenu.getFacilityCd());
    // 開始日、終了日のパラメータ設定 ( 期間指定でない場合は、1日指定の日付を開始日、終了日に設定 )
    // パラメータのフォーマットは基本「YYYY/MM/DD」とします
    String fromDate = localDateFrom.format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));
    String toData = localDateTo.format(DateTimeFormatter.ofPattern("yyyy/MM/dd"));

    List<Map<Long, byte[]>> excelReportList = new ArrayList<>();
    // 患者ID毎にord_no のリストでデータを取得する
    for (Long patId : patIdList) {

      // 検索条件を格納
      Map<String, Object> searchInfo = new HashMap<>();
      searchInfo.put("login", userName);
      searchInfo.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
      searchInfo.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate()); // 1日指定の日付を格納しているが問題ない
      searchInfo.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
      searchInfo.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
      searchInfo.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
      searchInfo.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate);
      searchInfo.put(ReportConstant.ReportDataKey.DATE_TO, toData);
      // add #9323 帳票「並び替え」機能のオーバーホール　高 2024/03/06 start
      searchInfo.put("tmpSortKeyStr",tmpSortKeyStr);
      searchInfo.put("tmpSortDirectionStr",tmpSortDirectionStr);
      // add #9323 帳票「並び替え」機能のオーバーホール　高 2024/03/06 end

      // 処方データ取得用のパラメータ
      // mod #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240613 sunsy start
//      List<OrdPrescription> ordPrescriptionList = ordPrescriptionDao.selectResultByPatId(patId, fromDate.replace("/", ""), toData.replace("/", ""));
      // mod #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
//      List<OrdPrescription> ordPrescriptionList = ordPrescriptionDao.selectResultByPatId(patId, fromDate.replace("/", ""));
      // 処方箋区分
      List<String> prescriptionClassList = reportMenu.getPrescriptionClassList() == null ? new ArrayList<String>(Arrays.asList("1", "2")) : reportMenu.getPrescriptionClassList();
      // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
//      List<OrdPrescription> ordPrescriptionList = ordPrescriptionDao.selectResultByPatId(patId, fromDate.replace("/", ""),prescriptionClassList);
      List<OrdPrescription> ordPrescriptionList = ordPrescriptionDao.selectResultByPatIdAndDateFromTo(patId, reportMenu.getFacilityCd(), localDateFrom.format(DateTimeFormatter.ofPattern("yyyyMMdd"))
        ,localDateTo.format(DateTimeFormatter.ofPattern("yyyyMMdd")),prescriptionClassList);
      if(ordPrescriptionList != null && ordPrescriptionList.size() > 0) {
        if(patIdPreDateMap.containsKey(patId)) {
          List<String> tempPreDateList = patIdPreDateMap.get(patId);
          ordPrescriptionList = ordPrescriptionList.stream().filter(el -> tempPreDateList.contains(el.getIssueDate())).collect(toList());
        }
      }
      // mod #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
      // mod #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end
      // mod #10525 保険区分が「セット」のときクラス「処方情報」が出力できない 20240613 sunsy end
      List<Long> ordPrescriptionNos = new ArrayList<>();
      for (OrdPrescription rx : ordPrescriptionList) {
        ordPrescriptionNos.add(rx.getOrdPrescriptionNo());
      }
      // sys_data_set の sql用のパラメータを格納
      Map<String, Object> dataKey = createDataKeyForOnePatient(searchList, fromDate, toData, reportMenu.getFacilityCd(), patIdOrdList.get(patId), patId, ordPrescriptionNos);
      // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
      dataKey.put("prescriptionClassList",prescriptionClassList);
      // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end
      // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
      List<String> regOrderClassList = reportMenu.getRegOrderClassList() == null ? new ArrayList<String>(Arrays.asList("1", "2", "0")) : reportMenu.getRegOrderClassList();
      dataKey.put("regOrderClassList", regOrderClassList);
      // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
      // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
      requestParamEdit(reportMenu, dataKey);
      // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　start
      // del #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
//      // mod #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
////      List<OrdPrescription> prescriptionList = ordPrescriptionDao.selectResultByPatIdAndDateFromTo(patId, reportMenu.getFacilityCd(), localDateFrom.format(DateTimeFormatter.ofPattern("yyyyMMdd"))
////        ,localDateTo.format(DateTimeFormatter.ofPattern("yyyyMMdd")));
//      List<OrdPrescription> prescriptionList = ordPrescriptionDao.selectResultByPatIdAndDateFromTo(patId, reportMenu.getFacilityCd(), localDateFrom.format(DateTimeFormatter.ofPattern("yyyyMMdd"))
//        ,localDateTo.format(DateTimeFormatter.ofPattern("yyyyMMdd")),prescriptionClassList);
//      // mod #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end
//      if(prescriptionList != null && prescriptionList.size() > 0) {
//        if(patIdPreDateMap.containsKey(patId)) {
//          List<String> tempPreDateList = patIdPreDateMap.get(patId);
//          prescriptionList = prescriptionList.stream().filter(el -> tempPreDateList.contains(el.getIssueDate())).collect(toList());
//          dataKey.put("prescriptionList", prescriptionList);
//        }
//      }
      // del #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
      dataKey.put("dateKind",reportMenu.getDateKind());
      // add #11226 患者情報系historyの取得条件見直し② (単患者帳票) 房　end
      // add 11009 カテゴリ「印刷情報」の仕様調整 房 end
      // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy start
      dataKey.put(ReportConstant.ReportDataKey.reportClass,reportMenu.getReportClass());
      dataKey.put(ReportConstant.ReportDataKey.currentPage,"");
      dataKey.put(ReportConstant.ReportDataKey.totalPages,"");
      // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy end
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 start
      // 単患者帳票
      if (null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate()) {
        // 1日指定
        String year = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(0, 4);
        String month = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(4, 6);
        String day = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(6,8);
        Calendar calendar =Calendar.getInstance();
        calendar.setFirstDayOfWeek(Calendar.MONDAY);
        calendar.set(Calendar.YEAR, Integer.valueOf(year));
        calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
        calendar.set(Calendar.DAY_OF_MONTH, Integer.valueOf(day));
        int week = calendar.get(Calendar.WEEK_OF_MONTH);
        dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
      } else {
        // 期間指定
        String year = reportMenu.getFromDate().replace("/","").replace("-","").substring(0, 4);
        String month = reportMenu.getFromDate().replace("/","").replace("-","").substring(4, 6);
        String day = reportMenu.getFromDate().replace("/","").replace("-","").substring(6,8);
        Calendar calendar =Calendar.getInstance();
        calendar.setFirstDayOfWeek(Calendar.MONDAY);
        calendar.set(Calendar.YEAR, Integer.valueOf(year));
        calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
        calendar.set(Calendar.DAY_OF_MONTH, Integer.valueOf(day));
        int week = calendar.get(Calendar.WEEK_OF_MONTH);
        dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
      }
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 end
      // Excelデータ取得
      // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe start
      //byte[] excelBytes = reportService.getReportExcelFileForOnePatient(reportCd, dataKey, searchInfo);
      byte[] excelBytes = reportForOnePatientService.getReportExcelFileForOnePatient(reportCd, dataKey, searchInfo);
      // mod #10887 繰返しでない項目」「グループ改頁OFFの項目」がテンプレート繰返し時に不正 limingzhe end
      Map<Long, byte[]> reportMap = new HashMap<>();
      reportMap.put(patId, excelBytes);
      excelReportList.add(reportMap);
    }

    return excelReportList;
  }

  /**
   *
   * {@inheritDoc}
   */
  @Override
  public Map<String, Object> createDataKeyForOnePatient(Map<String,List> searchList, String fromDate, String toData, String facilityCd, List<Long> ordNos, Long patId, List<Long> ordPrescriptionNos) {
    // sys_data_set の sql用のパラメータを格納
    Map<String, Object> dataKey = new HashMap<>();
    // 薬剤、医療材料、ダイアライザ条件の格納 ： 単患者帳票の場合は無効になっている為、全選択とする
    dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
    dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
    dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
    // 開始日、終了日
    dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate);
    dataKey.put(ReportConstant.ReportDataKey.DATE_TO, toData);
    // 施設コード
    dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, facilityCd);
    // ordNoリスト
    dataKey.put(ReportConstant.ReportDataKey.ORD_NOS, ordNos);
    dataKey.put(ReportConstant.ReportDataKey.PAT_ID, patId);

    // @date をパラメータに使用しているsqlの対応 ( sql側を @fromData に変更したいが、他の処理での影響を考え、sql側を変更しない方法で対応 )
    dataKey.put(ReportConstant.ReportDataKey.DATE, fromDate);

    // 処方データ取得用のパラメータ
    dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS, ordPrescriptionNos);

    // 検査予定(採血管・指定日)(sqlcd：53)用のパラメータ ( 単患者帳票項目では確認した限り sqlcd：53 しか使用していないパラメータです )
    dataKey.put("treatDate", fromDate);

    // 患者イベント画像(sqlcd：86)用のパラメータ(yyyy/MM/DD形式) (可能であれば、sqlcd：86のパラメータを変更し、処理を削除してください)
    dataKey.put("imageDateFrom", fromDate);
    dataKey.put("imageDateTo", toData);

    return dataKey;
  }


  //add #9058【IES起票】状況マップ画面にて単患者帳票機能帳票印刷後線とプレビューが不一致 liuc start
  @Override
  public void engineryReportPdfPrintBatch(List<Map<Long, List<byte[]>>> patPdfFiles, String reportName, Long printerCd)
    throws Exception {
    //Map<patId,patName>
    Map<Long,String> patNameMap = new HashMap<>();
    for (int i = 0; i < patPdfFiles.size(); i++) {
      for (Long patId : patPdfFiles.get(i).keySet()) {
        if(!patNameMap.containsKey(patId)){
          PatPersonalMain patPersonalMain = patPersonalMainDao.selectById(patId);
          String lastName = patPersonalMain.getPat_last_name();
          String firstName = patPersonalMain.getPat_first_name();
          String patName = lastName + firstName;
          patNameMap.put(patId,patName);
        }
      }
    }

    LocalDate localDate = LocalDate.now();

    for (int i = 0; i < patPdfFiles.size(); i++) {
      for (Long key : patPdfFiles.get(i).keySet()) {
        List<byte[]> pdfFiles = patPdfFiles.get(i).get(key);
        for (int j = 0; j < pdfFiles.size(); j++) {
          byte[] pdfFileBytes = pdfFiles.get(j);
          String fileName = getFileNameByPatName(localDate,patNameMap.get(key),reportName);
          if (pdfFileBytes.length > 0) {
            fileName = fileName.replace(".pdf", "(" + (j + 1) + ").pdf");
            String destFilePath = "pdf/" + fileName;
            // 印刷用ファイルはローカルに保存する
            this.engineryReportPdfPrint(pdfFileBytes, destFilePath, printerCd);
          }
        }
      }
    }
  }

  @Override
  public void engineryReportPdfPrint(byte[] excelBytes, String pdfPath, Long printerCd) {
    try {
      reportService.convertBytesToPdf(excelBytes, pdfPath);
      printerService.sendPrintRequest(printerCd, pdfPath);
    } finally {
      // 一時ファイルを削除
//      Path path = Paths.get(printTmpDir+ "/" + pdfPath);
//      try {
//        Files.delete(path);
//      } catch (IOException e) {
//        //e.printStackTrace();
//      }
    }

  }

  public String convertBtyesToHtml(byte[] excelBytes) throws Exception {
    String reportHtml = null;
    //mod 【帳票T】機能帳票「予定」画面配布リスト(ベッド)プレビューブランクボード liuc start
    //if (excelBytes.length > 0) {
    if (excelBytes != null) {
    //mod 【帳票T】機能帳票「予定」画面配布リスト(ベッド)プレビューブランクボード liuc end
      ByteArrayInputStream byteArrayInputStream = new ByteArrayInputStream(excelBytes);
      URL url = resourceLoader.getResource(ReportConstant.ReportGraph.LIC).getURL();
      // Excel Convert To Svg
      reportHtml = AsposeCellsUtils.excelToSvg(byteArrayInputStream, url);
    }

    return reportHtml;
  }

  //add #9058【IES起票】状況マップ画面にて単患者帳票機能帳票印刷後線とプレビューが不一致 liuc end

  /**
   *
   * {@inheritDoc}
   */
  @Override
  public byte[] getReportExcelFilesForMultiplePatient(ReportMenuSortContainer reportMenu, String userName) throws Exception {
    Integer reportClass = reportMenu.getReportClass();
    Boolean isDialyzer = false;

    // ダイアライザーが含まれるか
    if(reportMenu.getEquipmentCdList() != null) {
      if(reportMenu.getEquipmentCdList().contains(0)) {
        isDialyzer = true;
      }
    }

    byte[] excelResult = null;
    Long reportCd = reportMenu.getReportCd();
    List<Long> patIdList = reportMenu.getPatIds();

    List<Integer> listDia = new ArrayList<>();
    List<Long> listOrdNo = new ArrayList<>();
    List<Long> listPatId = new ArrayList<>();

    Map<String, Object> dataKey = new HashMap<>();
    // add #9323 donghao start
    Map<String, PatExamMain> newExamMainList = new HashMap<>();
    // add #9323 donghao end
    // 期間指定、1日指定に応じて、開始日、終了日を格納
    LocalDateTime localDateFrom = null;
    LocalDateTime localDateTo = null;
    if (reportMenu.getSpecifyDate() == null) {
      // 期間指定
      localDateFrom = LocalDate.parse(reportMenu.getFromDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
      localDateTo = LocalDate.parse(reportMenu.getToDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
      localDateTo = localDateTo.plusDays(1L).minusNanos(1000);
    } else {
      // 1日指定
      localDateFrom = LocalDate.parse(reportMenu.getSpecifyDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
      localDateTo = localDateFrom.plusDays(1L).minusNanos(1000);
    }

    // 期間内のordMain取得
    List<OrdMain> ordList = reportMenuDao.selectByTreatDateAndPatIds(patIdList, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
    // add #11679 複数患者帳票で「透析条件.補液量」が出ない 吉 start
    Map<Long,OrdMain>  ordMap = new HashMap<>();
    for(OrdMain or : ordList){
        ordMap.put(or.getOrdNo(),or);
    }
    // add #11679 複数患者帳票で「透析条件.補液量」が出ない 吉 end
    // ---------------------------------------------------------------------------

    //【01】透析日指定 / 検査日指定の判定
    if (reportMenu.getIsDialysisDate()) {
      // 透析日指定

      // 指定日、または期間内の透析日をターゲットに治療情報を取得します。
      if(null != patIdList && patIdList.size() > 0) {
        // mod #10805 単患者帳票と複数患者帳票で、対象患者一覧と帳票出力結果が一致しない limingzhe start
//        for(Long patId : patIdList) {
//          for (OrdMain ord : ordList) {
//            if (patId.equals(ord.getPatId())) {
//              listOrdNo.add(ord.getOrdNo());
//              listPatId.add(ord.getPatId());
//            }
//          }
//        }
        for(Long patId : patIdList) {
          boolean bHaveOrdNo = false;
          for (OrdMain ord : ordList) {
            if (patId.equals(ord.getPatId())) {
              listOrdNo.add(ord.getOrdNo());
              listPatId.add(ord.getPatId());
              bHaveOrdNo = true;
            }
          }
          if(!bHaveOrdNo){
            listOrdNo.add(-1l);
            listPatId.add(patId);
          }
        }
        // mod #10805 単患者帳票と複数患者帳票で、対象患者一覧と帳票出力結果が一致しない limingzhe end
      }
    }
    // mod #11226 患者情報系historyの取得条件見直し② (複数患者帳票) 高　start
//    else {
    else if (reportMenu.getDateKind().equals("exam_date")){
      // mod #11226 患者情報系historyの取得条件見直し② (複数患者帳票) 高　end
      // 検査日指定：検査日の存在する日の ordNo をリストに格納します。該当のordNoが存在しない場合は、-1Lを格納します。

      List<String> regOrderClassList = reportMenu.getRegOrderClassList();
      if (regOrderClassList.size() == 0) {
        // 検査区分が全て未チェックの場合は、全選択扱いとする
        regOrderClassList = new ArrayList<String>(Arrays.asList("1", "2", "0"));
      }

      for (Long patId : patIdList) {
        List<PatExamMain> examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateFrom), Timestamp.valueOf(localDateTo), regOrderClassList);
        // add #9323 donghao start
        if (examMainList.size()>0) {
          newExamMainList.put(patId.toString(),examMainList.get(0));
        }
        // add #9323 donghao end
        List<Long> ordNos = new ArrayList<>();
        for (PatExamMain exam : examMainList) {
          if (Objects.equal(exam.getExamStatus(), "1")) {
            // 検査実績：検査結果の場合は、result_exam_date と比較

            // 検査と同日の透析実績リストを取得する
            String uuuuMMdd = exam.getResultExamDate().toLocalDateTime().toLocalDate().format(DateTimeFormatter.ofPattern("uuuuMMdd"));
            List<OrdMain> ords = ordList.stream().filter(
                o -> Objects.equal(o.getTreatDate(), uuuuMMdd)).collect(Collectors.toList());

            if (ords.size() > 0) {
              // 検査日と同じ日に透析予定、または実績が存在する
              for (OrdMain ord : ords) {
                // mod #10611 【デグレ】複数患者帳票を検査日で抽出するとシステムエラー 高　start
                if (patId.equals(ord.getPatId())) {
                  ordNos.add(ord.getOrdNo());
                }
//                ordNos.add(ord.getOrdNo());
                // mod #10611 【デグレ】複数患者帳票を検査日で抽出するとシステムエラー 高　end
              }
            }
          } else {
            // 検査予定：検査依頼の場合は、reg_exam_date と比較

            String uuuuMMdd = exam.getRegExamDate().toLocalDateTime().toLocalDate().format(DateTimeFormatter.ofPattern("uuuuMMdd"));
            List<OrdMain> ords = ordList.stream().filter(
                o -> Objects.equal(o.getTreatDate(), uuuuMMdd)).collect(Collectors.toList());
            if (ords.size() > 0) {
              // 検査日と同じ日に透析データがある
              for (OrdMain ord : ords) {
                // mod #10611 【デグレ】複数患者帳票を検査日で抽出するとシステムエラー 高　start
                if (patId.equals(ord.getPatId())) {
                  ordNos.add(ord.getOrdNo());
                }
//                ordNos.add(ord.getOrdNo());
                // mod #10611 【デグレ】複数患者帳票を検査日で抽出するとシステムエラー 高　end
              }
            }
          }
        }
        // del #10522 因島帳票の再検証による指摘事項 王永吉 start
        // 検査データが存在し、検査データと同時の ordNo が存在しない場合は、エラーを避ける為に -1L を入れておく
//        if (ordNos.size() == 0) {
//          ordNos = new ArrayList<Long>(Arrays.asList(-1L));
          // add 9423 テンプレート繰返し時に元々値があるセルは上書きしないようにすること　吉 start
//        } else
        // del #10522 因島帳票の再検証による指摘事項 王永吉 end
        if(ordNos.size() < patIdList.size()){
          List<Long> combinedList = new ArrayList<>(patIdList.size());
          combinedList.addAll(ordNos);
          // del #10611 【デグレ】複数患者帳票を検査日で抽出するとシステムエラー 高　start
//          for (int i = ordNos.size(); i <  patIdList.size(); i++) {
//            combinedList.add(-1L);
//          }
          // add #11679 複数患者帳票で「透析条件.補液量」が出ない 高 start
          for (int i = ordNos.size(); i <  patIdList.size(); i++) {
            combinedList.add(-1L);
          }
          // add #11679 複数患者帳票で「透析条件.補液量」が出ない 高 end
          // del #10611 【デグレ】複数患者帳票を検査日で抽出するとシステムエラー 高　end
          ordNos = combinedList;
          // add 9423 テンプレート繰返し時に元々値があるセルは上書きしないようにすること　吉 end
        }
        // 重複チェックして格納する
        List<Long> tmpOrdNoList = new ArrayList<Long>(new LinkedHashSet<>(ordNos));
        for (Long ordNo : tmpOrdNoList) {
          listOrdNo.add(ordNo);
          listPatId.add(patId);
        }
      }
    }
    // add #11226 患者情報系historyの取得条件見直し② (複数患者帳票) 高　start
    // 処方
    else {
      for (Long patId : patIdList) {
        List<OrdPrescription> ordPrescriptionList = ordPrescriptionDao.selectPrescriptionResultByPatId(patId,
          String.valueOf(localDateFrom).replace("/", "").replace("-","").substring(0,8),
          String.valueOf(localDateTo).replace("/", "").replace("-","").substring(0,8));
        List<Long> ordNos = new ArrayList<>();
        for (OrdPrescription prescriptionList : ordPrescriptionList) {
          String uuuuMMdd = String.valueOf(prescriptionList.getIssueDate());
          List<OrdMain> ords = ordList.stream().filter(
            o -> Objects.equal(o.getTreatDate(), uuuuMMdd)).collect(Collectors.toList());

          if (ords.size() > 0) {
            for (OrdMain ord : ords) {
              if (patId.equals(ord.getPatId())) {
                ordNos.add(ord.getOrdNo());
              }
            }
          }
        }
        if(ordNos.size() < patIdList.size()){
          List<Long> combinedList = new ArrayList<>(patIdList.size());
          combinedList.addAll(ordNos);
          // add #11679 複数患者帳票で「透析条件.補液量」が出ない 2025/05/28 高 start
          for (int i = ordNos.size(); i <  patIdList.size(); i++) {
            combinedList.add(-1L);
          }
          // add #11679 複数患者帳票で「透析条件.補液量」が出ない 2025/05/28 高 end
          ordNos = combinedList;
        }
        List<Long> tmpOrdNoList = new ArrayList<Long>(new LinkedHashSet<>(ordNos));
        for (Long ordNo : tmpOrdNoList) {
          listOrdNo.add(ordNo);
          listPatId.add(patId);
        }
      }
    }
    // add #11226 患者情報系historyの取得条件見直し② (複数患者帳票) 高　end

    // ---------------------------------------------------------------------------

    // 患者ID を ソート条件にしたがってソートする
    List<Map<String, String>> sortConditions = reportMenu.getSortCondition();
    // add #9577 「？？？？」患者は表示されません（複数患者帳票）。 2024/03/18 高 start
    MstReport mstReport = getMstReport(reportCd);
    // S3から帳票定義XML、帳票デザインExcelが格納されたZipファイルを取得する
    ReportZipFile reportZipFile = getReportZip(mstReport);
    // SqlCodeをもとに帳票に出力する情報を取得する
    String reportXml = getReportXml(mstReport, reportZipFile);
    List<ReportXmlParam> params = ReportUtils.getParamElements(reportXml);
    List<String> sqlCodes = getSqlCode(params);
    // 複数患者帳票
    if (null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate()) {
      // 1日指定
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      String day = reportMenu.getSpecifyDate().substring(6,8);
      String year = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(0, 4);
      String month = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(4, 6);
      String day = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(6,8);
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 end
      String date = reportMenu.getSpecifyDate();
      Calendar calendar =Calendar.getInstance();
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      calendar.setFirstDayOfWeek(Calendar.MONDAY);
//      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.setFirstDayOfWeek(Calendar.MONDAY);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 start
      calendar.set(Calendar.YEAR, Integer.valueOf(year));
      calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      int week = calendar.get(Calendar.WEEK_OF_MONTH);
      dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
      // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//      String treatDateFormatted = date.substring(0,4) + "-" + date.substring(4,6) + "-" + date.substring(6);
//      String[] result = getStartAndEndDayByDate(treatDateFormatted);
//      String start = result[0].substring(0,4) + "年" + result[0].substring(5,7) + "月" + result[0].substring(8)+ "日";
//      String end = result[1].substring(5,7) + "月" + result[1].substring(8)+ "日";
//      dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
      // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, date.replace("/",""));
      dataKey.put(ReportConstant.ReportDataKey.DATE_TO, date.replace("/",""));
      // add #12163 "一般撮影.放射線検査予定"項目が、複数集計帳票だと出力されない limingzhe start
      dataKey.put(ReportConstant.ReportDataKey.DATE, date.replace("/",""));
      // add #12163 "一般撮影.放射線検査予定"項目が、複数集計帳票だと出力されない limingzhe end
    } else {
      // 期間指定
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      String day = reportMenu.getFromDate().substring(6,8);
      String year = reportMenu.getFromDate().replace("/","").replace("-","").substring(0, 4);
      String month = reportMenu.getFromDate().replace("/","").replace("-","").substring(4, 6);
      String day = reportMenu.getFromDate().replace("/","").replace("-","").substring(6,8);
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 end
      String fromDate = reportMenu.getFromDate().substring(0,4) + "-" + reportMenu.getFromDate().substring(4,6) + "-" + reportMenu.getFromDate().substring(6);
      String toDate = reportMenu.getToDate().substring(0,4) + "-" + reportMenu.getToDate().substring(4,6) + "-" + reportMenu.getToDate().substring(6);
      Calendar calendar =Calendar.getInstance();
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      calendar.setFirstDayOfWeek(Calendar.MONDAY);
//      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.setFirstDayOfWeek(Calendar.MONDAY);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 start
      calendar.set(Calendar.YEAR, Integer.valueOf(year));
      calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      int week = calendar.get(Calendar.WEEK_OF_MONTH);
      dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
      // del 11009 カテゴリ「印刷情報」の仕様調整 房 start
//      String start = "";
//      String end = "";
//      String[] result = getStartAndEndDayByDate(fromDate);
//      start = result[0].substring(0, 4) + "年" + result[0].substring(5, 7) + "月" + result[0].substring(8)+ "日";
//      end =  result[1].substring(5, 7) + "月" + result[1].substring(8)+ "日";
//      dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
      // del 11009 カテゴリ「印刷情報」の仕様調整 房 end
      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate.replace("/",""));
      dataKey.put(ReportConstant.ReportDataKey.DATE_TO, toDate.replace("/",""));
      // add #12163 "一般撮影.放射線検査予定"項目が、複数集計帳票だと出力されない limingzhe start
      dataKey.put(ReportConstant.ReportDataKey.DATE, fromDate.replace("/",""));
      // add #12163 "一般撮影.放射線検査予定"項目が、複数集計帳票だと出力されない limingzhe end
    }
    List<OrdMain> questionMarkPatId = rdMainDao.selectOrdMainByNullPatId(reportMenu.getFacilityCd(),
      dataKey.get("fromDate").toString(),
      dataKey.get("toDate").toString());
    // add #12206 【デグレード】帳票画面で透析予測でのソートが機能しない 高 start
    String patIdStr = "pat_id";
    String ordNoStr = "ord_no";
    // 01：患者IDのリストを、jsonのリストにまとめる
    List<JSONObject> tmpList = new ArrayList<>();
    for (int idx = 0; idx < listPatId.size(); idx++) {
      JSONObject jsonData = new JSONObject();
      jsonData.put(patIdStr, listPatId.get(idx));
      jsonData.put(ordNoStr, listOrdNo.get(idx));
      jsonData.put("treat_date", "");
      jsonData.put("hosp_pat_id", "");
      jsonData.put("in_out_class", "");
      jsonData.put("pat_name_kana", "");
      jsonData.put("pat_group_order", "");
      jsonData.put("pat_sex", "");
      jsonData.put("pat_blood_type_abo", "");
      jsonData.put("pat_blood_type_rh", "");
      jsonData.put("is_infect", "");
      jsonData.put("bed_order", "");
      jsonData.put("bed_group_order", "");
      jsonData.put("kur_order", "");
      jsonData.put("start_time", "");
      jsonData.put("end_time", "");
      jsonData.put("ind_end_date", "");
      jsonData.put("ind_end_date_time", "");
      tmpList.add(jsonData);
    }
    Map<Long,Map<Long, List<Map<String, Object>>>> reportInfoIndexPatIdMap = new LinkedHashMap<>();
    Map<Long, List<Map<String, Object>>> reportInfoIndexOrdNoMap = new LinkedHashMap<>();
    if (sqlCodes.contains("133")) {
      List<Long> ordNoJsonList = tmpList.stream()
        .map(json -> Long.parseLong(String.valueOf(json.get(ordNoStr))))
        .distinct()
        .collect(toList());

      List<Long> patIdJsonList = tmpList.stream()
        .map(json -> Long.parseLong(String.valueOf(json.get(patIdStr))))
        .distinct()
        .collect(toList());

      dataKey.put("patIds",patIdJsonList);
      dataKey.put("ordNos",ordNoJsonList);
      dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
      List<ReportXmlParam> paramNew133 = new ArrayList<>();
      if (sqlCodes.contains("133")) {
        List<ReportXmlParam> filtered = params.stream()
          .filter(p -> "133".equals(p.getSqlCode()))
          .collect(toList());
        ReportXmlParam param = filtered.get(0);
        paramNew133.add(param);
      }
      Map<Long, List<Map<String, Object>>> reportInfoIndex133 = reportServiceImpl.getReportInfo(paramNew133, dataKey);
      for (int i = 0; i < patIdJsonList.size(); i++) {
        Map<Long, List<Map<String, Object>>> reportInfoIndexNewPatIdMap = new HashMap<>();
        try{
          for (Map.Entry<Long, List<Map<String, Object>>> entry : reportInfoIndex133.entrySet()) {
            List<Map<String, Object>> dataList = entry.getValue();
            List<Map<String, Object>> dataListPatId = new ArrayList<>();
            for (Map<String, Object> dataMap : dataList) {
              Object patIdObj = dataMap.get("pat_id_tmp");
              if (patIdObj != null && patIdJsonList.get(i).equals(patIdObj) || entry.getKey() == 0) {
                dataListPatId.add(dataMap);
              }
            }
            reportInfoIndexNewPatIdMap.put(entry.getKey(),reportServiceImpl.deepCopyList(dataListPatId));
          }
          if (reportInfoIndexPatIdMap.containsKey(Long.parseLong(String.valueOf(patIdJsonList.get(i))))) {
            reportInfoIndexPatIdMap.get(Long.parseLong(String.valueOf(patIdJsonList.get(i)))).putAll(reportServiceImpl.deepCopy(reportInfoIndexNewPatIdMap));
          } else {
            reportInfoIndexPatIdMap.put(Long.parseLong(String.valueOf(patIdJsonList.get(i))), reportServiceImpl.deepCopy(reportInfoIndexNewPatIdMap));
          }
        } catch (IOException e) {
          throw new RuntimeException(e);
        } catch (ClassNotFoundException e) {
          throw new RuntimeException(e);
        }
      }
      for (int i = 0; i < ordNoJsonList.size(); i++) {
        Map<Long, List<Map<String, Object>>> reportInfoIndexNewOrdNoMap = new HashMap<>();
        try{
          for (Map.Entry<Long, List<Map<String, Object>>> entry : reportInfoIndex133.entrySet()) {
            List<Map<String, Object>> dataList = entry.getValue();
            List<Map<String, Object>> dataListOrdNo = new ArrayList<>();
            for (Map<String, Object> dataMap : dataList) {
              Object OrdNoObj = dataMap.get("ord_no");
              if (OrdNoObj != null && ordNoJsonList.get(i).equals(OrdNoObj) || entry.getKey() == 0) {
                dataListOrdNo.add(dataMap);
              }
            }
            reportInfoIndexOrdNoMap.put(Long.parseLong(String.valueOf(ordNoJsonList.get(i))),reportServiceImpl.deepCopyList(dataListOrdNo));
          }
        } catch (IOException e) {
          throw new RuntimeException(e);
        } catch (ClassNotFoundException e) {
          throw new RuntimeException(e);
        }
      }
    }
    // add #12206 【デグレード】帳票画面で透析予測でのソートが機能しない 高 end
    if (!sqlCodes.contains("133") || (sqlCodes.contains("133") && questionMarkPatId.size() == 0)) {
      // add #9577 「？？？？」患者は表示されません（複数患者帳票）。 2024/03/18 高 end
      // sortConditions (帳票画面>並び替え設定) は、優先3番目 → 優先2番目 → 優先1番目の順でデータがくることを想定しています (帳票種別：8：ラベルの並び替えと同様)
      if (sortConditions != null && sortConditions.size() > 0 && patIdList.size() > 0) {
        // add #9577 「？？？？」患者は表示されません（複数患者帳票）。 2024/03/18 高 start
        dataKey.put("sortFlag","0");
        // add #9577 「？？？？」患者は表示されません（複数患者帳票）。 2024/03/18 高 end
// del #12206 【デグレード】帳票画面で透析予測でのソートが機能しない 高 start
//      String patIdStr = "pat_id";
//      String ordNoStr = "ord_no";
//      // 01：患者IDのリストを、jsonのリストにまとめる
//      List<JSONObject> tmpList = new ArrayList<>();
//      for (int idx = 0; idx < listPatId.size(); idx++) {
//        JSONObject jsonData = new JSONObject();
//        jsonData.put(patIdStr, listPatId.get(idx));
//        jsonData.put(ordNoStr, listOrdNo.get(idx));
//        jsonData.put("treat_date", "");
//        jsonData.put("hosp_pat_id", "");
//        jsonData.put("in_out_class", "");
//        jsonData.put("pat_name_kana", "");
//        jsonData.put("pat_group_order", "");
//        jsonData.put("pat_sex", "");
//        jsonData.put("pat_blood_type_abo", "");
//        // add #9323 donghao start
//        jsonData.put("pat_blood_type_rh", "");
//        // add #9323 donghao add
//        jsonData.put("is_infect", "");
//        jsonData.put("bed_order", "");
//        jsonData.put("bed_group_order", "");
//        jsonData.put("kur_order", "");
//        jsonData.put("start_time", "");
//        jsonData.put("end_time", "");
//        jsonData.put("ind_end_date", "");
//        jsonData.put("ind_end_date_time", "");
//        tmpList.add(jsonData);
//      }
        // del #12206 【デグレード】帳票画面で透析予測でのソートが機能しない 高 end

      // 02：ソートに必要なデータを「01」で作成したjsonのリストに格納する
      // ※：画面上で並び順を 第1→患者ID(昇順)、第2→患者ID(降順) とした場合、sortConditions は 患者ID(昇順) 1件のみで送られてきます
      // ※：患者ID/入外区分/フリガナ/性別/血液型、ベッド/クールのデータは1度の処理で取得できる為、フラグで2回通らないようにします
      boolean ppmhPassedFlg = false;
      boolean ordPassedFlg = false;
      for (int index = 0; index < sortConditions.size(); index++) {
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//        Map<String, String> item = sortConditions.get(index);
        Map<String, String> item = sortConditions.get(sortConditions.size() - (index+1));
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        if ((item.keySet().contains(CoreConstant.ReportMenu.PATIENT_ID) ||
            item.keySet().contains(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION) ||
            item.keySet().contains(CoreConstant.ReportMenu.READING) ||
            item.keySet().contains(CoreConstant.ReportMenu.SEX) ||
            item.keySet().contains(CoreConstant.ReportMenu.BLOOD_TYPE)) && !ppmhPassedFlg) {
          // 患者ID/入外区分/フリガナ/性別/血液型のデータを取得

          // mongoDB検索条件作成
          String mongFromDate = localDateFrom.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")) + " 23:59:59";
          // mod #11679 複数患者帳票で「透析条件.補液量」が出ない 吉 start
//ArrayList<Bson> arr = new ArrayList<Bson>();
//          arr.add(lt("up_date", mongFromDate));
//          List<String> searchPatIdlist = new ArrayList<>();
//          for (JSONObject tmpJson : tmpList) {
//            searchPatIdlist.add(tmpJson.get(patIdStr).toString());
//          }
//          arr.add(in(patIdStr, searchPatIdlist));
//          Bson bson = and(arr);
//          // mongoDB検索処理
//          FindIterable<Document> resultDocs = mongoTemplate.getCollection("pat_personal_main_history").find(bson).sort(descending("up_date"));
          List<String> searchPatIdlist = new ArrayList<>();
          for (JSONObject tmpJson : tmpList) {
            searchPatIdlist.add(tmpJson.get(patIdStr).toString());
          }
          List<Bson> pipeline = Arrays.asList(
            Aggregates.match(and(
              eq("facility_cd", reportMenu.getFacilityCd()),
              lt("up_date", mongFromDate),
              in(patIdStr, searchPatIdlist)
            )),
            Aggregates.sort(Sorts.descending("up_date")),
            Aggregates.group("$" + patIdStr,
              Accumulators.first("latestRecord", "$$ROOT")
            ),
            Aggregates.replaceRoot("$latestRecord")
          );

          AggregateIterable<Document> resultDocs = mongoTemplate.getCollection("pat_personal_main_history").aggregate(pipeline);
          Map<String, Document> patIdToDocMap = new HashMap<>();
          for (Document doc : resultDocs) {
            String patId = doc.getString(patIdStr);
            patIdToDocMap.put(patId, doc);
          }
          // mod #11679 複数患者帳票で「透析条件.補液量」が出ない 吉 end
          // 患者ID毎に患者ID/入外区分を格納
          for (JSONObject tmpJson : tmpList) {
            // mod #11679 複数患者帳票で「透析条件.補液量」が出ない 吉 start
            // Document doc = resultDocs != null ? resultDocs.filter(eq(patIdStr, tmpJson.get(patIdStr).toString())).first() : new Document();
            Document doc = patIdToDocMap.getOrDefault(tmpJson.get(patIdStr).toString(), new Document());
            // mod #11679 複数患者帳票で「透析条件.補液量」が出ない 吉 end
            // add #9323 donghao start
           // mod #11679 複数患者帳票で「透析条件.補液量」が出ない 吉 start
            // inOutClass = rdMainDao.getInOutClass(reportMenu.getFacilityCd(),tmpJson.get(ordNoStr).toString(),tmpJson.get(patIdStr).toString());
            String inOutClass = null != ordMap.get(tmpJson.get(ordNoStr))? String.valueOf(ordMap.get(tmpJson.get(ordNoStr)).getRstInOutClass()) : "";
            // mod #11679 複数患者帳票で「透析条件.補液量」が出ない 吉 end
            // add #9323 donghao end
            // mod #11853 観察記録が記載されている患者で、観察記録(全体)の帳票を表示するとシステムエラーが発生する sunsy start
//            if (doc != null) {
            if (doc != null && doc.size() > 0) {
              // mod #11853 観察記録が記載されている患者で、観察記録(全体)の帳票を表示するとシステムエラーが発生する sunsy end
              // 患者ID ( ソート用に0埋めして格納 )
              // mod #11853 観察記録が記載されている患者で、観察記録(全体)の帳票を表示するとシステムエラーが発生する sunsy start
              if (doc.get("hosp_pat_id") != null) {
                // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//                tmpJson.put("hosp_pat_id", String.format("%12s", doc.get("hosp_pat_id").toString()).replace(" ", "0"));
                tmpJson.put("hosp_pat_id", doc.get("hosp_pat_id").toString());
                // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
              }
              // mod #11853 観察記録が記載されている患者で、観察記録(全体)の帳票を表示するとシステムエラーが発生する sunsy end
              // 入外区分
              // mod #9323 donghao start
              //tmpJson.put("in_out_class", doc.get("in_out_class"));
              // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//              if (reportMenu.getIsDialysisDate()) {
//                if (inOutClass !=null) {
//                  tmpJson.put("in_out_class", inOutClass);
//                } else {
//                  if (doc.get("in_out_class") != null) {
//                    tmpJson.put("in_out_class", doc.get("in_out_class"));
//                  } else {
//                    tmpJson.put("in_out_class", "");
//                  }
//                }
//              } else {
//                if (doc.get("in_out_class") != null) {
//                  tmpJson.put("in_out_class", doc.get("in_out_class"));
//                } else {
//                  tmpJson.put("in_out_class", "");
//                }
//              }
              if (reportMenu.getIsDialysisDate() && inOutClass !=null) {
                tmpJson.put("in_out_class", inOutClass);
              } else {
                tmpJson.put("in_out_class", doc.get("in_out_class") != null ? doc.get("in_out_class") : "");
              }
              // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
              //mod #9323 donghao end
              // フリガナ
              //mod #9323 donghao start
              //tmpJson.put("pat_name_kana", doc.get("pat_last_name_kana") + " " + doc.get("pat_first_name_kana"));
              // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//              if (doc.get("pat_last_name_kana")!=null && doc.get("pat_first_name_kana")!=null) {
//                tmpJson.put("pat_name_kana", doc.get("pat_last_name_kana") + " " + doc.get("pat_first_name_kana"));
//              } else if (doc.get("pat_last_name_kana")==null && doc.get("pat_first_name_kana")!=null) {
//                tmpJson.put("pat_name_kana", doc.get("pat_first_name_kana"));
//              } else if (doc.get("pat_last_name_kana") != null && doc.get("pat_first_name_kana") == null) {
//                tmpJson.put("pat_name_kana", doc.get("pat_last_name_kana"));
//              } else {
//                tmpJson.put("pat_name_kana", "");
//              }

              // カナ優先として半角スペースで連結し、ソート用キーを作成。文字列としてソートするソート用キーーカナ姓(漢字姓)&&カナ名(漢字名)
              if (doc.get("pat_last_name") != null && doc.get("pat_first_name") != null){
                if (doc.get("pat_last_name") != null && doc.get("pat_first_name") != null) {
                  String lastName = !StringUtils.isEmpty((CharSequence) doc.get("pat_last_name_kana")) ? String.valueOf(doc.get("pat_last_name_kana"))
                    : String.valueOf(doc.get("pat_last_name"));
                  String firstName = !StringUtils.isEmpty((CharSequence) doc.get("pat_first_name_kana")) ? String.valueOf(doc.get("pat_first_name_kana"))
                    : String.valueOf(doc.get("pat_first_name"));
                  tmpJson.put("pat_name_kana", lastName + " " + firstName);
                }
              }
              // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
              //mod #9323 donghao end

              // 性別
              // mod #11853 観察記録が記載されている患者で、観察記録(全体)の帳票を表示するとシステムエラーが発生する sunsy start
              if (doc.get("pat_sex") != null)
              // mod #11853 観察記録が記載されている患者で、観察記録(全体)の帳票を表示するとシステムエラーが発生する sunsy end
              tmpJson.put("pat_sex", doc.get("pat_sex"));
              // 血液型
              // mod #9323 donghao start
              //tmpJson.put("pat_blood_type_abo", doc.get("pat_blood_type_abo"));
              if(doc.get("pat_blood_type_abo") !=null){
                tmpJson.put("pat_blood_type_abo", doc.get("pat_blood_type_abo"));
              } else {
                tmpJson.put("pat_blood_type_abo", "");
              }
              if (doc.get("pat_blood_type_rh") != null) {
                tmpJson.put("pat_blood_type_rh", doc.get("pat_blood_type_rh"));
              } else {
                tmpJson.put("pat_blood_type_rh", "");
              }
              // mod #9323 donghao end
            }
          }
          ppmhPassedFlg = true;

        } else if (item.keySet().contains(CoreConstant.ReportMenu.INFECTIOUS_ISEASE_PATIENTS)) {
          // 感染症患者のデータを取得

          // mongoDB検索条件作成
          String mongFromDate = localDateFrom.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")) + " 23:59:59";
          // mod #11679 複数患者帳票で「透析条件.補液量」が出ない 吉 start
//          ArrayList<Bson> arr = new ArrayList<Bson>();
//          arr.add(lt("up_date", mongFromDate));
//          List<String> list = new ArrayList<>();
//          for (JSONObject tmpJson : tmpList) {
//            list.add(tmpJson.get(patIdStr).toString());
//          }
//          arr.add(in(patIdStr, list));
//          Bson bson = and(arr);
//          // mongoDB検索処理
//          FindIterable<Document> resultDocs = mongoTemplate.getCollection("pat_main_history").find(bson).sort(descending("up_date"));
          List<String> searchPatIdlist = new ArrayList<>();
          for (JSONObject tmpJson : tmpList) {
            searchPatIdlist.add(tmpJson.get(patIdStr).toString());
          }
          List<Bson> pipeline = Arrays.asList(
            Aggregates.match(and(
              eq("facility_cd", reportMenu.getFacilityCd()),
              lt("up_date", mongFromDate),
              in(patIdStr, searchPatIdlist)
            )),
            Aggregates.sort(Sorts.descending("up_date")),
            Aggregates.group("$" + patIdStr,
              Accumulators.first("latestRecord", "$$ROOT")
            ),
            Aggregates.replaceRoot("$latestRecord")
          );

          AggregateIterable<Document> resultDocs = mongoTemplate.getCollection("pat_main_history").aggregate(pipeline);
          Map<String, Document> patIdToDocMap = new HashMap<>();
          for (Document doc : resultDocs) {
            String patId = doc.getString(patIdStr);
            patIdToDocMap.put(patId, doc);
          }
          // mod #11679 複数患者帳票で「透析条件.補液量」が出ない 吉 end
          // 患者ID毎に感染症患者を格納
          for (JSONObject tmpJson : tmpList) {
            // mod #11679 複数患者帳票で「透析条件.補液量」が出ない 吉 start
//            Document doc = resultDocs != null ? resultDocs.filter(eq(patIdStr, tmpJson.get(patIdStr).toString())).first() : new Document();
            Document doc = patIdToDocMap.getOrDefault(tmpJson.get(patIdStr).toString(), new Document());
            // mod #11679 複数患者帳票で「透析条件.補液量」が出ない 吉 end
            if (doc != null) {
              // 感染症患者
              tmpJson.put("is_infect", doc.get("is_infect"));
            }
          }
        } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_BED) ||
                   item.keySet().contains(CoreConstant.ReportMenu.PATIENT_COOL) ||
                   item.keySet().contains(CoreConstant.ReportMenu.ROOM_BED_GROUP)
                     // del #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 吉 start
//          || item.keySet().contains(CoreConstant.ReportMenu.RST_START_DATE) ||
//          item.keySet().contains(CoreConstant.ReportMenu.RST_END_DATE) ||
//          item.keySet().contains(CoreConstant.ReportMenu.IND_END_DATE) ||
//          item.keySet().contains(CoreConstant.ReportMenu.IND_END_DATE_TIME)
                     // del #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 吉 end
                     && !ordPassedFlg) {
          // マスタデータを取得
          SelectOptions options = SelectOptions.get();
          List<MstBed> mstBedList = mstBedDao.selectByFacilityCd(reportMenu.getFacilityCd(), "1", "0");
          List<MstKur> mstKurList = mstKurDao.selectByFacilityCd(options, reportMenu.getFacilityCd(), "0");

          for (JSONObject tmpJson : tmpList) {
            String ordNo = tmpJson.get(ordNoStr).toString();
            // add #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 start
            String patId = tmpJson.get(patIdStr).toString();
            // add #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 end
            // ordMainから取得する値
            for (OrdMain ord : ordList) {
              if (ordNo.equals(ord.getOrdNo().toString())) {
                // ベッド, ベッドグループ表示順
                for (Integer bedListIndex = 0; bedListIndex < mstBedList.size(); bedListIndex++ ) {
                  if (ord.getIndBedCd().toString().equals(mstBedList.get(bedListIndex).getBedCd().toString())) {
                    tmpJson.put("bed_order", String.format("%5s", bedListIndex.toString()).replace(" ", "0"));
                    Integer bedGroupIndex = 999;
                    bedGroupIndex = mstRoomBedGroupDao.selectIndexBedCdIsContain(ord.getIndBedCd().toString(), reportMenu.getFacilityCd(), "1");
                    tmpJson.put("bed_group_order", String.format("%3s", bedGroupIndex.toString()).replace(" ", "0"));
                  }
                }
                // クール
                for (Integer kurListIndex = 0; kurListIndex < mstKurList.size(); kurListIndex++ ) {
                  if (ord.getIndKurCd().toString().equals(mstKurList.get(kurListIndex).getKurCd().toString())) {
                    tmpJson.put("kur_order", String.format("%3s", kurListIndex.toString()).replace(" ", "0"));
                  }
                }

// del #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 吉 start
//                  // mod #9577 「？？？？」患者は表示されません（複数患者帳票）。 2024/03/18 高 start
////                  MniMonitorRemainingTime remainingTime = mniMonitorDao.selectRemainingTime(Long.parseLong(ordNo));
//                // mod #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 start
////                MniMonitorRemainingTime remainingTime = mniMonitorDao.selectRemainingTime(Long.parseLong(ordNo),reportMenu.getFacilityCd());
//                  MniMonitorRemainingTime remainingTime = mniMonitorDao.selectRemainingTime(Long.parseLong(ordNo),reportMenu.getFacilityCd(),Long.parseLong(patId),dataKey.get("fromDate").toString(),dataKey.get("toDate").toString());
//                // mod #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 end
//                  // mod #9577 「？？？？」患者は表示されません（複数患者帳票）。 2024/03/18 高 end
//
//                Long elapsedTime = 0L;
//                Long remainingTimeDialysis = 0L;
//                Long remainingTimeRemoval = 0L;
//                if (remainingTime != null) {
//                  elapsedTime = remainingTime.getElapsedTime() != null ? Long.parseLong(remainingTime.getElapsedTime()) : 0L;
//                  remainingTimeDialysis = remainingTime.getRemainingTimeDialysis() != null ? Long.parseLong(remainingTime.getRemainingTimeDialysis()) : 0L;
//                  remainingTimeRemoval = remainingTime.getRemainingTimeRemoval() != null ? Long.parseLong(remainingTime.getRemainingTimeRemoval()) : 0L;
//                }
//                if (item.keySet().contains(CoreConstant.ReportMenu.RST_START_DATE) && ord.getRstStartDate() != null) {
//                  // 透析開始
//                  LocalDateTime startDate = ord.getRstStartDate().toLocalDateTime();
//                  if (startDate != null ) {
//                    tmpJson.put("start_time", startDate.toString());
//                  }
//                } else if (item.keySet().contains(CoreConstant.ReportMenu.RST_END_DATE) && ord.getRstEndDate() != null) {
//                  // 透析終了
//                  LocalDateTime endDate = ord.getRstEndDate().toLocalDateTime();
//                  if (endDate != null ) {
//                    tmpJson.put("end_time", endDate.toString());
//                  }
//                } else if (item.keySet().contains(CoreConstant.ReportMenu.IND_END_DATE) && ord.getRstStartDate() != null) {
//                  // 終了予定（透析開始日時＋実績の透析時間）
//                  // mod #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 start
////                  LocalDateTime startDate = ord.getRstStartDate().toLocalDateTime();
////                  if (startDate != null ) {
////                    LocalDateTime indEndDate = startDate;
////                    indEndDate = startDate.plusMinutes(elapsedTime);
////                    tmpJson.put("ind_end_date", indEndDate.toString());
////                  }
//                  if (remainingTime != null) {
//                    tmpJson.put("ind_end_date", remainingTime.getInd_end_date());
//                  }
//                  // mod #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 end
//                } else if (item.keySet().contains(CoreConstant.ReportMenu.IND_END_DATE_TIME) && ord.getRstStartDate() != null) {
//                  // 終了予測（透析開始日時＋（透析残り時間と除水残り時間のうち値が大きい方））
//                  // mod #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 start
////                  LocalDateTime startDate = ord.getRstStartDate().toLocalDateTime();
////                  if (startDate != null ) {
////                    LocalDateTime indEndDateTime = startDate;
////                    if (remainingTimeDialysis > remainingTimeRemoval) {
////                      indEndDateTime = startDate.plusMinutes(remainingTimeDialysis);
////                    } else {
////                      indEndDateTime = startDate.plusMinutes(remainingTimeRemoval);
////                    }
////                    tmpJson.put("ind_end_date_time", indEndDateTime.toString());
////                  }
//                  if (remainingTime != null && remainingTime.getInd_end_date_time() != null) {
//                    tmpJson.put("ind_end_date_time", remainingTime.getInd_end_date_time());
//                  }
//                  // mod #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 end
//                }
                // del #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 吉 end
              }
            }
          }
          ordPassedFlg = true;
        }
        // add #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 吉 start
        else if (item.keySet().contains(CoreConstant.ReportMenu.RST_START_DATE) ||
          item.keySet().contains(CoreConstant.ReportMenu.RST_END_DATE) ||
          item.keySet().contains(CoreConstant.ReportMenu.IND_END_DATE) ||
          item.keySet().contains(CoreConstant.ReportMenu.IND_END_DATE_TIME) ){
          for (JSONObject tmpJson : tmpList) {
            String ordNo = tmpJson.get(ordNoStr).toString();
            String patId = tmpJson.get(patIdStr).toString();
            // ordMainから取得する値
            for (OrdMain ord : ordList) {
              if (ordNo.equals(ord.getOrdNo().toString())) {
                // add #12206 【デグレード】帳票画面で透析予測でのソートが機能しない 高 start
                List<Map<String, Object>> indMap = reportInfoIndexOrdNoMap.get(ord.getOrdNo());
                // add #12206 【デグレード】帳票画面で透析予測でのソートが機能しない 高 end
                MniMonitorRemainingTime remainingTime = mniMonitorDao.selectRemainingTime(Long.parseLong(ordNo),reportMenu.getFacilityCd(),Long.parseLong(patId),dataKey.get("fromDate").toString(),dataKey.get("toDate").toString());
                Long elapsedTime = 0L;
                Long remainingTimeDialysis = 0L;
                Long remainingTimeRemoval = 0L;
                if (item.keySet().contains(CoreConstant.ReportMenu.RST_START_DATE) && ord.getRstStartDate() != null) {
                  // 透析開始
                  LocalDateTime startDate = ord.getRstStartDate().toLocalDateTime();
                  if (startDate != null ) {
                    tmpJson.put("start_time", startDate.toString());
                  }
                } else if (item.keySet().contains(CoreConstant.ReportMenu.RST_END_DATE) && ord.getRstEndDate() != null) {
                  // 透析終了
                  LocalDateTime endDate = ord.getRstEndDate().toLocalDateTime();
                  if (endDate != null ) {
                    tmpJson.put("end_time", endDate.toString());
                  }
                } else if (item.keySet().contains(CoreConstant.ReportMenu.IND_END_DATE) && ord.getRstStartDate() != null) {
                  // mod #12206 【デグレード】帳票画面で透析予測でのソートが機能しない 高 start
//                  if (remainingTime != null) {
//                    tmpJson.put("ind_end_date", remainingTime.getInd_end_date());
//                  }
                  if (indMap != null && indMap.size() != 0) {
                    for (Map<String, Object> row : indMap) {
                      for (Map.Entry<String, Object> entry : row.entrySet()) {
                        if ("ind_end_date".equals(entry.getKey())) {
                          tmpJson.put("ind_end_date", entry.getValue());
                        }
                      }
                    }
                  }
                  // mod #12206 【デグレード】帳票画面で透析予測でのソートが機能しない 高 end
                } else if (item.keySet().contains(CoreConstant.ReportMenu.IND_END_DATE_TIME) && ord.getRstStartDate() != null) {
                  // 終了予測（透析開始日時＋（透析残り時間と除水残り時間のうち値が大きい方））
                  // mod #12206 【デグレード】帳票画面で透析予測でのソートが機能しない 高 start
//                  if (remainingTime != null && remainingTime.getInd_end_date_time() != null) {
//                    tmpJson.put("ind_end_date_time", remainingTime.getInd_end_date_time());
//                  }
                  if (indMap != null && indMap.size() != 0) {
                    for (Map<String, Object> row : indMap) {
                      for (Map.Entry<String, Object> entry : row.entrySet()) {
                        if ("ind_end_date_time".equals(entry.getKey()) && entry.getValue() != null) {
                          tmpJson.put("ind_end_date_time", entry.getValue());
                        }
                      }
                    }
                  }
                  // mod #12206 【デグレード】帳票画面で透析予測でのソートが機能しない 高 end
                }
              }
            }
          }
        }
        // add #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 吉 end
        else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_GROUP)) {
          for (JSONObject tmpJson : tmpList) {
            Integer patGroupIndex = 999;
            patGroupIndex = patGroupDao.selectIndexPatIdIsContain(tmpJson.get(patIdStr).toString(), reportMenu.getFacilityCd());
            tmpJson.put("pat_group_order", String.format("%3s", patGroupIndex.toString()).replace(" ", "0"));
          }
        }
      }

      // 03：条件により並び替えを実施する
      // add #9323 帳票「並び替え」機能のオーバーホール　高 start
      List tmpSortKey = new ArrayList();
      List tmpSortDirection = new ArrayList();
      List sortKeyName = new ArrayList();
      String[] newTmpSortKey = new String[]{};
      // add #9323 帳票「並び替え」機能のオーバーホール　高 end
      for (int index = 0; index < sortConditions.size(); index++) {
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//        Map<String, String> item = sortConditions.get(index);
        Map<String, String> item = sortConditions.get(sortConditions.size() - (index+1));
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 end
        // 並び替えに使用する項目を取得
        // del #9323 帳票「並び替え」機能のオーバーホール　高 start
//        String tmpSortKey = "";
//        String tmpSortDirection = "";
        //add #9323 donghao start
//        String[] newTmpSortKey = new String[]{};
        //add #9323 donghao end
        // del #9323 帳票「並び替え」機能のオーバーホール　高 end
        if (item.keySet().contains(CoreConstant.ReportMenu.DIALYSIS_DAY)) {
          // 透析日
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey = "treat_date";
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.DIALYSIS_DAY).toString();
          tmpSortKey.add(index,"treat_date");
          sortKeyName.add(index,CoreConstant.ReportMenu.DIALYSIS_DAY);
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.DIALYSIS_DAY).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_ID)) {
          // 患者ID
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey = "hosp_pat_id";
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.PATIENT_ID).toString();
          tmpSortKey.add(index,"hosp_pat_id");
          sortKeyName.add(index,CoreConstant.ReportMenu.PATIENT_ID);
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_ID).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        } else if (item.keySet().contains(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION)) {
          // 入外区分
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey = "in_out_class";
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION).toString();
          tmpSortKey.add(index,"in_out_class");
          sortKeyName.add(index,CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION);
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        } else if (item.keySet().contains(CoreConstant.ReportMenu.INFECTIOUS_ISEASE_PATIENTS)) {
          // 感染症患者
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey = "is_infect";
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.INFECTIOUS_ISEASE_PATIENTS).toString();
          tmpSortKey.add(index,"is_infect");
          sortKeyName.add(index,CoreConstant.ReportMenu.INFECTIOUS_ISEASE_PATIENTS);
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.INFECTIOUS_ISEASE_PATIENTS).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        } else if (item.keySet().contains(CoreConstant.ReportMenu.READING)) {
          // フリガナ
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey = "pat_name_kana";
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.READING).toString();
          tmpSortKey.add(index,"pat_name_kana");
          sortKeyName.add(index,CoreConstant.ReportMenu.READING);
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.READING).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        } else if (item.keySet().contains(CoreConstant.ReportMenu.SEX)) {
          // 性別
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey = "pat_sex";
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.SEX).toString();
          tmpSortKey.add(index,"pat_sex");
          sortKeyName.add(index,CoreConstant.ReportMenu.SEX);
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.SEX).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        } else if (item.keySet().contains(CoreConstant.ReportMenu.BLOOD_TYPE)) {
          // 血液型
          //mod #9323 donghao start
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
          //tmpSortKey = "pat_blood_type_abo";
          tmpSortKey.add(index,"pat_blood_type_abo");
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end
          newTmpSortKey = new String[]{"pat_blood_type_abo","pat_blood_type_rh"};
          //mod #9323 donghao end

          // del #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.BLOOD_TYPE).toString();
          // del #9323 帳票「並び替え」機能のオーバーホール　高 end
          // add #9323 帳票「並び替え」機能のオーバーホール　高 start
          sortKeyName.add(index,CoreConstant.ReportMenu.BLOOD_TYPE);
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.BLOOD_TYPE).toString());
          // add #9323 帳票「並び替え」機能のオーバーホール　高 end

        } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_BED)) {
          // ベッド表示順
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey = "bed_order";
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.PATIENT_BED).toString();
          tmpSortKey.add(index,"bed_order");
          sortKeyName.add(index,CoreConstant.ReportMenu.PATIENT_BED);
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_BED).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_COOL)) {
          // クール表示順
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey = "kur_order";
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.PATIENT_COOL).toString();
          tmpSortKey.add(index,"kur_order");
          sortKeyName.add(index,CoreConstant.ReportMenu.PATIENT_COOL);
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_COOL).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        }else if (item.keySet().contains(CoreConstant.ReportMenu.ROOM_BED_GROUP)) {
          // ベッドグループ表示順
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey = "bed_group_order";
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.ROOM_BED_GROUP).toString();
          tmpSortKey.add(index,"bed_group_order");
          sortKeyName.add(index,CoreConstant.ReportMenu.ROOM_BED_GROUP);
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.ROOM_BED_GROUP).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        }else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_GROUP)) {
          // 患者グループ表示順
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey = "pat_group_order";
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.PATIENT_GROUP).toString();
          tmpSortKey.add(index,"pat_group_order");
          sortKeyName.add(index,CoreConstant.ReportMenu.PATIENT_GROUP);
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_GROUP).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        }else if (item.keySet().contains(CoreConstant.ReportMenu.RST_START_DATE)) {
          // 透析開始
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey = "start_time";
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.RST_START_DATE).toString();
          tmpSortKey.add(index,"start_time");
          sortKeyName.add(index,CoreConstant.ReportMenu.RST_START_DATE);
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.RST_START_DATE).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        }else if (item.keySet().contains(CoreConstant.ReportMenu.RST_END_DATE)) {
          // 透析終了
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey = "end_time";
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.RST_END_DATE).toString();
          tmpSortKey.add(index,"end_time");
          sortKeyName.add(index,CoreConstant.ReportMenu.RST_END_DATE);
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.RST_END_DATE).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        }else if (item.keySet().contains(CoreConstant.ReportMenu.IND_END_DATE)) {
          // 透析開始
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey = "ind_end_date";
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.IND_END_DATE).toString();
          tmpSortKey.add(index,"ind_end_date");
          sortKeyName.add(index,CoreConstant.ReportMenu.IND_END_DATE);
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.IND_END_DATE).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        }else if (item.keySet().contains(CoreConstant.ReportMenu.IND_END_DATE_TIME)) {
          // 透析終了
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey = "ind_end_date_time";
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.IND_END_DATE_TIME).toString();
          tmpSortKey.add(index,"ind_end_date_time");
          sortKeyName.add(index,CoreConstant.ReportMenu.IND_END_DATE_TIME);
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.IND_END_DATE_TIME).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        }
        // mod #9323 donghao start
//        // 並び替え
//        if (!tmpSortKey.equals("")) {
//          final String sortKey = tmpSortKey;
//          final String sortDirection = tmpSortDirection;
//          tmpList = tmpList.stream().sorted((patA, patB) -> {
//            if ("asc".equals(sortDirection)) {
//              return patA.get(sortKey).toString().compareTo(patB.get(sortKey).toString());
//            } else {
//              return patA.get(sortKey).toString().compareTo(patB.get(sortKey).toString()) * -1;
//            }
//          }).collect(Collectors.toList());
//
//          // ソート対象のデータが存在しないデータを最下段に寄せる
//          List<JSONObject> list = new ArrayList<>();
//          List<JSONObject> empList = new ArrayList<>();
//          for (JSONObject tmpJson : tmpList) {
//            if (tmpJson.getString(sortKey).equals("")) {
//              empList.add(tmpJson);
//            } else {
//              list.add(tmpJson);
//            }
//          }
//          list.addAll(empList);
//          tmpList = list;
//        }
//      }
        // del #9323 帳票「並び替え」機能のオーバーホール　高 start
        // 血液型
//        if (item.keySet().contains(CoreConstant.ReportMenu.BLOOD_TYPE)) {
//          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          final String sortKeyOne = newTmpSortKey[0];
//          final String sortKeyTwo = newTmpSortKey[1];
//          final String sortDirection = tmpSortDirection;
//          for (int num = 0;num < tmpList.size();num++){
//            if (tmpList.get(num).get(sortKeyOne).equals("0")) {
//              tmpList.get(num).put(sortKeyOne,"5");
//            }
//            if (tmpList.get(num).get(sortKeyTwo).equals("0")) {
//              tmpList.get(num).put(sortKeyTwo,"3");
//            }
//          }
//          tmpList = tmpList.stream().sorted((patA, patB) -> {
//            if (patA.get(sortKeyOne) != null && patA.get(sortKeyOne)!= "" && !patA.get(sortKeyOne).toString().equals(patB.get(sortKeyOne).toString())) {
//              if ("asc".equals(sortDirection)) {
//                return patA.get(sortKeyOne).toString().compareTo(patB.get(sortKeyOne).toString());
//              } else {
//                return patA.get(sortKeyOne).toString().compareTo(patB.get(sortKeyOne).toString()) * -1;
//              }
//            } else {
//              if ("asc".equals(sortDirection)) {
//                return patA.get(sortKeyTwo).toString().compareTo(patB.get(sortKeyTwo).toString());
//              } else {
//                return patA.get(sortKeyTwo).toString().compareTo(patB.get(sortKeyTwo).toString()) * -1;
//              }
//            }
//          }).collect(Collectors.toList());
//
//          // ソート対象のデータが存在しないデータを最下段に寄せる
//          List<JSONObject> list = new ArrayList<>();
//          List<JSONObject> empList = new ArrayList<>();
//          for (JSONObject tmpJson : tmpList) {
//            if (tmpJson.getString(sortKeyOne).equals("") || tmpJson.getString(sortKeyTwo).equals("") ) {
//              empList.add(tmpJson);
//            } else {
//              list.add(tmpJson);
//            }
//          }
//          list.addAll(empList);
//          tmpList = list;
//          for (int j=0;j<newTmpSortKey.length;j++){
//            final String sortKey = newTmpSortKey[j];
//            final String sortDirection = tmpSortDirection;
//            tmpList = tmpList.stream().sorted((patA, patB) -> {
//              if ("asc".equals(sortDirection)) {
//                return patA.get(sortKey).toString().compareTo(patB.get(sortKey).toString());
//              } else {
//                return patA.get(sortKey).toString().compareTo(patB.get(sortKey).toString()) * -1;
//              }
//            }).collect(Collectors.toList());
//            // ソート対象のデータが存在しないデータを最下段に寄せる
//            List<JSONObject> list = new ArrayList<>();
//            List<JSONObject> empList = new ArrayList<>();
//            for (JSONObject tmpJson : tmpList) {
//              if (tmpJson.getString(sortKey).equals("")) {
//                empList.add(tmpJson);
//              } else {
//                list.add(tmpJson);
//              }
//            }
//            list.addAll(empList);
//            tmpList = list;
//          }
//        }
      }
      // mod #9323 donghao end
      // del #9323 帳票「並び替え」機能のオーバーホール　高 end

      // add #9323 帳票「並び替え」機能のオーバーホール　高 start
      // 血液型
      List sortKey = tmpSortKey;
      List sortDirection = tmpSortDirection;
      String sortKeyOne = "";
      String sortKeyTwo = "";
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//        if (sortKeyName.contains(CoreConstant.ReportMenu.BLOOD_TYPE)) {
        if (sortKeyName.contains(CoreConstant.ReportMenu.BLOOD_TYPE)&& sortDirection.get(sortKey.indexOf("pat_blood_type_abo")).equals("asc")) {
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end
        sortKeyOne = newTmpSortKey[0];
        sortKeyTwo = newTmpSortKey[1];
        for (int num = 0;num < tmpList.size();num++){
          if (tmpList.get(num).get(sortKeyOne).equals("0")) {
            tmpList.get(num).put(sortKeyOne,"5");
          }
          if (tmpList.get(num).get(sortKeyTwo).equals("0")) {
            tmpList.get(num).put(sortKeyTwo,"3");
          }
        }
      }
        // add #9323 帳票「並び替え」機能のオーバーホール　高 start
        else if (sortKeyName.contains(CoreConstant.ReportMenu.BLOOD_TYPE)&& sortDirection.get(sortKey.indexOf("pat_blood_type_abo")).equals("desc")) {
          sortKeyOne = newTmpSortKey[0];
          sortKeyTwo = newTmpSortKey[1];
          for (int num = 0;num < tmpList.size();num++){
            if (tmpList.get(num).get(sortKeyOne).equals("0")) {
              tmpList.get(num).put(sortKeyOne,"-5");
            }
            if (tmpList.get(num).get(sortKeyTwo).equals("0")) {
              tmpList.get(num).put(sortKeyTwo,"-3");
            }
          }
        }
        // add #9323 帳票「並び替え」機能のオーバーホール　高 end
        // del #9323 帳票「並び替え」機能のオーバーホール　高 start
//        if (sortKeyName.contains(CoreConstant.ReportMenu.SEX)) {
//          for (JSONObject tmpJson : tmpList) {
//            if (tmpJson.get("pat_sex").equals("0")) {
//              tmpJson.put("pat_sex","3");
//            }
//          }
//        }
        // del #9323 帳票「並び替え」機能のオーバーホール　高 end

      // add #9323 帳票「並び替え」機能のオーバーホール　高 2024/03/06 start
      // 入外区分値3(「−」はありません)値の置き換え
      if (sortKey.contains("in_out_class") && sortDirection.get(sortKey.indexOf("in_out_class")).equals("asc")) {
        for (int index = 0;index < tmpList.size();index++) {
          if (tmpList.get(index).get("in_out_class").equals("2")) {
            tmpList.get(index).put("in_out_class","999999998");
          } else if (tmpList.get(index).get("in_out_class").equals("3")) {
            tmpList.get(index).put("in_out_class","999999999");
          }
        }
      } else if (sortKey.contains("in_out_class") && sortDirection.get(sortKey.indexOf("in_out_class")).equals("desc")) {
        for (int index = 0;index < tmpList.size();index++) {
          if (tmpList.get(index).get("in_out_class").equals("2")) {
            tmpList.get(index).put("in_out_class","-999999999");
          } else if (tmpList.get(index).get("in_out_class").equals("3")) {
            tmpList.get(index).put("in_out_class","-999999998");
          }
        }
      }
      // 患者の性別値の置き換え
        // del #9323 帳票「並び替え」機能のオーバーホール　高 start
//        if (sortKey.contains("pat_sex") && sortDirection.get(sortKey.indexOf("pat_sex")).equals("asc")) {
//          for (int index = 0;index < tmpList.size();index++) {
//            if (tmpList.get(index).get("pat_sex").equals("3")) {
//              tmpList.get(index).put("pat_sex","999999999");
//            }
//          }
//        } else if (sortKey.contains("pat_sex") && sortDirection.get(sortKey.indexOf("pat_sex")).equals("desc")) {
//          for (int index = 0;index < tmpList.size();index++) {
//            if (tmpList.get(index).get("pat_sex").equals("3")) {
//              tmpList.get(index).put("pat_sex","-999999999");
//            }
//          }
//        }
        // del #9323 帳票「並び替え」機能のオーバーホール　高 end
        // add #9323 帳票「並び替え」機能のオーバーホール　高 2024/03/06 end
        // add #9323 帳票「並び替え」機能のオーバーホール　高 start
        addTmpValueForSort(sortKey,sortDirection,sortKeyName,tmpList);
        // add #9323 帳票「並び替え」機能のオーバーホール　高 end

        // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//        tmpList = MultiplePatientCompare(tmpList,sortKey,tmpSortKey,sortDirection,sortKeyOne, sortKeyTwo,sortKeyName);
        tmpList = MultiplePatientCompare(tmpList,sortKey,tmpSortKey,sortDirection,sortKeyOne, sortKeyTwo,sortKeyName);
        // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end

        // add #9323 帳票「並び替え」機能のオーバーホール　高 start
        removeTmpValueForSort(sortKey,tmpList);

        if (sortKeyName.contains(CoreConstant.ReportMenu.BLOOD_TYPE)&& sortDirection.get(sortKey.indexOf("pat_blood_type_abo")).equals("asc")) {
          sortKeyOne = newTmpSortKey[0];
          sortKeyTwo = newTmpSortKey[1];
          for (int num = 0;num < tmpList.size();num++){
            if (tmpList.get(num).get(sortKeyOne).equals("5")) {
              tmpList.get(num).put(sortKeyOne,"0");
            }
            if (tmpList.get(num).get(sortKeyTwo).equals("3")) {
              tmpList.get(num).put(sortKeyTwo,"0");
            }
          }
        } else if (sortKeyName.contains(CoreConstant.ReportMenu.BLOOD_TYPE)&& sortDirection.get(sortKey.indexOf("pat_blood_type_abo")).equals("desc")) {
          sortKeyOne = newTmpSortKey[0];
          sortKeyTwo = newTmpSortKey[1];
          for (int num = 0;num < tmpList.size();num++){
            if (tmpList.get(num).get(sortKeyOne).equals("-5")) {
              tmpList.get(num).put(sortKeyOne,"0");
            }
            if (tmpList.get(num).get(sortKeyTwo).equals("-3")) {
              tmpList.get(num).put(sortKeyTwo,"0");
            }
          }
        }
        // add #9323 帳票「並び替え」機能のオーバーホール　高 end


      // add #9323 帳票「並び替え」機能のオーバーホール　高 2024/03/06 start
      // 入外区分値3(「−」はありません)値の置き換えキャンセル
      if (sortKey.contains("in_out_class") && sortDirection.get(sortKey.indexOf("in_out_class")).equals("asc")) {
        for (int index = 0;index < tmpList.size();index++) {
          if (tmpList.get(index).get("in_out_class").equals("999999998")) {
            tmpList.get(index).put("in_out_class","2");
          } else if (tmpList.get(index).get("in_out_class").equals("999999999")) {
            tmpList.get(index).put("in_out_class","3");
          }
        }
      } else if (sortKey.contains("in_out_class") && sortDirection.get(sortKey.indexOf("in_out_class")).equals("desc")) {
        for (int index = 0;index < tmpList.size();index++) {
          if (tmpList.get(index).get("in_out_class").equals("-999999999")) {
            tmpList.get(index).put("in_out_class","2");
          } else if (tmpList.get(index).get("in_out_class").equals("-999999998")) {
            tmpList.get(index).put("in_out_class","3");
          }
        }
      }
      // 患者の性別値の置き換えキャンセル
        // del #9323 帳票「並び替え」機能のオーバーホール　高 start
//        if (sortKey.contains("pat_sex") && sortDirection.get(sortKey.indexOf("pat_sex")).equals("asc")) {
//          for (int index = 0;index < tmpList.size();index++) {
//            if (tmpList.get(index).get("pat_sex").equals("999999999")) {
//              tmpList.get(index).put("pat_sex","3");
//            }
//          }
//        } else if (sortKey.contains("pat_sex") && sortDirection.get(sortKey.indexOf("pat_sex")).equals("desc")) {
//          for (int index = 0;index < tmpList.size();index++) {
//            if (tmpList.get(index).get("pat_sex").equals("-999999999")) {
//              tmpList.get(index).put("pat_sex","3");
//            }
//          }
//        }
        // del #9323 帳票「並び替え」機能のオーバーホール　高 end
      // add #9323 帳票「並び替え」機能のオーバーホール　高 2024/03/06 end

      // ソート対象のデータが存在しないデータを最下段に寄せる
      List<JSONObject> list = new ArrayList<>();
      List<JSONObject> empList = new ArrayList<>();
      for (JSONObject tmpJson : tmpList) {
        for (int index = 0; index < sortKey.size();index++) {
          if (tmpJson.getString(sortKey.get(index).toString()).equals("")) {
            empList.add(tmpJson);
          }
        }
      }
      list.addAll(empList);
      // add #9323 帳票「並び替え」機能のオーバーホール　高 end

      // ソートしたデータを適用
      List<Long> tmpListPatId = new ArrayList<>();
      List<Long> tmpListOrdNo = new ArrayList<>();
      for (JSONObject tmpJson : tmpList) {
        tmpListPatId.add(tmpJson.getLong(patIdStr));
        tmpListOrdNo.add(tmpJson.getLong(ordNoStr));
      }
      listPatId = tmpListPatId;
      listOrdNo = tmpListOrdNo;
// add #9577 「？？？？」患者は表示されません（複数患者帳票）。 2024/03/18 高 start
      }
      // add #9577 「？？？？」患者は表示されません（複数患者帳票）。 2024/03/18 高 end
    }

    // ---------------------------------------------------------------------------

    // mod 9423-1 テンプレート繰返し時に元々値があるセルは上書きしないようにすること　吉 start
//    dataKey.put("ordNos", listOrdNo);
//    dataKey.put("patIds", listPatId);
    // del #10805 単患者帳票と複数患者帳票で、対象患者一覧と帳票出力結果が一致しない limingzhe start
//    // mod #9577 大量の空行が発生する 高　start
////    Set<Long> setOrdNoList = new HashSet<Long>(listOrdNo);
//    Set<Long> setOrdNoList = new LinkedHashSet<Long>(listOrdNo);
//    // mod #9577 大量の空行が発生する 高　end
//    List<Long> listOrdNoList = new ArrayList<Long>(setOrdNoList);
//    dataKey.put("ordNos", listOrdNoList);
    // del #10805 単患者帳票と複数患者帳票で、対象患者一覧と帳票出力結果が一致しない limingzhe end
    // mod #9577 大量の空行が発生する 高　start
//    Set<Long> setlistPatId = new HashSet<Long>(listPatId);
    // mod #9577 大量の空行が発生する 高 2024/03/01　start
//    Set<Long> setlistPatId = new LinkedHashSet<Long>(listPatId);
    // mod #9577 大量の空行が発生する 高　end
//    List<Long> listPatIdList = new ArrayList<Long>(setlistPatId);
//    dataKey.put("patIds", listPatIdList);
    // add #10805 単患者帳票と複数患者帳票で、対象患者一覧と帳票出力結果が一致しない limingzhe start
    dataKey.put("ordNos", listOrdNo);
    // add #10805 単患者帳票と複数患者帳票で、対象患者一覧と帳票出力結果が一致しない limingzhe end
    dataKey.put("patIds", listPatId);
    // mod #9577 大量の空行が発生する 高 2024/03/01　end
    // mod 9423-1 テンプレート繰返し時に元々値があるセルは上書きしないようにすること　吉 end
    dataKey.put("login", userName);
    dataKey.put("reportClass",reportClass);
    dataKey.put(ReportConstant.ReportDataKey.SORT_CONDITIONS, reportMenu.getSortCondition());
    // add #11226 患者情報系historyの取得条件見直し② (複数患者帳票) 高　start
    dataKey.put("dateKind",reportMenu.getDateKind());
    // add #11226 患者情報系historyの取得条件見直し② (複数患者帳票) 高　end

    // mod #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
//    if (reportMenu.getMedicineCdList() != null && reportMenu.getMedicineCdList().size() > 0) {
//      dataKey.put("medIds", reportMenu.getMedicineCdList());
//    } else {
//      dataKey.put("medIds", Collections.singletonList(0));
//    }
//
//    if (isDialyzer) {
//      //ダイアライザの表示
//      for(MstDialyzer item : mstInfoService.findMstDialyzerAllByFacillityCd(reportMenu.getFacilityCd())) {
//          listDia.add(item.getDialyzerCd());
//      }
//      dataKey.put("diaIds", listDia);
//    } else {
//      dataKey.put("diaIds", Collections.singletonList(0));
//    }
//
//    List<Integer> equipmentCdList = new ArrayList<>();
//    if (reportMenu.getEquipmentCdList() != null && reportMenu.getEquipmentCdList().size() > 0) {
//      equipmentCdList = reportMenu.getEquipmentCdList();
//      dataKey.put("eqIds", equipmentCdList);
//    } else {
//      dataKey.put("eqIds", Collections.singletonList(0));
//    }
    Map<String,List> searchList = this.searchMap(reportMenu.getFacilityCd());
    dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS, searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
    dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS, searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
    dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
    // mod #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end
    // del #12163 "一般撮影.放射線検査予定"項目が、複数集計帳票だと出力されない limingzhe start
    //LocalDate nowDate = LocalDate.now();
    //String nowYYYYMMDD = nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));
    //dataKey.put(ReportConstant.ReportDataKey.DATE, nowYYYYMMDD);
    // del #12163 "一般撮影.放射線検査予定"項目が、複数集計帳票だと出力されない limingzhe end
    dataKey.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
    dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate());
    dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
    dataKey.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
    dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
    dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());

    // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//    String kind ="医療材料";
//    if (null != reportMenu.getEquipmentCdList()
//        && reportMenu.getEquipmentCdList().size() == 0
//        && null !=  reportMenu.getMedicineCdList()
//        && reportMenu.getMedicineCdList().size() > 0) {
//      kind="";
//    }
//
//    if (null !=  reportMenu.getMedicineCdList() && reportMenu.getMedicineCdList().size() > 0) {
//      if ("" == kind) {
//        kind = "薬剤";
//      } else {
//        kind = kind + "·薬剤";
//      }
//    }
//    dataKey.put(ReportConstant.ReportDataKey.kind,kind);
    // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
    // add #12206 【デグレード】帳票画面で透析予測でのソートが機能しない 高 start
    dataKey.put("reportInfoIndexPatIdMap",reportInfoIndexPatIdMap);
    // add #12206 【デグレード】帳票画面で透析予測でのソートが機能しない 高 end

    // del #9577 「？？？？」患者は表示されません（複数患者帳票）。 2024/03/18 高 start
    // 期間指定、1日指定に応じて、開始日、終了日を格納
//    if (null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate()) {
//      // 1日指定
//      String day = reportMenu.getSpecifyDate().substring(6,8);
//      String date = reportMenu.getSpecifyDate();
//      Calendar calendar =Calendar.getInstance();
//      calendar.setFirstDayOfWeek(Calendar.MONDAY);
//      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
//      int week = calendar.get(Calendar.WEEK_OF_MONTH);
//      dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
//      String treatDateFormatted = date.substring(0,4) + "-" + date.substring(4,6) + "-" + date.substring(6);
//      String[] result = getStartAndEndDayByDate(treatDateFormatted);
//      String start = result[0].substring(0,4) + "年" + result[0].substring(5,7) + "月" + result[0].substring(8)+ "日";
//      String end = result[1].substring(5,7) + "月" + result[1].substring(8)+ "日";
//      dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
//      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, date.replace("/",""));
//      dataKey.put(ReportConstant.ReportDataKey.DATE_TO, date.replace("/",""));
//    } else {
//      // 期間指定
//      String day = reportMenu.getFromDate().substring(6,8);
//      String fromDate = reportMenu.getFromDate().substring(0,4) + "-" + reportMenu.getFromDate().substring(4,6) + "-" + reportMenu.getFromDate().substring(6);
//      String toDate = reportMenu.getToDate().substring(0,4) + "-" + reportMenu.getToDate().substring(4,6) + "-" + reportMenu.getToDate().substring(6);
//      Calendar calendar =Calendar.getInstance();
//      calendar.setFirstDayOfWeek(Calendar.MONDAY);
//      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
//      int week = calendar.get(Calendar.WEEK_OF_MONTH);
//      dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
//      String start = "";
//      String end = "";
//      String[] result = getStartAndEndDayByDate(fromDate);
//      start = result[0].substring(0, 4) + "年" + result[0].substring(5, 7) + "月" + result[0].substring(8)+ "日";
//      end =  result[1].substring(5, 7) + "月" + result[1].substring(8)+ "日";
//      dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
//      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate.replace("/",""));
//      dataKey.put(ReportConstant.ReportDataKey.DATE_TO, toDate.replace("/",""));
//    }
    // del #9577 「？？？？」患者は表示されません（複数患者帳票）。 2024/03/18 高 end

    // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
    requestParamEdit(reportMenu, dataKey);
    // add 11009 カテゴリ「印刷情報」の仕様調整 房 end
    // Excelデータ取得
    excelResult = reportService.getReportExcelFileForMultiPatient(reportCd, dataKey);
    return excelResult;
  }

  /**
   *
   * {@inheritDoc}
   */
  @Override
  public byte[] getExcelReportForPreparationList(ReportMenuSortContainer reportMenu, String userName) throws Exception {

    Integer reportClass = reportMenu.getReportClass();
    Boolean isDialyzer = false;

    if(reportMenu.getEquipmentCdList() != null) {
      if(reportMenu.getEquipmentCdList().contains(0)) {
        isDialyzer = true;
      }
    }

    byte[] excelResult = null;
    Long reportCd = reportMenu.getReportCd();
    List<OrdMain> patOrdNo = getOrdNoListSorted(reportMenu);
    if(null != patOrdNo && patOrdNo.size() > 0){
      for(int i = patOrdNo.size(); i > 0; i--){
        if(patOrdNo.get(i-1).getOrdNo() == 0){
          patOrdNo.remove(i-1);
        }
      }
    }

    List<Long> listPat = new ArrayList<>();
    List<Long> listOrd = new ArrayList<>();
    List<Integer> listDia = new ArrayList<>();
    for (int i = 0; i < patOrdNo.size(); i++) {
      listPat.add(patOrdNo.get(i).getPatId());
      listOrd.add(patOrdNo.get(i).getOrdNo());
    }
    Collections.sort(listPat);
    if (listPat.size() == 0 || listOrd.size() == 0) {
        return null;
    }
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("sqlTestSign", reportMenu.getSqlTestTimeStr());
    dataKey.put("login", userName);
    dataKey.put("reportClass",reportClass);
    dataKey.put(ReportConstant.ReportDataKey.SORT_CONDITIONS, reportMenu.getSortCondition());
    dataKey.put("patIds", listPat);
    dataKey.put("ordNos", listOrd);

    if (reportMenu.getMedicineCdList() != null && reportMenu.getMedicineCdList().size() > 0) {
      dataKey.put("medIds", reportMenu.getMedicineCdList());
    } else {
      dataKey.put("medIds", Collections.singletonList(0));
    }

    if (isDialyzer) {
      //ダイアライザの表示
      for(MstDialyzer item : mstInfoService.findMstDialyzerAllByFacillityCd(reportMenu.getFacilityCd())) {
          listDia.add(item.getDialyzerCd());
      }
      dataKey.put("diaIds", listDia);
    } else {
      dataKey.put("diaIds", Collections.singletonList(0));
    }

    List<Integer> equipmentCdList = new ArrayList<>();
    if (reportMenu.getEquipmentCdList() != null && reportMenu.getEquipmentCdList().size() > 0) {
      equipmentCdList = reportMenu.getEquipmentCdList();
      dataKey.put("eqIds", equipmentCdList);
    } else {
      dataKey.put("eqIds", Collections.singletonList(0));
    }
    LocalDate nowDate = LocalDate.now();
    String nowYYYYMMDD = nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));
    dataKey.put(ReportConstant.ReportDataKey.DATE, nowYYYYMMDD);
    dataKey.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
    dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate());
    dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
    dataKey.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
    dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
    dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
    // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//    String kind ="医療材料";
//    if(null != reportMenu.getEquipmentCdList() && reportMenu.getEquipmentCdList().size() == 0 && null !=  reportMenu.getMedicineCdList() && reportMenu.getMedicineCdList().size()>0){
//      kind="";
//    }
//    if(null !=  reportMenu.getMedicineCdList() && reportMenu.getMedicineCdList().size()>0){
//      if("" == kind){
//        kind="薬剤";
//      }else{
//        kind=kind+"·薬剤";
//      }
//    }
//    dataKey.put(ReportConstant.ReportDataKey.kind,kind);
    // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
    // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy start
    dataKey.put(ReportConstant.ReportDataKey.dateKind, reportMenu.getDateKind());
    dataKey.put(ReportConstant.ReportDataKey.currentPage,"");
    dataKey.put(ReportConstant.ReportDataKey.totalPages,"");
    // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy end
    // 準備リスト
    if(null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate()){
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      String day=reportMenu.getSpecifyDate().substring(6,8);
      String year = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(0, 4);
      String month = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(4, 6);
      String day = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(6,8);
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 end
      String date = reportMenu.getSpecifyDate();
      Calendar calendar =Calendar.getInstance();
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      calendar.setFirstDayOfWeek(Calendar.MONDAY);
//      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.setFirstDayOfWeek(Calendar.MONDAY);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 start
      calendar.set(Calendar.YEAR, Integer.valueOf(year));
      calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      int week = calendar.get(Calendar.WEEK_OF_MONTH);
      dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
      // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//      String treatDateFormatted = date.substring(0,4) + "-" + date.substring(4,6) + "-" + date.substring(6);
//      String[] result = getStartAndEndDayByDate(treatDateFormatted);
//      String start = result[0].substring(0,4) + "年" + result[0].substring(5,7) + "月" + result[0].substring(8)+ "日";
//      String end = result[1].substring(5,7) + "月" + result[1].substring(8)+ "日";
//      dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
      // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, date.replace("/",""));
      dataKey.put(ReportConstant.ReportDataKey.DATE_TO, date.replace("/",""));
    } else {
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      String day=reportMenu.getFromDate().substring(6,8);
      String year = reportMenu.getFromDate().replace("/","").replace("-","").substring(0, 4);
      String month = reportMenu.getFromDate().replace("/","").replace("-","").substring(4, 6);
      String day = reportMenu.getFromDate().replace("/","").replace("-","").substring(6,8);
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 end
      String fromDate = reportMenu.getFromDate().substring(0,4) + "-" + reportMenu.getFromDate().substring(4,6) + "-" + reportMenu.getFromDate().substring(6);
      String toDate = reportMenu.getToDate().substring(0,4) + "-" + reportMenu.getToDate().substring(4,6) + "-" + reportMenu.getToDate().substring(6);
      Calendar calendar =Calendar.getInstance();
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      calendar.setFirstDayOfWeek(Calendar.MONDAY);
//      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.setFirstDayOfWeek(Calendar.MONDAY);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 start
      calendar.set(Calendar.YEAR, Integer.valueOf(year));
      calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      int week = calendar.get(Calendar.WEEK_OF_MONTH);
      dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");

      // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//      String start = "";
//      String end = "";
//      if(reportClass.equals(ReportConstant.ReportClass.ONE_TOTAL_REPORT)) {
//        start = fromDate.substring(0, 4) + "年" + fromDate.substring(5, 7) + "月" + fromDate.substring(8)+ "日";
//        end =  toDate.substring(5, 7) + "月" + toDate.substring(8)+ "日";
//      } else {
//        String[] result = getStartAndEndDayByDate(fromDate);
//        start = result[0].substring(0, 4) + "年" + result[0].substring(5, 7) + "月" + result[0].substring(8)+ "日";
//        end =  result[1].substring(5, 7) + "月" + result[1].substring(8)+ "日";
//      }
//      dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
      // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate.replace("/",""));
      dataKey.put(ReportConstant.ReportDataKey.DATE_TO, toDate.replace("/",""));
    }
    // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//    excelResult = reportService.getReportExcelFile(reportCd, dataKey);
    // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
    requestParamEdit(reportMenu, dataKey);
    // add 11009 カテゴリ「印刷情報」の仕様調整 房 end
    excelResult = reportService.getReportExcelFileForPreparationList(reportCd, dataKey);
    // mod #9323 帳票「並び替え」機能のオーバーホール　高 end
    return excelResult;
  }


  /**
   *
   * {@inheritDoc}
   */
  @Override
  public byte[] getExcelReportForDistributionListBed(ReportMenuSortContainer reportMenu,String userName) throws Exception {
    Integer reportClass = reportMenu.getReportClass();
    Boolean isDialyzer = false;

    if(reportMenu.getEquipmentCdList() != null) {
      if(reportMenu.getEquipmentCdList().contains(0)) {
        isDialyzer = true;
      }
    }

    byte[] excelResult = null;
    Long reportCd = reportMenu.getReportCd();
    List<OrdMain> patOrdNo = getOrdNoListSorted(reportMenu);
    if(null != patOrdNo && patOrdNo.size() > 0){
      for(int i = patOrdNo.size(); i > 0; i--){
        if(patOrdNo.get(i-1).getOrdNo() == 0){
          patOrdNo.remove(i-1);
        }
      }
    }
    List<Long> listPat = new ArrayList<>();
    List<Long> listOrd = new ArrayList<>();
    List<Integer> listDia = new ArrayList<>();
    for (int i = 0; i < patOrdNo.size(); i++) {
      listPat.add(patOrdNo.get(i).getPatId());
      listOrd.add(patOrdNo.get(i).getOrdNo());
    }
    Collections.sort(listPat);
    if (listPat.size() == 0 || listOrd.size() == 0) {
        return null;
    }

    // add #9323 donghao start
    List<Long> patIdList = reportMenu.getPatIds();
    List<OrdMain> ordList = reportMenuDao.selectByTreatDateAndPatIds(patIdList, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
    List<Map<String, String>> sortConditions = reportMenu.getSortCondition();
    if (sortConditions != null && sortConditions.size() > 0 && patIdList.size() > 0) {
      String patIdStr = "pat_id";
      String ordNoStr = "ord_no";

      List<JSONObject> tmpList = new ArrayList<>();
      for (int idx = 0; idx < listPat.size(); idx++) {
        JSONObject jsonData = new JSONObject();
        jsonData.put(patIdStr, listPat.get(idx));
        jsonData.put(ordNoStr, listOrd.get(idx));
        jsonData.put("bed_group_order", "");
        jsonData.put("bed_order", "");
        jsonData.put("kur_order", "");
        tmpList.add(jsonData);
      }
      for (int index = 0; index < sortConditions.size(); index++) {

        // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//        Map<String, String> item = sortConditions.get(index);
        Map<String, String> item = sortConditions.get(sortConditions.size() - (index+1));
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 end
        if (item.keySet().contains(CoreConstant.ReportMenu.ROOM_BED_GROUP) ||
          item.keySet().contains(CoreConstant.ReportMenu.PATIENT_BED) ||
          item.keySet().contains(CoreConstant.ReportMenu.PATIENT_COOL)){

          // マスタデータを取得
          SelectOptions options = SelectOptions.get();
          List<MstBed> mstBedList = mstBedDao.selectByFacilityCd(reportMenu.getFacilityCd(), "1", "0");
          List<MstKur> mstKurList = mstKurDao.selectByFacilityCd(options, reportMenu.getFacilityCd(), "0");

          for (JSONObject tmpJson : tmpList) {
            String ordNo = tmpJson.get(ordNoStr).toString();

            for (OrdMain ord : ordList) {
              if (ordNo.equals(ord.getOrdNo().toString())) {

                // ベッド, ベッドグループ表示順
                for (Integer bedListIndex = 0; bedListIndex < mstBedList.size(); bedListIndex++) {
                  if (ord.getIndBedCd().toString().equals(mstBedList.get(bedListIndex).getBedCd().toString())) {
                    tmpJson.put("bed_order", String.format("%5s", bedListIndex.toString()).replace(" ", "0"));
                    Integer bedGroupIndex = 999;
                    bedGroupIndex = mstRoomBedGroupDao.selectIndexBedCdIsContain(ord.getIndBedCd().toString(), reportMenu.getFacilityCd(), "1");
                    tmpJson.put("bed_group_order", String.format("%3s", bedGroupIndex.toString()).replace(" ", "0"));
                  }
                }
                // クール
                for (Integer kurListIndex = 0; kurListIndex < mstKurList.size(); kurListIndex++ ) {
                  if (ord.getIndKurCd().toString().equals(mstKurList.get(kurListIndex).getKurCd().toString())) {
                    tmpJson.put("kur_order", String.format("%3s", kurListIndex.toString()).replace(" ", "0"));
                  }
                }

              }
            }
          }
        }
      }

      // add #9323 帳票「並び替え」機能のオーバーホール　高 start
      List tmpSortKey = new ArrayList();
      List tmpSortDirection = new ArrayList();
      // add #9323 帳票「並び替え」機能のオーバーホール　高 end
      for (int index = 0; index < sortConditions.size(); index++) {
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//        Map<String, String> item = sortConditions.get(index);
        Map<String, String> item = sortConditions.get(sortConditions.size() - (index+1));
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        // 並び替えに使用する項目を取得
        // del #9323 帳票「並び替え」機能のオーバーホール　高 start
//        String tmpSortKey = "";
//        String tmpSortDirection = "";
        // del #9323 帳票「並び替え」機能のオーバーホール　高 end

        if (item.keySet().contains(CoreConstant.ReportMenu.ROOM_BED_GROUP)) {
          // ベッドグループ表示順
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey = "bed_group_order";
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.ROOM_BED_GROUP).toString();
          tmpSortKey.add(index,"bed_group_order");
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.ROOM_BED_GROUP).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        }else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_BED)){

          // ベッド表示順
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey = "bed_order";
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.PATIENT_BED).toString();
          tmpSortKey.add(index,"bed_order");
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_BED).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        }else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_COOL)){

          // クール表示順
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey = "kur_order";
//          tmpSortDirection = item.get(CoreConstant.ReportMenu.PATIENT_COOL).toString();
          tmpSortKey.add(index,"kur_order");
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_COOL).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

        }

        // del #9323 帳票「並び替え」機能のオーバーホール　高 start
        // 並び替え
//        if (!tmpSortKey.equals("")) {
//          final String sortKey = tmpSortKey;
//          final String sortDirection = tmpSortDirection;
//          tmpList = tmpList.stream().sorted((patA, patB) -> {
//            // add #9323 帳票「並び替え」機能のオーバーホール　高 start
//            if (!patA.get(sortKey).toString().equals(patB.get(sortKey).toString()) &&
//              patA.get(sortKey).toString() != "" && patB.get(sortKey).toString() != "") {
//              // add #9323 帳票「並び替え」機能のオーバーホール　高 end
//              if ("asc".equals(sortDirection)) {
//                return patA.get(sortKey).toString().compareTo(patB.get(sortKey).toString());
//              } else {
//                return patA.get(sortKey).toString().compareTo(patB.get(sortKey).toString()) * -1;
//              }
//              // add #9323 帳票「並び替え」機能のオーバーホール　高 start
//            } else {
//              if ("asc".equals(sortDirection)) {
//                return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//              } else {
//                return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString()) * -1;
//              }
//            }
//            // add #9323 帳票「並び替え」機能のオーバーホール　高 end
//          }).collect(Collectors.toList());
//
//          // ソート対象のデータが存在しないデータを最下段に寄せる
//          List<JSONObject> list = new ArrayList<>();
//          List<JSONObject> empList = new ArrayList<>();
//          for (JSONObject tmpJson : tmpList) {
//            if (tmpJson.getString(sortKey).equals("")) {
//              empList.add(tmpJson);
//            } else {
//              list.add(tmpJson);
//            }
//          }
//          list.addAll(empList);
//          tmpList = list;
//        }
        // del #9323 帳票「並び替え」機能のオーバーホール　高 end
      }

      // add #9323 帳票「並び替え」機能のオーバーホール　高 start
      // 並び替え
      List sortKey = tmpSortKey;
      List sortDirection = tmpSortDirection;

      // add #9323 帳票「並び替え」機能のオーバーホール(帳票種別：5：配布リスト（ベッド）)　高 start
      for(int indexSort = 0;indexSort < tmpSortKey.size();indexSort++) {
        for (int index = 0; index < tmpList.size();index++) {
          if ("bed_order".equals(tmpSortKey.get(indexSort))) {
            if ("asc".equals(sortDirection.get(indexSort))) {
              if (StringUtils.isEmpty(tmpList.get(index).get("bed_order").toString())) {
                tmpList.get(index).put("bed_order","999999999");
              }
            } else if ("desc".equals(sortDirection.get(indexSort))) {
              if (StringUtils.isEmpty(tmpList.get(index).get("bed_order").toString())) {
                tmpList.get(index).put("bed_order","-999999999");
              }
            }
          } else if ("bed_group_order".equals(tmpSortKey.get(indexSort))) {
            if ("asc".equals(sortDirection.get(indexSort))) {
              // mod #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 start
//              if (StringUtils.isEmpty(tmpList.get(index).get("bed_group_order").toString())) {
              if (StringUtils.isEmpty(tmpList.get(index).get("bed_group_order").toString()) || StringUtils.isEmpty(tmpList.get(index).get("bed_group_order").toString().replace("0",""))) {
                // mod #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 end
                tmpList.get(index).put("bed_group_order","999999999");
              }
            } else if ("desc".equals(sortDirection.get(indexSort))) {
              // mod #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 start
//              if (StringUtils.isEmpty(tmpList.get(index).get("bed_group_order").toString())) {
              if (StringUtils.isEmpty(tmpList.get(index).get("bed_group_order").toString()) || StringUtils.isEmpty(tmpList.get(index).get("bed_group_order").toString().replace("0",""))) {
                // mod #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 end
                tmpList.get(index).put("bed_group_order","-999999999");
              }
            }
          } else if ("kur_order".equals(tmpSortKey.get(indexSort))) {
            if ("asc".equals(sortDirection.get(indexSort))) {
              if (StringUtils.isEmpty(tmpList.get(index).get("kur_order").toString())) {
                tmpList.get(index).put("kur_order","999999999");
              }
            } else if ("desc".equals(sortDirection.get(indexSort))) {
              if (StringUtils.isEmpty(tmpList.get(index).get("kur_order").toString())) {
                tmpList.get(index).put("kur_order","-999999999");
              }
            }
          }
        }
      }
      // add #9323 帳票「並び替え」機能のオーバーホール(帳票種別：5：配布リスト（ベッド）)　高 start

      tmpList = DistributionListBedCompare(tmpList,sortKey,sortDirection,tmpSortKey);

      // add #9323 帳票「並び替え」機能のオーバーホール(帳票種別：5：配布リスト（ベッド）)　高 start
      for(int indexSort = 0;indexSort < tmpSortKey.size();indexSort++) {
        for (int index = 0; index < tmpList.size();index++) {
          if ("bed_order".equals(tmpSortKey.get(indexSort))) {
            if ("asc".equals(sortDirection.get(indexSort))) {
              if ("999999999".equals(tmpList.get(index).get("bed_order").toString())) {
                tmpList.get(index).put("bed_order","");
              }
            } else if ("desc".equals(sortDirection.get(indexSort))) {
              if ("-999999999".equals(tmpList.get(index).get("bed_order").toString())) {
                tmpList.get(index).put("bed_order","");
              }
            }
          } else if ("bed_group_order".equals(tmpSortKey.get(indexSort))) {
            if ("asc".equals(sortDirection.get(indexSort))) {
              if ("999999999".equals(tmpList.get(index).get("bed_group_order").toString())) {
                tmpList.get(index).put("bed_group_order","");
              }
            } else if ("desc".equals(sortDirection.get(indexSort))) {
              if ("-999999999".equals(tmpList.get(index).get("bed_group_order").toString())) {
                tmpList.get(index).put("bed_group_order","");
              }
            }
          } else if ("kur_order".equals(tmpSortKey.get(indexSort))) {
            if ("asc".equals(sortDirection.get(indexSort))) {
              if ("999999999".equals(tmpList.get(index).get("kur_order").toString())) {
                tmpList.get(index).put("kur_order","");
              }
            } else if ("desc".equals(sortDirection.get(indexSort))) {
              if ("-999999999".equals(tmpList.get(index).get("kur_order").toString())) {
                tmpList.get(index).put("kur_order","");
              }
            }
          }
        }
      }
      // add #9323 帳票「並び替え」機能のオーバーホール(帳票種別：5：配布リスト（ベッド）)　高 end

      // ソート対象のデータが存在しないデータを最下段に寄せる
      List<JSONObject> list = new ArrayList<>();
      List<JSONObject> empList = new ArrayList<>();
      for (JSONObject tmpJson : tmpList) {
        for (int index = 0; index < sortKey.size();index++) {
          if (tmpJson.getString(sortKey.get(index).toString()).equals("")) {
            empList.add(tmpJson);
          }
        }
      }
      list.addAll(empList);
      // add #9323 帳票「並び替え」機能のオーバーホール　高 end

      // ソートしたデータを適用
      List<Long> tmpListPatId = new ArrayList<>();
      List<Long> tmpListOrdNo = new ArrayList<>();
      for (JSONObject tmpJson : tmpList) {
        tmpListPatId.add(tmpJson.getLong(patIdStr));
        tmpListOrdNo.add(tmpJson.getLong(ordNoStr));
      }
      listPat = tmpListPatId;
      listOrd = tmpListOrdNo;
    }
    // add #9323 donghao end

    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("sqlTestSign", reportMenu.getSqlTestTimeStr());
    dataKey.put("login", userName);
    dataKey.put("reportClass",reportClass);
    dataKey.put(ReportConstant.ReportDataKey.SORT_CONDITIONS, reportMenu.getSortCondition());
    dataKey.put("patIds", listPat);
    dataKey.put("ordNos", listOrd);

    if (reportMenu.getMedicineCdList() != null && reportMenu.getMedicineCdList().size() > 0) {
      dataKey.put("medIds", reportMenu.getMedicineCdList());
    } else {
      dataKey.put("medIds", Collections.singletonList(0));
    }

    if (isDialyzer) {
      //ダイアライザの表示
      for(MstDialyzer item : mstInfoService.findMstDialyzerAllByFacillityCd(reportMenu.getFacilityCd())) {
        listDia.add(item.getDialyzerCd());
      }
      dataKey.put("diaIds", listDia);
    } else {
      dataKey.put("diaIds", Collections.singletonList(0));
    }
    List<Integer> equipmentCdList = new ArrayList<>();
    if (reportMenu.getEquipmentCdList() != null && reportMenu.getEquipmentCdList().size() > 0) {
      equipmentCdList = reportMenu.getEquipmentCdList();
      dataKey.put("eqIds", equipmentCdList);
    } else {
      dataKey.put("eqIds", Collections.singletonList(0));
    }
    LocalDate nowDate = LocalDate.now();
    String nowYYYYMMDD = nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));
    dataKey.put(ReportConstant.ReportDataKey.DATE, nowYYYYMMDD);
    dataKey.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
    dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate());
    dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
    dataKey.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
    dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
    dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
    // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//    String kind ="医療材料";
//    if(null != reportMenu.getEquipmentCdList() && reportMenu.getEquipmentCdList().size() == 0 && null !=  reportMenu.getMedicineCdList() && reportMenu.getMedicineCdList().size()>0){
//      kind="";
//    }
//    if(null !=  reportMenu.getMedicineCdList() && reportMenu.getMedicineCdList().size()>0){
//      if("" == kind){
//        kind="薬剤";
//      }else{
//        kind=kind+"·薬剤";
//      }
//    }
//    dataKey.put(ReportConstant.ReportDataKey.kind,kind);
    // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
    // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy start
    dataKey.put(ReportConstant.ReportDataKey.dateKind, reportMenu.getDateKind());
    dataKey.put(ReportConstant.ReportDataKey.currentPage,"");
    dataKey.put(ReportConstant.ReportDataKey.totalPages,"");
    // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy end
    // 配布リスト(ベッド)
    if(null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate()){
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      String day=reportMenu.getSpecifyDate().substring(6,8);
      String year = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(0, 4);
      String month = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(4, 6);
      String day = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(6,8);
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 end
      String date = reportMenu.getSpecifyDate();
      Calendar calendar =Calendar.getInstance();
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      calendar.setFirstDayOfWeek(Calendar.MONDAY);
//      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.setFirstDayOfWeek(Calendar.MONDAY);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 start
      calendar.set(Calendar.YEAR, Integer.valueOf(year));
      calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      int week = calendar.get(Calendar.WEEK_OF_MONTH);
      dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
      // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//      String treatDateFormatted = date.substring(0,4) + "-" + date.substring(4,6) + "-" + date.substring(6);
//      String[] result = getStartAndEndDayByDate(treatDateFormatted);
//      String start = result[0].substring(0,4) + "年" + result[0].substring(5,7) + "月" + result[0].substring(8)+ "日";
//      String end = result[1].substring(5,7) + "月" + result[1].substring(8)+ "日";
//      dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
      // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, date.replace("/",""));
      dataKey.put(ReportConstant.ReportDataKey.DATE_TO, date.replace("/",""));
    }else{
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      String day=reportMenu.getFromDate().substring(6,8);
      String year = reportMenu.getFromDate().replace("/","").replace("-","").substring(0, 4);
      String month = reportMenu.getFromDate().replace("/","").replace("-","").substring(4, 6);
      String day = reportMenu.getFromDate().replace("/","").replace("-","").substring(6,8);
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 end
      String fromDate = reportMenu.getFromDate().substring(0,4) + "-" + reportMenu.getFromDate().substring(4,6) + "-" + reportMenu.getFromDate().substring(6);
      String toDate = reportMenu.getToDate().substring(0,4) + "-" + reportMenu.getToDate().substring(4,6) + "-" + reportMenu.getToDate().substring(6);
      Calendar calendar =Calendar.getInstance();
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      calendar.setFirstDayOfWeek(Calendar.MONDAY);
//      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.setFirstDayOfWeek(Calendar.MONDAY);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 start
      calendar.set(Calendar.YEAR, Integer.valueOf(year));
      calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      int week = calendar.get(Calendar.WEEK_OF_MONTH);
      dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
      // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//      String start = "";
//      String end = "";
//      if(reportClass.equals(ReportConstant.ReportClass.ONE_TOTAL_REPORT)) {
//        start = fromDate.substring(0, 4) + "年" + fromDate.substring(5, 7) + "月" + fromDate.substring(8)+ "日";
//        end =  toDate.substring(5, 7) + "月" + toDate.substring(8)+ "日";
//      } else {
//        String[] result = getStartAndEndDayByDate(fromDate);
//        start = result[0].substring(0, 4) + "年" + result[0].substring(5, 7) + "月" + result[0].substring(8)+ "日";
//        end =  result[1].substring(5, 7) + "月" + result[1].substring(8)+ "日";
//      }
//      dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
      // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate.replace("/",""));
      dataKey.put(ReportConstant.ReportDataKey.DATE_TO, toDate.replace("/",""));
    }
    // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
    requestParamEdit(reportMenu, dataKey);
    // add 11009 カテゴリ「印刷情報」の仕様調整 房 end
    // mod #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
//    excelResult = reportService.getReportExcelFileForDistributionListBed(reportCd, dataKey);
    excelResult = reportForDistributionListService.getReportExcelFileForDistributionListBed(reportCd, dataKey);
    // mod #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end
    return excelResult;
  }

  /**
   *
   * {@inheritDoc}
   */
  @Override
  public byte[] getExcelReportForDistributionListGoods(ReportMenuSortContainer reportMenu,String userName) throws Exception {
    Integer reportClass = reportMenu.getReportClass();
    Boolean isDialyzer = false;

    if(reportMenu.getEquipmentCdList() != null) {
      if(reportMenu.getEquipmentCdList().contains(0)) {
        isDialyzer = true;
      }
    }

    byte[] excelResult = null;
    Long reportCd = reportMenu.getReportCd();
    List<OrdMain> patOrdNo = getOrdNoListSorted(reportMenu);
    if(null != patOrdNo && patOrdNo.size() > 0){
      for(int i = patOrdNo.size(); i > 0; i--){
        if(patOrdNo.get(i-1).getOrdNo() == 0){
          patOrdNo.remove(i-1);
        }
      }
    }
    List<Long> listPat = new ArrayList<>();
    List<Long> listOrd = new ArrayList<>();
    List<Integer> listDia = new ArrayList<>();
    for (int i = 0; i < patOrdNo.size(); i++) {
      listPat.add(patOrdNo.get(i).getPatId());
      listOrd.add(patOrdNo.get(i).getOrdNo());
    }
    Collections.sort(listPat);
    if (listPat.size() == 0 || listOrd.size() == 0) {
        return null;
    }
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("sqlTestSign", reportMenu.getSqlTestTimeStr());
    dataKey.put("login", userName);
    dataKey.put("reportClass",reportClass);
    dataKey.put(ReportConstant.ReportDataKey.SORT_CONDITIONS, reportMenu.getSortCondition());
    dataKey.put("patIds", listPat);
    dataKey.put("ordNos", listOrd);

    if (reportMenu.getMedicineCdList() != null && reportMenu.getMedicineCdList().size() > 0) {
      dataKey.put("medIds", reportMenu.getMedicineCdList());
    } else {
      dataKey.put("medIds", Collections.singletonList(0));
    }

    if (isDialyzer) {
      //ダイアライザの表示
      for(MstDialyzer item : mstInfoService.findMstDialyzerAllByFacillityCd(reportMenu.getFacilityCd())) {
        listDia.add(item.getDialyzerCd());
      }
      dataKey.put("diaIds", listDia);
    } else {
      dataKey.put("diaIds", Collections.singletonList(0));
    }
    List<Integer> equipmentCdList = new ArrayList<>();
    if (reportMenu.getEquipmentCdList() != null && reportMenu.getEquipmentCdList().size() > 0) {
      equipmentCdList = reportMenu.getEquipmentCdList();
      dataKey.put("eqIds", equipmentCdList);
    } else {
      dataKey.put("eqIds", Collections.singletonList(0));
    }
    LocalDate nowDate = LocalDate.now();
    String nowYYYYMMDD = nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));
    dataKey.put(ReportConstant.ReportDataKey.DATE, nowYYYYMMDD);
    dataKey.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
    dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate());
    dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
    dataKey.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
    dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
    dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
    // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//    String kind ="医療材料";
//    if(null != reportMenu.getEquipmentCdList() && reportMenu.getEquipmentCdList().size() == 0 && null !=  reportMenu.getMedicineCdList() && reportMenu.getMedicineCdList().size()>0){
//      kind="";
//    }
//    if(null !=  reportMenu.getMedicineCdList() && reportMenu.getMedicineCdList().size()>0){
//      if("" == kind){
//        kind="薬剤";
//      }else{
//        kind=kind+"·薬剤";
//      }
//    }
//    dataKey.put(ReportConstant.ReportDataKey.kind,kind);
    // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
    // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy start
    dataKey.put(ReportConstant.ReportDataKey.dateKind, reportMenu.getDateKind());
    dataKey.put(ReportConstant.ReportDataKey.currentPage,"");
    dataKey.put(ReportConstant.ReportDataKey.totalPages,"");
    // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy end
    // 配布リスト(物品)
    if(null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate()){
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      String day=reportMenu.getSpecifyDate().substring(6,8);
      String year = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(0, 4);
      String month = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(4, 6);
      String day = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(6,8);
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 end
      String date = reportMenu.getSpecifyDate();
      Calendar calendar =Calendar.getInstance();
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      calendar.setFirstDayOfWeek(Calendar.MONDAY);
//      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.setFirstDayOfWeek(Calendar.MONDAY);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 start
      calendar.set(Calendar.YEAR, Integer.valueOf(year));
      calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      int week = calendar.get(Calendar.WEEK_OF_MONTH);
      dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
      // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//      String treatDateFormatted = date.substring(0,4) + "-" + date.substring(4,6) + "-" + date.substring(6);
//      String[] result = getStartAndEndDayByDate(treatDateFormatted);
//      String start = result[0].substring(0,4) + "年" + result[0].substring(5,7) + "月" + result[0].substring(8)+ "日";
//      String end = result[1].substring(5,7) + "月" + result[1].substring(8)+ "日";
//      dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
      // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, date.replace("/",""));
      dataKey.put(ReportConstant.ReportDataKey.DATE_TO, date.replace("/",""));
    }else{
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      String day=reportMenu.getFromDate().substring(6,8);
      String year = reportMenu.getFromDate().replace("/","").replace("-","").substring(0, 4);
      String month = reportMenu.getFromDate().replace("/","").replace("-","").substring(4, 6);
      String day = reportMenu.getFromDate().replace("/","").replace("-","").substring(6,8);
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 end
      String fromDate = reportMenu.getFromDate().substring(0,4) + "-" + reportMenu.getFromDate().substring(4,6) + "-" + reportMenu.getFromDate().substring(6);
      String toDate = reportMenu.getToDate().substring(0,4) + "-" + reportMenu.getToDate().substring(4,6) + "-" + reportMenu.getToDate().substring(6);
      Calendar calendar =Calendar.getInstance();
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      calendar.setFirstDayOfWeek(Calendar.MONDAY);
//      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.setFirstDayOfWeek(Calendar.MONDAY);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 start
      calendar.set(Calendar.YEAR, Integer.valueOf(year));
      calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      int week = calendar.get(Calendar.WEEK_OF_MONTH);
      dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
      // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//      String start = "";
//      String end = "";
//      if(reportClass.equals(ReportConstant.ReportClass.ONE_TOTAL_REPORT)) {
//        start = fromDate.substring(0, 4) + "年" + fromDate.substring(5, 7) + "月" + fromDate.substring(8)+ "日";
//        end =  toDate.substring(5, 7) + "月" + toDate.substring(8)+ "日";
//      } else {
//        String[] result = getStartAndEndDayByDate(fromDate);
//        start = result[0].substring(0, 4) + "年" + result[0].substring(5, 7) + "月" + result[0].substring(8)+ "日";
//        end =  result[1].substring(5, 7) + "月" + result[1].substring(8)+ "日";
//      }
//      dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
      // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate.replace("/",""));
      dataKey.put(ReportConstant.ReportDataKey.DATE_TO, toDate.replace("/",""));
    }
    // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
    requestParamEdit(reportMenu, dataKey);
    // add 11009 カテゴリ「印刷情報」の仕様調整 房 end
    // mod #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
//    excelResult = reportService.getReportExcelFileForDistributionListGoods(reportCd, dataKey);
    excelResult = reportForDistributionListService.getReportExcelFileForDistributionListGoods(reportCd, dataKey);
    // mod #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end
    return excelResult;
  }

  /**
   *
   * {@inheritDoc}
   */
  @Override
  public byte[] getExcelReportForLabelReport(ReportMenuSortContainer reportMenu,String userName) throws Exception {
    Integer reportClass = reportMenu.getReportClass();
    Boolean isDialyzer = false;

    if(reportMenu.getEquipmentCdList() != null) {
      if(reportMenu.getEquipmentCdList().contains(0)) {
        isDialyzer = true;
      }
    }

    byte[] excelResult = null;
    Long reportCd = reportMenu.getReportCd();
    List<OrdMain> patOrdNo = getOrdNoListSorted(reportMenu);
    List<Long> listPat = new ArrayList<>();
    List<Long> listOrd = new ArrayList<>();
    List<Integer> listDia = new ArrayList<>();
    for (int i = 0; i < patOrdNo.size(); i++) {
      if (!listPat.contains(patOrdNo.get(i).getPatId())) {
        listPat.add(patOrdNo.get(i).getPatId());
      }
      listOrd.add(patOrdNo.get(i).getOrdNo());
    }
    Collections.sort(listPat);
    if (listPat.size() == 0 || listOrd.size() == 0) {
        return null;
    }
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("sqlTestSign", reportMenu.getSqlTestTimeStr());
    dataKey.put("login", userName);
    dataKey.put("reportClass",reportClass);
    dataKey.put(ReportConstant.ReportDataKey.SORT_CONDITIONS, reportMenu.getSortCondition());
    dataKey.put("patIds", listPat);
    dataKey.put("ordNos", listOrd);

    if (reportMenu.getMedicineCdList() != null && reportMenu.getMedicineCdList().size() > 0) {
      dataKey.put("medIds", reportMenu.getMedicineCdList());
    } else {
      dataKey.put("medIds", Collections.singletonList(0));
    }

    if (isDialyzer) {
      //ダイアライザの表示
      for(MstDialyzer item : mstInfoService.findMstDialyzerAllByFacillityCd(reportMenu.getFacilityCd())) {
        listDia.add(item.getDialyzerCd());
      }
      dataKey.put("diaIds", listDia);
    } else {
      dataKey.put("diaIds", Collections.singletonList(0));
    }
    List<Integer> equipmentCdList = new ArrayList<>();
    if (reportMenu.getEquipmentCdList() != null && reportMenu.getEquipmentCdList().size() > 0) {
      equipmentCdList = reportMenu.getEquipmentCdList();
      dataKey.put("eqIds", equipmentCdList);
    } else {
      dataKey.put("eqIds", Collections.singletonList(0));
    }

    // add #11603 検査予定のラベル出力とフィルタ機能 高 start
    // 検査セット
    List<Integer> examSetCdList = new ArrayList<>();
    if (reportMenu.getExamSetCdList() != null && reportMenu.getExamSetCdList().size() > 0) {
      examSetCdList = reportMenu.getExamSetCdList();
      dataKey.put("esIds", examSetCdList);
    } else {
      dataKey.put("esIds", Collections.singletonList(0));
    }

    List<String> regOrderClassList = new ArrayList<>();
    if (reportMenu.getRegOrderClassList() != null && reportMenu.getRegOrderClassList().size() > 0) {
      regOrderClassList = reportMenu.getRegOrderClassList();
      dataKey.put("regOrderClass", regOrderClassList);
    } else {
      dataKey.put("regOrderClass", new ArrayList<String>(Arrays.asList("1","2","0")));
    }
    // add #11603 検査予定のラベル出力とフィルタ機能 高 end

    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
    List<Integer> inspectionCdList = new ArrayList<>();
    if (reportMenu.getInspectionCdList() != null && reportMenu.getInspectionCdList().size() > 0) {
      inspectionCdList = reportMenu.getInspectionCdList();
      dataKey.put(ReportConstant.ReportDataKey.INSPECT_IDS, inspectionCdList);
    } else {
      dataKey.put(ReportConstant.ReportDataKey.INSPECT_IDS, Collections.singletonList(0));
    }
    // add #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end

    // del #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
//    LocalDate nowDate = LocalDate.now();
//    String nowYYYYMMDD = nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));
//    dataKey.put(ReportConstant.ReportDataKey.DATE, nowYYYYMMDD);
    // del #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end
    dataKey.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
    dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate());
    dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
    dataKey.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
    dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
    dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
    // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//    String kind ="医療材料";
//    if(null != reportMenu.getEquipmentCdList() && reportMenu.getEquipmentCdList().size() == 0 && null !=  reportMenu.getMedicineCdList() && reportMenu.getMedicineCdList().size()>0){
//      kind="";
//    }
//    if(null !=  reportMenu.getMedicineCdList() && reportMenu.getMedicineCdList().size()>0){
//      if("" == kind){
//        kind="薬剤";
//      }else{
//        kind=kind+"·薬剤";
//      }
//    }
//    dataKey.put(ReportConstant.ReportDataKey.kind,kind);
    // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
    // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy start
    dataKey.put(ReportConstant.ReportDataKey.dateKind, reportMenu.getDateKind());
    dataKey.put(ReportConstant.ReportDataKey.currentPage,"");
    dataKey.put(ReportConstant.ReportDataKey.totalPages,"");
    // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy end
    // ラベル
    if(null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate()){
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      String day=reportMenu.getSpecifyDate().substring(6,8);
      String year = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(0, 4);
      String month = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(4, 6);
      String day = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(6,8);
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 end
      String date = reportMenu.getSpecifyDate();
      Calendar calendar =Calendar.getInstance();
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      calendar.setFirstDayOfWeek(Calendar.MONDAY);
//      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.setFirstDayOfWeek(Calendar.MONDAY);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 start
      calendar.set(Calendar.YEAR, Integer.valueOf(year));
      calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      int week = calendar.get(Calendar.WEEK_OF_MONTH);
      dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
      // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//      String treatDateFormatted = date.substring(0,4) + "-" + date.substring(4,6) + "-" + date.substring(6);
//      String[] result = getStartAndEndDayByDate(treatDateFormatted);
//      String start = result[0].substring(0,4) + "年" + result[0].substring(5,7) + "月" + result[0].substring(8)+ "日";
//      String end = result[1].substring(5,7) + "月" + result[1].substring(8)+ "日";
//      dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
      // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, date.replace("/",""));
      dataKey.put(ReportConstant.ReportDataKey.DATE_TO, date.replace("/",""));
      // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
      dataKey.put(ReportConstant.ReportDataKey.DATE, date.replace("/",""));
      // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end
    }else{
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      String day=reportMenu.getFromDate().substring(6,8);
      String year = reportMenu.getFromDate().replace("/","").replace("-","").substring(0, 4);
      String month = reportMenu.getFromDate().replace("/","").replace("-","").substring(4, 6);
      String day = reportMenu.getFromDate().replace("/","").replace("-","").substring(6,8);
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 end
      String fromDate = reportMenu.getFromDate().substring(0,4) + "-" + reportMenu.getFromDate().substring(4,6) + "-" + reportMenu.getFromDate().substring(6);
      String toDate = reportMenu.getToDate().substring(0,4) + "-" + reportMenu.getToDate().substring(4,6) + "-" + reportMenu.getToDate().substring(6);
      Calendar calendar =Calendar.getInstance();
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      calendar.setFirstDayOfWeek(Calendar.MONDAY);
//      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.setFirstDayOfWeek(Calendar.MONDAY);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 start
      calendar.set(Calendar.YEAR, Integer.valueOf(year));
      calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      int week = calendar.get(Calendar.WEEK_OF_MONTH);
      dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
      // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//      String start = "";
//      String end = "";
//      if(reportClass.equals(ReportConstant.ReportClass.ONE_TOTAL_REPORT)) {
//        start = fromDate.substring(0, 4) + "年" + fromDate.substring(5, 7) + "月" + fromDate.substring(8)+ "日";
//        end =  toDate.substring(5, 7) + "月" + toDate.substring(8)+ "日";
//      } else {
//        String[] result = getStartAndEndDayByDate(fromDate);
//        start = result[0].substring(0, 4) + "年" + result[0].substring(5, 7) + "月" + result[0].substring(8)+ "日";
//        end =  result[1].substring(5, 7) + "月" + result[1].substring(8)+ "日";
//      }
//      dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
      // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate.replace("/",""));
      dataKey.put(ReportConstant.ReportDataKey.DATE_TO, toDate.replace("/",""));
      // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
      dataKey.put(ReportConstant.ReportDataKey.DATE, fromDate.replace("/",""));
      // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end
    }
    if(reportClass.equals(ReportConstant.ReportClass.LABEL_REPORT)){
      MstReport mstReport = getMstReport(reportMenu.getReportCd());
      ReportZipFile reportZipFile = getReportZip(mstReport);
      String reportXml = getReportXml(mstReport, reportZipFile);
      List<ReportXmlParam> params = ReportUtils.getParamElements(reportXml);
      final ReportXmlTmplRepeat reportXmlTmplRepeat = params.get(0).getReportXmlTmplRepeat();
      if (reportXmlTmplRepeat.getRepeatMax() < reportMenu.getStPos()) {
        reportMenu.setStPos(1);
      }
      dataKey.put("stPos", reportMenu.getStPos());
    }
    // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
    requestParamEdit(reportMenu, dataKey);
    // add 11009 カテゴリ「印刷情報」の仕様調整 房 end
    // mod #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
//    excelResult = reportService.getReportExcelFileForLabelReport(reportCd, dataKey);
    excelResult = reportForLabelReportService.getReportExcelFileForLabelReport(reportCd, dataKey);
    // mod #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end
    return excelResult;
  }

  /**
   *
   * {@inheritDoc}
   */
  @Override
  // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
//  public byte[] getExcelReportForIntroductionReport(ReportMenuSortContainer reportMenu,String userName) throws Exception {
  public List<Map<Long, List<byte[]>>> getExcelReportForIntroductionReport(ReportMenuSortContainer reportMenu,String userName) throws Exception {
    // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end
    Integer reportClass = reportMenu.getReportClass();
    // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
    // reportType [1:紹介状集計, 2:紹介状]
    Integer reportType = Integer.parseInt(reportMenu.getReportType());
    // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
    // del #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
//    Boolean isDialyzer = false;
//
//    if(reportMenu.getEquipmentCdList() != null) {
//      if(reportMenu.getEquipmentCdList().contains(0)) {
//        isDialyzer = true;
//      }
//    }
    // del #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end
    // del 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
//    byte[] excelResult = null;
    // del 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end
    Long reportCd = reportMenu.getReportCd();
    List<OrdMain> patOrdNo = getOrdNoListSorted(reportMenu);
    // del #11276 キー日付に対するデータ引き当て仕様対応 高　start
//    if(null != patOrdNo && patOrdNo.size() > 0){
//      for(int i = patOrdNo.size(); i > 0; i--){
//        if(patOrdNo.get(i-1).getOrdNo() == 0){
//          patOrdNo.remove(i-1);
//        }
//      }
//    }
    // del #11276 キー日付に対するデータ引き当て仕様対応 高　end
    // del 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
//    List<Long> listPat = new ArrayList<>();
//    List<Long> listOrd = new ArrayList<>();
    // del 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end
    List<Integer> listDia = new ArrayList<>();
    // add 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
    List repeatPatId = new ArrayList();
    for (int i = 0; i < patOrdNo.size(); i++) {
      if (!repeatPatId.contains(patOrdNo.get(i).getPatId())) {
        repeatPatId.add(patOrdNo.get(i).getPatId());
      }
      // add 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end
      // del 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
//      for (int i = 0; i < patOrdNo.size(); i++) {
//        listPat.add(patOrdNo.get(i).getPatId());
//        listOrd.add(patOrdNo.get(i).getOrdNo());
//      }
//      Collections.sort(listPat);
//      if (listPat.size() == 0 || listOrd.size() == 0) {
//        return null;
//      }
      // del 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end
    }
    // add #9323 donghao start
    // 期間指定、1日指定に応じて、開始日、終了日を格納
    LocalDateTime localDateFrom = null;
    LocalDateTime localDateTo = null;
    if (reportMenu.getSpecifyDate() == null) {
      // 期間指定
      localDateFrom = LocalDate.parse(reportMenu.getFromDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
      localDateTo = LocalDate.parse(reportMenu.getToDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
      localDateTo = localDateTo.plusDays(1L).minusNanos(1000);
    } else {
      // 1日指定
      localDateFrom = LocalDate.parse(reportMenu.getSpecifyDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
      localDateTo = localDateFrom.plusDays(1L).minusNanos(1000);
    }

    List<JSONObject> tmpList = new ArrayList<>();
    List<Map<String, String>> sortConditions = reportMenu.getSortCondition();
    String patIdStr = "pat_id";
    String ordNoStr = "ord_no";

    for (int idx = 0; idx < repeatPatId.size(); idx++) {
      JSONObject jsonData = new JSONObject();
      jsonData.put(patIdStr, repeatPatId.get(idx));
      jsonData.put(ordNoStr, patOrdNo.get(idx).getOrdNo());
      jsonData.put("treat_date", "");
      jsonData.put("hosp_pat_id", "");
      jsonData.put("in_out_class", "");
      jsonData.put("is_infect", "");
      tmpList.add(jsonData);
    }

    boolean ppmhPassedFlg = false;
    for (int index = 0; index < sortConditions.size(); index++) {
      // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//      Map<String, String> item = sortConditions.get(index);
      Map<String, String> item = sortConditions.get(sortConditions.size() - (index+1));
      // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

      if (item.keySet().contains(CoreConstant.ReportMenu.DIALYSIS_DAY)) {

        Config config = defaultDbConfig;
        SelectBuilder builder = SelectBuilder.newInstance(config);
        builder.sql("select pat_id, min(treat_date) as treat_date from ord_main where pat_id in (");
        for (Object patId : repeatPatId) {
          builder.param(Long.class, Long.valueOf(patId.toString()));
          builder.sql(",");
        }
        builder.removeLast();
        builder.sql(") and treat_date >= '" + localDateFrom.format(DateTimeFormatter.ofPattern("yyyyMMdd")) + "' ");
        builder.sql("and treat_date <= '" + localDateTo.format(DateTimeFormatter.ofPattern("yyyyMMdd")) + "' group by pat_id");
        List<Map<String, Object>> results = baseEntityDao.executeSql(builder);
        // 患者ID毎に透析日を格納
        for (JSONObject tmpJson : tmpList) {
          Long patId = tmpJson.getLong(patIdStr);
          for (Map<String, Object> tmpMap : results) {
            Long tmpId = Long.valueOf(tmpMap.get(patIdStr).toString());
            if (tmpId.equals(patId)) {
              tmpJson.put("treat_date", tmpMap.get("treat_date").toString());
            }
          }
        }
      } else if ((item.keySet().contains(CoreConstant.ReportMenu.PATIENT_ID) ||
        item.keySet().contains(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION)) && !ppmhPassedFlg) {

        // mongoDB検索条件作成
        String mongFromDate = localDateFrom.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")) + " 23:59:59";
        ArrayList<Bson> arr = new ArrayList<Bson>();
        arr.add(lt("up_date", mongFromDate));
        List<String> searchPatIdlist = new ArrayList<>();
        for (JSONObject tmpJson : tmpList) {
          searchPatIdlist.add(tmpJson.get(patIdStr).toString());
        }
        arr.add(in(patIdStr, searchPatIdlist));
        Bson bson = and(arr);
        // mongoDB検索処理

        FindIterable<Document> resultDocs = mongoTemplate.getCollection("pat_personal_main_history").find(bson).sort(descending("up_date"));
        // 患者ID毎に患者ID/入外区分を格納
        for (JSONObject tmpJson : tmpList) {
          String inOutClass = "";
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          inOutClass = rdMainDao.getInOutClass(reportMenu.getFacilityCd(),tmpJson.get(ordNoStr).toString(),tmpJson.get(patIdStr).toString());

          inOutClass = patPersonalMainDao.getInOutClassByPatPersonalMain(reportMenu.getFacilityCd(),tmpJson.get(patIdStr).toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end
          Document doc = resultDocs != null ? resultDocs.filter(eq(patIdStr, tmpJson.get(patIdStr).toString())).first() : new Document();
          // mod #11853 観察記録が記載されている患者で、観察記録(全体)の帳票を表示するとシステムエラーが発生する sunsy start
//          if (doc != null) {
          if (doc != null && doc.size() > 0) {
            // 患者ID ( ソート用に0埋めして格納 )
            if (doc.get("hosp_pat_id") != null)
          // mod #11853 観察記録が記載されている患者で、観察記録(全体)の帳票を表示するとシステムエラーが発生する sunsy end
              // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//            tmpJson.put("hosp_pat_id", String.format("%12s", doc.get("hosp_pat_id").toString()).replace(" ", "0"));
            tmpJson.put("hosp_pat_id", doc.get("hosp_pat_id").toString());
            // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
          }

          // 入外区分
          if (inOutClass != null) {
            // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//            tmpJson.put("in_out_class", doc.get("in_out_class"));
            tmpJson.put("in_out_class", inOutClass);
            // mod #9323 帳票「並び替え」機能のオーバーホール　高 end
          } else {
            tmpJson.put("in_out_class", "");
          }


        }
        ppmhPassedFlg= true;
      } else if (item.keySet().contains(CoreConstant.ReportMenu.INFECTIOUS_ISEASE_PATIENTS)) {
        // 感染症患者のデータを取得

        // mongoDB検索条件作成
        String mongFromDate = localDateFrom.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")) + " 23:59:59";
        ArrayList<Bson> arr = new ArrayList<Bson>();
        arr.add(lt("up_date", mongFromDate));
        List<String> list = new ArrayList<>();
        for (JSONObject tmpJson : tmpList) {
          list.add(tmpJson.get(patIdStr).toString());
        }
        arr.add(in(patIdStr, list));
        Bson bson = and(arr);
        // mongoDB検索処理
        FindIterable<Document> resultDocs = mongoTemplate.getCollection("pat_main_history").find(bson).sort(descending("up_date"));

        // 患者ID毎に感染症患者を格納
        for (JSONObject tmpJson : tmpList) {
          Document doc = resultDocs != null ? resultDocs.filter(eq(patIdStr, tmpJson.get(patIdStr).toString())).first() : new Document();
          if (doc != null) {
            // 感染症患者
            // add #11853 観察記録が記載されている患者で、観察記録(全体)の帳票を表示するとシステムエラーが発生する sunsy start
            if (doc.get("is_infect") != null)
            // add #11853 観察記録が記載されている患者で、観察記録(全体)の帳票を表示するとシステムエラーが発生する sunsy end
            tmpJson.put("is_infect", doc.get("is_infect"));
          }
        }
      }
    }

    // add #9323 帳票「並び替え」機能のオーバーホール　高 start
    // 並び替えに使用する項目を取得
    List tmpSortKey = new ArrayList();
    List tmpSortDirection = new ArrayList();
    // add #9323 帳票「並び替え」機能のオーバーホール　高 end
    for (int j = 0; j < sortConditions.size(); j++) {

      // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//      Map<String, String> item = sortConditions.get(j);
      Map<String, String> item = sortConditions.get(sortConditions.size() - (j+1));
      // mod #9323 帳票「並び替え」機能のオーバーホール　高 end
//      // 並び替えに使用する項目を取得
      // del #9323 帳票「並び替え」機能のオーバーホール　高 start
//      String tmpSortKey = "";
//      String tmpSortDirection = "";
      // del #9323 帳票「並び替え」機能のオーバーホール　高 end

      if (item.keySet().contains(CoreConstant.ReportMenu.DIALYSIS_DAY)) {
        // 透析日
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//        tmpSortKey = "treat_date";
//        tmpSortDirection = item.get(CoreConstant.ReportMenu.DIALYSIS_DAY).toString();
        tmpSortKey.add(j,"treat_date");
        tmpSortDirection.add(j,item.get(CoreConstant.ReportMenu.DIALYSIS_DAY).toString());
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

      } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_ID)) {
        // 患者ID
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//        tmpSortKey = "hosp_pat_id";
//        tmpSortDirection = item.get(CoreConstant.ReportMenu.PATIENT_ID).toString();
        tmpSortKey.add(j,"hosp_pat_id");
        tmpSortDirection.add(j,item.get(CoreConstant.ReportMenu.PATIENT_ID).toString());
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

      } else if (item.keySet().contains(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION)) {
        // 入外区分
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//        tmpSortKey = "in_out_class";
//        tmpSortDirection = item.get(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION).toString();
        tmpSortKey.add(j,"in_out_class");
        tmpSortDirection.add(j,item.get(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION).toString());
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 end

      } else if (item.keySet().contains(CoreConstant.ReportMenu.INFECTIOUS_ISEASE_PATIENTS)) {
        // 患者名
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//        tmpSortKey = "is_infect";
//        tmpSortDirection = item.get(CoreConstant.ReportMenu.INFECTIOUS_ISEASE_PATIENTS).toString();
        tmpSortKey.add(j,"is_infect");
        tmpSortDirection.add(j,item.get(CoreConstant.ReportMenu.INFECTIOUS_ISEASE_PATIENTS).toString());
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 end
      }

      // del #9323 帳票「並び替え」機能のオーバーホール　高 start
      // 並び替え
//      if (!tmpSortKey.equals("")) {
//        final String sortKey = tmpSortKey;
//        final String sortDirection = tmpSortDirection;
//        tmpList = tmpList.stream().sorted((patA, patB) -> {
//          if ("asc".equals(sortDirection)) {
//            if (patA.get(sortKey) != null && patA.get(sortKey)!= "" && !patA.get(sortKey).toString().equals(patB.get(sortKey).toString())) {
//              return patA.get(sortKey).toString().compareTo(patB.get(sortKey).toString());
//            } else {
//              return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//            }
//          } else {
//            if (patA.get(sortKey) != null && patA.get(sortKey)!= "" && !patA.get(sortKey).toString().equals(patB.get(sortKey).toString())) {
//              return patA.get(sortKey).toString().compareTo(patB.get(sortKey).toString()) * -1;
//            } else {
//              return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString()) * -1;
//            }
//          }
//        }).collect(Collectors.toList());
//
//        // ソート対象のデータが存在しないデータを最下段に寄せる
//        List<JSONObject> list = new ArrayList<>();
//        List<JSONObject> empList = new ArrayList<>();
//        for (JSONObject tmpJson : tmpList) {
//          if (tmpJson.getString(sortKey).equals("")) {
//            empList.add(tmpJson);
//          } else {
//            list.add(tmpJson);
//          }
//        }
//        list.addAll(empList);
//        tmpList = list;
//      }
      // del #9323 帳票「並び替え」機能のオーバーホール　高 end
    }
    // add #9323 帳票「並び替え」機能のオーバーホール　高 start
    List sortKey = tmpSortKey;
    List sortDirection = tmpSortDirection;
    // add #9323 帳票「並び替え」機能のオーバーホール(帳票種別：9：紹介状)　高 start
    if (sortKey.contains("in_out_class") && sortDirection.get(sortKey.indexOf("in_out_class")).equals("asc")) {
      for (int index = 0;index < tmpList.size();index++) {
        if (tmpList.get(index).get("in_out_class").equals("2")) {
          tmpList.get(index).put("in_out_class","999999998");
        } else if (tmpList.get(index).get("in_out_class").equals("3")) {
          tmpList.get(index).put("in_out_class","999999999");
        }
      }
    } else if (sortKey.contains("in_out_class") && sortDirection.get(sortKey.indexOf("in_out_class")).equals("desc")) {
      for (int index = 0;index < tmpList.size();index++) {
        if (tmpList.get(index).get("in_out_class").equals("2")) {
          tmpList.get(index).put("in_out_class","-999999999");
        } else if (tmpList.get(index).get("in_out_class").equals("3")) {
          tmpList.get(index).put("in_out_class","-999999998");
        }
      }
    }
    // add #9323 帳票「並び替え」機能のオーバーホール(帳票種別：9：紹介状)　高 end
    tmpList = IntroductionReportCompare(tmpList,sortKey,sortDirection,tmpSortKey);

    // add #9323 帳票「並び替え」機能のオーバーホール(帳票種別：9：紹介状)　高 start
    if (sortKey.contains("in_out_class") && sortDirection.get(sortKey.indexOf("in_out_class")).equals("asc")) {
      for (int index = 0;index < tmpList.size();index++) {
        if (tmpList.get(index).get("in_out_class").equals("999999998")) {
          tmpList.get(index).put("in_out_class","2");
        } else if (tmpList.get(index).get("in_out_class").equals("999999999")) {
          tmpList.get(index).put("in_out_class","3");
        }
      }
    } else if (sortKey.contains("in_out_class") && sortDirection.get(sortKey.indexOf("in_out_class")).equals("desc")) {
      for (int index = 0;index < tmpList.size();index++) {
        if (tmpList.get(index).get("in_out_class").equals("-999999999")) {
          tmpList.get(index).put("in_out_class","2");
        } else if (tmpList.get(index).get("in_out_class").equals("-999999998")) {
          tmpList.get(index).put("in_out_class","3");
        }
      }
    }
    // add #9323 帳票「並び替え」機能のオーバーホール(帳票種別：9：紹介状)　高 end
    // ソート対象のデータが存在しないデータを最下段に寄せる
    List<JSONObject> list = new ArrayList<>();
    List<JSONObject> empList = new ArrayList<>();
    for (JSONObject tmpJson : tmpList) {
      for (int index = 0; index < sortKey.size();index++) {
        if (tmpJson.getString(sortKey.get(index).toString()).equals("")) {
          empList.add(tmpJson);
        }
      }
    }
    list.addAll(empList);
    // add #9323 帳票「並び替え」機能のオーバーホール　高 end

    List<Long> tmpListPatId = new ArrayList<>();
    for (JSONObject tmpJson : tmpList) {
      tmpListPatId.add(tmpJson.getLong(patIdStr));
    }
    repeatPatId = tmpListPatId;
    // add #9323 donghao end
    // add #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe start
    List<OrdMain> ordList = reportMenuDao.selectByTreatDateAndPatIds(reportMenu.getPatIds(), reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
    // add #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe end
    Map<String, Object> dataKey = new HashMap<>();
    dataKey.put("sqlTestSign", reportMenu.getSqlTestTimeStr());
    dataKey.put("login", userName);
    dataKey.put("reportClass",reportClass);
    dataKey.put(ReportConstant.ReportDataKey.SORT_CONDITIONS, reportMenu.getSortCondition());
    // del 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
//    dataKey.put("patIds", listPat);
//    dataKey.put("ordNos", listOrd);
    // del 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end

    // mod #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe start
//    if (reportMenu.getMedicineCdList() != null && reportMenu.getMedicineCdList().size() > 0) {
//      dataKey.put("medIds", reportMenu.getMedicineCdList());
//    } else {
//      dataKey.put("medIds", Collections.singletonList(0));
//    }
//
//    if (isDialyzer) {
//      //ダイアライザの表示
//      for(MstDialyzer item : mstInfoService.findMstDialyzerAllByFacillityCd(reportMenu.getFacilityCd())) {
//        listDia.add(item.getDialyzerCd());
//      }
//      dataKey.put("diaIds", listDia);
//    } else {
//      dataKey.put("diaIds", Collections.singletonList(0));
//    }
//    List<Integer> equipmentCdList = new ArrayList<>();
//    if (reportMenu.getEquipmentCdList() != null && reportMenu.getEquipmentCdList().size() > 0) {
//      equipmentCdList = reportMenu.getEquipmentCdList();
//      dataKey.put("eqIds", equipmentCdList);
//    } else {
//      dataKey.put("eqIds", Collections.singletonList(0));
//    }
    Map<String,List> searchList = this.searchMap(reportMenu.getFacilityCd());
    dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS, searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
    dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS, searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
    dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
    // mod #11035 ラベルでデータ抽出条件の「採血管」が常に出力される limingzhe end

    // del #12163 "一般撮影.放射線検査予定"項目が、複数集計帳票だと出力されない limingzhe start
//    LocalDate nowDate = LocalDate.now();
//    String nowYYYYMMDD = nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));
//    dataKey.put(ReportConstant.ReportDataKey.DATE, nowYYYYMMDD);
    // del #12163 "一般撮影.放射線検査予定"項目が、複数集計帳票だと出力されない limingzhe end
    dataKey.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
    dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate());
    dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
    dataKey.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
    dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
    dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
    // del #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
//    String kind ="医療材料";
//    if(null != reportMenu.getEquipmentCdList() && reportMenu.getEquipmentCdList().size() == 0 && null !=  reportMenu.getMedicineCdList() && reportMenu.getMedicineCdList().size()>0){
//      kind="";
//    }
//    if(null !=  reportMenu.getMedicineCdList() && reportMenu.getMedicineCdList().size()>0){
//      if("" == kind){
//        kind="薬剤";
//      }else{
//        kind=kind+"·薬剤";
//      }
//    }
//    dataKey.put(ReportConstant.ReportDataKey.kind,kind);
    // del #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end
    // add #11226 患者情報系historyの取得条件見直し② limingzhe start
    dataKey.put("dateKind", reportMenu.getDateKind());
    // add #11226 患者情報系historyの取得条件見直し② limingzhe end
    // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy start
    dataKey.put(ReportConstant.ReportDataKey.reportClass,reportMenu.getReportClass());
    dataKey.put(ReportConstant.ReportDataKey.currentPage,"");
    dataKey.put(ReportConstant.ReportDataKey.totalPages,"");
    // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy end
    // 紹介状
    if(null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate()){
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      String day=reportMenu.getSpecifyDate().substring(6,8);
      String year = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(0, 4);
      String month = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(4, 6);
      String day = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(6,8);
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 end
      String date = reportMenu.getSpecifyDate();
      Calendar calendar =Calendar.getInstance();
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      calendar.setFirstDayOfWeek(Calendar.MONDAY);
//      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.setFirstDayOfWeek(Calendar.MONDAY);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 start
      calendar.set(Calendar.YEAR, Integer.valueOf(year));
      calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      int week = calendar.get(Calendar.WEEK_OF_MONTH);
      dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
      // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//      String treatDateFormatted = date.substring(0,4) + "-" + date.substring(4,6) + "-" + date.substring(6);
//      String[] result = getStartAndEndDayByDate(treatDateFormatted);
//      String start = result[0].substring(0,4) + "年" + result[0].substring(5,7) + "月" + result[0].substring(8)+ "日";
//      String end = result[1].substring(5,7) + "月" + result[1].substring(8)+ "日";
//      dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
      // del #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
      // mod #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
      //dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, date.replace("/",""));
      //dataKey.put(ReportConstant.ReportDataKey.DATE_TO, date.replace("/",""));
      //// add #12163 "一般撮影.放射線検査予定"項目が、複数集計帳票だと出力されない limingzhe start
      //dataKey.put(ReportConstant.ReportDataKey.DATE, date.replace("/",""));
      //// add #12163 "一般撮影.放射線検査予定"項目が、複数集計帳票だと出力されない limingzhe end
      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, date.replace("/","").replace("-",""));
      dataKey.put(ReportConstant.ReportDataKey.DATE_TO, date.replace("/","").replace("-",""));
      dataKey.put(ReportConstant.ReportDataKey.DATE, date.replace("/","").replace("-",""));
      // mod #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
    }else{
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      String day=reportMenu.getFromDate().substring(6,8);
      String year = reportMenu.getFromDate().replace("/","").replace("-","").substring(0, 4);
      String month = reportMenu.getFromDate().replace("/","").replace("-","").substring(4, 6);
      String day = reportMenu.getFromDate().replace("/","").replace("-","").substring(6,8);
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 end
      String fromDate = reportMenu.getFromDate().substring(0,4) + "-" + reportMenu.getFromDate().substring(4,6) + "-" + reportMenu.getFromDate().substring(6);
      String toDate = reportMenu.getToDate().substring(0,4) + "-" + reportMenu.getToDate().substring(4,6) + "-" + reportMenu.getToDate().substring(6);
      Calendar calendar =Calendar.getInstance();
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      calendar.setFirstDayOfWeek(Calendar.MONDAY);
//      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      // del #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.setFirstDayOfWeek(Calendar.MONDAY);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 start
      calendar.set(Calendar.YEAR, Integer.valueOf(year));
      calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
      // add #11009 カテゴリ「印刷情報」の仕様調整 高 end
      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
      int week = calendar.get(Calendar.WEEK_OF_MONTH);
      dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
      // del 11009 カテゴリ「印刷情報」の仕様調整 房 start
//      String start = "";
//      String end = "";
//      if(reportClass.equals(ReportConstant.ReportClass.ONE_TOTAL_REPORT)) {
//        start = fromDate.substring(0, 4) + "年" + fromDate.substring(5, 7) + "月" + fromDate.substring(8)+ "日";
//        end =  toDate.substring(5, 7) + "月" + toDate.substring(8)+ "日";
//      } else {
//        String[] result = getStartAndEndDayByDate(fromDate);
//        start = result[0].substring(0, 4) + "年" + result[0].substring(5, 7) + "月" + result[0].substring(8)+ "日";
//        end =  result[1].substring(5, 7) + "月" + result[1].substring(8)+ "日";
//      }
//      dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
      // del 11009 カテゴリ「印刷情報」の仕様調整 房 end
      // mod #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
      //dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate.replace("/",""));
      //dataKey.put(ReportConstant.ReportDataKey.DATE_TO, toDate.replace("/",""));
      //// add #12163 "一般撮影.放射線検査予定"項目が、複数集計帳票だと出力されない limingzhe start
      //dataKey.put(ReportConstant.ReportDataKey.DATE, fromDate.replace("/",""));
      //// add #12163 "一般撮影.放射線検査予定"項目が、複数集計帳票だと出力されない limingzhe end
      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate.replace("/","").replace("-",""));
      dataKey.put(ReportConstant.ReportDataKey.DATE_TO, toDate.replace("/","").replace("-",""));
      dataKey.put(ReportConstant.ReportDataKey.DATE, fromDate.replace("/","").replace("-",""));
      // mod #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
    }
    if(reportClass.equals(ReportConstant.ReportClass.LABEL_REPORT)){
      MstReport mstReport = getMstReport(reportMenu.getReportCd());
      ReportZipFile reportZipFile = getReportZip(mstReport);
      String reportXml = getReportXml(mstReport, reportZipFile);
      List<ReportXmlParam> params = ReportUtils.getParamElements(reportXml);
      final ReportXmlTmplRepeat reportXmlTmplRepeat = params.get(0).getReportXmlTmplRepeat();
      if (reportXmlTmplRepeat.getRepeatMax() < reportMenu.getStPos()) {
        reportMenu.setStPos(1);
      }
      dataKey.put("stPos", reportMenu.getStPos());
    }
    EventLogMessage LogMessage = new EventLogMessage();
    logService.log(LogLevel.INFO, LogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
    // add 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
    List<Map<Long, List<byte[]>>> excelReportList = new ArrayList<>();
    for (int index = 0; index < repeatPatId.size();index++) {
      List<Long> listPat = new ArrayList<>();
      List<Long> listOrd = new ArrayList<>();
      // mod #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe start
//      for (int i = 0; i < patOrdNo.size(); i++) {
//        if (repeatPatId.get(index).equals(patOrdNo.get(i).getPatId())) {
//          listPat.add(Long.parseLong(String.valueOf(repeatPatId.get(index))));
//          listOrd.add(patOrdNo.get(i).getOrdNo());
//        }
//      }
      for (int i = 0; i < ordList.size(); i++) {
        if (repeatPatId.get(index).equals(ordList.get(i).getPatId())) {
          listPat.add(Long.parseLong(String.valueOf(repeatPatId.get(index))));
          listOrd.add(ordList.get(i).getOrdNo());
        }
      }
      // mod #10446 テンプレート繰返しでの計算式繰返しの制限事項対応②（「=」で始まる計算式） limingzhe end
      dataKey.put("patIds", listPat);
      dataKey.put("ordNos", listOrd);
      byte[] excelResult = null;
      List<byte[]> reportExcel = new ArrayList<>();
      // add 9993 紹介状でプレビューのみ全く値が出力されないことがある　吉 start
      dataKey.put(ReportConstant.ReportDataKey.PAT_ID, repeatPatId.get(index));
      // add #10442【デグレ】帳票画面の紹介状の表示でシステムエラー 高　start
      // mod #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　start
//      List<Long> ordNoList = rdMainDao.selectOrdnoByPatId(dataKey.get("facilityCd").toString()
//        ,Long.parseLong(String.valueOf(dataKey.get("patId")))
//        , dataKey.get("fromDate").toString().replace("/", "").replace("-", "")
//        , dataKey.get("toDate").toString().replace("/", "").replace("-", ""));
      List<Long> ordNoList = rdMainDao.selectOrdnoByPatId(dataKey.get("facilityCd").toString()
        ,Long.parseLong(String.valueOf(dataKey.get("patId")))
        , dataKey.get("fromDate").toString().replace("/", "").replace("-", "")
        , dataKey.get("toDate").toString().replace("/", "").replace("-", "")
        , null);
      // mod #9558 機能帳票で正しく変数が引き渡されていない 2024/06/13 高　end
      // add #11276 キー日付に対するデータ引き当て仕様対応 高　start
      if (ordNoList.size() != 0)
      // add #11276 キー日付に対するデータ引き当て仕様対応 高　end
      dataKey.put(ReportConstant.ReportDataKey.ORD_NO, Math.toIntExact(ordNoList.get(0)));
      // add #10442【デグレ】帳票画面の紹介状の表示でシステムエラー 高　end
      // add 9993 紹介状でプレビューのみ全く値が出力されないことがある　吉 end
      // add 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end
      // add #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe start
      // 処方箋区分
      List<String> prescriptionClassList = reportMenu.getPrescriptionClassList() == null ? new ArrayList<String>(Arrays.asList("1", "2")) : reportMenu.getPrescriptionClassList();
      dataKey.put("prescriptionClassList", prescriptionClassList);
      List<OrdPrescription> ordPrescriptionList = ordPrescriptionDao.selectResultByPatIdAndDateFromTo(Long.parseLong(String.valueOf(dataKey.get("patId")))
        , reportMenu.getFacilityCd()
        , dataKey.get("fromDate").toString().replace("/", "").replace("-", "")
        , dataKey.get("toDate").toString().replace("/", "").replace("-", "")
        ,prescriptionClassList);
      List<Long> ordPrescriptionNos = new ArrayList<>();
      for (OrdPrescription rx : ordPrescriptionList) {
        ordPrescriptionNos.add(rx.getOrdPrescriptionNo());
      }
      // 処方データ取得用のパラメータ
      dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS, ordPrescriptionNos);
      // add #11277 カテゴリ「処方」を治療経過表と紹介状にも拡張する limingzhe end
      // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe start
      List<String> regOrderClassList = reportMenu.getRegOrderClassList() == null ? new ArrayList<String>(Arrays.asList("1", "2", "0")) : reportMenu.getRegOrderClassList();
      dataKey.put("regOrderClassList", regOrderClassList);
      // add #11679 複数患者帳票で「透析条件.補液量」が出ない limingzhe end
    // mod #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe start
    //excelResult = reportService.getReportExcelFileForIntroductionReport(reportCd, dataKey);
      // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
      requestParamEdit(reportMenu, dataKey);
      // add 11009 カテゴリ「印刷情報」の仕様調整 房 end
      // add #12324 紹介状の出力時にpat_eventを参照する zhao start
      // reportCdを条件として、患者情報を取得する
      List<PatEvent> patEventList = getPatEvent(reportCd, dataKey);
      if(patEventList != null && patEventList.size() > 0){
        // 帳票から遷移場合、moveFlag = 1
        dataKey.put("moveFlag", "1");
        // 初期化
        reportExcel = new ArrayList<>();
        Map<String, List<Object>> ctlNoGroup = getCtlNoGroup(patEventList);
        for (Map.Entry<String, List<Object>> entry : ctlNoGroup.entrySet()) {
          dataKey.put("ctlNo", entry.getKey());
          dataKey.put("letterDataList", entry.getValue());
          if(reportType == 1){
            dataKey.put(ReportConstant.ReportDataKey.PAT_IDS, listPat.stream().distinct().collect(Collectors.toList()));
            excelResult = reportForTotalService.getReportExcelFileForIntroductionReport(reportCd, dataKey);
          }
          else {
            excelResult = reportForIntroductionReportService.getReportExcelFileForIntroductionReport(reportCd, dataKey);
          }
          reportExcel.add(excelResult);
        }
        if (reportExcel.size() > 0) {
          Map<Long, List<byte[]>> reportMap = new HashMap<>();
          reportMap.put(Long.parseLong(String.valueOf(repeatPatId.get(index))), reportExcel);
          excelReportList.add(reportMap);
        }
      } else {
        dataKey.keySet().removeIf(key -> key.startsWith("moveFlag"));
        dataKey.keySet().removeIf(key -> key.startsWith("ctlNo"));
        dataKey.keySet().removeIf(key -> key.startsWith("letterDataList"));
        // add #12324 紹介状の出力時にpat_eventを参照する zhao end
        // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
        if(reportType == 1){
          dataKey.put(ReportConstant.ReportDataKey.PAT_IDS, listPat.stream().distinct().collect(Collectors.toList()));
          excelResult = reportForTotalService.getReportExcelFileForIntroductionReport(reportCd, dataKey);
        }
        else {
        // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
          excelResult = reportForIntroductionReportService.getReportExcelFileForIntroductionReport(reportCd, dataKey);
        // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe start
        }
        // add #12320 紹介状で集計の縦単位／横単位の値のない行省略が未対応 limingzhe end
       // mod #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe end

        reportExcel.add(excelResult);
        // add 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
        if (reportExcel.size() > 0) {
          Map<Long, List<byte[]>> reportMap = new HashMap<>();
          // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
  //        reportMap.put(patOrdNo.get(index).getPatId(), reportExcel);
          reportMap.put(Long.parseLong(String.valueOf(repeatPatId.get(index))), reportExcel);
          // mod 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 start
          excelReportList.add(reportMap);
        }
        // add #12324 紹介状の出力時にpat_eventを参照する zhao start
      }
      // add #12324 紹介状の出力時にpat_eventを参照する zhao end
    }
    return excelReportList;
    // add 9824 因島紹介状、集計帳票の集計部分のロジックに不備がある。　高 end
  }


  /**
   *
   * {@inheritDoc}
   */
  @Override
  public List<Map<Long, List<byte[]>>> getExcelReportForIntroductionReport2(ReportMenuSortContainer reportMenu, String userName) throws Exception {
    List<Map<Long, List<byte[]>>> excelReportList = new ArrayList<>();
    Long reportCd = reportMenu.getReportCd();
    HashMap<Long, List<Long>> patOrdNo = getOrdNoList(reportMenu);
    List<Integer> medicineCdList = new ArrayList<>();
    if (reportMenu.getMedicineCdList() != null && reportMenu.getMedicineCdList().size() > 0) {
      medicineCdList = reportMenu.getMedicineCdList();
    } else {
      medicineCdList = Collections.singletonList(0);
    }
    List<Integer> dialyzeeCdList = new ArrayList<>();
    if (reportMenu.getEquipmentCdList() != null && reportMenu.getEquipmentCdList().contains(0)) {
      //ダイアライザの表示
      for(MstDialyzer item : mstInfoService.findMstDialyzerAllByFacillityCd(reportMenu.getFacilityCd())) {
        dialyzeeCdList.add(item.getDialyzerCd());
      }
    } else {
      dialyzeeCdList = Collections.singletonList(0);
    }
    List<Integer> equipmentCdList = new ArrayList<>();
    if (reportMenu.getEquipmentCdList() != null && reportMenu.getEquipmentCdList().size() > 0) {
      equipmentCdList = reportMenu.getEquipmentCdList();
    } else {
      equipmentCdList = Collections.singletonList(0);
    }
    for (Long key : patOrdNo.keySet()) {
      List<byte[]> reportExcel = new ArrayList<>();
      List<Long> values = patOrdNo.get(key);
      Map<String, Object> dataKey = new HashMap<>();
      dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,medicineCdList);
      dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,dialyzeeCdList);
      dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,equipmentCdList);
      dataKey.put("ordNo", values.get(0));
      dataKey.put("patId", key.toString());
      dataKey.put("login", userName);
      dataKey.put("ordRstNos", values);
      if (null == reportMenu.getFromDate() || null ==reportMenu.getToDate()) {
        dataKey.put(ReportConstant.ReportDataKey.DATE_FROM,dateStr2dispDateStr(reportMenu.getSpecifyDate()));
        dataKey.put(ReportConstant.ReportDataKey.DATE_TO,dateStr2dispDateStr(reportMenu.getSpecifyDate()));
        dataKey.put(ReportConstant.ReportDataKey.DATE,reportMenu.getSpecifyDate());
      } else {
        dataKey.put(ReportConstant.ReportDataKey.DATE,reportMenu.getFromDate());
        dataKey.put(ReportConstant.ReportDataKey.DATE_FROM,dateStr2dispDateStr(reportMenu.getFromDate()));
        dataKey.put(ReportConstant.ReportDataKey.DATE_TO,dateStr2dispDateStr(reportMenu.getToDate()));
      }
      dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD,reportMenu.getFacilityCd());
      List<Long> prescriptionList = ordPrescriptionDao.getPrescriptionListByPatId(key,reportMenu.getFacilityCd());
      if (null != prescriptionList && prescriptionList.size() > 0) {
        dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS,prescriptionList);
      } else {
        dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS,0);
      }
      dataKey.put(ReportConstant.ReportDataKey.DATE, null != reportMenu.getSpecifyDate() ? dateStr2dispDateStr(reportMenu.getSpecifyDate()) : null);
      dataKey.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
      dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate());
      dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
      dataKey.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
      dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
      // mod #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe start
      //byte[] excelBytes = reportService.getReportExcelFileForIntroductionReport(reportCd, dataKey);
      byte[] excelBytes = reportForIntroductionReportService.getReportExcelFileForIntroductionReport(reportCd, dataKey);
      // mod #10857 帳票内に同項目が複数あると設定値を取り違える limingzhe end

      reportExcel.add(excelBytes);
      if (reportExcel.size() > 0) {
        Map<Long, List<byte[]>> reportMap = new HashMap<>();
        reportMap.put(key, reportExcel);
        excelReportList.add(reportMap);
      }
    }
    return excelReportList;
  }

  /**
   *
   * {@inheritDoc}
   */
  @Override
  public List<Map<Long, List<byte[]>>> getExcelReportForDialysisReport(ReportMenuSortContainer reportMenu, String userName) throws Exception {
    List<Map<Long, List<byte[]>>> excelReportList = new ArrayList<>();
    Long reportCd = reportMenu.getReportCd();
    List<Long> patIdList = reportMenu.getPatIds();

    // del #11737 グラフがセルサイズにフィットしないときがある 房 start
//    List<Long> listOrdNo = new ArrayList<>();
//    List<Long> listPatId = new ArrayList<>();
    // del #11737 グラフがセルサイズにフィットしないときがある 房 end
    //add #10504 一日複数回指示ある患者の治療経過表出力で空帳票が出力される 王永吉 start
    //del #11097 治療経過表(手書き)が実績のない患者で出力できない 杜 start
    boolean inOrOutFlag = false;
    //del #11097 治療経過表(手書き)が実績のない患者で出力できない 杜 end
    //add #10504 一日複数回指示ある患者の治療経過表出力で空帳票が出力される 王永吉 end
    Map<String,List> searchList = new HashMap<>();
    searchList =this.searchMap(reportMenu.getFacilityCd());
    // add #11737 グラフがセルサイズにフィットしないときがある 房 start
    List<Long> listPatId = listPatIdGet(reportMenu);
    // add #11737 グラフがセルサイズにフィットしないときがある 房 end

    // ---------------------------------------------------------------------------

    HashMap<Long, List<Long>> patOrdNo = getOrdNoList(reportMenu);
    // add #9323 donghao start

    List<Long> lstPatId = new ArrayList<>();
    if (listPatId.size() != new HashSet<>(listPatId).size()) {
      LinkedHashSet<Long> hashSet = new LinkedHashSet<>(listPatId);
      ArrayList<Long> arrPatId = new ArrayList<>(hashSet);

      lstPatId = arrPatId;
    } else {
      lstPatId = listPatId;
    }


    List<Long> newListPatId = new ArrayList();
    int pageIndex = reportMenu.getPageIndex();
    int sum = (pageIndex - 1) * 2 - 1;

    if (sum<0){
      sum=0;
    }

    int selectCount = 1;
    if(pageIndex > 1){
      selectCount = 2;
    }

    // mod #10504 一日複数回指示ある患者の治療経過表出力で空帳票が出力される 王永吉 start
//    for (int i = sum; i < sum + selectCount && i < lstPatId.size(); i++) {
//      newListPatId.add(Long.parseLong(String.valueOf(lstPatId.get(i))));
//    }
//    // add #9323 donghao end
    // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang start
    // if (optionCdFlag){
    boolean currentOptionCdFlag = optionCdFlag.get();
    optionCdFlag.remove();
    if (currentOptionCdFlag){
      // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang end
      for (int i = 0; i < lstPatId.size(); i++) {
        newListPatId.add(Long.parseLong(String.valueOf(lstPatId.get(i))));
      }
    } else {
      for (int i = sum; i < sum + selectCount && i < lstPatId.size(); i++) {
        newListPatId.add(Long.parseLong(String.valueOf(lstPatId.get(i))));
      }
    }
    // mod #10504 一日複数回指示ある患者の治療経過表出力で空帳票が出力される 王永吉 end
    // mod #9323 donghao start
    //for (Long key : listPatId) {
    for (Long key : newListPatId) {
      // mod #9323 donghao end
      // del 10510 カテゴリ「処方(最新)」を追加 sunsy start
//      boolean isLoop = true;
      // del 10510 カテゴリ「処方(最新)」を追加 sunsy end
      List<byte[]> reportExcel = new ArrayList<>();
      List<Long> values = patOrdNo.get(key);
      // add #11583 治療経過表の「処方カテゴリ」出力の修正 limingzhe start
      Map<Long, List<Long>> reportCdMap = new HashMap<>();
      // 治療経過表（手書き：自動選択） 治療経過表（自動選択）
      // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
      //if(reportCd == -3 || reportCd == -2)
      if(reportCd == CoreConstant.FixedReportCd.DIALYSIS_REPORT
        || reportCd == CoreConstant.FixedReportCd.DIALYSIS_REPORT_HANDWRITTEN
      )
      // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      {
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
        //if(reportCd == -3)
        if(reportCd == CoreConstant.FixedReportCd.DIALYSIS_REPORT)
        // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
        {
          inOrOutFlag = true;
        }
        for (int index = 0; index < values.size(); index++) {
          if (inOrOutFlag) {
            OrdMain ordNew = rdMainDao.selectByOrdNo(values.get(index));
            if ("0".equals(ordNew.getRstDialysisState())) {
              continue;
            }
          }
          Long rCd = getTemplateReportCd(reportMenu.getFacilityCd(), values.get(index), reportCd);
          MstReport report = mstReportDao.selectReportByReportCd(rCd);
          if (report == null) {
            FacilitySettingInfo info = mstFacilitySettingDao.getBySettingNoAndCd(reportMenu.getFacilityCd(), "3004");
            Long rtnValue = 0L;
            if (null != info) {
              String value = info.getValue();
              if (NumberUtils.isCreatable(value)) {
                rtnValue = Long.parseLong(value);
              }
            }
            rCd = rtnValue;
          }
          if(rCd > 0) {
            List<Long> ordNos = new ArrayList<Long>();
            if(reportCdMap.containsKey(rCd)){
              ordNos.addAll(reportCdMap.get(rCd));
            }
            ordNos.add(values.get(index));
            reportCdMap.put(rCd, ordNos);
          }
        }
        if (reportCdMap.size() == 0) {
          String error ="テンプレートが設定されていません。";
          outputErrorLog(reportMenu.getFacilityCd(), error);
          throw new NtssException(error);
        }
      }
      else {
        reportCdMap.put(reportCd, values);
      }
      Map<String, Object> dataKey = new HashMap<>();
      requestParamEdit(reportMenu, dataKey);
      dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD,reportMenu.getFacilityCd());
      if(searchList.size()>0){
        dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
        dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
        dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
      }
      else{
        List<Integer> dialyzeeCdList = new ArrayList<>();
        if (reportMenu.getEquipmentCdList() != null && reportMenu.getEquipmentCdList().contains(0)) {
          //ダイアライザの表示
          for(MstDialyzer item : mstInfoService.findMstDialyzerAllByFacillityCd(reportMenu.getFacilityCd())) {
            dialyzeeCdList.add(item.getDialyzerCd());
          }
        }else{
          dialyzeeCdList = Collections.singletonList(0);
        }
        dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,reportMenu.getMedicineCdList());
        dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,dialyzeeCdList);
        dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,reportMenu.getEquipmentCdList());
      }
      String fromDate = "";
      String toData = "";
      if(null == reportMenu.getFromDate() || null ==reportMenu.getToDate()){
        fromDate = reportMenu.getSpecifyDate();
        toData = reportMenu.getSpecifyDate();
      }else{
        fromDate = reportMenu.getFromDate();
        toData = reportMenu.getToDate();
      }
      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate);
      dataKey.put(ReportConstant.ReportDataKey.DATE_TO, toData);
      String data ="";
      if (null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate()){
        data = dateStr2dispDateStr(reportMenu.getSpecifyDate());
      } else {
        data = dateStr2dispDateStr(reportMenu.getFromDate());
      }
      dataKey.put(ReportConstant.ReportDataKey.DATE, data);
      if (null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate()) {
        // 1日指定
        String year = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(0, 4);
        String month = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(4, 6);
        String day = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(6,8);
        Calendar calendar =Calendar.getInstance();
        calendar.setFirstDayOfWeek(Calendar.MONDAY);
        calendar.set(Calendar.YEAR, Integer.valueOf(year));
        calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
        calendar.set(Calendar.DAY_OF_MONTH, Integer.valueOf(day));
        int week = calendar.get(Calendar.WEEK_OF_MONTH);
        dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
      } else {
        // 期間指定
        String year = reportMenu.getFromDate().replace("/","").replace("-","").substring(0, 4);
        String month = reportMenu.getFromDate().replace("/","").replace("-","").substring(4, 6);
        String day = reportMenu.getFromDate().replace("/","").replace("-","").substring(6,8);
        Calendar calendar =Calendar.getInstance();
        calendar.setFirstDayOfWeek(Calendar.MONDAY);
        calendar.set(Calendar.YEAR, Integer.valueOf(year));
        calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
        calendar.set(Calendar.DAY_OF_MONTH, Integer.valueOf(day));
        int week = calendar.get(Calendar.WEEK_OF_MONTH);
        dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
      }
      dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
      dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
      dataKey.put(ReportConstant.ReportDataKey.reportClass,reportMenu.getReportClass());
      dataKey.put(ReportConstant.ReportDataKey.dateKind,reportMenu.getDateKind());
      dataKey.put(ReportConstant.ReportDataKey.currentPage,"");
      dataKey.put(ReportConstant.ReportDataKey.totalPages,"");

      dataKey.put("patId", key.toString());
      List<Long> patIds = new ArrayList<Long>();
      patIds.add(key);
      dataKey.put("patIds", patIds);

      // 処方箋区分
      List<String> prescriptionClassList = reportMenu.getPrescriptionClassList() == null ? new ArrayList<String>(Arrays.asList("1", "2")) : reportMenu.getPrescriptionClassList();
      dataKey.put("prescriptionClassList", prescriptionClassList);
      List<OrdPrescription> ordPrescriptionList = ordPrescriptionDao.selectResultByPatIdAndDateFromTo(Long.parseLong(String.valueOf(dataKey.get("patId")))
        , reportMenu.getFacilityCd()
        , dataKey.get("fromDate").toString().replace("/", "").replace("-", "")
        , dataKey.get("toDate").toString().replace("/", "").replace("-", "")
        ,prescriptionClassList);
      List<Long> ordPrescriptionNos = new ArrayList<>();
      for (OrdPrescription rx : ordPrescriptionList) {
        ordPrescriptionNos.add(rx.getOrdPrescriptionNo());
      }

      for(Long rCd : reportCdMap.keySet()){
        Long pageCount = 1l;
        List<Long> ordNos = reportCdMap.get(rCd);
        if(ordNos.size() > pageCount){
          pageCount = Long.parseLong(String.valueOf(ordNos.size()));
        }

        for (int index = 0; index < pageCount; index++){
          if(ordNos.size() > index){
            dataKey.put(ReportConstant.ReportDataKey.ORD_NO, ordNos.get(index));
          }else{
            dataKey.put(ReportConstant.ReportDataKey.ORD_NO, 0);
          }
          // 処方データ取得用のパラメータ
          dataKey.put(ReportConstant.ReportDataKey.ORD_PRESCRIPTION_NOS, ordPrescriptionNos);
          byte[] excelBytes = reportService.getReportExcelFileForDialysisReport(rCd, dataKey);
          reportExcel.add(excelBytes);
        }
      }
      // mod #11583 治療経過表の「処方カテゴリ」出力の修正 limingzhe end

      if (reportExcel.size() > 0) {
        Map<Long, List<byte[]>> reportMap = new HashMap<>();
        reportMap.put(key, reportExcel);
        excelReportList.add(reportMap);
      }
    }
    return excelReportList;
  }


  /**
   *
   * {@inheritDoc}
   */
  @Override
  public List<Map<Long, List<byte[]>>> getExcelReportForMachineReport(ReportMenuSortContainer reportMenu, String userName) throws Exception {
    List<Map<Long, List<byte[]>>> excelReportList = new ArrayList<>();
    List<byte[]> reportExcel = new ArrayList<>();
    String date = "";
    Map<String, Object> dataKey = new HashMap<>();
    Map<String,List> searchList =this.searchMap(reportMenu.getFacilityCd());
    dataKey.put(ReportConstant.ReportDataKey.MEDICINE_IDS,searchList.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
    dataKey.put(ReportConstant.ReportDataKey.DIALYZER_IDS,searchList.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
    dataKey.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS,searchList.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
    // mod #11117 日常点検記録簿が1ページ1装置で出力される limingzhe start
    List<Long> machineNos = new ArrayList<>();
    // mod #11117 日常点検記録簿が1ページ1装置で出力される limingzhe end
    // add #9323 donghao start
    List<Map<String,String>> sortCondition = reportMenu.getSortCondition();
    List<JSONObject> tmpList = new ArrayList<>();
    for (int j=0; j<reportMenu.getMachines().size();j++) {
      JSONObject jsonData = new JSONObject();
      // add #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
      // 装置マスタの表示順を取得する
      String machineCdIndexNo = mstMachineDao.selectIndexNoFromMstMachine(reportMenu.getFacilityCd(),
        String.valueOf(reportMenu.getMachines().get(j).getMachineTypeCd()),
        String.valueOf(reportMenu.getMachines().get(j).getMachineSerial()));
      // add #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
      jsonData.put("machine_no", reportMenu.getMachines().get(j).getMachineNo().toString());
      // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//      jsonData.put("machine_name", reportMenu.getMachines().get(j).getMachineName());
      jsonData.put("machine_cd", machineCdIndexNo);
      // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
      // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//      jsonData.put("bed_name", reportMenu.getMachines().get(j).getBedName());
      jsonData.put("bed_name", reportMenu.getMachines().get(j).getBedName() == null ? "" : reportMenu.getMachines().get(j).getBedName());
      // mod #9323 帳票「並び替え」機能のオーバーホール　高 end
      jsonData.put("machine_Serial", reportMenu.getMachines().get(j).getMachineSerial());
      // mod #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe start
      //jsonData.put("machine_type", reportMenu.getMachines().get(j).getMachineType());
      jsonData.put("machine_type", reportMenu.getMachines().get(j).getMachineTypeCd());
      // mod #12655 機能帳票出力時に「条件保存」の内容が反映しない limingzhe end
      tmpList.add(jsonData);
      // add #11117 日常点検記録簿が1ページ1装置で出力される limingzhe start
      machineNos.add(Long.parseLong(reportMenu.getMachines().get(j).getMachineNo().toString()));
      // add #11117 日常点検記録簿が1ページ1装置で出力される limingzhe end
    }

    // add #9323 帳票「並び替え」機能のオーバーホール　高 start
    List<MstBed> mstBedList = mstBedDao.selectByFacilityCd(reportMenu.getFacilityCd(), "1", "0");
    // 期間内のordMain取得
    for (JSONObject tmpJson : tmpList) {
      String bedName = tmpJson.get("bed_name").toString();
      if (StringUtils.isEmpty(bedName)) {
        tmpJson.put("bed_order", "");
        continue;
      }
      for (Integer bedListIndex = 0; bedListIndex < mstBedList.size(); bedListIndex++ ) {
        if (bedName.equals(mstBedList.get(bedListIndex).getBedName().toString())) {
          tmpJson.put("bed_order", String.format("%5s", bedListIndex.toString()).replace(" ", "0"));
        }
      }
    }
    // add #9323 帳票「並び替え」機能のオーバーホール　高 end

    // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//    String tmpSortKey="";
//    String tmpSortDirection="";
    List tmpSortKey = new ArrayList();
    List tmpSortDirection = new ArrayList();
    // mod #9323 帳票「並び替え」機能のオーバーホール　高 end
    for (int index =0;index< sortCondition.size();index++){
      if (sortCondition.size()!=0){
        dataKey.put(ReportConstant.ReportDataKey.SORT_CONDITIONS,sortCondition);
      }
      // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//      for (Map.Entry<String,String> vv: sortCondition.get(index).entrySet()) {
      for (Map.Entry<String,String> vv: sortCondition.get(sortCondition.size() - (index+1)).entrySet()) {
        // mod #9323 帳票「並び替え」機能のオーバーホール　高 end
        if (vv.getKey() == CoreConstant.ReportMenu.MACHINE_NAME){
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey="machine_name";
//          tmpSortDirection =vv.getValue().toString();
          // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//          tmpSortKey.add(index,"machine_name");
          tmpSortKey.add(index,"machine_cd");
          // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
          tmpSortDirection.add(index,vv.getValue().toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end
        }
        else if (vv.getKey() == CoreConstant.ReportMenu.MACHINE_SERIAL){
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey="machine_Serial";
//          tmpSortDirection =vv.getValue().toString();
          tmpSortKey.add(index,"machine_Serial");
          tmpSortDirection.add(index,vv.getValue().toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end
        }
        else if (vv.getKey() == CoreConstant.ReportMenu.MACHINE_TYPE){
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey="machine_type";
//          tmpSortDirection =vv.getValue().toString();
          tmpSortKey.add(index,"machine_type");
          tmpSortDirection.add(index,vv.getValue().toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end
        }
        else if (vv.getKey() == CoreConstant.ReportMenu.BED_NAME){
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 start
//          tmpSortKey="bed_name";
//          tmpSortDirection =vv.getValue().toString();
//          tmpSortKey.add(index,"bed_name");
          tmpSortKey.add(index,"bed_order");
          tmpSortDirection.add(index,vv.getValue().toString());
          // mod #9323 帳票「並び替え」機能のオーバーホール　高 end
        }
      }

      // del #9323 帳票「並び替え」機能のオーバーホール　高 start
      // 並び替え
//      if (!tmpSortKey.equals("")) {
//        final String sortKey = tmpSortKey;
//        final String sortDirection = tmpSortDirection;
//        tmpList = tmpList.stream().sorted((patA, patB) -> {
//          if ("asc".equals(sortDirection)) {
//            return patA.get(sortKey).toString().compareTo(patB.get(sortKey).toString());
//          } else {
//            return patA.get(sortKey).toString().compareTo(patB.get(sortKey).toString()) * -1;
//          }
//        }).collect(Collectors.toList());
//
//        // ソート対象のデータが存在しないデータを最下段に寄せる
//        List<JSONObject> list = new ArrayList<>();
//        List<JSONObject> empList = new ArrayList<>();
//        for (JSONObject tmpJson : tmpList) {
//          if (tmpJson.getString(sortKey).equals("")) {
//            empList.add(tmpJson);
//          } else {
//            list.add(tmpJson);
//          }
//        }
//        list.addAll(empList);
//        tmpList = list;
//      }
      // del #9323 帳票「並び替え」機能のオーバーホール　高 end
    }

    // mod #11117 日常点検記録簿が1ページ1装置で出力される limingzhe start
//    // add #9323 帳票「並び替え」機能のオーバーホール　高 start
//    List sortKey = tmpSortKey;
//    List sortDirection = tmpSortDirection;
//    // 並び替え
//    tmpList = MachineReportCompare(tmpList,sortKey,sortDirection,tmpSortKey);
//    // ソート対象のデータが存在しないデータを最下段に寄せる
//    List<JSONObject> list = new ArrayList<>();
//    List<JSONObject> empList = new ArrayList<>();
//    for (JSONObject tmpJson : tmpList) {
//      for (int index = 0; index < sortKey.size();index++) {
//        if (tmpJson.getString(sortKey.get(index).toString()).equals("")) {
//          empList.add(tmpJson);
//        }
//      }
//    }
//    list.addAll(empList);
//    // mod #9323 帳票「並び替え」機能のオーバーホール　高 end
//    // add #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe start
//    boolean bHaveReportList = false;
//    // add #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe end
//    for(int i = 0;i<tmpList.size();i++) {
//      machineNo.add(Long.parseLong(tmpList.get(i).get("machine_no").toString()));
//      if(reportMenu.getSpecifyDate() != null) {
//        date = reportMenu.getSpecifyDate();
//        dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, date);
//        dataKey.put(ReportConstant.ReportDataKey.DATE_TO, date);
//        dataKey.put(ReportConstant.ReportDataKey.DATE, date);
//        if(reportMenu.getReportCd() < 0){
//          reportExcel = new ArrayList<>();
//          List<Long> reportCdList = getReportCdList(reportMenu,i,date,reportMenu.getReportCd() == -5 ? "2" : "1");
//          // mod #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe start
//          //dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, reportMenu.getMachines().get(i).getMachineNo());
//          dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD,reportMenu.getFacilityCd());
//          List<Long> mNos = new ArrayList<>();
//          mNos.add(reportMenu.getMachines().get(i).getMachineNo());
//          dataKey.put(ReportConstant.ReportDataKey.MACHINE_NOS, mNos);
//          // mod #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe end
//
//          if(reportCdList.size()>0){
//            for(int k =0 ;k<reportCdList.size();k++){
//              // mod #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe start
//              //byte[] excelBytes = reportService.getReportExcelFile(reportCdList.get(k), dataKey);
//              byte[] excelBytes = reportService.getReportExcelFileForMachineReport(reportCdList.get(k), dataKey);
//              // mod #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe end
//              reportExcel.add(excelBytes);
//            }
//            // add #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe start
//            bHaveReportList = true;
//            // add #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe end
//          }
//        }
//      } else {
//        String fromDate = reportMenu.getFromDate();
//        String toDate = reportMenu.getToDate();
//        dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate);
//        dataKey.put(ReportConstant.ReportDataKey.DATE_TO, toDate);
//        SimpleDateFormat sdf=new SimpleDateFormat("yyyyMMdd");
//        Calendar cal = Calendar.getInstance();
//        cal.setTime(sdf.parse(fromDate));
//        long time1 = cal.getTimeInMillis();
//        cal.setTime(sdf.parse(toDate));
//        long time2 = cal.getTimeInMillis();
//        long between_days=(time2-time1)/(1000*3600*24);
//        Calendar calendar = new GregorianCalendar();
//        calendar.setTime(sdf.parse(reportMenu.getFromDate()));
//        boolean htmlFlg = false;
//        if(!"1".equals(reportMenu.getReportType())){
//          // add #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe start
//          reportExcel = new ArrayList<>();
//          // add #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe end
//          for (int j = 0; j <= between_days; j++) {
//            date = sdf.format(calendar.getTime());
//            dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD,reportMenu.getFacilityCd());
//            dataKey.put(ReportConstant.ReportDataKey.DATE,date);
//            // add #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe start
//            List<Long> mNos = new ArrayList<>();
//            mNos.add(reportMenu.getMachines().get(i).getMachineNo());
//            dataKey.put(ReportConstant.ReportDataKey.MACHINE_NOS, mNos);
//            // add #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe end
//            if(reportMenu.getReportCd() <0){
//              List<Long> reportCdList = getReportCdList(reportMenu,i,date,reportMenu.getReportCd() == -5 ? "2" : "1");
//              // del #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe start
//              //dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, reportMenu.getMachines().get(i).getMachineNo());
//              // del #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe end
//              if(reportCdList.size()>0){
//                for(int k =0 ;k<reportCdList.size();k++){
//                  htmlFlg = true;
//                  // mod #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe start
//                  //byte[] excelBytes = reportService.getReportExcelFile(reportCdList.get(k), dataKey);
//                  byte[] excelBytes = reportService.getReportExcelFileForMachineReport(reportCdList.get(k), dataKey);
//                  // mod #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe end
//                  for (byte[] dataList : reportExcel) {
//                    if (Arrays.equals(dataList,excelBytes) == true) {
//                      htmlFlg = false;
//                      break;
//                    }
//                  }
//                  if(htmlFlg == true){
//                    reportExcel.add(excelBytes);
//                  }
//                }
//                // add #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe start
//                bHaveReportList = true;
//                // add #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe end
//              }
//            } else {
//              // del #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe start
//              //dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, reportMenu.getMachines().get(i).getMachineNo());
//              // del #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe end
//              byte[] excelBytes = reportService.getReportExcelFileForMachineReport(reportMenu.getReportCd(), dataKey);
//              reportExcel.add(excelBytes);
//            }
//            calendar.add(calendar.DATE, 1);
//          }
//        }
//      }
//      if (reportMenu.getReportCd() < 0) {
//        if (reportExcel.size() > 0) {
//          Map<Long, List<byte[]>> reportMap = new HashMap<>();
//          reportMap.put(Long.parseLong(i+""), reportExcel);
//          excelReportList.add(reportMap);
//        }
//      }
      // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy start
      dataKey.put(ReportConstant.ReportDataKey.reportClass,reportMenu.getReportClass());
      dataKey.put(ReportConstant.ReportDataKey.dateKind,reportMenu.getDateKind());
      dataKey.put(ReportConstant.ReportDataKey.currentPage,"");
      dataKey.put(ReportConstant.ReportDataKey.totalPages,"");
      // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy end
//      // add #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      // 装置帳票
//      if (null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate()) {
//        // 1日指定
//        String year = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(0, 4);
//        String month = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(4, 6);
//        String day = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(6,8);
//        Calendar calendar =Calendar.getInstance();
//        calendar.setFirstDayOfWeek(Calendar.MONDAY);
//        calendar.set(Calendar.YEAR, Integer.valueOf(year));
//        calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
//        calendar.set(Calendar.DAY_OF_MONTH, Integer.valueOf(day));
//        int week = calendar.get(Calendar.WEEK_OF_MONTH);
//        dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
//      } else {
//        // 期間指定
//        String year = reportMenu.getFromDate().replace("/","").replace("-","").substring(0, 4);
//        String month = reportMenu.getFromDate().replace("/","").replace("-","").substring(4, 6);
//        String day = reportMenu.getFromDate().replace("/","").replace("-","").substring(6,8);
//        Calendar calendar =Calendar.getInstance();
//        calendar.setFirstDayOfWeek(Calendar.MONDAY);
//        calendar.set(Calendar.YEAR, Integer.valueOf(year));
//        calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
//        calendar.set(Calendar.DAY_OF_MONTH, Integer.valueOf(day));
//        int week = calendar.get(Calendar.WEEK_OF_MONTH);
//        dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
//      }
//      // add #11009 カテゴリ「印刷情報」の仕様調整 高 end
//    }
//    // add #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe start
//    if (reportMenu.getReportCd() < 0 && !bHaveReportList){
//      throw new NtssException("テンプレートがない");
//    }
//    // add #11100 【総合検証NG】装置帳票＞定期点検（日常点検記録簿、定期点検記録簿）のプレビューができない。 limingzhe end
//    if (reportMenu.getReportCd() > 0) {
//      // mod #9558 機能帳票で正しく変数が引き渡されていない limingzhe start
//      //dataKey.put(ReportConstant.ReportDataKey.MACHINE_NO, machineNo);
//      dataKey.put(ReportConstant.ReportDataKey.MACHINE_NOS, machineNo);
//      // mod #9558 機能帳票で正しく変数が引き渡されていない limingzhe end
//      dataKey.put("newMachineNos", machineNo);
//      dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD,reportMenu.getFacilityCd());
//      // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
//      requestParamEdit(reportMenu, dataKey);
//      // add 11009 カテゴリ「印刷情報」の仕様調整 房 end
//      byte[] excelBytes = reportService.getReportExcelFileForMachineReport(reportMenu.getReportCd(), dataKey);
//      reportExcel.add(excelBytes);
//      if (reportExcel.size() > 0) {
//        Map<Long, List<byte[]>> reportMap = new HashMap<>();
//        reportMap.put(Long.parseLong(0+""), reportExcel);
//        excelReportList.add(reportMap);
//      }
//    }
    requestParamEdit(reportMenu, dataKey);
    dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
    if (null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate()) {
      // 1日指定
      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, reportMenu.getSpecifyDate());
      dataKey.put(ReportConstant.ReportDataKey.DATE_TO, reportMenu.getSpecifyDate());
      dataKey.put(ReportConstant.ReportDataKey.DATE, reportMenu.getSpecifyDate());
    } else {
      // 期間指定
      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, reportMenu.getFromDate());
      dataKey.put(ReportConstant.ReportDataKey.DATE_TO, reportMenu.getToDate());
      dataKey.put(ReportConstant.ReportDataKey.DATE, reportMenu.getFromDate());
    }
    String year = dataKey.get(ReportConstant.ReportDataKey.DATE_FROM).toString().replace("/","").replace("-","").substring(0, 4);
    String month = dataKey.get(ReportConstant.ReportDataKey.DATE_FROM).toString().replace("/","").replace("-","").substring(4, 6);
    String day = dataKey.get(ReportConstant.ReportDataKey.DATE_FROM).toString().replace("/","").replace("-","").substring(6,8);
    Calendar calendar =Calendar.getInstance();
    calendar.setFirstDayOfWeek(Calendar.MONDAY);
    calendar.set(Calendar.YEAR, Integer.valueOf(year));
    calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
    calendar.set(Calendar.DAY_OF_MONTH, Integer.valueOf(day));
    int week = calendar.get(Calendar.WEEK_OF_MONTH);
    dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
    Map<Long, List<Long>> machineReportMap = new HashMap<>();
    if (reportMenu.getReportCd() < 0){
      // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe start
      // List<MstMachineReportList> machineReportList = devMenteMainDao.selectReportCdandMachineNoListByMainte(reportMenu.getReportCd() == -5 ? "2" : "1", machineNos, reportMenu.getFacilityCd(),
      //        dataKey.get(ReportConstant.ReportDataKey.DATE_FROM).toString(), dataKey.get(ReportConstant.ReportDataKey.DATE_TO).toString());
      List<MstMachineReportList> machineReportList = new ArrayList<>();
      if(reportMenu.getReportCd() == CoreConstant.FixedReportCd.DAILY_INSPECT_RECORD_BOOK){
        // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
//        machineReportList = devMenteMainDao.selectReportCdandMachineNoListByMainte("1", machineNos, reportMenu.getFacilityCd(),
//          dataKey.get(ReportConstant.ReportDataKey.DATE_FROM).toString(), dataKey.get(ReportConstant.ReportDataKey.DATE_TO).toString());
        machineReportList = mstReportDao.selectReportCdandMachineNoListByMachineTypeCd("1", reportMenu.getFacilityCd(), machineNos);
        // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
      }
      else if(reportMenu.getReportCd() == CoreConstant.FixedReportCd.PERIODIC_INSPECT_RECORD_BOOK){
        // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe start
//        machineReportList = devMenteMainDao.selectReportCdandMachineNoListByMainte("2", machineNos, reportMenu.getFacilityCd(),
//          dataKey.get(ReportConstant.ReportDataKey.DATE_FROM).toString(), dataKey.get(ReportConstant.ReportDataKey.DATE_TO).toString());
        machineReportList = mstReportDao.selectReportCdandMachineNoListByMachineTypeCd("2", reportMenu.getFacilityCd(), machineNos);
        // mod #12549 現状の設定仕様では装置点検帳票の要求を満たせない limingzhe end
      }
      // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe start
      else if(reportMenu.getReportCd() == CoreConstant.FixedReportCd.WATER_SURVEY_RECORD_BOOK){
        machineReportList = mstReportDao.selectReportCdandMachineNoListByMachineTypeCd("3", reportMenu.getFacilityCd(), machineNos);
      }
      // add #12582 固定帳票「水質管理記録簿」が必要 limingzhe end
      // mod #11326 帳票メニューの帳票リストの固定項目の表示/非表示・並び順が制御できない limingzhe end
      if(machineReportList == null || machineReportList.size() == 0){
        throw new NtssException("テンプレートがない");
      }
      for(int i =0; i < machineReportList.size(); i++){
        List<Long> machineList = new ArrayList<Long>();
        if(machineReportMap.get(machineReportList.get(i).getReportCd()) != null){
          machineList = machineReportMap.get(machineReportList.get(i).getReportCd());
        }
        machineList.add(machineReportList.get(i).getMachineNo());
        Set<Long> machineSet = new LinkedHashSet<Long>(machineList);
        machineList = new ArrayList<Long>(machineSet);
        machineReportMap.put(machineReportList.get(i).getReportCd(), machineList);
      }
    } else if (reportMenu.getReportCd() > 0) {
      machineReportMap.put(reportMenu.getReportCd(), machineNos);
    }
    Long reportCount = 0l;
    for (Long rCd : machineReportMap.keySet()) {
      reportExcel = new ArrayList<>();
      // 並び替え
      List sortKey = tmpSortKey;
      List sortDirection = tmpSortDirection;
      List<JSONObject> newTmpList = new ArrayList<>();
      for (JSONObject tmpJson : tmpList){
        if(machineReportMap.get(rCd).contains(Long.parseLong(tmpJson.get("machine_no").toString()))){
          newTmpList.add(tmpJson);
        }
      }
      newTmpList = MachineReportCompare(newTmpList,sortKey,sortDirection,tmpSortKey);
      List<Long> mNos = new ArrayList<>();
      for (JSONObject tmpJson : newTmpList){
        mNos.add(Long.parseLong(tmpJson.get("machine_no").toString()));
      }
      dataKey.put(ReportConstant.ReportDataKey.MACHINE_NOS, mNos);
      byte[] excelBytes = reportForMachineReportService.getReportExcelFileForMachineReport(rCd, dataKey);
      reportExcel.add(excelBytes);
      if (reportExcel.size() > 0) {
        Map<Long, List<byte[]>> reportMap = new HashMap<>();
        reportMap.put(reportCount++, reportExcel);
        excelReportList.add(reportMap);
      }
    }
    // mod #11117 日常点検記録簿が1ページ1装置で出力される limingzhe end
    return excelReportList;
  }


  /**
   *
   * {@inheritDoc}
   */
  @Override
// mod 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 start
//  public List<Map<Long, byte[]>>  getExcelReportForOneTotal(ReportMenuSortContainer reportMenu,String userName) throws Exception {
    public List<Map<Long, List<byte[]>>>  getExcelReportForOneTotal(ReportMenuSortContainer reportMenu,String userName) throws Exception {
// mod 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 end
    Integer reportClass = reportMenu.getReportClass();
    Boolean isDialyzer = false;

    if(reportMenu.getEquipmentCdList() != null) {
      if(reportMenu.getEquipmentCdList().contains(0)) {
        isDialyzer = true;
      }
    }

    byte[] excelResult = null;
// mod 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 start
//    List<Map<Long, byte[]>> excelResultList = new ArrayList<>();
    List<Map<Long, List<byte[]>>> excelReportList = new ArrayList<>();
// mod 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 end
    Long reportCd = reportMenu.getReportCd();
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe start
//    List<OrdMain> patOrdNo = getOrdNoListSorted(reportMenu);
//    if(null != patOrdNo && patOrdNo.size() > 0) {
//      for(int i = patOrdNo.size(); i > 0; i--){
//        if(patOrdNo.get(i-1).getOrdNo() == 0){
//          patOrdNo.remove(i-1);
//        }
//      }
//    }
//    List<Long> listPat = new ArrayList<>();
//    List<Long> listOrd = new ArrayList<>();
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe end
    List<Integer> listDia = new ArrayList<>();
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe start
//    for (int i = 0; i < patOrdNo.size(); i++) {
//      listPat.add(patOrdNo.get(i).getPatId());
//      listOrd.add(patOrdNo.get(i).getOrdNo());
//    }
//    Collections.sort(listPat);
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe end
    // del 10550 患者別の検査結果一覧帳票を出力できるようにする gjn start
//    if (listPat.size() == 0 || listOrd.size() == 0) {
//        return null;
//    }
    // del 10550 患者別の検査結果一覧帳票を出力できるようにする gjn end
    Map<String, Object> dataKey = new HashMap<>();
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe start
//    // add 10550 患者別の検査結果一覧帳票を出力できるようにする gjn start
//    dataKey.put("regOrderClassList", reportMenu.getRegOrderClassList());
//    // add 10550 患者別の検査結果一覧帳票を出力できるようにする gjn end
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe end
    dataKey.put("sqlTestSign", reportMenu.getSqlTestTimeStr());
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe start
//    dataKey.put("login", userName);
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe end
    dataKey.put("reportClass",reportClass);
    dataKey.put(ReportConstant.ReportDataKey.SORT_CONDITIONS, reportMenu.getSortCondition());
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe start
//    dataKey.put("patIds", listPat);
//    dataKey.put("ordNos", listOrd);
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe end

    if (reportMenu.getMedicineCdList() != null && reportMenu.getMedicineCdList().size() > 0) {
      dataKey.put("medIds", reportMenu.getMedicineCdList());
    } else {
      dataKey.put("medIds", Collections.singletonList(0));
    }

    if (isDialyzer) {
      //ダイアライザの表示
      for(MstDialyzer item : mstInfoService.findMstDialyzerAllByFacillityCd(reportMenu.getFacilityCd())) {
        listDia.add(item.getDialyzerCd());
      }
      dataKey.put("diaIds", listDia);
    } else {
      dataKey.put("diaIds", Collections.singletonList(0));
    }
    List<Integer> equipmentCdList = new ArrayList<>();
    if (reportMenu.getEquipmentCdList() != null && reportMenu.getEquipmentCdList().size() > 0) {
      equipmentCdList = reportMenu.getEquipmentCdList();
      dataKey.put("eqIds", equipmentCdList);
    } else {
      dataKey.put("eqIds", Collections.singletonList(0));
    }
    // del #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
//    LocalDate nowDate = LocalDate.now();
//    String nowYYYYMMDD = nowDate.format(DateTimeFormatter.ofPattern("uuuuMMdd"));
//    dataKey.put(ReportConstant.ReportDataKey.DATE, nowYYYYMMDD);
    // del #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe start
//    dataKey.put(ReportConstant.ReportDataKey.freeWord,reportMenu.getFreeWord());
//    dataKey.put(ReportConstant.ReportDataKey.treatDate,reportMenu.getSpecifyDate());
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe end
    dataKey.put(ReportConstant.ReportDataKey.kurCdList,reportMenu.getKurCdList());
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe start
//    dataKey.put(ReportConstant.ReportDataKey.bedCdListString,reportMenu.getBedCdListString());
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe end
    dataKey.put(ReportConstant.ReportDataKey.expressCondCd,reportMenu.getExpressCondCd());
    dataKey.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe start
//    String kind ="医療材料";
//    if(null != reportMenu.getEquipmentCdList() && reportMenu.getEquipmentCdList().size() == 0 && null !=  reportMenu.getMedicineCdList() && reportMenu.getMedicineCdList().size()>0){
//      kind="";
//    }
//    if(null !=  reportMenu.getMedicineCdList() && reportMenu.getMedicineCdList().size()>0){
//      if("" == kind){
//        kind="薬剤";
//      }else{
//        kind=kind+"·薬剤";
//      }
//    }
//    dataKey.put(ReportConstant.ReportDataKey.kind,kind);
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe end
    // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy start
    dataKey.put(ReportConstant.ReportDataKey.dateKind,reportMenu.getDateKind());
    dataKey.put(ReportConstant.ReportDataKey.currentPage,"");
    dataKey.put(ReportConstant.ReportDataKey.totalPages,"");
    // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy end
    // 単集計
    if(null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate()){
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      String day=reportMenu.getSpecifyDate().substring(6,8);
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe start
//      String year = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(0, 4);
//      String month = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(4, 6);
//      String day = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(6,8);
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe end
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 end
      String date = reportMenu.getSpecifyDate();
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe start
//      Calendar calendar =Calendar.getInstance();
//      // del #11009 カテゴリ「印刷情報」の仕様調整 高 start
////      calendar.setFirstDayOfWeek(Calendar.MONDAY);
////      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
//      // del #11009 カテゴリ「印刷情報」の仕様調整 高 end
//      calendar.setFirstDayOfWeek(Calendar.MONDAY);
//      // add #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      calendar.set(Calendar.YEAR, Integer.valueOf(year));
//      calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
//      // add #11009 カテゴリ「印刷情報」の仕様調整 高 end
//      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
//      int week = calendar.get(Calendar.WEEK_OF_MONTH);
//      dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
//      String treatDateFormatted = date.substring(0,4) + "-" + date.substring(4,6) + "-" + date.substring(6);
//      String[] result = getStartAndEndDayByDate(treatDateFormatted);
//      String start = result[0].substring(0,4) + "年" + result[0].substring(5,7) + "月" + result[0].substring(8)+ "日";
//      String end = result[1].substring(5,7) + "月" + result[1].substring(8)+ "日";
//      dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe end
      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, date.replace("/",""));
      dataKey.put(ReportConstant.ReportDataKey.DATE_TO, date.replace("/",""));
      // add #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
      dataKey.put(ReportConstant.ReportDataKey.DATE, date.replace("/",""));
      // add #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end
    }else{
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      String day=reportMenu.getFromDate().substring(6,8);
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe start
//      String year = reportMenu.getFromDate().replace("/","").replace("-","").substring(0, 4);
//      String month = reportMenu.getFromDate().replace("/","").replace("-","").substring(4, 6);
//      String day = reportMenu.getFromDate().replace("/","").replace("-","").substring(6,8);
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe end
      // mod #11009 カテゴリ「印刷情報」の仕様調整 高 end
      String fromDate = reportMenu.getFromDate().substring(0,4) + "-" + reportMenu.getFromDate().substring(4,6) + "-" + reportMenu.getFromDate().substring(6);
      String toDate = reportMenu.getToDate().substring(0,4) + "-" + reportMenu.getToDate().substring(4,6) + "-" + reportMenu.getToDate().substring(6);
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe start
//      Calendar calendar =Calendar.getInstance();
//      // del #11009 カテゴリ「印刷情報」の仕様調整 高 start
////      calendar.setFirstDayOfWeek(Calendar.MONDAY);
////      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
//      // del #11009 カテゴリ「印刷情報」の仕様調整 高 end
//      calendar.setFirstDayOfWeek(Calendar.MONDAY);
//      // add #11009 カテゴリ「印刷情報」の仕様調整 高 start
//      calendar.set(Calendar.YEAR, Integer.valueOf(year));
//      calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
//      // add #11009 カテゴリ「印刷情報」の仕様調整 高 end
//      calendar.set(Calendar.DAY_OF_MONTH,Integer.valueOf(day));
//      int week = calendar.get(Calendar.WEEK_OF_MONTH);
//      dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
//      String start = "";
//      String end = "";
//      if(reportClass.equals(ReportConstant.ReportClass.ONE_TOTAL_REPORT)) {
//        start = fromDate.substring(0, 4) + "年" + fromDate.substring(5, 7) + "月" + fromDate.substring(8)+ "日";
//        end =  toDate.substring(5, 7) + "月" + toDate.substring(8)+ "日";
//      } else {
//        String[] result = getStartAndEndDayByDate(fromDate);
//        start = result[0].substring(0, 4) + "年" + result[0].substring(5, 7) + "月" + result[0].substring(8)+ "日";
//        end =  result[1].substring(5, 7) + "月" + result[1].substring(8)+ "日";
//      }
//      dataKey.put(ReportConstant.ReportDataKey.period,start+"～"+end);
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe end
      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, fromDate.replace("/",""));
      dataKey.put(ReportConstant.ReportDataKey.DATE_TO, toDate.replace("/",""));
      // add #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
      dataKey.put(ReportConstant.ReportDataKey.DATE, fromDate.replace("/",""));
      // add #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end
    }
    // del #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
//    List<Map<String, Object>> tmplParams = new ArrayList<Map<String, Object>>();
//    for (int param = 0; param < patOrdNo.size(); param++) {
//      Map<String, Object> tmplParam = new HashMap<>();
//      tmplParam.put(ReportConstant.ReportDataKey.DIALYZER_IDS, dataKey.get(ReportConstant.ReportDataKey.DIALYZER_IDS));
//      tmplParam.put(ReportConstant.ReportDataKey.MEDICINE_IDS, dataKey.get(ReportConstant.ReportDataKey.MEDICINE_IDS));
//      tmplParam.put(ReportConstant.ReportDataKey.EQUIPMENT_IDS, dataKey.get(ReportConstant.ReportDataKey.EQUIPMENT_IDS));
//      tmplParam.put(ReportConstant.ReportDataKey.ORD_NO, patOrdNo.get(param).getOrdNo());
//      tmplParam.put(ReportConstant.ReportDataKey.PAT_ID, patOrdNo.get(param).getPatId());
//      tmplParam.put(ReportConstant.ReportDataKey.DATE_FROM, dataKey.get(ReportConstant.ReportDataKey.DATE_FROM));
//      tmplParam.put(ReportConstant.ReportDataKey.DATE_TO, dataKey.get(ReportConstant.ReportDataKey.DATE_TO));
//      tmplParam.put(ReportConstant.ReportDataKey.DATE, dataKey.get(ReportConstant.ReportDataKey.DATE));
//      tmplParam.put(ReportConstant.ReportDataKey.FACILITY_CD, reportMenu.getFacilityCd());
//      tmplParams.add(tmplParam);
//    }
    // del #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end
// mod 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 start
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe start
//        Map<Long, OrdMain> map2 = patOrdNo.stream().filter(o -> o != null && o.getPatId() != null)
//      .collect(HashMap::new, (m, o) -> m.put(o.getPatId(), o), HashMap::putAll);
//    List<OrdMain> distinctlist = new ArrayList<>(map2.values());
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe end

    // add #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe start
    List<String> regOrderClassList = reportMenu.getRegOrderClassList() == null ? new ArrayList<String>(Arrays.asList("1", "2", "0")) : reportMenu.getRegOrderClassList();
    dataKey.put("regOrderClassList", regOrderClassList);
    requestParamEdit(reportMenu, dataKey);
    List<Long> patIdList = reportMenu.getPatIds();
    Map<Long, List<Long>> patMapOrdNos = new HashMap<>();
    List<OrdMain> ordMainList = reportMenuDao.selectByTreatDateAndPatIds(
      patIdList,
      reportMenu.getSpecifyDate(),
      reportMenu.getFromDate(),
      reportMenu.getToDate()
    );
    for (Long patId : patIdList) {
      List<Long> ordNos = new ArrayList<>();
      if(ordMainList != null){
        ordNos = ordMainList.stream().filter(el -> String.valueOf(el.getPatId()).equals(String.valueOf(patId))).map(el -> el.getOrdNo()).collect(toList());
      }
      if(ordNos == null || ordNos.size() == 0) ordNos.add(-1l);
      patMapOrdNos.put(patId, ordNos);
    }
    // add #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe end
    // mod #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe start
    // for(int i = 0; i<distinctlist.size(); i++){
    for(int i = 0; i < patIdList.size(); i++){
    // mod #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe end
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe start
//      List ordList = new ArrayList();
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe end
      // del #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
      // dataKey.put(ReportConstant.ReportDataKey.TEMPLATE_PARAMS, tmplParams);
      // del #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end
      // mod #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe start
//      if (distinctlist.size() > 0) {
//          dataKey.put("patId", distinctlist.get(i).getPatId());
//          List patIds = new ArrayList();
//          patIds.add(distinctlist.get(i).getPatId());
//          dataKey.put("patIds", patIds);
//          for(int index = 0; index < patOrdNo.size(); index++){
//            if (patOrdNo.get(index).getPatId() == distinctlist.get(i).getPatId()){
//              ordList.add(patOrdNo.get(index).getOrdNo());
//            }
//          }
//          dataKey.put("ordNos",ordList);
//       }
//      EventLogMessage LogMessage = new EventLogMessage();
//      logService.log(LogLevel.INFO, LogMessage, FUNCTION_CODE.FUNC_REPORT_MENU, SERVICE_NAME.FNSI, null);
      dataKey.put("patId", patIdList.get(i));
      List<Long> patIds = new ArrayList();
      patIds.add(patIdList.get(i));
      dataKey.put("patIds", patIds);
      dataKey.put("ordNo", patMapOrdNos.get(patIdList.get(i)).get(0));
      dataKey.put("ordNos",patMapOrdNos.get(patIdList.get(i)));
      // mod #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe end
      List<byte[]> reportExcel = new ArrayList<>();
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe start
//      // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
//      requestParamEdit(reportMenu, dataKey);
//      // add 11009 カテゴリ「印刷情報」の仕様調整 房 end
// del #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe end
      // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
      //excelResult = reportService.getReportExcelFileForOneTotal(reportCd, dataKey);
      excelResult = reportForTotalService.getReportExcelFileForOneTotal(reportCd, dataKey);
      // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end
      reportExcel.add(excelResult);
      if (reportExcel.size() > 0) {
        Map<Long, List<byte[]>> reportMap = new HashMap<>();
        // mod #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe start
        // reportMap.put(Long.parseLong(String.valueOf(distinctlist.get(i).getPatId())), reportExcel);
        reportMap.put(patIdList.get(i), reportExcel);
        // mod #12134 単集計帳票で検査結果が指示のない日だと出ない limingzhe end
        excelReportList.add(reportMap);
      }
//      Map<Long, byte[]> reportMap = new HashMap<>();
//      reportMap.put(patOrdNo.get(i).getPatId(), excelResult);
//      excelResultList.add(reportMap);
    }
//    return excelResultList;
    return excelReportList;
// mod 10432 出力対象患者が複数名の時「単集計」帳票が全員出力されない。　杜 end
  }


  /**
   *
   * {@inheritDoc}
   */
  // del 10546 複数集計出力時にサーバが高負荷になる gjn start
//  @Override
//  public byte[] getExcelReportForMultiTotal(ReportMenuSortContainer reportMenu,String userName) throws Exception {
//    Integer reportClass = reportMenu.getReportClass();
//
//    byte[] excelResult = null;
//    Long reportCd = reportMenu.getReportCd();
//    List<OrdMain> patOrdNo = getOrdNoListSorted(reportMenu);
//    if (null != patOrdNo && patOrdNo.size() > 0) {
//      for(int i = patOrdNo.size(); i > 0; i--){
//        if(patOrdNo.get(i-1).getOrdNo() == 0){
//          patOrdNo.remove(i-1);
//        }
//      }
//    }
//    List<Long> listPat = new ArrayList<>();
//    List<Long> listOrd = new ArrayList<>();
//    for (int i = 0; i < patOrdNo.size(); i++) {
//      listPat.add(patOrdNo.get(i).getPatId());
//      listOrd.add(patOrdNo.get(i).getOrdNo());
//    }
//    Collections.sort(listPat);
//    if (listPat.size() == 0 || listOrd.size() == 0) {
//        return null;
//    }
//    Map<String, Object> dataKey = new HashMap<>();
//    dataKey.put("sqlTestSign", reportMenu.getSqlTestTimeStr());
//    dataKey.put("login", userName);
//    dataKey.put("reportClass",reportClass);
//    dataKey.put("sortCondition", reportMenu.getSortCondition());
//    dataKey.put("patIds", listPat);
//    if (reportClass.equals(ReportConstant.ReportClass.MULTI_TOTAL_REPORT)) {
//      dataKey = setMultiTotalDataKey(reportMenu,0l,userName);
//      dataKey.put("sqlTestSign", reportMenu.getSqlTestTimeStr());
//      dataKey.put("reportClass",reportClass);
//      //add 9400 複数集計で「##印刷情報.抽出条件.期間」が正しく出ない sunsy start
//      dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, reportMenu.getFromDate());
//      dataKey.put(ReportConstant.ReportDataKey.DATE_TO, reportMenu.getToDate());
//      //add 9400 複数集計で「##印刷情報.抽出条件.期間」が正しく出ない sunsy end
//      dataKey.put("regOrderClassList",reportMenu.getRegOrderClassList());
//      excelResult = reportService.getReportExcelFileForMultiTotal(reportCd, dataKey);
//    }
//    return excelResult;
//  }
  // del 10546 複数集計出力時にサーバが高負荷になる gjn end


  // add 10546 複数集計出力時にサーバが高負荷になる gjn start
  @Override
  public byte[] getExcelReportForMultiTotalHighPerformanceVersion(ReportMenuSortContainer reportMenu,String userName) throws Exception {
    // del #11642 スケジュール表帳票がデータ抽出条件「指定日」で「一週間出力」になるのはNG limingzhe start
    //Integer reportClass = reportMenu.getReportClass();
    // del #11642 スケジュール表帳票がデータ抽出条件「指定日」で「一週間出力」になるのはNG limingzhe end
    Long reportCd = reportMenu.getReportCd();
    List<Long> listPat = reportMenu.getPatIds();
    Collections.sort(listPat);

    Map<String, Object> dataKey = setMultiTotalDataKey(reportMenu, userName);
    dataKey.put("sqlTestSign", reportMenu.getSqlTestTimeStr());
    // del #11642 スケジュール表帳票がデータ抽出条件「指定日」で「一週間出力」になるのはNG limingzhe start
    //dataKey.put("login", userName);
    //dataKey.put("reportClass",reportClass);
    // del #11642 スケジュール表帳票がデータ抽出条件「指定日」で「一週間出力」になるのはNG limingzhe end
    dataKey.put(ReportConstant.ReportDataKey.SORT_CONDITIONS, reportMenu.getSortCondition());
    dataKey.put("patIds", listPat);
    // del #11642 スケジュール表帳票がデータ抽出条件「指定日」で「一週間出力」になるのはNG limingzhe start
    //dataKey.put("sqlTestSign", reportMenu.getSqlTestTimeStr());
    //dataKey.put("reportClass",reportClass);
    //dataKey.put(ReportConstant.ReportDataKey.DATE_FROM, reportMenu.getFromDate());
    //dataKey.put(ReportConstant.ReportDataKey.DATE_TO, reportMenu.getToDate());
    // del #11642 スケジュール表帳票がデータ抽出条件「指定日」で「一週間出力」になるのはNG limingzhe end
    // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe start
    //dataKey.put("regOrderClassList",reportMenu.getRegOrderClassList());
    List<String> regOrderClassList = reportMenu.getRegOrderClassList() == null ? new ArrayList<String>(Arrays.asList("1", "2", "0")) : reportMenu.getRegOrderClassList();
    dataKey.put("regOrderClassList", regOrderClassList);
    // mod #11106 集計帳票で集計範囲外のグループ項目が出力されない limingzhe end
    // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
    requestParamEdit(reportMenu, dataKey);
    // add 11009 カテゴリ「印刷情報」の仕様調整 房 end
    // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy start
    dataKey.put(ReportConstant.ReportDataKey.reportClass,reportMenu.getReportClass());
    dataKey.put(ReportConstant.ReportDataKey.dateKind,reportMenu.getDateKind());
    dataKey.put(ReportConstant.ReportDataKey.currentPage,"");
    dataKey.put(ReportConstant.ReportDataKey.totalPages,"");
    // add #11103 カテゴリ「印刷情報」の項目追加と修正 sunsy end
    // add #11009 カテゴリ「印刷情報」の仕様調整 高 start
    // 複数集計
    if (null != reportMenu.getSpecifyDate() && null == reportMenu.getToDate() && null == reportMenu.getFromDate()) {
      // 1日指定
      String year = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(0, 4);
      String month = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(4, 6);
      String day = reportMenu.getSpecifyDate().replace("/","").replace("-","").substring(6,8);
      Calendar calendar =Calendar.getInstance();
      calendar.setFirstDayOfWeek(Calendar.MONDAY);
      calendar.set(Calendar.YEAR, Integer.valueOf(year));
      calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
      calendar.set(Calendar.DAY_OF_MONTH, Integer.valueOf(day));
      int week = calendar.get(Calendar.WEEK_OF_MONTH);
      dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
    } else {
      // 期間指定
      String year = reportMenu.getFromDate().replace("/","").replace("-","").substring(0, 4);
      String month = reportMenu.getFromDate().replace("/","").replace("-","").substring(4, 6);
      String day = reportMenu.getFromDate().replace("/","").replace("-","").substring(6,8);
      Calendar calendar =Calendar.getInstance();
      calendar.setFirstDayOfWeek(Calendar.MONDAY);
      calendar.set(Calendar.YEAR, Integer.valueOf(year));
      calendar.set(Calendar.MONTH, Integer.valueOf(month) - 1);
      calendar.set(Calendar.DAY_OF_MONTH, Integer.valueOf(day));
      int week = calendar.get(Calendar.WEEK_OF_MONTH);
      dataKey.put(ReportConstant.ReportDataKey.weeks,week+"週目");
    }
    // add #11009 カテゴリ「印刷情報」の仕様調整 高 end
    // mod #11973 日常点検一覧帳票が正常に出せない limingzhe start
    //return reportForMultiTotalService.getReportExcelFileForMultiTotal(reportCd, dataKey);
    return reportForTotalService.getReportExcelFileForMultiTotal(reportCd, dataKey);
    // mod #11973 日常点検一覧帳票が正常に出せない limingzhe end
  }
  // add 10546 複数集計出力時にサーバが高負荷になる gjn end


  // add #9323 帳票「並び替え」機能のオーバーホール　高 start
  /**
   *
   * 帳票種別：1：治療経過表
   * 並び替え
   * */
  // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//  private List<JSONObject> DialysisReportCompare(List<JSONObject> tmpList,List sortKey,List sortDirection){
//    if (sortKey.size() != 0) {
//      tmpList = tmpList.stream().sorted((patA, patB) -> {
//        if (sortKey.size() == 1) {
//          String sortKeyOne = "";
//          String sortDirectionOne = "";
//          sortKeyOne = sortKey.get(0).toString();
//          sortDirectionOne = sortDirection.get(0).toString();
//          if ("asc".equals(sortDirectionOne)) {
//            if (patA.get(sortKeyOne) != null && patA.get(sortKeyOne)!= "" && !patA.get(sortKeyOne).toString().equals(patB.get(sortKeyOne).toString())) {
//              return patA.get(sortKeyOne).toString().compareTo(patB.get(sortKeyOne).toString());
//            } else {
//              return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//            }
//          } else {
//            if (patA.get(sortKeyOne) != null && patA.get(sortKeyOne)!= "" && !patA.get(sortKeyOne).toString().equals(patB.get(sortKeyOne).toString())) {
//              return patA.get(sortKeyOne).toString().compareTo(patB.get(sortKeyOne).toString()) * -1;
//            } else {
//              return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//            }
//          }
//        } else if (sortKey.size()==2){
//          if ("asc".equals(sortDirection.get(0))) {
//            if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//              !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString());
//            } else {
//              if ("asc".equals(sortDirection.get(1))) {
//                if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                  !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
//                } else {
//                  return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                }
//              } else {
//                if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                  !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                } else {
//                  return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                }
//              }
//            }
//          } else {
//            if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//              !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//            } else {
//              if ("asc".equals(sortDirection.get(1))) {
//                if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                  !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
//                } else {
//                  return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                }
//              } else {
//                if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                  !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                } else {
//                  return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                }
//              }
//            }
//          }
//        } else {
//          if ("asc".equals(sortDirection.get(0))) {
//            if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//              !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString());
//            } else {
//              if ("asc".equals(sortDirection.get(1))) {
//                if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                  !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
//                } else {
//                  if ("asc".equals(sortDirection.get(2))) {
//                    if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                      !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  } else {
//                    if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                      !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  }
//                }
//              } else {
//                if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                  !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                } else {
//                  if ("asc".equals(sortDirection.get(2))) {
//                    if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                      !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  } else {
//                    if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                      !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  }
//                }
//              }
//            }
//          } else {
//            if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//              !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//            } else {
//              if ("asc".equals(sortDirection.get(1))) {
//                if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                  !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
//                } else {
//                  if ("asc".equals(sortDirection.get(2))) {
//                    if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                      !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  } else {
//                    if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                      !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  }
//                }
//              } else {
//                if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                  !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                } else {
//                  if ("asc".equals(sortDirection.get(2))) {
//                    if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                      !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  } else {
//                    if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                      !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  }
//                }
//              }
//            }
//          }
//        }
//      }).collect(Collectors.toList());
//    }
//    return tmpList;
//  }

  /**
   *
   * 帳票種別：2：単患者帳票
   * 並び替え
   * */
//  private List<JSONObject> OnePatientCompare(List<JSONObject> tmpList,List sortKey,List sortDirection) {
//    if (sortKey.size() != 0) {
//      tmpList = tmpList.stream().sorted((patA, patB) -> {
//        if (sortKey.size() == 1) {
//          String sortKeyOne = "";
//          String sortDirectionOne = "";
//          sortKeyOne = sortKey.get(0).toString();
//          sortDirectionOne = sortDirection.get(0).toString();
//          if ("asc".equals(sortDirectionOne)) {
//            if (patA.get(sortKeyOne) != null && patA.get(sortKeyOne) != "" &&
//              !patA.get(sortKeyOne).toString().equals(patB.get(sortKeyOne).toString())) {
//              return patA.get(sortKeyOne).toString().compareTo(patB.get(sortKeyOne).toString());
//            } else {
//              return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//            }
//          } else {
//            if (patA.get(sortKeyOne) != null && patA.get(sortKeyOne) != "" &&
//              !patA.get(sortKeyOne).toString().equals(patB.get(sortKeyOne).toString())) {
//              return patA.get(sortKeyOne).toString().compareTo(patB.get(sortKeyOne).toString()) * -1;
//            } else {
//              return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//            }
//          }
//        } else if (sortKey.size()==2) {
//          if ("asc".equals(sortDirection.get(0))) {
//            if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//              !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString());
//            } else {
//              if ("asc".equals(sortDirection.get(1))) {
//                if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                  !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
//                } else {
//                  return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                }
//              } else {
//                if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                  !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                } else {
//                  return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                }
//              }
//            }
//          } else {
//            if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//              !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//            } else {
//              if ("asc".equals(sortDirection.get(1))) {
//                if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                  !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
//                } else {
//                  return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                }
//              } else {
//                if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                  !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                } else {
//                  return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                }
//              }
//            }
//          }
//        } else {
//          if ("asc".equals(sortDirection.get(0))) {
//            if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//              !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString());
//            } else {
//              if ("asc".equals(sortDirection.get(1))) {
//                if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                  !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
//                } else {
//                  if ("asc".equals(sortDirection.get(2))) {
//                    if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                      !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  } else {
//                    if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                      !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  }
//                }
//              } else {
//                if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                  !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                } else {
//                  if ("asc".equals(sortDirection.get(2))) {
//                    if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                      !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  } else {
//                    if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                      !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  }
//                }
//              }
//            }
//          } else {
//            if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//              !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//            } else {
//              if ("asc".equals(sortDirection.get(1))) {
//                if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                  !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
//                } else {
//                  if ("asc".equals(sortDirection.get(2))) {
//                    if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                      !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  } else {
//                    if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                      !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  }
//                }
//              } else {
//                if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                  !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                } else {
//                  if ("asc".equals(sortDirection.get(2))) {
//                    if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                      !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  } else {
//                    if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                      !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  }
//                }
//              }
//            }
//          }
//        }
//      }).collect(Collectors.toList());
//    }
//    return tmpList;
//  }

  /**
   *
   * 帳票種別：1：治療経過表、2：単患者帳票
   * 並び替え
   * */
  private List<JSONObject> DialysisAndOnePatientReportCompare(List<JSONObject> tmpList, List<String> sortKey, List<String> sortDirection) {
    // sortKey が null または空の場合はそのまま返す
    if (sortKey == null || sortKey.isEmpty()) return tmpList;

    // Comparator を作成
    Comparator<JSONObject> comparator = (a, b) -> {
      // sortKey の優先順位に従って比較
      for (int i = 0; i < sortKey.size(); i++) {
        // 比較対象のフィールド名
        String key = sortKey.get(i);
        // sortDirection が存在すれば取得、なければ "asc" をデフォルトに設定
        String direction = (sortDirection != null && i < sortDirection.size()) ? sortDirection.get(i) : "asc";

        // JSON 内の値を安全に取得（null 対策）
        String va = safeString(a.opt(key));
        String vb = safeString(b.opt(key));

        // 値が同じ場合（大文字小文字を区別せず） → 次の優先フィールドへ
        if (va.equalsIgnoreCase(vb)) {
          continue;
        }

        int cmp;
        // pat_id の場合はシステム共通患者IDの特殊な比較ルールを使用
        if ("hosp_pat_id".equals(key)) {
          cmp = comparePatientId(va, vb);
        } else {
          // その他のフィールドは大文字小文字を区別しない辞書順で比較
          cmp = va.compareToIgnoreCase(vb);
        }

        // 昇順・降順を反映
        return "asc".equalsIgnoreCase(direction) ? cmp : -cmp;
      }

      // すべての優先フィールドが同じ場合は、最終的に pat_id で tie-breaker
      // これによりソートの安定性と決定性を保証
      return comparePatientId(safeString(a.opt("pat_id")), safeString(b.opt("pat_id")));
    };

    // Comparator に従ってソートしたリストを返す
    return tmpList.stream().sorted(comparator).collect(Collectors.toList());
  }
  // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end

  /**
   *
   * 帳票種別：3：複数患者帳票
   * 並び替え
   * */
  // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//  private List<JSONObject> MultiplePatientCompare(List<JSONObject> tmpList,List sortKey,List tmpSortKey,List sortDirection,String sortKeyOne, String sortKeyTwo,List sortKeyName){
//    if (tmpSortKey.size() != 0) {
//      String finalSortKeyOne = sortKeyOne;
//      String finalSortKeyTwo = sortKeyTwo;
//      tmpList = tmpList.stream().sorted((patA, patB) -> {
//        if (sortDirection.size() == 1) {
//          if (sortKeyName.contains(CoreConstant.ReportMenu.BLOOD_TYPE)) {
//            if ("asc".equals(sortDirection.get(0))) {
//              if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                return patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString());
//              } else {
//                if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                  !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                  return patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString());
//                } else {
//                  return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                }
//              }
//            } else {
//              if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                return patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) * -1;
//              } else {
//                if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                  !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                  return patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) * -1;
//                } else {
//                  return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                }
//              }
//            }
//          } else {
//            if ("asc".equals(sortDirection.get(0))) {
//              if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//                !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//                return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString());
//              } else {
//                return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//              }
//            } else {
//              if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//                !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//                return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//              } else {
//                return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//              }
//            }
//          }
//        }
//        else if (sortDirection.size() == 2) {
//          if (sortKeyName.contains(CoreConstant.ReportMenu.BLOOD_TYPE)) {
//            if ("asc".equals(sortDirection.get(0))) {
//              if (sortKeyName.get(0).toString().equals(CoreConstant.ReportMenu.BLOOD_TYPE)) {
//                if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                  !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                  return patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString());
//                } else {
//                  if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                    !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                    return patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString());
//                  } else {
//                   // mod #10571 複数患者帳票でテンプレート内の繰返しが機能しない 高　start
////                    if ("asc".equals(sortDirection.get(2))) {
////                      if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
////                        !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
////                        return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
////                      } else {
////                        return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
////                      }
////                    } else {
////                      if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
////                        !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
////                        return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
////                      } else {
////                        return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
////                      }
////                    }
//                    if ("asc".equals(sortDirection.get(1))) {
//                      if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                        !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                        return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
//                      } else {
//                        return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                      }
//                    } else {
//                      if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                        !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                        return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                      } else {
//                        return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                      }
//                    }
//                    // mod #10571 複数患者帳票でテンプレート内の繰返しが機能しない 高　end
//                  }
//                }
//              } else {
//                if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//                  !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//                  return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString());
//                } else {
//                  if ("asc".equals(sortDirection.get(1))) {
//                    if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                      !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                      return patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString());
//                    } else {
//                      if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                        !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                        return patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString());
//                      } else {
//                        return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                      }
//                    }
//                  } else {
//                    if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                      !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                      return patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) * -1;
//                    } else {
//                      if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                        !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                        return patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) * -1;
//                      } else {
//                        return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                      }
//                    }
//                  }
//                }
//              }
//            } else {
//              if (sortKeyName.get(0).toString().equals(CoreConstant.ReportMenu.BLOOD_TYPE)) {
//                if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                  !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                  return patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) * -1;
//                } else {
//                  if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                    !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                    return patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) * -1;
//                  } else {
//                    // mod #10571 複数患者帳票でテンプレート内の繰返しが機能しない 高　start
////                    if ("asc".equals(sortDirection.get(2))) {
////                      if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
////                        !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
////                        return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
////                      } else {
////                        return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
////                      }
////                    } else {
////                      if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
////                        !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
////                        return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
////                      } else {
////                        return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
////                      }
////                    }
//                    if ("asc".equals(sortDirection.get(1))) {
//                      if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                        !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                        return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
//                      } else {
//                        return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                      }
//                    } else {
//                      if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                        !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                        return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                      } else {
//                        return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                      }
//                    }
//                    // mod #10571 複数患者帳票でテンプレート内の繰返しが機能しない 高　end
//                  }
//                }
//              } else {
//                if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//                  !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//                  return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//                } else {
//                  if ("asc".equals(sortDirection.get(1))) {
//                    if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                      !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                      return patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString());
//                    } else {
//                      if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                        !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                        return patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString());
//                      } else {
//                        return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                      }
//                    }
//                  } else {
//                    if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                      !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                      return patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) * -1;
//                    } else {
//                      if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                        !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                        return patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) * -1;
//                      } else {
//                        return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                      }
//                    }
//                  }
//                }
//              }
//            }
//          } else {
//            if ("asc".equals(sortDirection.get(0))) {
//              if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//                !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//                return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString());
//              } else {
//                if ("asc".equals(sortDirection.get(1))) {
//                  if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                    !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                    return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
//                  } else {
//                    return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                  }
//                } else {
//                  if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                    !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                    return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                  } else {
//                    return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                  }
//                }
//              }
//            } else {
//              if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//                !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//                return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//              } else {
//                if ("asc".equals(sortDirection.get(1))) {
//                  if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                    !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                    return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
//                  } else {
//                    return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                  }
//                } else {
//                  if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                    !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                    return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                  } else {
//                    return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                  }
//                }
//              }
//            }
//          }
//        }
//        else {
//          if (sortKeyName.contains(CoreConstant.ReportMenu.BLOOD_TYPE)) {
//            if (sortKeyName.get(0).toString().equals(CoreConstant.ReportMenu.BLOOD_TYPE)) {
//              if ("asc".equals(sortDirection.get(0))) {
//                if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                  !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                  return patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString());
//                } else {
//                  if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                    !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                    return patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString());
//                  } else {
//                    // mod #10571 複数患者帳票でテンプレート内の繰返しが機能しない 高　start
////                    if ("asc".equals(sortDirection.get(2))) {
////                      if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
////                        !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
////                        return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
////                      } else {
////                        if ("asc".equals(sortDirection.get(3))) {
////                          if (patA.get(sortKey.get(3).toString()) != null && patA.get(sortKey.get(3).toString())!= "" &&
////                            !patA.get(sortKey.get(3).toString()).toString().equals(patB.get(sortKey.get(3).toString()).toString())) {
////                            return patA.get(sortKey.get(3).toString()).toString().compareTo(patB.get(sortKey.get(3).toString()).toString());
////                          } else {
////                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
////                          }
////                        } else {
////                          if (patA.get(sortKey.get(3).toString()) != null && patA.get(sortKey.get(3).toString())!= "" &&
////                            !patA.get(sortKey.get(3).toString()).toString().equals(patB.get(sortKey.get(3).toString()).toString())) {
////                            return patA.get(sortKey.get(3).toString()).toString().compareTo(patB.get(sortKey.get(3).toString()).toString()) * -1;
////                          } else {
////                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
////                          }
////                        }
////                      }
////                    } else {
////                      if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
////                        !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
////                        return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
////                      } else {
////                        if ("asc".equals(sortDirection.get(3))) {
////                          if (patA.get(sortKey.get(3).toString()) != null && patA.get(sortKey.get(3).toString())!= "" &&
////                            !patA.get(sortKey.get(3).toString()).toString().equals(patB.get(sortKey.get(3).toString()).toString())) {
////                            return patA.get(sortKey.get(3).toString()).toString().compareTo(patB.get(sortKey.get(3).toString()).toString());
////                          } else {
////                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
////                          }
////                        } else {
////                          if (patA.get(sortKey.get(3).toString()) != null && patA.get(sortKey.get(3).toString())!= "" &&
////                            !patA.get(sortKey.get(3).toString()).toString().equals(patB.get(sortKey.get(3).toString()).toString())) {
////                            return patA.get(sortKey.get(3).toString()).toString().compareTo(patB.get(sortKey.get(3).toString()).toString()) * -1;
////                          } else {
////                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
////                          }
////                        }
////                      }
////                    }
//                    if ("asc".equals(sortDirection.get(1))) {
//                      if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                        !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                        return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
//                      } else {
//                        if ("asc".equals(sortDirection.get(2))) {
//                          if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                            !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                            return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        } else {
//                          if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                            !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                            return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        }
//                      }
//                    } else {
//                      if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                        !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                        return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                      } else {
//                        if ("asc".equals(sortDirection.get(2))) {
//                          if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                            !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                            return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        } else {
//                          if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                            !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                            return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        }
//                      }
//                    }
//                    // mod #10571 複数患者帳票でテンプレート内の繰返しが機能しない 高　end
//                  }
//                }
//              } else {
//                if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                  !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                  return patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) * -1;
//                } else {
//                  if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                    !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                    return patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) * -1;
//                  } else {
//                    // mod #10571 複数患者帳票でテンプレート内の繰返しが機能しない 高　start
////                    if ("asc".equals(sortDirection.get(2))) {
////                      if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
////                        !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
////                        return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
////                      } else {
////                        if ("asc".equals(sortDirection.get(3))) {
////                          if (patA.get(sortKey.get(3).toString()) != null && patA.get(sortKey.get(3).toString())!= "" &&
////                            !patA.get(sortKey.get(3).toString()).toString().equals(patB.get(sortKey.get(3).toString()).toString())) {
////                            return patA.get(sortKey.get(3).toString()).toString().compareTo(patB.get(sortKey.get(3).toString()).toString());
////                          } else {
////                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
////                          }
////                        } else {
////                          if (patA.get(sortKey.get(3).toString()) != null && patA.get(sortKey.get(3).toString())!= "" &&
////                            !patA.get(sortKey.get(3).toString()).toString().equals(patB.get(sortKey.get(3).toString()).toString())) {
////                            return patA.get(sortKey.get(3).toString()).toString().compareTo(patB.get(sortKey.get(3).toString()).toString()) * -1;
////                          } else {
////                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
////                          }
////                        }
////                      }
////                    } else {
////                      if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
////                        !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
////                        return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
////                      } else {
////                        if ("asc".equals(sortDirection.get(3))) {
////                          if (patA.get(sortKey.get(3).toString()) != null && patA.get(sortKey.get(3).toString())!= "" &&
////                            !patA.get(sortKey.get(3).toString()).toString().equals(patB.get(sortKey.get(3).toString()).toString())) {
////                            return patA.get(sortKey.get(3).toString()).toString().compareTo(patB.get(sortKey.get(3).toString()).toString());
////                          } else {
////                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
////                          }
////                        } else {
////                          if (patA.get(sortKey.get(3).toString()) != null && patA.get(sortKey.get(3).toString())!= "" &&
////                            !patA.get(sortKey.get(3).toString()).toString().equals(patB.get(sortKey.get(3).toString()).toString())) {
////                            return patA.get(sortKey.get(3).toString()).toString().compareTo(patB.get(sortKey.get(3).toString()).toString()) * -1;
////                          } else {
////                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
////                          }
////                        }
////                      }
////                    }
//                    if ("asc".equals(sortDirection.get(1))) {
//                      if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                        !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                        return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
//                      } else {
//                        if ("asc".equals(sortDirection.get(2))) {
//                          if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                            !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                            return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        } else {
//                          if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                            !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                            return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        }
//                      }
//                    } else {
//                      if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                        !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                        return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                      } else {
//                        if ("asc".equals(sortDirection.get(2))) {
//                          if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                            !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                            return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        } else {
//                          if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                            !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                            return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        }
//                      }
//                    }
//                    // mod #10571 複数患者帳票でテンプレート内の繰返しが機能しない 高　end
//                  }
//                }
//              }
//            } else if (sortKeyName.get(1).toString().equals(CoreConstant.ReportMenu.BLOOD_TYPE)) {
//              if ("asc".equals(sortDirection.get(0))) {
//                if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//                  !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//                  return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString());
//                } else {
//                  if ("asc".equals(sortDirection.get(1))) {
//                    if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                      !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                      return patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString());
//                    } else {
//                      if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                        !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                        return patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString());
//                      } else {
//                        // mod #10571 複数患者帳票でテンプレート内の繰返しが機能しない 高　start
////                        if ("asc".equals(sortDirection.get(3))) {
////                          if (patA.get(sortKey.get(3).toString()) != null && patA.get(sortKey.get(3).toString())!= "" &&
////                            !patA.get(sortKey.get(3).toString()).toString().equals(patB.get(sortKey.get(3).toString()).toString())) {
////                            return patA.get(sortKey.get(3).toString()).toString().compareTo(patB.get(sortKey.get(3).toString()).toString());
////                          } else {
////                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
////                          }
////                        } else {
////                          if (patA.get(sortKey.get(3).toString()) != null && patA.get(sortKey.get(3).toString())!= "" &&
////                            !patA.get(sortKey.get(3).toString()).toString().equals(patB.get(sortKey.get(3).toString()).toString())) {
////                            return patA.get(sortKey.get(3).toString()).toString().compareTo(patB.get(sortKey.get(3).toString()).toString()) * -1;
////                          } else {
////                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
////                          }
////                        }
//                        if ("asc".equals(sortDirection.get(2))) {
//                          if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                            !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                            return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        } else {
//                          if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                            !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                            return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        }
//                        // mod #10571 複数患者帳票でテンプレート内の繰返しが機能しない 高　end
//                      }
//                    }
//                  } else {
//                    if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                      !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                      return patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) * -1;
//                    } else {
//                      if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                        !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                        return patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) * -1;
//                      } else {
//                        // mod #10571 複数患者帳票でテンプレート内の繰返しが機能しない 高　start
////                        if ("asc".equals(sortDirection.get(3))) {
////                          if (patA.get(sortKey.get(3).toString()) != null && patA.get(sortKey.get(3).toString())!= "" &&
////                            !patA.get(sortKey.get(3).toString()).toString().equals(patB.get(sortKey.get(3).toString()).toString())) {
////                            return patA.get(sortKey.get(3).toString()).toString().compareTo(patB.get(sortKey.get(3).toString()).toString());
////                          } else {
////                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
////                          }
////                        } else {
////                          if (patA.get(sortKey.get(3).toString()) != null && patA.get(sortKey.get(3).toString())!= "" &&
////                            !patA.get(sortKey.get(3).toString()).toString().equals(patB.get(sortKey.get(3).toString()).toString())) {
////                            return patA.get(sortKey.get(3).toString()).toString().compareTo(patB.get(sortKey.get(3).toString()).toString()) * -1;
////                          } else {
////                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
////                          }
////                        }
//                        if ("asc".equals(sortDirection.get(2))) {
//                          if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                            !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                            return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        } else {
//                          if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                            !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                            return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        }
//                        // mod #10571 複数患者帳票でテンプレート内の繰返しが機能しない 高　end
//                      }
//                    }
//                  }
//                }
//              } else {
//                if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//                  !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//                  return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//                } else {
//                  if ("asc".equals(sortDirection.get(1))) {
//                    if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                      !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                      return patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString());
//                    } else {
//                      if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                        !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                        return patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString());
//                      } else {
//                        // mod #10571 複数患者帳票でテンプレート内の繰返しが機能しない 高　start
////                        if ("asc".equals(sortDirection.get(3))) {
////                          if (patA.get(sortKey.get(3).toString()) != null && patA.get(sortKey.get(3).toString())!= "" &&
////                            !patA.get(sortKey.get(3).toString()).toString().equals(patB.get(sortKey.get(3).toString()).toString())) {
////                            return patA.get(sortKey.get(3).toString()).toString().compareTo(patB.get(sortKey.get(3).toString()).toString());
////                          } else {
////                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
////                          }
////                        } else {
////                          if (patA.get(sortKey.get(3).toString()) != null && patA.get(sortKey.get(3).toString())!= "" &&
////                            !patA.get(sortKey.get(3).toString()).toString().equals(patB.get(sortKey.get(3).toString()).toString())) {
////                            return patA.get(sortKey.get(3).toString()).toString().compareTo(patB.get(sortKey.get(3).toString()).toString()) * -1;
////                          } else {
////                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
////                          }
////                        }
//                        if ("asc".equals(sortDirection.get(2))) {
//                          if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                            !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                            return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        } else {
//                          if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                            !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                            return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        }
//                        // mod #10571 複数患者帳票でテンプレート内の繰返しが機能しない 高　end
//                      }
//                    }
//                  } else {
//                    if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                      !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                      return patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) * -1;
//                    } else {
//                      if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                        !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                        return patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) * -1;
//                      } else {
//                        // mod #10571 複数患者帳票でテンプレート内の繰返しが機能しない 高　start
////                        if ("asc".equals(sortDirection.get(3))) {
////                          if (patA.get(sortKey.get(3).toString()) != null && patA.get(sortKey.get(3).toString())!= "" &&
////                            !patA.get(sortKey.get(3).toString()).toString().equals(patB.get(sortKey.get(3).toString()).toString())) {
////                            return patA.get(sortKey.get(3).toString()).toString().compareTo(patB.get(sortKey.get(3).toString()).toString());
////                          } else {
////                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
////                          }
////                        } else {
////                          if (patA.get(sortKey.get(3).toString()) != null && patA.get(sortKey.get(3).toString())!= "" &&
////                            !patA.get(sortKey.get(3).toString()).toString().equals(patB.get(sortKey.get(3).toString()).toString())) {
////                            return patA.get(sortKey.get(3).toString()).toString().compareTo(patB.get(sortKey.get(3).toString()).toString()) * -1;
////                          } else {
////                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
////                          }
////                        }
//                        if ("asc".equals(sortDirection.get(2))) {
//                          if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                            !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                            return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        } else {
//                          if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                            !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                            return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        }
//                        // mod #10571 複数患者帳票でテンプレート内の繰返しが機能しない 高　end
//                      }
//                    }
//                  }
//                }
//              }
//            } else {
//              if ("asc".equals(sortDirection.get(0))) {
//                if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//                  !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//                  return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString());
//                } else {
//                  if ("asc".equals(sortDirection.get(1))) {
//                    if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                      !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                      return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
//                    } else {
//                      if ("asc".equals(sortDirection.get(2))) {
//                        if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                          !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                          return patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString());
//                        } else {
//                          if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                            !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                            return patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString());
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        }
//                      } else {
//                        if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                          !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                          return patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) * -1;
//                        } else {
//                          if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                            !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                            return patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) * -1;
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        }
//                      }
//                    }
//                  } else {
//                    if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                      !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                      return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                    } else {
//                      if ("asc".equals(sortDirection.get(2))) {
//                        if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                          !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                          return patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString());
//                        } else {
//                          if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                            !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                            return patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString());
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        }
//                      } else {
//                        if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                          !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                          return patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) * -1;
//                        } else {
//                          if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                            !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                            return patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) * -1;
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        }
//                      }
//                    }
//                  }
//                }
//              } else {
//                if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//                  !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//                  return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//                } else {
//                  if ("asc".equals(sortDirection.get(1))) {
//                    if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                      !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                      return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
//                    } else {
//                      if ("asc".equals(sortDirection.get(2))) {
//                        if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                          !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                          return patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString());
//                        } else {
//                          if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                            !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                            return patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString());
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        }
//                      } else {
//                        if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                          !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                          return patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) * -1;
//                        } else {
//                          if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                            !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                            return patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) * -1;
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        }
//                      }
//                    }
//                  } else {
//                    if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                      !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                      return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                    } else {
//                      if ("asc".equals(sortDirection.get(2))) {
//                        if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                          !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                          return patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString());
//                        } else {
//                          if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                            !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                            return patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString());
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        }
//                      } else {
//                        if (patA.get(finalSortKeyOne) != null && patA.get(finalSortKeyOne)!= "" &&
//                          !patA.get(finalSortKeyOne).toString().equals(patB.get(finalSortKeyOne).toString())) {
//                          return patA.get(finalSortKeyOne).toString().compareTo(patB.get(finalSortKeyOne).toString()) * -1;
//                        } else {
//                          if (patA.get(finalSortKeyTwo) != null && patA.get(finalSortKeyTwo)!= "" &&
//                            !patA.get(finalSortKeyTwo).toString().equals(patB.get(finalSortKeyTwo).toString())) {
//                            return patA.get(finalSortKeyTwo).toString().compareTo(patB.get(finalSortKeyTwo).toString()) * -1;
//                          } else {
//                            return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                          }
//                        }
//                      }
//                    }
//                  }
//                }
//              }
//            }
//          } else {
//            if ("asc".equals(sortDirection.get(0))) {
//              if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//                !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//                return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString());
//              } else {
//                if ("asc".equals(sortDirection.get(1))) {
//                  if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                    !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                    return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
//                  } else {
//                    if ("asc".equals(sortDirection.get(2))) {
//                      if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                        !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                        return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                      } else {
//                        return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                      }
//                    } else {
//                      if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                        !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                        return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                      } else {
//                        return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                      }
//                    }
//                  }
//                } else {
//                  if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                    !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                    return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                  } else {
//                    if ("asc".equals(sortDirection.get(2))) {
//                      if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                        !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                        return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                      } else {
//                        return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                      }
//                    } else {
//                      if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                        !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                        return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                      } else {
//                        return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                      }
//                    }
//                  }
//                }
//              }
//            } else {
//              if (patA.get(sortKey.get(0).toString()) != null && patA.get(sortKey.get(0).toString())!= "" &&
//                !patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString())) {
//                return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//              } else {
//                if ("asc".equals(sortDirection.get(1))) {
//                  if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                    !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                    return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
//                  } else {
//                    if ("asc".equals(sortDirection.get(2))) {
//                      if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                        !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                        return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                      } else {
//                        return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                      }
//                    } else {
//                      if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                        !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                        return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                      } else {
//                        return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                      }
//                    }
//                  }
//                } else {
//                  if (patA.get(sortKey.get(1).toString()) != null && patA.get(sortKey.get(1).toString())!= "" &&
//                    !patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString())) {
//                    return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                  } else {
//                    if ("asc".equals(sortDirection.get(2))) {
//                      if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                        !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                        return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                      } else {
//                        return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                      }
//                    } else {
//                      if (patA.get(sortKey.get(2).toString()) != null && patA.get(sortKey.get(2).toString())!= "" &&
//                        !patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString())) {
//                        return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                      } else {
//                        return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                      }
//                    }
//                  }
//                }
//              }
//            }
//          }
//        }
//      }).collect(Collectors.toList());
//    }
//    return tmpList;
//  }
  private List<JSONObject> MultiplePatientCompare(List<JSONObject> tmpList,
                                                  List sortKey,
                                                  List tmpSortKey,
                                                  List sortDirection,
                                                  String sortKeyOne,
                                                  String sortKeyTwo,
                                                  List sortKeyName) {
    // sortKey が null または空の場合はそのまま返す
    if (tmpSortKey == null || tmpSortKey.isEmpty()) return tmpList;

    // 血液型用の2つのフィールドを保持
    String finalSortKeyOne = sortKeyOne;
    String finalSortKeyTwo = sortKeyTwo;

    // Comparator を作成
    Comparator<JSONObject> comparator = (a, b) -> {
      // sortKey の優先順位に従って比較
      for (int i = 0; i < sortKey.size(); i++) {
        String key = String.valueOf(sortKey.get(i));
        // sortDirection が存在すれば取得、なければ "asc" をデフォルト
        String direction = (sortDirection != null && i < sortDirection.size()) ? String.valueOf(sortDirection.get(i)) : "asc";

        // 血液型の場合は特殊処理: finalSortKeyOne, finalSortKeyTwo を順に比較
        if (sortKeyName.contains(CoreConstant.ReportMenu.BLOOD_TYPE) && "pat_blood_type_abo".equals(key)) {
          String va = safeString(a.opt(finalSortKeyOne));
          String vb = safeString(b.opt(finalSortKeyOne));
          if (!va.equalsIgnoreCase(vb)) {
            int cmp = va.compareToIgnoreCase(vb);
            return "asc".equalsIgnoreCase(direction) ? cmp : -cmp;
          }

          va = safeString(a.opt(finalSortKeyTwo));
          vb = safeString(b.opt(finalSortKeyTwo));
          if (!va.equalsIgnoreCase(vb)) {
            int cmp = va.compareToIgnoreCase(vb);
            return "asc".equalsIgnoreCase(direction) ? cmp : -cmp;
          }

          // 両方のフィールドが同じ場合は次の sortKey へ
          continue;
        }

        // 血液型以外の通常フィールドの処理
        String va = safeString(a.opt(key));
        String vb = safeString(b.opt(key));

        // 値が同じ場合は次の優先キーへ
        if (va.equalsIgnoreCase(vb)) continue;

        int cmp;
        // hosp_pat_id は専用の比較ルールを使用
        if ("hosp_pat_id".equals(key)) {
          cmp = comparePatientId(va, vb);
        } else {
          // その他の文字列は大文字小文字を区別せず辞書順で比較
          cmp = va.compareToIgnoreCase(vb);
        }

        // 昇順・降順を適用
        return "asc".equalsIgnoreCase(direction) ? cmp : -cmp;
      }

      // 全ての優先フィールドが同じ場合は、pat_id で tie-breaker
      // これによりソートの安定性と決定性を保証
      return comparePatientId(safeString(a.opt("pat_id")), safeString(b.opt("pat_id")));
    };

    // Comparator に従ってソートしたリストを返す
    return tmpList.stream().sorted(comparator).collect(Collectors.toList());
  }
  // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end

  /**
   *
   * 帳票種別：5：配布リスト（ベッド）
   * 並び替え
   * */
  private List<JSONObject> DistributionListBedCompare (List<JSONObject> tmpList,List sortKey,List sortDirection,List tmpSortKey) {
    if (tmpSortKey.size() != 0) {
      tmpList = tmpList.stream().sorted((patA, patB) -> {
        if (tmpSortKey.size() == 1) {
          if (sortDirection.get(0).toString().equals("asc")) {
            if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
              patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString());
            } else{
              return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
            }
          } else {
            if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
              patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
            } else{
              return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
            }
          }
        } else if (tmpSortKey.size() == 2) {
          if (sortDirection.get(0).toString().equals("asc")) {
            if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
              patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString());
            } else{
              if (sortDirection.get(1).toString().equals("asc")) {
                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
                } else {
                  return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
                }
              } else {
                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
                } else {
                  return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
                }
              }
            }
          } else {
            if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
              patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
            } else{
              if (sortDirection.get(1).toString().equals("asc")) {
                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
                } else {
                  return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
                }
              } else {
                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
                } else {
                  return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
                }
              }
            }
          }
        } else {
          if (sortDirection.get(0).toString().equals("asc")) {
            if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
              patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString());
            } else{
              if (sortDirection.get(1).toString().equals("asc")) {
                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
                } else {
                  if (sortDirection.get(2).toString().equals("asc")) {
                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
                    } else {
                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
                    }
                  } else {
                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
                    } else {
                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
                    }
                  }
                }
              } else {
                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
                } else {
                  if (sortDirection.get(2).toString().equals("asc")) {
                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
                    } else {
                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
                    }
                  } else {
                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
                    } else {
                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
                    }
                  }
                }
              }
            }
          } else {
            if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
              patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
            } else{
              if (sortDirection.get(1).toString().equals("asc")) {
                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
                } else {
                  if (sortDirection.get(2).toString().equals("asc")) {
                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
                    } else {
                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
                    }
                  } else {
                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
                    } else {
                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
                    }
                  }
                }
              } else {
                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
                } else {
                  if (sortDirection.get(2).toString().equals("asc")) {
                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
                    } else {
                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
                    }
                  } else {
                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
                    } else {
                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
                    }
                  }
                }
              }
            }
          }
        }
      }).collect(Collectors.toList());
    }
    return tmpList;
  }

  /**
   *
   * 帳票種別：7：装置帳票
   * 並び替え
   * */
  private List<JSONObject> MachineReportCompare (List<JSONObject> tmpList,List sortKey,List sortDirection,List tmpSortKey) {

    // add #9323 帳票「並び替え」機能のオーバーホール　高 start
    for(int index = 0; index < sortKey.size();index++) {
      for (int num =0; num < tmpList.size();num++) {
        if (tmpList.get(num).get(sortKey.get(index).toString()) == "" && "asc".equals(sortDirection.get(index))) {
          tmpList.get(num).put(sortKey.get(index).toString(),"100000000");
        }
        if (tmpList.get(num).get(sortKey.get(index).toString()) == "" && "desc".equals(sortDirection.get(index))) {
          tmpList.get(num).put(sortKey.get(index).toString(),"-100000000");
        }
      }
    }
    // add #9323 帳票「並び替え」機能のオーバーホール　高 end

    if (tmpSortKey.size() != 0) {
      tmpList = tmpList.stream().sorted((patA, patB) -> {
        if (tmpSortKey.size() == 1) {
          if (sortDirection.get(0).toString().equals("asc")) {
            if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
              patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString());
            } else{
              return 0;
            }
          } else {
            if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
              patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
            } else{
              return 0;
            }
          }
        } else if (tmpSortKey.size() == 2) {
          if (sortDirection.get(0).toString().equals("asc")) {
            if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
              patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString());
            } else{
              if (sortDirection.get(1).toString().equals("asc")) {
                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
                } else {
                  return 0;
                }
              } else {
                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
                } else {
                  return 0;
                }
              }
            }
          } else {
            if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
              patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
            } else{
              if (sortDirection.get(1).toString().equals("asc")) {
                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
                } else {
                  return 0;
                }
              } else {
                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
                } else {
                  return 0;
                }
              }
            }
          }
        } else {
          if (sortDirection.get(0).toString().equals("asc")) {
            if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
              patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString());
            } else{
              if (sortDirection.get(1).toString().equals("asc")) {
                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
                } else {
                  if (sortDirection.get(2).toString().equals("asc")) {
                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
                    } else {
                      return 0;
                    }
                  } else {
                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
                    } else {
                      return 0;
                    }
                  }
                }
              } else {
                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
                } else {
                  if (sortDirection.get(2).toString().equals("asc")) {
                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
                    } else {
                      return 0;
                    }
                  } else {
                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
                    } else {
                      return 0;
                    }
                  }
                }
              }
            }
          } else {
            if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
              patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
            } else{
              if (sortDirection.get(1).toString().equals("asc")) {
                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
                } else {
                  if (sortDirection.get(2).toString().equals("asc")) {
                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
                    } else {
                      return 0;
                    }
                  } else {
                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
                    } else {
                      return 0;
                    }
                  }
                }
              } else {
                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
                } else {
                  if (sortDirection.get(2).toString().equals("asc")) {
                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
                    } else {
                      return 0;
                    }
                  } else {
                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
                    } else {
                      return 0;
                    }
                  }
                }
              }
            }
          }
        }
      }).collect(Collectors.toList());
    }

    // add #9323 帳票「並び替え」機能のオーバーホール　高 start
    for(int index = 0; index < sortKey.size();index++) {
      for (int num =0; num < tmpList.size();num++) {
        if (tmpList.get(num).get(sortKey.get(index).toString()) == "-100000000" ||
          tmpList.get(num).get(sortKey.get(index).toString()) == "100000000") {
          tmpList.get(num).put(sortKey.get(index).toString(),"");
        }
      }
    }
    // add #9323 帳票「並び替え」機能のオーバーホール　高 end
    return tmpList;
  }

  /**
   *
   * 帳票種別：9：紹介状
   * 並び替え
   * */
  // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//  private List<JSONObject> IntroductionReportCompare (List<JSONObject> tmpList,List sortKey,List sortDirection,List tmpSortKey){
//    if (tmpSortKey.size() != 0) {
//      tmpList = tmpList.stream().sorted((patA, patB) -> {
//        if (tmpSortKey.size() == 1) {
//          if (sortDirection.get(0).toString().equals("asc")) {
//            if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
//              patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
//              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString());
//            } else{
//              return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//            }
//          } else {
//            if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
//              patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
//              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//            } else{
//              return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//            }
//          }
//        } else if (tmpSortKey.size() == 2) {
//          if (sortDirection.get(0).toString().equals("asc")) {
//            if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
//              patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
//              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString());
//            } else{
//              if (sortDirection.get(1).toString().equals("asc")) {
//                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
//                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
//                } else {
//                  return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                }
//              } else {
//                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
//                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                } else {
//                  return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                }
//              }
//            }
//          } else {
//            if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
//              patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
//              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//            } else{
//              if (sortDirection.get(1).toString().equals("asc")) {
//                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
//                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
//                } else {
//                  return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                }
//              } else {
//                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
//                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                } else {
//                  return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                }
//              }
//            }
//          }
//        } else {
//          if (sortDirection.get(0).toString().equals("asc")) {
//            if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
//              patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
//              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString());
//            } else{
//              if (sortDirection.get(1).toString().equals("asc")) {
//                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
//                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
//                } else {
//                  if (sortDirection.get(2).toString().equals("asc")) {
//                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
//                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  } else {
//                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
//                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  }
//                }
//              } else {
//                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
//                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                } else {
//                  if (sortDirection.get(2).toString().equals("asc")) {
//                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
//                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  } else {
//                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
//                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  }
//                }
//              }
//            }
//          } else {
//            if (!patA.get(sortKey.get(0).toString()).toString().equals(patB.get(sortKey.get(0).toString()).toString()) &&
//              patA.get(sortKey.get(0).toString()).toString() != "" && patB.get(sortKey.get(0).toString()).toString() != "") {
//              return patA.get(sortKey.get(0).toString()).toString().compareTo(patB.get(sortKey.get(0).toString()).toString()) * -1;
//            } else{
//              if (sortDirection.get(1).toString().equals("asc")) {
//                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
//                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString());
//                } else {
//                  if (sortDirection.get(2).toString().equals("asc")) {
//                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
//                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  } else {
//                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
//                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  }
//                }
//              } else {
//                if (!patA.get(sortKey.get(1).toString()).toString().equals(patB.get(sortKey.get(1).toString()).toString()) &&
//                  patA.get(sortKey.get(1).toString()).toString() != "" && patB.get(sortKey.get(1).toString()).toString() != "") {
//                  return patA.get(sortKey.get(1).toString()).toString().compareTo(patB.get(sortKey.get(1).toString()).toString()) * -1;
//                } else {
//                  if (sortDirection.get(2).toString().equals("asc")) {
//                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
//                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString());
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  } else {
//                    if (!patA.get(sortKey.get(2).toString()).toString().equals(patB.get(sortKey.get(2).toString()).toString()) &&
//                      patA.get(sortKey.get(2).toString()).toString() != "" && patB.get(sortKey.get(2).toString()).toString() != "") {
//                      return patA.get(sortKey.get(2).toString()).toString().compareTo(patB.get(sortKey.get(2).toString()).toString()) * -1;
//                    } else {
//                      return patA.get("pat_id").toString().compareTo(patB.get("pat_id").toString());
//                    }
//                  }
//                }
//              }
//            }
//          }
//        }
//      }).collect(Collectors.toList());
//    }
//    return tmpList;
//  }
  private List<JSONObject> IntroductionReportCompare(List<JSONObject> tmpList,List sortKey,List sortDirection,List tmpSortKey) {
    // tmpSortKey が null または空の場合はそのまま返す
    if (tmpSortKey == null || tmpSortKey.isEmpty()) return tmpList;

    // Comparator を作成
    Comparator<JSONObject> comparator = (a, b) -> {
      // sortKey の優先順位に従って比較
      for (int i = 0; i < sortKey.size(); i++) {
        // 比較対象のフィールド名
        String key = String.valueOf(sortKey.get(i));
        // sortDirection が存在すれば取得、なければ "asc" をデフォルトに設定
        String direction = (sortDirection != null && i < sortDirection.size()) ? String.valueOf(sortDirection.get(i)) : "asc";

        // JSON 内の値を安全に取得（null 対策）
        String va = safeString(a.opt(key));
        String vb = safeString(b.opt(key));

        // 値が同じ場合（大文字小文字を区別せず） → 次の優先フィールドへ
        if (va.equalsIgnoreCase(vb)) {
          continue;
        }

        int cmp;
        // pat_id の場合はシステム共通患者IDの特殊な比較ルールを使用
        if ("hosp_pat_id".equals(key)) {
          cmp = comparePatientId(va, vb);
        } else {
          // その他のフィールドは大文字小文字を区別しない辞書順で比較
          cmp = va.compareToIgnoreCase(vb);
        }

        // 昇順・降順を反映
        return "asc".equalsIgnoreCase(direction) ? cmp : -cmp;
      }

      // すべての優先フィールドが同じ場合は、最終的に pat_id で tie-breaker
      // これによりソートの安定性と決定性を保証
      return comparePatientId(safeString(a.opt("pat_id")), safeString(b.opt("pat_id")));
    };

    // Comparator に従ってソートしたリストを返す
    return tmpList.stream().sorted(comparator).collect(Collectors.toList());
  }
  // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
  // add #9323 帳票「並び替え」機能のオーバーホール　高 end

  // add #9577 「？？？？」患者は表示されません（複数患者帳票）。 2024/03/18 高 start
  /**
   * Param要素情報からsqlCodeの値を取得します.
   *
   * @param params Param要素情報
   * @return SQLCODEのリスト
   */
  private List<String> getSqlCode(List<ReportXmlParam> params){

    // sqlCodeの値を取得する
    List<String> sqlCodes = params.stream()
      .filter(p -> !org.springframework.util.StringUtils.isEmpty(p.getSqlCode()))
      .map(p -> p.getSqlCode())
      .collect(Collectors.toList())
      ;

    // formula属性に設定されているsqlCodeを取得する
    List<String> tmpList = new ArrayList<>();
    params.stream()
      .filter(p -> p.isFormulaToCalc())
      .forEach(p -> tmpList.addAll(getSqlCodeAndDataCodes(p.getFormula())));
    tmpList.stream().forEach(t -> {
      String[] tmps = t.split(Pattern.quote("."));
      if (tmps.length == 2) {
        sqlCodes.add(tmps[0]);
      }
    });

    // 重複は除外する
    return sqlCodes.stream().distinct().collect(toList());
  }
  /**
   * 計算式から <code>[SqlCode.データ項目コード]</code>を取得します.
   * @param formula 計算式
   * @return <code>[SqlCode.データ項目コード]</code>のリスト
   */
  private List<String> getSqlCodeAndDataCodes(String formula) {
    List<String> result = new ArrayList<>();
    Matcher m = Pattern.compile("\\[([^\\[\\]]+)\\]").matcher(formula);
    while (m.find()) {
      result.add(m.group(1));
    }
    return result;
  }
  // add #9577 「？？？？」患者は表示されません（複数患者帳票）。 2024/03/18 高 end
  //add #10504 一日複数回指示ある患者の治療経過表出力で空帳票が出力される 王永吉 start
  public void getOption(boolean optionFlag){
    // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang start
    optionCdFlag.set(optionFlag);
    // #10959 システム内でstatic変数を使っている箇所の洗い出し 20260428 mod yangxuewang end
  }
  //add #10504 一日複数回指示ある患者の治療経過表出力で空帳票が出力される 王永吉 end

  // add #9323 帳票「並び替え」機能のオーバーホール(複数患者帳票)　高 start

  /**
   * ソートに使用するための一時的な値を追加提供する
   * @param sortKey
   * @param sortDirection
   * @param sortKeyName
   * @param tmpList
   *
   * */
  public void addTmpValueForSort(List sortKey,List sortDirection,List sortKeyName,List<JSONObject> tmpList) {
    for (int index = 0; index < sortKey.size();index++) {
      // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//      if (!CoreConstant.ReportMenu.BLOOD_TYPE.equals(sortKey.get(index).toString()) && !"in_out_class".equals(sortKey.get(index).toString()) && !"is_infect".equals(sortKey.get(index).toString())) {
      if (!CoreConstant.ReportMenu.BLOOD_TYPE.equals(sortKey.get(index).toString()) && !"in_out_class".equals(sortKey.get(index).toString()) && !"is_infect".equals(sortKey.get(index).toString())
        && !"hosp_pat_id".equals(sortKey.get(index).toString())&& !"pat_name_kana".equals(sortKey.get(index).toString())) {
        // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
        if (sortDirection.get(index).equals("asc")) {
          for (int num = 0;num < tmpList.size();num++){
            // mod #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 start
//            if (StringUtils.isEmpty(tmpList.get(num).get(sortKey.get(index).toString()).toString()) ||
//              ("pat_group_order".equals(sortKey.get(index).toString()) &&
//                StringUtils.isEmpty(tmpList.get(num).get(sortKey.get(index).toString()).toString().replace("0","")))) {
//              tmpList.get(num).put(sortKey.get(index).toString(),"1-"+ tmpList.get(num).get(sortKey.get(index).toString()).toString());
            if (StringUtils.isEmpty(tmpList.get(num).get(sortKey.get(index).toString()).toString()) ||
              (("pat_group_order".equals(sortKey.get(index).toString()) || "bed_group_order".equals(sortKey.get(index).toString()))&&
                StringUtils.isEmpty(tmpList.get(num).get(sortKey.get(index).toString()).toString().replace("0","")))) {
              tmpList.get(num).put(sortKey.get(index).toString(),"1-");
              // mod #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 end
            } else {
              if ("0".equals(tmpList.get(num).get(sortKey.get(index).toString()).toString()) && "pat_sex".equals(sortKey.get(index).toString())) {
                tmpList.get(num).put(sortKey.get(index).toString(),"1-"+ tmpList.get(num).get(sortKey.get(index).toString()).toString());
              } else if (" ".equals(tmpList.get(num).get(sortKey.get(index).toString()).toString()) && "pat_name_kana".equals(sortKey.get(index).toString())) {
                tmpList.get(num).put(sortKey.get(index).toString(),"1-"+ tmpList.get(num).get(sortKey.get(index).toString()).toString());
              } else {
                tmpList.get(num).put(sortKey.get(index).toString(),"0-"+ tmpList.get(num).get(sortKey.get(index).toString()).toString());
              }
            }
          }
        } else if (sortDirection.get(index).equals("desc")) {
          for (int num = 0;num < tmpList.size();num++){
            // mod #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 start
//            if (StringUtils.isEmpty(tmpList.get(num).get(sortKey.get(index).toString()).toString()) ||
//              ("pat_group_order".equals(sortKey.get(index).toString()) &&
//                StringUtils.isEmpty(tmpList.get(num).get(sortKey.get(index).toString()).toString().replace("0","")))) {
//              tmpList.get(num).put(sortKey.get(index).toString(),"0-"+ tmpList.get(num).get(sortKey.get(index).toString()).toString());
            if (StringUtils.isEmpty(tmpList.get(num).get(sortKey.get(index).toString()).toString()) ||
              (("pat_group_order".equals(sortKey.get(index).toString()) || "bed_group_order".equals(sortKey.get(index).toString())) &&
                StringUtils.isEmpty(tmpList.get(num).get(sortKey.get(index).toString()).toString().replace("0","")))) {
              tmpList.get(num).put(sortKey.get(index).toString(),"0-");
              // mod #9323 帳票「並び替え」機能のオーバーホール【マニュアル検証指摘】 高 end
            } else {
              if ("0".equals(tmpList.get(num).get(sortKey.get(index).toString()).toString()) && "pat_sex".equals(sortKey.get(index).toString())) {
                tmpList.get(num).put(sortKey.get(index).toString(),"0-"+ tmpList.get(num).get(sortKey.get(index).toString()).toString());
              } else if (" ".equals(tmpList.get(num).get(sortKey.get(index).toString()).toString()) && "pat_name_kana".equals(sortKey.get(index).toString())) {
                tmpList.get(num).put(sortKey.get(index).toString(),"0-"+ tmpList.get(num).get(sortKey.get(index).toString()).toString());
              } else {
                tmpList.get(num).put(sortKey.get(index).toString(),"1-"+ tmpList.get(num).get(sortKey.get(index).toString()).toString());
              }
            }
          }
        }
      }
    }
  }

  /**
   * 一時的な値を削除する
   * @param sortKey
   * @param tmpList
   *
   * */
  public void removeTmpValueForSort(List sortKey ,List<JSONObject> tmpList) {
    for (int index = 0; index < sortKey.size();index++) {
      if (!CoreConstant.ReportMenu.BLOOD_TYPE.equals(sortKey.get(index).toString()) && !"in_out_class".equals(sortKey.get(index).toString()) && !"is_infect".equals(sortKey.get(index).toString())) {
        for (int indexList = 0;indexList < tmpList.size();indexList++) {
          tmpList.get(indexList).put(sortKey.get(index).toString(),tmpList.get(indexList).get(sortKey.get(index).toString()).toString().replaceFirst("^.{2}",""));
        }
      }
    }
  }
  // add #9323 帳票「並び替え」機能のオーバーホール(複数患者帳票)　高 end
  // add 11009 カテゴリ「印刷情報」の仕様調整 房 start
  /**
   * パラメータ編集
   * @param payload
   * @param dataKey
   */
  private void requestParamEdit(ReportMenuSortContainer payload, Map<String, Object> dataKey) {
    // ログイン者
    if(!dataKey.containsKey("login")) {
      dataKey.put("login", payload.getLogin());
    }
    // フリーワード
    if(!dataKey.containsKey("freeWord")) {
      dataKey.put("freeWord", payload.getFreeWord());
    }
    // 治療日
    if(!dataKey.containsKey("treatDate")) {
      dataKey.put("treatDate", payload.getTreatDate());
    } else {
      if(dataKey.get("treatDate") == null) {
        dataKey.put("treatDate", payload.getTreatDate());
      }
    }
    // 予定/実績
    if(!dataKey.containsKey("expressCondCdStr")) {
      dataKey.put("expressCondCdStr", payload.getExpressCondCdStr());
    }
    // クール名
    if(!dataKey.containsKey("kurNames")) {
      dataKey.put("kurNames", payload.getKurNames());
    }
    // ベッドグループ名
    if(!dataKey.containsKey("bedCdListString")) {
      dataKey.put("bedCdListString", payload.getBedCdListString());
    }
    // 患者グループ名
    if(!dataKey.containsKey("patGroups")) {
      dataKey.put("patGroups", payload.getPatGroups());
    }
    // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
    // 基準日（印刷情報用）
    if(!dataKey.containsKey("dateKindPrint")) {
      dataKey.put("dateKindPrint", payload.getDateKindPrint());
    }
    // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
    // 開始日
    if(!dataKey.containsKey("fromDate")) {
      dataKey.put("fromDate", payload.getFromDate());
    }
    // 終了日
    if(!dataKey.containsKey("toDate")) {
      dataKey.put("toDate", payload.getToDate());
    }
    // 期間
    if(!dataKey.containsKey("period")) {
      // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
//      if(payload.getPeriod() != null && payload.getPeriod().contains("～")) {
//        String[] tempArr = payload.getPeriod().split("～");
//        String period = tempArr[0].substring(0, 4) + "年" + tempArr[0].substring(4, 6) + "月" + tempArr[0].substring(6) + "日～"
//          + tempArr[1].substring(0, 4) + "年" + tempArr[1].substring(4, 6) + "月" + tempArr[1].substring(6) + "日";
//        dataKey.put("period", period);
//      }
//    } else {
//      // 画面で選択しない場合、空白を表示する。
//      if(payload.getPeriod() == null) {
//        dataKey.put("period", null);
//      }
      dataKey.put("period", payload.getPeriod());
      // mod #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
    }
    // 1日指定日
    if(!dataKey.containsKey("specifyDate")) {
      dataKey.put("specifyDate", payload.getSpecifyDate());
    }
    // 週数
    if(!dataKey.containsKey("weeks")) {
      dataKey.put("weeks", payload.getWeeks());
    }
    // 種別
    dataKey.put("kind", payload.getKind());

    // 医療材料分類
    if(!dataKey.containsKey("equipmentType")) {
      dataKey.put("equipmentType", payload.getEquipmentType());
    }
    // 薬剤分類
    if(!dataKey.containsKey("medicineType")) {
      dataKey.put("medicineType", payload.getMedicineType());
    }
    // 採血管分類
    if(!dataKey.containsKey("inspectionType")) {
      dataKey.put("inspectionType", payload.getInspectionType());
    }
    // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
    // 検査セット分類
    if(!dataKey.containsKey("examSetType")) {
      dataKey.put("examSetType", payload.getExamSetType());
    }
    // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
    // 検査日数指定基準日
    if(!dataKey.containsKey("inspectionDate")) {
      if(payload.getInspectionDate() != null) {
        dataKey.put("inspectionDate", payload.getInspectionDate().replace("-", "/"));
      }
    }
    // 検査出力方向
    if(!dataKey.containsKey("inspectionDirection")) {
      dataKey.put("inspectionDirection", payload.getInspectionDirection());
    }
    // 検査出力日数
    if(!dataKey.containsKey("inspectionDays")) {
      dataKey.put("inspectionDays", payload.getInspectionDays());
    }
    // 検査区分
    if(!dataKey.containsKey("inspectionKbn")) {
      dataKey.put("inspectionKbn", payload.getInspectionKbn());
    }
    // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy start
    // 処方区分
    if(!dataKey.containsKey("prescriptionKbn")) {
      dataKey.put("prescriptionKbn", payload.getPrescriptionKbn());
    }
    // 紹介区分
    if(!dataKey.containsKey("introductionKbn")) {
      dataKey.put("introductionKbn", payload.getIntroductionKbn());
    }
    // add #12307 印刷情報カテゴリの最新仕様との差異修正 sunsy end
    if(payload.getSortColumn1() != null && !"".equals(payload.getSortColumn1())) {
      // 第1優先情報
      dataKey.put("sortColumn1", payload.getSortColumn1());
    }
    // 第1優先昇順/降順
    if(payload.getSortOrder1() != null && !"".equals(payload.getSortOrder1())) {
      if("asc".equals(payload.getSortOrder1())) {
        dataKey.put("sortOrder1", "0");
      } else {
        dataKey.put("sortOrder1", "1");
      }
    }
    if(payload.getSortColumn2() != null && !"".equals(payload.getSortColumn2())) {
      // 第2優先情報
      dataKey.put("sortColumn2", payload.getSortColumn2());
    }
    // 第2優先昇順/降順
    if(payload.getSortOrder2() != null && !"".equals(payload.getSortOrder2())) {
      if("asc".equals(payload.getSortOrder2())) {
        dataKey.put("sortOrder2", "0");
      } else {
        dataKey.put("sortOrder2", "1");
      }
    }
    if(payload.getSortColumn3() != null && !"".equals(payload.getSortColumn3())) {
      // 第3優先情報
      dataKey.put("sortColumn3", payload.getSortColumn3());
    }
    // 第3優先昇順/降順
    if(payload.getSortOrder3() != null && !"".equals(payload.getSortOrder3())) {
      if("asc".equals(payload.getSortOrder3())) {
        dataKey.put("sortOrder3", "0");
      } else {
        dataKey.put("sortOrder3", "1");
      }
    }
    // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 start
    if(!dataKey.containsKey("prescriptionClassList")) {
      dataKey.put("prescriptionClassList", payload.getPrescriptionClassList());
    }
    // add #11354 【たくしん会：改良】帳票画面データ抽出条件に「処方箋区分」を追加 高 end
    // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe start
    if(!dataKey.containsKey("regOrderClassList")){
      if (payload.getRegOrderClassList() != null && payload.getRegOrderClassList().size() > 0) {
        dataKey.put("regOrderClassList", payload.getRegOrderClassList());
      } else {
        dataKey.put("regOrderClassList", new ArrayList<String>(Arrays.asList("1","2","0")));
      }
    }
    // add #12400 配布リスト、ラベルのテンプレート処理不正 limingzhe end
  }
  // add 11009 カテゴリ「印刷情報」の仕様調整 房 end

  // add #11737 グラフがセルサイズにフィットしないときがある 房 start
  public List<Long> listPatIdGet(ReportMenuSortContainer reportMenu) {
    List<Map<String, String>> sortConditions = reportMenu.getSortCondition();
    List<Long> patIdList = reportMenu.getPatIds();
    List<Long> listOrdNo = new ArrayList<>();
    List<Long> listPatId = new ArrayList<>();
    Map<String,List> searchList = new HashMap<>();
    searchList =this.searchMap(reportMenu.getFacilityCd());

    // 1日指定に応じて、開始日、終了日を格納
    LocalDateTime localDateFrom = LocalDate.parse(reportMenu.getSpecifyDate(), DateTimeFormatter.ofPattern("uuuuMMdd")).atStartOfDay();
    LocalDateTime localDateTo = localDateFrom.plusDays(1L).minusNanos(1000);

    // 期間内のordMain取得
    List<OrdMain> ordList = reportMenuDao.selectByTreatDateAndPatIds(patIdList, reportMenu.getSpecifyDate(), reportMenu.getFromDate(), reportMenu.getToDate());
    //【01】透析日指定 / 検査日指定の判定
    if (reportMenu.getIsDialysisDate()) {
      // 透析日指定
      // 指定日、または期間内の透析日をターゲットに治療情報を取得します。
      if(null != patIdList && patIdList.size() > 0) {
        for(Long patId : patIdList) {
          for (OrdMain ord : ordList) {
            if (patId.equals(ord.getPatId())) {
              listOrdNo.add(ord.getOrdNo());
              listPatId.add(ord.getPatId());
            }
          }
        }
      }
    }
    else {
      // 検査日指定：検査日の存在する日の ordNo をリストに格納します。該当のordNoが存在しない場合は、-1Lを格納します。

      List<String> regOrderClassList = reportMenu.getRegOrderClassList();
      if (regOrderClassList == null || regOrderClassList.size() == 0) {
        // 検査区分が全て未チェックの場合は、全選択扱いとする
        regOrderClassList = new ArrayList<String>(Arrays.asList("1", "2", "0"));
      }

      for (Long patId : patIdList) {
        List<PatExamMain> examMainList = reportMenuDao.selectExamByDate(patId, Timestamp.valueOf(localDateFrom), Timestamp.valueOf(localDateTo), regOrderClassList);
        List<Long> ordNos = new ArrayList<>();
        for (PatExamMain exam : examMainList) {
          if (Objects.equal(exam.getExamStatus(), "1")) {
            // 検査実績：検査結果の場合は、result_exam_date と比較

            // 検査と同日の透析実績リストを取得する
            String uuuuMMdd = exam.getResultExamDate().toLocalDateTime().toLocalDate().format(DateTimeFormatter.ofPattern("uuuuMMdd"));
            List<OrdMain> ords = ordList.stream().filter(
              o -> Objects.equal(o.getTreatDate(), uuuuMMdd)).collect(Collectors.toList());

            if (ords.size() > 0) {
              // 検査日と同じ日に透析予定、または実績が存在する
              for (OrdMain ord : ords) {
                ordNos.add(ord.getOrdNo());
              }
            }
          } else {
            // 検査予定：検査依頼の場合は、reg_exam_date と比較

            String uuuuMMdd = exam.getRegExamDate().toLocalDateTime().toLocalDate().format(DateTimeFormatter.ofPattern("uuuuMMdd"));
            List<OrdMain> ords = ordList.stream().filter(
              o -> Objects.equal(o.getTreatDate(), uuuuMMdd)).collect(Collectors.toList());
            if (ords.size() > 0) {
              // 検査日と同じ日に透析データがある
              for (OrdMain ord : ords) {
                ordNos.add(ord.getOrdNo());
              }
            }
          }
        }
        // 検査データが存在し、検査データと同時の ordNo が存在しない場合は、エラーを避ける為に -1L を入れておく
        if (ordNos.size() == 0) {
          ordNos = new ArrayList<Long>(Arrays.asList(-1L));
        }
        // 重複チェックして格納する
        List<Long> tmpOrdNoList = new ArrayList<Long>(new LinkedHashSet<>(ordNos));
        for (Long ordNo : tmpOrdNoList) {
          listOrdNo.add(ordNo);
          listPatId.add(patId);
        }
      }
    }
    // sortConditions (帳票画面>並び替え設定) は、優先3番目 → 優先2番目 → 優先1番目の順でデータがくることを想定しています (帳票種別：8：ラベルの並び替えと同様)
    if (sortConditions != null && sortConditions.size() > 0 && patIdList.size() > 0) {

      String patIdStr = "pat_id";
      String ordNoStr = "ord_no";
      // 01：患者IDのリストを、jsonのリストにまとめる
      List<JSONObject> tmpList = new ArrayList<>();
      for (int idx = 0; idx < listPatId.size(); idx++) {
        JSONObject jsonData = new JSONObject();
        jsonData.put(patIdStr, listPatId.get(idx));
        jsonData.put(ordNoStr, listOrdNo.get(idx));
        jsonData.put("hosp_pat_id", ""); // 患者ID
        jsonData.put("pat_full_name", ""); // 患者名
        jsonData.put("bed_order", ""); // ベッド表示順
        jsonData.put("kur_order", ""); // クール表示順
        jsonData.put("in_out_class", ""); // 入外区分
        jsonData.put("room_group_order", ""); // 透析室表示順
        jsonData.put("bed_group_order", ""); // ベッドグループ表示順
        tmpList.add(jsonData);
      }

      // 02：ソートに必要なデータを「01」で作成したjsonのリストに格納する
      // ※：画面上で並び順を 第1→患者ID(昇順)、第2→患者ID(降順) とした場合、sortConditions は 患者ID(昇順) 1件のみで送られてきます
      // ※：患者ID/入外区分、ベッド/クールのデータは1度の処理で取得できる為、フラグで2回通らないようにします
      boolean ppmhPassedFlg = false;
      boolean ordPassedFlg = false;
      for (int index = 0; index < sortConditions.size(); index++) {
        Map<String, String> item = sortConditions.get(sortConditions.size() - (index+1));

        if ((item.keySet().contains(CoreConstant.ReportMenu.PATIENT_ID) ||
          item.keySet().contains(CoreConstant.ReportMenu.PATIENT_NAME) ||
          item.keySet().contains(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION)) && !ppmhPassedFlg) {
          // 患者ID/患者名/入外区分のデータを取得

          // mongoDB検索条件作成
          String mongFromDate = localDateFrom.format(DateTimeFormatter.ofPattern("yyyy-MM-dd")) + " 23:59:59";
          ArrayList<Bson> arr = new ArrayList<Bson>();
          arr.add(lt("up_date", mongFromDate));
          List<String> searchPatIdlist = new ArrayList<>();
          for (JSONObject tmpJson : tmpList) {
            searchPatIdlist.add(tmpJson.get(patIdStr).toString());
          }
          arr.add(in(patIdStr, searchPatIdlist));
          Bson bson = and(arr);
          // mongoDB検索処理
          FindIterable<Document> resultDocs = mongoTemplate.getCollection("pat_personal_main_history").find(bson).sort(descending("up_date"));
          // 患者ID毎に患者ID/入外区分を格納
          for (JSONObject tmpJson : tmpList) {
            Document doc = resultDocs != null ? resultDocs.filter(eq(patIdStr, tmpJson.get(patIdStr).toString())).first() : new Document();
            String inOutClass = "";
            inOutClass = rdMainDao.getInOutClass(reportMenu.getFacilityCd(), tmpJson.get(ordNoStr).toString(), tmpJson.get(patIdStr).toString());
            // add #11853 観察記録が記載されている患者で、観察記録(全体)の帳票を表示するとシステムエラーが発生する sunsy start
//            if (doc != null) {
            if (doc != null && doc.size() > 0) {
            // add #11853 観察記録が記載されている患者で、観察記録(全体)の帳票を表示するとシステムエラーが発生する sunsy end
              // 患者ID ( ソート用に0埋めして格納 )
              // add #11853 観察記録が記載されている患者で、観察記録(全体)の帳票を表示するとシステムエラーが発生する sunsy start
              if (doc.get("hosp_pat_id") != null)
              // add #11853 観察記録が記載されている患者で、観察記録(全体)の帳票を表示するとシステムエラーが発生する sunsy end
                // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//              tmpJson.put("hosp_pat_id", String.format("%12s", doc.get("hosp_pat_id").toString()).replace(" ", "0"));
              tmpJson.put("hosp_pat_id", doc.get("hosp_pat_id").toString());
              // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
              // 入外区分
              if (inOutClass !=null) {

                tmpJson.put("in_out_class", inOutClass);
              } else {
                tmpJson.put("in_out_class", "");
              }
              // 患者名
              // add #11853 観察記録が記載されている患者で、観察記録(全体)の帳票を表示するとシステムエラーが発生する sunsy start
              if (doc.get("pat_last_name") != null && doc.get("pat_first_name") != null)
                // add #11853 観察記録が記載されている患者で、観察記録(全体)の帳票を表示するとシステムエラーが発生する sunsy end
                // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
                // カナ優先として半角スペースで連結し、ソート用キーを作成。文字列としてソートするソート用キーーカナ姓(漢字姓)&&カナ名(漢字名)
                if (doc.get("pat_last_name") != null && doc.get("pat_first_name") != null) {
                  String lastName = !StringUtils.isEmpty((CharSequence) doc.get("pat_last_name_kana")) ? String.valueOf(doc.get("pat_last_name_kana"))
                    : String.valueOf(doc.get("pat_last_name"));
                  String firstName = !StringUtils.isEmpty((CharSequence) doc.get("pat_first_name_kana")) ? String.valueOf(doc.get("pat_first_name_kana"))
                    : String.valueOf(doc.get("pat_first_name"));
                  tmpJson.put("pat_full_name", lastName + " " + firstName);
                }
//              tmpJson.put("pat_full_name", doc.get("pat_last_name").toString() + " " + doc.get("pat_first_name").toString());
              // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
            }
          }
          ppmhPassedFlg = true;

        }
        else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_BED) ||
          item.keySet().contains(CoreConstant.ReportMenu.PATIENT_COOL) ||
          item.keySet().contains(CoreConstant.ReportMenu.ROOM_BED_GROUP1) ||
          item.keySet().contains(CoreConstant.ReportMenu.DIALYSIS_ROOM_GROUP1) && !ordPassedFlg) {
          // マスタデータを取得
          SelectOptions options = SelectOptions.get();
          List<MstBed> mstBedList = mstBedDao.selectByFacilityCd(reportMenu.getFacilityCd(), "1", "0");
          List<MstKur> mstKurList = mstKurDao.selectByFacilityCd(options, reportMenu.getFacilityCd(), "0");

          for (JSONObject tmpJson : tmpList) {
            String ordNo = tmpJson.get(ordNoStr).toString();
            // ordMainから取得する値
            for (OrdMain ord : ordList) {
              if (ordNo.equals(ord.getOrdNo().toString())) {
                // ベッド, ベッドグループ表示順, 透析室表示順
                for (Integer bedListIndex = 0; bedListIndex < mstBedList.size(); bedListIndex++ ) {
                  if (ord.getIndBedCd().toString().equals(mstBedList.get(bedListIndex).getBedCd().toString())) {
                    tmpJson.put("bed_order", String.format("%5s", bedListIndex.toString()).replace(" ", "0"));
                    Integer bedGroupIndex = 999;
                    bedGroupIndex = mstRoomBedGroupDao.selectIndexBedCdIsContain(ord.getIndBedCd().toString(), reportMenu.getFacilityCd(), "1");
                    tmpJson.put("bed_group_order", String.format("%3s", bedGroupIndex.toString()).replace(" ", "0"));
                    Integer RoomIndex = 999;
                    RoomIndex = mstRoomBedGroupDao.selectIndexBedCdIsContain(ord.getIndBedCd().toString(), reportMenu.getFacilityCd(), "2");
                    tmpJson.put("room_group_order", String.format("%3s", RoomIndex.toString()).replace(" ", "0"));
                  }
                }
                // クール
                for (Integer kurListIndex = 0; kurListIndex < mstKurList.size(); kurListIndex++ ) {
                  if (ord.getIndKurCd().toString().equals(mstKurList.get(kurListIndex).getKurCd().toString())) {
                    tmpJson.put("kur_order", String.format("%3s", kurListIndex.toString()).replace(" ", "0"));
                  }
                }
              }
            }
          }
          ordPassedFlg = true;
        }
      }

      List tmpSortKey = new ArrayList();
      List tmpSortDirection = new ArrayList();

      // 03：条件により並び替えを実施する
      for (int index = 0; index < sortConditions.size(); index++) {
        Map<String, String> item = sortConditions.get(sortConditions.size() - (index+1));

        if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_ID)) {
          // 患者ID
          tmpSortKey.add(index,"hosp_pat_id");
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_ID).toString());

        } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_NAME)) {
          // 患者名
          tmpSortKey.add(index,"pat_full_name");
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_NAME).toString());

        } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_BED)) {
          // ベッド表示順
          tmpSortKey.add(index,"bed_order");
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_BED).toString());

        } else if (item.keySet().contains(CoreConstant.ReportMenu.PATIENT_COOL)) {
          // クール表示順
          tmpSortKey.add(index,"kur_order");
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.PATIENT_COOL).toString());

        } else if (item.keySet().contains(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION)) {
          // 入外区分
          tmpSortKey.add(index,"in_out_class");
          tmpSortDirection.add(index,item.get(CoreConstant.ReportMenu.ENTRANCE_EXIT_CLASSIFICATION).toString());

        }
        else if (item.keySet().contains(CoreConstant.ReportMenu.DIALYSIS_ROOM_GROUP1)) {
          // 透析室表示順
          tmpSortKey.add(index, "room_group_order");
          tmpSortDirection.add(index, item.get(CoreConstant.ReportMenu.DIALYSIS_ROOM_GROUP1).toString());
        }
        else if (item.keySet().contains(CoreConstant.ReportMenu.ROOM_BED_GROUP1)) {
          // ベッドグループ表示順
          tmpSortKey.add(index, "bed_group_order");
          tmpSortDirection.add(index, item.get(CoreConstant.ReportMenu.ROOM_BED_GROUP1).toString());
        }
      }

      List sortKey = tmpSortKey;
      List sortDirection = tmpSortDirection;
      for(int indexSort = 0;indexSort < tmpSortKey.size();indexSort++) {
        for (int index = 0; index < tmpList.size();index++) {
          if ("bed_order".equals(tmpSortKey.get(indexSort))) {
            if ("asc".equals(sortDirection.get(indexSort))) {
              if (StringUtils.isEmpty(tmpList.get(index).get("bed_order").toString())) {
                tmpList.get(index).put("bed_order","999999999");
              }
            } else if ("desc".equals(sortDirection.get(indexSort))) {
              if (StringUtils.isEmpty(tmpList.get(index).get("bed_order").toString())) {
                tmpList.get(index).put("bed_order","-999999999");
              }
            }
          } else if ("kur_order".equals(tmpSortKey.get(indexSort))) {
            if ("asc".equals(sortDirection.get(indexSort))) {
              if (StringUtils.isEmpty(tmpList.get(index).get("kur_order").toString())) {
                tmpList.get(index).put("kur_order","999999999");
              }
            } else if ("desc".equals(sortDirection.get(indexSort))) {
              if (StringUtils.isEmpty(tmpList.get(index).get("kur_order").toString())) {
                tmpList.get(index).put("kur_order","-999999999");
              }
            }
          } else if ("room_group_order".equals(tmpSortKey.get(indexSort))) {
            if ("asc".equals(sortDirection.get(indexSort))) {
              if (StringUtils.isEmpty(tmpList.get(index).get("room_group_order").toString())|| StringUtils.isEmpty(tmpList.get(index).get("room_group_order").toString().replace("0",""))) {
                tmpList.get(index).put("room_group_order","999999999");
              }
            } else if ("desc".equals(sortDirection.get(indexSort))) {
              if (StringUtils.isEmpty(tmpList.get(index).get("room_group_order").toString())|| StringUtils.isEmpty(tmpList.get(index).get("room_group_order").toString().replace("0",""))) {
                tmpList.get(index).put("room_group_order","-999999999");
              }
            }
          } else if ("bed_group_order".equals(tmpSortKey.get(indexSort))) {
            if ("asc".equals(sortDirection.get(indexSort))) {
              if (StringUtils.isEmpty(tmpList.get(index).get("bed_group_order").toString())|| StringUtils.isEmpty(tmpList.get(index).get("bed_group_order").toString().replace("0",""))) {
                tmpList.get(index).put("bed_group_order","999999999");
              }
            } else if ("desc".equals(sortDirection.get(indexSort))) {
              if (StringUtils.isEmpty(tmpList.get(index).get("bed_group_order").toString())|| StringUtils.isEmpty(tmpList.get(index).get("bed_group_order").toString().replace("0",""))) {
                tmpList.get(index).put("bed_group_order","-999999999");
              }
            }
          }
        }
      }

      if (sortKey.contains("in_out_class") && sortDirection.get(sortKey.indexOf("in_out_class")).equals("asc")) {
        for (int index = 0;index < tmpList.size();index++) {
          if (tmpList.get(index).get("in_out_class").equals("2")) {
            tmpList.get(index).put("in_out_class","999999998");
          } else if (tmpList.get(index).get("in_out_class").equals("3")) {
            tmpList.get(index).put("in_out_class","999999999");
          } else if (tmpList.get(index).get("in_out_class").equals("")){
            tmpList.get(index).put("in_out_class","9999999999");
          }
        }
      } else if (sortKey.contains("in_out_class") && sortDirection.get(sortKey.indexOf("in_out_class")).equals("desc")) {
        for (int index = 0;index < tmpList.size();index++) {
          if (tmpList.get(index).get("in_out_class").equals("2")) {
            tmpList.get(index).put("in_out_class","-999999999");
          } else if (tmpList.get(index).get("in_out_class").equals("3")) {
            tmpList.get(index).put("in_out_class","-999999998");
          } else if (tmpList.get(index).get("in_out_class").equals("")){
            tmpList.get(index).put("in_out_class","-999999997");
          }
        }
      }

      // 並び替え
      // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
//      tmpList = DialysisReportCompare(tmpList, sortKey, sortDirection);
      tmpList = DialysisAndOnePatientReportCompare(tmpList, sortKey, sortDirection);
      // mod #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end

      if (sortKey.contains("in_out_class") && sortDirection.get(sortKey.indexOf("in_out_class")).equals("asc")) {
        for (int index = 0;index < tmpList.size();index++) {
          if (tmpList.get(index).get("in_out_class").equals("999999998")) {
            tmpList.get(index).put("in_out_class","2");
          } else if (tmpList.get(index).get("in_out_class").equals("999999999")) {
            tmpList.get(index).put("in_out_class","3");
          } else if (tmpList.get(index).get("in_out_class").equals("9999999999")){
            tmpList.get(index).put("in_out_class","");
          }
        }
      } else if (sortKey.contains("in_out_class") && sortDirection.get(sortKey.indexOf("in_out_class")).equals("desc")) {
        for (int index = 0;index < tmpList.size();index++) {
          if (tmpList.get(index).get("in_out_class").equals("-999999999")) {
            tmpList.get(index).put("in_out_class","2");
          } else if (tmpList.get(index).get("in_out_class").equals("-999999998")) {
            tmpList.get(index).put("in_out_class","3");
          } else if (tmpList.get(index).get("in_out_class").equals("-999999997")){
            tmpList.get(index).put("in_out_class","");
          }
        }
      }
      for(int indexSort = 0;indexSort < tmpSortKey.size();indexSort++) {
        for (int index = 0; index < tmpList.size();index++) {
          if ("bed_order".equals(tmpSortKey.get(indexSort))) {
            if ("asc".equals(sortDirection.get(indexSort))) {
              if ("999999999".equals(tmpList.get(index).get("bed_order").toString())) {
                tmpList.get(index).put("bed_order","");
              }
            } else if ("desc".equals(sortDirection.get(indexSort))) {
              if ("-999999999".equals(tmpList.get(index).get("bed_order").toString())) {
                tmpList.get(index).put("bed_order","");
              }
            }
          } else if ("kur_order".equals(tmpSortKey.get(indexSort))) {
            if ("asc".equals(sortDirection.get(indexSort))) {
              if ("999999999".equals(tmpList.get(index).get("kur_order").toString())) {
                tmpList.get(index).put("kur_order","");
              }
            } else if ("desc".equals(sortDirection.get(indexSort))) {
              if ("-999999999".equals(tmpList.get(index).get("kur_order").toString())) {
                tmpList.get(index).put("kur_order","");
              }
            }
          } else if ("room_group_order".equals(tmpSortKey.get(indexSort))) {
            if ("asc".equals(sortDirection.get(indexSort))) {
              if ("999999999".equals(tmpList.get(index).get("room_group_order").toString())) {
                tmpList.get(index).put("room_group_order","");
              }
            } else if ("desc".equals(sortDirection.get(indexSort))) {
              if ("-999999999".equals(tmpList.get(index).get("room_group_order").toString())) {
                tmpList.get(index).put("room_group_order","");
              }
            }
          } else if ("bed_group_order".equals(tmpSortKey.get(indexSort))) {
            if ("asc".equals(sortDirection.get(indexSort))) {
              if ("999999999".equals(tmpList.get(index).get("bed_group_order").toString())) {
                tmpList.get(index).put("bed_group_order","");
              }
            } else if ("desc".equals(sortDirection.get(indexSort))) {
              if ("-999999999".equals(tmpList.get(index).get("bed_group_order").toString())) {
                tmpList.get(index).put("bed_group_order","");
              }
            }
          }
        }
      }

      // ソート対象のデータが存在しないデータを最下段に寄せる
      List<JSONObject> list = new ArrayList<>();
      List<JSONObject> empList = new ArrayList<>();
      for (JSONObject tmpJson : tmpList) {
        for (int number = 0; number < sortKey.size(); number++) {
          if (tmpJson.getString(sortKey.get(number).toString()).equals("")) {
            empList.add(tmpJson);
          }
        }
      }
      list.addAll(empList);

      // ソートしたデータを適用
      List<Long> tmpListPatId = new ArrayList<>();
      List<Long> tmpListOrdNo = new ArrayList<>();
      for (JSONObject tmpJson : tmpList) {
        tmpListPatId.add(tmpJson.getLong(patIdStr));
        tmpListOrdNo.add(tmpJson.getLong(ordNoStr));
      }
      listPatId = tmpListPatId;
      listOrdNo = tmpListOrdNo;
    }
    return listPatId;
  }
  // add #11737 グラフがセルサイズにフィットしないときがある 房 end
  // add #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 start
  /**
   * JSON の値を安全に文字列化する
   * null の場合は空文字列を返す
   */
  public String safeString(Object o) {
    if (o == null) return "";
    return o.toString();
  }

  /**
   * システム共通患者IDの比較ルール
   * "pat_id" 用の特殊なソート処理
   *
   * ルール：
   * 1. "未設定" / "未登録" は常に最後
   * 2. 両方とも数字の場合は数値で比較、数値が同じなら桁数の短い方を先に
   * 3. 一方が数字、一方が文字列の場合は数字を優先（数字が前）
   * 4. 両方とも数字でない場合は辞書順（大文字小文字を区別しない）
   */
  public int comparePatientId(String a, String b) {
    // 特殊値の処理 ("未設定","未登録") — 常に最後
    if (isSpecial(a) && isSpecial(b)) return 0;
    if (isSpecial(a)) return 1;
    if (isSpecial(b)) return -1;

    boolean aIsNum = isNumeric(a);   // 純数字のみか
    boolean bIsNum = isNumeric(b);

    boolean aHasNum = containsDigit(a); // 数字を含むか
    boolean bHasNum = containsDigit(b);

    // タイプ優先度: 純数字(0) < 含数字(1) < 無数字(2)
    int aType = aIsNum ? 0 : (aHasNum ? 1 : 2);
    int bType = bIsNum ? 0 : (bHasNum ? 1 : 2);

    // タイプが違う場合は優先度で比較
    if (aType != bType) return Integer.compare(aType, bType);

    // 両方とも純数字
    if (aType == 0) {
      try {
        java.math.BigInteger na = new java.math.BigInteger(a);
        java.math.BigInteger nb = new java.math.BigInteger(b);
        int cmp = na.compareTo(nb);
        if (cmp != 0) return cmp;
        return Integer.compare(a.length(), b.length()); // 桁数が短い方を先に
      } catch (NumberFormatException ex) {
        return a.compareToIgnoreCase(b);
      }
    }

    // 両方とも含数字または無数字
    if (aType == 1) {
      // 含数字の場合は、文字列内の全数字を取り出して連結し数値比較
      String aDigits = extractDigits(a);
      String bDigits = extractDigits(b);

      java.math.BigInteger na = aDigits.isEmpty() ? java.math.BigInteger.ZERO : new java.math.BigInteger(aDigits);
      java.math.BigInteger nb = bDigits.isEmpty() ? java.math.BigInteger.ZERO : new java.math.BigInteger(bDigits);
      int cmp = na.compareTo(nb);
      if (cmp != 0) return cmp;

      // 数字が同じ場合は辞書順
      return a.compareToIgnoreCase(b);
    }

    // 両方とも無数字（純文字列） → 辞書順
    return a.compareToIgnoreCase(b);
  }

  /**
   * 文字列に数字が含まれるか
   */
  private boolean containsDigit(String s) {
    return s != null && s.matches(".*\\d.*");
  }

  /**
   * 文字列が数字のみか判定
   */
  private boolean isNumeric(String s) {
    return s != null && s.matches("\\d+");
  }

  // 文字列内の数字をすべて取り出して連結
  private String extractDigits(String s) {
    if (s == null) return "";
    return s.replaceAll("\\D", "");
  }

  /**
   * 特殊値か判定
   * "未設定" または "未登録" の場合 true
   */
  private boolean isSpecial(String s) {
    return "未設定".equals(s) || "未登録".equals(s);
  }
  // add #12410 帳票「並び替え」処理仕様の一部がシステム共通ソート仕様と異なる 高 end
  // add #12324 紹介状の出力時にpat_eventを参照する zhao start
  /**
   * 帳票画面の入力条件により、患者情報を取得する
   * @param reportCd 帳票コード
   * @param dataKey 抽出キー
   * @return patEvent 患者情報
   */
  public List<PatEvent> getPatEvent(Long reportCd, Map<String, Object> dataKey){
    // データ抽出キーに、検索条件を取得する
    // 開始日
    String fromDate = (String)dataKey.get("fromDate");
    // 終了日
    String toDate = (String)dataKey.get("toDate");
    // 患者情報を取得する
    List<PatEvent> patEventList = patEventDao.selectByPatIdAndDate(Long.valueOf(dataKey.get("patId").toString()),
      dataKey.get("facilityCd").toString(), fromDate, toDate);

    if(patEventList == null || patEventList.size() == 0){
      return null;
    }
    // JavaオブジェクトとJSONデータの間で変換を行うためのインスタンス化
    ObjectMapper mapper = new ObjectMapper();
    List<PatEvent> editPatEventList = new ArrayList<>();
    // 患者情報をループする
    for(PatEvent patEvent: patEventList){
      // 紹介状データを取得する
      String jsonLetterInfo = patEvent.getLetterInfo();
      if(jsonLetterInfo == null || jsonLetterInfo.isEmpty()){
        continue;
      }
      // JSON文字列をJsonNodeに解析する
      JsonNode rootNode = null;
      try {
        rootNode = mapper.readTree(jsonLetterInfo);
        // reportCdを取得する
        JsonNode reportCdDb = rootNode.get("report_cd");
        if(reportCdDb == null || reportCdDb.isNull() || reportCdDb.asText().isEmpty()){
          continue;
        }
        // 管理番号の取得
        JsonNode ctlNo = rootNode.get("ctlNo");
        if(ctlNo == null || ctlNo.isNull() || ctlNo.asText().isEmpty()){
          continue;
        }
        // 紹介状の取得
        JsonNode letterData = rootNode.get("letter_data");
        if(letterData == null || letterData.isNull() || (letterData.isObject() && letterData.size() == 0)){
          continue;
        }
        // 選択テンプレートは最新紹介状と同じかどうか判断
        if(reportCd.toString().equals(reportCdDb.asText())){
          editPatEventList.add(patEvent);
        }
      } catch (JacksonException e) {
        throw new RuntimeException(e);
      }
    }
    return editPatEventList;
  }

  /**
   * 管理Noでグループ、患者情報を取得する
   * @param patEventList 患者情報
   * @return 患者情報
   */
  public Map<String, List<Object>> getCtlNoGroup(List<PatEvent> patEventList){
    ObjectMapper mapper = new ObjectMapper();
    Map<String, List<Object>> groupedData = patEventList.stream().collect(
      Collectors.groupingBy(
        patEvent -> {
          try {
            JsonNode root = mapper.readTree(patEvent.getLetterInfo());
            return root.has("ctlNo") ? root.get("ctlNo").asText() : "";
          } catch (Exception e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 add yangxuewang start
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 add yangxuewang end
            return "";
          }
        },
        LinkedHashMap::new,
        Collectors.mapping(patEvent -> {
          try {
            JsonNode root = mapper.readTree(patEvent.getLetterInfo());
            return root.has("letter_data") ? root.get("letter_data") : "";
          } catch (Exception e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang start
//      e.printStackTrace();
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 del yangxuewang end
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 add yangxuewang start
            EventLogMessage eventLogMessage = new EventLogMessage();
            eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
            logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260525 add yangxuewang end
            return "";
          }
        }, Collectors.toList())
      )
    );
    return groupedData;
  }
  // add #12324 紹介状の出力時にpat_eventを参照する zhao end
}
