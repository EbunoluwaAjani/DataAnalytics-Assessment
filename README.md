Here’s a well-formatted version for your README file:

---

## **Question 1: High-Value Customers with Multiple Products**  

### **Approach**  
- Identified unique users with **savings (`is_regular_savings = 1`)** and **investment (`is_a_fund = 1`)** accounts.  
- Calculated financial metrics, including the number of **savings accounts, investment accounts, and total confirmed deposits per user**.  
- Filtered users with **both savings and investment products (`multiple_prod = 1`)** to analyze their engagement.  
- Retrieved and displayed **customer details (name, account statistics, and total deposit)**, sorted by descending total deposits.  

### **Challenges & Fixes**  
- **Overcounting issue in `CASE` statements**:  
  - Initially, using:
    ```sql
    SUM(CASE WHEN a.is_regular_savings = 1 THEN 1 ELSE 0 END) AS savings_count
    ```
    resulted in **overcounting occurrences** rather than counting unique users.  
  - **Fix:** Replaced `SUM()` with `COUNT(DISTINCT a.id)` to ensure each **plan** is counted only once per user.  

### **Result**  
From the available records, **no users were found with both savings and investment accounts**.

### **Transaction Frequency Analysis**
#### **Approach**
- Calculated the average **transactions per customer per month**.
- Categorized users into **High Frequency (≥10 transactions/month)**, **Medium Frequency (3-9 transactions/month)**, and **Low Frequency (≤2 transactions/month)**.
- Aggregated **customer counts** per frequency category.


#### **Result**
| Frequency Category | Customer Count | Avg Transactions/Month |
|------------------|---------------|----------------------|
| High Frequency  | 211           | 61.04               |
| Medium Frequency | 394           | 5.02                |
| Low Frequency   | 778           | 1.27                |


### **Account Inactivity Alert**
#### **Approach**
- Retrieved the **last transaction date** for each active account.
- Computed the **number of inactivity days** (`DATEDIFF(CURRENT_DATE, last_transaction_date)`).
- Filtered accounts with **no inflow in the past 365 days**.

#### **Challenges & Fixes**
- **Handling NULL values in transaction dates:** Some accounts had never had transactions, leading to errors.
- **Fix:** Used `COALESCE(MAX(transaction_date), '2000-01-01')` to **avoid NULL issues**.

#### **Result**
1,638 accounts flagged as inactive, ranging from **366 to 3,165 days** of inactivity.

---

### **Customer Lifetime Value (CLV) Estimation**
#### **Approach**
- Calculated **account tenure (months since signup)**.
- Counted total **transactions per customer**.
- Estimated **CLV = (total_transactions / tenure) * 12 * avg_profit_per_transaction**.

#### **Challenges & Fixes**
- **Division by zero error:** Users who signed up recently had **zero tenure months**, causing calculation failures.
- **Fix:** Used `NULLIF(tenure_months, 0)` to **prevent divide-by-zero issues**.

#### **Result**
CLV computed for all users, ordered from **highest to lowest**.

#### **Production Readiness**
To ensure the script was production-ready, SQL formatting and linting were performed using sqlfmt, which helped improve code readability, maintainability, and consistency before deployment.
