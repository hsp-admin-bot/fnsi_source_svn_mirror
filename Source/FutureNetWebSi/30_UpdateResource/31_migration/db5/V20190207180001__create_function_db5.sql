-- Fnction: jsonb_merge_recursive(jsonb, jsonb)
CREATE OR REPLACE FUNCTION jsonb_merge_recursive(a jsonb, b jsonb)
 RETURNS jsonb
 LANGUAGE sql
 IMMUTABLE
AS $function$
  -- 2つのjsonb型データをマージして返す
  select
    case jsonb_typeof(a)
    when 'object' then
      case jsonb_typeof(b)
        when 'object' then (
          select
            jsonb_object_agg(k,
              case
                  when e2.v is null then e1.v
                  when e1.v is null then e2.v
                  else jsonb_merge_recursive(e1.v, e2.v)
              end
            )
          from      jsonb_each(a) e1(k, v)
          full join jsonb_each(b) e2(k, v) using (k)
        )
        else b
      end
    when 'array' then a || b
    else b
    end
$function$
