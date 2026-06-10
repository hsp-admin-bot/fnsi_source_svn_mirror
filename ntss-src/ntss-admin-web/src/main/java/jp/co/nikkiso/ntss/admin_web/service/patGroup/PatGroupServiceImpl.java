package jp.co.nikkiso.ntss.admin_web.service.patGroup;

import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Collections;
import java.util.Date;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.Optional;
import java.util.stream.Collectors;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.core.type.TypeReference;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.MongoService;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
import jp.co.nikkiso.ntss.admin_web.service.MongoServiceImpl;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.admin_web.service.patGroupDetail.PatGroupDetailService;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
import jp.co.nikkiso.ntss.admin_web.service.patHistory.PatMainHistory;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
import jp.co.nikkiso.ntss.admin_web.web.rest.util.WebApiCallCommonUtil;
import jp.co.nikkiso.ntss.core.constant.CoreConstant;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
import jp.co.nikkiso.ntss.core.dao.MstSelectorDao;
import jp.co.nikkiso.ntss.core.dao.PatGroupDao;
import jp.co.nikkiso.ntss.core.dao.PatGroupDetailDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.entity.MstSelector;
import jp.co.nikkiso.ntss.core.entity.PatGroup;
import jp.co.nikkiso.ntss.core.entity.PatGroupDetail;
import jp.co.nikkiso.ntss.core.entity.PatMain;
import jp.co.nikkiso.ntss.core.entity.custom.PatGroupCustomForPg;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
import jp.co.nikkiso.ntss.core.entity.patHistory.patMainHistoryDetail.PatGroupInfo;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.logger.LogObjectUtils;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
import jp.co.nikkiso.ntss.core.utils.MongoHealthCheckService;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
import org.json.JSONArray;
import org.json.JSONObject;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
import org.springframework.data.mongodb.core.MongoTemplate;
import org.springframework.data.mongodb.core.query.Criteria;
import org.springframework.data.mongodb.core.query.Query;
import org.springframework.data.mongodb.core.query.Update;
import org.bson.Document;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
import org.springframework.util.CollectionUtils;
import org.springframework.util.StringUtils;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
import org.springframework.web.bind.annotation.RequestBody;
import com.fasterxml.jackson.databind.ObjectMapper;
import jp.co.nikkiso.ntss.admin_web.request.patGroup.PatGroupDetailRequest;
import jp.co.nikkiso.ntss.admin_web.response.patGroup.PatGroupResponse;

import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;

/**
 * 患者グループのService実装クラス.
 */
@Service
public class PatGroupServiceImpl implements PatGroupService {
	@Autowired
	private PatGroupDao patGroupDao;

	@Autowired
	private PatGroupDetailDao patGroupDetailDao;

	@Autowired
	private MstSelectorDao mstSelectorDao;

  // DB更新ログ出力ロジック wangzuo Start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  // DB更新ログ出力ロジック wangzuo End
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 dengshen start
  @Autowired
  private MongoService mongoService;
  @Autowired
  private PatMainDao patMainDao;
  // add #10245 帳票用患者情報履歴mongoDBのマスタ変更影響問題 dengshen end

  @Autowired
  private WebApiCallCommonUtil webApiCallCommonUtil;
  // add by YangYongzhuang  2023-02-03 [CodeOptimization]  start /
  private final static String MODPATGROUP_LOG_MESSAGE = "患者グループ%s→%sが変更されました。";
  private final static String MODPATGROUP_ITEM_LOG_MESSAGE = "[%s]の[%s]が[%s]→[%s]に変更されました。";
  private final static String UPDPATGROUP_LOG_MESSAGE = "患者グループ%sの患者が%sから%sに変更されました。";

  @Autowired
  private PatGroupServiceImpl patGroupService;

  @Autowired
  private LogService logService;

