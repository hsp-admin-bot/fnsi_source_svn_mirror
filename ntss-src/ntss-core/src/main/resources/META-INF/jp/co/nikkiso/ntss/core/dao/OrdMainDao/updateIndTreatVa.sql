update ord_main
set
  ind_info = (ind_info::jsonb)
              /*%for json : sampleJSON */
              ||
                case
                  when ind_info->>/* json.getKey().toString() */'0' is null then
                    (json_build_object(/*json.getKey().toString()*/'0', /*json.getValue().toString()*/'{}'::jsonb))::jsonb
                  else
                    (json_build_object(/*json.getKey().toString()*/'0', ind_info->/*json.getKey().toString()*/'0' || /*json.getValue().toString()*/'{}'::jsonb))::jsonb
                end
             /*%end*/,
  up_date = CURRENT_TIMESTAMP
where
  ord_no = /*ordNo*/'1'
