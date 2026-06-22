with max_row as(
 SELECT MAX(A.row_no) AS max_row_no FROM (
 SELECT
 (rst_treat_staff_info_element->>'row_no')::int as row_no, ord_no
FROM
    ord_main om
CROSS JOIN LATERAL
    jsonb_array_elements(om.rst_treat_staff_info) AS rst_treat_staff_info_element
WHERE
  ord_no = /*ordNo*/1
AND
    (rst_treat_staff_info_element->>'ctl_no')::int = /*ctl_no*/1
UNION ALL
SELECT 0 AS row_no, /*ordNo*/1 AS ord_no) AS A GROUP BY A.ord_no
)
update
  ord_main
set
  rst_treat_staff_info = COALESCE(rst_treat_staff_info, '[]') ||
  ('[{' ||
    '"ctl_no": ' || /*ctl_no*/1 ||
    ',"row_no": ' || max_row.max_row_no + 1 ||
    ',"input_class": 0' ||
    ',"occur_date": ' || /*occurDate*/'null' ||
    ',"treat_staff_cd": ' || /*staffCd*/'null' ||
    ',"treat_staff_name": ' || /*staffName*/'null' || -- 名称
    ',"cop_order_no": null' ||
    ',"checkFlag": 1' ||
	',"is_editable": "1"' ||
  '}]')::jsonb,
  up_date = current_timestamp
	from max_row
where
  ord_no = /*ordNo*/1
;

