const http = require('http');

// Integration test for the application
function runIntegrationTest() {
    console.log('Starting integration test...');
    
    const options = {
        hostname: '127.0.0.1',
        port: 3000,
        path: '/',
        method: 'GET'
    };
    
    const req = http.request(options, (res) => {
        console.log(`Status Code: ${res.statusCode}`);
        
        let data = '';
        res.on('data', (chunk) => {
            data += chunk;
        });
        
        res.on('end', () => {
            console.log('Response:', data);
            console.log('Integration test completed successfully!');
        });
    });
    
    req.on('error', (error) => {
        console.error('Integration test failed:', error);
    });
    
    req.end();
}

// Export for use in other modules
module.exports = { runIntegrationTest };

// Run test if called directly
if (require.main === module) {
    runIntegrationTest();
}
