-- Cleanup script: Drop all test objects
-- This script cleans up the database after tests complete

-- Drop procedures
BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE create_order';
    DBMS_OUTPUT.PUT_LINE('Dropped procedure: create_order');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4043 THEN -- Ignore "object does not exist" errors
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP PROCEDURE update_order_status';
    DBMS_OUTPUT.PUT_LINE('Dropped procedure: update_order_status');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4043 THEN
            RAISE;
        END IF;
END;
/

-- Drop functions
BEGIN
    EXECUTE IMMEDIATE 'DROP FUNCTION get_user_count_by_status';
    DBMS_OUTPUT.PUT_LINE('Dropped function: get_user_count_by_status');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -4043 THEN
            RAISE;
        END IF;
END;
/

-- Drop tables (orders first due to foreign key)
BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE test_orders CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('Dropped table: test_orders');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN -- Ignore "table does not exist" errors
            RAISE;
        END IF;
END;
/

BEGIN
    EXECUTE IMMEDIATE 'DROP TABLE test_users CASCADE CONSTRAINTS';
    DBMS_OUTPUT.PUT_LINE('Dropped table: test_users');
EXCEPTION
    WHEN OTHERS THEN
        IF SQLCODE != -942 THEN
            RAISE;
        END IF;
END;
/

-- Verify cleanup
DECLARE
    v_table_count NUMBER;
    v_proc_count NUMBER;
    v_func_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_table_count
    FROM user_tables
    WHERE table_name IN ('TEST_USERS', 'TEST_ORDERS');
    
    SELECT COUNT(*) INTO v_proc_count
    FROM user_procedures
    WHERE object_name IN ('CREATE_ORDER', 'UPDATE_ORDER_STATUS');
    
    SELECT COUNT(*) INTO v_func_count
    FROM user_procedures
    WHERE object_name = 'GET_USER_COUNT_BY_STATUS'
    AND object_type = 'FUNCTION';
    
    DBMS_OUTPUT.PUT_LINE('Cleanup verification:');
    DBMS_OUTPUT.PUT_LINE('  Tables remaining: ' || v_table_count);
    DBMS_OUTPUT.PUT_LINE('  Procedures remaining: ' || v_proc_count);
    DBMS_OUTPUT.PUT_LINE('  Functions remaining: ' || v_func_count);
    
    IF v_table_count > 0 OR v_proc_count > 0 OR v_func_count > 0 THEN
        DBMS_OUTPUT.PUT_LINE('✗ Warning: Some objects were not cleaned up');
    ELSE
        DBMS_OUTPUT.PUT_LINE('✓ All test objects cleaned up successfully');
    END IF;
END;
/
