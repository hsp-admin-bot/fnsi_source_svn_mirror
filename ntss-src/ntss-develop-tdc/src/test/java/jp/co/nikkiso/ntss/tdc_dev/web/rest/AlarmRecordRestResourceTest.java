package jp.co.nikkiso.ntss.tdc_dev.web.rest;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.Matchers.hasSize;
import static org.junit.Assert.assertEquals;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import java.sql.Date;
import java.sql.Timestamp;
import java.util.Base64;
import java.util.List;

import org.joda.time.DateTime;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.ResultActions;
import org.springframework.test.web.servlet.request.MockMvcRequestBuilders;
import org.springframework.test.web.servlet.result.MockMvcResultMatchers;
import org.springframework.transaction.annotation.Transactional;

import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.entity.MntAlarmRecord;
import jp.co.nikkiso.ntss.tdc_dev.constant.AppConstant;
import jp.co.nikkiso.ntss.tdc_dev.service.MntAlarmRecordService;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/AlarmRecordRestResourceTest.before.sql")
public class AlarmRecordRestResourceTest {

  @Autowired
  private MockMvc mockMvc;
  
  @Autowired
  private MntAlarmRecordService mntAlarmRecordService;

  @Test
  public void getAlarmRecord_該当施設の1週間分のデータを取得すること() throws Exception {
    
    final String faciltiyCd = "999999";
    final String startDate = "20180101";    

    ResultActions result = mockMvc.perform(get(AppConstant.Uri.ALARM_RECORD + "/{facilityCd}/{startDate}", faciltiyCd, startDate));
    
    result.andExpect(status().isOk())
    .andExpect(jsonPath("$", hasSize(1)))
    .andExpect(jsonPath("$[0].alarmRecordMessage", is("hogehoge")));    
  }
  
  @Test
  public void postAlarmRecord_警報内容が正しく登録されること() throws Exception {
    
    final String msg = "モニタデータ名称 注意下限 発生";
    
    MntAlarmRecord param = new MntAlarmRecord();
    param.setFacilityCd("999999");
    param.setMachineTypeCd("999");
    param.setMachineSerial("99999999");
    param.setOccurDate(new Timestamp(new DateTime(2010, 12, 1, 10, 30).getMillis()));
    param.setOccurClass(1); 
    param.setMoniNo(1);
    param.setAlarmClass(1);
    param.setPatId("123456789012");
    param.setOrdNo(1);
    param.setIsDisp("1");
    param.setIsDel("0");
    
    ObjectMapper mapper = new ObjectMapper();
    String json = mapper.writeValueAsString(param);

    ResultActions actions = mockMvc.perform(
        MockMvcRequestBuilders
        .post(AppConstant.Uri.ALARM_RECORD)
        .contentType(MediaType.APPLICATION_JSON)
        .content(json)
        );
    
    // 200が返る
    actions.andExpect(MockMvcResultMatchers.status().isOk());
    
    List<MntAlarmRecord> rcd = 
        mntAlarmRecordService.selectByOccurDate(param.getFacilityCd(), param.getOccurDate(), new Timestamp(param.getOccurDate().getTime() + 1000000));

    // 警報内容が正しく登録されていること
    assertEquals(rcd.get(0).getAlarmRecordMessage(), msg);
  }
}
