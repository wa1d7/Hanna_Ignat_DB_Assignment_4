-- 1 create 3 different users
DO $$
BEGIN
    IF NOT EXISTS (SELECT 1 FROM pg_roles WHERE rolname = 'bk_admin') THEN
        CREATE ROLE bk_admin LOGIN PASSWORD 'admin_pass';
        CREATE ROLE bk_manager LOGIN PASSWORD 'manager_pass';
        CREATE ROLE bk_cashier LOGIN PASSWORD 'cashier_pass';
    END IF;
END
$$;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO bk_admin;
GRANT SELECT, INSERT, UPDATE ON orders, order_items TO bk_manager;
GRANT SELECT ON menu_items TO bk_cashier;
GRANT INSERT ON orders, order_items TO bk_cashier;
-- 2 create at least 1 view
CREATE OR REPLACE VIEW daily_sales_summary AS
SELECT 
    r.store_code,
    DATE(o.order_date) AS sale_date,
    COUNT(o.id) AS total_orders,
    SUM(o.total_amount) AS daily_revenue
FROM restaurants r
JOIN orders o ON r.id = o.restaurant_id
GROUP BY r.store_code, DATE(o.order_date);
-- 3 create at least 1 trigger/function
-- automatically updates total_amount in orders when items are added
CREATE OR REPLACE FUNCTION update_order_total()
RETURNS TRIGGER AS $$
BEGIN
    UPDATE orders
    SET total_amount = (
        SELECT COALESCE(SUM(subtotal), 0)
        FROM order_items
        WHERE order_id = NEW.order_id
    )
    WHERE id = NEW.order_id;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;
CREATE TRIGGER trigger_update_order_total
AFTER INSERT OR UPDATE OR DELETE ON order_items
FOR EACH ROW EXECUTE FUNCTION update_order_total();
-- 4 create at least 1 stored procedure
-- inserts a menu item and its nutritional data simultaneously
CREATE OR REPLACE PROCEDURE add_menu_item(
    p_id UUID, p_name VARCHAR, p_category VARCHAR, p_price DECIMAL,
    p_calories INT, p_protein INT, p_carbs INT, p_fat INT
)
LANGUAGE plpgsql AS $$
BEGIN
    INSERT INTO menu_items (id, name, category, price)
    VALUES (p_id, p_name, p_category, p_price);
    INSERT INTO nutrition_facts (menu_item_id, calories, protein_g, carbs_g, fat_g)
    VALUES (p_id, p_calories, p_protein, p_carbs, p_fat);
    COMMIT;
END;
$$;
