-- Setup script: Create stored procedures and functions
-- This script creates reusable database objects

-- Create a function to get user count by status
CREATE OR REPLACE FUNCTION get_user_count_by_status(p_status VARCHAR2)
RETURN NUMBER
IS
    v_count NUMBER;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM test_users
    WHERE status = p_status;
    
    RETURN v_count;
END;
/

-- Create a procedure to create an order
CREATE OR REPLACE PROCEDURE create_order(
    p_user_id IN NUMBER,
    p_amount IN NUMBER,
    p_order_id OUT NUMBER
)
IS
BEGIN
    INSERT INTO test_orders (user_id, total_amount, status)
    VALUES (p_user_id, p_amount, 'pending')
    RETURNING order_id INTO p_order_id;
    
    COMMIT;
END;
/

-- Create a procedure to update order status
CREATE OR REPLACE PROCEDURE update_order_status(
    p_order_id IN NUMBER,
    p_status IN VARCHAR2
)
IS
BEGIN
    UPDATE test_orders
    SET status = p_status
    WHERE order_id = p_order_id;
    
    COMMIT;
END;
/
