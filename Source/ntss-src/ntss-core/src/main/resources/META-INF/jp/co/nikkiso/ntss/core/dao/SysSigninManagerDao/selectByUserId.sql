-- add 11587 by kangjie 20250226 start
select
  distinct ssm.server_ip
from
  ntss.sys_signin_manager ssm
where
  ssm.user_id  = /*userId*/0
;
-- add 11587 by kangjie 20250226 end
