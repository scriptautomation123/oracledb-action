-- Setup script: Create test tables and schemas
-- This script runs before tests to set up the database environment

-- Create a test table for users
CREATE TABLE test_users (
    user_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    username VARCHAR2(50) NOT NULL UNIQUE,
    email VARCHAR2(100) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR2(20) DEFAULT 'active'
);

-- Create index for better query performance
CREATE INDEX idx_users_email ON test_users(email);
CREATE INDEX idx_users_status ON test_users(status);

-- Create a test table for orders
CREATE TABLE test_orders (
    order_id NUMBER GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
    user_id NUMBER NOT NULL,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount NUMBER(10,2) NOT NULL,
    status VARCHAR2(20) DEFAULT 'pending',
    CONSTRAINT fk_orders_user FOREIGN KEY (user_id) REFERENCES test_users(user_id)
);

-- Create index for orders
CREATE INDEX idx_orders_user ON test_orders(user_id);
CREATE INDEX idx_orders_status ON test_orders(status);

-- Insert sample data
INSERT INTO test_users (username, email, status) 
VALUES ('john_doe', 'john@example.com', 'active');

INSERT INTO test_users (username, email, status) 
VALUES ('jane_smith', 'jane@example.com', 'active');

INSERT INTO test_users (username, email, status) 
VALUES ('bob_jones', 'bob@example.com', 'inactive');

-- Commit the setup
COMMIT;
