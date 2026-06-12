package jp.co.nikkiso.ntss.admin_web.service.linkageDefinitionCreateion;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Map.Entry;
import java.util.Optional;

import jp.co.nikkiso.ntss.admin_web.security.NtssUser;
import jp.co.nikkiso.ntss.admin_web.service.log.LogEventUtils;
import jp.co.nikkiso.ntss.admin_web.service.log.LogService;
import jp.co.nikkiso.ntss.core.constant.LoggingConstant;
import jp.co.nikkiso.ntss.core.entity.MstCoopApilink;
import jp.co.nikkiso.ntss.core.entity.MstCoopDistribute;
import jp.co.nikkiso.ntss.core.entity.MstCoopFacility;
import jp.co.nikkiso.ntss.core.entity.MstCoopFilename;
import jp.co.nikkiso.ntss.core.entity.MstCoopIni;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayout;
import jp.co.nikkiso.ntss.core.entity.MstCoopLayoutDetail;
import jp.co.nikkiso.ntss.core.entity.SysDataSet;
import jp.co.nikkiso.ntss.core.logevent.DataUpdateLogCommonNew;
import jp.co.nikkiso.ntss.core.logevent.LogServiceCore;
import jp.co.nikkiso.ntss.core.logger.EventLogMessage;
import jp.co.nikkiso.ntss.core.logger.EventLoggerFactory;
import org.seasar.doma.jdbc.Config;
import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageImpl;
import org.springframework.data.domain.Pageable;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.fasterxml.jackson.core.type.TypeReference;

import jp.co.nikkiso.ntss.admin_web.service.SelectOptionsUtils;
import jp.co.nikkiso.ntss.core.dao.MstCoopDistributeDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopFacilityDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopLayoutDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopLayoutDetailDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopFilenameDao;
import jp.co.nikkiso.ntss.core.dao.SysDataSetDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopApilinkDao;
import jp.co.nikkiso.ntss.core.dao.MstCoopIniDao;
import jp.co.nikkiso.ntss.core.entity.xml.Item;
import jp.co.nikkiso.ntss.core.entity.xml.Root;
import jp.co.nikkiso.ntss.admin_web.constant.AdminWebConstant.FlagType;
import org.springframework.util.StringUtils;

@Service
public class LinkageDefinitionCreaetionServiceImpl implements LinkageDefinitionCreationService {

  /* upd by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --start */
  // ObjectMapper objectMapper = new ObjectMapper();
  @Autowired
  private ObjectMapper objectMapper;
  /* upd by chamaojia 2026-05-06 [10959] システム内でstatic変数を使っている箇所の洗い出し --end */

  /**
   * 連携電文設定マスタDao
   */
  @Autowired
  MstCoopLayoutDao mstCoopLayoutDao;

  /**
   * 連携電文設定マスタ詳細Dao
   */
  @Autowired
  MstCoopLayoutDetailDao mstCoopLayoutDetailDao;

  /**
   * 連携配信設定マスタDao
   */
  @Autowired
  MstCoopDistributeDao mstCoopDistributeDao;

  /**
   * 連携ファイル名マスタDao
   */
  @Autowired
  MstCoopFilenameDao mstCoopFilenameDao;

  /**
   * 連携設定マスタDao
   */
  @Autowired
  MstCoopFacilityDao mstCoopFacilityDao;

  /**
   * システムデータ設定dao
   */
  @Autowired
  SysDataSetDao sysDataSetDao;

  /**
   * 連携API関連付けマスタのDao
   */
  @Autowired
  MstCoopApilinkDao mstCoopApilinkDao;

  /**
   * 連携設定マスタ
   */
  @Autowired
  private MstCoopIniDao mstCoopIniDao;

  //DB更新ログ出力ロジック wp start
  @Autowired
  private EventLoggerFactory eventLoggerFactory;

  @Autowired
  private LogServiceCore logServiceCore;
  //DB更新ログ出力ロジック wp end 20210202

  @Autowired
  private LogService logService;

  /**
   * すべてのMstCoopLayoutを選択します
   */
  @Override
  public Page<MstCoopLayout> selectAllMstCoopLayout(Pageable pageable) {
    SelectOptions selectOptions = SelectOptionsUtils.get(pageable, true);
    List<MstCoopLayout> coopLayouts = mstCoopLayoutDao.selectAllItemCoopLayout(selectOptions);
    return new PageImpl<>(coopLayouts, pageable, selectOptions.getCount());
  }

  /**
   * MstCoopLayoutをCtlNoで選択します
   */
  @Override
  public MstCoopLayout selectMstCoopLayoutByCtlNo(Long ctl_no) {
    MstCoopLayout msLayouts = mstCoopLayoutDao.selectMstCoopLayoutByCtlNo(ctl_no);
    return msLayouts;
  }

  /**
   * FacilityCd、CoopCd、CoopCdSubによってMstCoopLayoutを選択します
   */
  @Override
  public List<MstCoopLayout> selectMstCoopLayoutByFacilityCdOrCoopCdOrCoopCdSub(MstCoopLayout mstCoopLayout)
    throws Exception {
    List<MstCoopLayout> msLayouts = mstCoopLayoutDao.selectMstCoopLayoutByFacilityCdOrCoopCdOrCoopCdSub(mstCoopLayout);
    return msLayouts;
  }

  @Override
  public List<MstCoopLayout> selectSourceMstCoopLayouts(MstCoopLayout mstCoopLayout) throws Exception {
    String coopVersion = StringUtils.isEmpty(mstCoopLayout.getCoopVersion()) ? "" : mstCoopLayout.getCoopVersion();
    String coopCd = StringUtils.isEmpty(mstCoopLayout.getCoopCd()) ? "" : mstCoopLayout.getCoopCd();
    String direction = StringUtils.isEmpty(mstCoopLayout.getDirection()) ? "" : mstCoopLayout.getDirection();
    return mstCoopLayoutDao.selectSource(coopVersion, coopCd, direction);
  }

  /**
   * MstCoopLayoutをCoopNameで選択します
   */
  @Override
  public Page<MstCoopLayout> selectMstCoopLayoutByCoopName(Pageable pageable, String coop_name) {
    SelectOptions selectOptions = SelectOptionsUtils.get(pageable, true);
    List<MstCoopLayout> msLayouts = mstCoopLayoutDao.selectMstCoopLayoutByCoopName(selectOptions,
      coop_name.toUpperCase());
    return new PageImpl<>(msLayouts, pageable, selectOptions.getCount());
  }

  /**
   * 最新の連携電文レイアウトマスタの管理番号を取得.
   * @param facilityCd 施設コード
   * @return 連携電文レイアウトマスタの管理番号
   */
  public List<String> selectNewestMstCoopLayoutCtlNoByFacilityCd(String facilityCd){
    return mstCoopLayoutDao.selectNewestCtlNoByFacilityCd(facilityCd);
  }

  @Override
  public List<MstCoopLayout> selectCurrentMstCoopLayoutsByFacilityCd(String facilityCd) {
    return mstCoopLayoutDao.selectCurrentByFacilityCd(facilityCd);
  }

