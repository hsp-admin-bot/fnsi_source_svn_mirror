package jp.co.nikkiso.ntss.m_notice.service;

import java.util.List;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

import jp.co.nikkiso.ntss.m_notice.NtssMNoticeProperties;

/**
 * メール送信サービスです。
 */
@Service
public class MailSenderServiceImpl implements MailSenderService {

    private final JavaMailSender mailSender;
    
    private final NtssMNoticeProperties ntssMNoticeProperties;

    @Autowired
    public MailSenderServiceImpl(JavaMailSender mailSender, NtssMNoticeProperties ntssMNoticeProperties) {
        this.mailSender = mailSender;
        this.ntssMNoticeProperties = ntssMNoticeProperties;
    }

    /* (non-Javadoc)
     * @see jp.co.nikkiso.ntss.m_notice.service.MailSenderService#sendMessage(java.util.List, java.lang.String, java.lang.String)
     */
    @Override
    public void sendMessage(List<String> toAdresses, String subject, String body) {
      this.mailSender.send(mimeMessage -> {
            MimeMessageHelper helper = new MimeMessageHelper(mimeMessage, false, "UTF-8");
            helper.setBcc(toAdresses.toArray(new String[toAdresses.size()]));
            helper.setFrom(ntssMNoticeProperties.getMail().getFromAddress());
            helper.setSubject(subject);
            helper.setText(body, false);
        }
      );
    }
}