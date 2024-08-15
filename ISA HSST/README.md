<h1 align="center">🎒 ISA's Custom Student Tracke </h1> 

> [!Important]
> PowerSchool SIS Export + `GAMADV-XT3` upload script + Google Sheets.

## Setup & Documentation 

> [!note]
> **Please Note** : you must have an instance of `GAMADV-XT3` configured on your live PowerSchool server along with having an authenticated oAuth session and GAM project that has full domain access.

## How the Script Works
* The script runs a windows scheduled task every night after powerschool has exported the list of students alongside their grades + learning standard data.
![](images/task.png)

* This task scheduler runs a `.bat` file that contains the following script.

```powershell
cd D:\GAMADV-XTD3
.\gam.exe user $gam-user-email update drivefile $sheet-id csvsheet name:DataImport localfile D:\PSShare\external\autosend\HSSTstoredgradesexport retainname
```

Where:
* `$gam-user-email` - The email you have configured for access using `GAM`
* `$sheet-id` - The ID of the Google Sheet to update

> [!Tip]
> This then will populate a sheet named `DataImport` within the main spreadsheet with id: `$sheet-id`.