  /**
   * 連携電文レイアウトマスタ情報保存
   * @param mstCoopLayout 連携電文レイアウト
   * @return
   */
  @Transactional
  public boolean submitMstCoopLayout(MstCoopLayout mstCoopLayout, final Long userId){
    Boolean ret = true;

    MstCoopLayout mstCoopLayoutCheck = mstCoopLayoutDao.selectMstCoopLayoutByCtlNo(mstCoopLayout.getCtlNo());

    if (mstCoopLayoutCheck == null) {
      mstCoopLayout.setUserId(Integer.parseInt(userId.toString()));
      mstCoopLayoutDao.insertMstCoopLayout(mstCoopLayout);
    } else {
      mstCoopLayoutCheck.setFacilityCd(mstCoopLayout.getFacilityCd());
      mstCoopLayoutCheck.setCoopCd(mstCoopLayout.getCoopCd());
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
      String coopCdIndex = StringUtils.isEmpty(mstCoopLayout.getCoopCdIndex())?"":mstCoopLayout.getCoopCdIndex();
      String coopVersion = StringUtils.isEmpty(mstCoopLayout.getCoopVersion())?"":mstCoopLayout.getCoopVersion();
      mstCoopLayoutCheck.setCoopCdIndex(coopCdIndex);
      mstCoopLayoutCheck.setCoopVersion(coopVersion);
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      mstCoopLayoutCheck.setDirection(mstCoopLayout.getDirection());
      mstCoopLayoutCheck.setCoopCdSub(mstCoopLayout.getCoopCdSub());
      mstCoopLayoutCheck.setCoopFormat(mstCoopLayout.getCoopFormat());
      mstCoopLayoutCheck.setCoopName(mstCoopLayout.getCoopName());
      mstCoopLayoutCheck.setCoopVender(mstCoopLayout.getCoopVender());
      mstCoopLayoutCheck.setDescription(mstCoopLayout.getDescription());
      mstCoopLayoutCheck.setCoopSetting(mstCoopLayout.getCoopSetting());
      mstCoopLayoutCheck.setCoopExtSetting(mstCoopLayout.getCoopExtSetting());
      mstCoopLayoutCheck.setIsDel(mstCoopLayout.getIsDel());
      mstCoopLayoutCheck.setIsDisp(mstCoopLayout.getIsDisp());

      mstCoopLayoutDao.updateMstCoopLayout(mstCoopLayoutCheck);
    }

    return ret;
  }

  /**
   * すべて選択MstCoopLayoutDetail
   */
  @Override
  public Page<MstCoopLayoutDetail> selectAllMstCoopLayoutDetail(Pageable pageable) {
    SelectOptions selectOptions = SelectOptionsUtils.get(pageable, true);
    List<MstCoopLayoutDetail> coopLayoutDetailLst = mstCoopLayoutDetailDao.selectAllMstCoopLayoutDetail(selectOptions);
    return new PageImpl<>(coopLayoutDetailLst, pageable, selectOptions.getCount());
  }

  /**
   * 最新の変換レイアウト詳細マスタの管理番号を取得.
   * @param facilityCd 施設コード
   * @return 変換レイアウト詳細マスタの管理番号
   */
  public List<String> selectNewestMstCoopLayoutDetailCtlNoByFacilityCd(String facilityCd){
    return mstCoopLayoutDetailDao.selectNewestCtlNoByFacilityCd(facilityCd);
  }

  @Override
  public List<MstCoopLayoutDetail> selectCurrentMstCoopLayoutDetailsByFacilityCd(String facilityCd) {
    return mstCoopLayoutDetailDao.selectCurrentByFacilityCd(facilityCd);
  }

  /**
   * 管理番号による変換レイアウト詳細マスタ情報を取得.
   * @param ctlNo 管理番号
   * @return 変換レイアウト詳細マスタ情報
   */
  public MstCoopLayoutDetail selectMstCoopLayoutDetailByCtlNo(Long ctlNo){
    return mstCoopLayoutDetailDao.selectMstCoopLayoutDetailByCtlNo(ctlNo);
  }

  @Override
  public List<MstCoopLayoutDetail> selectSourceMstCoopLayoutDetails(MstCoopLayoutDetail mstCoopLayoutDetail) throws Exception {
    String coopVersion = StringUtils.isEmpty(mstCoopLayoutDetail.getCoopVersion()) ? "" : mstCoopLayoutDetail.getCoopVersion();
    String coopCd = StringUtils.isEmpty(mstCoopLayoutDetail.getCoopCd()) ? "" : mstCoopLayoutDetail.getCoopCd();
    String direction = StringUtils.isEmpty(mstCoopLayoutDetail.getDirection()) ? "" : mstCoopLayoutDetail.getDirection();
    return mstCoopLayoutDetailDao.selectSource(coopVersion, coopCd, direction);
  }

  /**
   * 変換レイアウト詳細マスタ情報保存
   * @param mstCoopLayoutDetail 変換レイアウト詳細
   * @return
   */
  @Transactional
  public boolean submitMstCoopLayoutDetail(MstCoopLayoutDetail mstCoopLayoutDetail, final Long userId){
    Boolean ret = true;
    MstCoopLayoutDetail mstCoopLayoutDetailCheck = mstCoopLayoutDetailDao.selectMstCoopLayoutDetailByCtlNo(mstCoopLayoutDetail.getCtlNo());

    if (mstCoopLayoutDetailCheck == null) {
      mstCoopLayoutDetail.setUserId(userId);
      mstCoopLayoutDetailDao.insertMstCoopLayoutDetail(mstCoopLayoutDetail);
    } else {
      mstCoopLayoutDetailCheck.setFacilityCd(mstCoopLayoutDetail.getFacilityCd());
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
      String coopVersion = StringUtils.isEmpty(mstCoopLayoutDetail.getCoopVersion())?"":mstCoopLayoutDetail.getCoopVersion();
      mstCoopLayoutDetailCheck.setCoopVersion(coopVersion);
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      mstCoopLayoutDetailCheck.setDirection(mstCoopLayoutDetail.getDirection());
      mstCoopLayoutDetailCheck.setCoopCdDetail(mstCoopLayoutDetail.getCoopCdDetail());
      mstCoopLayoutDetailCheck.setCoopCdDetailSub(mstCoopLayoutDetail.getCoopCdDetailSub());
      mstCoopLayoutDetailCheck.setCoopName(mstCoopLayoutDetail.getCoopName());
      mstCoopLayoutDetailCheck.setDescription(mstCoopLayoutDetail.getDescription());
      mstCoopLayoutDetailCheck.setCoopSetting(mstCoopLayoutDetail.getCoopSetting());
      mstCoopLayoutDetailCheck.setCoopExtSetting(mstCoopLayoutDetail.getCoopExtSetting());
      mstCoopLayoutDetailCheck.setIsDel(mstCoopLayoutDetail.getIsDel());
      mstCoopLayoutDetailCheck.setIsDisp(mstCoopLayoutDetail.getIsDisp());

      mstCoopLayoutDetailDao.updateMstCoopLayoutDetail(mstCoopLayoutDetailCheck);
    }

    return ret;
  }

  /**
   * 最新の連携ファイル名マスタの管理番号を取得.
   * @param facilityCd 施設コード
   * @return 連携ファイル名マスタの管理番号
   */
  public List<String> selectNewestMstCoopFilenameCtlNoByFacilityCd(String facilityCd){
    return mstCoopFilenameDao.selectNewestCtlNoByFacilityCd(facilityCd);
  }

  @Override
  public List<MstCoopFilename> selectCurrentMstCoopFilenamesByFacilityCd(String facilityCd) {
    return mstCoopFilenameDao.selectCurrentByFacilityCd(facilityCd);
  }

  /**
   * 管理番号による連携ファイル名を取得.
   * @param ctlNo 管理番号
   * @return 連携ファイル名
   */
  public MstCoopFilename selectMstCoopFilenameByCtlNo(Long ctlNo){
    return mstCoopFilenameDao.selectMstCoopFilenameByCtlNo(ctlNo);
  }

  @Override
  public List<MstCoopFilename> selectSourceMstCoopFilenames(MstCoopFilename mstCoopFilename) throws Exception {
    String coopVersion = StringUtils.isEmpty(mstCoopFilename.getCoopVersion()) ? "" : mstCoopFilename.getCoopVersion();
    String coopCd = StringUtils.isEmpty(mstCoopFilename.getCoopCd()) ? "" : mstCoopFilename.getCoopCd();
    return mstCoopFilenameDao.selectSource(coopVersion, coopCd);
  }

