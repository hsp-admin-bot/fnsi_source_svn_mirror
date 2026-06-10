package web.service;


import batch.ApplicationConst;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.NamedParameterJdbcTemplate;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;
import web.authentication.BaseUser;
import web.authentication.SignRequest;
import web.authentication.SignResponse;
import web.authentication.User;
import web.config.EventLoggerUtil;
import web.exception.AccountNotFoundException;
import web.exception.WrongCredentialsException;
import web.logger.EventLogMessage;
import web.logger.LogLevel;
import web.utils.DateTimeFormatterUtil;

import javax.sql.DataSource;
import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;
import java.util.concurrent.atomic.AtomicLong;

@Service
public class UserServiceImpl implements UserService {

    @Autowired
    private ApplicationContext appContext;

    @Autowired
    private PasswordEncoder passwordEncoder;

    private AtomicLong idIncrement = new AtomicLong();
    private List<User> userStorage = new CopyOnWriteArrayList<>();

    private TokenService tokenService;

    @Autowired
    private AesDecryption aesDecryption;

    @Autowired
    private EventLoggerUtil eventLoggerUtil;

    public UserServiceImpl(TokenService tokenService) {
        this.tokenService = tokenService;
    }

    /**
     * 利用者ユーザの登録情報を取得する
     *
     * @param disp_user_id
     */
    private void getUserInfo(String disp_user_id) throws AccountNotFoundException {
        DataSource nkk4DataSource = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK4);
        JdbcTemplate machineJdbcTemplateNkk4 = new JdbcTemplate(nkk4DataSource);

        DataSource nkk5DataSource = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
        JdbcTemplate machineJdbcTemplateNkk5= new JdbcTemplate(nkk5DataSource);

        String failure_cnt_sql="SELECT " +
                            "    COALESCE( " +
                            "        (SELECT value FROM mst_facility_setting WHERE facility_setting_no='1062' AND facility_cd='nkknkk')," +
                            "        (SELECT default_value FROM sys_facility_setting WHERE facility_setting_no='1062')" +
                            "    ) AS result_value;";

        String failure_cnt = machineJdbcTemplateNkk5.queryForObject(failure_cnt_sql,String.class);

        String loginSql = "SELECT user_password FROM mst_user_authentication A WHERE A.facility_cd = 'nkknkk' and disp_user_id = :disp_user_id and failure_cnt<:failure_cnt  LIMIT 1";
        Map<String, Object> parameters = new HashMap<>();
        parameters.put("disp_user_id", disp_user_id);
        parameters.put("failure_cnt",Integer.parseInt(failure_cnt));
        NamedParameterJdbcTemplate namedParameterJdbcTemplate = new NamedParameterJdbcTemplate(machineJdbcTemplateNkk4.getDataSource());

        try{
            String  userpassword = namedParameterJdbcTemplate.queryForObject(loginSql, parameters,String.class);
            if (userpassword != null && !userpassword.isEmpty()) {
                User user = new User();
                user.setId(idIncrement.incrementAndGet());
                user.setLogin(String.valueOf(disp_user_id));
                user.setBcryptPassword(userpassword);
                userStorage.add(user);
            } else {
                throw new AccountNotFoundException();
            }
        }catch (Exception ex){
            EventLogMessage eventLogMessagex = eventLoggerUtil.getEventLogMessage("詳細なエラー情報：" + ex.toString(),
                    null, "getUserInfo");
            eventLoggerUtil.recordLog("getUserInfo", eventLogMessagex, LogLevel.ERROR);
            throw new AccountNotFoundException();
        }
    }

    /**
     * ログインユーザーのアカウントとパスワードの検証
     *
     * @param requestBody
     * @return
     * @throws WrongCredentialsException
     */
    @Override
    public SignResponse userLogin(SignRequest requestBody) throws WrongCredentialsException, AccountNotFoundException {
        User user = null;
        this.getUserInfo(requestBody.getLogin());
        DataSource nkk4DataSource = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK4);
        JdbcTemplate machineJdbcTemplateNkk4 = new JdbcTemplate(nkk4DataSource);
        Map<String, String> hash_value_map = new HashMap<>();
        try {
            String  password = aesDecryption.decrypt(requestBody.getPassword());
            for (User currentUser : userStorage) {
                if (currentUser.getLogin().equals(requestBody.getLogin())) {
                    //TODO BCryptPasswordEncoderは暗号が解読されないように非解読方式を用いて照合する
                    if (passwordEncoder.matches(password, currentUser.getBcryptPassword())) {
                        user = currentUser;
                        List<String> facilityCodes = Arrays.stream(requestBody.getFacilitycd().split(",")).toList();
                        String placeholders = String.join(",", facilityCodes.stream().map(s -> "?").toArray(String[]::new));

                        String sql = "SELECT facility_cd, hash_value FROM mst_facility_hash WHERE facility_cd IN (" + placeholders + ")";

                        machineJdbcTemplateNkk4.query(sql, facilityCodes.toArray(), rs -> {
                            hash_value_map.put(rs.getString("facility_cd"), rs.getString("hash_value"));
                        });

                        if(hash_value_map.isEmpty()){
                            throw new WrongCredentialsException();
                        }
                    } else {
                        break;
                    }
                }
            }
            if (user == null) {
                String  failure_cnt_update="UPDATE  mst_user_authentication set failure_cnt=failure_cnt+1,up_date=now()  WHERE facility_cd = 'nkknkk' and disp_user_id = ?";
                String   disp_user_id=requestBody.getLogin();
                machineJdbcTemplateNkk4.update(failure_cnt_update, new Object[]{disp_user_id});
                throw new WrongCredentialsException();
            }
            return new SignResponse(
                    HttpStatus.OK.value(),
                    user.getId(),
                    user.getLogin(),
                    tokenService.generateToken(new BaseUser(user.getId())),
                    hash_value_map,
                    DateTimeFormatterUtil.dateTimeFormatter(LocalDateTime.now(), "yyyy-MM-dd HH:mm:ss")
            );
        } catch (ResponseStatusException e) {
            throw e;
        }
        catch (Exception ex) {

            EventLogMessage eventLogMessagex = eventLoggerUtil.getEventLogMessage("詳細なエラー情報：" + ex.toString(),
                    null, "userLogin");
            eventLoggerUtil.recordLog("userLogin", eventLogMessagex, LogLevel.ERROR);
            throw new WrongCredentialsException();
        }

    }
}
