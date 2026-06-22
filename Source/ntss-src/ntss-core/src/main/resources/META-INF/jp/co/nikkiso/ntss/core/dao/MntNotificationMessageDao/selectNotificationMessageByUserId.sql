-- mod bug 8158 修正 chen start
-- select
--   m.notification_message_no
--   , m.content
--   , m.additional_info
--   , s.is_read
--   , m.reg_date
--   , m.notification_no
--   ,case when notification_no in (
--     /*%for notificationNo : notificationNoList */
--      /*notificationNo*/0
--      /*%if notificationNo_has_next */
--      /*# "," */
--      /*%end */
--     /*%end*/
--     )
--         then 1
--         else 0 end as is_important
-- from
--   mnt_notification_message m,
-- --mod FNSi6143メーカー通知で正常に通知しない 周 start
-- --     inner join mnt_notification_status s
-- --       on m.notification_message_no = s.notification_message_no
-- --      and m.facility_cd = s.facility_cd
--   mnt_notification_status s
-- --mod FNSi6143メーカー通知で正常に通知しない 周 end
-- where
-- --add FNSi6143メーカー通知で正常に通知しない 周 start
--   m.notification_message_no = s.notification_message_no
--   --add FNSi6970別の施設の通知が表示される 周 start
--   and m.notification_message_no IN (
--   select notification_message_no from mnt_notification_message
--   where facility_cd = /*facilityCd*/000000 or notification_no = 0
--   )
--   --add FNSi6970別の施設の通知が表示される 周 end
--   and
-- --add FNSi6143メーカー通知で正常に通知しない 周 end
--   -- FutreNetWeb+SI課題管理 no.6015 関春麗 start
--   to_char(m.reg_date,'yyyy-mm-dd') >= to_char(now()-interval'3'month,'yyyy-mm-dd')
--   -- FutreNetWeb+SI課題管理 no.6015 関春麗 end
-- and
--   s.user_id = /*userId*/1
-- --mod FNSi6143メーカー通知で正常に通知しない 周 start
-- --del FNSi6970別の施設の通知が表示される 周 start
-- -- and
-- --   s.facility_cd IN (select distinct facility_cd
-- --   from mnt_notification_message mnm
-- --   where mnm.facility_cd  = /*facilityCd*/000000)
-- --del FNSi6970別の施設の通知が表示される 周 end
-- --mod FNSi6143メーカー通知で正常に通知しない 周 end
-- /*%if isNotified != null*/
-- and
--   is_notified = /*isNotified*/null
-- /*%end*/
-- order by
-- -- FutreNetWeb+SI課題管理 no.5695 劉全航 start
-- --add 5695通知一覧の表示順不正 周 start
--     m.reg_date desc,
-- --add 5695通知一覧の表示順不正 周 end
--     s.is_read,
--     is_important
--     desc
--     ,
-- -- is_important desc,
-- -- s.is_read asc,
-- -- FutreNetWeb+SI課題管理 no.5695 劉全航 end
-- m.reg_date
-- /*%if isDesc == true*/
--  desc
-- /*%end*/
-- -- add FNSI-通知表示が遅いを修正 江 start
-- limit 100
-- /*%if offset != null*/
-- offset /*offset*/0
-- /*%end*/
-- -- add FNSI-通知表示が遅いを修正 江 end
-- ;
select * from
    (select * from
        (select
             m.notification_message_no
              , m.content
              , m.additional_info
              , s.is_read
              , m.reg_date
              , m.notification_no
              ,case when notification_no in (
                /*%for notificationNo : notificationNoList */
                /*notificationNo*/0
                /*%if notificationNo_has_next */
                /*# "," */
                /*%end */
                /*%end*/
                )
                        then 1
                    else 0 end as is_important
         from
             mnt_notification_message m,
             mnt_notification_status s
         where
                 m.notification_message_no = s.notification_message_no
           and m.notification_message_no IN (
             select notification_message_no from mnt_notification_message
             where facility_cd = /*facilityCd*/000000 or notification_no = 0
         )
-- del #10110 通知一覧から既読にした通知以外も消える dengshen start
--           and
--                 to_char(m.reg_date,'yyyy-mm-dd') >= to_char(now()-interval'3'month,'yyyy-mm-dd')
-- del #10110 通知一覧から既読にした通知以外も消える dengshen end
           and
                 s.user_id = /*userId*/1
/*%if isNotified != null*/
           and
                 is_notified = /*isNotified*/null
/*%end*/
           and m.notification_no in (
             /*%for notificationNo : notificationNoList */
             /*notificationNo*/0
             /*%if notificationNo_has_next */
             /*# "," */
             /*%end */
             /*%end*/
             )
           and s.is_read <> '1'
         order by
             m.reg_date
/*%if isDesc == true*/
             desc
/*%end*/) as notification_is_important
     UNION ALL
     select * from
         (select
              m.notification_message_no
               , m.content
               , m.additional_info
               , s.is_read
               , m.reg_date
               , m.notification_no
               ,case when notification_no in (
                 /*%for notificationNo : notificationNoList */
                 /*notificationNo*/0
                 /*%if notificationNo_has_next */
                 /*# "," */
                 /*%end */
                 /*%end*/
                 )
                         then 1
                     else 0 end as is_important
          from
              mnt_notification_message m,
              mnt_notification_status s
          where
                  m.notification_message_no = s.notification_message_no
            and m.notification_message_no IN (
              select notification_message_no from mnt_notification_message
              where facility_cd = /*facilityCd*/000000 or notification_no = 0
          )
-- del #10110 通知一覧から既読にした通知以外も消える dengshen start
--             and
--                  to_char(m.reg_date,'yyyy-mm-dd') >= to_char(now()-interval'3'month,'yyyy-mm-dd')
-- del #10110 通知一覧から既読にした通知以外も消える dengshen end
            and
                  s.user_id = /*userId*/1
/*%if isNotified != null*/
            and
                  is_notified = /*isNotified*/null
/*%end*/
            and ((m.notification_no in (
              /*%for notificationNo : notificationNoList */
              /*notificationNo*/0
              /*%if notificationNo_has_next */
              /*# "," */
              /*%end */
              /*%end*/
              )
              and s.is_read = '1') or (m.notification_no not in (
              /*%for notificationNo : notificationNoList */
              /*notificationNo*/0
              /*%if notificationNo_has_next */
              /*# "," */
              /*%end */
              /*%end*/
              )))
          order by
              m.reg_date
/*%if isDesc == true*/
              desc
/*%end*/) as notification_not_important
    ) as notification
-- del #10110 通知一覧から既読にした通知以外も消える dengshen start
--     limit 100
-- del #10110 通知一覧から既読にした通知以外も消える dengshen end
/*%if offset != null*/
offset /*offset*/0
/*%end*/
;
-- mod bug 8158 修正 chen end