  /**
   * 連携ファイル名保存
   * @param mstCoopFilename 連携ファイル名
   * @return
   */
  @Transactional
  public boolean submitMstCoopFilename(MstCoopFilename mstCoopFilename, final Long userId){
    Boolean ret = true;
    MstCoopFilename mstCoopFilenameCheck = mstCoopFilenameDao.selectMstCoopFilenameByCtlNo(mstCoopFilename.getCtlNo());

    if (mstCoopFilenameCheck == null) {
      mstCoopFilename.setUserId(userId);
      mstCoopFilenameDao.insertMstCoopFilename(mstCoopFilename);
    } else {
      String coopVersion = StringUtils.isEmpty(mstCoopFilename.getCoopVersion())?"":mstCoopFilename.getCoopVersion();
      mstCoopFilenameCheck.setCoopVersion(coopVersion);
      mstCoopFilenameCheck.setPdfName(mstCoopFilename.getPdfName());
      mstCoopFilenameCheck.setDumpName(mstCoopFilename.getDumpName());
      mstCoopFilenameCheck.setCompressionName(mstCoopFilename.getCompressionName());
      mstCoopFilenameCheck.setIsDel(mstCoopFilename.getIsDel());
      mstCoopFilenameCheck.setIsDisp(mstCoopFilename.getIsDisp());

      mstCoopFilenameDao.updateMstCoopFilename(mstCoopFilenameCheck);
    }

    return ret;
  }

  /**
   * すべてのMstCoopDistributeを選択します
   */
  @Override
  public Page<MstCoopDistribute> selectALlMstCoopDistribute(Pageable pageable) {
    SelectOptions selectOptions = SelectOptionsUtils.get(pageable, true);
    List<MstCoopDistribute> coopDistributes = mstCoopDistributeDao.selectAllMstCoopDistribute(selectOptions);
    return new PageImpl<>(coopDistributes, pageable, selectOptions.getCount());
  }

  /**
   * CtlNoによってMstCoopDistributeを選択します
   */
  @Override
  public MstCoopDistribute selectMstCoopDistributeByCtlNo(Long ctlNo) {
    MstCoopDistribute coopDistribute = mstCoopDistributeDao.selectMstCoopDistributeByCtlNo(ctlNo);
    return coopDistribute;
  }

  /**
   * CtlNo、FacilityCd、coopCdによる選択
   */
  @Override
// mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  public Page<MstCoopDistribute> selectByCtlNoORFacilityCdAndcoopCd(Pageable pageable, Long ctlNo, String facilityCd,
//                                                                    String coopCd) {
  public Page<MstCoopDistribute> selectByCtlNoORFacilityCdAndcoopCd(Pageable pageable, Long ctlNo, String facilityCd,
                                                                    String coopCd, String coopVersion) {
// mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    SelectOptions selectOptions = SelectOptionsUtils.get(pageable, true);
// mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    List<MstCoopDistribute> coopDistributes = mstCoopDistributeDao.selectByCtlNoORFacilityCdAndcoopCd(selectOptions,
//      ctlNo, facilityCd, coopCd);
    List<MstCoopDistribute> coopDistributes = mstCoopDistributeDao.selectByCtlNoORFacilityCdAndcoopCd(selectOptions,
      ctlNo, facilityCd, coopCd, coopVersion);
// mod 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    return new PageImpl<>(coopDistributes, pageable, selectOptions.getCount());
  }

  /**
   * 最新の連携配信設定マスタの管理番号を取得.
   * @param facilityCd 施設コード
   * @return 連携配信設定マスタの管理番号
   */
  public List<String> selectNewestMstCoopDistributeCtlNoByFacilityCd(String facilityCd){
    return mstCoopDistributeDao.selectNewestCtlNoByFacilityCd(facilityCd);
  }

  @Override
  public List<MstCoopDistribute> selectCurrentMstCoopDistributesByFacilityCd(String facilityCd) {
    return mstCoopDistributeDao.selectCurrentByFacilityCd(facilityCd);
  }

  @Override
  public List<MstCoopDistribute> selectSourceMstCoopDistributes(MstCoopDistribute mstCoopDistribute) throws Exception {
    String coopVersion = StringUtils.isEmpty(mstCoopDistribute.getCoopVersion()) ? "" : mstCoopDistribute.getCoopVersion();
    String coopCd = StringUtils.isEmpty(mstCoopDistribute.getCoopCd()) ? "" : mstCoopDistribute.getCoopCd();
    String direction = StringUtils.isEmpty(mstCoopDistribute.getDirection()) ? "" : mstCoopDistribute.getDirection();
    return mstCoopDistributeDao.selectSource(coopVersion, coopCd, direction);
  }

  /**
   * 連携配信設定マスタ情報保存
   * @param mstCoopDistribute 連携配信設定
   * @return
   */
  @Transactional
  public boolean submitMstCoopDistribute(MstCoopDistribute mstCoopDistribute, final Long userId){
    Boolean ret = true;

    MstCoopDistribute mstCoopDistributeCheck = mstCoopDistributeDao
        .selectMstCoopDistributeByCtlNo(mstCoopDistribute.getCtlNo());

    if (mstCoopDistributeCheck == null) {
      mstCoopDistribute.setUserId(Integer.parseInt(userId.toString()));
      mstCoopDistributeDao.insertMstCoopDistribute(mstCoopDistribute);
    } else {
      mstCoopDistributeCheck.setCoopCd(mstCoopDistribute.getCoopCd());
// add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
      String coopCdIndex = StringUtils.isEmpty(mstCoopDistribute.getCoopCdIndex())?"":mstCoopDistribute.getCoopCdIndex();
      String coopVersion = StringUtils.isEmpty(mstCoopDistribute.getCoopVersion())?"":mstCoopDistribute.getCoopVersion();
      mstCoopDistributeCheck.setCoopCdIndex(coopCdIndex);
      mstCoopDistributeCheck.setCoopVersion(coopVersion);
// add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      mstCoopDistributeCheck.setDirection(mstCoopDistribute.getDirection());
      mstCoopDistributeCheck.setCoopVender(mstCoopDistribute.getCoopVender());
      mstCoopDistributeCheck.setDescription(mstCoopDistribute.getDescription());
      mstCoopDistributeCheck.setDistributeSetting(mstCoopDistribute.getDistributeSetting());
      mstCoopDistributeCheck.setIsDel(mstCoopDistribute.getIsDel());
      mstCoopDistributeCheck.setIsDisp(mstCoopDistribute.getIsDisp());

      mstCoopDistributeDao.updateMstCoopDistribute(mstCoopDistributeCheck);
    }

    return ret;
  }

  /**
   * 最新の連携設定マスタを取得.
   * @return 連携設定マスタの管理番号
   */
  public List<String> selectNewestMstCoopFacilityCtlNo(){
    return mstCoopFacilityDao.selectNewestCtlNo();
  }

  /**
   * CtlNo、FacilityCdで選択
   */
  @Override
  public Page<MstCoopFacility> selectByCtlNoOrFacilityCd(Pageable pageable, Long ctlNo, String facilityCd) {
    SelectOptions selectOptions = SelectOptionsUtils.get(pageable, true);
    List<MstCoopFacility> coopFacilitieLst = mstCoopFacilityDao.selectByCtlNoOrFacilityCd(selectOptions, ctlNo,
      facilityCd);
    return new PageImpl<>(coopFacilitieLst, pageable, selectOptions.getCount());
  }

