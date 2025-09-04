# 🛒 Vending Machine Simulator (x86 Assembly)

A complete, menu-driven vending machine simulation written in x86 Assembly Language (MASM/TASM syntax). This project demonstrates low-level programming mastery by implementing a dual-mode system with a customer-facing interface and a secure admin backend, all in pure assembly.

[![Assembly](https://img.shields.io/badge/Language-x86%20Assembly-red.svg)](#)
[![Status](https://img.shields.io/badge/Status-Stable-brightgreen.svg)](#)

---

## ✨ Features

### 🧑‍💻 Customer Mode
*   **Browse Inventory:** View available items, their prices, and stock levels.
*   **Make Purchases:** Select items and specify desired quantity.
*   **Payment System:** Accepts virtual cash inputs (20, 50, 100).
*   **Transaction Processing:** Calculates bill, handles payment, and returns change.
*   **Friendly UI:** Clear prompts and messages guide the user through the process.

### 🔐 Admin Mode (PIN: 1234)
*   **Secure Access:** Protected by a 4-digit PIN code.
*   **View Total Sales:** Displays the total revenue generated from all transactions.
*   **Low Stock Alerts:** Intelligently scans and lists all items with a quantity below 5.
*   **Dynamic Inventory Management:**
    *   **Update Any Item:** Change the price and stock quantity of any product in real-time.
    *   **Live Editing:** Modifications are immediately reflected in the customer mode.

---

## 🚀 Why This Project is Cool

*   **Pure Assembly:** It's not just a "Hello World"; it's a complex application pushing the limits of what's possible in ASM.
*   **Real-World Concepts:** Implements core CS concepts like memory management, arithmetic operations, string handling, and control flow at the hardware level.
*   **Dual-Interface Design:** Showcases structured programming in a low-level environment with separate modes for different users.
*   **Perfect for Learning:** An excellent codebase for students and enthusiasts to understand how high-level logic translates down to assembly.

---

## 🛠️ How to Run

### Prerequisites
You need an 8086 assembler and emulator. We recommend:
*   **MASM (Microsoft Macro Assembler)** or **TASM (Turbo Assembler)**
*   **DOSBox** to emulate a 16-bit environment on modern systems.

### Instructions
1.  Clone this repository or download the `.asm` file.
2.  Mount your project directory in DOSBox.
3.  Assemble and link the program:
    ```bash
    masm vending.asm;
    link vending.obj;
    ```
    or for TASM:
    ```bash
    tasm vending.asm
    tlink vending.obj
    ```
4.  Run the executable: `vending.exe`

---

## 📁 Code Overview

| Label | Description |
| :--- | :--- |
| `NewLine` | Prints a carriage return and line feed. |
| `PrintWordDecimal` | Converts and prints a word-sized integer to decimal. |
| `AdminCheck` | Validates the admin PIN. |
| `ShowTotalSales` | Feature #5.1: Prints the `total_sell` value. |
| `ShowLowStock` | Feature #5.2: Lists items with quantity < 5. |
| `UpdateItems` | Feature #6: Allows updating an item's price and quantity. |
| `Calculate_bill` | Multiplies item price by quantity and stores the result. |

**Key Data Structures:**
*   `item_name`: Array of strings (6 bytes each).
*   `item_price`, `item_quantity`: Parallel byte arrays.
*   `total_sell`, `bill`, `cash`: Word variables for financial tracking.

---

## 🤝 Contributing

Contributions are welcome! If you have ideas for new features (e.g., a better UI, more items, a password change function), feel free to fork the repo and submit a pull request.

1.  Fork the Project
2.  Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3.  Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4.  Push to the Branch (`git push origin feature/AmazingFeature`)
5.  Open a Pull Request



## ⭐ If You Like This...

If you find this project interesting or useful, please give it a **star** ⭐ on GitHub! It helps others discover it and motivates further development.
