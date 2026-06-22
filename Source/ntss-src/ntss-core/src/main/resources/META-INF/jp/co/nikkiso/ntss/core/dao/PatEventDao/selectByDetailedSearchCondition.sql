---add 患者イベント start 劉全航
SELECT DISTINCT
    pat_id
FROM
    pat_event
WHERE
    is_del = '0'
AND is_newest = '1'

/*%if patIdList.size() > 0 */
AND pat_id in /* patIdList */(null)
/*%end */

/*%if conditions.categoryCdList.size() > 0 */
AND category_cd IN /* conditions.categoryCdList */(null)
/*%end*/

/*%if !conditions.eventStartDate.isEmpty() */
AND event_start_date >= /* conditions.eventStartDate */null
/*%end*/

/*%if !conditions.eventEndDate.isEmpty() */
AND event_start_date <= /* conditions.eventEndDate */null
/*%end*/

---add 患者イベント end 劉全航

