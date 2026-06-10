package jp.co.nikkiso.ntss.monitoring.web.rest;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.CoreMatchers.nullValue;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.autoconfigure.web.servlet.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/MachineResourceTest.before.sql")
public class MachineResourceTest {
  
  @Autowired
  private MockMvc mockMvc;

  @Test
  public void test_getMachines_該当施設なしならば取得がゼロ件であること() throws Exception {
    
    final String faciltiyCd = "nothing";
    
    mockMvc.perform(get("/api/machines/{facilityCd}", faciltiyCd))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)));
    
  }

  @Test
  public void test_getMachines_該当施設がある場合は取得すること() throws Exception {
    
    final String faciltiyCd = "431833";
    
    mockMvc.perform(get("/api/machines/{facilityCd}", faciltiyCd))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(1)))
      .andExpect(jsonPath("$.[0].machineSerial", is("TDC0000")))
      .andExpect(jsonPath("$.[0].machineName", is("別テスト装置")))
      .andExpect(jsonPath("$.[0].processState", is("01")))
      .andExpect(jsonPath("$.[0].machineStatus", equalTo(0)))
      .andExpect(jsonPath("$.[0].startDate", nullValue()))
      .andExpect(jsonPath("$.[0].endDate", nullValue()));
    
  }

  @Test
  public void test_getMachines_製造番号順に取得すること() throws Exception {
    
    final String faciltiyCd = "431844";
    
    mockMvc.perform(get("/api/machines/{facilityCd}", faciltiyCd))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(4)))
      .andExpect(jsonPath("$.[0].machineSerial", is("TDC0001")))
      .andExpect(jsonPath("$.[0].machineName", is("テスト装置1")))
      .andExpect(jsonPath("$.[0].processState", is("-1")))
      .andExpect(jsonPath("$.[0].machineStatus", equalTo(1)))
      .andExpect(jsonPath("$.[0].startDate", nullValue()))
      .andExpect(jsonPath("$.[0].endDate", nullValue()))
      .andExpect(jsonPath("$.[1].machineSerial", is("TDC0002")))
      .andExpect(jsonPath("$.[1].machineName", is("テスト装置2")))
      .andExpect(jsonPath("$.[1].processState", is("00")))
      .andExpect(jsonPath("$.[1].machineStatus", equalTo(1)))
      .andExpect(jsonPath("$.[1].startDate", notNullValue()))
      .andExpect(jsonPath("$.[1].endDate", notNullValue()))
      .andExpect(jsonPath("$.[2].machineSerial", is("TDC0003")))
      .andExpect(jsonPath("$.[2].machineName", is("テスト装置3")))
      .andExpect(jsonPath("$.[2].processState", is("01")))
      .andExpect(jsonPath("$.[2].machineStatus", equalTo(2)))
      .andExpect(jsonPath("$.[2].startDate", notNullValue()))
      .andExpect(jsonPath("$.[2].endDate", notNullValue()));
    
  }
}
