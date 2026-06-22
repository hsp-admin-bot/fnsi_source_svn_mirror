package web.utils;

import batch.ApplicationConst;
import jakarta.annotation.PostConstruct;
import tools.jackson.core.type.TypeReference;
import tools.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.context.ApplicationContext;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

import javax.sql.DataSource;
import java.util.Collections;
import java.util.List;

@Component
public class HashValueTOFacilityCd {

    @Autowired
    private ApplicationContext appContext;

    private JdbcTemplate machineJdbcTemplateNkk4;

    @PostConstruct
    public void init() {
        DataSource nkk4DataSource = (DataSource) appContext.getBean(ApplicationConst.DbType.NKK4);
        machineJdbcTemplateNkk4 = new JdbcTemplate(nkk4DataSource);
    }

   public   List<String>  getfacilitycd(String  hash_value){
       List<String> hashValues;
       try {
           ObjectMapper mapper = new ObjectMapper();
           hashValues = mapper.readValue(hash_value, new TypeReference<List<String>>() {});
       } catch (Exception e) {
           //#12737 【securify】convert-server-sideが落ちる start
           throw new ResponseStatusException(
                   HttpStatus.FORBIDDEN,
                   "Forbidden");
           //#12737 【securify】convert-server-sideが落ちる end

       }

       if (hashValues == null || hashValues.isEmpty()) {
           return null;
       }
       String placeholders = String.join(",", Collections.nCopies(hashValues.size(), "?"));

       String sql = "SELECT facility_cd FROM mst_facility_hash WHERE hash_value IN (" + placeholders + ")";

       List<String> results = machineJdbcTemplateNkk4.queryForList(sql, hashValues.toArray(), String.class);

       if (results.isEmpty()) {
           //#12737 【securify】convert-server-sideが落ちる start
           throw new ResponseStatusException(
                   HttpStatus.FORBIDDEN,
                   "Forbidden");
           //#12737 【securify】convert-server-sideが落ちる end
       } else {
           return results;
       }
     }
}
