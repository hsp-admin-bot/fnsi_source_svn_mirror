package jp.co.nikkiso.ntss.admin_web.service.externalCoopOperViewer;

import java.net.URI;
import java.util.ArrayList;
import java.util.Collections;
import java.util.HashMap;
import java.util.Iterator;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Function;
import java.util.stream.Collectors;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import com.fasterxml.jackson.databind.ObjectMapper;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import jp.co.nikkiso.ntss.admin_web.constant.CoopCdConstant;
import jp.co.nikkiso.ntss.admin_web.request.patientCapture.JournalCreateRequestPayload;
import jp.co.nikkiso.ntss.admin_web.service.JournalService;
import jp.co.nikkiso.ntss.admin_web.service.PatInfoService;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MntIfEdgeClientConnectDao;
import jp.co.nikkiso.ntss.core.dao.MntIfEdgeHealthmonDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstIfEdgeCommandDao;
import jp.co.nikkiso.ntss.core.dao.PatPersonalMainDao;
import jp.co.nikkiso.ntss.core.dao.SysCoopJournalDao;
import jp.co.nikkiso.ntss.core.entity.ConIntelligenceListmon;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeClientConnect;
import jp.co.nikkiso.ntss.core.entity.MntIfEdgeHealthmon;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;
import jp.co.nikkiso.ntss.core.entity.MstIfEdgeCommand;
import jp.co.nikkiso.ntss.core.entity.OrdCoopNo;
import jp.co.nikkiso.ntss.core.entity.PatPersonalMain;
import jp.co.nikkiso.ntss.core.entity.SysCoopJournal;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.LogLevel;
import jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils;
import org.json.JSONObject;
import org.modelmapper.ModelMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.MediaType;
import org.springframework.http.RequestEntity;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import org.springframework.http.ResponseEntity;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.admin_web.response.externalCoopOperViewer.SysCoopJournalDetail;
import jp.co.nikkiso.ntss.admin_web.security.NtssUser;

import jp.co.nikkiso.ntss.core.entity.custom.ExternalCoopPayload;
import org.springframework.util.StringUtils;
import org.springframework.web.client.RestTemplate;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang start
import static jp.co.nikkiso.ntss.core.utils.LogAspectorToolsUtils.toJson;
import static jp.co.nikkiso.ntss.core.utils.NtssUtils.ExcetionStackTraceToString;
// #9698 アプリケーションログの内容修正 20260328 add yangxuewang end

@Service
public class ExternalCoopOperViewerServiceImpl implements ExternalCoopOperViewerService {
	@Autowired
  MntIfEdgeHealthmonDao mntIfEdgeHealthmonDao;

	@Autowired
  SysCoopJournalDao sysCoopJournalDao;

