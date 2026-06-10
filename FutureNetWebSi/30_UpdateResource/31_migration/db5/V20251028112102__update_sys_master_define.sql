-- add mst_exam_set.order_class
UPDATE sys_master_define 
SET
  column_info = jsonb_set( 
    column_info
    , '{fields}'
    , column_info -> 'fields' || '[{
    "type": "json",
    "alias": null,
    "title": "検査区分",
    "hidden": "true",
    "physical_name": "order_class"
  }]'
     ::jsonb
  ) 
  , up_date = current_timestamp 
WHERE
  master_physical_name = 'mst_exam_set';