  /**
   * 連携施設マスタ保存
   * @param MstCoopFacility
   * @return
   */
  @Override
  @Transactional
  public boolean submitMstCoopFacility(MstCoopFacility mstCoopFacility, final Long userId){
    Boolean ret = true;

    MstCoopFacility mstCoopFacilityCheck = mstCoopFacilityDao.selectMstCoopFacilityByCtlNo(mstCoopFacility.getCtlNo());
    if (mstCoopFacilityCheck == null) {
      mstCoopFacility.setUserId(userId);
      mstCoopFacility.setIsDisp(FlagType.FLAG_ON);
      mstCoopFacility.setIsDel(FlagType.FLAG_OFF);
      mstCoopFacilityDao.insert(mstCoopFacility);
    } else {
      mstCoopFacilityCheck.setDescription(mstCoopFacility.getDescription());
      mstCoopFacilityCheck.setIfEdgeSetting(mstCoopFacility.getIfEdgeSetting());
      mstCoopFacilityCheck.setCommonSetting(mstCoopFacility.getCommonSetting());
      mstCoopFacilityCheck.setIsDel(mstCoopFacility.getIsDel());
      // DB更新ログ出力ロジック
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
      LogEventUtils.setOperatorId(mstCoopFacilityCheck,logService);
      // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
      mstCoopFacilityDao.updateMstMstCoopFacility(mstCoopFacilityCheck);
    }

    return ret;
  }

  /**
   * すべてのSysDataSetを選択
   */
  @Override
  public List<SysDataSet> selectAllSysDataSet() {
    List<SysDataSet> sysDataSets = sysDataSetDao.selectAllSysDataSet();
    return sysDataSets;
  }

