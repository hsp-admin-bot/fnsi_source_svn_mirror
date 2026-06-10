package jp.co.nikkiso.ntss.m_notice.web.rest;

import java.sql.SQLException;
import java.util.List;

import jp.co.nikkiso.ntss.m_notice.service.LogEventUtils;
import jp.co.nikkiso.ntss.m_notice.service.MntMNoticeManageService;
import jp.co.nikkiso.ntss.m_notice.service.MstFacilityService;
import jp.co.nikkiso.ntss.m_notice.service.MstMNoticeService;
import jp.co.nikkiso.ntss.m_notice.service.MstMachineRecordService;
import jp.co.nikkiso.ntss.m_notice.service.MstMachineService;
import jp.co.nikkiso.ntss.m_notice.service.SysSystemDefineService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;

import jp.co.nikkiso.ntss.core.entity.MntMNoticeManage;
import jp.co.nikkiso.ntss.core.entity.MstFacility;
import jp.co.nikkiso.ntss.core.entity.MstMNotice;
import jp.co.nikkiso.ntss.core.entity.MstMachine;
import jp.co.nikkiso.ntss.core.entity.MstMachineRecord;
import jp.co.nikkiso.ntss.core.entity.SysSystemDefine;

import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.AFTER_LOG_FLG_INFO;
import static jp.co.nikkiso.ntss.core.constant.LoggingConstant.MONGO_LOG.BEFORE_LOG_FLG_INFO;

@Controller
public class MNoticeResource {

  /**
   * 緊急発報マスタサービス.
   */
  @Autowired
  MstMNoticeService mstMNoticeService;

  /**
   * 緊急発報管理サービス.
   */
  @Autowired
  MntMNoticeManageService mNoticeManageService;

  /**
   * 施設マスタサービス.
   */
  @Autowired
  MstFacilityService mstFacilityService;

  /**
   * 装置記録マスタサービス.
   */
  @Autowired
  MstMachineRecordService mstMachineRecordService;

  /**
   * 装置マスタサービス.
   */
  @Autowired
  MstMachineService mstMachineService;

  /**
   * システム設定クラス.
   */
  @Autowired
  SysSystemDefineService sysSystemDefineService;
  // wp アプリケーションログの適正化 Add Start
  @Autowired
  LogEventUtils logEventUtils;
  // wp アプリケーションログの適正化 Add End

  /**
   * 緊急発報マスタから全データを取得.
   *
   * @return 緊急発報マスタリスト
   * @throws SQLException
   */
  public List<MstMNotice> mstMNoticeGetAll() throws SQLException {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    List<MstMNotice> mstMNoticeList = mstMNoticeService.selectAll();


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return mstMNoticeList;
  }

