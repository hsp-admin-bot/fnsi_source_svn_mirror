package jp.co.nikkiso.ntss.certificate_management.service;

import static java.util.Collections.emptyList;

import java.sql.Timestamp;
import java.util.Comparator;
import java.util.List;

import org.seasar.doma.jdbc.SelectOptions;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.util.StringUtils;

import jp.co.nikkiso.ntss.certificate_management.response.clUser.ResponseClUserSetting;
import jp.co.nikkiso.ntss.core.dao.ClUserDao;
import jp.co.nikkiso.ntss.core.entity.ClUser;

@Service
public class ClUserServiceImpl implements ClUserService {

    @Autowired
    private PasswordEncoder passwordEncoder;

    // クライアントユーザー（認証DB）Daoインターフェイス。
    @Autowired
    private ClUserDao clUserDao;

    // アプリのバージョン
    @Value("${ntss.cl-certificate.cl-user.version}")
    private float version;

    // ユーザーの最小パスワード
    @Value("${ntss.cl-certificate.cl-user.password-min}")
    private int passwordMin;

    // ユーザーのロックカウント
    @Value("${ntss.cl-certificate.cl-user.lock-count}")
    private int lockCount;

    @Override
    //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
    //public List<ClUser> getAllUser() throws Exception {
    public List<ClUser> getAllUser(String OrderKey) throws Exception {
      //mod FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
        final SelectOptions options = SelectOptions.get();
        final List<ClUser> entities = clUserDao.selectAllUser(options);
        //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 start
        switch (OrderKey) {
          case "userName":
            entities.sort(Comparator.comparing(ClUser::getUserName,Comparator.nullsFirst(String::compareTo)));
            break;
          case "userId":
            entities.sort(Comparator.comparing(ClUser::getUserId,Comparator.nullsFirst(String::compareTo)));
            break;
          case "departmentCd":
            entities.sort(Comparator.comparing(ClUser::getDepartmentCd,Comparator.nullsFirst(String::compareTo)));
            break;
          case "regDate":
            entities.sort(Comparator.comparing(ClUser::getRegDate,Comparator.nullsFirst(Timestamp::compareTo)));
            break;
          case "userRole":
            entities.sort(Comparator.comparing(ClUser::getUserRole,Comparator.nullsFirst(String::compareTo)));
            break;
          default:
            break;
        }
        //add FNSI-【1006】最新の改修対象一覧.NO51を修正 周安寧 end
        if (entities.isEmpty()) {
            return emptyList();
        }
        return entities;
    }

    @Override
    public void deleteUser(String userId) throws Exception {
        clUserDao.deleteUser(userId);
    }

    @Override
    public void updateUser(long id, String userName, String userRole, String departmentCd, String userPass,
            Timestamp upDate) throws Exception {
        String encodedPass = StringUtils.isEmpty(userPass) ? "" : passwordEncoder.encode(userPass);
        clUserDao.updateUser(id, userName, userRole, encodedPass, departmentCd, upDate);
    }

    @Override
    public void updateUserNoPass(long id, String userName, String userRole, String departmentCd, Timestamp upDate)
            throws Exception {
        clUserDao.updateUserNoPass(id, userName, userRole, departmentCd, upDate);

    }

    @Override
    public void insertUser(String userName, String userRole, Timestamp regDate, Timestamp upDate, String departmentCd,
            String userPass, String userId, int numLoginAttempt) throws Exception {
        String encodedPass = StringUtils.isEmpty(userPass) ? "" : passwordEncoder.encode(userPass);
        clUserDao.insertUser(userId, userName, userRole, regDate, upDate, encodedPass, departmentCd, numLoginAttempt);
    }

    @Override
    public ResponseClUserSetting getUserSetting() throws Exception {
        ResponseClUserSetting userSetting = new ResponseClUserSetting();
        userSetting.setVersion(version);
        userSetting.setPasswordMin(passwordMin);
        userSetting.setLockCount(lockCount);
        return userSetting;
    }

    @Override
    public void updateAttemptFail(String userId, int numLoginAttempt) throws Exception {
        clUserDao.updateNumLoginAttempt(userId, numLoginAttempt);
    }

    @Override
    public ClUser selectById(String userId) {
        return clUserDao.selectById(userId);
    }
}
