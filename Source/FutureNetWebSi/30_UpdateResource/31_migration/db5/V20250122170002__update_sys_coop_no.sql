DELETE FROM ntss.sys_coop_no
WHERE ctl_no = -301;

INSERT INTO sys_coop_no
(ctl_no, facility_cd, coop_ord_cd, cur_coop_ord_no, no_of_digit, padding_char, padding_pos, range_max, range_min, prefix_char, suffix_char, is_disp, is_del, user_id, reg_date, up_date, coop_cd, coop_cd_index, coop_version)
VALUES(-301, 'N_hosp', '[
  {
    "ord_cd": "ini_dial"
  },
  {
    "ord_cd": "ind_dial"
  },
  {
    "ord_cd": "rst_dial"
  },
  {
    "ord_cd": "rep_dial"
  },
  {
    "ord_cd": "exam_rst"
  },
  {
    "ord_cd": "exam_ord"
  },
  {
    "ord_cd": "rad_ord"
  },
  {
    "ord_cd": "phy_ord"
  },
  {
    "ord_cd": "shot_ord"
  },
  {
    "ord_cd": "pre_ord"
  },
  {
    "ord_cd": "staff_mst"
  },
  {
    "ord_cd": "vit_cop"
  }
]'::jsonb, 1, 10, '0', 'left', 9999999999, 1, '', '', '1', '0', -1, '2023-06-16 17:44:46.755', CURRENT_TIMESTAMP, '', '', 'HR');