  /**
   * 緊急発報マスタから、施設コード・装置記録コードに該当する緊急発報マスタを取得.
   *
   * @param facilityCd 施設コード
   * @param machineRecordCd 装置記録コード
   * @return 緊急発報マスタ
   * @throws SQLException
   */
  public MstMNotice mstMNoticeGet(String facilityCd, String machineRecordCd) throws SQLException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    MstMNotice mstMNotice = mstMNoticeService.findByCd(facilityCd, machineRecordCd);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return mstMNotice;
  }

  /**
   * 緊急発報マスタに緊急発報管理エンティティを追加.
   *
   * @param manage 緊急発報管理エンティティ
   * @return 緊急発報管理エンティティ
   * @throws SQLException
   */
  public MstMNotice mstMNoticeCreate(MstMNotice manage) throws SQLException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    MstMNotice mstMNotice = mstMNoticeService.create(manage);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return mstMNotice;
  }

  /**
   * 緊急発報マスタから施設コード・装置記録コードに該当するデータを削除.
   *
   * @param facilityCd 施設コード
   * @param machineRecordCd 装置記録コード
   * @throws SQLException
   */
  public void mstMNoticeDelete(String facilityCd, String machineRecordCd) throws SQLException {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    mstMNoticeService.delete(facilityCd, machineRecordCd);
  }

  /**
   * 緊急発報マスタに緊急発報エンティティを更新.
   *
   * @param manage 緊急発報エンティティ
   * @return 緊急発報エンティティ
   * @throws SQLException
   */
  public MstMNotice mstMNoticeUpdate(MstMNotice manage) throws SQLException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    MstMNotice mstMNotice = mstMNoticeService.update(manage);


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return mstMNotice;
  }

  /**
   * 緊急発報管理から、全レコードを取得.
   *
   * @return 緊急発報管理エンティティリスト
   * @throws SQLException
   */
  public List<MntMNoticeManage> manageGetAll() throws SQLException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    List<MntMNoticeManage> manageList = mNoticeManageService.selectAll();


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return manageList;
  }

  /**
   * 緊急発報管理にデータを追加.
   *
   * @param manage 緊急発報管理エンティティ
   * @return 緊急発報管理エンティティ
   * @throws SQLException
   */
  public MntMNoticeManage manageCreate(MntMNoticeManage manage) throws SQLException {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    MntMNoticeManage mNoticeManage = mNoticeManageService.create(manage);
    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    return mNoticeManage;
  }

  /**
   * 緊急発報管理から、緊急発報管理番号に該当するデータを取得.
   *
   * @param mNoticeManageNo 緊急発報管理番号
   * @return 緊急発報管理エンティティ
   * @throws SQLException
   */
  public MntMNoticeManage manageGetByManageNo(Long mNoticeManageNo) throws SQLException {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    MntMNoticeManage manageEntity = mNoticeManageService.findByManageNo(mNoticeManageNo);
    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    return manageEntity;
  }

  /**
   * 緊急発報管理から該当するデータを削除.
   *
   * @param mNoticeManageNo 緊急発報管理番号
   * @throws SQLException
   */
  public void manageDelete(Long mNoticeManageNo) throws SQLException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    mNoticeManageService.delete(mNoticeManageNo);
  }

  /**
   * 緊急発報管理へデータを更新.
   *
   * @param manage 緊急発報管理エンティティ
   * @return 緊急発報管理エンティティ
   * @throws SQLException
   */
  public MntMNoticeManage manageUpdate(MntMNoticeManage manage) throws SQLException {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    MntMNoticeManage mNoticeManage = mNoticeManageService.update(manage);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return mNoticeManage;
  }

  /**
   * 施設マスタから、全レコードを取得.
   *
   * @return 施設マスタエンティティ
   * @throws SQLException
   */
  public List<MstFacility> facilityGetALL() throws SQLException {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    List<MstFacility> facilityList = mstFacilityService.selectAll();


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return facilityList;
  }

  /**
   * 施設マスタにデータを追加.
   *
   * @param facility 施設マスタエンティティ
   * @return 施設マスタエンティティ
   * @throws SQLException
   */
  public MstFacility facilityCreate(MstFacility facility) throws SQLException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    MstFacility mstFacility = mstFacilityService.create(facility);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return mstFacility;
  }

  /**
   * 施設マスタから施設コードをもとにデータを取得.
   *
   * @param facilityCd 施設コード
   * @return 施設マスタエンティティ
   * @throws SQLException
   */
  public MstFacility facilityGet(String facilityCd) throws SQLException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    MstFacility mstFacility = mstFacilityService.findByCd(facilityCd);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return mstFacility;
  }

  /**
   * 施設マスタから該当するデータを削除.
   *
   * @param facilityCd 施設コード
   * @throws SQLException
   */
  public void facilityDelete(String facilityCd) throws SQLException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    mstFacilityService.delete(facilityCd);
  }

  /**
   * 施設マスタへデータを更新.
   *
   * @param facility 施設マスタエンティティ
   * @return 施設マスタエンティティ
   * @throws SQLException
   */
  public MstFacility facilityUpdate(MstFacility facility) throws SQLException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End


    MstFacility mstFacility = mstFacilityService.update(facility);
    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    return mstFacility;
  }

  /**
   * 装置記録マスタより全レコードを取得.
   *
   * @return 装置記録マスタエンティティ
   * @throws SQLException
   */
  public List<MstMachineRecord> machineRecordGetAll() throws SQLException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    List<MstMachineRecord> machineRecordList = mstMachineRecordService.selectAll();

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return machineRecordList;
  }

  /**
   * 装置記録マスタにデータを追加.
   *
   * @param machineRecord 装置記録コード
   * @return 装置記録マスタエンティティ
   * @throws SQLException
   */
  public MstMachineRecord machineRecordCreate(MstMachineRecord machineRecord) throws SQLException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    MstMachineRecord mstMachineRecord = mstMachineRecordService.create(machineRecord);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return mstMachineRecord;
  }

  /**
   * 装置記録マスタから該当するデータを取得.
   *
   * @param machineRecordCd 装置記録コード
   * @return 装置記録マスタエンティティ
   * @throws SQLException
   */
  public MstMachineRecord machineRecordGetByCd(String machineRecordCd) throws SQLException {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    MstMachineRecord mstMachineRecord = mstMachineRecordService.findByCd(machineRecordCd);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return mstMachineRecord;
  }

  /**
   * 装置記録マスタから装置記録コードより、装置記録メッセージを取得.
   *
   * @param machineRecordCd 装置記録コード
   * @return 装置記録メッセージ
   * @throws SQLException
   */
  public String machineRecordGetMessage(String machineRecordCd) throws SQLException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return mstMachineRecordService.selectMachineMessage(machineRecordCd);
  }

  /**
   * 装置記録マスタから該当するデータを削除.
   *
   * @param machineRecordCd 装置記録コード
   * @throws SQLException
   */
  public void machineRecordDelete(String machineRecordCd) throws SQLException {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    mstMachineRecordService.delete(machineRecordCd);
  }

  /**
   * 施設マスタへデータを更新.
   *
   * @param machineRecord 施設マスタエンティティ
   * @return 施設マスタエンティティ
   * @throws SQLException
   */
  public MstMachineRecord machineRecordUpdate(MstMachineRecord machineRecord) throws SQLException {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End


    MstMachineRecord mstMachineRecord = mstMachineRecordService.update(machineRecord);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return mstMachineRecord;
  }

  /**
   * 装置マスタから全レコードを取得.
   *
   * @return 装置マスタエンティティリスト
   * @throws SQLException
   */
  public List<MstMachine> machineGetAll() throws SQLException {


    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    List<MstMachine> mstMachineList = mstMachineService.selectAll();

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return mstMachineList;
  }

  /**
   * 装置マスタにデータを追加.
   *
   * @param machine 装置マスタエンティティ
   * @return 装置マスタエンティティ
   * @throws SQLException
   */
  public MstMachine machineCreate(MstMachine machine) throws SQLException {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    MstMachine mstMachine = mstMachineService.create(machine);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return mstMachine;
  }

  /**
   * 装置マスタから、該当するデータを取得.
   *
   * @param machineTypeCd 型式コード
   * @return 装置マスタエンティティ
   * @throws SQLException
   */
  public MstMachine machineGetByCd(String machineTypeCd, String machineSerial, String facilityCd) throws SQLException {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    MstMachine mstMachine = mstMachineService.findByCd(machineTypeCd, machineSerial, facilityCd);


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return mstMachine;
  }

  /**
   * 装置マスタから該当するデータを削除.
   *
   * @param machineTypeCd 型式コード
   * @throws SQLException
   */
  public void machineDelete(String machineTypeCd, String machineSerial, String facilityCd) throws SQLException{

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    mstMachineService.delete(machineTypeCd, machineSerial, facilityCd);
  }

  /**
   * 装置マスタへデータを更新.
   *
   * @param machine 装置マスタエンティティ
   * @return 装置マスタエンティティ
   * @throws SQLException
   */
  public MstMachine machineUpdate(MstMachine machine) throws SQLException {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    MstMachine mstMachine = mstMachineService.update(machine);


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return mstMachine;
  }

  /**
   * システム設定から全データを取得.
   *
   * @return システム設定リスト
   */
  public List<SysSystemDefine> systemSelectAll() {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    List<SysSystemDefine> sysSystemDefineList = sysSystemDefineService.selectAll();


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return sysSystemDefineList;
  }

  /**
   * システム設定から施設コードに該当するデータを取得.
   *
   * @param facilityCd 施設コード
   * @return システム設定エンティティ
   */
  public SysSystemDefine systemSelectByFacilityCd(String facilityCd) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    SysSystemDefine sysSystemDefine = sysSystemDefineService.selectByFacilityCd(facilityCd);


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return sysSystemDefine;
  }

  /**
   * システム設定からデフォルトメールテンプレートを取得.
   *
   * @return システム設定エンティティ
   */
  public SysSystemDefine systemselectDefaultMail() {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    SysSystemDefine sysSystemDefine = sysSystemDefineService.selectDefaultMail();
    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End

    return sysSystemDefine;
  }

  /**
   * システム設定にデータを追加.
   *
   * @param sysSystemDefine システム設定エンティティ
   * @return システム設定エンティティ
   */
  public SysSystemDefine systemInsert(SysSystemDefine sysSystemDefine) {

    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    sysSystemDefineService.insert(sysSystemDefine);

    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return sysSystemDefine;
  }

  /**
   * システム設定から該当のデータを削除.
   *
   * @param facilityCd 施設コード
   */
  public void systemDelete(String facilityCd) {
    sysSystemDefineService.delete(facilityCd);
  }

  /**
   * システム設定の該当のデータを更新.
   *
   * @param sysSystemDefine システム設定エンティティ
   * @return システム設定エンティティ
   */
  public SysSystemDefine systemUpdate(SysSystemDefine sysSystemDefine) {
    // wp アプリケーションログの適正化 Add Start
    String mappingUrl = "";
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", BEFORE_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    sysSystemDefineService.update(sysSystemDefine);


    // wp アプリケーションログの適正化 Add Start
    logEventUtils.resourceLogOutput(getClassName(), getMethodName(), "", AFTER_LOG_FLG_INFO, mappingUrl, null,
      null);
    // wp アプリケーションログの適正化 Add End
    return sysSystemDefine;
  }

  /**
   * クラス名取得
   */
  private String getClassName() {
    return this.getClass().getName();
  }

  /**
   * メソッド名取得
   */
  private String getMethodName() {
    return Thread.currentThread().getStackTrace()[2].getMethodName();
  }

}
