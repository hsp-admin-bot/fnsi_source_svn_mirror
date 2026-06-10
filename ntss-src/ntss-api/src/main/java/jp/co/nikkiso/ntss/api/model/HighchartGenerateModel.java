package jp.co.nikkiso.ntss.api.model;

/**
 * Used for generating images from high charts export server
 * @author IES-史
 * @date 2024-05-30
 */
public class HighchartGenerateModel {

  /**
   * High charts export server input Json file path
   */
  private String inJsonFilePath;

  /**
   * High charts export server output Image file path
   */
  private String outImagefilePath;

  public String getInJsonFilePath() {
    return inJsonFilePath;
  }

  public void setInJsonFilePath(String inJsonFilePath) {
    this.inJsonFilePath = inJsonFilePath;
  }

  public String getOutImagefilePath() {
    return outImagefilePath;
  }

  public void setOutImagefilePath(String outImagefilePath) {
    this.outImagefilePath = outImagefilePath;
  }
}