	@Autowired
  PatPersonalMainDao patPersonalMainDao;

//  add 5615 IFエッジコマンド実行 関 start
  @Autowired
  MstIfEdgeCommandDao mstIfEdgeCommandDao;
//  add 5615 IFエッジコマンド実行 関 end
  // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
  @Autowired
  MntIfEdgeClientConnectDao mntIfEdgeClientConnectDao;
  // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
  //add #9490 電子カルテアイコンの連携先情報の制御について、2023.8.25 lmf start
  @Autowired
  private MstCoopFacilityDao mstCoopFacilityDao;
  //add #9490 電子カルテアイコンの連携先情報の制御について、2023.8.25 lmf end
	/**
	 * {@inheritDoc}
	 */
	@Override
	public List<MntIfEdgeHealthmon> getMntIfEdgeHealthMonByFacilityCd(String facilityCd) throws Exception {
		return mntIfEdgeHealthmonDao.selectByFacilityCd(facilityCd);
	}
  // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 start
  @Override
  public MntIfEdgeClientConnect getMntIfEdgeClientConn(String facilityCd) throws Exception {
    return mntIfEdgeClientConnectDao.selectByFacilityCd(facilityCd);
  }
  // add 7348 IFエッジ→AWSへの死活監視電文が送信されなくなった 吉 end
	// add FNSI-連携情報を追加 李 start
  /**
   * {@inheritDoc}
   */
  @Override
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  public List<ConIntelligenceListmon> getConIntelligenceListByFacilityCd(String facilityCd, String selectedPatId) throws Exception {
//    return mntIfEdgeHealthmonDao.selectConIntelligenceListByFacilityCd(facilityCd, selectedPatId);
//  }
  public List<ConIntelligenceListmon> getConIntelligenceListByFacilityCd(String facilityCd, String coopVersion,
                                                                         String selectedPatId) throws Exception {
    return mntIfEdgeHealthmonDao.selectConIntelligenceListByFacilityCd(facilityCd, coopVersion, selectedPatId);
  }
// mod 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  // add FNSI-連携情報を追加 李 end

	/**
	 * {@inheritDoc}
	 */
	@Override
	public List<SysCoopJournalDetail> getSysCoopJournalByCondition(String facilityCd, ExternalCoopPayload payload)
			throws Exception {
      List<SysCoopJournal> sysList = new ArrayList<SysCoopJournal>();

      //#9509 検索条件のフリーワードの検索範囲について 2023-08-30 卓 start
      if (payload.getContent() != null && !payload.getContent().isEmpty() && !payload.getContent().trim().isEmpty()) {
        List<PatPersonalMain> patPersonNameList = patPersonalMainDao.selectByPatFirstLastName(facilityCd, payload.getContent());
        if (patPersonNameList != null && patPersonNameList.size() > 0) {
          payload.setPatIdList(patPersonNameList.stream().map(PatPersonalMain::getPat_id).collect(Collectors.toList()));
        }
      }
      //#9509 検索条件のフリーワードの検索範囲について 2023-08-30 卓 end

      sysList = sysCoopJournalDao.selectByConditionNoMoreTo(facilityCd, payload);

      // add  #7701 2022-10-20  【デグレ】稼働ビューア画面の電文内容確認画面に何も表示されなくなった 孟堅 start
      if (sysList!=null){
        for(int i = 0 ; i < sysList.size() ; i++){
          SysCoopJournal sysCoopJournal = sysList.get(i);
          byte[] dump = sysCoopJournal.getDump();
          if(dump != null){
            String sjisStr = new String(dump, "MS932");
            // mod 8488 連携稼働ビューアにて処理成功だったprofile（受信）のana_resultを未処理にするとエラーが発生する 関 start
            // sysCoopJournal.setDump(sjisStr.getBytes());
            sysCoopJournal.setDump(sjisStr.getBytes("UTF-8"));
            // mod 8488 連携稼働ビューアにて処理成功だったprofile（受信）のana_resultを未処理にするとエラーが発生する 関 end
          }
        }
      }
      // add #7701 2022-10-20  【デグレ】稼働ビューア画面の電文内容確認画面に何も表示されなくなった　 孟堅 end

      NtssUser user = (NtssUser) SecurityContextHolder.getContext().getAuthentication().getPrincipal();
      // 日機装施設の連携稼働ビューアで顧客施設の情報を表示する際に患者名はマスキングする
      boolean isMasked = user != null && !user.getFacilityCd().equals(facilityCd);

      // patId一覧を抽出して重複除去
      List<Long> patIdList = sysList.stream()
          .map(SysCoopJournal::getPatId)
          .filter(Objects::nonNull)
          .distinct()
          .collect(Collectors.toList());

      // 患者情報を取得
      Map<Long, PatPersonalMain> patMap = patIdList.isEmpty()
          ? Collections.emptyMap()
          : patPersonalMainDao.selectByIdList(patIdList).stream()
              .collect(Collectors.toMap(PatPersonalMain::getPat_id, Function.identity()));

      return sysList.stream()
          .map(sysCoopJournal -> toSysCoopJournalDetail(sysCoopJournal, isMasked, patMap))
          .collect(Collectors.toList());
    }

	/**
	 * {@inheritDoc}
	 */
	@Override
	@Transactional
	public void updateSys(List<SysCoopJournalDetail> sysList) throws Exception {
		List<SysCoopJournal> list = sysList.stream().map(this::toSysCoopJournal).collect(Collectors.toList());
		for (int i = 0; i < list.size(); i++) {
      // mod 8488 連携稼働ビューアにて処理成功だったprofile（受信）のana_resultを未処理にするとエラーが発生する 関 start
      // byte[] dump = list.get(i).getDump();
      /* modify by chamaojia 2023-05-06 [8353] NULL値判定の追加  --start */
      byte[] dump = null;
      if (list.get(i).getDump() != null) {
        String utf8Str = new String(list.get(i).getDump(), "UTF-8");
        dump = utf8Str.getBytes("MS932");
      }
      /* modify by chamaojia 2023-05-06 [8353] NULL値判定の追加  --end */
      // mod 8488 連携稼働ビューアにて処理成功だったprofile（受信）のana_resultを未処理にするとエラーが発生する 関 end
      // mod FutreNetWeb+SI課題管理No4358 趙 start
      // add FNSI-通信結果を「未処理」にして「保存」ボタン押下時の処理 鄭 start
      // if("0".equals(list.get(i).getCoopResult())){
      // 通信開始日時をクリア
      // list.get(i).setInRegDate(null);
      // 通信完了日時をクリア
      // list.get(i).setOutRegDate(null);
      // 処理開始日時をクリア
      // list.get(i).setInAnaDate(null);
      // 処理完了日時をクリア
      // list.get(i).setOutAnaDate(null);
      // メッセージをクリア
      // list.get(i).setMessage(null);
      // }
      // add FNSI-通信結果を「未処理」にして「保存」ボタン押下時の処理 鄭 end
      if("S".equals(list.get(i).getDirection()) && "0".equals(list.get(i).getAnaResult())){
        // 配信処理終了日時をクリア
        list.get(i).setInAnaDate(null);
        // 変換処理完了日時をクリア
        list.get(i).setOutAnaDate(null);
        // メッセージをクリア
        list.get(i).setMessage(null);
        // 送信電文パスをクリア
        list.get(i).setDumpPath(null);
        // 送信電文をクリア
        list.get(i).setDump(null);
        // レポートコード
        list.get(i).setReportCd(null);
      }
      if("S".equals(list.get(i).getDirection()) && "0".equals(list.get(i).getCoopResult())){
        // 配信処理開始日時をクリア
        list.get(i).setInRegDate(null);
        // 変換処理開始日時をクリア
        if (!list.get(i).getCoopCdIndex().contains("pdf")) {
          list.get(i).setOutRegDate(null);
        }
        // メッセージをクリア
        list.get(i).setMessage(null);
      }
      if("R".equals(list.get(i).getDirection()) && "0".equals(list.get(i).getAnaResult())){
        // 配信処理終了日時をクリア
        list.get(i).setInAnaDate(null);
        // 変換処理完了日時をクリア
        list.get(i).setOutAnaDate(null);
        // メッセージをクリア
        list.get(i).setMessage(null);
      }
      // mod FutreNetWeb+SI課題管理No4358 趙 end
			sysCoopJournalDao.updateSysExternal(list.get(i), dump);
      // del 8229 外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230129 zhaoqi start
      // add FNSI-通信結果を「未処理」にして「保存」ボタン押下時の処理 鄭 start
      //配信処理ステータスは0:未処理の場合
//      if("0".equals(list.get(i).getCoopResult()) && "0".equals(list.get(i).getAnaResult()) && "S".equals(list.get(i).getDirection())){
//        //
//        //連携API → 電文生成API呼び出し
//        this.callCreateJournal(
//          list.get(i).getFacilityCd(),
//          list.get(i).getOrdNo(),
//          list.get(i).getUserId(),
//          list.get(i).getPatId(),
//          list.get(i).getCoopCd());
//      }
      // add FNSI-通信結果を「未処理」にして「保存」ボタン押下時の処理 鄭 end
      // del 8229 外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230129 zhaoqi end
		}
	}

	/**
	 * 外部連携用ジャーナル詳細に変換
	 * @param sysCoopJournal 外部連携用ジャーナル
	 * @param isMasked 患者名をマスキングするかのフラグ
     * @param patMap 患者情報を格納したMap
	 * @return 外部連携用ジャーナル詳細
	 */
	private SysCoopJournalDetail toSysCoopJournalDetail(SysCoopJournal sysCoopJournal, boolean isMasked, Map<Long, PatPersonalMain> patMap) {
	  ModelMapper mapper = new ModelMapper();
	  SysCoopJournalDetail detail = mapper.map(sysCoopJournal, SysCoopJournalDetail.class);

	  PatPersonalMain pat = patMap.get(sysCoopJournal.getPatId());
	  String patName = "";
	  if (pat != null) {
	    String pat_first_name = pat.getPat_first_name() == null ? "" : pat.getPat_first_name();
	    String pat_last_name = pat.getPat_last_name() == null ? "" : pat.getPat_last_name();
	    patName = pat_last_name + " " + pat_first_name;

	    if (!isMasked) {
	      // マスクなしの場合のみレスポンスに設定
  	    detail.setPatLastName(pat.getPat_last_name());
  	    detail.setPatFirstName(pat.getPat_first_name());
  	    detail.setPatLastNameKana(pat.getPat_last_name_kana());
  	    detail.setPatFirstNameKana(pat.getPat_first_name_kana());
	    }
	  }
	  if (isMasked) {
	    // 患者名のスペースを除く1文字ごとに「＊(全角アスタリスク)」に置換する
	    patName = patName.replaceAll("[^　\\s]", "＊");
	  }
	  detail.setPatName(patName);
	  return detail;
	}

	/**
	 * 外部連携用ジャーナルに変換
	 * @param sysCoopJournalDetail 外部連携用ジャーナル詳細
	 * @return 外部連携用ジャーナル
	 */
	private SysCoopJournal toSysCoopJournal(SysCoopJournalDetail sysCoopJournalDetail) {
		ModelMapper mapper = new ModelMapper();
		return mapper.map(sysCoopJournalDetail, SysCoopJournal.class);
	}
  // add FNSI-通信結果を「未処理」にして「保存」ボタン押下時の処理 鄭 start
  @Value("${ntss.admin-web.coop-api.url}")
  private String coopApi;
  /* add by chamaojia 2024-06-21 [10574] communication security related additions --start */
  @Value("${ntss.admin-web.coop-api.header-name}")
  private String headerKey;
  @Value("${ntss.admin-web.coop-api.header-value}")
  private String headerValue;
  /* add by chamaojia 2024-06-21 [10574] communication security related additions --end */
  @Autowired
  private PatInfoService patInfoService;
  @Autowired
  private JournalService journalService;
  @Autowired
  LogService logService;
  /**
   * {@inheritDoc}
   */
  // mod 8229 外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230129 zhaoqi start
  public void callCreateJournal(String facilityCd,Long ordNo, Long userId, Long patId, String coopCd) throws Exception {
  // mod 8229 外部連携のSQLのロック待ちによりDBの負荷が高くなる 20230129 zhaoqi end
    JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
    payload = mappingJournalCreateRequestPayload(userId, facilityCd, patId, coopCd,
      CoopCdConstant.CRUD_UPDATE);
    try {
      boolean callFlg = true;
      if (!payload.getCrud().equals("C")) {
        List<OrdCoopNo> list = new ArrayList<OrdCoopNo>();
        list = journalService.getByCondition(payload.getFacilityCd(), payload.getOrdNo(),
          payload.getCoopCd());
        if (list.size() == 0) {
          callFlg = false;
        }
      }
      if (callFlg) {
        RestTemplate rt = new RestTemplate();
        URI uri = new URI(coopApi + "/journal/create");
        RequestEntity<JournalCreateRequestPayload> request = RequestEntity.post(uri)
                .contentType(MediaType.APPLICATION_JSON)
                /* add by chamaojia 2024-06-21 [10574] communication security related additions --start */
                .header(headerKey, headerValue)
                /* add by chamaojia 2024-06-21 [10574] communication security related additions --end */
                .body(payload);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang start
        long start = System.currentTimeMillis();
        ResponseEntity<Object> response = rt.exchange(request, Object.class);
        long cost = System.currentTimeMillis() - start;
        Map<String, Object> map = new HashMap<>();
        map.put("logType", "RESTTEMPLATE-LOG");
        map.put("className", "jp.co.nikkiso.ntss.admin_web.service.externalCoopOperViewer.ExternalCoopOperViewerServiceImpl");
        map.put("methodName", "callCreateJournal");
        map.put("method", request.getMethod());
        map.put("url", uri.getPath());
        map.put("headers", request.getHeaders());
        map.put("requestParameter", request.getBody());
        map.put("status",response.getStatusCode());
        map.put("cost", cost);
        map.put("result",response.getBody());
        EventLogMessage restTemplateEventLogMessage = new EventLogMessage();
        restTemplateEventLogMessage.setLogMessage(toJson(map));
        restTemplateEventLogMessage.setFacilityCd(facilityCd);
        logService.log(LogLevel.INFO, restTemplateEventLogMessage, null, LoggingConstant.SERVICE_NAME.FNSI, null);
// #9698 アプリケーションログの内容修正 20260328 mod yangxuewang end
      }
    } catch (Exception ex) {
      //patInfoService.createNotificationMessage(userId, payload);
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(ex));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }
  }

