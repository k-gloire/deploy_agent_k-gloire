#!/bin/bash

echo "Enter your name:"
read name


cleanup() {
    echo "Interrupted"

    if [ -d "attendance_tracker_$name" ]; then
        tar -czf attendance_tracker_${name}_archive.tar.gz attendance_tracker_$name
        rm -rf attendance_tracker_$name
    fi

    echo "Cleanup done. Exiting safely."
    exit 1
}

trap cleanup SIGINT


if [ -d "attendance_tracker_$name" ]; then
    echo "Project already exists."
    exit 1
fi


mkdir -p attendance_tracker_$name/Helpers
mkdir -p attendance_tracker_$name/reports


cat > attendance_tracker_$name/Helpers/config.json << EOF
{
    "thresholds": {
        "warning": 75,
        "failure": 50
    },
    "run_mode": "live",
    "total_sessions": 15
}
EOF


cat > attendance_tracker_$name/Helpers/assets.csv << EOF
Email,Names,Attendance Count,Absence Count
alice@example.com,Alice Johnson,14,1
bob@example.com,Bob Smith,7,8
charlie@example.com,Charlie Davis,4,11
diana@example.com,Diana Prince,15,0
EOF


cat > attendance_tracker_$name/attendance_checker.py << 'EOF'
import csv
import json
import os
from datetime import datetime

def run_attendance_check():
    with open('Helpers/config.json', 'r') as f:
        config = json.load(f)

    if os.path.exists('reports/reports.log'):
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        os.rename('reports/reports.log', f'reports/reports_{timestamp}.log.archive')

    with open('Helpers/assets.csv', mode='r') as f, open('reports/reports.log', 'w') as log:
        reader = csv.DictReader(f)
        total_sessions = config['total_sessions']

        log.write(f"--- Attendance Report Run: {datetime.now()} ---\n")

        for row in reader:
            name = row['Names']
            email = row['Email']
            attended = int(row['Attendance Count'])

            attendance_pct = (attended / total_sessions) * 100

            message = ""

            if attendance_pct < config['thresholds']['failure']:
                message = f"URGENT: {name}, your attendance is {attendance_pct:.1f}%. You will fail this class."
            elif attendance_pct < config['thresholds']['warning']:
                message = f"WARNING: {name}, your attendance is {attendance_pct:.1f}%. Please be careful."

            if message:
                if config['run_mode'] == "live":
                    log.write(f"[{datetime.now()}] ALERT SENT TO {email}: {message}\n")
                    print(f"Logged alert for {name}")
                else:
                    print(f"[DRY RUN] Email to {email}: {message}")

if __name__ == "__main__":
    run_attendance_check()
EOF


cat > attendance_tracker_$name/reports/reports.log << 'EOF'

--- Attendance Report Run: 2026-02-06 18:10:01.468726 ---
[2026-02-06 18:10:01.469363] ALERT SENT TO bob@example.com: URGENT: Bob Smith, your attendance is 46.7%. You will fail this class.
[2026-02-06 18:10:01.469424] ALERT SENT TO charlie@example.com: URGENT: Charlie Davis, your attendance is 26.7%. You will fail this class.

EOF

echo "Project structure created successfully."


echo "Enter warning threshold (default 75):"
read warning

echo "Enter failure threshold (default 50):"
read failure


if [[ ! "$warning" =~ ^[0-9]+$ ]] || [[ ! "$failure" =~ ^[0-9]+$ ]]; then
    echo "Thresholds must be numbers."
    exit 1
fi


sed -i "s/\"warning\": *[0-9]\+/\"warning\": $warning/" attendance_tracker_$name/Helpers/config.json
sed -i "s/\"failure\": *[0-9]\+/\"failure\": $failure/" attendance_tracker_$name/Helpers/config.json

echo "Configuration updated successfully."


echo "Checking Python installation..."

if command -v python3 >/dev/null 2>&1
then
    echo "Python3 is installed."
    python3 --version
else
    echo "Warning: Python3 is not installed."
fi

echo "Setup completed successfully."