  /**
   * 保存
   */
  @Override
  @Transactional
  public Boolean submit(final Map<String, String> payload, final Long userId) throws Exception {
    MstCoopLayout mstCoopLayoutAfter = objectMapper.readValue(payload.get("mst_coop_layout"), MstCoopLayout.class);
    Root rootAfter = mstCoopLayoutAfter.getCoopSettingRoot();
    mstCoopLayoutAfter.setUserId(Integer.parseInt(userId.toString()));
    MstCoopFacility mstCoopFacilityAfter = objectMapper.readValue(payload.get("mst_coop_facility"),
      MstCoopFacility.class);
    MstCoopDistribute mstCoopDistributeAfter = objectMapper.readValue(payload.get("mst_coop_distribute"),
      MstCoopDistribute.class);
    List<Item> itemListAfter = rootAfter.getItemList();
    if (itemListAfter == null) {
      itemListAfter = new ArrayList<>();
    }
    List<MstCoopLayout> mstCoopLayoutsInsert = new ArrayList<>();
    List<MstCoopLayoutDetail> mstCoopLayoutDetailsInsert = new ArrayList<>();
    HashMap<String, Object> keyValueAfter = objectMapper.convertValue(mstCoopLayoutAfter.getCoopExtSetting().get("key"),
      new TypeReference<HashMap<String, Object>>() {
      });
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    // 連携版番号
    String coopVersion = StringUtils.isEmpty(mstCoopLayoutAfter.getCoopVersion())?"":mstCoopLayoutAfter.getCoopVersion();
    // 付帯情報（電文）
    String coopCdIndex = StringUtils.isEmpty(mstCoopLayoutAfter.getCoopCdIndex())?"":mstCoopLayoutAfter.getCoopCdIndex();
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    if (mstCoopLayoutAfter.getCtlNo() == null) {
      mstCoopLayoutAfter.setIsDel(FlagType.FLAG_OFF);
      mstCoopLayoutAfter.setIsDisp(FlagType.FLAG_ON);
      mstCoopLayoutDao.insertMstCoopLayout(mstCoopLayoutAfter);
      // Insert item has key mst_coop_layout
      for (Entry<String, Object> item : keyValueAfter.entrySet()) {
        Optional<Item> el = itemListAfter.stream().findFirst()
          .filter(x -> x.getKey() != null && x.getKey().equals(item.getKey()));
        if (el.isPresent()) {
          MstCoopLayout mstCoopTemp = new MstCoopLayout();
          mstCoopTemp.setFacilityCd(mstCoopLayoutAfter.getFacilityCd());
          mstCoopTemp.setCoopCd(mstCoopLayoutAfter.getCoopCd());
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
          mstCoopTemp.setCoopCdIndex(coopCdIndex);
          mstCoopTemp.setCoopVersion(coopVersion);
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          mstCoopTemp.setDirection(mstCoopLayoutAfter.getDirection());
          mstCoopTemp.setCoopCdSub(item.getKey());
          mstCoopTemp.setCoopFormat(mstCoopLayoutAfter.getCoopFormat());
          mstCoopTemp.setCoopName(mstCoopLayoutAfter.getCoopName());
          mstCoopTemp.setCoopVender(mstCoopLayoutAfter.getCoopVender());
          mstCoopTemp.setDescription(mstCoopLayoutAfter.getDescription());
          mstCoopTemp.setIsDel(FlagType.FLAG_OFF);
          mstCoopTemp.setIsDisp(FlagType.FLAG_ON);
          mstCoopLayoutDao.insertMstCoopLayout(mstCoopTemp);
        }
      }

      // insert occ Mst_coop_layout_detail
      itemListAfter.forEach(x -> {
        if (x.isOcc()) {
          MstCoopLayoutDetail mstCoopDetailItemAdd = new MstCoopLayoutDetail();
          mstCoopDetailItemAdd.setFacilityCd(mstCoopLayoutAfter.getFacilityCd());
          mstCoopDetailItemAdd.setCoopCd(mstCoopLayoutAfter.getCoopCd());
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
          mstCoopDetailItemAdd.setCoopVersion(coopVersion);
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          mstCoopDetailItemAdd.setDirection(mstCoopLayoutAfter.getDirection());
          mstCoopDetailItemAdd.setCoopCdDetail(x.getName());
          mstCoopDetailItemAdd.setCoopCdDetailSub(mstCoopLayoutAfter.getCoopCdSub());
          mstCoopDetailItemAdd.setCoopName(mstCoopLayoutAfter.getCoopName());
          mstCoopDetailItemAdd.setDescription(mstCoopLayoutAfter.getDescription());
          mstCoopDetailItemAdd.setIsDel(FlagType.FLAG_OFF);
          mstCoopDetailItemAdd.setIsDisp(FlagType.FLAG_ON);
          mstCoopLayoutDetailDao.insertMstCoopLayoutDetail(mstCoopDetailItemAdd);
        }
      });

      // insert direction
      MstCoopFacility mstCoopFacilityCheck = mstCoopFacilityDao.select(mstCoopFacilityAfter.getFacilityCd());
      if (mstCoopFacilityCheck == null) {
        mstCoopFacilityAfter.setUserId(userId);
        mstCoopFacilityAfter.setIsDisp(FlagType.FLAG_ON);
        mstCoopFacilityAfter.setIsDel(FlagType.FLAG_OFF);
        mstCoopFacilityDao.insert(mstCoopFacilityAfter);
      } else {
        mstCoopFacilityCheck.setDescription(mstCoopFacilityAfter.getDescription());
        mstCoopFacilityCheck.setIfEdgeSetting(mstCoopFacilityAfter.getIfEdgeSetting());
        mstCoopFacilityCheck.setCommonSetting(mstCoopFacilityAfter.getCommonSetting());
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        LogEventUtils.setOperatorId(mstCoopFacilityCheck,logService);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
        int ret = mstCoopFacilityDao.updateMstMstCoopFacility(mstCoopFacilityCheck);

      }

      if (mstCoopDistributeAfter.getFacilityCd() != null) {
        MstCoopDistribute mstCoopDistributeCheck = mstCoopDistributeDao
        .selectMstCoopDistributeByCtlNo(mstCoopDistributeAfter.getCtlNo());
        if (mstCoopDistributeCheck == null) {
          mstCoopDistributeAfter.setUserId(Integer.parseInt(userId.toString()));
          mstCoopDistributeAfter.setIsDel(FlagType.FLAG_OFF);
          mstCoopDistributeAfter.setIsDisp(FlagType.FLAG_ON);
          mstCoopDistributeDao.insert(mstCoopDistributeAfter);
        } else {
          mstCoopDistributeCheck.setCoopCd(mstCoopDistributeAfter.getCoopCd());
// add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
          String coopCdIndexAfter = StringUtils.isEmpty(mstCoopDistributeAfter.getCoopCdIndex())?"":mstCoopDistributeAfter.getCoopCdIndex();
          String coopVersionAfter = StringUtils.isEmpty(mstCoopDistributeAfter.getCoopVersion())?"":mstCoopDistributeAfter.getCoopVersion();
          mstCoopDistributeCheck.setCoopCdIndex(coopCdIndexAfter);
          mstCoopDistributeCheck.setCoopVersion(coopVersionAfter);
// add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          mstCoopDistributeCheck.setDirection(mstCoopDistributeAfter.getDirection());
          mstCoopDistributeCheck.setCoopVender(mstCoopDistributeAfter.getCoopVender());
          mstCoopDistributeCheck.setDescription(mstCoopDistributeAfter.getDescription());
          mstCoopDistributeCheck.setDistributeSetting(mstCoopDistributeAfter.getDistributeSetting());
          mstCoopDistributeCheck.setIsDel(FlagType.FLAG_OFF);
          mstCoopDistributeCheck.setIsDisp(FlagType.FLAG_ON);

          int ret = mstCoopDistributeDao.updateMstCoopDistribute(mstCoopDistributeCheck);
        }
      }
    } else {
      MstCoopLayout mstCoopLayoutBefore = objectMapper.readValue(payload.get("mst_coop_layout_before"),
          MstCoopLayout.class);
      Root rootBefore = mstCoopLayoutBefore.getCoopSettingRoot();
      // Insert or Update by MstCoopLayout.Direction

      MstCoopFacility mstCoopFacilityCheck = mstCoopFacilityDao.select(mstCoopLayoutBefore.getFacilityCd());
      if (mstCoopFacilityCheck == null) {
        mstCoopFacilityAfter.setUserId(userId);
        mstCoopFacilityAfter.setIsDisp(FlagType.FLAG_ON);
        mstCoopFacilityAfter.setIsDel(FlagType.FLAG_OFF);
        mstCoopFacilityDao.insert(mstCoopFacilityAfter);
      } else {
        mstCoopFacilityCheck.setDescription(mstCoopFacilityAfter.getDescription());
        mstCoopFacilityCheck.setIfEdgeSetting(mstCoopFacilityAfter.getIfEdgeSetting());
        mstCoopFacilityCheck.setCommonSetting(mstCoopFacilityAfter.getCommonSetting());
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie start
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang start
        LogEventUtils.setOperatorId(mstCoopFacilityCheck,logService);
        // #9700 イベントログに出るべきではないもの、判読不可能なログがある mod yangxuewang end
        // DB更新ログ出力ロジック Entity更新 OperatorIdとclientip設定 xie end
        int ret = mstCoopFacilityDao.updateMstMstCoopFacility(mstCoopFacilityCheck);

      }
      if (mstCoopDistributeAfter.getFacilityCd() != null) {
        MstCoopDistribute mstCoopDistributeCheck = mstCoopDistributeDao
            .selectMstCoopDistributeByCtlNo(mstCoopDistributeAfter.getCtlNo());
        if (mstCoopDistributeCheck == null) {
          mstCoopDistributeAfter.setUserId(Integer.parseInt(userId.toString()));
          mstCoopDistributeAfter.setIsDel(FlagType.FLAG_OFF);
          mstCoopDistributeAfter.setIsDisp(FlagType.FLAG_ON);
          mstCoopDistributeDao.insert(mstCoopDistributeAfter);
        } else {
          mstCoopDistributeCheck.setCoopCd(mstCoopDistributeAfter.getCoopCd());
// add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
          String coopCdIndexAfter = StringUtils.isEmpty(mstCoopDistributeAfter.getCoopCdIndex())?"":mstCoopDistributeAfter.getCoopCdIndex();
          String coopVersionAfter = StringUtils.isEmpty(mstCoopDistributeAfter.getCoopVersion())?"":mstCoopDistributeAfter.getCoopVersion();
          mstCoopDistributeCheck.setCoopCdIndex(coopCdIndexAfter);
          mstCoopDistributeCheck.setCoopVersion(coopVersionAfter);
// add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          mstCoopDistributeCheck.setDirection(mstCoopDistributeAfter.getDirection());
          mstCoopDistributeCheck.setCoopVender(mstCoopDistributeAfter.getCoopVender());
          mstCoopDistributeCheck.setDescription(mstCoopDistributeAfter.getDescription());
          mstCoopDistributeCheck.setDistributeSetting(mstCoopDistributeAfter.getDistributeSetting());
          mstCoopDistributeCheck.setIsDel(FlagType.FLAG_OFF);
          mstCoopDistributeCheck.setIsDisp(FlagType.FLAG_ON);

          int ret = mstCoopDistributeDao.updateMstCoopDistribute(mstCoopDistributeCheck);
        }
      }

      if (mstCoopLayoutBefore.getCoopExtSetting() != null) {
        HashMap<String, Object> keyValueBefore = objectMapper.convertValue(
          mstCoopLayoutBefore.getCoopExtSetting().get("key"), new TypeReference<HashMap<String, Object>>() {
          });
        if (keyValueBefore != null && keyValueBefore.size() > 0) {
          keyValueBefore.forEach((k, v) -> {
            // TODO: mst_coop_layoutの拡張に対応する必要がある
            //
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//            MstCoopLayout mstCoopLayoutsCheck = mstCoopLayoutDao.select(mstCoopLayoutBefore.getFacilityCd(),
//              mstCoopLayoutBefore.getCoopCd(), "", mstCoopLayoutBefore.getDirection(), k);
            MstCoopLayout mstCoopLayoutsCheck = mstCoopLayoutDao.select(mstCoopLayoutBefore.getFacilityCd(),
              mstCoopLayoutBefore.getCoopCd(), "", coopVersion, mstCoopLayoutBefore.getDirection(), k);
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
            if (mstCoopLayoutsCheck != null) {
              if (keyValueAfter.containsKey(k) == false) {
                // REMOVE mstCoopLayoutsCheck
                if (mstCoopLayoutsCheck != null) {
                  mstCoopLayoutsCheck.setIsDisp(FlagType.FLAG_OFF);
                  mstCoopLayoutsCheck.setIsDel(FlagType.FLAG_ON);

                  int ret = mstCoopLayoutDao.updateMstCoopLayout(mstCoopLayoutsCheck);


                }
              } else {
                // Update mstCoopLayoutsCheck
                MstCoopLayout mstCoopLayoutItemUpdate = mstCoopLayoutsCheck;
                mstCoopLayoutItemUpdate.setFacilityCd(mstCoopLayoutAfter.getFacilityCd());
                mstCoopLayoutItemUpdate.setCoopCd(mstCoopLayoutAfter.getCoopCd());
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
                mstCoopLayoutItemUpdate.setCoopCdIndex(coopCdIndex);
                mstCoopLayoutItemUpdate.setCoopVersion(coopVersion);
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
                mstCoopLayoutItemUpdate.setDirection(mstCoopLayoutAfter.getDirection());
                mstCoopLayoutItemUpdate.setCoopCdSub(k);
                mstCoopLayoutItemUpdate.setCoopFormat(mstCoopLayoutAfter.getCoopFormat());
                mstCoopLayoutItemUpdate.setCoopName(mstCoopLayoutAfter.getCoopName());
                mstCoopLayoutItemUpdate.setCoopVender(mstCoopLayoutAfter.getCoopVender());
                mstCoopLayoutItemUpdate.setDescription(mstCoopLayoutAfter.getDescription());
                mstCoopLayoutItemUpdate.setIsDel(FlagType.FLAG_OFF);
                mstCoopLayoutItemUpdate.setIsDisp(FlagType.FLAG_ON);

                int ret = mstCoopLayoutDao.updateMstCoopLayout(mstCoopLayoutItemUpdate);

              }
            }
          });
        }
        // Add MstCoopLayout
        if (keyValueAfter != null && keyValueAfter.size() > 0) {
          keyValueAfter.forEach((k, v) -> {
            if (keyValueBefore.containsKey(k) == false) {
              MstCoopLayout mstCoopLayoutItemAdd = new MstCoopLayout();
              mstCoopLayoutItemAdd.setFacilityCd(mstCoopLayoutAfter.getFacilityCd());
              mstCoopLayoutItemAdd.setCoopCd(mstCoopLayoutAfter.getCoopCd());
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
              mstCoopLayoutItemAdd.setCoopCdIndex(coopCdIndex);
              mstCoopLayoutItemAdd.setCoopVersion(coopVersion);
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
              mstCoopLayoutItemAdd.setDirection(mstCoopLayoutAfter.getDirection());
              mstCoopLayoutItemAdd.setCoopCdSub(k);
              mstCoopLayoutItemAdd.setCoopFormat(mstCoopLayoutAfter.getCoopFormat());
              mstCoopLayoutItemAdd.setCoopName(mstCoopLayoutAfter.getCoopName());
              mstCoopLayoutItemAdd.setCoopVender(mstCoopLayoutAfter.getCoopVender());
              mstCoopLayoutItemAdd.setDescription(mstCoopLayoutAfter.getDescription());
              mstCoopLayoutItemAdd.setIsDel(FlagType.FLAG_OFF);
              mstCoopLayoutItemAdd.setIsDisp(FlagType.FLAG_ON);
              mstCoopLayoutDao.insertMstCoopLayout(mstCoopLayoutItemAdd);
            }
          });
        }
      }
      if (itemListAfter != null && itemListAfter.size() > 0) {
        itemListAfter.forEach(x -> {
          if (x.isOcc()) {
            // Check existed item on table mst_coop_layout_detail
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//            MstCoopLayoutDetail mstCoopLayoutDetailsCheck = mstCoopLayoutDetailDao.select(
//              mstCoopLayoutBefore.getFacilityCd(), mstCoopLayoutBefore.getCoopCd(),
//              mstCoopLayoutBefore.getDirection(), x.getName(), mstCoopLayoutBefore.getCoopCdSub());
            MstCoopLayoutDetail mstCoopLayoutDetailsCheck = mstCoopLayoutDetailDao.select(
              mstCoopLayoutBefore.getFacilityCd(), mstCoopLayoutBefore.getCoopCd(), coopVersion,
              mstCoopLayoutBefore.getDirection(), x.getName(), mstCoopLayoutBefore.getCoopCdSub());
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
            if (mstCoopLayoutDetailsCheck != null) {
              // Update mstCoopLayoutDetailsCheck
              mstCoopLayoutDetailsCheck.setFacilityCd(mstCoopLayoutAfter.getFacilityCd());
              mstCoopLayoutDetailsCheck.setCoopCd(mstCoopLayoutAfter.getCoopCd());
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
              mstCoopLayoutDetailsCheck.setCoopVersion(coopVersion);
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
              mstCoopLayoutDetailsCheck.setDirection(mstCoopLayoutAfter.getDirection());
              mstCoopLayoutDetailsCheck.setCoopCdDetail(x.getName());
              mstCoopLayoutDetailsCheck.setCoopCdDetailSub(mstCoopLayoutAfter.getCoopCdSub());
              mstCoopLayoutDetailsCheck.setCoopName(mstCoopLayoutAfter.getCoopName());
              mstCoopLayoutDetailsCheck.setDescription(mstCoopLayoutAfter.getDescription());
              mstCoopLayoutDetailsCheck.setIsDel(FlagType.FLAG_OFF);
              mstCoopLayoutDetailsCheck.setIsDisp(FlagType.FLAG_ON);


              int ret = mstCoopLayoutDetailDao.updateMstCoopLayoutDetail(mstCoopLayoutDetailsCheck);


            } else {
              // Add
              MstCoopLayoutDetail mstCoopLayoutDetailItemAdd = new MstCoopLayoutDetail();
              mstCoopLayoutDetailItemAdd.setFacilityCd(mstCoopLayoutAfter.getFacilityCd());
              mstCoopLayoutDetailItemAdd.setCoopCd(mstCoopLayoutAfter.getCoopCd());
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
              mstCoopLayoutDetailItemAdd.setCoopVersion(coopVersion);
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
              mstCoopLayoutDetailItemAdd.setDirection(mstCoopLayoutAfter.getDirection());
              mstCoopLayoutDetailItemAdd.setCoopCdDetail(x.getName());
              mstCoopLayoutDetailItemAdd.setCoopCdDetailSub(mstCoopLayoutAfter.getCoopCdSub());
              mstCoopLayoutDetailItemAdd.setCoopName(mstCoopLayoutAfter.getCoopName());
              mstCoopLayoutDetailItemAdd.setDescription(mstCoopLayoutAfter.getDescription());
              mstCoopLayoutDetailItemAdd.setIsDel(FlagType.FLAG_OFF);
              mstCoopLayoutDetailItemAdd.setIsDisp(FlagType.FLAG_ON);
              mstCoopLayoutDetailDao.insertMstCoopLayoutDetail(mstCoopLayoutDetailItemAdd);
            }
          }
        });
      }
      // Update mstCoopLayoutAfter
      mstCoopLayoutAfter.setIsDel(FlagType.FLAG_OFF);
      mstCoopLayoutAfter.setIsDisp(FlagType.FLAG_ON);


      int ret = mstCoopLayoutDao.updateMstCoopLayout(mstCoopLayoutAfter);

    }
    return true;
  }

