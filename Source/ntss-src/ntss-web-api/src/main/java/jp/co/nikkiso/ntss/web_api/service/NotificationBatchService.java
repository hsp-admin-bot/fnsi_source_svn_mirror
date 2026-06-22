package jp.co.nikkiso.ntss.web_api.service;

import org.springframework.http.ResponseEntity;

public interface NotificationBatchService {
  ResponseEntity<?> genericNotificationsReceiver(String request);
}
