insert into mst_user_switch(
            	group_id,
            	user_id,
            	opt_status,
            	facility_cd,
              reg_staff,
              up_staff,
              up_date,
              reg_date
            )
            values
            /*%for user1 : entityList */

              (
                /*user1.groupId*/'',
                /*user1.userId*/0,
                /*user1.optStatus*/'0',
                /*user1.facilityCd*/'',
                /*user1.regStaff*/0,
                /*user1.upStaff*/0,
               now(),
               now()
              )
              /*%if user1_has_next */,/*%end*/
            /*%end*/