  /**
   * 戻り値：編集済のジャーナル登録依頼ペイロード
   *
   * @param userId ユーザーID
   * @param facilityCd 施設コード
   * @param patId 患者ID
   * @param coopCd 連携種別
   * @param crud 作成更新区分
   * @return
   */
  private JournalCreateRequestPayload mappingJournalCreateRequestPayload(Long userId, String facilityCd, Long patId,
                                                                         String coopCd, String crud) {
    JournalCreateRequestPayload payload = new JournalCreateRequestPayload();
    payload.setFacilityCd(facilityCd);
    payload.setCoopCd(coopCd);
    payload.setCoopCdIndex("");
    payload.setCrud(crud);
    payload.setDirection("S");
    payload.setAnaResult("0");
    payload.setCoopResult("0");
    payload.setPatId(patId);
    payload.setHospPatId("");
    payload.setOrdNo(0L);
    payload.setUserId(userId);
    return payload;
  }
  // add FNSI-通信結果を「未処理」にして「保存」ボタン押下時の処理 鄭 end
//  add 5615 IFエッジコマンド実行 関 start
  @Override
  public Map<String, Object> selectEdgeCommand() {
    Map<String, Object> map = new HashMap<String, Object>();
    List<MstIfEdgeCommand> listEdgeCommand =  mstIfEdgeCommandDao.selectCommand();
    map.put("listEdgeCommand",listEdgeCommand);
    return map;
  }
//  add 5615 IFエッジコマンド実行 関 end

