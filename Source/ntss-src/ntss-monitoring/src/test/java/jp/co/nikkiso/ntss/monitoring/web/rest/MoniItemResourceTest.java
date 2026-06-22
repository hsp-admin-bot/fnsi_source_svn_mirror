package jp.co.nikkiso.ntss.monitoring.web.rest;

import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.context.ActiveProfiles;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/MoniItemResourceTest.before.sql")
@ActiveProfiles("test") // Like this
public class MoniItemResourceTest {
  
  @Autowired
  private MockMvc mockMvc;

  @Test
  public void test_getMoniItem_該当施設なしでも施設コードallのものを取得すること() throws Exception {
    
    final String faciltiyCd = "nothing";
    
    mockMvc.perform(get("/api/moni_item/{facilityCd}", faciltiyCd))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$.[0].facilityCd", is("all")));
    
  }

  @Test
  public void test_getMoniItem_ユニークな条件では1件だけ取得すること() throws Exception {
    
    final String faciltiyCd = "all";
    final String model = "001";
    final String moniNo = "1";
    
    mockMvc.perform(get("/api/moni_item/{facilityCd}/{model}/{moniNo}", faciltiyCd, model, moniNo))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(1)));
    
  }
}
