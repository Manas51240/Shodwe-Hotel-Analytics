# 📖 Shodwe Hospitality Data Dictionary

Comprehensive dimensional and transactional schema documentation for Shodwe Hotels.

---

### 1. `dim_date` (Date Dimension)
Contains temporal attributes covering the May – July operational quarter.

| Column Name | Data Type | Nullable | Description | Sample Values |
| :--- | :--- | :--- | :--- | :--- |
| `date` | `DATE` | No | Primary key; individual operational calendar date. | `2022-05-01` |
| `mmm_yy` | `VARCHAR(10)` | No | Formatted month and year representation. | `May 22`, `Jun 22`, `Jul 22` |
| `week_no` | `VARCHAR(10)` | No | Weekly identifier across the business fiscal calendar. | `W 19`, `W 20` |
| `day_type` | `VARCHAR(15)` | No | Operational day classification: `Weekend` (Fri/Sat) or `Weekday`. | `Weekend`, `Weekday` |

---

### 2. `dim_hotels` (Property Dimension)
Contains property-level metadata across metropolitan branches.

| Column Name | Data Type | Nullable | Description | Sample Values |
| :--- | :--- | :--- | :--- | :--- |
| `property_id` | `INT` | No | Primary key; unique hotel property identifier. | `16558`, `17560` |
| `property_name`| `VARCHAR(100)`| No | Brand and location name of the hotel property. | `Atliq Grands`, `Atliq Palace` |
| `category` | `VARCHAR(50)` | No | Market segment tier: `Luxury` or `Business`. | `Luxury`, `Business` |
| `city` | `VARCHAR(50)` | No | Metropolitan operational location. | `Mumbai`, `Bangalore`, `Delhi`, `Hyderabad` |

---

### 3. `dim_rooms` (Room Dimension)
Defines room categories and tier classifications.

| Column Name | Data Type | Nullable | Description | Sample Values |
| :--- | :--- | :--- | :--- | :--- |
| `room_id` | `VARCHAR(10)` | No | Primary key; internal category code. | `RT1`, `RT2`, `RT3`, `RT4` |
| `room_class` | `VARCHAR(50)` | No | Customer-facing room classification. | `Standard`, `Elite`, `Premium`, `Presidential` |

---

### 4. `fact_aggregated_bookings` (Aggregated Capacity Fact)
High-level daily inventory tracking table for capacity planning and occupancy analysis.

| Column Name | Data Type | Nullable | Description |
| :--- | :--- | :--- | :--- |
| `property_id` | `INT` | No | Foreign key referencing `dim_hotels(property_id)`. |
| `check_in_date`| `DATE` | No | Foreign key referencing `dim_date(date)`. |
| `room_category`| `VARCHAR(10)` | No | Foreign key referencing `dim_rooms(room_id)`. |
| `successful_bookings` | `INT` | No | Count of confirmed bookings received for that property/date/room. |
| `capacity` | `INT` | No | Maximum inventory of rooms available to sell. |

---

### 5. `fact_bookings` (Granular Booking Transaction Fact)
Transactional-level table recording every individual customer reservation and financial outcome.

| Column Name | Data Type | Nullable | Description | Business Rules & Notes |
| :--- | :--- | :--- | :--- | :--- |
| `booking_id` | `VARCHAR(50)` | No | Unique transaction primary key. | e.g. `May012216558RT11` |
| `property_id` | `INT` | No | Foreign key referencing `dim_hotels(property_id)`. | |
| `booking_date` | `DATE` | No | Date on which the customer reserved the room. | Must be $\le$ `check_in_date`. |
| `check_in_date`| `DATE` | No | Scheduled check-in date. | Foreign key to `dim_date(date)`. |
| `check_out_date`| `DATE` | No | Scheduled check-out date. | Must be $\ge$ `check_in_date`. |
| `no_guests` | `INT` | No | Total guest head-count for reservation. | Typically $1$ to $6$. |
| `room_category`| `VARCHAR(10)` | No | Foreign key to `dim_rooms(room_id)`. | RT1, RT2, RT3, RT4. |
| `booking_platform` | `VARCHAR(50)` | No | Distribution channel. | `MakeMyTrip`, `LogTrip`, `Direct Online`, etc. |
| `ratings_given`| `DECIMAL(3,1)`| Yes | Customer review rating ($1.0$ to $5.0$). | Null if guest did not submit review. |
| `booking_status`| `VARCHAR(30)` | No | Final reservation state. | `Checked Out`, `Cancelled`, `No show`. |
| `revenue_generated` | `DECIMAL(12,2)` | No | Gross booking value before modifications. | Base transaction amount. |
| `revenue_realized` | `DECIMAL(12,2)` | No | Net retained cash by the hotel. | **If Cancelled:** Hotel keeps 40% (60% refunded). <br/>**If Checked Out / No Show:** Hotel keeps 100%. |
