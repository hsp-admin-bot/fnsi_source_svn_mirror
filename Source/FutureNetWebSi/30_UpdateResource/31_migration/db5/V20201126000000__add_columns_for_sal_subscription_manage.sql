ALTER TABLE
  sal_subscription_manage
  ADD COLUMN canceller bigint,
  ADD COLUMN cancel_date timestamp(3)
;