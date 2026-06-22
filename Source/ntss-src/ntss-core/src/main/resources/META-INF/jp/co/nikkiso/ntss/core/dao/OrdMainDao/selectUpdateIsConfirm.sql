select
  /*%expand "A" */*
from
  ord_main A
WHERE
    ord_no = /*ordNo*/0
  AND
    is_confirm = /*updateTargetIsConfirm*/'1'
