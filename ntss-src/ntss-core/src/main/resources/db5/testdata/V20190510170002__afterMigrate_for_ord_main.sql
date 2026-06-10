UPDATE ord_main
SET rst_vital_info = '[
  {
    "bio_moni_ctl_no": 0,
    "occur_date":  "2019-05-10T13:10:00.000+09:00",
    "bp_class":  "0",
    "bp_max":  150,
    "bp_min":  90,
    "bp_ave":  125,
    "blood_sugar_level":  120,
    "pulse":  60,
    "temperature":  36.3,
    "is_del":  "0"  
  },
  {
    "bio_moni_ctl_no": 0,
    "occur_date":  "2019-05-10T13:00:00.000+09:00",
    "bp_class":  "1",
    "bp_max":  151,
    "bp_min":  91,
    "bp_ave":  126,
    "blood_sugar_level":  121,
    "pulse":  61,
    "temperature":  36.4,
    "is_del":  "0"  
  },
  {
    "bio_moni_ctl_no": 0,
    "occur_date":  "2019-05-10T15:00:00.000+09:00",
    "bp_class":  "2",
    "bp_max":  152,
    "bp_min":  92,
    "bp_ave":  127,
    "blood_sugar_level":  122,
    "pulse":  62,
    "temperature":  36.5,
    "is_del":  "0"  
  }
]'
WHERE ord_no = 4;

UPDATE ord_main
SET rst_vital_info = '[
  {
    "bio_moni_ctl_no": 39,
    "occur_date":  "2019-05-10T13:02:00.000+09:00",
    "bp_class":  "1",
    "bp_max":  150,
    "bp_min":  90,
    "bp_ave":  125,
    "blood_sugar_level":  120,
    "pulse":  60,
    "temperature":  36.3,
    "is_del":  "0"  
  },
  {
    "bio_moni_ctl_no": 42,
    "occur_date":  "2019-05-10T15:02:00.000+09:00",
    "bp_class":  "2",
    "bp_max":  151,
    "bp_min":  91,
    "bp_ave":  126,
    "blood_sugar_level":  121,
    "pulse":  61,
    "temperature":  36.4,
    "is_del":  "0"  
  },
  {
    "bio_moni_ctl_no": 0,
    "occur_date":  "2019-05-10T13:20:00.000+09:00",
    "bp_class":  "0",
    "bp_max":  152,
    "bp_min":  92,
    "bp_ave":  127,
    "blood_sugar_level":  122,
    "pulse":  62,
    "temperature":  36.5,
    "is_del":  "0"  
  },
  {
    "bio_moni_ctl_no": 0,
    "occur_date":  "2019-05-10T13:22:00.000+09:00",
    "bp_class":  "0",
    "bp_max":  153,
    "bp_min":  93,
    "bp_ave":  128,
    "blood_sugar_level":  123,
    "pulse":  63,
    "temperature":  36.6,
    "is_del":  "0"  
  },
  {
    "bio_moni_ctl_no": 45,
    "occur_date":  "2019-05-10T13:12:00.000+09:00",
    "bp_class":  "0",
    "bp_max":  154,
    "bp_min":  94,
    "bp_ave":  129,
    "blood_sugar_level":  124,
    "pulse":  64,
    "temperature":  36.7,
    "is_del":  "0"  
  },
  {
    "bio_moni_ctl_no": 48,
    "occur_date":  "2019-05-10T13:17:00.000+09:00",
    "bp_class":  "0",
    "bp_max":  155,
    "bp_min":  95,
    "bp_ave":  130,
    "blood_sugar_level":  125,
    "pulse":  65,
    "temperature":  36.8,
    "is_del":  "1"  
  }
]'
WHERE ord_no = 5;
