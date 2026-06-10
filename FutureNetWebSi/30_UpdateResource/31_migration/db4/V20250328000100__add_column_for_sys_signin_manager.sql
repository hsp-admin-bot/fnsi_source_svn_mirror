-- add 11587 by kangjie 20250226 start
ALTER TABLE ntss.sys_signin_manager ADD server_ip varchar NULL;
COMMENT ON COLUMN ntss.sys_signin_manager.server_ip IS 'サーバip';
-- add 11587 by kangjie 20250226 end