  @Autowired
  private PatGroupDetailService patGroupDetailService;
// add by YangYongzhuang  2023-02-03 [CodeOptimization]  End /

// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
  @Autowired(required = false)
  private MongoTemplate mongoTemplate;

    @Autowired(required = false)
    private MongoServiceImpl mongoServiceImpl;
// add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end

  /**
	 *
	 * {@inheritDoc}
	 */
	@Override
	public PatGroupResponse getAllPatGroup(String facilityCd) {
		return new PatGroupResponse(patGroupDao.selectAll(facilityCd));
	}

	/**
	 *
	 * {@inheritDoc}
	 */
	@Override
	public PatGroup selectPatGroupByCd(String facilityCd, Long patGroupCd) {
		return patGroupDao.selectById(patGroupCd, facilityCd);
	}

	/**
	 *
	 * {@inheritDoc}
	 */
	@Override
  @Transactional
	public long insert(@RequestBody Map<String, String> payload) throws Exception {

		// 各レコードのJSONを対応するクラスにマッピング
		ObjectMapper mapper = new ObjectMapper();
		PatGroup patGroup = mapper.readValue(payload.get("pat_group"), PatGroup.class);
		PatGroupDetailRequest patGroupDetail = mapper.readValue(payload.get("pat_list_detail"),
				PatGroupDetailRequest.class);

		PatGroupDetail temp = new PatGroupDetail();

		// 次の利用可能のIDの習得
		long nextSeqPatId = patGroupDao.selectNextSeqPatGroupId();

		// 患者グループの登録
		patGroup.setPatGroupCd(nextSeqPatId);
		patGroupDao.insert(patGroup);

		// 患者グループ詳細の登録
		for (Long item : patGroupDetail.getPatList()) {
			temp.setPatGroupCd(nextSeqPatId);
			temp.setPatId(item);
			temp.setFacilityCd(patGroup.getFacilityCd());
			patGroupDetailDao.insert(temp);
		}
        // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
        this.handlePatGroupInfoById(patGroup.getFacilityCd(), patGroupDetail.getPatList(), null,
                nextSeqPatId);
        // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end

		// mst_selectorに登録する
		String facilityCd = patGroup.getFacilityCd();
		String masterPhysicalName = "pat_group";
		MstSelector mstSelector = mstSelectorDao.selectByName(facilityCd, "pat_group");
		MstSelector.OrderSettings orderSettings = new MstSelector.OrderSettings();
		MstSelector.Item item = new MstSelector.Item();
		item.setCode(patGroup.getPatGroupCd());
		item.setName(patGroup.getPatGroupName());

		if (mstSelector == null) {
			mstSelector = new MstSelector();
			orderSettings.setItems(Collections.singletonList(item));
			mstSelector.setFacilityCd(facilityCd);
			mstSelector.setMasterPhysicalName(masterPhysicalName);
			mstSelector.setOrderSettings(orderSettings);
			mstSelectorDao.insert(mstSelector);
		} else {
			orderSettings = mstSelector.getOrderSettings();
			List<MstSelector.Item> items = orderSettings.getItems();
			items.add(item);

			mstSelector.setOrderSettings(orderSettings);
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
      LogEventUtils.setOperatorId(mstSelector,logService);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
      // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
			mstSelectorDao.update(mstSelector);
		}

		return nextSeqPatId;
	}

