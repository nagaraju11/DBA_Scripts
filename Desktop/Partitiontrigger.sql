-- FUNCTION: public.func_inventory_movement_insert_trigger()

-- DROP FUNCTION public.func_inventory_movement_insert_trigger();

CREATE FUNCTION public.func_inventory_movement_insert_trigger()
    RETURNS trigger
    LANGUAGE 'plpgsql'
    COST 100
    VOLATILE NOT LEAKPROOF
AS $BODY$
DECLARE
      m_ varchar(3);
	  y_ bigint;
	  r1 text;
	  r2 text;
	  chk_cond text;
	  c_table TEXT;
	  c_table1 text;
	  m_table1 text;
    
    BEGIN

      m_ := to_char(NEW.report_date::date,'MM');
	  y_ := to_char(NEW.report_date,'YYYY');
      c_table := TG_TABLE_NAME || '_' || 'y'||y_||'m'||m_;
	  c_table1 := 'public.' || c_table;
      m_table1 := 'core.'||TG_TABLE_NAME;
      IF NOT EXISTS(SELECT relname FROM pg_class WHERE relname=c_table) THEN
	
      RAISE NOTICE 'values out of range partition, creating  partition table:  public.%',c_table;
		
	    r1 := y_||'-'|| m_||'-01';
		r2 := y_||'-'|| cast(m_ as integer)+1 ||'-01';
		
		IF cast(m_ as integer) = 12 then r2 := y_+1||'-01-01'  ; 
		END IF;
		chk_cond := 'report_date >= '''|| r1 ||''' AND report_date < ''' || r2 || '''';
        EXECUTE 'CREATE TABLE public.' || c_table || '(check ('|| chk_cond||')) INHERITS (' ||'core.'|| TG_TABLE_NAME || ');';
		-- Create index on new child table

        EXECUTE  'Create index on ' || c_table1 ||'(report_date);';

        EXECUTE 'ALTER TABLE '||c_table1 ||' OWNER to postgres;'; 

        EXECUTE 'GRANT SELECT ON TABLE '||c_table1 ||' TO readonly;';

       END IF;
	  
      EXECUTE 'INSERT INTO ' || c_table1 || ' SELECT(' || m_table1 || ' ' || quote_literal(NEW) || ').* RETURNING load_dttm;';
	  
      RETURN NULL;
    END;
$BODY$;
