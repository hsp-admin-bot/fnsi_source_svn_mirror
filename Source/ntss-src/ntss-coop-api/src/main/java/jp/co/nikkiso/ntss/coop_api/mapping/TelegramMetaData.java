package jp.co.nikkiso.ntss.coop_api.mapping;

import org.apache.commons.codec.binary.Hex;

import com.fasterxml.jackson.annotation.JsonProperty;

import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * 配信用の電文情報
 *
 */
@NoArgsConstructor
@Data
public class TelegramMetaData {
  public TelegramMetaData(String filename, byte[] dump) {
    this.fileName = filename;
    this.dump = new String(Hex.encodeHex(dump));
  }

  /** 電文名 */
  @JsonProperty("filename")
  private String fileName;

  /** 電文データ */
  @JsonProperty("dump")
  private String dump;
}
