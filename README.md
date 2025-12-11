## 🔍 Project Overview – Stopwatch + SR04 + DHT11 + UART Integrated System

본 프로젝트는 **FPGA 기반 스톱워치, 초음파 거리 측정, 온·습도 측정 시스템을 UART로 PC와 연동하여 통합 제어하는 임베디드 시스템 설계 프로젝트**입니다.

---

## 🧩 1. 전체 기능 요약 (PDF p.5)

- 스톱워치(시간 측정)  
- 초음파 센서 SR04 (거리 측정)  
- DHT11 센서 (온도/습도 측정)  
- UART로 PC ↔ FPGA 양방향 통신  
- 버튼 입력 + UART 명령 모두 지원  
- FND(7-seg)로 시간/거리/온습도 값을 모드에 따라 표시  

---

## ⏱ 2. Stopwatch + UART (p.6–15)

### ✔ 주요 기능
- UART 명령(run/stop/reset)을 수신해 스톱워치 제어  
- 버튼 입력 + UART 명령 OR 처리 → 둘 중 하나만 와도 동작  
- FIFO 기반 UART 통신: 안정적인 데이터 전송  
- command_cu FSM:  
  - 'r'(0x72) → run/stop  
  - 'c'(0x63) → clear  

### ✔ 트러블슈팅  
- 문제: Rx_trigger 순간 FIFO 데이터 불일치(X 값 발생)  
- 해결: **버퍼(data_reg)** 사용하여 데이터 안정성 확보  
- 결과: PC ComportMaster 입력 **1회만으로 정상 동작**

---

## 📡 3. SR04 초음파 센서 + UART (p.16–33)

### ✔ 주요 기능  
- trig 신호 발생 → echo high 유지 시간 측정  
- echo 시간 → cm 단위 거리 변환  
- UART로 거리 값 PC 전송  

### ✔ FSM 구성 (p.19)
- IDLE → START → WAIT → DIST → IDLE  
- tick_cnt 기반 타이밍 제어  
- echo high인 시간만큼 카운트 후 거리 계산  

### ✔ Testbench 검증 결과  
- 300ms 입력 → 300/58 = 5cm  
- 500ms 입력 → 500/58 ≈ 8.62cm  
- ‘R’ 입력에만 반응하여 동작하는 UART 명령 FSM 정상 검증  

---

## 🌡 4. DHT11 온습도 센서 + UART (p.34–41)

### ✔ 주요 기능  
- DHT11로부터 온도/습도 데이터 수집  
- UART로 PC 전송  
- command_cu를 통해 UART 명령 인식  

### ✔ FSM & Code Review  
- 센서 프로토콜에 따라 IDLE → START → WAIT → SYNC → DATA RECV 단계를 거침  
- 유효한 데이터(valid = 1)만 전송  

### ✔ Testbench  
- valid 값이 나오는 합법적 패턴 입력하여 정상 데이터 수신 검증  

---

## 🔗 5. ALL_TOP – 전체 통합 시스템 (p.42–54)

### ✔ 주요 내용  
- Stopwatch + SR04 + DHT11 + UART + FND 완전 통합  
- 모드 설정:
  - SW[1] = 0 → Stopwatch  
  - SW[1] = 1 → SR04 거리 측정  
  - SW[2] = 1 → DHT11 온습도 측정  

### ✔ FND Controller  
- 모드에 따라 표시 값 선택  
- Stopwatch: stopwatch_time  
- SR04: sensor_dist  
- DHT11: 온도/습도 값  

### ✔ UART TX MUX  
- 모드에 따라 전송 값 선택 (시간 / 거리 / 온습도)  
- 하나의 UART 출력으로 모든 기능 지원  

### ✔ Simulation  
- stopwatch, sr04, dht11 기능이 각각 정상적으로 FND / UART로 출력되는 것 확인  

---

## 🎥 6. 동작 영상  
- Basys3 보드에서 Stopwatch / SR04 / DHT11이 정상 동작  
- UART로 PC와 연동  
- FND에서 실시간 값 표시






## 📄 Stopwatch + SR04 Ultrasonic + DHT11 Sensor + UART 통합 프로젝트 (PDF Report)

전체 프로젝트 보고서는 아래 PDF에서 확인할 수 있습니다.

👉 [📘 **Stopwatch / SR04 / DHT11 통합 시스템 PDF 열기**](./stopwath_sr04_dht11.pdf)



:contentReference[oaicite:0]{index=0}

---

### 📌 PDF 미리보기 썸네일 (옵션)

[![PDF Preview](./stopwatch_sr04_dht11_page1.png)](./stopwath_sr04_dht11.pdf)