	/**
	 *
	 * {@inheritDoc}
	 */
	@Override
    // mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
//    public void deleteById(Long patGroupId) {
    public void deleteById(Long patGroupId, String facilityCd) throws Exception {
        // mod #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end

    // DB更新ログ出力ロジック wangzuo Start
    String tableName = "pat_group";
    // SQL検索条件
    StringBuffer wheres = new StringBuffer("");
    wheres.append(" WHERE\n");
    wheres.append(" pat_group_cd = " + patGroupId + "\n");

    // logCommon設定
    DataUpdateLogCommonNew logCommon = getLogCommon(patGroupDao, tableName, wheres, getEventLogMessage());
    // ログ出力カラム情報及び更新前データ情報取得
    boolean setResult = logCommon.setInfo();
    // DB更新ログ出力ロジック wangzuo End

        int updateCount = patGroupDao.deleteById(patGroupId);
        // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
        List<Long> patIdsByPGDetailBeforeDel = patGroupDetailDao.selectByPatGroupCd(patGroupId).stream()
                .map(PatGroupDetail::getPatId).toList();
        // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
        // add #7481-削除された患者グループが表示される 徐博 start
        patGroupDetailDao.deleteByPatGroupId(patGroupId);
        // add #7481-削除された患者グループが表示される 徐博 end
        // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
        this.handlePatGroupInfoById(facilityCd, null, patIdsByPGDetailBeforeDel, patGroupId);
        // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
        // DB更新ログ出力ロジック wangzuo Start
        // 更新後データ取得、差分あれば、log出力
        if (setResult && updateCount > 0) {
            logCommon.updateLog();
        }
        // DB更新ログ出力ロジック wangzuo End
    }

	/**
	 *
	 * {@inheritDoc}
	 */
	@Override
  @Transactional
	public void updateById(Long patGroupCd, Map<String, String> payload) throws Exception {

    // add by YangYongzhuang  2023-02-03 [CodeOptimization]  start /
    // add redmine 6471 患者グループの編集した記録がログに残らない  周 start
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    PatGroup patGroupOrg = patGroupService.selectPatGroupByCd(user.getFacilityCd(), patGroupCd);
    List<PatGroupDetail> PGDetailsOrg = patGroupDetailService.selectByPatGroupCd(patGroupCd, user.getFacilityCd());
    // add redmine 6471 患者グループの編集した記録がログに残らない  周 end
    // add by YangYongzhuang  2023-02-03 [CodeOptimization]  End /

		// 各レコードのJSONを対応するクラスにマッピング
		ObjectMapper mapper = new ObjectMapper();
		PatGroup patGroup = mapper.readValue(payload.get("pat_group"), PatGroup.class);
		PatGroupDetailRequest patGroupDetail = mapper.readValue(payload.get("pat_list_detail"),
				PatGroupDetailRequest.class);

		// 患者グループの更新
    // DB更新ログ出力ロジック xie start
    patGroup.setPatGroupCd(patGroupCd);
    // DB更新ログ出力ロジック xie end

    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
    LogEventUtils.setOperatorId(patGroup,logService);
    // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
    // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
		patGroupDao.updateById(patGroupCd, patGroup);
        // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
        List<Long> patIdsByPGDetailBeforeDel = patGroupDetailDao.selectByPatGroupCd(patGroupCd).stream()
                .map(PatGroupDetail::getPatId).toList();
        List<Long> diffPatIds = patIdsByPGDetailBeforeDel.stream()
                .filter(item -> !patGroupDetail.getPatList().contains(item)).collect(Collectors.toList());
        // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end
		// 更新したグループの患者グループ詳細情報を削除
		patGroupDetailDao.deleteByPatGroupId(patGroupCd);

		// 患者グループ詳細の登録
		PatGroupDetail temp = new PatGroupDetail();
		for (Long item : patGroupDetail.getPatList()) {
			temp.setPatGroupCd(patGroupCd);
			temp.setPatId(item);
			temp.setFacilityCd(patGroup.getFacilityCd());
			patGroupDetailDao.insert(temp);
		}

    // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
    this.handlePatGroupInfoById(patGroup.getFacilityCd(), patGroupDetail.getPatList(), diffPatIds, patGroupCd);
    // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end

    // add by YangYongzhuang  2023-02-03 [CodeOptimization]  start /
    writeOutputLog(patGroupCd, payload, patGroupOrg, PGDetailsOrg, user);
    // add by YangYongzhuang  2023-02-03 [CodeOptimization]  End /

		return;
	}

  // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 start
  /**
   * pat_main患者グループの更新
   *
   * @param facilityCd 施設コード
   * @param patIdList  patIds
   * @param diffPatIds delete patIds
   * @param patGroupCd 患者グループCd
   * @throws Exception
   */
  public void handlePatGroupInfoById(String facilityCd, List<Long> patIdList, List<Long> diffPatIds,
                                     Long patGroupCd) throws Exception {
    List<PatMain> resultPatMains = new ArrayList<>();
    if (patGroupCd != null) {
      String patGroupCdStr = String.valueOf(patGroupCd);
      if (!CollectionUtils.isEmpty(patIdList)) {
        processPatIdList(patIdList, facilityCd, patGroupCdStr, resultPatMains);
      }
      if (!CollectionUtils.isEmpty(diffPatIds)) {
        processDiffPatIds(diffPatIds, facilityCd, patGroupCdStr, resultPatMains);
      }
    }
    if (!CollectionUtils.isEmpty(resultPatMains) && MongoHealthCheckService.getMongoDBConnected()) {
      SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
      Timestamp now = new Timestamp(new Date().getTime());
      Update update = new Update();
      update.set("ins_date", now);
      update.set("reg_date", sdf.format(now));
      update.set("up_date", sdf.format(now));
      List<PatMainHistory> queryLastPatMainHistorys = new ArrayList<>();
      resultPatMains.forEach(rpm -> {
        Query query = new Query();
        query.addCriteria(Criteria.where("facility_cd").is(facilityCd)
          .and("pat_id").in(rpm.getPat_id().toString())
          .and("latest_flag").is("on"));
        queryLastPatMainHistorys.addAll(mongoTemplate.find(query, PatMainHistory.class));
        List<Document> foundGroupInfoDocuments = new ArrayList<>();
        ObjectMapper objectMapper = new ObjectMapper();
        try {
          List<PatGroupCustomForPg> patGroupCustomForPgs = new ArrayList<>();
          if(StringUtils.hasLength(rpm.getPat_group_info())){
            patGroupCustomForPgs = objectMapper.readValue(rpm.getPat_group_info(), new TypeReference<>() {});
          }
          for (Integer i = 0; i < patGroupCustomForPgs.size(); i++) {
            PatGroupInfo patGroupInfo = new PatGroupInfo();
            patGroupInfo.setCtl_no(patGroupCustomForPgs.get(i).getCtl_no());
            patGroupInfo.setPat_group_cd(patGroupCustomForPgs.get(i).getPatGroupCd());
            PatGroup patGroupOrg = patGroupDao
              .selectById(Long.valueOf(patGroupCustomForPgs.get(i).getPatGroupCd()), facilityCd);
            patGroupInfo.setPat_group_name(patGroupOrg.getPatGroupName());
            Document foundGroupInfoDoc = Document.parse(new JSONObject(patGroupInfo).toString());
            foundGroupInfoDocuments.add(foundGroupInfoDoc);
          }
          update.set("pat_group_info", foundGroupInfoDocuments);
          mongoTemplate.updateMulti(query, update, "pat_main_history");
        } catch (JsonProcessingException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        }
      });
      if (!CollectionUtils.isEmpty(queryLastPatMainHistorys)) {
        mongoServiceImpl.insertPatMainHistorysTasks(queryLastPatMainHistorys);
      }
    }
  }

