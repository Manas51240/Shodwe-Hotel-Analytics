# 📐 Hospitality KPI & Metrics Formulation Guide

This guide details the mathematical equations, business rationale, and DAX / SQL implementations for all key performance indicators analyzed in this project.

---

### 1. Revenue Realized (Net Revenue)
- **Concept:** The actual cash retained by the hotel chain after processing cancellations and non-refundable deposits.
- **Business Rule:**
  - If a guest completes their stay (`Checked Out`) or fails to arrive (`No show`), 100% of the booking value is retained.
  - If a guest cancels (`Cancelled`), a 40% cancellation charge is retained and 60% is refunded.
- **DAX Formula:**
  ```dax
  Revenue Realized = SUM(fact_bookings[revenue_realized])
  ```
- **SQL Expression:**
  ```sql
  SUM(revenue_realized)
  ```

---

### 2. Occupancy Rate (%)
- **Concept:** The percentage of total available room inventory successfully booked and occupied across properties.
- **Hospitality Benchmark:** Healthy full-service hotels typically aim for 55% – 70% occupancy depending on season.
- **Mathematical Formula:**
  $$\text{Occupancy \%} = \frac{\text{Total Successful Bookings}}{\text{Total Available Capacity}} \times 100$$
- **DAX Formula:**
  ```dax
  Occupancy % = DIVIDE(SUM(fact_aggregated_bookings[successful_bookings]), SUM(fact_aggregated_bookings[capacity]), 0) * 100
  ```

---

### 3. Average Daily Rate (ADR)
- **Concept:** The average rental revenue realized per occupied room over a given operational period.
- **Hospitality Importance:** Measures pure pricing power independent of room volume.
- **Mathematical Formula:**
  $$\text{ADR} = \frac{\text{Total Realized Revenue}}{\text{Total Bookings / Stays}}$$
- **DAX Formula:**
  ```dax
  ADR = DIVIDE([Revenue Realized], COUNT(fact_bookings[booking_id]), 0)
  ```

---

### 4. Revenue Per Available Room (RevPAR)
- **Concept:** The gold standard in hospitality management. RevPAR combines both pricing power (ADR) and capacity utilization (Occupancy %) into a single metric.
- **Mathematical Relationship:**
  $$\text{RevPAR} = \text{ADR} \times \text{Occupancy Rate}$$
  $$\text{RevPAR} = \frac{\text{Total Realized Revenue}}{\text{Total Sellable Capacity}}$$
- **DAX Formula:**
  ```dax
  RevPAR = DIVIDE([Revenue Realized], SUM(fact_aggregated_bookings[capacity]), 0)
  ```

---

### 5. Realisation Percentage (%)
- **Concept:** The efficiency of converting gross bookings generated into final retained revenue.
- **Mathematical Formula:**
  $$\text{Realisation \%} = \frac{\text{Total Revenue Realized}}{\text{Total Revenue Generated}} \times 100$$
- **DAX Formula:**
  ```dax
  Realisation % = DIVIDE([Revenue Realized], SUM(fact_bookings[revenue_generated]), 0) * 100
  ```

---

### 6. Cancellation & No-Show Rates
- **Concept:** Diagnoses booking churn and channel unreliability.
- **Formulas:**
  $$\text{Cancellation \%} = \frac{\text{Count of Cancelled Bookings}}{\text{Total Bookings Received}} \times 100$$
  $$\text{No-Show \%} = \frac{\text{Count of No-Shows}}{\text{Total Bookings Received}} \times 100$$

---

### 7. DSRN & DURN (Room Night Velocity)
- **DSRN (Daily Sellable Room Nights):** Average number of rooms available to sell per calendar day.
  $$\text{DSRN} = \frac{\text{Total Capacity}}{\text{Total Operating Days}}$$
- **DURN (Daily Utilized Room Nights):** Average number of rooms occupied by customers per calendar day.
  $$\text{DURN} = \frac{\text{Total Successful Stays}}{\text{Total Operating Days}}$$
