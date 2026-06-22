package jp.co.nikkiso.ntss.monitoring.web.rest;

import static org.hamcrest.CoreMatchers.equalTo;
import static org.hamcrest.CoreMatchers.is;
import static org.hamcrest.CoreMatchers.notNullValue;
import static org.hamcrest.Matchers.hasSize;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.get;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.post;
import static org.springframework.test.web.servlet.request.MockMvcRequestBuilders.put;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.content;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.jsonPath;
import static org.springframework.test.web.servlet.result.MockMvcResultMatchers.status;

import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.webmvc.test.autoconfigure.AutoConfigureMockMvc;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.http.MediaType;
import org.springframework.test.context.jdbc.Sql;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.transaction.annotation.Transactional;

import tools.jackson.databind.ObjectMapper;

import jp.co.nikkiso.ntss.core.entity.MstBioMoniFramePattern;

@RunWith(SpringRunner.class)
@SpringBootTest
@AutoConfigureMockMvc
@Transactional
@Sql("classpath:resource.script/BioMoniFramePatternResourceTest.before.sql")
public class BioMoniFramePatternResourceTest {

  @Autowired
  private MockMvc mockMvc;

  @Test
  public void test_getPattern_該当なしならば取得がゼロ件であること() throws Exception {
    
    final String faciltiyCd = "nothing";
    final String ctl_no = "-1";
    
    mockMvc.perform(get("/api/bio_moni_frame_pattern/{facilityCd}", faciltiyCd))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)));
    
    mockMvc.perform(get("/api/bio_moni_frame_pattern/{facilityCd}/{ctl_no}", faciltiyCd, ctl_no))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(0)));
    
  }
  
  @Test
  public void test_getPattern_該当なしならば設定項目のみの取得が空であること() throws Exception {
    
    final String faciltiyCd = "nothing";
    final String ctl_no = "-1";
    
    mockMvc.perform(get("/api/bio_moni_frame_pattern/define_info/{facilityCd}/{ctl_no}", faciltiyCd, ctl_no))
      .andExpect(status().isOk())
      .andExpect(content().string(""));    
  }

  @Test
  public void test_getPattern_該当ありならば取得すること() throws Exception {
    
    final String faciltiyCd = "431844";
    final String ctl_no = "1";
    
    mockMvc.perform(get("/api/bio_moni_frame_pattern/{facilityCd}", faciltiyCd))
      .andExpect(status().isOk())
      .andExpect(jsonPath("$", hasSize(1)));
    
    mockMvc.perform(get("/api/bio_moni_frame_pattern/{facilityCd}/{ctl_no}", faciltiyCd, ctl_no))
      .andExpect(status().isOk())
      .andExpect(content().contentType(MediaType.APPLICATION_JSON))
      .andExpect(jsonPath("$", hasSize(1)))
      .andExpect(jsonPath("$.[0].templateName", is("test")))
      .andExpect(jsonPath("$.[0].frameNo", equalTo(1)))
      .andExpect(jsonPath("$.[0].defineInfo", notNullValue()));
    
  }
  
  @Test
  public void test_getPattern_該当ありならば設定項目のみの取得ができること() throws Exception {

    final String faciltiyCd = "431844";
    final String ctl_no = "1";
    
    mockMvc.perform(get("/api/bio_moni_frame_pattern/define_info/{facilityCd}/{ctl_no}", faciltiyCd, ctl_no))
      .andExpect(status().isOk())
      .andExpect(content().json("{\"l1\":{\"l2\":[{\"c1\":\"t1\",\"c2\":1},{\"c1\":\"t2\",\"c2\":2}]}}", false));    
  }

  @Test
  public void test_postPattern_項目の登録ができること() throws Exception {

    final String facilityCd = "431833";
    final Integer ctl_no = 1;
    final MstBioMoniFramePattern pat = new MstBioMoniFramePattern();
    pat.setFacilityCd(facilityCd);
    pat.setCtlNo(ctl_no);
    pat.setTemplateName("a");
    pat.setDefineInfo("{\"aa\":\"aaa\"}");
    
    mockMvc.perform(post("/api/bio_moni_frame_pattern/")
        .contentType(MediaType.APPLICATION_JSON)
        .content(new ObjectMapper().writeValueAsString(pat)))
      .andExpect(status().is2xxSuccessful());
  }
  @Test
  public void test_postPattern_項目の重複登録ができないこと() throws Exception {

    final String facilityCd = "431844";
    final Integer ctl_no = 1;
    final MstBioMoniFramePattern pat = new MstBioMoniFramePattern();
    pat.setFacilityCd(facilityCd);
    pat.setCtlNo(ctl_no);
    pat.setTemplateName("a");
    pat.setDefineInfo("{\"aa\":\"aaa\"}");
    
    mockMvc.perform(post("/api/bio_moni_frame_pattern/")
        .contentType(MediaType.APPLICATION_JSON)
        .content(new ObjectMapper().writeValueAsString(pat)))
      .andExpect(status().is5xxServerError());
  }

  @Test
  public void test_putPattern_項目の更新ができること() throws Exception {

    final String facilityCd = "431844";
    final Integer ctl_no = 1;
    final MstBioMoniFramePattern pat = new MstBioMoniFramePattern();
    pat.setFacilityCd(facilityCd);
    pat.setCtlNo(ctl_no);
    pat.setTemplateName("a");
    pat.setDefineInfo("{\"aa\":\"aaa\"}");
    
    mockMvc.perform(put("/api/bio_moni_frame_pattern/{facilityCd}/{ctl_no}", facilityCd, ctl_no.toString())
        .contentType(MediaType.APPLICATION_JSON)
        .content(new ObjectMapper().writeValueAsString(pat)))
      .andExpect(status().isOk());
    }
}