  /**
   * Occを保存する
   */
  @Override
  @Transactional
  public Boolean submitOcc(final Map<String, String> payload, final Long userId) throws Exception {
    MstCoopLayoutDetail mstCoopLayoutDetailAfter = objectMapper.readValue(payload.get("mst_coop_layout_detail"),
      MstCoopLayoutDetail.class);
    MstCoopLayoutDetail mstCoopLayoutDetailBefore = objectMapper.readValue(payload.get("mst_coop_layout_detail_before"),
      MstCoopLayoutDetail.class);
    MstCoopLayout mstCoopLayoutBefore = objectMapper.readValue(payload.get("mst_coop_layout_before"),
      MstCoopLayout.class);
    MstCoopFacility mstCoopFacilityAfter = objectMapper.readValue(payload.get("mst_coop_facility"),
      MstCoopFacility.class);
    MstCoopDistribute mstCoopDistributeAfter = objectMapper.readValue(payload.get("mst_coop_distribute"),
      MstCoopDistribute.class);
    HashMap<String, Object> keyValueAfter = objectMapper.convertValue(
      mstCoopLayoutDetailAfter.getCoopExtSetting().get("key"), new TypeReference<HashMap<String, Object>>() {
      });
    List<Item> itemListAfter = mstCoopLayoutDetailAfter.getCoopSettingRoot().getItemList();

    MstCoopFacility mstCoopFacilityCheck = mstCoopFacilityDao.select(mstCoopLayoutDetailBefore.getFacilityCd());
    if (mstCoopFacilityCheck == null) {
      mstCoopFacilityAfter.setUserId(userId);
      mstCoopFacilityAfter.setIsDisp(FlagType.FLAG_ON);
      mstCoopFacilityAfter.setIsDel(FlagType.FLAG_OFF);
      mstCoopFacilityDao.insert(mstCoopFacilityAfter);
    } else {
      mstCoopFacilityCheck.setDescription(mstCoopFacilityAfter.getDescription());
      mstCoopFacilityCheck.setIfEdgeSetting(mstCoopFacilityAfter.getIfEdgeSetting());
      mstCoopFacilityCheck.setCommonSetting(mstCoopFacilityAfter.getCommonSetting());

      int ret = mstCoopFacilityDao.updateMstMstCoopFacility(mstCoopFacilityCheck);

    }
    if (mstCoopDistributeAfter.getFacilityCd() != null) {
        MstCoopDistribute mstCoopDistributeCheck = mstCoopDistributeDao
            .selectMstCoopDistributeByCtlNo(mstCoopDistributeAfter.getCtlNo());
        if (mstCoopDistributeCheck == null) {
          mstCoopDistributeAfter.setUserId(Integer.parseInt(userId.toString()));
          mstCoopDistributeAfter.setIsDel(FlagType.FLAG_OFF);
          mstCoopDistributeAfter.setIsDisp(FlagType.FLAG_ON);
          mstCoopDistributeDao.insert(mstCoopDistributeAfter);
        } else {
          mstCoopDistributeCheck.setCoopCd(mstCoopDistributeAfter.getCoopCd());
// add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
          String coopCdIndexAfter = StringUtils.isEmpty(mstCoopDistributeAfter.getCoopCdIndex())?"":mstCoopDistributeAfter.getCoopCdIndex();
          String coopVersionAfter = StringUtils.isEmpty(mstCoopDistributeAfter.getCoopVersion())?"":mstCoopDistributeAfter.getCoopVersion();
          mstCoopDistributeCheck.setCoopCdIndex(coopCdIndexAfter);
          mstCoopDistributeCheck.setCoopVersion(coopVersionAfter);
// add 2022-12-30 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          mstCoopDistributeCheck.setDirection(mstCoopDistributeAfter.getDirection());
          mstCoopDistributeCheck.setCoopVender(mstCoopDistributeAfter.getCoopVender());
          mstCoopDistributeCheck.setDescription(mstCoopDistributeAfter.getDescription());
          mstCoopDistributeCheck.setDistributeSetting(mstCoopDistributeAfter.getDistributeSetting());
          mstCoopDistributeCheck.setIsDel(FlagType.FLAG_OFF);
          mstCoopDistributeCheck.setIsDisp(FlagType.FLAG_ON);

          int ret = mstCoopDistributeDao.updateMstCoopDistribute(mstCoopDistributeCheck);
        }
      }

    if (mstCoopLayoutDetailBefore.getCoopExtSetting() != null) {
      HashMap<String, Object> keyValueBefore = objectMapper.convertValue(
        mstCoopLayoutDetailBefore.getCoopExtSetting().get("key"), new TypeReference<HashMap<String, Object>>() {
        });
      if (keyValueBefore != null && keyValueBefore.size() > 0) {
        keyValueBefore.forEach((k, v) -> {
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//          MstCoopLayoutDetail mstCoopLayoutDetailCheck = mstCoopLayoutDetailDao.selectMstCoopLayoutDetail(
//            mstCoopLayoutDetailBefore.getFacilityCd(), mstCoopLayoutDetailBefore.getCoopCd(),
//            mstCoopLayoutDetailBefore.getDirection(), mstCoopLayoutDetailBefore.getCoopCdDetail(), k);
          String coopVersionBefore = StringUtils.isEmpty(mstCoopLayoutDetailBefore.getCoopVersion())?"":mstCoopLayoutDetailBefore.getCoopVersion();
          MstCoopLayoutDetail mstCoopLayoutDetailCheck = mstCoopLayoutDetailDao.selectMstCoopLayoutDetail(
            mstCoopLayoutDetailBefore.getFacilityCd(), mstCoopLayoutDetailBefore.getCoopCd(), coopVersionBefore,
            mstCoopLayoutDetailBefore.getDirection(), mstCoopLayoutDetailBefore.getCoopCdDetail(), k);
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

          if (mstCoopLayoutDetailCheck != null) {
            if (keyValueAfter.containsKey(k) == false) {
              // REMOVE mstCoopLayoutDetailCheck
              if (mstCoopLayoutDetailCheck != null) {
                mstCoopLayoutDetailCheck.setIsDisp(FlagType.FLAG_OFF);
                mstCoopLayoutDetailCheck.setIsDel(FlagType.FLAG_ON);



                int ret = mstCoopLayoutDetailDao.updateMstCoopLayoutDetail(mstCoopLayoutDetailCheck);

              }
            }
          }
        });
      }
      // Add MstCoopLayoutDetail
      if (keyValueAfter != null && keyValueAfter.size() > 0) {
        keyValueAfter.forEach((k, v) -> {
          if (keyValueBefore.containsKey(k) == false) {
            MstCoopLayoutDetail mstCoopLayoutDetailItemAdd = new MstCoopLayoutDetail();
            mstCoopLayoutDetailItemAdd.setFacilityCd(mstCoopLayoutDetailAfter.getFacilityCd());
            mstCoopLayoutDetailItemAdd.setCoopCd(mstCoopLayoutDetailAfter.getCoopCd());
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
            String coopVersionAfter = StringUtils.isEmpty(mstCoopLayoutDetailAfter.getCoopVersion())?"":mstCoopLayoutDetailAfter.getCoopVersion();
            mstCoopLayoutDetailItemAdd.setCoopVersion(coopVersionAfter);
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
            mstCoopLayoutDetailItemAdd.setDirection(mstCoopLayoutDetailAfter.getDirection());
            mstCoopLayoutDetailItemAdd.setCoopCdDetail(mstCoopLayoutDetailAfter.getCoopCdDetail());
            mstCoopLayoutDetailItemAdd.setCoopCdDetailSub(k);
            mstCoopLayoutDetailItemAdd.setCoopName(mstCoopLayoutDetailAfter.getCoopName());
            mstCoopLayoutDetailItemAdd.setDescription(mstCoopLayoutDetailAfter.getDescription());
            mstCoopLayoutDetailItemAdd.setIsDel(FlagType.FLAG_OFF);
            mstCoopLayoutDetailItemAdd.setIsDisp(FlagType.FLAG_ON);
            mstCoopLayoutDetailDao.insertMstCoopLayoutDetail(mstCoopLayoutDetailItemAdd);
          }
        });
      }
    }
    if (itemListAfter != null && itemListAfter.size() > 0) {
      itemListAfter.forEach(x -> {
        // Check existed item on table mst_coop_layout_detail
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//        MstCoopLayoutDetail mstCoopLayoutDetailsCheck = mstCoopLayoutDetailDao.select(
//          mstCoopLayoutBefore.getFacilityCd(), mstCoopLayoutBefore.getCoopCd(), mstCoopLayoutBefore.getDirection(),
//          x.getName(), mstCoopLayoutBefore.getCoopCdSub());
        String coopVersionBefore = StringUtils.isEmpty(mstCoopLayoutBefore.getCoopVersion())?"":mstCoopLayoutBefore.getCoopVersion();
        MstCoopLayoutDetail mstCoopLayoutDetailsCheck = mstCoopLayoutDetailDao.select(
          mstCoopLayoutBefore.getFacilityCd(), mstCoopLayoutBefore.getCoopCd(), coopVersionBefore,
          mstCoopLayoutBefore.getDirection(), x.getName(), mstCoopLayoutBefore.getCoopCdSub());
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
        if (mstCoopLayoutDetailsCheck != null) {
          // Update mstCoopLayoutDetailsCheck
          mstCoopLayoutDetailsCheck.setFacilityCd(mstCoopLayoutDetailAfter.getFacilityCd());
          mstCoopLayoutDetailsCheck.setCoopCd(mstCoopLayoutDetailAfter.getCoopCd());
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
          String coopVersionAfter = StringUtils.isEmpty(mstCoopLayoutDetailAfter.getCoopVersion())?"":mstCoopLayoutDetailAfter.getCoopVersion();
          mstCoopLayoutDetailsCheck.setCoopVersion(coopVersionAfter);
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          mstCoopLayoutDetailsCheck.setDirection(mstCoopLayoutDetailAfter.getDirection());
          mstCoopLayoutDetailsCheck.setCoopSetting(mstCoopLayoutDetailAfter.getCoopSetting());
          mstCoopLayoutDetailsCheck.setCoopName(mstCoopLayoutDetailAfter.getCoopName());
          mstCoopLayoutDetailsCheck.setDescription(mstCoopLayoutDetailAfter.getDescription());
          mstCoopLayoutDetailsCheck.setCoopExtSetting(mstCoopLayoutDetailAfter.getCoopExtSetting());
          mstCoopLayoutDetailsCheck.setIsDel(FlagType.FLAG_OFF);
          mstCoopLayoutDetailsCheck.setIsDisp(FlagType.FLAG_ON);


          int ret = mstCoopLayoutDetailDao.updateMstCoopLayoutDetail(mstCoopLayoutDetailsCheck);

        } else {
          // Add
          MstCoopLayoutDetail mstCoopLayoutDetailItemAdd = new MstCoopLayoutDetail();
          mstCoopLayoutDetailItemAdd.setFacilityCd(mstCoopLayoutDetailAfter.getFacilityCd());
          mstCoopLayoutDetailItemAdd.setCoopCd(mstCoopLayoutDetailAfter.getCoopCd());
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
          String coopVersionAfter = StringUtils.isEmpty(mstCoopLayoutDetailAfter.getCoopVersion())?"":mstCoopLayoutDetailAfter.getCoopVersion();
          mstCoopLayoutDetailItemAdd.setCoopVersion(coopVersionAfter);
// add 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
          mstCoopLayoutDetailItemAdd.setDirection(mstCoopLayoutDetailAfter.getDirection());
          mstCoopLayoutDetailItemAdd.setCoopCdDetail(x.getName());
          mstCoopLayoutDetailItemAdd.setCoopCdDetailSub(mstCoopLayoutBefore.getCoopCdSub());
          mstCoopLayoutDetailItemAdd.setCoopName(mstCoopLayoutDetailAfter.getCoopName());
          mstCoopLayoutDetailItemAdd.setDescription(mstCoopLayoutDetailAfter.getDescription());
          mstCoopLayoutDetailItemAdd.setIsDel(FlagType.FLAG_OFF);
          mstCoopLayoutDetailItemAdd.setIsDisp(FlagType.FLAG_ON);
          mstCoopLayoutDetailDao.insertMstCoopLayoutDetail(mstCoopLayoutDetailItemAdd);
        }
      });
    }
    mstCoopLayoutDetailAfter.setIsDel(FlagType.FLAG_OFF);
    mstCoopLayoutDetailAfter.setIsDisp(FlagType.FLAG_ON);


    int ret = mstCoopLayoutDetailDao.updateMstCoopLayoutDetail(mstCoopLayoutDetailAfter);

    return true;
  }

