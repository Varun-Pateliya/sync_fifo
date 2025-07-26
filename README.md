# Synchronous FIFO Design and Verification

This project implements a **Synchronous FIFO (First-In-First-Out)** buffer in Verilog HDL. The design is accompanied by a testbench that simulates both write and read operations to verify functional correctness.

---

## 📌 Project Overview

A FIFO (First-In-First-Out) buffer is widely used in digital systems for temporary data storage between two blocks operating at the same clock rate. This FIFO is synchronous, meaning all operations (read/write) are triggered on the same clock edge.

---

## 🧱 Features

- Parameterized **data width** and **depth**
- **Full** and **empty** status flags
- **Write enable (wr_en)** and **Read enable (rd_en)** controls
- Optional **valid signal** for clean data verification
- Fully synchronous design (single-clock domain)

---

## 📂 File Structure
```
├── sync_fifo.v # FIFO design module
├── tb_sync_fifo.v # Testbench to verify FIFO
├── Output_data.jpg # Screenshot of console output (data match)
├── Output_waveform.jpg # Waveform of simulation (XSim or ModelSim)
└── README.md # This file
```
---

## 🔧 Parameters

| Parameter    | Description                  | Default |
|--------------|------------------------------|---------|
| `DATA_WIDTH` | Bit-width of each data word  | 8       |
| `DEPTH`      | Number of FIFO slots         | 16      |

---

## 🧪 Verification

### ✅ Testbench Features

- Initializes input memory with values
- Writes a range of values to FIFO using `write()` task
- Reads back using `read()` task and compares with expected data
- Displays match/mismatch for each data read
- Uses timeout mechanism to avoid hanging on full/empty FIFO

### ✅ Console Output

Shows data comparisons:
```
data matched | output data = 101, expected data = 101
data matched | output data = 18, expected data = 18
```

### ✅ Waveform

- Includes signals: `clk`, `wr_en`, `rd_en`, `full`, `empty`, `valid`, `data_in`, `data_out`
- Visual trace of FIFO behavior during simulation

📷 See:

- `Output_data.jpg` — terminal output
- `Output_waveform.jpg` — waveform diagram

---

## ▶️ How to Run the Simulation

Using Xilinx Vivado / ModelSim / any Verilog simulator:

```sh
vlog sync_fifo.v tb_sync_fifo.v
vsim work.tb_sync_fifo
run 1000ns
