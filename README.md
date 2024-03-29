# Powershell Nessus
PowerShell Script to Manage Scan Result in Nessus Professional, leveraging on the Nessus API.

NOTE: This script only works in Powershell 6/7.

# 🤔 ABOUT

This script exports and downloads Nessus scans based on the scan Name or ID.
<p>The actions herein are based on the Nessus Professional API https://developer.tenable.com/reference/navigate  </p>

## 🎫 Mandatory Dependencies

This script is only compatible with Powershell 6/7. 
<p>You can download and install Powershell 7 Here https://learn.microsoft.com/en-us/powershell/scripting/install/installing-powershell-on-windows?view=powershell-7.4</p>

## 🔨 Usage

```python
# copy the files to the computer
git clone https://github.com/Johnng007/Nessus-Pro-API

# Execution
.\NessusAPI.ps1 <parameters>

```
## 🥊 Examples

```python
# Export and Download with a scan Name
.\NessusAPI.ps1 -Name NameofScan

# Export and Download with Scan ID
.\NessusAPI.ps1 -ID IDNumber

# Export and Download in a certain Format
.\NessusAPI.ps1 -Name NameofScan -Format html
NB: format could be(nessus,csv,html,pdf)

# Specify the Server URL
.\NessusAPI.ps1 -Name NameofScan -Format html -Server https://localhost:8834
NB: Defaults to https://localhost:8834
```
## ✍ Notes
* You can either use a scan name or a scan id but not both.<br>
* On script execution, a check is done to determine the powershell version in use, if its below 6, the user is prompted to auto download and install powershell 7.<br>
* If the format parameter is not specified it defaults to html.<br>
* If the server parameter is not specified it defaults to https://localhost:8834 .<br>
  The server parameter accepts Nessus Cloud URL as well https://cloud.tenable.com

## 🤔 MORE TOOLS
Want to check out other Black Widow Tools?
1. Forensicator - Live Forensics and Incidence Response Script. https://github.com/Johnng007/Live-Forensicator
1. Anteater - A python based web reconnaisence tool. https://github.com/Johnng007/Anteater

## ✨ ChangeLog
```bash
v1.0 10/01/2024
Initial Release.
```

  
