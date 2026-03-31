# Plex SSL Certificate Auto-Renew Script for DSM 7+
This script has been overhauled to ensure compatibility with Synology DSM 7.0 and later, addressing several breaking changes introduced in more recent Plex Media Server versions. 
Current Compatibility & Requirements
- **Target OS:** Specifically tested on DSM 7.3.*
- **Security:** Built and verified using OpenSSL 3.
- **Functionality:** Designed to automate the renewal and deployment of SSL certificates for Plex Media Server running natively on Synology. 

---

## Synology Scheduled Task in DSM
To ensure the certificate stays updated, you must automate the script.

1.  Log in to DSM and go to **Control Panel** > **Task Scheduler**.
2.  Click **Create** > **Scheduled Task** > **User-defined script**.
3.  **General Tab**:
    *   **Task**: `Plex SSL Auto-Renew`
    *   **User**: **root** (Required to access system certs and restart services).
4.  **Schedule Tab**:
    *   **Run on the following days**: Daily.
    *   **First run time**: 03:00 (or any time the NAS is idle).
5.  **Task Settings Tab**:
    *   (Optional) Check **Send run details by email** to receive a confirmation daily.
    *   **User-defined script**: Enter the script or path to the script
6.  Click **OK**.

---

## Testing
1.  In the **Task Scheduler** list, right-click your new task (`Plex SSL Auto-Renew`).
2.  Select **Run**.
3.  Click **Yes** to confirm.
4.  Check your destination folder in **File Station**. You should see a new `.pfx` file.
5.  Check your Plex server; the "Remote Access" should now show a green lock with your custom domain.

---

## Troubleshooting
- **Permission Denied**: If sourcing a script.sh file, Ensure the script is owned by `root` and has execute permissions (`chmod +x plex_renew.sh`). Ensure task user has access to certificate folder
- **Wrong Cert**: If you have multiple certificates, ensure your "Default" certificate in DSM is the one you intend to use for Plex.
- **Default Plex Cert**: *Example* = ***random_hash*.plex.direct** - Plex is unable to use the PFX file generated, ensure all file path, passwords, configurations in Plex etc are correct.

--- 

## Disclaimer & Support Policy
Use at your own discretion: This script is provided "as-is." While it is actively used and maintained for my personal Synology NAS, I cannot guarantee it will work for every environment.
- **No Legacy Support:** I will not be providing updates or support for older DSM versions (DSM 6.x or earlier). \
- **Bug Reports:** I am currently not accepting requests for bug fixes or maintenance to suit specific user configurations. If you encounter issues on your hardware, you are encouraged to fork the repository and adjust the code as needed. 

---

## Credits & Origins 
This project is an evolution of several community-driven solutions. It is based on the following repositories:
- https://github.com/zachg99/synology-plex-cert-autorenew
- https://github.com/AntCardFR/Renew-SSLForPlex-Synology
