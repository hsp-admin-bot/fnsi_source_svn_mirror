package jp.co.nikkiso.ntss.admin_web.service.exam;

import jp.co.nikkiso.ntss.core.entity.PatMain;

public interface ExamRecordNotificationService {

  public void registerInfectionNotification(PatMain oldPatMain, PatMain newPatMain);
}
