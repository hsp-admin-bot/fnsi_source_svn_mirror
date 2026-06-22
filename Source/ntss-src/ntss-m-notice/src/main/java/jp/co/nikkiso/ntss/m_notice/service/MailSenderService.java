package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import org.springframework.mail.MailException;

/**
 * メール送信サービスです。
 */
public interface MailSenderService {

  /**
   * メールを送信します。
   * @param toAdresses 宛先アドレスとのリスト
   * @param subject メールのタイトル
   * @param body メール本文
   * @throws MailException メール送信に失敗した場合
   */
  void sendMessage(List<String> toAdresses, String subject, String body);
}