package jp.co.nikkiso.ntss.device_edge_updater.service.version;

import java.util.List;

import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import jp.co.nikkiso.ntss.core.dao.MntDeviceEdgeStateDao;
import jp.co.nikkiso.ntss.core.entity.MntDeviceEdgeState;

@Service
public class VersionServiceImpl implements VersionService {

  @Autowired
  MntDeviceEdgeStateDao mntDeviceEdgeStateDao;

  @Override
  @Transactional
  public int saveDeviceEdgeVersion(String facilityCd, int deviceEdgeNo, String versionText) {

    String[] versionTexts = versionText.split("<LF>");
    JSONObject json = new JSONObject();
    for (String line : versionTexts) {
      int idx = line.toLowerCase().indexOf(".exe");
      if (idx < 0) {
        // ～～.exe の情報が含まれている行ではない
        continue;
      }
      String appName = line.substring(0, idx + 4);
      if (appName.startsWith("・")) {
        // 先頭の・を除去
        appName = appName.substring(1);
      }
      String version = line.substring(idx + 4).trim();
      json.put(appName, version);
    }

    List<MntDeviceEdgeState> stateList = mntDeviceEdgeStateDao.selectByFacilityDeviceEdgeNo(facilityCd, deviceEdgeNo);
    if (stateList.size() > 0) {
      MntDeviceEdgeState state = stateList.get(0);
      state.setVersionInformation(json.toString());
      return mntDeviceEdgeStateDao.update(state);
    }
    return 0;
  }

}
