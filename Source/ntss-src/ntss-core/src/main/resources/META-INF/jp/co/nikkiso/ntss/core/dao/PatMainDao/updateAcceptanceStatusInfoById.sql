update pat_main
  set acceptance_status_info = /*acceptanceStatusInfo*/null
  -- mod FutreNetWeb+SI課題管理No4821 趙 start
  -- ,up_date = CURRENT_TIMESTAMP
  -- mod FutreNetWeb+SI課題管理No4821 趙 end
  where
    pat_id = /*patId*/null
;
