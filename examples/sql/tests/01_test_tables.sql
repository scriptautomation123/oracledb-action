-- Test script: Verify table creation and basic queries
-- This script tests that setup completed successfully

-- Test 1: Verify test_users table exists and has data
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count FROM test_users;
    
    IF v_count < 3 THEN
        RAISE_APPLICATION_ERROR(-20001, 'Test failed: Expected at least 3 users, found ' || v_count);
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('✓ Test 1 passed: test_users table has ' || v_count || ' records');
END;
/

-- Test 2: Verify unique constraint on username
DECLARE
    v_error_occurred BOOLEAN := FALSE;
BEGIN
    BEGIN
        INSERT INTO test_users (username, email) VALUES ('john_doe', 'duplicate@example.com');
    EXCEPTION
        WHEN OTHERS THEN
            v_error_occurred := TRUE;
    END;
    
    IF NOT v_error_occurred THEN
        RAISE_APPLICATION_ERROR(-20002, 'Test failed: Unique constraint not working on username');
    END IF;
    
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('✓ Test 2 passed: Unique constraint on username works correctly');
END;
/

-- Test 3: Verify foreign key constraint
DECLARE
    v_error_occurred BOOLEAN := FALSE;
BEGIN
    BEGIN
        INSERT INTO test_orders (user_id, total_amount) VALUES (99999, 100.00);
    EXCEPTION
        WHEN OTHERS THEN
            v_error_occurred := TRUE;
    END;
    
    IF NOT v_error_occurred THEN
        RAISE_APPLICATION_ERROR(-20003, 'Test failed: Foreign key constraint not working');
    END IF;
    
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('✓ Test 3 passed: Foreign key constraint works correctly');
END;
/

-- Test 4: Verify indexes exist
DECLARE
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM user_indexes
    WHERE table_name IN ('TEST_USERS', 'TEST_ORDERS');
    
    IF v_count < 4 THEN
        RAISE_APPLICATION_ERROR(-20004, 'Test failed: Expected at least 4 indexes, found ' || v_count);
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('✓ Test 4 passed: Found ' || v_count || ' indexes');
END;
/

-- Test 5: Verify active users query
DECLARE
    v_active_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_active_count
    FROM test_users
    WHERE status = 'active';
    
    IF v_active_count < 2 THEN
        RAISE_APPLICATION_ERROR(-20005, 'Test failed: Expected at least 2 active users, found ' || v_active_count);
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('✓ Test 5 passed: Found ' || v_active_count || ' active users');
END;
/