  /**
   * 連携電文設定マスタ詳細を取得する
   */
  public MstCoopLayoutDetail selectMstCoopLayoutDetail(Map<String, String> payload) throws Exception {
    String facilityCd = payload.get("facilityCd");
    String coopCd = payload.get("coopCd");
    String direction = payload.get("direction");
    String coopCdDetail = payload.get("coopCdDetail");
    String coopDetailSub = payload.get("coopDetailSub");
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//    return mstCoopLayoutDetailDao.selectMstCoopLayoutDetail(facilityCd, coopCd, direction, coopCdDetail, coopDetailSub);
    String coopVersion = StringUtils.isEmpty(payload.get("coopVersion"))?"":payload.get("coopVersion");
    return mstCoopLayoutDetailDao.selectMstCoopLayoutDetail(facilityCd, coopCd, coopVersion, direction, coopCdDetail, coopDetailSub);
// mod 2022-12-26 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
  }

  //FNSI-修正 ログ対応 wp add start

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


  //FNSI-修正 ログ対応 wp add end

  /**
   * 連携API関連付けマスタEntityを取得する
   * @param facilityCd 施設コード
   * @return 連携API関連付けマスタEntity
   */
  public List<MstCoopApilink> selectMstCoopApilinksByFacility(String facilityCd) throws Exception{
    return mstCoopApilinkDao.selectByFacility(facilityCd);
  }

