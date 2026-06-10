package jp.co.nikkiso.ntss.admin_web.service.sysReleaseInfo;

import java.util.List;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.io.File;
import java.io.FileInputStream;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.core.dao.SysReleaseInfoDao;
import jp.co.nikkiso.ntss.core.entity.SysReleaseInfo;

@Service
public class SysReleaseInfoServiceImpl implements SysReleaseInfoService {
  
  /**
   * リリース情報のDaoインタフェース.
   */
  @Autowired
  SysReleaseInfoDao sysReleaseInfoDao;

  /**
   * リリース一覧情報取得
   */
  @Override
  public List<SysReleaseInfo> getSysReleaseInfoAll() {
    return sysReleaseInfoDao.selectAll();
  }

  /**
   * リリース明細情報取得
   */

  @Override
  public String getReleaseDetail(Long ctl_no) throws Exception{
    BufferedReader bufferedReader = null;
    // レスポンス用データ生成
    try{
        String selectPath = sysReleaseInfoDao.selectPath(ctl_no);
        if (StringUtils.isEmpty(selectPath)) {
          // ファイル指定無し
          return "";
        }
        //稼働サーバー内ファイル取得
        File file = new File(selectPath);
        if (!file.exists()) {
          // 対象ファイル無し：出力無し
            return "";
        }
        bufferedReader = new BufferedReader(new InputStreamReader(new FileInputStream(file),"UTF-8"));
        // 文字列に変換
        StringBuilder sb = new StringBuilder();
        String line;
        while((line = bufferedReader.readLine()) != null) {
            sb.append(line);
        }
        bufferedReader.close();
        return sb.toString();
    } catch (Exception e) {
      if (bufferedReader != null) {
        bufferedReader.close();
      }
      throw e;
    }
  }
}
