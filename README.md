# TMR-Hardened 4-Point Moving Average Filter (Rad-Hard RTL)

A parameterized **SystemVerilog RTL implementation** of a **4-point Moving Average Filter (MAF)** with a **Triple Modular Redundancy (TMR)** architecture for **single-event upset (SEU)** tolerance. The project demonstrates both fundamental RTL design and basic radiation-hardening techniques commonly used in aerospace and satellite electronics.

---

## Features

- **v1.0:** 4-point Moving Average Filter
- **v2.0:** Triple Modular Redundancy (TMR)
- Bitwise **2-out-of-3 majority voting**
- **SEU detection** via mismatch flag
- Parameterized, synthesizable SystemVerilog
- Self-checking verification environment
- Open-source simulation flow (Icarus Verilog + GTKWave)

---

## Specifications

| Parameter | Value |
|----------|-------|
| Data Width | 8-bit unsigned |
| Window Size | 4 samples |
| Redundancy | Triple Modular Redundancy (TMR) |
| Voting | Bitwise 2-of-3 Majority Vote |
| Clock | Single clock, synchronous reset |
| Outputs | `out[7:0]`, `seu_detected` |

---

## Architecture

```
           sensor_in
               │
      ┌────────┼────────┐
      │        │        │
    MAF A    MAF B    MAF C
      │        │        │
      └────────┼────────┘
               │
        Majority Voter
               │
      ┌────────┴────────┐
      │                 │
 corrected_out     seu_detected
```

---

## Verification

| Test Case | Description | Status |
|-----------|-------------|--------|
| TC1 | Normal operation | ✅ |
| TC2 | Boundary values | ✅ |
| TC3 | Reset behavior | ✅ |
| TC4 | Edge-case inputs | ✅ |
| TC5 | Single SEU correction | ✅ |
| TC6 | Dual-fault detection | ✅ |

Fault injection is performed during simulation to validate:
- Correction of a single corrupted TMR path
- Detection of multiple-path disagreement

---

## Repository Structure

```
.
├── rtl/
│   ├── moving_avg_filter.sv
│   ├── majority_voter.sv
│   └── tmr_moving_avg_filter.sv
│
├── tb/
│   ├── tb_moving_avg_filter.sv
│   └── tb_tmr_moving_avg_filter.sv
│
├── sim/
├── waves/
└── README.md
```

---

## Simulation

```bash
iverilog -g2012 -o sim/a.out rtl/*.sv tb/tb_tmr_moving_avg_filter.sv
vvp sim/a.out
gtkwave sim/dump.vcd
```

---

## Learning Outcomes

- Parameterized RTL design
- Modular SystemVerilog coding
- Shift-register based Moving Average Filter
- Triple Modular Redundancy (TMR)
- Majority voter implementation
- SEU fault injection and verification
- Self-checking testbench development

---

## Tools

- SystemVerilog
- Icarus Verilog
- GTKWave
- Visual Studio Code

---

## Applications

- Satellite thermal sensor signal conditioning
- Radiation-tolerant digital systems
- Fault-tolerant FPGA/ASIC design
- RTL design portfolio projects

---

## License

This project is intended for educational and portfolio purposes.