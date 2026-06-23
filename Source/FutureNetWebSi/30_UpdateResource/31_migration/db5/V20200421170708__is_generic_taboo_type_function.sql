DROP FUNCTION IF EXISTS is_generic_taboo_type(character varying, character varying);

CREATE OR REPLACE FUNCTION is_generic_taboo_type(
	medicine_type character varying,
	cd character varying,
	patId bigint)
    RETURNS integer
    LANGUAGE 'plpgsql'
AS $BODY$DECLARE
  taboo_allergy_class integer := 0; -- normal
  number_of_taboo integer := 0;
  number_of_allergy integer := 0;
BEGIN
	-- count taboo
 	select 
		count(pat_id) into number_of_taboo
	from pat_main
	where pat_id = patId and json_array_contains_key_pair(COALESCE(taboo_allergy_info, '[]'), 'taboo_allergy_cd','taboo_allergy_class', ARRAY(
			select taboo_allergy_cd
			from mst_taboo_allergy
			where 
				json_array_contains_array_value(COALESCE(detail_info, '[]'), 'type', medicine_type)
			and json_array_contains_array_value(COALESCE(detail_info, '[]'), 'cd', cd)
			and json_array_contains_array_value(COALESCE(detail_info, '[]'), 'classCd','6') -- CLASS_GENERIC_MEDICINE = "6"; // ダイアライザ
		)::int[],'1');
	
	-- count allergy
	select 
		count(pat_id) into number_of_allergy
	from pat_main
		where pat_id = patId and json_array_contains_key_pair(COALESCE(taboo_allergy_info, '[]'), 'taboo_allergy_cd','taboo_allergy_class', ARRAY(
			select taboo_allergy_cd
			from mst_taboo_allergy
			where 
			json_array_contains_array_value(COALESCE(detail_info, '[]'), 'type', medicine_type)
			and json_array_contains_array_value(COALESCE(detail_info, '[]'), 'cd', cd)
			and json_array_contains_array_value(COALESCE(detail_info, '[]'), 'classCd', '6') -- CLASS_GENERIC_MEDICINE = "6"; // ダイアライザ
		)::int[],'2');

	if (number_of_allergy > 0 and number_of_taboo > 0) then
		taboo_allergy_class := 3; -- taboo + allergy
	elsif number_of_allergy > 0 then
		taboo_allergy_class := 2; -- allergy
	elsif number_of_taboo > 0 then
		taboo_allergy_class := 1; -- taboo
	end if;
	RETURN taboo_allergy_class;
END;
$BODY$;