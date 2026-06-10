insert into sal_subscription_manage( 
  subscription_no,
  facility_cd,
  is_first,
  subscription_plan_name,
  subscription_fnc,
  subscription_adv,
  subscription_status,
  applicant,
  reg_date,
  up_date
) 
values ( 
  /*salSub.subscriptionNo*/null,
  /*salSub.facilityCd*/null,
  /*salSub.isFirst*/null,
  /*salSub.subscriptionPlanName*/null,
  /*salSub.subscriptionFnc*/null,
  /*salSub.subscriptionAdv*/null,
  /*salSub.subscriptionStatus*/null,
  /*salSub.applicant*/null,
  to_timestamp(/*salSub.regDate*/null, 'YYYY-MM-DD HH24:MI:SS'),
  to_timestamp(/*salSub.upDate*/null, 'YYYY-MM-DD HH24:MI:SS')
)
