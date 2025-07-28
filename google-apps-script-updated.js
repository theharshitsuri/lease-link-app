/**
 * Updated Google Apps Script for LeaseLink Waitlist with CORS support
 * 
 * Instructions:
 * 1. Go to your Google Sheet
 * 2. Click Extensions → Apps Script
 * 3. Replace the existing code with this code
 * 4. Deploy as a web app
 * 5. Update the URL in your React app
 */

function doPost(e) {
  try {
    // Set CORS headers
    const headers = {
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type',
      'Content-Type': 'application/json'
    };
    
    // Handle preflight OPTIONS request
    if (e.parameter.method === 'OPTIONS') {
      return ContentService
        .createTextOutput('')
        .setMimeType(ContentService.MimeType.TEXT)
        .setHeaders(headers);
    }
    
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
    
    // Return success response with CORS headers
    return ContentService
      .createTextOutput(JSON.stringify({ 'result': 'success' }))
      .setMimeType(ContentService.MimeType.JSON)
      .setHeaders(headers);
      
  } catch(error) {
    // Log error for debugging
    console.error('Error in doPost:', error);
    
    // Return error response with CORS headers
    return ContentService
      .createTextOutput(JSON.stringify({ 'result': 'error', 'error': error.toString() }))
      .setMimeType(ContentService.MimeType.JSON)
      .setHeaders({
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
        'Access-Control-Allow-Headers': 'Content-Type',
        'Content-Type': 'application/json'
      });
  }
}

function doGet(e) {
  return ContentService
    .createTextOutput('LeaseLink Waitlist API is running')
    .setMimeType(ContentService.MimeType.TEXT)
    .setHeaders({
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type'
    });
}

function doOptions(e) {
  return ContentService
    .createTextOutput('')
    .setMimeType(ContentService.MimeType.TEXT)
    .setHeaders({
      'Access-Control-Allow-Origin': '*',
      'Access-Control-Allow-Methods': 'POST, GET, OPTIONS',
      'Access-Control-Allow-Headers': 'Content-Type'
    });
} 