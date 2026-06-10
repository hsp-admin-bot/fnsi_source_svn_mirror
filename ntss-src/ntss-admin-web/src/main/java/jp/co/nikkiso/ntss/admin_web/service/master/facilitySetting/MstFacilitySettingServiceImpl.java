package jp.co.nikkiso.ntss.admin_web.service.master.facilitySetting;

import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.OPERATION;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.SORT_INPUT_TIME;
import static jp.co.nikkiso.ntss.core.dao.MasterMaintenanceGenericDao.SORT_RANK;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.dao.MstDeviceSetInfoDefaultDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilityHashDao;
import jp.co.nikkiso.ntss.core.dao.MstFacilitySettingDao;
import jp.co.nikkiso.ntss.core.dao.MstPersonalUserDao;
import jp.co.nikkiso.ntss.core.dao.MstUserDao;
import jp.co.nikkiso.ntss.core.dao.PatMainDao;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import org.seasar.doma.jdbc.Config;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.google.common.base.CaseFormat;

import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterColumn;
import jp.co.nikkiso.ntss.admin_web.response.masterMaintenance.MasterDataResponse;
import jp.co.nikkiso.ntss.admin_web.service.utils.QRCodeUtils;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstFacilityHash;
import jp.co.nikkiso.ntss.core.entity.MstFacilitySetting;
import jp.co.nikkiso.ntss.core.entity.MstUser;
import jp.co.nikkiso.ntss.core.entity.SysMasterDefine.FieldType;
import jp.co.nikkiso.ntss.core.entity.custom.FacilitySettingInfo;
import jp.co.nikkiso.ntss.core.constant.CoreConstant.FacilitySettingNo;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class MstFacilitySettingServiceImpl implements MstFacilitySettingService {

  /**
   * KendoUI 数値項目の標準フォーマット(整数部のみ少数なし).
   */
  static final String NUMBER_FORMAT = "n0";

  /**
   * ソート用表示項目名.
   */
  static final String SORT_RANK_TITLE = "並び順";

  /**
   * レコード追加許可項目名.
   */
  static final String ALLOW_ADD_RECORD = "allowAddRecord";

  /**
   * 施設マスタのDaoインタフェース.
   */
  @Autowired
  private MstFacilityDao mstFacilityDao;

  /**
   * 施設設定マスタのDaoインタフェース.
   */
  @Autowired
  private MstFacilitySettingDao mstFacilitySettingDao;

  /**
   * 利用者マスタ(個人情報DB)のDaoインタフェース.
   */
  @Autowired
  private MstPersonalUserDao mstPersonalUserDao;

  /**
   * 利用者マスタのDaoインタフェース.
   */
  @Autowired
  private MstUserDao mstUserDao;

  /**
   * 施設マスタハッシュのDaoインタフェース.
   */
  @Autowired
  private MstFacilityHashDao mstFacilityHashDao;


  //DB更新ログ出力ロジック wp start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  //DB更新ログ出力ロジック wp end

  @Autowired
  private MstDeviceSetInfoDefaultDao mstDeviceSetInfoDefaultDao;

  @Autowired
  private PatMainDao patMainDao;

  @Autowired
  private LogService logService;
  /**
   * {@inheritDoc}
   */
  @Override
  public MasterDataResponse getMasterData(String facilityCd) {

    MasterDataResponse masterResponse = new MasterDataResponse();

    // カラム情報の作成
    masterResponse.columns = makeMasterColumn();

    // スキーマのフィールド情報の作成
    masterResponse.localDataSource.schema.model.fields = makeMasterField();

    // 対象データ取得
    masterResponse.localDataSource.data = selectUserDataByFacilityCd(facilityCd);

    // 成功レスポンス返却
    return masterResponse;
  }

  // 施設設定データ一覧取得
  public List<Map<String, Object>> selectUserDataByFacilityCd(String facilityCd) {

    String facilitySettingNo = null;

    // 施設コードを元に施設設定データ(Mst/Sys)を取得:全項目ケースのためfacilitySettingNoはnullセット
    List<FacilitySettingInfo> settingInfoList = mstFacilitySettingDao.selectFacilitySetting(facilityCd,facilitySettingNo);
    // 施設コードを元に施設マスタハッシュデータを取得
    MstFacilityHash mstFacilityHash = mstFacilityHashDao.selectByFacilityCd(facilityCd);

    // 取得データをMstUserDataに統合
    List<Map<String, Object>> facilitySettingList = new ArrayList<Map<String, Object>>();
    for(FacilitySettingInfo settingInfo : settingInfoList){

      // オブジェクトをHashMapに変換
      Map<String, Object> hashData = new HashMap<>();
      hashData.put("functionName", settingInfo.getFunctionName());
      hashData.put("facilitySettingNo", settingInfo.getFacilitySettingNo());
      hashData.put("facilityCd", settingInfo.getFacilityCd());
      hashData.put("settingName", settingInfo.getSettingName());
      if (settingInfo.getFacilitySettingNo().equals(FacilitySettingNo.ACCOUNT_LOCK_SETTING)) {
        // 施設設定番号が"1061"の場合、施設マスタハッシュのアカウントロック設定を設定
        hashData.put("value", mstFacilityHash.getAccountLockSetting());
      } else if (settingInfo.getFacilitySettingNo().equals(FacilitySettingNo.FAILURE_CNT)) {
        // 施設設定番号が"1062"の場合の場合、施設マスタハッシュのサインイン失敗回数を設定
        hashData.put("value", mstFacilityHash.getFailureCnt());
      } else if (settingInfo.getFacilitySettingNo().equals(FacilitySettingNo.OTP_FAILURE_CNT)) {
        // 施設設定番号が"1063"の場合の場合、施設マスタハッシュの2要素認証失敗回数を設定
        hashData.put("value", mstFacilityHash.getOtpFailureCnt());
      } else if (settingInfo.getFacilitySettingNo().equals(FacilitySettingNo.URL_SIGNIN)) {
        // 施設設定番号が"2001"の場合の場合、施設マスタハッシュのURLサインイン設定を設定
        hashData.put("value", mstFacilityHash.getUrlSignin());
      } else if (settingInfo.getFacilitySettingNo().equals(FacilitySettingNo.URL_SIGNIN_SECRETKEY)) {
        // 施設設定番号が"2002"の場合の場合、施設マスタハッシュのURLサインイン秘密鍵を設定
        hashData.put("value", mstFacilityHash.getUrlSigninSecretkey());
      } else if (settingInfo.getFacilitySettingNo().equals(FacilitySettingNo.IS_SIGNIN_DISP)) {
        // 施設設定番号が"3144"の場合の場合、施設マスタハッシュのサインイン表示設定を設定
        hashData.put("value", mstFacilityHash.getIsSigninDisp());
      } else {
        // 以外の場合、施設設定データを設定
        hashData.put("value", settingInfo.getValue());
      }
      hashData.put("inputType", settingInfo.getInputType());
      hashData.put("optionValue", settingInfo.getOptionValue());
      hashData.put("makerSetting", settingInfo.getMakerSetting());
      hashData.put("description", settingInfo.getDescription());
      hashData.put("dispOrder", settingInfo.getDispOrder());
      hashData.put("systemUseDisp", settingInfo.getSystemUseDisp());
      facilitySettingList.add(hashData);
    }

    return facilitySettingList;
  }

  /**
   * {@inheritDoc}
   */
  @Override
  public List<MstFacility> selectMstFacility() {
    List<MstFacility> mstFacilityList = mstFacilityDao.selectAllOrderBy("order by facility_cd");
    return mstFacilityList;
  }

  /**
   * 文字列をスネークケースに変換.
   *
   * @param targetString 対象文字列
   * @return 変換後文字列
   */
  private String convertToSnake(String targetString) {
    return CaseFormat.LOWER_CAMEL.to(CaseFormat.LOWER_UNDERSCORE, targetString);
  }

  /**
   * フォーマット文字列をKendoUI用に変換.
   *
   * @param formatString 対象文字列
   * @return 変換後文字列
   */
  private String getKendoFormatString(String formatString) {
    return "{0:" + formatString + "}";
  }

  /**
   * カラム情報の作成.
   *
   * @return カラム情報リスト
   */
  private List<MasterColumn> makeMasterColumn() {

    // カラム情報の作成
    List<MasterColumn> masterColumns = new ArrayList<MasterColumn>();

    MasterColumn masterColumn = null;

    // 表示順
    masterColumn = new MasterColumn("dispOrder", "No", false, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // userId
    masterColumn = new MasterColumn("facilitySettingNo", "No", true, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // ソート順項目を追加
    masterColumn = new MasterColumn(SORT_RANK, SORT_RANK_TITLE, false, false, getKendoFormatString(NUMBER_FORMAT), null, false, "");
    masterColumns.add(masterColumn);

    // ソート順用追加時刻項目を追加
    masterColumn = new MasterColumn(SORT_INPUT_TIME, SORT_INPUT_TIME, true, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // 機能名
    masterColumn = new MasterColumn("functionName", "機能名", false, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // facilityCd
    masterColumn = new MasterColumn("facilityCd", "施設コード", true, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // userName
    masterColumn = new MasterColumn("settingName", "設定名称", false, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // value
    masterColumn = new MasterColumn("value", "値", true, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // 画面表示値格納項目
    masterColumn = new MasterColumn("dispValue", "設定値", false, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // input_type
    masterColumn = new MasterColumn("inputType", "入力分類", true, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // option情報
    masterColumn = new MasterColumn("optionValue", "option情報", true, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // 操作権限可否
    masterColumn = new MasterColumn("makerSetting", "操作権限可否", true, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // 設定説明
    masterColumn = new MasterColumn("description", "設定説明", false, false, null, null, false, "");
    masterColumns.add(masterColumn);

    // 付加情報としてoperationを追加
    masterColumn = new MasterColumn(OPERATION, OPERATION, true, false, null, null, true, "");
    masterColumns.add(masterColumn);

    // 付加情報として追加許可を追加(allowAddRecord=1)
    masterColumn = new MasterColumn(ALLOW_ADD_RECORD, ALLOW_ADD_RECORD, true, false, null, null, true, "");
    masterColumns.add(masterColumn);

    return masterColumns;

  }

  /**
   * フィールド情報の作成.
   *
   * @return フィールド情報MAP
   */
  private Map<String, Object> makeMasterField() {

    Map<String, Object> fieldsMap = new HashMap<>();
    Map<String, Object> fieldsList;

    // function_name
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.STRING);
    fieldsMap.put("functionName", fieldsList);

    // facility_setting_no
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.STRING);
    fieldsMap.put("facilitySettingNo", fieldsList);

    // facility_cd
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.STRING);
    fieldsMap.put("facilityCd", fieldsList);

    // setting_name
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.STRING);
    fieldsMap.put("settingName", fieldsList);

    // value
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.STRING);
    fieldsMap.put("value", fieldsList);

    // dispValue
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.STRING);
    fieldsMap.put("dispValue", fieldsList);

    // input_type
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.NUMBER);
    fieldsMap.put("inputType", fieldsList);

    // option_value
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.STRING);
    fieldsMap.put("optionValue", fieldsList);

    // maker_setting
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.NUMBER);
    fieldsMap.put("makerSetting", fieldsList);

    // description
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.STRING);
    fieldsMap.put("description", fieldsList);

    // disp_order
    fieldsList = new HashMap<>();
    fieldsList.put("type", FieldType.NUMBER);
    fieldsMap.put("dispOrder", fieldsList);

    return fieldsMap;
  }

  @Override
  @Transactional
	public void saveMstFacilitySetting(Map<String, List<String>> payload) throws Exception {
			ObjectMapper mapper = new ObjectMapper();
			List<Long> listUserId = new ArrayList<>();
			List<MstFacilitySetting> mstFacilitySettingList = new ArrayList<MstFacilitySetting>();
    List<MstFacilitySetting> replenisherFiltrationSettingList = new ArrayList<MstFacilitySetting>();
			// 登録処理
			for (int i = 0; payload.get("insertRecord").size() > i; i++) {
				MstFacilitySetting mstFacilitySetting = mapper.readValue(payload.get("insertRecord").get(i),
						MstFacilitySetting.class);
				int result = 0;
				if (mstFacilitySetting.getFacilitySettingNo().equals(FacilitySettingNo.ACCOUNT_LOCK_SETTING)
				    || mstFacilitySetting.getFacilitySettingNo().equals(FacilitySettingNo.FAILURE_CNT)
				    || mstFacilitySetting.getFacilitySettingNo().equals(FacilitySettingNo.OTP_FAILURE_CNT)
 				    || mstFacilitySetting.getFacilitySettingNo().equals(FacilitySettingNo.URL_SIGNIN)
				    || mstFacilitySetting.getFacilitySettingNo().equals(FacilitySettingNo.URL_SIGNIN_SECRETKEY)
				    || mstFacilitySetting.getFacilitySettingNo().equals(FacilitySettingNo.IS_SIGNIN_DISP)) {
	              // 施設設定番号が"1061"、"1062"、"1063"、"2001"、"2002"、"3144"の場合、施設設定マスタリストに追加
				  mstFacilitySettingList.add(mstFacilitySetting);

				} else {

          //DB更新ログ出力ロジック wp start

          String mmsTbN = "mst_facility_setting";

          // SQL検索条件
          StringBuffer wheres = new StringBuffer("");
          wheres.append(" WHERE\n");
          wheres.append("  facility_setting_no = '" + mstFacilitySetting.getFacilitySettingNo() + "'" +"\n");
          wheres.append("  and \n");
          wheres.append("  facility_cd = '" + mstFacilitySetting.getFacilityCd() + "'" +"\n");
          // logCommon設定
          // logCommon設定
          DataUpdateLogCommonNew logCommon = getLogCommon(mstFacilitySettingDao, mmsTbN, wheres, getEventLogMessage());
          // ログ出力カラム情報及び更新前データ情報取得
          boolean setResult = logCommon.setInfo();
          //DB更新ログ出力ロジック wp end

          // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
          LogEventUtils.setOperatorId(mstFacilitySetting,logService);
          // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
          // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
          result = mstFacilitySettingDao.update(mstFacilitySetting);
          //add 7328 IDｍが医療情報DBにて管理されている 関俊楠 start
          //del 8094 【デグレ】スタッフカードでのサインインができない zhao start
//          if (result > 0 && FacilitySettingNo.LOGIN_METHOD_SETTING_NO.equals(mstFacilitySetting.getFacilitySettingNo())) {
//            //修改DB4 mst_facility_hash表中的value列值
//            mstFacilityHashDao.updateValue(mstFacilitySetting.getFacilityCd(), mstFacilitySetting.getValue());
//          }
          //del 8094 【デグレ】スタッフカードでのサインインができない zhao end
          //add 7328 IDｍが医療情報DBにて管理されている 関俊楠 end

          //DB更新ログ出力ロジック wp start
          // 更新後データ取得、差分あれば、log出力
          if (setResult && result > 0) {
            logCommon.updateLog();
          }
          //DB更新ログ出力ロジック wp end

          if(result == 0 ) {
            result = mstFacilitySettingDao.insert(mstFacilitySetting);
          }
          //add 8094 【デグレ】スタッフカードでのサインインができない zhao start
          if (result > 0 && FacilitySettingNo.LOGIN_METHOD_SETTING_NO.equals(mstFacilitySetting.getFacilitySettingNo())) {
            //修改DB4 mst_facility_hash表中的value列值
            mstFacilityHashDao.updateValue(mstFacilitySetting.getFacilityCd(), mstFacilitySetting.getValue());
          }
          //add 8094 【デグレ】スタッフカードでのサインインができない zhao end
        if(mstFacilitySetting.getFacilitySettingNo().equals(FacilitySettingNo.REPLENISHER_FILTRATION_SETTING)){
          replenisherFiltrationSettingList.add(mstFacilitySetting);
        }
      }
				// 必須使用
				if (result > 0 && mstFacilitySetting.getValue().equals("2") && mstFacilitySetting.getFacilitySettingNo().equals(FacilitySettingNo.TWO_FACTOR_AUTHENTICATION)) {
					// 施設ごとのユーザーIDのリスト
					listUserId = mstPersonalUserDao.selectListUserIdByFacilityCd(mstFacilitySetting.getFacilityCd(),
							"0");
					if (listUserId != null) {
						List<MstUser> listUser = mstUserDao.selectListUserNullSercetKey(listUserId);
						listUser.stream().forEach(user -> {
							MstUser newMstUser = new MstUser() {
								{
									setUserId(user.getUserId());
									setUpDate(getCurrentDate());
									setSecretKey(QRCodeUtils.getSecretKey());
									setIsSetQrCode(0);
								}
							};
							// 秘密鍵を作成し、otpで最初のログインを設定します
							mstUserDao.setSecretKey(newMstUser);
					  });
					}
				}
			}
			// 施設設定マスタリストの件数が「０」件でない場合、施設マスタハッシュテーブルに更新
			if (mstFacilitySettingList.size() != 0) {
			  mstFacilityHashDao.updateByFacilityCd(mstFacilitySettingList, mstFacilitySettingList.get(0).getFacilityCd(),
			      mstFacilitySettingList.get(0).getUpDate());
    }
    if(replenisherFiltrationSettingList.size() != 0){
      if("0".equals(replenisherFiltrationSettingList.get(0).getValue())){
        // del #12651 施設設定マスタ>No.114濾過率から算出有効化設定をON/OFFした際の動作について fang start
//        mstDeviceSetInfoDefaultDao.deleteReplenisherFiltration(replenisherFiltrationSettingList.get(0).getFacilityCd());
        // del #12651 施設設定マスタ>No.114濾過率から算出有効化設定をON/OFFした際の動作について fang end
        mstDeviceSetInfoDefaultDao.updateReplenisherFiltrationCode(replenisherFiltrationSettingList.get(0).getFacilityCd());
        // del #12651 施設設定マスタ>No.114濾過率から算出有効化設定をON/OFFした際の動作について fang start
//        patMainDao.deletePatReplenisherFiltration(replenisherFiltrationSettingList.get(0).getFacilityCd());
        // del #12651 施設設定マスタ>No.114濾過率から算出有効化設定をON/OFFした際の動作について fang end
        patMainDao.updatePatReplenisherFiltrationCode(replenisherFiltrationSettingList.get(0).getFacilityCd());
      } else if("1".equals(replenisherFiltrationSettingList.get(0).getValue())){
        mstDeviceSetInfoDefaultDao.insertReplenisherFiltration(replenisherFiltrationSettingList.get(0).getFacilityCd());
        patMainDao.insertPatReplenisherFiltration(replenisherFiltrationSettingList.get(0).getFacilityCd());
      }
    }
	}

  /**
   * 施設コードによる施設レベルの取得
   * @return 結果
   */
  @Override
  public String getValueSignInByFacilityCd(String facilityCd){
    FacilitySettingInfo fsi = new FacilitySettingInfo();
    fsi = mstFacilitySettingDao.getValueSignInByFacilityCd(facilityCd);
    return fsi.getValue();
  }

  /**
   * システム日時を取得します
   * @return システム日時
   */
  private java.sql.Timestamp getCurrentDate() {
    return new java.sql.Timestamp(System.currentTimeMillis());
  }

  //DB更新ログ出力ロジック wp start

  /**
   * ログ情報設定
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
    return   eventLogMessage;
  }

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

  //DB更新ログ出力ロジック wp end
}
