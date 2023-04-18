/*
Finn Lestrange (finnlestrange.tech) - 28/03/2023
Written for the International School Aberdeen's GSuite

This script takes in a list of students given their student ID's and a list of their teacher emails from an automatically uploaded powerschool export
see here for details -> https://github.com/InternationalSchoolAberdeen/DriveAPIFileUploadJava/blob/main/src/main/java/tech/finnlestrange/FileUpload.java
and then shares each new / unique students documents with their class teachers from powerschool.

*/

// Constants
const FOLDER_ID = "";
const SHARED_DRIVE_ID = "";


const readCSV = (folderID) => {
  Logger.log("[!] Step 1/2: Creating Data CSV")
  // Get ID of latest csv in folder
  let folder = DriveApp.getFolderById(folderID);
  let csvFileList = folder.getFilesByName("export.csv");
  if (csvFileList.hasNext() === false) {
    Logger.log("[!] CSV Not Found! Check Powerschool Export Logs & Java Script.")
    return null;
  }
  let csv = csvFileList.next();

  Logger.log("[*] Found CSV: " + csv.getName());

  let csvData = Utilities.parseCsv(csv.getBlob().getDataAsString());

  const csvSheet = SpreadsheetApp.create("Export Data - " + new Date().toDateString());
  csvSheet.insertSheet("export");
  csvSheet.insertSheet("original");
  csvSheet.getSheetByName("original").getRange(1,1, csvData.length, csvData[0].length).setValues(csvData);
  const sheet = csvSheet.getSheetByName("export");
  csvSheet.deleteSheet(csvSheet.getSheetByName("Sheet1"));

  DriveApp.getFileById(csvSheet.getId()).moveTo(DriveApp.getFolderById(folderID));

  // If there is no master sheet then create one
  if (folder.getFilesByName("master").hasNext === null) {
    // then there is no master sheet so set current sheet to be master sheet
    const masterSS = SpreadsheetApp.create("master");
    masterSS.insertSheet("master");
    const masterSheet = masterSS.getSheetByName("master");

    masterSheet.getRange(1, 1, csvData.length, csvData[0].length).setValues(csvData);
    return masterSheet;
  }

  // filter out rows so that only uniqe ones remain
  Logger.log("[*] Filtering for only new changes . . . ")
  var uniqueRows = [];
  const masterSheet = SpreadsheetApp.openById(folder.getFilesByName("master").next().getId());
  var masterSheetData = masterSheet.getSheetByName("master").getDataRange().getValues();
  for (var i = 0; i < csvData.length; i++) {
    var foundRow = false;
    for (var j = 0; j < masterSheetData.length; j++) {
      if (csvData[i].toString() === masterSheetData[j].toString()) {
        foundRow = true;
        break;
      }
    }

    if (!foundRow) {
      uniqueRows.push(csvData[i]);
    }
  }

  if (uniqueRows.length === 0 || uniqueRows[0] === null) {
    Logger.log("[!] No new entries to be updated!");
    DriveApp.getFileById(csvSheet.getId()).setTrashed(true);
    DriveApp.getFileById(csv.getId()).setTrashed(true);
    return null;
  }
  sheet.getRange(1, 1, uniqueRows.length, uniqueRows[0].length).setValues(uniqueRows);
  Logger.log("[*] Data sheet created! ");
  Logger.log("[*] Setting master sheet to current csv from powerschool ...")
  csvSheet.getSheetByName("original").copyTo(masterSheet);
  masterSheet.deleteSheet(masterSheet.getSheetByName("master"));
  masterSheet.getSheets()[0].setName("master");

  // Delete CSV File
  csv.setTrashed(true);

  Logger.log("[!] Finshed sheet creation step.")
  return csvSheet;
}

const fixPermissions = (csvSheet, sharedDriveID) => {
  Logger.log("[!] Step 2/2: Fixing Permissions")

  const masterSheet = SpreadsheetApp.openById("--INSERT-SHEET-ID-HERE--").getSheetByName("master");

  // Create lookup table for 'Class of 20xx' folders in shared drive
  const sharedDriveFolders = DriveApp.getFolderById(sharedDriveID).getFolders();  
  let folderIdMap = new Map(); // -> Key: Folder Name, Value: Folder ID
  while (sharedDriveFolders.hasNext() === true) {
    const cFolder = sharedDriveFolders.next();
    folderIdMap.set(cFolder.getName(), cFolder.getId());
  }

  // Get Data & Loop through sheet and make sure each folder has specific permissions 
  const data = csvSheet.getSheetByName("export").getDataRange().getValues();
  for (let i = 0; i < data.length; i++) {
    try {
      const row = data[i];
      const folderID = folderIdMap.get(row[1]); // -> "class of" column
      const emails = row[2];

      const sharingList = emails.split(",");

      let studentFolder = DriveApp.getFolderById(folderID).getFoldersByName(row[0]); // gets the folder that has the name of students id

      if (studentFolder.hasNext() === false) {
        studentFolder = DriveApp.getFolderById(folderID).createFolder(row[0]);
        Logger.log("[*] Created student folder: " + row[1] + "/" + row[0]);
      } else {
        studentFolder = studentFolder.next();
      }

      
      Logger.log("[*] Folder Name: " + row[1] + "/" + studentFolder.getName() + "\n---------------------------------------");
      for (let j = 0; j < sharingList.length; j++) {
        try {
            Drive.Permissions.insert(
            {
              'role': 'reader',
              'type': 'user',
              'value': sharingList[j].trim()
            }, studentFolder.getId(),
            {
              'sendNotificationEmails': 'false',
              'supportsAllDrives': true
            }
          );
          Logger.log("[*] Added user: " + sharingList[j].trim() + ", to folder: " + row[1] + "/" + row[0]);
        } catch (e) {
          Logger.log("[*] Failed to share folder with user.");
        }
      }
    } catch (e) {
      Logger.log("[*] Error in parsing student data (outer catch loop)");
      Logger.log(e);
      continue;
    }
  }

}

const run = () => {
  Logger.log("[!] Starting Script ...")
  const csvSheet = readCSV(FOLDER_ID);

  // Run Permission Fixing Function
  if (csvSheet === null) return;
  fixPermissions(csvSheet, SHARED_DRIVE_ID);

  // Delete previous run's sheet
  Logger.log("[*] Cleaning Up Temp Files ...")
  DriveApp.getFileById(csvSheet.getId()).setTrashed(true)

  Logger.log("[!] Script Finished!")

}
