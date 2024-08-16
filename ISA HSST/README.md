<h1 align="center"> 🕵️ ISA's PowerSchool + Looker Studio Student Tracker</h1> 

> [!Important]
> PowerSchool SIS Export + `GAMADV-XT3` upload script + Google Sheets.

## Setup & Documentation 

> [!note]
> **Please Note** : you must have an instance of `GAMADV-XT3` configured on your live PowerSchool server along with having an authenticated oAuth session and GAM project that has full domain access.

## Configuring PowerSchool Exports
First install the plugin `ISA HHST PowerQuerys` located in this repo, `ISA PS Plugins/ISA HSST PowerQuery Plugin`. This allows you to use custom SQL queries to pull out specific data for export.

> [!Warning]
> Make sure the names of the columns in the export template match those you are going to use in Google Sheets / Looker Studio.

Next, head to the Export Page - `/admin/datamgmt/exporttemplates.html#/export-schedule-content` & setup new export templates using these powerqueries and the fields they return.

> [!Warning]
> Please also ensure that the export settings specify `UTF-8` encoding and `comma` as the delimiter.
> ![](images/createExportTemplate.png)

Then head to the `My Templates` and setup scheduled exports for each of the new export templates.


## GAM Upload Script
* The script runs a windows scheduled task every night after powerschool has exported the list of students alongside their grades + learning standard data.
![](images/task.png)

* This task scheduler runs a `.bat` file that contains the following script.

```shell
cd D:\GAMADV-XTD3
.\gam.exe user $gam-user-email update drivefile $spreadsheet-id csvsheet id:$sheet-id localfile D:\PSShare\external\autosend\HSSTstoredgradesexport retainname
```

Where:
* `$gam-user-email` - The email you have configured for access using `GAM`
* `$spreadsheet-id` - The ID of the Gooogle Spreadsheet containing the sheet to update
* `$sheet-id` - The ID of the Google Sheet to update

> [!Tip]
> This then will populate a sheet named `DataImport` within the main spreadsheet with id: `$sheet-id`.


## Google Sheets Script
> [!import]