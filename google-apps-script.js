/**
 * Google Apps Script for LeaseLink Waitlist
 * 
 * Instructions:
 * 1. Go to your Google Sheet
 * 2. Click Extensions → Apps Script
 * 3. Replace the default code with this code
 * 4. Deploy as a web app
 * 5. Copy the web app URL and update script.js
 */

function doPost(e) {
  try {
    // Parse the JSON data from the request
    const data = JSON.parse(e.postData.contents);
    
    // Get the active spreadsheet and sheet
    const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
    const sheet = spreadsheet.getActiveSheet();
    
    // Prepare the row data (only email and timestamp)
    const rowData = [
      data.timestamp,
      data.email
    ];
    
    // Append the data to the sheet
    sheet.appendRow(rowData);
    
    // Return success response
    return ContentService
      .createTextOutput(JSON.stringify({ 'result': 'success' }))
      .setMimeType(ContentService.MimeType.JSON);
      
  } catch(error) {
    // Log error for debugging
    console.error('Error in doPost:', error);
    
    // Return error response
    return ContentService
      .createTextOutput(JSON.stringify({ 'result': 'error', 'error': error.toString() }))
      .setMimeType(ContentService.MimeType.JSON);
  }
}

function doGet(e) {
  return ContentService
    .createTextOutput('LeaseLink Waitlist API is running')
    .setMimeType(ContentService.MimeType.TEXT);
} 