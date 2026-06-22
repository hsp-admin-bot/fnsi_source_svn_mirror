SELECT
  /*%expand "A" */*
FROM
  sal_subscription_manage A
WHERE 
  A.is_disp = '1'
AND
  A.is_del = '0'
AND
  subscription_no = /*subscriptionNo*/0L
;