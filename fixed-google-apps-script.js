function doPost(e) {
  try {
    let email, timestamp;
    
    if (e.postData && e.postData.contents) {
      const data = JSON.parse(e.postData.contents);
      email = data.email;
      timestamp = data.timestamp;
    } else if (e.parameter) {
      email = e.parameter.email;
      timestamp = e.parameter.timestamp || new Date().toISOString();
    } else {
      throw new Error('No data received');
    }
    
    if (!email) {
      throw new Error('Email is required');
    }
    
    const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
    const sheet = spreadsheet.getActiveSheet();
    
    const rowData = [
      timestamp,
      email
    ];
    
    sheet.appendRow(rowData);
    
    return ContentService
      .createTextOutput(JSON.stringify({ 'result': 'success' }))
      .setMimeType(ContentService.MimeType.JSON);
      
  } catch(error) {
    console.error('Error in doPost:', error);
    
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