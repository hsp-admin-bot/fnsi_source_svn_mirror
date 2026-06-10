delete from
  sys_signin_manager A
where
  A.user_id = /*userId*/0
  /*%if terminalUniqueString != null */
  and
  A.terminal_unique_string <> /*terminalUniqueString*/null
  /*%end*/
;
