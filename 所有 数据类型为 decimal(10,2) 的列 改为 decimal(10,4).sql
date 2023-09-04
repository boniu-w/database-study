DELIMITER $$
CREATE PROCEDURE `update_precision`()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE COLUMN_NAME VARCHAR(255);
    DECLARE TABLE_NAME VARCHAR(255);
    DECLARE cols_cursor CURSOR FOR 
        SELECT COLUMN_NAME, TABLE_NAME 
        FROM INFORMATION_SCHEMA.COLUMNS 
        WHERE TABLE_SCHEMA='v7127_process_pipe_inspection_and_assessment_system_xian' 
          AND DATA_TYPE='decimal' AND NUMERIC_PRECISION=10 AND NUMERIC_SCALE=2;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;
	
    OPEN cols_cursor;

    read_cols_loop: LOOP
        FETCH cols_cursor INTO COLUMN_NAME, TABLE_NAME;
        IF done THEN
            LEAVE read_cols_loop;
        END IF;
        SELECT CONCAT('ALTER TABLE `', TABLE_NAME, '` MODIFY COLUMN `', COLUMN_NAME, '` decimal(10,4);');
    END LOOP;

    CLOSE cols_cursor;
END$$
DELIMITER ;

call update_precision();