CREATE OR REPLACE FUNCTION APPS.xx_get_tat_cca_date (p_attribute2 IN VARCHAR2)
   RETURN DATE
IS
   v_serial_prefix   VARCHAR2 (50);
   v_serial_number   NUMBER;
   v_new_serial      VARCHAR2 (50);
   v_cca_no          VARCHAR2 (50);
   v_numeric_suffix  VARCHAR2 (50);
   v_date_cca        DATE;
BEGIN
   -- Extract the alphabetic prefix from attribute2  
   /*v_serial_prefix := REGEXP_SUBSTR (p_attribute2, '^[A-Za-z]+');

   -- Extract the numeric part from attribute2 and increment it by 1
   v_serial_number := TO_NUMBER (REGEXP_SUBSTR (p_attribute2, '[0-9]+$')) + 1;

   -- Construct the new serial number
   v_new_serial := v_serial_prefix || LPAD(TO_NUMBER(REGEXP_SUBSTR(p_attribute2, '[0-9]+$')) + 1, LENGTH(REGEXP_SUBSTR(p_attribute2, '[0-9]+$')), '0'); 
    */
    
   v_serial_prefix := REGEXP_SUBSTR(p_attribute2, '^.*[^0-9]');

   -- Extract only the numeric suffix and increment it
   v_serial_number := TO_NUMBER(REGEXP_SUBSTR(p_attribute2, '[[:digit:]]+$')) + 1;

   -- Preserve leading zeros in numeric suffix
   v_new_serial := v_serial_prefix || LPAD(v_serial_number, LENGTH(REGEXP_SUBSTR(p_attribute2, '[[:digit:]]+$')), '0');
    
   -- Step 1: Search for the new serial number in cca_serial_mapping
   BEGIN
      SELECT ccano
        INTO v_cca_no
        FROM cca_serial_mapping@biatest csm
       WHERE csm.serialno = v_new_serial
         AND csm.cdate = (SELECT MAX (cdate)
                            FROM cca_serial_mapping@biatest
                           WHERE serialno = csm.serialno);
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         BEGIN
            -- Step 2: If not found, search in com_test_master_new
            SELECT cca_no
              INTO v_cca_no
              FROM com_test_master_new@biatest ctn
             WHERE ctn.meter_srl_no = v_new_serial
               AND ctn.meter_srl_no != ctn.cca_no
               AND ctn.meter_srl_no NOT IN ('ABCDEF', 'ABCDEFG', 'ABCDEFGH')
               AND ctn.test_date IN (
                      SELECT MAX (ctn1.test_date)
                        FROM com_test_master_new@biatest ctn1
                       WHERE ctn1.meter_srl_no = ctn.meter_srl_no
                         AND ctn1.cca_no <> '00000000'
                         AND ctn1.meter_srl_no != ctn.cca_no);
         EXCEPTION
            WHEN NO_DATA_FOUND
            THEN
               BEGIN
                  -- Step 3: If not found, search in ft_test_master_new
                  SELECT cca_no
                    INTO v_cca_no
                    FROM ft_test_master_new@biatest ftn
                   WHERE ftn.meter_srl_no = v_new_serial
                     AND ftn.cca_no <> '00000000'
                     AND ftn.test_date IN (
                              SELECT MAX (test_date)
                                FROM ft_test_master_new@biatest
                               WHERE cca_no = ftn.cca_no
                                     AND site_id = ftn.site_id)
                     AND ftn.meter_srl_no NOT IN
                                               ('ABCDEF', 'ABCDEFG', 'ABCDEFGH')
                     AND NVL (ftn.meter_srl_no, '-') != NVL (ftn.cca_no, '|');
               EXCEPTION
                  WHEN NO_DATA_FOUND
                  THEN
                     -- If CCA_NO not found in any table, return NULL
                     RETURN NULL;
               END;
         END;
   END;

   -- Step 4: If CCA_NO found, fetch DATE_CCA
   BEGIN
      SELECT MIN(ab.date_cca)
        INTO v_date_cca
        FROM (
            SELECT ctr.starting_cca, ctr.ending_cca, ctr.date_cca,
                   ctd.part_number,
                   ROW_NUMBER() OVER (PARTITION BY ctr.ending_cca, ctd.part_number ORDER BY ctr.starting_cca DESC) AS rn
              FROM sml.component_traceability_range@biatest ctr,
                   component_traceability_details@biatest ctd
             WHERE ctr.ID = ctd.cca_id
               AND v_cca_no BETWEEN ctr.starting_cca AND ctr.ending_cca
        ) ab
       WHERE ab.rn = 1;

      RETURN v_date_cca;
   EXCEPTION
      WHEN NO_DATA_FOUND
      THEN
         RETURN NULL;
   END;
END xx_get_tat_cca_date;



select xx_get_tat_cca_date('24P0423645') from dual






select REGEXP_SUBSTR ('L24S0002', '[0-9]+$') from dual

select  TO_NUMBER ('0002') + 1 from dual

select LPAD(v_serial_number, LENGTH(v_numeric_suffix), '0');

v_serial_prefix := select REGEXP_SUBSTR('L24S0002', '^.*[^0-9]') from dual

   -- Extract only the numeric suffix and increment it
v_serial_number := select TO_NUMBER(REGEXP_SUBSTR('L24S0002', '[[:digit:]]+$')) + 1 from dual

   -- Preserve leading zeros in numeric suffix
/* Formatted on 2025/02/14 12:19 (Formatter Plus v4.8.8) */
SELECT    REGEXP_SUBSTR (:pm, '^.*[^0-9]')
       || LPAD (TO_NUMBER (REGEXP_SUBSTR (:pm, '[[:digit:]]+$')) + 1,
                LENGTH (REGEXP_SUBSTR (:pm, '[[:digit:]]+$')),
                '0'
               )
  FROM DUAL