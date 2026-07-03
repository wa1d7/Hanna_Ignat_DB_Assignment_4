# Hanna_Ignat_DB_Assignment_4

ERD
```mermaid
  erDiagram
      RESTAURANTS {
          UUID id PK
          VARCHAR address
          VARCHAR phone_number
          VARCHAR store_code
      }
  
      EMPLOYEES {
          UUID id PK
          UUID restaurant_id FK
          VARCHAR first_name
          VARCHAR last_name
          VARCHAR role
          DECIMAL hourly_rate
      }
  
      MENU_ITEMS {
          UUID id PK
          VARCHAR name
          VARCHAR category
          DECIMAL price
          BOOLEAN is_active
      }
  
      NUTRITION_FACTS {
          UUID menu_item_id PK, FK
          INT calories
          INT protein_g
          INT carbs_g
          INT fat_g
      }
  
      ORDERS {
          UUID id PK
          UUID restaurant_id FK
          TIMESTAMP order_date
          DECIMAL total_amount
      }
  
      ORDER_ITEMS {
          UUID id PK
          UUID order_id FK
          UUID menu_item_id FK
          INT quantity
          DECIMAL subtotal
      }
  
      RESTAURANTS ||--o{ EMPLOYEES: "employs"
      RESTAURANTS ||--o{ ORDERS: "processes"
      MENU_ITEMS ||--|| NUTRITION_FACTS: "has"
      ORDERS ||--o{ ORDER_ITEMS: "contains"
      MENU_ITEMS ||--o{ ORDER_ITEMS: "included in"
```



Indexes optimisation:

code:
```
EXPLAIN ANALYZE 
SELECT * FROM order_items 
WHERE order_id = 'bd604b49-a053-40d9-9aac-ad4f88913322';
```
indexes:

```
CREATE INDEX idx_orders_restaurant_id ON orders(restaurant_id);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_menu_item_id ON order_items(menu_item_id);
```


result without:
<img width="1625" height="549" alt="image" src="https://github.com/user-attachments/assets/557ee49f-2481-414e-8752-59f53b990ab9" />

result with them:
<img width="1680" height="576" alt="image" src="https://github.com/user-attachments/assets/f70132ed-4449-41fc-b70f-18041edacd8c" />

View, roles, procedure, triger, etc in scripts file.

### Database Relationships

**1:1 (One-to-One)**
* **Example:** A **Menu Item** and its **Nutrition Facts**. A Whopper has exactly one set of nutritional macros, and that specific set of macros belongs only to the Whopper

**1:M (One-to-Many)**
* **Example:** **Orders** and **Menu Items**.  single order can contain many different burgers and drinks. At the same time, a specific burger (like a Cheeseburger) can appear in thousands of different orders. The junction table `order_items` sits between them to record each specific

**M:M (Many-to-Many)**
* **Example:** **Orders** and **Menu Items**. A single order can contain many different burgers and drinks. At the same time, a specific burger (like a Cheeseburger) can appear in thousands of different orders. The junction table `order_items` sits between them to record each specific instance.

### Database Constraints
* **Primary Key (PK):** `id UUID PRIMARY KEY`
* **Foreign Key (FK):**  You cannot assign an employee to a `restaurant_id` that doesn't exist
* **Check:** `CHECK (price >= 0)` ensures an item cannot have a negative cost
* **Unique:** `store_code UNIQUE` ensures two branches don't accidentally get the same code
* **Not Null:**`first_name NOT NULL` means an employee record must have a name

### In this project were responsible:

**Ignat**-For normilize db architecture, ddl scripts, role, view, index

**Hanna**-Python generation script, procedure and triggers, explain analyse
