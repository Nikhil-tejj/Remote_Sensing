const WebSocket = require('ws');

const wss = new WebSocket.Server({ port: 8081 });

let employees = [];
let idCounter = 1;

wss.on('connection', (ws) => {
    console.log('New client connected.');

    ws.on('message', (message) => {
        console.log(`Received: ${message}`);
        const parts = message.toString().split(' ');

        if (parts[0] === 'INSERT' && parts.length === 3) {
            const name = parts[1];
            const salary = parseInt(parts[2]);

            if (!isNaN(salary)) {
                employees.push({ id: idCounter++, name, salary });
                ws.send('Employee inserted successfully.');
            } else {
                ws.send('Invalid command.');
            }
        } else if (parts[0] === 'RETRIEVE' && parts.length === 1) {
            const response = employees.map(emp => `ID: ${emp.id}, Name: ${emp.name}, Salary: ${emp.salary}`).join('\n');
            ws.send(response || 'No employees found.');
        } else {
            ws.send('Invalid command.');
        }
    });

    ws.on('close', () => {
        console.log('Client disconnected.');
    });
});

console.log('WebSocket server is running on ws://localhost:8080');
