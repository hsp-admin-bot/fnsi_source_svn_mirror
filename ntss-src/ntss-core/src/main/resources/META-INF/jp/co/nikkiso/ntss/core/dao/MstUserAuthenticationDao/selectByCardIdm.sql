select
  /*%expand */*
from
  mst_user_authentication
where
  user_id = /*userId*/'0'
and
  card_idm = /*cardIdm*/null
