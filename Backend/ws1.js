const WebSocket = require("ws");
const mongoose = require("mongoose");
const AutoIncrement = require("mongoose-sequence")(mongoose);

const server = new WebSocket.Server({ port: 8081 });

mongoose.connect("mongodb://localhost:27017/employeeManage").then(() => {
  console.log("Connected to mongoDB");
});

const employeeSchema = new mongoose.Schema({
  id: Number,
  name: String,
  salary: Number,
  role: String,
  department: String,
  experience: Number,
});

employeeSchema.plugin(AutoIncrement, { inc_field: "id" });
const Employee = mongoose.model("Employees", employeeSchema);

server.on("connection", (ws) => {
  console.log("Client connected");

  ws.on("message", async (message) => {
    console.log(`Received: ${message}`);
    const parts = message.toString().split(" ");
    const command = parts[0].toUpperCase();

    if (command === "INSERT" && parts.length === 6) {
      const name = parts[1];
      const salary = parseInt(parts[2]);
      const role = parts[3];
      const department = parts[4];
      const experience = parseInt(parts[5]);

      const newEmployee = new Employee({
        name: name,
        salary: salary,
        role: role,
        department: department,
        experience: experience,
      });
      await newEmployee.save();
      console.log(newEmployee);
      ws.send(`Employee inserted successfully. ID: ${newEmployee.id}`);
      console.log(`Employee inserted successfully. ID:${newEmployee.id}`);
    } else if (command === "RETRIEVE") {
      const employees = await Employee.find({});

      employees.forEach((emp) =>
        ws.send(
          `ID: ${emp.id}, Name: ${emp.name}, Salary: ${emp.salary}, Role: ${emp.role}, Department: ${emp.department}, Experience: ${emp.experience} years`
        )
      );
    } else if (command === "RETRIEVE_BY_DEPT" && parts.length === 2) {
      const employees = await Employee.find({ department: parts[1] });
      //   console.log(employees);
      employees.forEach((emp) =>
        ws.send(
          `ID: ${emp.id}, Name: ${emp.name}, Salary: ${emp.salary}, Role: ${emp.role}, Department: ${emp.department}, Experience: ${emp.experience} years`
        )
      );
    } else {
      ws.send("Invalid command.");
    }
  });

  ws.on("close", () => {
    console.log("Client disconnected");
  });
});

console.log("WebSocket server is running on ws://localhost:8080");