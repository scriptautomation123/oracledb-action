-- Test script: Test stored procedures and functions
-- This script tests database objects created in setup

-- Test 1: Test get_user_count_by_status function
DECLARE
    v_active_count NUMBER;
    v_inactive_count NUMBER;
BEGIN
    v_active_count := get_user_count_by_status('active');
    v_inactive_count := get_user_count_by_status('inactive');
    
    IF v_active_count < 2 THEN
        RAISE_APPLICATION_ERROR(-20101, 'Test failed: Expected at least 2 active users');
    END IF;
    
    IF v_inactive_count < 1 THEN
        RAISE_APPLICATION_ERROR(-20102, 'Test failed: Expected at least 1 inactive user');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('✓ Test 1 passed: get_user_count_by_status function works correctly');
    DBMS_OUTPUT.PUT_LINE('  Active users: ' || v_active_count);
    DBMS_OUTPUT.PUT_LINE('  Inactive users: ' || v_inactive_count);
END;
/

-- Test 2: Test create_order procedure
DECLARE
    v_order_id NUMBER;
    v_user_id NUMBER;
    v_amount NUMBER := 99.99;
    v_count NUMBER;
BEGIN
    -- Get first user ID
    SELECT user_id INTO v_user_id FROM test_users WHERE ROWNUM = 1;
    
    -- Create an order
    create_order(v_user_id, v_amount, v_order_id);
    
    -- Verify order was created
    SELECT COUNT(*) INTO v_count
    FROM test_orders
    WHERE order_id = v_order_id
    AND user_id = v_user_id
    AND total_amount = v_amount;
    
    IF v_count != 1 THEN
        RAISE_APPLICATION_ERROR(-20103, 'Test failed: Order not created correctly');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('✓ Test 2 passed: create_order procedure works correctly');
    DBMS_OUTPUT.PUT_LINE('  Created order ID: ' || v_order_id);
END;
/

-- Test 3: Test update_order_status procedure
DECLARE
    v_order_id NUMBER;
    v_new_status VARCHAR2(20) := 'completed';
    v_updated_status VARCHAR2(20);
BEGIN
    -- Get an order ID
    SELECT order_id INTO v_order_id FROM test_orders WHERE ROWNUM = 1;
    
    -- Update the status
    update_order_status(v_order_id, v_new_status);
    
    -- Verify status was updated
    SELECT status INTO v_updated_status
    FROM test_orders
    WHERE order_id = v_order_id;
    
    IF v_updated_status != v_new_status THEN
        RAISE_APPLICATION_ERROR(-20104, 'Test failed: Order status not updated correctly');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('✓ Test 3 passed: update_order_status procedure works correctly');
    DBMS_OUTPUT.PUT_LINE('  Order ' || v_order_id || ' status: ' || v_updated_status);
END;
/

-- Test 4: Test multiple orders for same user
DECLARE
    v_user_id NUMBER;
    v_order_id1 NUMBER;
    v_order_id2 NUMBER;
    v_order_count NUMBER;
BEGIN
    SELECT user_id INTO v_user_id FROM test_users WHERE ROWNUM = 1;
    
    create_order(v_user_id, 50.00, v_order_id1);
    create_order(v_user_id, 75.00, v_order_id2);
    
    SELECT COUNT(*) INTO v_order_count
    FROM test_orders
    WHERE user_id = v_user_id;
    
    IF v_order_count < 2 THEN
        RAISE_APPLICATION_ERROR(-20105, 'Test failed: Multiple orders not created');
    END IF;
    
    DBMS_OUTPUT.PUT_LINE('✓ Test 4 passed: Multiple orders created successfully');
    DBMS_OUTPUT.PUT_LINE('  User ' || v_user_id || ' has ' || v_order_count || ' orders');
END;
/
