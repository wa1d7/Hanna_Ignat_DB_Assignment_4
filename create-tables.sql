DROP TABLE IF EXISTS order_items CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS nutrition_facts CASCADE;
DROP TABLE IF EXISTS menu_items CASCADE;
DROP TABLE IF EXISTS employees CASCADE;
DROP TABLE IF EXISTS restaurants CASCADE;
CREATE TABLE restaurants (
    id UUID PRIMARY KEY,
    address VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20),
    store_code VARCHAR(10) UNIQUE NOT NULL
);
CREATE TABLE employees (
    id UUID PRIMARY KEY,
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    role VARCHAR(50) NOT NULL,
    hourly_rate DECIMAL(5, 2) CHECK (hourly_rate > 0)
);
CREATE TABLE menu_items (
    id UUID PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    category VARCHAR(50),
    price DECIMAL(6, 2) CHECK (price >= 0),
    is_active BOOLEAN DEFAULT TRUE
);
CREATE TABLE nutrition_facts (
    menu_item_id UUID PRIMARY KEY REFERENCES menu_items(id) ON DELETE CASCADE,
    calories INT CHECK (calories >= 0),
    protein_g INT CHECK (protein_g >= 0),
    carbs_g INT CHECK (carbs_g >= 0),
    fat_g INT CHECK (fat_g >= 0)
);
CREATE TABLE orders (
    id UUID PRIMARY KEY,
    restaurant_id UUID REFERENCES restaurants(id) ON DELETE CASCADE,
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    total_amount DECIMAL(8, 2) DEFAULT 0.00
);
CREATE TABLE order_items (
    id UUID PRIMARY KEY,
    order_id UUID REFERENCES orders(id) ON DELETE CASCADE,
    menu_item_id UUID REFERENCES menu_items(id) ON DELETE RESTRICT,
    quantity INT CHECK (quantity > 0),
    subtotal DECIMAL(8, 2) CHECK (subtotal >= 0)
);
CREATE INDEX idx_orders_restaurant_id ON orders(restaurant_id);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_menu_item_id ON order_items(menu_item_id);
