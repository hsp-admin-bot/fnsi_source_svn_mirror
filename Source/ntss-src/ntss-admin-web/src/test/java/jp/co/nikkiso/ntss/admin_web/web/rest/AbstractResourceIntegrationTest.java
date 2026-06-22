package jp.co.nikkiso.ntss.admin_web.web.rest;

import static org.springframework.restdocs.mockmvc.MockMvcRestDocumentation.documentationConfiguration;

import org.junit.Before;
import org.junit.Rule;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.restdocs.JUnitRestDocumentation;
import org.springframework.test.web.servlet.MockMvc;
import org.springframework.test.web.servlet.setup.MockMvcBuilders;
import org.springframework.web.context.WebApplicationContext;

/**
 * Resource結合テストの抽象基底クラス.
 */
public abstract class AbstractResourceIntegrationTest {

  /**
   * MockMVC.
   */
  @Autowired
  protected MockMvc mockMvc;

  /**
   * Rest Docs出力用.
   */
  @Rule
  public JUnitRestDocumentation restDocumentation = new JUnitRestDocumentation();
  
  /**
   * WebApplicationContext.
   */
  @Autowired
  private WebApplicationContext context;

  /**
   * テスト実行前処理.
   */
  @Before
  public void setUp() {
    // Rest Docs出力の準備
    this.mockMvc = MockMvcBuilders.webAppContextSetup(this.context)
            .apply(documentationConfiguration(this.restDocumentation)) 
            .build();
  }
  
}
