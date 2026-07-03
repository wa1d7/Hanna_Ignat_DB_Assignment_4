import uuid
import random
import psycopg2
from psycopg2.extras import execute_values
from faker import Faker
from datetime import datetime, timedelta

# Update these credentials for your local PostgreSQL instance
HOST = 'localhost'
USER = 'postgres'
PASSWORD = '1'
DATABASE = 'bk_database'
PORT = '5432'

fake = Faker()

def create_connection():
    try:
        connection = psycopg2.connect(
            host=HOST, port=PORT, user=USER, password=PASSWORD, dbname=DATABASE
        )
        print("Connected to PostgreSQL successfully")
        return connection
    except Exception as e:
        print(f"Connection error: {e}")
        return None

def generate_and_insert_data(connection):
    cursor = connection.cursor()

    # 1. Generate Restaurants
    print("Inserting Restaurants...")
    restaurants = [(str(uuid.uuid4()), fake.address(), fake.phone_number(), f"BK-{i}") for i in range(1, 6)]
    execute_values(cursor, "INSERT INTO restaurants (id, address, phone_number, store_code) VALUES %s", restaurants)

    # 2. Generate Employees
    print("Inserting Employees...")
    roles = ["Cashier", "Cook", "Manager", "Shift Supervisor"]
    employees = []
    restaurant_ids = [r[0] for r in restaurants] # Grab the IDs we just created

    for rest_id in restaurant_ids:
        num_employees = random.randint(5, 12)
        for _ in range(num_employees):
            emp_id = str(uuid.uuid4())
            first_name = fake.first_name()
            last_name = fake.last_name()
            role = random.choice(roles)
            hourly_rate = round(random.uniform(10.0, 25.0), 2)
            
            employees.append((emp_id, rest_id, first_name, last_name, role, hourly_rate))

    execute_values(cursor, "INSERT INTO employees (id, restaurant_id, first_name, last_name, role, hourly_rate) VALUES %s", employees)

    # 3. Generate Menu Items & Nutrition
    print("Inserting Menu Items & Nutrition...")
    menu_data = [
        ("Whopper", "Burgers", 6.99, 650, 28, 49, 37),
        ("Cheeseburger", "Burgers", 2.99, 280, 15, 27, 13),
        ("Fries (Medium)", "Sides", 3.49, 380, 5, 53, 17),
        ("Onion Rings", "Sides", 3.49, 400, 4, 48, 21),
        ("Coke (Large)", "Drinks", 2.49, 290, 0, 75, 0)
    ]
    
    menu_items = []
    nutrition = []
    for item in menu_data:
        item_id = str(uuid.uuid4())
        menu_items.append((item_id, item[0], item[1], item[2], True))
        nutrition.append((item_id, item[3], item[4], item[5], item[6]))
        
    execute_values(cursor, "INSERT INTO menu_items (id, name, category, price, is_active) VALUES %s", menu_items)
    execute_values(cursor, "INSERT INTO nutrition_facts (menu_item_id, calories, protein_g, carbs_g, fat_g) VALUES %s", nutrition)

    # 4. Generate Orders & Order Items
    print("Generating Orders and Order Items. This will take a few seconds...")
    orders = []
    order_items = []
    
    menu_lookup = {m[0]: m[3] for m in menu_items} 
    menu_ids = list(menu_lookup.keys())

    # Generates 100,000 orders. At ~5 items per order, this yields ~500,000 order_items rows
    for _ in range(100000):
        order_id = str(uuid.uuid4())
        rest_id = random.choice(restaurant_ids)
        order_date = datetime.now() - timedelta(days=random.randint(0, 365))
        
        # total_amount is 0; the PostgreSQL trigger handles the actual math
        orders.append((order_id, rest_id, order_date, 0))
        
        num_items = random.randint(1, 8)
        for _ in range(num_items):
            item_id = str(uuid.uuid4())
            menu_id = random.choice(menu_ids)
            qty = random.randint(1, 3)
            subtotal = round(qty * menu_lookup[menu_id], 2)
            
            order_items.append((item_id, order_id, menu_id, qty, subtotal))

    print(f"Executing batch insert for {len(orders)} orders...")
    execute_values(cursor, "INSERT INTO orders (id, restaurant_id, order_date, total_amount) VALUES %s", orders)
    
    print(f"Executing batch insert for {len(order_items)} order items...")
    execute_values(cursor, "INSERT INTO order_items (id, order_id, menu_item_id, quantity, subtotal) VALUES %s", order_items)

    connection.commit()
    cursor.close()
    print("Data generation complete!")

if __name__ == "__main__":
    conn = create_connection()
    if conn:
        generate_and_insert_data(conn)
        conn.close()