package jp.co.nikkiso.ntss.admin_web.response.roundType;

import com.fasterxml.jackson.annotation.JsonProperty;
import lombok.AllArgsConstructor;

/**
 * 職種マスタのResponse.
 */
@AllArgsConstructor
public class RoundTypeNameAndContentResponse {

  /**
   * 種別コード.
   */
  private Long roundTypeCd;

  /**
   * 種別名.
   */
  private String roundTypeName;

  /**
   * 内容.
   */
  private String content;

  /**
   * 内容省略フラグ.
   */
  private String isContentOmission;

  /**
   * 指示コメント転記初期値.
   */
  private String commentPostDefault;

  /**
   * 転記区分初期値.
   */
  private String postingClassDefault;

  /**
   * 強調表示.
   */
  private String highlighting;

  @JsonProperty("round_type_cd")
  public Long getRoundTypeCd() {
    return roundTypeCd;
  }

  @JsonProperty("round_type_name")
  public String getRoundTypeName() {
    return roundTypeName;
  }

  @JsonProperty("content")
  public String getContent() {
    return content;
  }

  @JsonProperty("is_content_omission")
  public String getIsContentOmission() {
    return isContentOmission;
  }

  @JsonProperty("comment_post_default")
  public String getCommentPostDefault() {
    return commentPostDefault;
  }

  @JsonProperty("posting_class_default")
  public String getPostingClassDefault() {
    return postingClassDefault;
  }

  @JsonProperty("highlighting")
  public String getHighlighting() {
    return highlighting;
  }
}
