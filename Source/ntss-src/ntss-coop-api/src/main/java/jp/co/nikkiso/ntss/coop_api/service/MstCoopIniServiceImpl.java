package jp.co.nikkiso.ntss.coop_api.service;

import jp.co.nikkiso.ntss.core.dao.MstCoopIniDao;
import jp.co.nikkiso.ntss.core.entity.custom.MstCoopIniInfo;
import jp.co.nikkiso.ntss.core.exception.NtssException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

@Service
public class MstCoopIniServiceImpl implements MstCoopIniService {
  @Autowired
  private MstCoopIniDao mstCoopIniDao;

// del 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  @Override
//  public Boolean validateCoopByFacilityCd(String coopIniMemo, String facilityCd) {
//    List<MstCoopIni> mstCoopIniList = mstCoopIniDao.selectByFacilityCd(facilityCd);
//    if (CollectionUtils.isEmpty(mstCoopIniList)) {
//      throw new NtssException("連携設定マスタが見つかりません");
//    }
//
//    return coopIniMemo.equals(mstCoopIniList.get(0).getCoopIniMemo());
//
//  }
// del 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end

  @Override
  public String getEffectValue(MstCoopIniInfo mstCoopIniInfo) {
    String defaultV = StringUtils.isEmpty(mstCoopIniInfo.getDefaultV()) ? "" : mstCoopIniInfo.getDefaultV();
    String value = StringUtils.isEmpty(mstCoopIniInfo.getVal()) ? "" : mstCoopIniInfo.getVal();
    if ("1".equals(mstCoopIniInfo.getIsEffect())) {
      if ("".equals(value)) {
        return defaultV;
      } else {
        return value;
      }
    }
    return defaultV;

  }

  @Override
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 start
//  public MstCoopIniInfo getCoopIniInfo(String facilityCd, String key1, String key2) {
//    MstCoopIniInfo mstCoopIniInfo = mstCoopIniDao.selectCoopIniInfo(facilityCd, key1, key2);
  public MstCoopIniInfo getCoopIniInfo(String facilityCd, String key0, String key1, String key2) {
    MstCoopIniInfo mstCoopIniInfo = mstCoopIniDao.selectCoopIniInfo(facilityCd, key0, key1, key2);
// mod 2023-01-10 bug #7304 異なる連携の機能を組み合わせて使用する方法 孫 end
    if (mstCoopIniInfo == null) {
      throw new NtssException("連携設定マスタ MstCoopIniInfo 連携設定情報が存在しません。 "
        + "facility_cd:[" + facilityCd + "], "
        + "key0:[" + key0 + "], "
        + "key1:[" + key1 + "], "
        + "key2:[" + key2 + "]");
    }

    if (null == mstCoopIniInfo.getIsEffect() ||
      (null != mstCoopIniInfo.getIsEffect() && ("0".equals(mstCoopIniInfo.getIsEffect())) || "".equals(mstCoopIniInfo.getIsEffect()))) {
      throw new NtssException("連携設定マスタ MstCoopIniInfo 。有効ではありません "
        + "facility_cd:[" + facilityCd + "], "
        + "key0:[" + key0 + "], "
        + "key1:[" + key1 + "], "
        + "key2:[" + key2 + "]");
    }
    return mstCoopIniInfo;
  }
}
