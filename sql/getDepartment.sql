/*
 * function: évaluation code Département, à partir code INSEE
 */

-- calcul code Département (à partir INSEE)
drop function IF EXISTS getdepartment(character varying);
CREATE OR REPLACE FUNCTION getDepartment(citycode VARCHAR(5)) 
RETURNS VARCHAR(3) AS 
$$
DECLARE
	dept VARCHAR(3);
BEGIN
	dept := case
		when substr(citycode, 1, 2) between '97' and '98' then
			substr(citycode, 1, 3)
		else
			substr(citycode, 1, 2)
		end;

	return dept;
END;
$$ LANGUAGE plpgsql;	

