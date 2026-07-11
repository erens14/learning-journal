# Google Sheets Automation: Monthly Form Router with Dynamic Formulas & Formatting

This learning journal documents the process of building a Google Sheets automation solution using Google Apps Script (GAS). The script automatically routes Google Form responses into specific monthly tabs, injects dynamic accounting formulas, and applies instant visual formatting.

## 📝 Problems Solved (QA Test Insights)

During the testing phase, several advanced runtime and logic bugs were identified and successfully resolved:

1. **`appendRow` Conflict with Array/MAP Formulas:** The native `appendRow` function checks the entire row for empty cells. Because the Array formulas (`MAP` & `SCAN`) automatically expand down to the very last row of the sheet (e.g., row 1000), `appendRow` falsely assumes these rows are occupied and pushes new data all the way down to row 1001. The solution was to build a custom empty-row finder that strictly evaluates Column A (Timestamp).
2. **Formula Parse Error due to Regional Settings (Indonesian Locale):** The standard `.setFormula()` function in Apps Script strictly mandates international syntax (commas `,`). When dealing with highly complex nested `LAMBDA` functions, the Google Sheets engine frequently fails to translate them into local semicolons (`;`), throwing a `#FORMULA_PARSE_ERROR`. The solution was to utilize `.setValue()`, allowing raw text strings pre-formatted with semicolons to pass directly into the local spreadsheet parser.
3. **Optimizing Running Balance Without FILTER/INDIRECT:** The initial formula using `FILTER` would completely crash with a `#N/A` error when a new monthly sheet was generated because the data area was still completely empty. The formula was refactored into a highly stable `MAP` + `SCAN` combination that handles empty states gracefully.
4. **Space-Free Sheet Names:** Spaces were stripped from the monthly tab naming convention (e.g., converting "Juli 2026" to `Juli2026`). This prevents syntax errors and eliminates the need for annoying single quotes (`'`) when referencing these tabs in other formulas later on.

## 🚀 Key Features
* **On-Form-Submit Trigger:** The script triggers instantly and automatically every time a Google Form is submitted.
* **Auto-Create Monthly Sheets:** Automatically generates a new tab if it detects a new month (Format: `MonthYear`).
* **Dynamic Local Formulas:** Injects a Running Balance formula in Column G, and Total Income/Expenses in Columns I & J. These are injected as local ranges (`D2:D`, `F2:F`), making them 100% dynamic to that specific month's data.
* **Custom Typography Styling:** Automatically overrides the default sheet style by applying `Calibri 11` to the entire working grid and formatting the Header Row (Row 1) to `Calibri 12 Bold`.

## 💻 Final Google Apps Script Code

> *Note: The `monthNames` array retains Indonesian naming conventions to perfectly match the local spreadsheet environment and form timestamps.*

```javascript
function autoRouteMonthlyForm(e) {
  try {
    var ss = SpreadsheetApp.getActiveSpreadsheet();
    var responseRange = e.range;
    var rowData = responseRange.getValues()[0];
    
    var timestamp = new Date(rowData[0]);
    var monthNames = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni", 
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    
    var targetSheetName = monthNames[timestamp.getMonth()] + timestamp.getFullYear();
    var targetSheet = ss.getSheetByName(targetSheetName);
    
    // TYPOGRAPHY CONFIGURATION
    var namaFont = "Calibri"; 
    var ukuranData = 11;      
    var ukuranHeader = 12;    
    
    // If the monthly sheet does not exist yet, create it and set up the foundation
    if (!targetSheet) {
      targetSheet = ss.insertSheet(targetSheetName);
      
      // Apply font family and size to the entire working range (Columns A to J)
      targetSheet.getRange("A:J").setFontFamily(namaFont).setFontSize(ukuranData);
      
      var sourceSheet = responseRange.getSheet();
      var lastColumn = sourceSheet.getLastColumn();
      var headers = sourceSheet.getRange(1, 1, 1, lastColumn).getValues();
      
      // 1. Paste the original header from the Google Form response
      targetSheet.getRange(1, 1, 1, lastColumn).setValues(headers);
      
      // 2. Running Balance (G1/G2) using .setValue() with semicolon (;) for Indonesian Locale compliance
      targetSheet.getRange("G1").setValue("Saldo");
      targetSheet.getRange("G2").setValue('=MAP(D2:D; SCAN(0; MAP(D2:D; F2:F; LAMBDA(s; n; IF(s="Masuk"; n; IF(s="Keluar"; -n; 0)))); LAMBDA(p; c; p + c)); LAMBDA(status; saldo; IF(status=""; ""; saldo)))');
      
      // 3. Total Income (I1/I2)
      targetSheet.getRange("I1").setValue("Total Pemasukan");
      targetSheet.getRange("I2").setValue('=SUMIF(D2:D; "Masuk"; F2:F)');
      
      // 4. Total Expenses (J1/J2)
      targetSheet.getRange("J1").setValue("Total Pengeluaran");
      targetSheet.getRange("J2").setValue('=SUMIF(D2:D; "Keluar"; F2:F)');
      
      // 5. Format Header Row to Bold and slightly larger text
      targetSheet.getRange("1:1").setFontWeight("bold").setFontSize(ukuranHeader);
    }
    
    // Custom empty-row lookup focusing only on Column A to avoid formula expansion blocks in Column G
    var values = targetSheet.getRange("A:A").getValues();
    var nextRow = 2; 
    
    for (var i = values.length - 1; i >= 0; i--) {
      if (values[i][0] !== "") {
        nextRow = i + 2; 
        break;
      }
    }
    
    // Append the new transaction data to the precisely targeted row
    var targetRange = targetSheet.getRange(nextRow, 1, 1, rowData.length);
    targetRange.setValues([rowData]);
    
    // Enforce the custom font styling on the newly added row
    targetRange.setFontFamily(namaFont).setFontSize(ukuranData);
    
  } catch(error) {
    Logger.log("An error occurred: " + error.toString());
  }
}
