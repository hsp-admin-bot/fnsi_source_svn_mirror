select
  treat ->> 'occur_date' as occur_date,
  treat ->> 'oxygen_start' as oxygen_start,
  treat ->> 'oxygen_amount' as oxygen_amount,
  staff ->> 'treat_staff_cd' as treat_staff_cd
from
  ord_main as ord
cross join lateral
  json_array_elements (ord.rst_treatment_info :: json) treat
left outer join
  json_array_elements (ord.rst_treat_staff_info :: json) staff
-- mod 10270 酸素吸入でブラウザから開始を行った後に透析装置の仮想端末で終了ができない 関  start
-- on
--   treat ->> 'occur_date' = staff ->> 'occur_date'
on
  treat ->> 'ctl_no' = staff ->> 'ctl_no'
-- mod 10270 酸素吸入でブラウザから開始を行った後に透析装置の仮想端末で終了ができない 関  end
where
  ord.ord_no = /*ordNo*/1 and
  (treat ->> 'oxygen_start' IS NOT NULL or
  treat ->> 'oxygen_amount' IS NOT NULL)
order by
-- mod #10270 酸素吸入でブラウザから開始を行った後に透析装置の仮想端末で終了ができない dengshen start
--   occur_date desc
  CAST(treat ->> 'ctl_no' AS INTEGER) desc
-- mod #10270 酸素吸入でブラウザから開始を行った後に透析装置の仮想端末で終了ができない dengshen end
;
