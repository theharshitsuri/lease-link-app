function doPost(e) {
  try {
    console.log('Request received:', e);
    
    let email = '';
    let timestamp = new Date().toISOString();
    
    if (e && e.postData && e.postData.contents) {
      const data = JSON.parse(e.postData.contents);
      email = data.email || '';
      timestamp = data.timestamp || timestamp;
    } else if (e && e.parameter) {
      email = e.parameter.email || '';
      timestamp = e.parameter.timestamp || timestamp;
    }
    
    console.log('Email:', email);
    console.log('Timestamp:', timestamp);
    
    if (!email) {
      throw new Error('Email is required');
    }
    
    const spreadsheet = SpreadsheetApp.getActiveSpreadsheet();
    const sheet = spreadsheet.getActiveSheet();
    
    sheet.appendRow([timestamp, email]);
    
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