  public void processPatIdList(List<Long> patIdList, String facilityCd, String patGroupCdStr, List<PatMain> resultPatMains) {
    List<PatMain> patMainList = patMainDao.selectByIdListFacilityCd(patIdList, facilityCd);
    if (!CollectionUtils.isEmpty(patMainList)) {
      ObjectMapper objectMapper = new ObjectMapper();
      patMainList.forEach(pMain -> {
        List<PatGroupCustomForPg> patGroupCustomForPgs = new ArrayList<>();
        //#11607 患者グループを削除した時の通知メッセージが不適切 zrx start
//        if (pMain.getPat_group_info() == null || pMain.getPat_group_info().isEmpty()) {
        if (pMain.getPat_group_info() == null || pMain.getPat_group_info().isEmpty() || Objects.equals("null", pMain.getPat_group_info())) {
          //#11607 患者グループを削除した時の通知メッセージが不適切 zrx end
          patGroupCustomForPgs = new ArrayList<>();
        } else {
          try {
            patGroupCustomForPgs = objectMapper.readValue(pMain.getPat_group_info(), new TypeReference<List<PatGroupCustomForPg>>() { });
          } catch (JsonProcessingException e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
          }
        }
        Optional<PatGroupCustomForPg> existingGroup = Optional.empty();
        if (!CollectionUtils.isEmpty(patGroupCustomForPgs)) {
          existingGroup = patGroupCustomForPgs.stream().filter(group -> patGroupCdStr.equals(group.getPatGroupCd())).findFirst();
        }
        if (existingGroup.isEmpty()) {
          int maxCtlNo = patGroupCustomForPgs.stream().mapToInt(PatGroupCustomForPg::getCtl_no).max().orElse(0);
          PatGroupCustomForPg newPatGroupInfo = new PatGroupCustomForPg();
          newPatGroupInfo.setCtl_no(maxCtlNo + 1);
          newPatGroupInfo.setPatGroupCd(patGroupCdStr);
          patGroupCustomForPgs.add(newPatGroupInfo);
        }
        try {
          pMain.setPat_group_info(objectMapper.writeValueAsString(patGroupCustomForPgs));
        } catch (JsonProcessingException e) {
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
        }
        patMainDao.updateById(pMain.getPat_id(), pMain);
        if(resultPatMains != null) {
          resultPatMains.add(pMain);
        }
      });
    }
  }