  //add 9490 2023.8.25 lmf start
  @Override
  public String getHealthmonFacilityConnByOn(String facilityCd) {
    /* modify by chamaojia 2024-10-11 [11140] 【healthmon_facility_conn】 JSON structure change  --start */
    Map<String,Map<String,Object>> map = new HashMap<>();
    try {
      MstCoopFacility mstCoopFacility =  mstCoopFacilityDao.select(facilityCd);
      List<MstCoopFacility.CoopOrdCd> validCoopOrdCdList = new ArrayList<>();
      MstCoopFacility.CommonSetting commonSetting = mstCoopFacility.getCommonSetting();
      if (commonSetting != null) {
        MstCoopFacility.CoopOpeCd coopOpeCd = commonSetting.getCoopOpeCd();
        List<MstCoopFacility.CoopOrdCd> coopOrdCds = commonSetting.getCoopOrdCds();
        if (coopOpeCd != null) {
          // オペコード
          List<MstCoopFacility.OpeCdStatus> opeCdSends = coopOpeCd.getOpeCdSends();
          if (opeCdSends != null && opeCdSends.size() != 0) {
            // オペコードをループ
            for (MstCoopFacility.OpeCdStatus opeStatus : opeCdSends) {
              if (!"on".equals(opeStatus.getStatus())) {
                continue;
              }
              // 「on:有効」の場合
              for (MstCoopFacility.CoopOrdCd coopOrdCd : coopOrdCds) {
                List<String> opeCds = coopOrdCd.getOpeCds();
                if (opeCds != null && opeCds.size() != 0 && opeCds.contains(opeStatus.getOpeCd())) {
                  if (!StringUtils.isEmpty(coopOrdCd.getCoopCd())) {
                    validCoopOrdCdList.add(coopOrdCd);
                  }
                }
              }
            }
          }
        }
      }
      List<MntIfEdgeHealthmon> list = mntIfEdgeHealthmonDao.selectByFacilityCd(facilityCd);
      if (list != null && list.size() > 0) {
        for (MntIfEdgeHealthmon mntIfEdgeHealthmon : list){
          JSONObject json = new JSONObject(mntIfEdgeHealthmon.getHealthmonFacilityConn());
          Iterator<String> keys = json.keys();
          while (keys.hasNext()){
            String coopVersion = keys.next();
            JSONObject cvvJson = new JSONObject(json.get(coopVersion).toString());
            Iterator<String> coopCdKeys = cvvJson.keys();
            Map<String,Object> coopCdMap = new HashMap<>();
            while (coopCdKeys.hasNext()){
              String coopCd = coopCdKeys.next();
              long existsCount =
                      validCoopOrdCdList.stream().filter(c -> c.getCoopCd().equals(coopCd)
                              && c.getCoopVersion().equals(coopVersion)).count();
              if (existsCount > 0) {
                coopCdMap.put(coopCd,cvvJson.get(coopCd));
              }
            }

            if (!coopCdMap.isEmpty()) {
              map.put(coopVersion, coopCdMap);
            }
          }
        }
      }
    } catch (Exception e) {
      EventLogMessage eventLogMessage = new EventLogMessage();
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang start
      eventLogMessage.setLogMessage(ExcetionStackTraceToString(e));
      if (facilityCd != null) {
        eventLogMessage.setFacilityCd(facilityCd);
      }
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある 20260407 mod yangxuewang end
      logService.log(LogLevel.ERROR, eventLogMessage, "", LoggingConstant.SERVICE_NAME.FNSI, null);
    }
    /* modify by chamaojia 2024-10-11 [11140] 【healthmon_facility_conn】 JSON structure change  --end */
    String jsonString = JSONObject.valueToString(map);
    return jsonString;
  }
  //add 9490 2023.8.25 lmf end
}
