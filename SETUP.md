# Running Bloomly on Physical Android Device

## Prerequisites

- Flutter SDK installed and in PATH
- Python 3.12+
- MongoDB running locally
- Android device connected via USB or on same Wi-Fi
- Windows Firewall allows port 8000 inbound

## Backend Setup

1. Navigate to backend directory:
   ```
   cd backend
   ```

2. Install dependencies:
   ```
   pip install -r requirements.txt
   ```

3. Update `.env` file:
   - Change `MONGO_URL=mongodb://mongo:27017` to `MONGO_URL=mongodb://localhost:27017`

4. Start backend:
   ```
   python -m uvicorn app.main:app --host 0.0.0.0 --port 8000
   ```

## Mobile App Setup

1. Find your machine's Wi-Fi IP address:
   ```
   ipconfig
   ```
   Look for "IPv4 Address" under your Wi-Fi adapter (e.g., 192.168.178.150)

2. Update API endpoint in `mobile/lib/data/api/api_client.dart`:
   - Change `defaultValue: 'http://10.0.2.2:8000'` to your IP
   - Example: `defaultValue: 'http://192.168.178.150:8000'`

3. Connect Android device and verify it's connected:
   ```
   flutter devices
   ```

4. Install dependencies:
   ```
   cd mobile
   flutter pub get
   ```

5. Run on device:
   ```
   flutter run -d <device-id>
   ```

## Firewall Configuration

Add Windows Firewall rule for port 8000:
```
New-NetFirewallRule -DisplayName "Bloomly Backend" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 8000
```

## Network Requirements

- Android device must be on the same Wi-Fi network as your development machine
- Not hotspot, not VPN - same local network
- Backend must be accessible from the device's IP perspective

## Troubleshooting

**App times out connecting to backend:**
- Verify device is on same Wi-Fi network
- Check Windows Firewall allows port 8000
- Confirm backend is running: `netstat -an | findstr "8000"`

**MongoDB connection error:**
- Make sure MongoDB is running locally
- Verify `.env` has `MONGO_URL=mongodb://localhost:27017`
- Restart backend after `.env` changes

**Port 8000 already in use:**
- Kill existing Python processes: `Get-Process python | Stop-Process -Force`
- Or restart backend
