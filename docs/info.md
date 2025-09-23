<# UART PWM Top Wrapper (tt_um_madeesha)

This project implements a **TinyTapeout wrapper** around the `uart_pwm_top` design.  
The wrapper (`tt_um_madeesha`) maps the signals of the core module to the TinyTapeout interface (`ui_in`, `uo_out`, `uio_in/out/oe`, `clk`, `rst_n`, `ena`).

---

## 📦 Top Module: `uart_pwm_top`

The `uart_pwm_top` module generates **9 channels of PWM signals** that can be controlled via **UART input**.  
It also drives **4 seven-segment displays** and provides a **packet counter**.

### Ports

- **Inputs**
  - `clk` : System clock  
  - `rst_n` : Active-low reset  
  - `uart_rx` : UART input line  

- **Outputs**
  - `pwm_out[8:0]` : Nine PWM channels  
  - `seg0..seg3[6:0]` : Four seven-segment display outputs  
  - `pkt_count[3:0]` : Packet counter  

---

## 🧩 Wrapper: `tt_um_madeesha`

The wrapper connects `uart_pwm_top` to the **TinyTapeout harness**.

### Mapping

- **Inputs (`ui_in`)**
  - `ui_in[0]` → `uart_rx` (UART input)
  - `ui_in[7:1]` → unused  

- **Outputs (`uo_out`)**
  - `uo_out[0..7]` → First 8 PWM outputs (`pwm_out[0..7]`)  
  - `pwm_out[8]`, `seg0..seg3`, and `pkt_count` are **not exposed** due to output pin limitations.  

- **Bidirectional IOs (`uio_in/out/oe`)**
  - All tied off (unused).  

- **Other signals**
  - `clk`, `rst_n`, `ena` → directly connected to `uart_pwm_top`.  
  - Unused signals (`pwm_out[8]`, `seg0..seg3`, `pkt_count`) are included in a dummy `_unused` wire to prevent synthesis warnings.  

---

## ⚙️ How It Works

1. A **UART stream** is received on `ui_in[0]`.  
2. The `uart_pwm_top` decodes this data and updates PWM duty cycles.  
3. **9 PWM outputs** are generated internally, with the first 8 mapped to `uo_out[0..7]`.  
4. **7-segment displays** (`seg0..seg3`) show decoded information (not exposed in this wrapper).  
5. A **packet counter** (`pkt_count`) increments whenever valid UART packets are received (also not exposed in this wrapper).  

---

## 🚧 Limitations

- Only **8 outputs** are available on TinyTapeout (`uo_out`), so:
  - `pwm_out[8]`, the seven-segment outputs, and `pkt_count` are not visible externally.  
- For debugging, you may choose to **remap outputs** (e.g., expose `pkt_count` or segments instead of some PWM channels).

---

## ✅ Summary

- `uart_pwm_top` provides **PWM + seven-segment display + counter** functionality.  
- `tt_um_madeesha` adapts it to the **TinyTapeout pinout**.  
- External users will see **8 PWM outputs** on `uo_out`, and can drive UART data on `ui_in[0]`.  