  @Override
  public List<MstCoopApilink> selectSourceMstCoopApilinks(MstCoopApilink mstCoopApilink) throws Exception{
    String coopVersion = StringUtils.isEmpty(mstCoopApilink.getCoopVersion()) ? "" : mstCoopApilink.getCoopVersion();
    String coopCd = StringUtils.isEmpty(mstCoopApilink.getCoopCd()) ? "" : mstCoopApilink.getCoopCd();
    return mstCoopApilinkDao.selectSource(coopVersion, coopCd);
  }

  /**
   * 連携API関連付けマスタEntityを保存する
   * @param mstCoopApilink 連携API関連付けマスタEntity
   */
  @Override
  @Transactional
  public Boolean submitMstCoopApilink(MstCoopApilink mstCoopApilink, Long userId) throws Exception{
    MstCoopApilink mstCoopApilinkCheck = mstCoopApilinkDao.selectByCtlNo(mstCoopApilink.getCtlNo());
    Boolean ret = true;
// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
    String coopVersion = StringUtils.isEmpty(mstCoopApilink.getCoopVersion())?"":mstCoopApilink.getCoopVersion();
    String isDel = StringUtils.isEmpty(mstCoopApilink.getIsDel()) ? FlagType.FLAG_OFF : mstCoopApilink.getIsDel();
// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    if (mstCoopApilinkCheck == null) {
      mstCoopApilink.setUserId(userId.toString());
      mstCoopApilink.setIsDel(isDel);
      mstCoopApilinkDao.insert(mstCoopApilink);
    } else {
// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
      mstCoopApilinkCheck.setCoopVersion(coopVersion);
// add 2023-01-04 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
      mstCoopApilinkCheck.setApiUri(mstCoopApilink.getApiUri());
      mstCoopApilinkCheck.setApiMethod(mstCoopApilink.getApiMethod());
      mstCoopApilinkCheck.setApiBody(mstCoopApilink.getApiBody());
      mstCoopApilinkCheck.setContinueApiStatus(mstCoopApilink.getContinueApiStatus());
      mstCoopApilinkCheck.setAfterApiStatus(mstCoopApilink.getAfterApiStatus());
      mstCoopApilinkCheck.setApiType(mstCoopApilink.getApiType());
      mstCoopApilinkCheck.setSqlSetting(mstCoopApilink.getSqlSetting());
      mstCoopApilinkCheck.setIsDel(isDel);

      mstCoopApilinkDao.update(mstCoopApilinkCheck);
    }

    return ret;
  }

  /**
   * 連携設定マスタを取得.
   * @param facilityCd 施設コード
   * @return 連携エッジマスタ情報
   */
  @Override
  public List<MstCoopIni> selectMstCoopIniByFacilityCd(String facilityCd){
    return mstCoopIniDao.selectByFacilityCd(facilityCd);
  }

  /**
   * 連携設定マスタ保存
   * @param MstCoopIni
   * @return
   */
  @Override
  @Transactional
  public boolean submitMstCoopIni(MstCoopIni mstCoopIni){
    Boolean ret = true;

    MstCoopIni mstCoopIniCheck = mstCoopIniDao.selectByCoopIniCd(mstCoopIni.getCoopIniCd());
    if (mstCoopIniCheck == null) {
      mstCoopIniDao.insert(mstCoopIni);
    }
    else {
      mstCoopIniDao.update(mstCoopIni);
    }

    return ret;
  }

  /**
   * アンインストール連携
   * @param facilityCd
   * @return
   * @throws Exception
   */
  @Override
  @Transactional
  public Boolean UninstallCoop(String facilityCd) throws Exception{
    Boolean ret = true;

    mstCoopDistributeDao.deleteByFacilityCd(facilityCd);
    mstCoopLayoutDao.deleteByFacilityCd(facilityCd);
    mstCoopLayoutDetailDao.deleteByFacilityCd(facilityCd);
    mstCoopApilinkDao.deleteByFacilityCd(facilityCd);
    mstCoopFacilityDao.deleteByFacilityCd(facilityCd);

    return ret;
  }
}