  public void processDiffPatIds(List<Long> diffPatIds, String facilityCd, String patGroupCdStr, List<PatMain> resultPatMains) {
    List<PatMain> patMainList = patMainDao.selectByIdListFacilityCd(diffPatIds, facilityCd);
    if (!CollectionUtils.isEmpty(patMainList)) {
      ObjectMapper objectMapper = new ObjectMapper();
      patMainList.forEach(pMain -> {
        List<PatGroupCustomForPg> patGroupCustomForPgs = new ArrayList<>();
        //#11607 患者グループを削除した時の通知メッセージが不適切 zrx start
//        if (pMain.getPat_group_info() != null && !pMain.getPat_group_info().isEmpty()) {
        if (pMain.getPat_group_info() != null && !pMain.getPat_group_info().isEmpty() && !Objects.equals("null", pMain.getPat_group_info())) {
          //#11607 患者グループを削除した時の通知メッセージが不適切 zrx end
          try {
            patGroupCustomForPgs = objectMapper.readValue(pMain.getPat_group_info(), new TypeReference<List<PatGroupCustomForPg>>() {});
          } catch (JsonProcessingException e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
          }
          patGroupCustomForPgs.removeIf(group -> patGroupCdStr.equals(group.getPatGroupCd()));
          for (int i = 0; i < patGroupCustomForPgs.size(); i++) {
            patGroupCustomForPgs.get(i).setCtl_no(i + 1);
          }
          try {
            pMain.setPat_group_info(patGroupCustomForPgs.size() > 0 ? objectMapper.writeValueAsString(patGroupCustomForPgs) : null);
          } catch (JsonProcessingException e) {
            // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          if (!StringUtils.isEmpty(facilityCd)) {
            eventLogMessage.setFacilityCd(facilityCd);
          }
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
          }
          patMainDao.updateById(pMain.getPat_id(), pMain);
          if(resultPatMains != null) {
            resultPatMains.add(pMain);
          }
        }
      });
    }
  }

  // add #11309 患者グループ編集時、特定条件で保存ボタンが活性化しない ztc 20241212 end

	/**
	 * 患者グループの更新
	 *
	 * @param facilityCd 施設コード
	 * @param patGroup 患者グループ
	 * @throws Exception
	 */
	@Override
	@Transactional
	public void updatePatGroupById(String facilityCd, PatGroup patGroup) throws Exception {
		// 定義
		String newInHospitalCd_1 = "";
		String oldInHospitalCd_1 = "";
		try {
			// (新)連携コード1の取得
			newInHospitalCd_1 = patGroup.getInHospitalCd_1();
			// (旧)連携コード1の取得
			oldInHospitalCd_1 = getInHospitalCd_1(facilityCd, patGroup.getPatGroupCd());
			// (MongoDB)ログの出力
			outputLog(LogLevel.MONGO, String.format(MODPATGROUP_ITEM_LOG_MESSAGE, "患者グループ", "連携コード1", convertString(oldInHospitalCd_1), convertString(newInHospitalCd_1)), "患者グループ", null);
			// 患者グループの更新
			patGroupDao.updatePatGroupById(facilityCd, patGroup);

		} catch (Exception e) {
			// 例外処理
			throw new Exception(e);
		}
	}

  //add FutreNetWeb+SI課題管理 no.4266 劉全航 start
  @Override
  public void registerPatGroupNotification(Map<String, String> payload) {
    JSONObject baseReplaceData = new JSONObject();
    baseReplaceData.put("PATGROUP", payload.get("patGroupName"));
    JSONObject replaceData = new JSONObject(baseReplaceData, JSONObject.getNames(baseReplaceData));
    replaceData.put("FACILITYCD", payload.get("ficilityCd"));
    // mode 9546 by kangjie 20230830 start
    replaceData.put("PATGROUPCD", payload.get("patGroupCd"));
    // mode 9546 by kangjie 20230830 end
    try{
      webApiCallCommonUtil.registerNotification(CoreConstant.NotificationDefinition.ADD_PAT_GROUP,payload.get("ficilityCd"),replaceData);
    }catch (Exception e){
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang start
//      e.printStackTrace();
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 del yangxuewang end
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang start
          EventLogMessage eventLogMessage = new EventLogMessage();
          eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
          logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260402 add yangxuewang end
    }
  }
  //add FutreNetWeb+SI課題管理 no.4266 劉全航 end

  // DB更新ログ出力ロジック wangzuo Start
  /**
   * ログ情報設定
   *
   * @return eventLogMessage
   */
  private EventLogMessage getEventLogMessage() {
    EventLogMessage eventLogMessage = new EventLogMessage();
    NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
    if (user != null) {
      // 利用者ID
      eventLogMessage.setUserId(user.getUserId().toString());
      // 施設コード
      eventLogMessage.setFacilityCd(user.getFacilityCd());
      // 接続先IPアドレス
      eventLogMessage.setClientIp(user.getClientIpAddress());
      // セッションID
      eventLogMessage.setSessionId(user.getSessionId());
    }
    // サービス名
    eventLogMessage.setServiceName(LoggingConstant.MODULE_NAME.ADMIN_WEB + "," + LoggingConstant.SERVICE_NAME.FNSI);
    return eventLogMessage;
  }

  // add by YangYongzhuang  2023-02-03 [CodeOptimization]  start /
  private void writeOutputLog(long pat_group_id, Map<String, String> payload, PatGroup patGroupOrg, List<PatGroupDetail> PGDetailsOrg, NtssUser user){

    String functionName = convertString(payload.get("functionName"));
    String patGroupName = "";
      if(null != payload) {
        JSONArray jsonArray = new JSONArray("[" + payload.get("pat_group") + "]");
        JSONObject jsonObj = jsonArray.getJSONObject(0);
        patGroupName = jsonObj.getString("patGroupName");
        // del redmine 6471 患者グループの編集した記録がログに残らない  周 start
        //PatGroup patGroupOrg = patGroupService.selectPatGroupByCd(user.getFacilityCd(), pat_group_id);
        // del redmine 6471 患者グループの編集した記録がログに残らない  周 start
        if(!patGroupOrg.getPatGroupName().equals(patGroupName)) {
          outputLog(LogLevel.MONGO, String.format(MODPATGROUP_LOG_MESSAGE, patGroupOrg.getPatGroupName(), patGroupName), functionName, null);
        }
        // add redmine 6471 患者グループの編集した記録がログに残らない  周 start
        List<Long> orgUsers = new ArrayList<>();
        List<Long> newUsers = new ArrayList<>();
        List<PatGroupDetail> PGDetailsNew = patGroupDetailService.selectByPatGroupCd(pat_group_id, user.getFacilityCd());
        PGDetailsOrg.stream().forEach(patDetailOrg -> {
          orgUsers.add(patDetailOrg.getPatId());
        });
        PGDetailsNew.stream().forEach(patDetailNew -> {
          newUsers.add(patDetailNew.getPatId());
        });
        outputLog(LogLevel.MONGO, String.format(UPDPATGROUP_LOG_MESSAGE, patGroupName, orgUsers.toString(), newUsers.toString()), functionName, null);
        // add redmine 6471 患者グループの編集した記録がログに残らない  周 end
      }

  }

   /**
    * 連携コード1の取得
    *
    * @param facilityCd 施設コード
    * @param patGroupCd 患者グループコード
    * @throws Exception
    */
  private String getInHospitalCd_1(String facilityCd, Long patGroupCd) throws Exception {
    // 定義
    PatGroup patGroup = null;
    String inHospitalCd_1 = "";
    try {
      // 患者グループの取得
      patGroup = patGroupDao.selectById(patGroupCd, facilityCd);
      // 患者グループ取得済の場合
      if (patGroup != null) {
        // 連携コード1の取得
       inHospitalCd_1 = patGroup.getInHospitalCd_1();
      }

    } catch (Exception e) {
      // 例外処理
      throw new Exception(e);
    }
    return inHospitalCd_1;
  }

  // redmine 6471 患者グループの編集した記録がログに残らない  周 start
  private void outputLog(LogLevel level, String message, String functionName,String patid) {
    if (StringUtils.isEmpty(message)) {
      return;
    }
    EventLogMessage eventLogMessage = new EventLogMessage();
    eventLogMessage.setEc2Identification(LogObjectUtils.getHostAddress());
    eventLogMessage.setLogMessage(message);
    eventLogMessage.setInvokeClass(this.getClass().getName());
    eventLogMessage.setFunctionName(convertString(functionName));
    eventLogMessage.setPatId(patid);
    logService.log(level, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
  }

  private String convertString(Object obj) {
    if (obj == null) {
      return "";
    }

    return obj.toString();
  }
  // redmine 6471 患者グループの編集した記録がログに残らない  周 end
  // add by YangYongzhuang  2023-02-03 [CodeOptimization]  End /

  /**
   * ログ出力共通クラス設定、取得
   * @return logCommon ログ出力共通クラス
   */
  private DataUpdateLogCommonNew getLogCommon(Object dao, String tableName, StringBuffer whereStr, EventLogMessage eventLogMessage) {
    DataUpdateLogCommonNew logCommon = new DataUpdateLogCommonNew();
    logCommon.setEventLoggerFactory(eventLoggerFactory);
    logCommon.setLogServiceCore(logServiceCore);
    logCommon.setConfig(Config.get(dao));
    logCommon.setTableName(tableName);
    logCommon.setWhereStr(whereStr);
    logCommon.setCommonEventLogMessage(eventLogMessage);
    return logCommon;
  }
  // DB更新ログ出力ロジック wangzuo End
}
