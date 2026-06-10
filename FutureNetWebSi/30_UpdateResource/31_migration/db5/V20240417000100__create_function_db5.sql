CREATE OR REPLACE FUNCTION unescape_html(text_in text)  
RETURNS text AS 
$$
  
DECLARE  
    text_out text := text_in;  
BEGIN  
  
    text_out := regexp_replace(text_out, '&lt;', '<', 'g');  
    text_out := regexp_replace(text_out, '&gt;', '>', 'g');  
    text_out := regexp_replace(text_out, '&amp;', '&', 'g');    
    text_out := regexp_replace(text_out, '&nbsp;', ' ', 'g');
    RETURN text_out;  
END;  

$$
 LANGUAGE plpgsql IMMUTABLE;