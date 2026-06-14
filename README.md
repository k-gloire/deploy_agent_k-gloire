ATTENDANCE TRACKER PROJECT 

1.What is this?
This is a Bash shell script that automate the setup of a Student Attendance Tracker project. Instead of manually creating folders and files every time, you just run the script, answer a few questions, and everything is set up for you automatically.

2.What does it do?
When you run the script, it will:

.Ask you for a project name and create a folder with that name
.Build all the required files and folders inside it
.Ask if you want to change the attendance warning and failure thresholds
.Validate that your inputs are actually numbers before updating the config
.Check whether Python 3 is installed on your machine and display the version
.If you cancel mid-way (Ctrl+C), it saves what was done into a backup archive and cleans up

3.Project Structure
After running the script, your project will look like this:
attendance_tracker_yourname/
├── attendance_checker.py
├── Helpers/
│   ├── assets.csv
│   └── config.json
└── reports/
    └── reports.log

4.How to Run It

.Open Git Bash
.Navigate to where the script is saved
.Make it executable by running:

chmod +x setup_project.sh

Run it:

./setup_project.sh

Follow the prompts — it will ask for your project name and threshold values

5.How to Trigger the Archive (Ctrl+C)
If you press Ctrl+C while the script is running, it won't just crash. It will:
i.Catch the interruption using a trap signal handler
ii.Bundle whatever was created into a .tar.gz archive named attendance_tracker_yourname_archive.tar.gz
iii.Delete the incomplete project folder to keep your workspace clean
iv.Exit safely

To test this yourself, simply run the script and press Ctrl+C before it finishes. You will see the archive file appear in the same directory.

6.Error Handling
The script also handles these edge cases:
.If the project folder already exists, it will warn you instead of overwriting it
.If you enter a non-numeric threshold value, the script rejects it and uses the default values (75% warning, 50% failure)
.If Python 3 is not found, you get a clear warning message instead of a crash

