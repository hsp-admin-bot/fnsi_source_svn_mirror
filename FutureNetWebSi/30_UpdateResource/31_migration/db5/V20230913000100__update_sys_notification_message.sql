update sys_notification set message = '担当者に設定：[STAFFLASTNAME] [STAFFFIRSTNAME] さんが [LASTNAME] [FIRSTNAME] さんの[STAFFTYPE]に設定されました。',
up_date = CURRENT_TIMESTAMP
where notification_no = 16;
