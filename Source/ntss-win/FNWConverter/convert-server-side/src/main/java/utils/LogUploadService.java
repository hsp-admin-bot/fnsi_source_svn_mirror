package utils;

import batch.ApplicationConst;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.jdbc.core.BeanPropertyRowMapper;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import web.entity.SysSystemDefine;
import javax.sql.DataSource;
import java.util.List;
@Component
public class LogUploadService {

    @Autowired
    private ApplicationContext appContext;

    /**
     * 管理番号よりシステム設定を取得する
     *
     * @param ctlNo 管理番号
     * @return システム設定
     */
    public SysSystemDefine getSystemDefine(int ctlNo) {
        String sql = "select ctl_no as ctlNo, service_cd as serviceCd, name, value, description, " +
                "is_enable as isEnable, up_date as upDate  from sys_system_define where ctl_no = ?";
        DataSource dataSource = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK5);
        JdbcTemplate jdbcTemplate = new JdbcTemplate(dataSource);
        SysSystemDefine systemDefine = new SysSystemDefine();
        List<SysSystemDefine> userList = jdbcTemplate.query(sql, new Object[]{ctlNo}, new BeanPropertyRowMapper<>(SysSystemDefine.class));
        if (!userList.isEmpty()) {
            systemDefine = userList.get(0);
        }
        return systemDefine;
    }
}
